pragma solidity ^0.4.25;

contract Condition{
    bool isNull;
    uint condType;
    address payFrom;
    address payTo;
    uint256 amount;
    bool completed;
    
    constructor(uint256 _condType, address _payFrom, address _payTo, uint256 _amount) public {
        condType = _condType;
        payFrom = _payFrom;
        payTo = _payTo;
        amount = _amount;
    }
    
    function nullify() public {
        isNull = true;
    }
    
    function complete() public {
        completed = true;
    }
    
    function get() view public returns(bool, uint, address, address, uint256, bool){
        return(isNull, condType, payFrom, payTo, amount, completed);
    }
    
    function getIsNull() view public returns(bool){
        return isNull;
    }
}
