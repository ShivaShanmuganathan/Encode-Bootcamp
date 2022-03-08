# Tips and Tricks

**1. No need to initialize variables with default values**

If a variable is not set/initialized, it is assumed to have the default value (0, false, 0x0 etc depending on the data type). If you explicitly initialize it with its default value, you are just wasting gas.

```
uint256 hello = 0; //bad, expensive
uint256 world; //good, cheap
```

**2. Custom Errors**

Starting from Solidity v0.8.4, there is a convenient and gas-efficient way to explain to users why an operation failed through the use of custom errors. Until now, you could already use strings to give more information about failures (e.g., revert("Insufficient funds.");), but they are rather expensive, especially when it comes to deploy cost, and it is difficult to use dynamic information in them.

Custom errors are defined using the error statement, which can be used inside and outside of contracts (including interfaces and libraries).

``` 
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

error Unauthorized();

contract VendingMachine {
    address payable owner = payable(msg.sender);

    function withdraw() public {
        if (msg.sender != owner)
            revert Unauthorized();

        owner.transfer(address(this).balance);
    }
}

```

**3. Avoid repetitive checks**

There is no need to check the same condition again and again in different forms. Most common redundant checks are due to SafeMath library. SafeMath library checks for underflows and overflows by itself so you don’t need to check the variables yourself.
```
require(balance >= amount); 

//This check is redundant because the safemath subtract function used below already includes this check.

balance = balance.sub(amount);
```

**4. Calling internal functions is cheaper**

From inside a smart contract, calling its internal functions is cheaper than calling its public functions, because when you call a public function, all the parameters are again copied into memory and passed to that function. By contrast, when you call an internal function, references of those parameters are passed and they are not copied into memory again. This saves a bit of gas, especially when the parameters are big.

**5. Use external function modifier.**

For all the public functions, the input parameters are copied to memory automatically, and it costs gas. If your function is only called externally, then you should explicitly mark it as external. External function’s parameters are not copied into memory but are read from calldata directly. This small optimization in your solidity code can save you a lot of gas when the function input parameters are huge.


**6. Use Short Circuiting rules to your advantage.**

When using logical disjunction (||), logical conjunction (&&), make sure to order your functions correctly for optimal gas usage. In logical disjunction (OR), if the first function resolves to true, the second one won’t be executed and hence save you gas. In logical disjunction (AND), if the first function evaluates to false, the next function won’t be evaluated. Therefore, you should order your functions accordingly in your solidity code to reduce the probability of needing to evaluate the second function.


**7. Avoid changing storage data.**

Changing storage data costs a lot more gas than changing memory or stack variables so you should update the storage variable after all the calculations rather than updating it on every calculation. The following solidity code will help you understand the difference between a poor code and better-optimized code

```
contract Demo
{
    uint internal counter;
 
    // The below function updates the storage counter every time
    // This is a bad coding practice and should be avoided
    // as updating a storage variable is expensive
    function badFunction(){
        for (uint i = 0; i < 100; i++){
            counter++;
        }
    }
    
    // This function uses a stack variable, j for calculations
    // and updates the storage variable at the last.
    // it's cheaper as updating a stack variable is almost free
    function betterfunction(){
        uint j;
        for (uint i = 0; i < 100; i++){
            j++;
        }
        counter = j;
    }
    // I know, you don't need a loop for this :/
}
```

**8.  Always store the object in memory, and load it from there**

It is better to use MLOAD instead when possible,  instead of loading from storage using SLOAD. SLOAD costs more gas than MLOAD.

```
    // bad code
    uint256 percentage = 30;
    function splitAmountToOwnerAndSeller(uint256 amount)
        internal
        view
        returns (uint256 amountForSender, uint256 amountForOwner)
    {
        amountForSender = (amount * (100 - percentage)) / 100;
        amountForOwner = (amount * percentage) / 100;
    }
```
```
    // good code
    uint256 percentage = 30;
    function splitAmountToOwnerAndSeller(uint256 amount) internal view returns (uint256 amountForSender, uint256 amountForOwner)
    {
        uint256 ownerPercentage = percentage;
        amountForSender = (amount * (100 - ownerPercentage)) / 100;
        amountForOwner = (amount * ownerPercentage) / 100;
    }

```

**9. Make use of constant or immutable modifier when necessary**

Use a constant or immutable modifier when you need to instantiate a variable on creation or deployment and do not expect that variable to change.

```
// bad code
contract Token {
    uint8 VERSION = 1;
    uint256 decimals;
    constructor(uint256 val) {
      decimals = val;
    }
}
```

```

// good code
contract Token {
    uint8 constant VERSION = 1;
    uint256 immutable decimals;
    constructor(uint256 val) {
      decimals = val;
    }
}
```


Caveat to note is that constant variables cannot make reference to the state of the blockchain.
Example - block.timestamp, address(this).balance, block.number, msg.value, gasleft() nor call external contracts.

```
// This is not possible
uint256 constant VERSION = block.number
```

**10. Pack Structs Wisely**

Variable types
Size of common data types in Solidity

- uint256 is 32 bytes
- uint128 is 16 bytes
- uint64 is 8 bytes
- address (and address payable) is 20 bytes
- bool is 1 byte
- string is usually one byte per character

```
    // bad code
    // uses 3 storage slots [ storage slot is 32 bytes (256 bits) ]
    uint128 a;
    uint256 b;
    uint128 c;
```
```
    // good code
    // uses 2 storage slots [ storage slot is 32 bytes (256 bits) ]
    uint128 a;
    uint128 c;
    uint256 b;
```