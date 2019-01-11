pragma solidity ^0.4.25;
import "./condition.sol";

contract InteractionContract{
    uint256 n_parties;
    bool[] consentGiven;
    address[] parties;
    Condition[] conds;
    
    constructor(uint256 _n_parties, address[] _parties) public {
        n_parties = _n_parties;
        consentGiven = new bool[](n_parties);
        parties = new address[](n_parties);
        for (uint i = 0; i < _n_parties; i++){
            parties[i] = _parties[i];
        }
    }
    
    function consent() public {
        bool found;
        uint l = parties.length;
        for (uint i = 0; i < l; i++){
            if (msg.sender == parties[i]){
                found = true;
                break;
            }
        }
        require(
            found,
            "Not authorised"    
        );
        consentGiven[i]= true;
        bool fullConsent = true;
        for (i = 0; i < n_parties; i++){
            if (!(consentGiven[i])){
                fullConsent = false;
                break;
            }
        }
        if (fullConsent){
            exec();
        }
    }
    
    function addCond(uint _condType, address _payFrom, address _payTo, uint256 _amount) public {
        require(
            isRelevant(msg.sender),
            "Not authorised"
        );
        conds.push(new Condition(_condType, _payFrom, _payTo, _amount));
    }
    
    function nullifyCond(uint256 i) public {
        require(
            isRelevant(msg.sender),
            "Not authorised"
        );
        conds[i].nullify();
    }
    
    function getCond(uint256 i) view public returns (bool, uint, address, address, uint256, bool){
        return conds[i].get();
    }
    
    function exec() private {
        uint l = conds.length;
        for (uint i = 0; i < l; i++){
            Condition c = conds[i];
            if (!(c.getIsNull())){
                c.complete();
            }
        }
    }
    
    function isRelevant(address addr) view private returns(bool){
        bool found;
        for (uint i = 0; i < n_parties; i++){
            if (parties[i] == addr){
                found = true;
                break;
            }
        }
        return (found);
    }
}