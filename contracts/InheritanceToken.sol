// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract InheritanceToken is ERC20 {
    constructor() ERC20("InheritanceToken", "IT") {
       
    }

    function mintToAddress(address _address) external {
        _mint(_address, 100000*10**18);
    }

    function getBalance(address _address) external view returns(uint) {
       return balanceOf(_address);
    }
}