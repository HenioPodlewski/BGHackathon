pragma solidity ^0.4.25;
//import "./SafeMath.sol";
contract ElectionFactory {
    address[] public deployedElections;
    string name;
    string electionType;
    address theElectionOwner = msg.sender;

    function createElection(string memory name, string memory electionType, address theElectionOwner) public {
       address newElection = new Election(name, electionType, theElectionOwner);
       deployedElections.push(newElection);
    }

    function getDeployedElections() public view returns (address[] memory) {
        return deployedElections;
    }

}

contract Election {
    address public owner;
    string public name;
    string electionType;
    event ElectionResult(string candidateName, uint voteCount);

    struct Candidate {
        string name;
        uint voteCount;
        string constituency;
        string affiliation;
        bool paidup;
        bool authorized;
    }

    struct Voter {
        bool authorized;
        bool voted;
        uint vote;
        string constituency;
    }

    Candidate[] public candidates;
    //mapping(address => Candidate) public candidates;
    mapping(address => Voter) public voters;

    
    
    function Election(string memory _name, string memory _electionType, address campaignOwner) public {
        owner = campaignOwner;
        electionType = _electionType;
        name = _name;

        // candidates.push(Candidate(_candidate1, 0));
        // candidates.push(Candidate(_candidate2, 0));
    }
    
    // =================================
    // Events and modifiers
    // =================================
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    modifier notVoted() {
        require(!voters[msg.sender].voted);
        _;
    }
    modifier voterAuthorized() {
        require(voters[msg.sender].authorized);
        _;
    }

    // =================================
    // Functions
    // =================================

    function authorizeVoter(address _voter, string _constituency) public onlyOwner notVoted {
        voters[_voter].authorized = true;
        voters[_voter].constituency = _constituency;
    }
    function unAuthorizeVoter(address _voter) public onlyOwner notVoted voterAuthorized{
        voters[_voter].authorized = false;
    }
    
    // pay candidate fee
    uint candidateFee = 0.10 ether;

    function payCandidateFee(uint _candidate) public payable {
        // TODO add your code   - need to get last index to add as ballers parameter
        
        require(candidates[_candidate].paidup == false);
        require(msg.value == candidateFee);   //paid in ether
        owner.transfer(msg.value);
        candidates[_candidate].paidup = true;
    }
    
    function vote(uint _candidate) public notVoted voterAuthorized  {
        require(candidates[_candidate].paidup);
        require(candidates[_candidate].authorized);
        voters[msg.sender].vote = _candidate;
        voters[msg.sender].voted = true;

        candidates[_candidate].voteCount += 1;
    }

    function end() public {
        require(msg.sender == owner, "Only owner can end election");

        // Emit event for each candidates results
        for(uint i=0; i < candidates.length; i++){
            emit ElectionResult(candidates[i].name, candidates[i].voteCount);
        }
    }
}