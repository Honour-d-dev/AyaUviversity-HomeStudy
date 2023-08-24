// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

contract ElectoralVotingSystem {
  //can be modified to fit the required number of parties
  enum Party {
    partyA,
    partyB
  }

  struct VotingUnit {
    address[] voters;
    uint duration;
  }

  address admin;
  address[] moderators;
  VotingUnit[] units;
  mapping(Party => uint) noOfVotes;
  mapping(address => bool) voted;

  constructor() {
    admin = msg.sender;
  }

  function addModerator(address moderator) external {
    require(msg.sender == admin, "only admin can add moderators");
    moderators.push(moderator);
  }

  function isModerator() internal view returns (bool) {
    for (uint i; i < moderators.length; i++) {
      if (moderators[i] == msg.sender) {
        return true;
      }
    }
    return false;
  }

  function createUnit(address[] memory _voters, uint _duration) external returns (uint) {
    require(isModerator(), "Only moderators can create units");
    units.push(VotingUnit(_voters, block.timestamp + _duration));
    return units.length - 1;
  }

  function isUnitMember(uint unit) internal view returns (bool) {
    for (uint i; i < units[unit].voters.length; i++) {
      if (units[unit].voters[i] == msg.sender) {
        return true;
      }
    }
    return false;
  }

  function vote(Party party, uint unit) external {
    require(isUnitMember(unit), "Not a member of this unit");
    require(block.timestamp < units[unit].duration, "Voting has ended");
    require(!voted[msg.sender], "Voter has already voted");

    noOfVotes[party] += 1;
    voted[msg.sender] = true;
  }

  function result(Party party) external view returns (uint) {
    return noOfVotes[party];
  }
}
