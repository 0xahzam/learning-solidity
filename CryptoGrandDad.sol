// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.7;

contract CryptoKids{
    // owner DAD
    address owner;

    event LogKidFundingRecieved(address addr, uint amount, uint contractBalance);

    constructor(){
        owner = msg.sender;
    }

    // define Kid

    struct Kid{
        address payable walletAddress;
        string firstName;
        string lastName;
        uint releaseTime;
        uint amount;
        bool canWithDraw;
    }

    Kid[] public kids;
    
    modifier onlyOwner(){
        require(msg.sender == owner, "Only owner can add kids");    
        _;
    }

    // add kid to contract

    function addKid(
        address payable walletAddress,
        string memory firstName,
        string memory lastName,
        uint releaseTime,
        uint amount,
        bool canWithDraw)
        public onlyOwner{
        kids.push(Kid(
            walletAddress,
            firstName,
            lastName,
            releaseTime,
            amount,
            canWithDraw
            ));
        }

    // deposit funds to contract, specifically to a kid's account
    function balanceOf() public view returns(uint){
        return address(this).balance;
    }    

    function deposite(address walletAddress) payable public{
        addToKidsBalance(walletAddress);
    }

    function addToKidsBalance(address walletAddress) private{
        for(uint i = 0; i < kids.length; i++){
            if(kids[i].walletAddress == walletAddress){
                kids[i].amount += msg.value;
                emit LogKidFundingRecieved(walletAddress, msg.value, balanceOf());
            }
        }
    }

    // kid checks if able to withdraw
    function getIndex(address walletAddress) view private returns(uint){
        for(uint i=0; i<kids.length; i++){
            if (kids[i].walletAddress == walletAddress){
                return i;
            }
        }

        return 999;
    }

    function availableToWithDraw(address walletAddress) public returns(bool){
        uint i = getIndex(walletAddress);
        require(block.timestamp > kids[i].releaseTime, " You are not eligible yet");
        if (block.timestamp > kids[i].releaseTime){
            kids[i].canWithDraw = true;
            return true;
        } else{
            return false;
        }
    }

    // withdraw money
    function withdraw(address payable walletAddress) payable public {
        uint i = getIndex(walletAddress);
        require(msg.sender == kids[i].walletAddress, "You must be the kid to withdraw");
        require(kids[i].canWithDraw == true, "You are not eligible yet");
        kids[i].walletAddress.transfer(kids[i].amount);
    }
}