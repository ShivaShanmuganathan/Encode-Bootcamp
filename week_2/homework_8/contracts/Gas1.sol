// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

// contract Constants {
    
//     uint8 constant tradeFlag = 1;
//     uint8 constant basicFlag = 0;
//     uint8 constant dividendFlag = 1;
    
// }

contract GasContract is Ownable{
    
    error Unauthorized();
    error InsufficientBalance();
    error NameTooLong();
    error AmountTooLow();
    error IncompatibleTier();
    error IDError();
    error InvalidAddress();
    
    uint256 public immutable totalSupply; // cannot be updated
    uint256 public paymentCounter;

    address[5] public administrators; 
    address immutable contractOwner;
    uint8 constant tradeFlag = 1;
    uint8 constant basicFlag = 0;
    uint8 constant dividendFlag = 1;
    

    enum PaymentType {
        Unknown,
        BasicPayment,
        Refund,
        Dividend,
        GroupPayment
    }

    // PaymentType constant defaultPayment = PaymentType.Unknown;

    mapping(address => uint256) public balances;
    mapping(address => Payment[]) public payments;
    History[] public paymentHistory; // when a payment was updated
    mapping(address => uint8) public whitelist;

    struct Payment {
        uint256 paymentID;
        bool adminUpdated;
        PaymentType paymentType;
        address recipient;
        bytes8 recipientName; // max 8 characters
        address admin; // administrators address
        uint256 amount;
    }

    struct History {
        uint256 blockNumber;
        uint256 lastUpdate;
        address updatedBy;
    }

    event AddedToWhitelist(address userAddress, uint8 tier);

    modifier onlyAdminOrOwner() {

        if(checkForAdmin(msg.sender)) {
            _;
        }
        else if(msg.sender == contractOwner) {
            _;
        }
        else{
            revert Unauthorized();
        }

    }

    event supplyChanged(address indexed, uint256 indexed);
    event Transfer(address recipient, uint256 amount);
    event PaymentUpdated(
        address admin,
        uint256 ID,
        uint256 amount,
        bytes8 recipient
    );
    event WhiteListTransfer(address indexed);

    constructor(address[] memory _admins, uint256 _totalSupply) {
        
        contractOwner = msg.sender;
        totalSupply = _totalSupply;

        for (uint256 ii = 0; ii < administrators.length; ii++) {

            if (_admins[ii] != address(0)) {
                
                administrators[ii] = _admins[ii];

                if (_admins[ii] == msg.sender) {
                
                    balances[msg.sender] = _totalSupply;
                    emit supplyChanged(_admins[ii], _totalSupply);

                } 

                else {

                    balances[_admins[ii]] = 0;
                    emit supplyChanged(_admins[ii], 0);

                }

            }
        }
    
    }

    function getPaymentHistory()
        public
        returns (History[] memory paymentHistory_)
    {
        return paymentHistory;
    }

    function checkForAdmin(address _user) public view returns (bool) {
        
        for (uint256 ii = 0; ii < administrators.length; ii++) {
            if (administrators[ii] == _user) {
                return true;
            }
        }
        return false;
        
    }

    function balanceOf(address _user) public view returns (uint256) {
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
        internal
    {
        History memory history;
        history.blockNumber = block.number;
        history.lastUpdate = block.timestamp;
        history.updatedBy = _updateAddress;
        paymentHistory.push(history);
        
    }

    function getPayments(address _user)
        public
        view
        returns (Payment[] memory payments_)
    {
        if (_user == address(0)) {
            revert InvalidAddress();
        }
        return payments[_user];
    }

    function transfer(
        address _recipient,
        uint256 _amount,
        string memory _name
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
        
        Payment memory payment;
        payment.paymentType = PaymentType.BasicPayment;
        payment.recipient = _recipient;
        payment.amount = _amount;
        payment.recipientName = bytes8(bytes(_name));
        payment.paymentID = ++paymentCounter;
        payments[msg.sender].push(payment);
        return true;
        
    }

    function updatePayment(
        address _user,
        uint256 _ID,
        uint256 _amount,
        PaymentType _type
    ) public onlyAdminOrOwner {
        
        if (_ID == 0) {
            revert IDError();
        }

        if (_amount == 0) {
            revert AmountTooLow();
        }

        if (_user == address(0)) {
            revert InvalidAddress();
        }

        for (uint256 ii = 0; ii < payments[_user].length; ii++) {
            if (payments[_user][ii].paymentID == _ID) {
                payments[_user][ii].adminUpdated = true;
                payments[_user][ii].admin = _user;
                payments[_user][ii].paymentType = _type;
                payments[_user][ii].amount = _amount;
                // bool tradingMode = getTradingMode();
                addHistory(_user);
                emit PaymentUpdated(
                    msg.sender,
                    _ID,
                    _amount,
                    payments[_user][ii].recipientName
                );
            }
        }
    }

    function addToWhitelist(address _userAddrs, uint8 _tier)
        public
        onlyAdminOrOwner
    {

        if(_tier > 254 || _tier == 0) {
            revert IncompatibleTier();
        }
        
        if (_tier >= 3 ){
            whitelist[_userAddrs] = 3; 
        }

        else{
            whitelist[_userAddrs] = _tier;
        }

        emit AddedToWhitelist(_userAddrs, _tier);
    }

    function whiteTransfer(address _recipient, uint256 _amount) public {
        
        if (balances[msg.sender] < _amount) {
            revert InsufficientBalance();
        }

        if (_amount < 4) {
            revert AmountTooLow();
        }

        uint sender_balance = balances[msg.sender];
        uint recipient_balance = balances[_recipient];

        sender_balance = sender_balance + whitelist[msg.sender] - _amount;
        recipient_balance = recipient_balance + _amount - whitelist[msg.sender] ;

        balances[msg.sender] = sender_balance;
        balances[_recipient] = recipient_balance;
        
        emit WhiteListTransfer(_recipient);

    }
}