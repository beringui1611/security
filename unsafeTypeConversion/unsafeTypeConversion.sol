// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


contract unsafe{
    function unsafeType(uint256 a) public returns(uint8){
        //conversao insegura para uint8
        return uint8(a);
    }
}