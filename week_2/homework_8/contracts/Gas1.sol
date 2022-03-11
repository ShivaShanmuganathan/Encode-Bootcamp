// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "hardhat/console.sol";

contract GasContract is Ownable{
    
    uint256 public immutable totalSupply; // cannot be updated
    uint256 public paymentCounter;
    // 2 slots

    // address[5] public administrators; 
    mapping (address => bool) public admins;
    // 20 bytes each
    // 5 slots
    address immutable contractOwner;

    uint8 constant tradeFlag = 1;
    uint8 constant basicFlag = 0;
    uint8 constant dividendFlag = 1;
    uint8 constant adminLen = 5;

    bytes32 public whitelistMerkleRoot1;
    bytes32 public whitelistMerkleRoot2;
    bytes32 public whitelistMerkleRoot3;

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

    mapping(address => uint256) public balances;
    mapping(address => Payment[]) public payments;
    History[] public paymentHistory; // when a payment was updated
    mapping(address => uint8) public whitelist;

    event AddedToWhitelist(address userAddress, uint8 tier);
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

    modifier onlyAdminOrOwner() {

        if(admins[msg.sender] == false && (msg.sender != contractOwner)) {
            revert Unauthorized();
        }
        else{
            _;
        }

    }

    constructor(address[] memory _admins, uint256 _totalSupply) {
        
        contractOwner = msg.sender;
        totalSupply = _totalSupply;
        
        for (uint256 ii = 0; ii < adminLen; ii++) {
            address _admin = _admins[ii];
            if (_admin != address(0)) {
                admins[_admin] = true;
                
                if (_admin == contractOwner) {
                    balances[_admin] = _totalSupply;
                    emit supplyChanged(_admin, _totalSupply);
                } 
                
            }
        }
    
    }

    function addToWhitelist(bytes32 merkleRoot1, bytes32 merkleRoot2, bytes32 merkleRoot3) 
    external 
    onlyAdminOrOwner
    {
        whitelistMerkleRoot1 = merkleRoot1;
        whitelistMerkleRoot2 = merkleRoot2;
        whitelistMerkleRoot3 = merkleRoot3;
    }

    function checkWhitelist(address user, bytes32[] calldata merkleProof) 
    public
    view 
    returns (uint8)
    {
        if (MerkleProof.verify(
                merkleProof,
                whitelistMerkleRoot1,
                keccak256(abi.encodePacked(user))
        )){
            return 1;
        } 
        else if (MerkleProof.verify(
                merkleProof,
                whitelistMerkleRoot2,
                keccak256(abi.encodePacked(user))
        )){
            return 2;
        }
        else if (MerkleProof.verify(
                merkleProof,
                whitelistMerkleRoot3,
                keccak256(abi.encodePacked(user))
        )) {
            return 3;
        }

        else {
            return 0;
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
        
        // Payment memory payment;
        // payment = ;
        
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


    function whiteTransfer(address _recipient, uint256 _amount, bytes32[] calldata merkleProof) external {
        
        if (balances[msg.sender] < _amount) {
            revert InsufficientBalance();
        }

        if (_amount < 4) {
            revert AmountTooLow();
        }
        

        uint sender_balance = balances[msg.sender];
        uint recipient_balance = balances[_recipient];

        sender_balance = sender_balance + checkWhitelist(msg.sender, merkleProof) - _amount;
        recipient_balance = recipient_balance + _amount - checkWhitelist(msg.sender, merkleProof);

        balances[msg.sender] = sender_balance;
        balances[_recipient] = recipient_balance;
        
        emit WhiteListTransfer(_recipient);

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
    ) external onlyAdminOrOwner {
        
        if (_ID == 0) {
            revert IDError();
        }

        if (_amount == 0) {
            revert AmountTooLow();
        }

        if (_user == address(0)) {
            revert InvalidAddress();
        }
        uint usersCount = payments[_user].length;
        for (uint256 ii = 0; ii < usersCount; ii++) {

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