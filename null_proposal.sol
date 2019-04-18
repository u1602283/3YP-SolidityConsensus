pragma solidity ^0.4.25;

//A simple class that represents a proposal to nullify a condition.
contract ProposedNull{
    uint256 idx;
    bool[] consent;
    bool public allAgreed;
    uint256 n_parties;
    
    constructor(uint256 _idx, uint256 _n_parties) public {
        idx = _idx;
        consent = new bool[](_n_parties);
        n_parties = _n_parties;
    }
    
    //Allows a user to agree to a null proposal
    function giveConsent(uint i) public returns(bool){
        //If this check has been previously completed, skip the check to save gas
        if (allAgreed) {
            return true;
        }
        //Check to see if consent has been given by all parties
        consent[i] = true;
        for (uint j = 0; j < n_parties; j++){
            if (!(consent[j])){
                return false;
            }
        }
        allAgreed = true;
        return allAgreed;
    }
    
    //Used for debugging purposes
    function get() view public returns(bool[]){
        return consent;
    }
}
