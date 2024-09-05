// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract CrowdFunding {
    address public immutable beneficiary;   // 受益人
    uint256 public immutable fundingGoal;   // 筹资目标
    uint256 public fundingAmount;           // 当前募集到的金额
    mapping(address => uint256) public funders;//出资人
    mapping(address => bool) private fundersInserted;//出资人出资状态
    address[] public fundersKey; // 出资人地址集
    bool public AVAILABLED = true; // 状态-不用自销毁方法，使用变量来控制

    // 部署的时候，写入受益人+筹资目标数量
    constructor(address beneficiary_, uint256 fundingGoal_) {
        beneficiary = beneficiary_;
        fundingGoal = fundingGoal_;
    }

    //资助: 可用的时候才可以捐，合约关闭之后，就不能在操作了
    function contribute() external payable {
        require(AVAILABLED, "CrowdFunding is closed");
        uint256 potentialFundingAmount = fundingAmount + msg.value;
        uint256 refundAmount = 0;   //退款金额
        // 检查捐赠金额是否会超过目标金额
        if (potentialFundingAmount > fundingGoal) {
            refundAmount = potentialFundingAmount - fundingGoal;
            funders[msg.sender] += (msg.value - refundAmount);
            fundingAmount += (msg.value - refundAmount);
        } else {
            funders[msg.sender] += msg.value;
            fundingAmount += msg.value;
        }
        // 更新捐赠者信息
        if (!fundersInserted[msg.sender]) {
            fundersInserted[msg.sender] = true;
            fundersKey.push(msg.sender);
        }
        // 退还多余的金额给最后一位出资人
        if (refundAmount > 0) {
            payable(msg.sender).transfer(refundAmount);
        }
    }

    // 关闭合约
    function close() external returns(bool) {
        if(fundingAmount < fundingGoal){//不符合关系条件
            return false;
        }
        payable(beneficiary).transfer(fundingAmount);//目标达到，把款项转账给受益人
        fundingAmount = 0;
        AVAILABLED = false;//失效合约
        return true;
    }

    //获取出资人数
    function fundersLenght() public view returns(uint256) {
        return fundersKey.length;
    }
}