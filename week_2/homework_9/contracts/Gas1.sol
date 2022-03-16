// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "hardhat/console.sol";

contract GasContract is Ownable, EIP712{

    address immutable contractOwner;
    string private constant SIGNING_DOMAIN = "Lazy-Voucher";
    string private constant SIGNATURE_VERSION = "1";
    uint8 constant tradeFlag = 1;
    uint8 constant basicFlag = 0;
    uint8 constant dividendFlag = 1;
    uint8 constant adminLen = 5;
    
    uint256 public immutable totalSupply; // cannot be updated
    uint256 public paymentCounter;
    // 2 slots

    // address[5] public administrators; 
    mapping (address => bool) public admins;
    mapping(address => uint256) public balances;
    mapping(address => Payment[]) public payments;
    History[] public paymentHistory;
    // 20 bytes each
    // 5 slots

    struct Voucher {
        uint8 tier;
        address user;
        bytes signature;
    }
    
    struct Payment {
        uint256 paymentID; // 1 slot
        bool adminUpdated; // 1 bit
        PaymentType paymentType; 
        address recipient; // 20 bytes 
        bytes8 recipientName; // max 8 characters
        address admin; // administrators address
        uint256 amount; // 1 slot
    }

    struct History {
        address updatedBy;
        uint256 blockNumber;
        uint256 lastUpdate;        
    }

    enum PaymentType {
        Unknown,
        BasicPayment,
        Refund,
        Dividend,
        GroupPayment
    }

     // when a payment was updated
    
    event supplyChanged(address indexed, uint256 indexed);
    event Transfer(address recipient, uint256 amount);
    event PaymentUpdated(
        address admin,
        uint256 ID,
        uint256 amount,
        bytes8 recipient
    );
    event WhiteListTransfer(address indexed);

    error Unauthorized();
    error InsufficientBalance();
    error NameTooLong();
    error AmountTooLow();
    error IncompatibleTier();
    error IDError();
    error InvalidAddress();
    error InvalidSignature();

    constructor(address[] memory _admins, uint256 _totalSupply) 
    EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION) {
        
        contractOwner = msg.sender;
        totalSupply = _totalSupply;
        
        for (uint256 ii = 0; ii < adminLen; ++ii) 
        {
            address _admin = _admins[ii];
            if (_admin != address(0)) 
            {
                admins[_admin] = true;
                
                if (_admin == contractOwner) 
                {
                    balances[_admin] = _totalSupply;
                    emit supplyChanged(_admin, _totalSupply);
                } 
                
            }
        }
    
    }

    function transfer(
        address _recipient,
        uint256 _amount,
        string calldata _name
    ) public returns (bool) {
        
        if (balances[msg.sender] < _amount) {
            revert InsufficientBalance();
        }

        if (bytes(_name).length > 8) {
            revert NameTooLong();
        }

        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;
        emit Transfer(_recipient, _amount);
                
        payments[msg.sender].push(Payment(
            ++paymentCounter,
            false,
            PaymentType.BasicPayment,
            _recipient,
            bytes8(bytes(_name)),
            address(0),
            _amount));

        return true;   
    }


    function whiteTransfer(address _recipient, uint256 _amount, Voucher calldata _voucher) external {
        
        if (balances[msg.sender] < _amount) {
            revert InsufficientBalance();
        }

        if (_amount < 4) {
            revert AmountTooLow();
        }

        address signer = _verify(_voucher);

        if (signer != contractOwner) {
            revert InvalidSignature();
        }

        if(msg.sender != _voucher.user){
            revert InvalidAddress();
        }
        
        uint8 _tier = _voucher.tier;

        if(_tier > 254 || _tier == 0) {
            revert IncompatibleTier();
        }

        if (_tier > 3){
            _tier = 3;
        }
        
        uint sender_balance = balances[msg.sender];
        uint recipient_balance = balances[_recipient];

        sender_balance = sender_balance + _tier - _amount;
        recipient_balance = recipient_balance + _amount - _tier;

        balances[msg.sender] = sender_balance;
        balances[_recipient] = recipient_balance;
        
        emit WhiteListTransfer(_recipient);

    }

    function checkWhitelist(Voucher calldata _voucher) external view returns(uint256) {

        address signer = _verify(_voucher);

        if (signer != contractOwner) {
            revert InvalidSignature();
        }

        if(msg.sender != _voucher.user){
            revert InvalidAddress();
        }

        return _voucher.tier;

    }

    function getChainID() external view returns (uint256) {
        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }



    /// @notice Verifies the signature for a given Voucher, returning the address of the signer.
    function _verify(Voucher calldata voucher) internal view returns (address) {
        bytes32 digest = _hash(voucher);
        return ECDSA.recover(digest, voucher.signature);
    }

    /// @notice Returns a hash of the given Voucher, prepared using EIP712 typed data hashing rules.
    /// @param voucher A Voucher to hash.
    function _hash(Voucher calldata voucher) internal view returns (bytes32) {
        return _hashTypedDataV4(keccak256(abi.encode(
        keccak256("Voucher(uint8 tier,address user)"),
        voucher.tier,
        voucher.user
        )));
    }


    function getPaymentHistory()
        external
        view
        returns (History[] memory paymentHistory_)
    {
        return paymentHistory;
    }

    function balanceOf(address _user) external view returns (uint256) {
        return balances[_user];
    }

    function getTradingMode() external pure returns (bool) {
        
        if (tradeFlag == 1 || dividendFlag == 1) {
            
            return true;
        } else {

            return false;
        }

    }

    // assuming addHistory is an internal function, since it changes state and is called by updatePayment
    function addHistory(address _updateAddress)
        private
    {
        
        paymentHistory.push(History(
            _updateAddress,
            block.timestamp,
            block.number
        ));
        
    }

    function getPayments(address _user)
        external
        view
        returns (Payment[] memory payments_)
    {
        if (_user == address(0)) {
            revert InvalidAddress();
        }
        return payments[_user];
    }


    function updatePayment(
        address _user,
        uint256 _ID,
        uint256 _amount,
        PaymentType _type
    ) external {

        if(admins[msg.sender] == false && (msg.sender != contractOwner)) {
            revert Unauthorized();
        }
        
        if (_ID == 0) {
            revert IDError();
        }

        if (_amount == 0) {
            revert AmountTooLow();
        }

        if (_user == address(0)) {
            revert InvalidAddress();
        }

        
        
        for (uint256 ii = 0; ii < payments[_user].length; ++ii) {

            Payment storage _payment = payments[_user][ii];

            if (_payment.paymentID == _ID) {
                
                _payment.adminUpdated = true;
                _payment.paymentType = _type;
                _payment.admin = _user;
                _payment.amount = _amount;
                
                addHistory(_user);

                emit PaymentUpdated(
                    msg.sender,
                    _ID,
                    _amount,
                    _payment.recipientName
                );

                payments[_user][ii] = _payment;
            }

        }
    }

}