// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title IERC20
 * @dev Interface ERC20
 */
interface IERC20 {
    // Events
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value); 
    
    // Views: name, symbol, decimals, totalSupply, balanceOf, allowance
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    // Effects: transfer, approve, transferFrom
    function transfer(address _to, uint256 _amount) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool success);
    function approve(address _spender, uint256 _value) external returns (bool success);
}