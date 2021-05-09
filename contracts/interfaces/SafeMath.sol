// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

// does the simple math for the contracts
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function multiply(
        uint256 x,
        uint256 _numerator,
        uint256 _denominator
    ) internal pure returns (uint256) {
        return (x * _numerator) / _denominator;
    }

    /**
     * @dev this function will find the rate for the exchange. it will
     * multiply the amount by a factor of 3 so that we can get three decimals
     * on the front end, the return will need to be divided by 1000 to get the actual
     * number
    */
    function findRate(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a*(10 ** 3) / b;
        return c;

    }
<<<<<<< HEAD
<<<<<<< HEAD
=======
=======
>>>>>>> 3848d8968bfc3fce2fc9ef31cedf56cc186704a2

    function findFee(uint a) internal pure returns (uint) {
        return a / 200;
    }
<<<<<<< HEAD
>>>>>>> 356b79db46ddae412c8182ec59f278828bde0646
=======
>>>>>>> 3848d8968bfc3fce2fc9ef31cedf56cc186704a2
}
