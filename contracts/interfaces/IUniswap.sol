// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

abstract contract IUniswap {

    function getAmountsOut(uint amountIn, address[] calldata path) external view virtual returns (uint[] memory amounts);
}
