// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract MultiSigWallet {
    address[] public owners;
    mapping(address => bool) public isOwner;
    uint256 public requiredSigns;
    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool isExected;
    }
    Transaction[] public transactions;
    mapping(uint256 => mapping(address => bool)) public approved;
    // 事件
    event Deposit(address indexed sender, uint256 amount);
    event Submit(uint256 indexed txId);
    event Approve(address indexed owner, uint256 indexed txId);
    event Revoke(address indexed owner, uint256 indexed txId);
    event Execute(uint256 indexed txId);

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    modifier onlyOwner() {
        require(isOwner[msg.sender], "You are not owner");
        _;
    }
    modifier txExists(uint256 _txId) {
        require(_txId < transactions.length, "tx doesn't exist");
        _;
    }
    modifier notApproved(uint256 _txId) {
        require(!approved[_txId][msg.sender], "tx already approved");
        _;
    }
    modifier notExecuted(uint256 _txId) {
        require(!transactions[_txId].isExected, "tx is exected");
        _;
    }

    constructor(address[] memory _owners, uint256 _requiredSigns) {
        require(_owners.length > 0, "Must be one owner at least");
        require(
            _requiredSigns > 0 && _requiredSigns <= _owners.length,
            "Invalid required signatures number of owners"
        );
        for (uint256 index = 0; index < _owners.length; index++) {
            address owner = _owners[index];
            require(owner != address(0), "Invalid owner address");
            require(!isOwner[owner], "Owner is not unique"); // 如果重复会抛出错误
            isOwner[owner] = true;
            owners.push(owner);
        }
        requiredSigns = _requiredSigns;
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function submit(address _to, uint256 _value, bytes calldata _data)
    external onlyOwner returns(uint256) {
        transactions.push(
            Transaction({to: _to, value: _value, data: _data, isExected: false})
        );
        emit Submit(transactions.length - 1);
        return transactions.length - 1;
    }

    function approve(uint256 _txId) external onlyOwner txExists(_txId) notApproved(_txId) 
    notExecuted(_txId) {
        approved[_txId][msg.sender] = true;
        emit Approve(msg.sender, _txId);
    }

    function execute(uint256 _txId) external onlyOwner txExists(_txId) notExecuted(_txId) {
        require(getApprovalCount(_txId) >= requiredSigns, "Approval count < required signatures");
        Transaction storage transaction = transactions[_txId];
        transaction.isExected = true;
        (bool sucess, ) = transaction.to.call{value: transaction.value}(transaction.data);
        require(sucess, "tx execute failed");
        emit Execute(_txId);
    }

    function getApprovalCount(uint256 _txId) public view returns(uint256 count) {
        for (uint256 index = 0; index < owners.length; index++) {
            if (approved[_txId][owners[index]]) {
                count += 1;
            }
        }
        return count;
    }

    function revoke(uint256 _txId) external onlyOwner txExists(_txId) notExecuted(_txId) {
        require(approved[_txId][msg.sender], "tx not approved");
        approved[_txId][msg.sender] = false;
        emit Revoke(msg.sender, _txId);
    }
}