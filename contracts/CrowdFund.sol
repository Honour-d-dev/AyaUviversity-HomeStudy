// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract CrowFund {
  struct Fundraiser {
    address beneficiary;
    uint target;
    uint deposited;
    uint duration;
    bool claimed;
  }

  Fundraiser[] fundraisers;
  mapping(uint => mapping(address => uint)) depositedAmount;

  function createFundraiser(uint _target, uint _duration) external returns (uint) {
    fundraisers.push(
      Fundraiser({
        beneficiary: msg.sender,
        target: _target,
        deposited: 0,
        duration: block.timestamp + _duration,
        claimed: false
      })
    );

    return fundraisers.length - 1;
  }

  function deposit(uint id) external payable {
    require(block.timestamp < fundraisers[id].duration, "fundraising has ended");
    fundraisers[id].deposited += msg.value;
    depositedAmount[id][msg.sender] += msg.value;
  }

  //to allow for values below 1 ether amounts should have a precision of 1o^3 ie 1ether = 1000
  function withdrawAmount(uint id, uint amount) external {
    amount *= 1e15; //converting to wei
    require(block.timestamp < fundraisers[id].duration, "fundraising has ended");
    require(amount <= depositedAmount[id][msg.sender], "insifficient balance");

    _withdraw(id, amount);
  }

  function withdraw(uint id) external {
    require(block.timestamp < fundraisers[id].duration, "fundraising has ended");

    uint amount = depositedAmount[id][msg.sender];
    require(amount > 0, "no Balance");

    _withdraw(id, amount);
  }

  function claim(uint id) external {
    require(msg.sender == fundraisers[id].beneficiary, " not the beneficiary");
    require(block.timestamp > fundraisers[id].duration, "fundraising hasn't ended");
    require(fundraisers[id].deposited >= fundraisers[id].target, "target not reached");
    require(!fundraisers[id].claimed, "already claimed");

    (bool sent, ) = msg.sender.call{value: fundraisers[id].deposited}("");
    require(sent);

    fundraisers[id].claimed = true;
  }

  function refund(uint id) external {
    require(block.timestamp > fundraisers[id].duration, "fundraising hasn't ended, use 'withdraw'");
    require(!fundraisers[id].claimed, "already claimed");
    require(fundraisers[id].deposited < fundraisers[id].target, "target was reached can't refund");
    uint amount = depositedAmount[id][msg.sender];
    require(amount > 0, "no Balance");

    _withdraw(id, amount);
  }

  function _withdraw(uint id, uint amount) internal {
    fundraisers[id].deposited -= amount;
    depositedAmount[id][msg.sender] -= amount;
    (bool sent, ) = msg.sender.call{value: amount}("");
    require(sent);
  }
}
