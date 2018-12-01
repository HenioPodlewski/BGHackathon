pragma solidity ^0.4.25;

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
    }

    struct Voter {
        bool authorized;
        bool voted;
        uint vote;
        string constituency;
    }

    Candidate[] public candidates;
    mapping(address => Voter) public voters;

    function Election(string memory _name, string memory _electionType, address campaignOwner) public {
        owner = campaignOwner;
        electionType = _electionType;
        name = _name;

        // candidates.push(Candidate(_candidate1, 0));
        // candidates.push(Candidate(_candidate2, 0));
    }

    function authorize(address _voter, string _constituency) public {
        require(msg.sender == owner, "Only owner can authorize voting rights");
        require(!voters[_voter].voted, "Voter already voted");
        voters[_voter].authorized = true;
        voters[_voter].constituency = _constituency;
    }

    function vote(uint _candidate) public {
        require(voters[msg.sender].authorized, "Not authorized to vote");
        require(!voters[msg.sender].voted, "Voter already voted");
        require(_candidate < candidates.length, "Not a valid candidate");

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