// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

// making sure the tokens that are deposited follow the ERC20 format
abstract contract IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view virtual returns (uint256);

    function balanceOf(address account) external view virtual returns (uint256);

    function allowance(address owner, address spender) external view virtual returns (uint256);

    function transfer(address recipient, uint256 amount) external virtual returns (bool);

    function approve(address spender, uint256 amount) external virtual returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external virtual returns (bool);
}
