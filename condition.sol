pragma solidity ^0.4.25;

//A fairly self-explanantory class that represents one condition within a contract.
//At this stage of development, it represents an agreed payment of some amount from one wallet address to another.
contract Condition{
    bool isNull;
    uint condType;
    address payFrom;
    address payTo;
    uint256 amount;
    bool completed;
    
    constructor(uint256 _condType, address _payFrom, address _payTo, uint256 _amount) public {
        condType = _condType; //Would be used if further developed to differentiate between Ethereum and real-life transactions
        payFrom = _payFrom;
        payTo = _payTo;
        amount = _amount;
    }
    
    //Used once everyone accepts a proposal to nullify a condition, prevents execution
    function nullify() public {
        isNull = true;
    }
    
    //Used during execution
    function complete() public {
        completed = true;
    }
    
    //Return all of the necessary details about a condition
    function get() view public returns(bool, uint, address, address, uint256, bool){
        return(isNull, condType, payFrom, payTo, amount, completed);
    }
    
    //Used during debugging
    function getIsNull() view public returns(bool){
        return isNull;
    }
}
