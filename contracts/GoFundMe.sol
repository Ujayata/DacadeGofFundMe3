// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DacadeGofFundMe {
    address public owner;
    uint256 public fundingGoal;
    uint256 public deadline;
    uint256 public amountRaised;
    mapping(address => uint256) public donations;
    bool public goalReached = false;

    event GoalReached(address recipient, uint256 totalAmountRaised);
    event FundTransfer(address backer, uint256 amount, bool isContribution);

    constructor(
        uint256 _fundingGoal,
        uint256 _durationInDays
    ) {
        owner = msg.sender;
        fundingGoal = _fundingGoal * 1 ether;
        deadline = block.timestamp + (_durationInDays * 1 days);
    }

    function contribute() public payable {
        require(block.timestamp < deadline, "The deadline has already passed.");
        require(msg.value > 0, "Donation amount must be greater than 0.");

        uint256 newAmountRaised = amountRaised + msg.value;
        require(newAmountRaised <= fundingGoal, "The funding goal has already been reached.");

        donations[msg.sender] += msg.value;
        amountRaised = newAmountRaised;

        emit FundTransfer(msg.sender, msg.value, true);

        if (amountRaised == fundingGoal && !goalReached) {
            goalReached = true;
            emit GoalReached(owner, amountRaised);
        }
    }

    function withdrawFunds() public {
        require(msg.sender == owner, "Only the contract owner can withdraw the funds.");
        require(goalReached, "The funding goal has not been reached yet.");

        payable(owner).transfer(amountRaised);
        amountRaised = 0;
    }

    function getRefund() public {
        require(block.timestamp > deadline, "The deadline has not passed yet.");
        require(!goalReached, "The funding goal has already been reached.");

        uint256 donation = donations[msg.sender];
        require(donation > 0, "The sender has not made a donation.");

        donations[msg.sender] = 0;
        payable(msg.sender).transfer(donation);

        emit FundTransfer(msg.sender, donation, false);
    }
}
