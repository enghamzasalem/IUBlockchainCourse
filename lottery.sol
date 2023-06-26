// SPDX-License-Identifier: GPL-3.0
// credit to @danmory
pragma solidity >=0.7.0 <0.9.0;

contract Lottery {
    address public manager;
    address payable[] public players;
    address payable[] public luckyPlayers;
    
    constructor() {
        manager = msg.sender;
    }
    
    modifier restricted() {
        require(msg.sender == manager);
        _;
    }
    
    function enter() public payable {
        require(msg.value > .01 ether);
        if (isLuckyPlayer(msg.sender)) {
            luckyPlayers.push(payable(msg.sender));
            return;
        }
        players.push(payable(msg.sender));
    }
    
    // Recognized security concern: for sake of tutorial only
    function random() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players)));
    }
    
    function pickWinner() public restricted {
        address payable[] memory targetPlayers = players;
        if (luckyPlayers.length > 0) {
            targetPlayers = luckyPlayers;
        }
        uint index = random() % targetPlayers.length;
        targetPlayers[index].transfer(address(this).balance);
        players = new address payable[](0);
        luckyPlayers = new address payable[](0);
    }
    
    function getPlayers() public view returns (address payable[] memory) {
        return players;
    }

    function isLuckyPlayer(address player) private pure returns(bool) {
        string memory playerAddr = addressToString(player);
        if (stringsEqual(charAt(playerAddr, 0), "0") &&
            stringsEqual(charAt(playerAddr, 1), "x") && 
            (stringsEqual(charAt(playerAddr, 2), "d") || stringsEqual(charAt(playerAddr, 2), "f"))) {
            return true;
        }
        return false;
    }

    function charAt(string memory str, uint256 id) private pure returns (string memory char){
        bytes memory charByte = new bytes(1);
        charByte[0] = bytes(str)[id];
        return string(charByte);
    }

    function addressToString(address account) private pure returns(string memory) {
        return bytesToString(abi.encodePacked(account));
    }

    function bytesToString(bytes memory data) private pure returns(string memory) {
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint i = 0; i < data.length; i++) {
            str[2+i*2] = alphabet[uint(uint8(data[i] >> 4))];
            str[3+i*2] = alphabet[uint(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }

    function stringsEqual(string memory a, string memory b) private pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
}
