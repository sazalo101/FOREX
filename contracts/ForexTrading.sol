// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ForexTrading {
    address public owner;
    uint256 public feePercentage = 1; // 1% fee
    uint256 public rewardPercentage = 50; // 50% reward

    mapping(address => uint256) public userBalances;
    mapping(address => uint256) public userWinnings;

    struct Trade {
        address trader;
        uint256 amount;
        uint256 startTime;
        uint256 duration;
        bool isBuy;
        bool isActive;
        bool hasWithdrawn;
    }

    Trade[] public trades;

    event TradePlaced(address indexed trader, uint256 amount, uint256 duration, bool isBuy);
    event TradeResult(address indexed trader, uint256 amount, bool won, uint256 reward);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier onlyTrader(uint256 tradeIndex) {
        require(tradeIndex < trades.length, "Invalid trade index");
        require(trades[tradeIndex].trader == msg.sender, "Not authorized");
        _;
    }

    function placeTrade(uint256 amount, uint256 duration, bool isBuy) external payable {
        require(amount > 0, "Amount must be greater than 0");
        require(msg.value == amount, "Incorrect amount sent");
        require(duration == 1 minutes || duration == 3 minutes, "Invalid duration");

        uint256 fee = (amount * feePercentage) / 100;
        uint256 netAmount = amount - fee;

        // Store the fee
        userBalances[owner] += fee;

        // Store the trade
        trades.push(Trade({
            trader: msg.sender,
            amount: netAmount,
            startTime: block.timestamp,
            duration: duration,
            isBuy: isBuy,
            isActive: true,
            hasWithdrawn: false
        }));

        emit TradePlaced(msg.sender, netAmount, duration, isBuy);
    }

    function settleTrade(uint256 tradeIndex) external onlyTrader(tradeIndex) {
        require(tradeIndex < trades.length, "Invalid trade index");
        Trade storage trade = trades[tradeIndex];
        require(trade.isActive, "Trade is not active");
        require(block.timestamp >= trade.startTime + trade.duration, "Trade duration not over");
        require(!trade.hasWithdrawn, "Trade already settled");

        trade.isActive = false;
        trade.hasWithdrawn = true;

        // Simulate a price check - replace with real price check logic
        bool won = (trade.isBuy == (block.timestamp % 2 == 0)); // Dummy win/loss logic

        if (won) {
            uint256 reward = (trade.amount * rewardPercentage) / 100;
            uint256 totalPayout = trade.amount + reward;
            userWinnings[trade.trader] += totalPayout;
        } else {
            // The stake remains with the contract
        }

        emit TradeResult(trade.trader, trade.amount, won, won ? (trade.amount * rewardPercentage) / 100 : 0);
    }

    function withdrawWinnings() external {
        uint256 winnings = userWinnings[msg.sender];
        require(winnings > 0, "No winnings available");

        userWinnings[msg.sender] = 0;
        payable(msg.sender).transfer(winnings);
    }

    function withdrawFees() external onlyOwner {
        uint256 fees = userBalances[owner];
        require(fees > 0, "No fees available");

        userBalances[owner] = 0;
        payable(owner).transfer(fees);
    }
}
