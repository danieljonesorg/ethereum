pragma solidity ^0.4.16;

interface token {
    function transfer(address receiver, uint amount) public;
}

contract CrowdDonation {
    address public beneficiary;
    uint public amountRaised;
    uint public price;
    token public tokenReward;
    
    event FundTransfer(address backer, uint amount, bool isContribution);

    /**
     * Constrctor function
     *
     * Setup the owner
     */
    function CrowdDonation (
        address beneficiaryAddress,
        uint szaboCostOfEachToken,
        address rewardAddress
    ) public {
        beneficiary = beneficiaryAddress;
        price = szaboCostOfEachToken * 1 szabo;
        tokenReward = token(rewardAddress);
    }

    /**
     * Fallback function
     *
     * The function without name is the default function that is called whenever anyone sends funds to a contract
     */
    function () public payable {
        uint amount = msg.value;
        amountRaised += amount;
        tokenReward.transfer(msg.sender, amount / price);
        FundTransfer(msg.sender, amount, true);
    }

    /**
     * Withdraw the funds
     */
    function safeWithdrawal() public {
        if (beneficiary == msg.sender) {
            beneficiary.transfer(amountRaised);
            FundTransfer(beneficiary, amountRaised, false);
        }
    }
}