// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {TokenSale} from "../src/TokenSale.sol";

contract TokenSaleTest is Test {
    TokenSale public tokenSale;
    address owner;
    function setUp() public {
        owner = address(1);
        uint256 _presaleMinCap = 10;
        uint256 _publicSaleMinCap = 10;
        uint256 _presaleMaxCap = 100;
        uint256 _publicSaleMaxCap = 100;
        uint256 _presaleMinContribution = 1;
        uint256 _presaleMaxContribution = 100;
        uint256 _publicSaleMinContribution = 1;
        uint256 _publicSaleMaxContribution = 100;
        uint256 _presaleStartTime = block.timestamp;
        uint256 _presaleEndTime = block.timestamp + 3600;
        uint256 _publicSaleStartTime = _presaleEndTime + 3600;
        uint256 _publicSaleEndTime = _publicSaleStartTime + 3600;
        tokenSale = new TokenSale(_presaleMinCap,
        _publicSaleMinCap,
        _presaleMaxCap,
        _publicSaleMaxCap,
        _presaleMinContribution,
        _presaleMaxContribution,
        _publicSaleMinContribution,
        _publicSaleMaxContribution,
        _presaleStartTime,
        _presaleEndTime,
        _publicSaleStartTime,
        _publicSaleEndTime);
    
}
}
