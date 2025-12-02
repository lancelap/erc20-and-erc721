// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {IERC20} from "./IERC20.sol";

error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);
error ERC20InvalidSender(address sender);
error ERC20InvalidReceiver(address receiver);
error ERC20InsufficientAllowance(
    address spender,
    uint256 allowance,
    uint256 needed
);
error ERC20InvalidApprover(address approver);
error ERC20InvalidSpender(address spender);

contract MyTokenERC20 is IERC20 {
    string public override name;
    string public override symbol;
    uint8 public override decimals;
    uint256 public override totalSupply;

    mapping(address account => uint256 balance) public override balanceOf;
    mapping(address owner => mapping(address spender => uint256) allowance)
        public
        override allowance;

    modifier checkTransfer(
        address from,
        address to) {
        if (from == address(0)) {
            revert ERC20InvalidSender(from);
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(to);
        }        
        _;
    }

    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        uint256 totalAmount = 100_000_000 * (10 ** _decimals);
        balanceOf[msg.sender] = totalAmount;
        totalSupply = totalAmount;

        emit Transfer(address(0), msg.sender, totalAmount);
    }

    function transfer(
        address to,
        uint256 value
    ) public override returns (bool success) {
        _sendTokens(msg.sender, to, value);

        return true;
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool success) {
        if (spender == address(0)) {
            revert ERC20InvalidSpender(spender);
        }

        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public  override checkTransfer(from, to) returns (bool success)  {
        uint256 allowed = allowance[from][msg.sender];

        if (from != msg.sender) {
            uint256 _allowance = allowance[from][msg.sender];
            if (_allowance < amount) {
                revert ERC20InsufficientAllowance(
                    msg.sender,
                    _allowance,
                    amount
                );
            }
            unchecked { allowance[from][msg.sender] = allowed - amount; }
        }

        _sendTokens(from, to, amount);

        return true;
    }

    function _sendTokens(address from, address to, uint256 amount) checkTransfer(from, to) internal {
        uint256 balance = balanceOf[from];

        if (balance < amount) {
            revert ERC20InsufficientBalance(from, balance, amount);
        }

        unchecked {
            balanceOf[from] = balance - amount;
        }
        balanceOf[to] += amount;

        emit Transfer(from, to, amount);
    }
}
