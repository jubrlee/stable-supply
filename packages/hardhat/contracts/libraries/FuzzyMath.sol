// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "hardhat/console.sol";

/**
 * @dev provides some functions for maths that are illegal under solidity rules
 */
library FuzzyMath {

    /**
     * @dev estimates the equation f(x) = x^(a/b)^
     * does so by calculating x^a^ and iterating to the b-root of that subtotal
     * using a generalized form of the Babylonian Method
     * https://www.researchgate.net/publication/237415858_EXTENDING_THE_BABYLONIAN_ALGORITHM

     * NOTE: greater inputs could be considered if this function were used to
     * estimate exponential mappings with a limited number of sig-figs
     */ 
    function fraxExp(uint x, uint8 a, uint8 b) external view returns (uint ans)  {
        // constraints
        require(b < 10, "need exponent denominator b < 10");
        require(a < 10, "need exponent numerator a < 10");
        require(x < 1000000000, "maximum input is 1e9");

        if (x <= 1) return x;                   // shortcut this nonsense
        if (a % b == 0) return x ** (a / b);    // and this nonsense
        if (b % a == 0) (a, b) = (1, b / a);    // simplify

        uint subTotal = (a > 1) ? x**a : x;     // calculate subtotal with exponent numerator, prior to rooting
        ans = subTotal;                         // initial guess for answer
        if (b == 2) return sqrt(subTotal);      // shortcut square root case
        
        uint z = x**(a/b + 1) - 1;              // z < ans, always
        z = (z < 1000000000) ? z : 1000000000;  // potentially tighter guess, answer must be bounded by 1e9
        z = (z > 1000) ? 1000: z; 

        uint count = 0;
        uint8 b2 = b - 1;
        while (z < ans) {
            count++;
            console.log("loop",count);
            (ans, z) = (z, (subTotal / z**b2 + b2 * z) / b);
        }
    }

    /**
     * @dev estimates the square root of an input
     */
    function sqrt(uint x) public pure returns (uint ans) {
        ans = x;
        uint est = (x + 1) / 2; // intial guess, could be improved
        while (est < ans) {
            (ans, est) = (est, (x / est + est) / 2);
        }
    }
}