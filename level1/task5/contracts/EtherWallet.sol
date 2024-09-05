// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract EtherWallet {
    address public immutable owner;
    event Log(string funName, address from, uint256 value, bytes data);

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {
        emit Log("receive", msg.sender, msg.value, "");
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not owner!");
        _;
    }    

    function withdraw1() external onlyOwner {
        // owner.transfer 相比 msg.sender 更消耗Gas
        // owner.transfer(address(this).balance);
        payable(msg.sender).transfer(address(this).balance);
    }

    function withdraw2() external onlyOwner {
        bool success = payable(msg.sender).send(address(this).balance);
        require(success, "Send Failed");
    }

    function withdraw3() external onlyOwner {
        (bool success, ) = msg.sender.call{value: address(this).balance, gas: 300000}("");
        require(success, "Call Failed");
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}