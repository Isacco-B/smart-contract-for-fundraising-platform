// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract Crowdfunding {
    address public manager;
    uint public totalBalance;
    uint public goal;
    uint public donators;
    bool public fundsTransferred = false;
    enum Statuses {
        Open,
        Close
    }
    Statuses public currentStatus = Statuses.Open;

    constructor(uint _goal) {
        manager = msg.sender;
        goal = _goal;
    }

    modifier isManager() {
        require(manager == msg.sender, "Only the manager can call this function");
        _;
    }

    modifier isOpen() {
        require(currentStatus == Statuses.Open, "The Crowdfunding campaign is closed");
        _;
    }

    function donate() public payable isOpen {
        require(msg.value > 0, "Donation amount must be greater than 0");
        totalBalance += msg.value;
        donators++;
    }

    function withdrawFound() public isManager {
        require(currentStatus == Statuses.Close, "The Crowdfunding campaign is not closed");
        require(!fundsTransferred, "Funds already transferred");
        (bool success, ) = payable(manager).call{value: totalBalance}("");
        require(success, "Transfer failed");

        fundsTransferred = true;
    }

    function closeCampain() public isManager isOpen{
        require(checkGoalReached(), "Goal not reached yet");
        currentStatus = Statuses.Close;
    }

    function checkGoalReached() public view returns (bool) {
        return totalBalance >= goal;
    }

    function startNewCampain(uint _goal) public isManager {
        require(currentStatus == Statuses.Close, "The Crowdfunding campaign is not closed");
        require(fundsTransferred, "the funds have not yet been transferred");
        totalBalance = 0;
        donators = 0;
        goal = _goal;
        currentStatus = Statuses.Open;
        fundsTransferred = false;
    }
}

