// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

contract Bank {
  //Bank ledger
  mapping(address => uint256) balance;

  //to allow for values below 1 ether amounts should have a precision of 1o^3 ie 1ether = 1000

  function withdraw(uint amount) external {
    amount *= 1e15; //converting back to wei
    require(amount <= balance[msg.sender], "insufficient ballance");
    (bool sent, ) = msg.sender.call{value: amount}("");
    require(sent);
    balance[msg.sender] -= amount;
  }

  function deposit() external payable {
    balance[msg.sender] += msg.value;
  }

  function transfer(address to, uint amount) external {
    amount *= 1e15;
    require(amount <= balance[msg.sender], "insufficient balance");
    (bool sent, ) = payable(to).call{value: amount}("");
    require(sent);
    balance[msg.sender] -= amount;
  }

  function checkBalance() external view returns (uint) {
    return balance[msg.sender] / 1e15;
  }
}
