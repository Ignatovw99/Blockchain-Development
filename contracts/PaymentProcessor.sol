// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

contract PaymentProcessor {

    mapping(address customer => uint256 paymentAmounts) internal balances;
    mapping(address customer => uint256) private paymentsCount;

    error ZeroPaymentNotAllowed();
    error InsufficientFunds(uint256 available, uint256 requested);
    error RefundFailed(address customer, uint256 amount);
    error InsufficientBalance(address customer, uint256 amount);

    event PaymentReceived(address indexed customer, uint256 amount);
    event RefundProcessed(address indexed customer, uint256 amount);
    
    function receivePayment() external payable {
        if (msg.value == 0) {
            revert ZeroPaymentNotAllowed();
        }

        balances[msg.sender] += msg.value;
        _processPaymentAdditionally();

        emit PaymentReceived(msg.sender, msg.value);
    }

    function checkBalance(address customer) external view returns (uint256) {
        return balances[customer];
    }

    function refundPayment(uint256 amount) public virtual {
        address customer = msg.sender;
        _decreaseBalance(customer, amount);

        (bool success, ) = customer.call{value: amount}("");
        if (!success) {
            revert RefundFailed(customer, amount);
        }

        emit RefundProcessed(customer, amount);
    }

    function _decreaseBalance(address customer, uint256 amount) internal {
        if (balances[customer] < amount) {
            revert InsufficientBalance(customer, amount);
        }
        balances[customer] -= amount;
    }

    function _processPaymentAdditionally() internal virtual {
        paymentsCount[msg.sender]++;
    }
}

contract Merchant is PaymentProcessor {

    mapping(address customer => uint256) private loyaltyPoints;

    function checkCustomerLoyaltyPoints(address customer) external view returns (uint256) {
        return loyaltyPoints[customer];
    }
    
    function refundPayment(uint256 amount) public override {
        address customer = msg.sender;
        if (balances[customer] < amount) {
            revert InsufficientBalance(customer, amount);
        }

        uint256 bonus;

        if (loyaltyPoints[customer] > 15) {
            bonus = amount * 1 / 100;
        }

        uint256 totalRefundAmount = amount + bonus;
        
        super.refundPayment(totalRefundAmount);
    }

    function _processPaymentAdditionally() internal override {
        loyaltyPoints[msg.sender] += loyaltyPoints[msg.sender] * 1 / 100 + 1;
    }
}