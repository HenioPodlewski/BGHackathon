pragma solidity ^0.4.25;

contract Election {
    address public owner;
    string public name;
    event ElectionResult(string candidateName, uint voteCount);

    struct Candidate {
        string name;
        uint voteCount;
    }

    struct Voter {
        bool authorized;
        bool voted;
        uint vote;
    }

    Candidate[] public candidates;
    mapping(address => Voter) public voters;

    constructor(string _name, string _candidate1, string _candidate2) public {
        owner = msg.sender;
        name = _name;

        candidates.push(Candidate(_candidate1, 0));
        candidates.push(Candidate(_candidate2, 0));
    }

    function authorize(address _voter) public {
        require(msg.sender == owner, "Only owner can authorize voting rights");
        require(!voters[_voter].voted, "Voter already voted");
        voters[_voter].authorized = true;
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
