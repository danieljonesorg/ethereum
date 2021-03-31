
pragma solidity ^0.4.16;

interface token {
    function transfer(address receiver, uint amount) public;
    function balanceOf(address owner) public constant returns (uint balance);
}

contract CrowdDonation {
    address public owner;
    address public beneficiary;
    uint public amountRaised;
    uint public price;
    token public tokenReceipt;
    
    event FundTransfer(address dAddress, uint amount, bool isDonation);

    /**
     * Initialize CrowdDonation
     * 10 szabo is approximately $0.01 in early 2018
     */
    function CrowdDonation (
        address beneficiaryAddress,
        uint szaboCostOfEachToken,
        address receiptAddress
    ) public {
        owner = msg.sender;
        beneficiary = beneficiaryAddress;
        price = szaboCostOfEachToken * 1 szabo;
        tokenReceipt = token(receiptAddress);
    }

    modifier isOwner {
        assert(msg.sender == owner);
        _;
    }

    modifier isAllowed {
        assert(msg.sender == owner || msg.sender == beneficiary);
        _;
    }

    modifier isValidAddress(address target) {
        require(target != 0x0);
        _;
    }

    /* Withdraw receipt tokens and send ETH to beneficiary */
    function sunset() public 
        isOwner 
    {
        withdrawTokens();
        selfdestruct(beneficiary);
    }

    /* Change owner */
    function changeOwner(address newOwner) public 
        isOwner
        isValidAddress(newOwner) 
    {
        owner = newOwner;
    }

    /* Default function */
    function () public payable {
        uint amount = msg.value;
        amountRaised += amount;
        tokenReceipt.transfer(msg.sender, amount / price);
        FundTransfer(msg.sender, amount, true);
    }

    /* Contract ETH balance */
    function balanceOf() public constant returns (uint) {
        return address(this).balance;
    }

    /* Withdraw ETH */
    function withdrawBalance() public 
        isAllowed 
    {
        uint balance = address(this).balance;
        if (beneficiary.send(balance)) {
            FundTransfer(beneficiary, balance, false);
        }
    }

    /* Withdraw receipt tokens */
    function withdrawTokens() public
        isOwner 
    {
        tokenReceipt.transfer(owner, tokenReceipt.balanceOf(this));
    }
}
