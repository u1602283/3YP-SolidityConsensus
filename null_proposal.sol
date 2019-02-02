pragma solidity ^0.4.25;

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
    
    function giveConsent(uint i) public returns(bool){
        if (allAgreed) {
            return true;
        }
        consent[i] = true;
        for (uint j = 0; j < n_parties; j++){
            if (!(consent[j])){
                return false;
            }
        }
        allAgreed = true;
        return allAgreed;
    }
    
    function get() view public returns(bool[]){
        return consent;
    }
}
