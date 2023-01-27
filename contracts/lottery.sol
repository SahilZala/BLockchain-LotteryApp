// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 < 0.9.0;

contract Lottery {
    struct LotterStruct {
        uint id;
        string lottery_name;
        string lottery_desc;
        uint lottery_fund;
        address payable winner;
        UserStruct[] users;
        bool active;
    }

    struct UserStruct{
        string user_name;
        address payable user_address;
    }

    address public manager;
    LotterStruct[] public lotterys;
    LotterStruct public ls;

    constructor(){
        manager = msg.sender;
    }

    function createLottery(uint id,string memory lname,string memory ldesc) public {
        require(msg.sender == manager,"only manager can create lottery!");
        ls.id = id;
        ls.lottery_name = lname;
        ls.lottery_desc = ldesc;
        ls.lottery_fund = 0;
        ls.active = true;
        lotterys.push(ls);
        delete ls;
    }

    function participate(uint lid,string memory name) public payable{
        if(msg.sender == manager)
        {
            revert(': manager cannot participate');
        }
        //require(msg.sender != manager,"manager cannot participate");
        //require(msg.value == 10000,"participate ammount should be 10000 wei");
        
        for(uint i=0;i<lotterys.length;i++)
        {
            if(lotterys[i].id == lid)
            {
                require(lotterys[i].active,'this lottery is not active');
                lotterys[i].users.push(UserStruct(name,payable(msg.sender)));
                lotterys[i].lottery_fund += msg.value;
                break;
            }
        }
    }

    function getBalance() view public returns(uint)
    {
        require(manager == msg.sender,"only manager can check balance");
        return address(this).balance;
    }

    function findLotteryIndex(uint lid) view public returns(uint){
        require(lotterys.length > 0,'no lotter is created at'); 
        for(uint i=0;i<lotterys.length;i++)
        {
            if(lotterys[i].id == lid)
            {      
                return i;
            }
        }
        require(false,'lottery not found');
        return 0;
    }


    function random(uint index) view public returns(uint){
        return uint(keccak256(abi.encodePacked(block.difficulty,block.timestamp,lotterys[index].users.length)))%lotterys[index].users.length;
    }

    function selectWinner(uint id) public{
        require(msg.sender == manager,'only manager can select winner');
        uint index =findLotteryIndex(id);
        require(lotterys[index].users.length >= 3,'very less number of participants has joined');
        uint r = random(index);
        lotterys[index].winner = lotterys[index].users[r].user_address;
        lotterys[index].winner.transfer(lotterys[index].lottery_fund);
        lotterys[index].active = false;
    }

    function getLotteryLength() view public returns(uint){
        return lotterys.length;
    }

    function getLotteryByIndex(uint index) view public returns(LotterStruct memory){
        return lotterys[index];
    }
}
