// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract Bank is ERC20, Ownable {
    event Deposit(address from, uint256 amount);
    event Withdraw(address to, uint256 amount);

    constructor() ERC20("Bank", "BK") Ownable(msg.sender) { }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(address payable to) external onlyOwner {
        emit Withdraw(to, getBalance());
        to.transfer(getBalance());
        //selfdestruct(payable(owner()));
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
