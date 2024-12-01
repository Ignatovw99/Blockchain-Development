// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

struct Candidate {
    string name;
    uint256 voteCount;
}
struct Voter {
    uint16 age;
    bool isRegistered;
    bool hasVoted;
    uint256 chosenCandidate;
}

contract SimpleVoting {
    Candidate[] public candidates;
    mapping(address => Voter) public voters;
    bool public votingEnded;
    address public owner;

    uint256 private constant NO_CHOICE = type(uint256).max;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the owner of the smart contract can call this function"
        );
        _;
    }

    event VoteCasted(address indexed voter, uint256 candidateIndex);
    event VoterRegistered(address voter, uint256 age);

    function addCandidate(string memory name) public onlyOwner {
        require(!votingEnded, "Cannot add candidates after voting has ended");
        candidates.push(Candidate(name, 0));
    }

    function registerVoter(uint16 age) external {
        require(!votingEnded, "Voting has ended");
        require(
            !voters[msg.sender].isRegistered,
            "You are already registered voter"
        );

        voters[msg.sender] = Voter({
            age: age,
            isRegistered: true,
            hasVoted: false,
            chosenCandidate: NO_CHOICE
        });

        emit VoterRegistered(msg.sender, age);
    }

    function vote(uint256 candidateIndex) external {
        require(!votingEnded, "Voting has ended");
        require(candidateIndex < candidates.length, "Invalid candidate index.");

        Voter storage voter = voters[msg.sender];

        require(voter.isRegistered, "You are not registered to vode");
        require(!voter.hasVoted, "Double voting is not possible. You have already voted.");
        require(voter.age >= 18, "You must be at least 18 to vote");

        voter.hasVoted = true;
        voter.chosenCandidate = candidateIndex;
        candidates[candidateIndex].voteCount++;

        emit VoteCasted(msg.sender, candidateIndex);
    }

    function getVoterStatus()
        public
        view
        returns (
            uint16 age,
            bool isRegistered,
            bool hasVoted,
            uint256 chosenCandidate
        )
    {
        Voter memory voter = voters[msg.sender];

        return (
            voter.age,
            voter.isRegistered,
            voter.hasVoted,
            voter.chosenCandidate
        );
    }

    function getCandidatesCount() public view returns (uint256) {
        return candidates.length;
    }

    function getCandidate(uint256 candidateIndex)
        public
        view
        returns (string memory name, uint256 voteCount)
    {
        require(candidateIndex < candidates.length, "Invalid candidate index");
        Candidate storage candidate = candidates[candidateIndex];
        return (candidate.name, candidate.voteCount);
    }

    function endVoting() public onlyOwner {
        require(!votingEnded, "Voting is already ended");
        votingEnded = true;
    }

    function getWinner()
        external
        view
        returns (string memory name, uint256 voteCount)
    {
        require(votingEnded, "Voting is not yet ended");
        require(candidates.length > 0, "No candidates available");

        uint256 highestVoteCount;

        for (uint256 i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > highestVoteCount) {
                highestVoteCount = candidates[i].voteCount;
            }
        }

        uint256 winnerCount;
        uint256 winnerIndex;

        for (uint256 i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount == highestVoteCount) {
                winnerCount++;
                winnerIndex = i;
            }
        }

        require(
            winnerCount == 1,
            "More votes are needed to determine the winner."
        );

        Candidate storage winner = candidates[winnerIndex];
        return (winner.name, winner.voteCount);
    }
}
