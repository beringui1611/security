// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract IntegerOverflowUnderflow {
    uint8 public maxValue = 255;
    uint8 minValue = 0;


    function overflow() public {
        unchecked{
            maxValue = maxValue + 1;
        }

        //integer oveflow: estora a variavel fazendo voltar a zero
    }


    function underflow() public {
        unchecked{
            minValue = maxValue - 1;
        }

        //integer underflow: estora a capacidade de memoria fazendo ir ao maximo := 255
    }
}