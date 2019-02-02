pragma solidity ^0.4.25;
// pragma experimental ABIEncoderV2;
import "./condition.sol";
import "./null_proposal.sol";

contract InteractionContract{
    uint256 n_parties;
    bool[] consentGiven;
    address[] parties;
    Condition[] conds;
    ProposedNull[] nullProposals;
    mapping(address=>uint256) addrIdx;
    mapping(uint256=>uint256) isProposedNull;
    
    constructor(uint256 _n_parties, address[] _parties) public {
        n_parties = _n_parties;
        consentGiven = new bool[](n_parties);
        parties = new address[](n_parties);
        for (uint i = 0; i < _n_parties; i++){
            addrIdx[_parties[i]] = i + 1;
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
        consentGiven = new bool[](n_parties);
    }
    
    function proposeNullify(uint256 i) public returns (uint256){
        require(
            isRelevant(msg.sender),
            "Not authorised"
        );
        //Check if already null
        if (conds[i].getIsNull()){
            return;
        }
        //Check if already proposed
        if (isProposedNull[i] > 0){
            return;
        }
        nullProposals.push(new ProposedNull(i, n_parties));
        isProposedNull[i] = nullProposals.length;
        return nullProposals.length - 1;
    }
    
    function consentNullify(uint256 i) public{
        require(
            isRelevant(msg.sender),
            "Not authorised"
        );
        uint256 proposalN = isProposedNull[i];
        if (proposalN == 0){
            proposeNullify(i);
        }
        ProposedNull p = nullProposals[proposalN - 1];
        if (p.giveConsent(addrIdx[msg.sender] - 1)){
            conds[i].nullify();
        }
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
        return (addrIdx[addr] > 0);
    }

    // function get() view public returns(string[]){
        
    // }

}
