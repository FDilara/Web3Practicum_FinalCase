// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { SafeMath } from "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract InheritanceSharing {
    // For use mathematical operations
    using SafeMath for uint;

    //Events
    event PublishTestament(address _testatorAddress, uint _totalAmount);
    event ProofDeath(address _testatorAddress, address indexed _heirAddress, uint _proofTime);
    event ReceiptedInheritance(address _testatorAddress, address indexed _heirAddress, bool _isReceipted);
 
    //Information of a testator
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

    //Testament to an address
    mapping(address => Testator) public testators;
    //Proof of heir
    mapping(address => mapping(address => bool)) public proof;
    //Is inheritance receipted
    mapping(address => mapping(address => bool)) public isReceipted;
    //Heir proof count
    mapping(address => uint) public counter;
    
    //Address of the testators
    address[] public allTestators;

    //There is no data to write to state while deploying
    constructor() {}

    //Control to heir for inheritance
    modifier checkHeirAddress(address _heirAddress) {
        require(_heirAddress == msg.sender, "not heir address");
        _;
    }

    //Address that does not testament a publishs testament
    function publishTestament(address _inheritanceToken, address[] memory _heirs, uint _time, uint _totalAmount) external {
        Testator storage testator = testators[msg.sender];
        require(!testators[msg.sender].isPublished, "published");
        testator.isPublished = true;
        testator.inheritanceToken = _inheritanceToken;
        testator.heirs = _heirs;  
        testator.time = _time;
        testator.numberOfHeirs = testator.heirs.length;
        testator.totalAmount = _totalAmount;
        allTestators.push(msg.sender);
        ERC20 inheritanceToken = ERC20(testator.inheritanceToken);
        inheritanceToken.transferFrom(msg.sender, address(this), testator.totalAmount);

        emit PublishTestament(msg.sender, _totalAmount);
    }

    //Each heir proof the death of the testator
    function proofToDeath(address _testatorAddress, address _heirAddress) external checkHeirAddress(_heirAddress) {
        require(!testators[_testatorAddress].isDied, "died");
        require(!proof[_testatorAddress][_heirAddress], "proved");
        proof[_testatorAddress][_heirAddress] = true;
        counter[_testatorAddress] += 1;
        if(counter[_testatorAddress] == testators[_testatorAddress].numberOfHeirs) {
            testators[_testatorAddress].isDied = true;
            testators[_testatorAddress].inheritanceBeginTime = (block.timestamp).add(testators[_testatorAddress].time);
        }

        emit ProofDeath(_testatorAddress, _heirAddress, block.timestamp);
    }

    //Heir, receipts his inheritance
    function receiptToTestament(address _testatorAddress, address _heirAddress) external checkHeirAddress(_heirAddress) {
        require(testators[_testatorAddress].isDied, "did not die");
        require(block.timestamp >= testators[_testatorAddress].inheritanceBeginTime, "not inheritance time");
        require(!isReceipted[_testatorAddress][_heirAddress], "receipted");
        isReceipted[_testatorAddress][_heirAddress] = true;
        ERC20 inheritanceToken = ERC20(testators[_testatorAddress].inheritanceToken);
        inheritanceToken.transfer(_heirAddress, (testators[_testatorAddress].totalAmount.div(testators[_testatorAddress].numberOfHeirs)));
    
        emit ReceiptedInheritance(_testatorAddress, _heirAddress, true);
    }

    //Read address of all testators
    function viewTestators() external view returns (address[] memory) {
        return allTestators; 
    }

    //Read heirs address of all testators
    function allHeirs(address _testatorAddress) external view returns (address[] memory) {
        return testators[_testatorAddress].heirs; 
    }

    //Read the death information
    function died(address _testatorAddress) external view returns(bool) {
        return testators[_testatorAddress].isDied;
    }

    //Read the receipt information
    function receipt(address _testatorAddress, address _heirAddress) external view returns(bool) {
        return isReceipted[_testatorAddress][_heirAddress];
    }
}