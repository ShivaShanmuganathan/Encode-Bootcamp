// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract GasContract is Ownable{
    
    uint256 public immutable totalSupply; // cannot be updated
    uint256 public paymentCounter;
    // 2 slots

    address[5] public administrators; 
    // 20 bytes each
    // 5 slots
    address immutable contractOwner;

    uint8 constant tradeFlag = 1;
    uint8 constant basicFlag = 0;
    uint8 constant dividendFlag = 1;

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

    // PaymentType constant defaultPayment = PaymentType.Unknown;

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
        external
        view
        returns (History[] memory paymentHistory_)
    {
        return paymentHistory;
    }

    function checkForAdmin(address _user) private view returns (bool) {
        
        for (uint256 ii = 0; ii < administrators.length; ii++) {
            if (administrators[ii] == _user) {
                return true;
            }
        }
        return false;
        
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
        History memory history;
        history.blockNumber = block.number;
        history.lastUpdate = block.timestamp;
        history.updatedBy = _updateAddress;
        paymentHistory.push(history);
        
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
        
        Payment memory payment;
        payment = Payment({
            recipientName : bytes8(bytes(_name)),
            admin: address(0),
            paymentID : ++paymentCounter,
            amount :_amount,
            adminUpdated: false,
            recipient :_recipient,
            paymentType: PaymentType.BasicPayment
        });
        
        payments[msg.sender].push(payment);
        return true;
        
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
        
        for (uint256 ii = 0; ii < payments[_user].length; ii++) {

            Payment storage _payment = payments[_user][ii];

            if (_payment.paymentID == _ID) {
                
                _payment.adminUpdated = true;
                _payment.admin = _user;
                _payment.paymentType = _type;
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

    function addToWhitelist(address _userAddrs, uint8 _tier)
        external
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

    function whiteTransfer(address _recipient, uint256 _amount) external {
        
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