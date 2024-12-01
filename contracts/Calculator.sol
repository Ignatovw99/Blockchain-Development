// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

contract Calculator {
    
    function add(int256 x, int256 y) public pure returns (int256) {
        return x + y;
    }

    function subtract(int256 x, int256 y) public pure returns (int256) {
        return x - y;
    }

    function multiply(int256 x, int256 y) public pure returns (int256) {
        return x * y;
    }

    function divide(int256 x, int256 y) public pure returns (int256) {
        require(y != 0, "Division by zero is not allowed");
        return x / y;
    }
}