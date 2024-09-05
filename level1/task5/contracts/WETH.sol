// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract WETH {
    string public constant name = "Wrapped Ether";
    string public constant symbol = "WETH";
    uint8 public constant decimals = 18;
    address public owner;

    event Approval(address indexed from, address indexed spender, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Deposit(address indexed to, uint256 amount);
    event Withdraw(address indexed from, uint256 amount);

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor() {
        owner = msg.sender;
    }
    
    // modifier onlyOwner() {
    //     require(msg.sender == owner, "You are not owner");
    //     _;
    // }

    modifier checkBalance(address account, uint amount) {
        require(balanceOf[account] >= amount, "Insufficent funds");
        _;
    }

    function deposit() public payable {
        balanceOf[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) public checkBalance(msg.sender, amount) {
        balanceOf[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdraw(msg.sender, amount);
    }

    function totalSupply() public view returns (uint256) {
        return address(this).balance;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        return transferFrom(msg.sender, to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) public checkBalance(from, amount) returns (bool) {
        if (from != msg.sender) {
            require(allowance[from][msg.sender] >= amount);
            allowance[from][msg.sender] -= amount;
        }
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }

    fallback() external payable {
        deposit();
    }

    receive() external payable {
        deposit();
    }
}
