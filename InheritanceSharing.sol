// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { SafeMath } from "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract InheritanceSharing {
    using SafeMath for uint;

    struct Testator {
        address inheritanceToken;
        address[] heirs;
        uint numberOfHeirs;
        uint totalAmount;
        uint time;
        uint inheritanceBeginTime;
        bool isPublished;
        bool isDied;
    }

    mapping(address => Testator) public testators;
    mapping(address => mapping(address => bool)) public proof;
    mapping(address => mapping(address => bool)) public isReceipted;
    mapping(address => uint) public counter;
    
    Testator[] public allTestators;

    function publishTestament(address _inheritanceToken, address[] memory _heirs, uint _time, uint _numberOfHeirs, uint _totalAmount) external {
        Testator storage testator = testators[msg.sender];
        require(!testators[msg.sender].isPublished, "published");
        testator.isPublished = true;
        testator.inheritanceToken = _inheritanceToken;
        testator.heirs = _heirs;  
        testator.time = _time;
        testator.numberOfHeirs = _numberOfHeirs;
        testator.totalAmount = _totalAmount;
        allTestators.push(testator);
        ERC20 inheritanceToken = ERC20(testator.inheritanceToken);
        inheritanceToken.transferFrom(msg.sender, address(this), testator.totalAmount);
    }

    function proofToDeath(address _testatorAddress, address _heirAddress) external {
        require(!testators[_testatorAddress].isDied, "died");
        require(_heirAddress == msg.sender, "not heir address");
        require(!proof[_testatorAddress][_heirAddress], "proved");
        proof[_testatorAddress][_heirAddress] = true;
        counter[_testatorAddress] += 1;
        if(counter[_testatorAddress] == testators[_testatorAddress].numberOfHeirs) {
            testators[_testatorAddress].isDied = true;
            testators[_testatorAddress].inheritanceBeginTime = (block.timestamp).add(testators[_testatorAddress].time);
        }
    }

    function receiptToTestament(address _testatorAddress, address _heirAddress) external {
        require(testators[_testatorAddress].isDied, "did not die");
        require(block.timestamp >= testators[_testatorAddress].inheritanceBeginTime, "not inheritance time");
        require(_heirAddress == msg.sender, "not heir address");
        require(!isReceipted[_testatorAddress][_heirAddress], "receipted");
        isReceipted[_testatorAddress][_heirAddress] = true;
        ERC20 inheritanceToken = ERC20(testators[_testatorAddress].inheritanceToken);
        inheritanceToken.transfer(_heirAddress, (testators[_testatorAddress].totalAmount.div(testators[_testatorAddress].numberOfHeirs)));
    }

    function viewTestators() external view returns (Testator[] memory) {
        return allTestators; 
    }

    function allHeirs(address _testatorAddress) external view returns (address[] memory) {
        return testators[_testatorAddress].heirs; 
    }

    function died(address _testatorAddress) external view returns(bool) {
        return testators[_testatorAddress].isDied;
    }
}