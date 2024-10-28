// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProjectIdeal {
    struct Project {
        address payable creator;
        string title;
        string description;
        uint fundingGoal;
        uint deadline;
        uint fundsRaised;
        bool withdrawn;
    }

    Project[] public projects;
    mapping(uint => mapping(address => uint)) public contributions;

    event ProjectCreated(uint projectId, address indexed creator, string title, uint fundingGoal, uint deadline);
    event ContributionMade(uint projectId, address indexed contributor, uint amount);
    event FundsWithdrawn(uint projectId, address indexed creator, uint amount);

    
    function submitProject(string memory _title, string memory _description, uint _fundingGoal, uint _deadline) public {
        require(_deadline > block.timestamp, "Deadline should be in the future");
        projects.push(Project({
            creator: payable(msg.sender),
            title: _title,
            description: _description,
            fundingGoal: _fundingGoal,
            deadline: _deadline,
            fundsRaised: 0,
            withdrawn: false
        }));
        
        emit ProjectCreated(projects.length - 1, msg.sender, _title, _fundingGoal, _deadline);
    }


    function fundProject(uint _projectId) public payable {
        require(_projectId < projects.length, "Project does not exist");
        Project storage project = projects[_projectId];
        require(block.timestamp < project.deadline, "Funding period has ended");
        require(msg.value > 0, "Contribution must be greater than zero");

        project.fundsRaised += msg.value;
        contributions[_projectId][msg.sender] += msg.value;
        
        emit ContributionMade(_projectId, msg.sender, msg.value);
    }

    
    function withdrawFunds(uint _projectId) public {
        require(_projectId < projects.length, "Project does not exist");
        Project storage project = projects[_projectId];
        require(msg.sender == project.creator, "Only creator can withdraw funds");
        require(block.timestamp > project.deadline, "Cannot withdraw before deadline");
        require(project.fundsRaised >= project.fundingGoal, "Funding goal not reached");
        require(!project.withdrawn, "Funds already withdrawn");

        project.withdrawn = true;
        project.creator.transfer(project.fundsRaised);

        emit FundsWithdrawn(_projectId, project.creator, project.fundsRaised);
    }

    
    function getProjectCount() public view returns (uint) {
        return projects.length;
    }

    // Get details of a specific project
    function getProject(uint _projectId) public view returns (
        address creator,
        string memory title,
        string memory description,
        uint fundingGoal,
        uint deadline,
        uint fundsRaised,
        bool withdrawn
    ) {
        require(_projectId < projects.length, "Project does not exist");
        Project storage project = projects[_projectId];
        return (
            project.creator,
            project.title,
            project.description,
            project.fundingGoal,
            project.deadline,
            project.fundsRaised,
            project.withdrawn
        );
    }
}
