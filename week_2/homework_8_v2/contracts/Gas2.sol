// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "hardhat/console.sol";

contract GasContract{
    using MerkleProof for bytes32[];

    bytes32 merkleRoot1;
    bytes32 merkleRoot2;
    bytes32 merkleRoot3;

    
    uint16 public immutable totalSupply; // cannot be updated
    uint16 private paymentCounter; 
    address immutable contractOwner;
    uint8 constant adminLen = 5;
    bytes32 public whitelistMerkleRoot;
    mapping (address => bool) public admins;
    

    struct Payment {
        uint256 amount; // 1 slot
        uint256 paymentID; // 1 slot
        bytes8 recipientName; // max 8 characters
        PaymentType paymentType; 
    }


    enum PaymentType {
        Unknown,
        BasicPayment,
        Refund,
        Dividend,
        GroupPayment
    }

    mapping(address => uint256) private balances;
    mapping(address => Payment[]) public payments;
    // History[] public paymentHistory; 
    // mapping(address => uint8) private whitelist;

    event AddedToWhitelist(address userAddress, uint8 tier);
    event supplyChanged(address indexed, uint256 indexed);
    event Transfer(address recipient, uint256 amount);
    // event PaymentUpdated(
    //     address user,
    //     uint256 ID,
    //     uint256 amount,
    //     bytes8 recipient
    // );
    event WhiteListTransfer(address indexed);

    error Unauthorized();
    error InsufficientBalance();
    error NameTooLong();
    error AmountTooLow();
    error IncompatibleTier();
    error IDError();
    error InvalidAddress();

    // modifier onlyAdminOrOwner() {

    //     if(admins[msg.sender] == false && (msg.sender != contractOwner)) {
    //         revert Unauthorized();
    //     }
    //     else{
    //         _;
    //     }

    // }

    constructor(address[] memory _admins, uint16 _totalSupply) {
        
        contractOwner = msg.sender;
        totalSupply = _totalSupply;
        
        for (uint8 ii = 0; ii < adminLen; ii++) {
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

    function whiteTransfer(address _recipient, uint256 _amount, bytes32[] calldata _merkleProof) external {
        
        if (balances[msg.sender] < _amount) {
            revert InsufficientBalance();
        }

        if (_amount < 4) {
            revert AmountTooLow();
        }
        uint8 _tier = 0;

        if (checkWhitelist(msg.sender, merkleRoot1,_merkleProof)){
            _tier = 1;
        }

        else if (checkWhitelist(msg.sender, merkleRoot2,_merkleProof)){
            _tier = 2;
        }
        else if (checkWhitelist(msg.sender, merkleRoot3,_merkleProof)){
            _tier = 3;
        }
        
        // require(, "not whitelisted");

        // if(_tier > 3){
        //     _tier =3;
        // }

        uint sender_balance = balances[msg.sender];
        uint recipient_balance = balances[_recipient];

        sender_balance = sender_balance + _tier - _amount;
        recipient_balance = recipient_balance + _amount - _tier;

        balances[msg.sender] = sender_balance;
        balances[_recipient] = recipient_balance;
        
        emit WhiteListTransfer(_recipient);

    }

    function addToWhitelist(bytes32 merkleRoot, uint8 _tier) 
    external 
    
    {
        if(_tier == 1) {
            merkleRoot1 = merkleRoot;
        }

        else if(_tier == 2) {
            merkleRoot2 = merkleRoot;
        }

        else if(_tier == 3) {
            merkleRoot3 = merkleRoot;
        }
        
        
    }

    function checkWhitelist(address user, bytes32 root, bytes32[] calldata merkleProof) 
    public
    view 
    returns (bool)
    {   
        bytes32  leafNode = bytes32(keccak256(abi.encodePacked(user)));
                
        return (MerkleProof.verify(
                merkleProof,
                root,
                leafNode
        ));
        
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
        
        
        // Payment memory payment;
        // payment = ;
        
        payments[msg.sender].push(Payment(
            _amount,
            paymentCounter+1,
            bytes8(bytes(_name)),
            PaymentType.BasicPayment));
            // _recipient,
            
            // address(0),
            // _amount));
        emit Transfer(_recipient, _amount);
        return true;   
    }


    


    // function getPaymentHistory()
    //     external
    //     view
    //     returns (History[] memory paymentHistory_)
    // {
    //     return paymentHistory;
    // }

    function balanceOf(address _user) external view returns (uint256) {
        return balances[_user];
    }

    function getTradingMode() external pure returns (bool) {
        
        // if (tradeFlag == 1 || dividendFlag == 1) {
            
        //     return true;
        // } else {

        //     return false;
        // }
        return true;

    }

    // assuming addHistory is an internal function, since it changes state and is called by updatePayment
    // function addHistory(address _updateAddress)
    //     private
    // {
        
    //     paymentHistory.push(History(
    //         _updateAddress,
    //         block.timestamp,
    //         block.number
    //     ));
        
    // }

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
        uint usersCount = payments[_user].length;
        for (uint256 ii = 0; ii < usersCount; ii++) {

            Payment storage _payment = payments[_user][ii];

            if (_payment.paymentID == _ID) {
                
                // _payment.adminUpdated = true;
                _payment.amount = _amount;
                _payment.paymentType = _type;
                break;
                // _payment.admin = _user;
                
                
                // addHistory(_user);

                // emit PaymentUpdated(
                //     msg.sender,
                //     _ID,
                //     _amount,
                //     _payment.recipientName
                // );

                // payments[_user][ii] = _payment;
                
            }

        }
    }

}