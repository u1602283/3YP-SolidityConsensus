pragma solidity ^0.4.25;
// The experimental ABIEnconderV2 would be used to return arrays of strings, it has high gas usage so was not used
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
    
    //Used for a user to agree to a contract overall, automatically executed once consent is received from all parties
    function consent() public {
        bool found;
        uint l = parties.length;
        //Check that a user is a relevant party in this contract
        for (uint i = 0; i < l; i++){
            if (msg.sender == parties[i]){
                found = true;
                break;
            }
        }
        //Fail if the user is not authorised
        require(
            found,
            "Not authorised"    
        );
        consentGiven[i]= true;
        bool fullConsent = true;
        //Check if everyone has agreed
        for (i = 0; i < n_parties; i++){
            if (!(consentGiven[i])){
                fullConsent = false;
                break;
            }
        }
        //If everyone has agreed, execute the contract
        if (fullConsent){
            exec();
        }
    }
    
    //Used to build uppon an existing contract, adding a condition/clause
    function addCond(uint _condType, address _payFrom, address _payTo, uint256 _amount) public {
        //Check to see if user is authorised
        require(
            isRelevant(msg.sender),
            "Not authorised"
        );
        //Add the new condition to the list
        conds.push(new Condition(_condType, _payFrom, _payTo, _amount));
        //Reset consent for the contract to allow parties to review the new condition
        consentGiven = new bool[](n_parties);
    }
    
    //Create a proposal to nullify a condition so that it will not be executed
    function proposeNullify(uint256 i) public returns (uint256){
        //Check to see if user is authorised
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
        //Add to the list of proposals
        nullProposals.push(new ProposedNull(i, n_parties));
        //Used to check if someone has already proposed that a condition be nullified
        isProposedNull[i] = nullProposals.length;
        return nullProposals.length - 1;
    }
    
    //Agree that a condition should be nullified (agreeing to a null proposal)
    function consentNullify(uint256 i) public{
        //Check to see if user is authorised
        require(
            isRelevant(msg.sender),
            "Not authorised"
        );
        //Check to see if someone has already proposed that the condition be nullified, if not, make the proposal
        uint256 proposalN = isProposedNull[i];
        if (proposalN == 0){
            proposeNullify(i);
        }
        //Find the proposal
        ProposedNull p = nullProposals[proposalN - 1];
        //Add this user's consent to the proposal
        if (p.giveConsent(addrIdx[msg.sender] - 1)){
            conds[i].nullify();
        }
    }
    
    //Simple getter for a single condition
    function getCond(uint256 i) view public returns (bool, uint, address, address, uint256, bool){
        return conds[i].get();
    }
    
    //Execute each of the conditions sequentially (nothing actually happens, as explained in the report, but each condition's
    //'completed' property is set to true if not nullified already
    function exec() private {
        uint l = conds.length;
        //Iterate over each of the conditions, first checking if it has been nullified
        for (uint i = 0; i < l; i++){
            Condition c = conds[i];
            if (!(c.getIsNull())){
                c.complete();
            }
        }
    }
    
    //Check if a user is relevant to a contract using a map for reduced gas cost.
    function isRelevant(address addr) view private returns(bool){
        return (addrIdx[addr] > 0);
    }

}
