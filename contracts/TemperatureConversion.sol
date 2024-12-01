// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

contract TemperatureConversion {
    
    function toFahrenheit(int256 celsius) public pure returns (int256) {
        return celsius * 9 / 5 + 32;
    }

    function toCelsius(int256 fahrenheit) public pure returns (int256) {
        return (fahrenheit - 32) * 5 / 9;
    }
}