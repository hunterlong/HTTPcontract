pragma solidity ^0.4.15;

contract RemoteContract {
    function callback(uint id, string value);
}

contract HTTP {
    
    address public owner;
    address public responder;
    uint public callbackCost;
    uint public cost;
    uint private sentAmount;
    bool public enabled;
    
    event NewRequestCallback(uint id, string url, string method, string data, string variable, address toAddress);
    event NewRequest(uint id, string url, string method, string data);
    
    function HTTP() {
        owner = msg.sender;
        enabled = true;
        cost = 0;
        callbackCost = 0;
        responder = 0xa82ee9C06b39bdE11653aEB5671FB97B2267d3Cd;
    }
    
    function getCallbackCost() constant returns (uint){
        return callbackCost;
    }
    
    function getCost() constant returns (uint){
        return cost;
    }
    
    function isEnabled() constant returns (bool){
        return enabled;
    }
    
    function getResponder() constant returns (address) {
        return responder;
    }
    
    function changeResponder(address newResponder) external {
        require(msg.sender==owner);
        responder = newResponder;
    }
    
    function changeCost(uint newCost, uint newCallbackCost) external {
        require(msg.sender==owner || msg.sender==responder);
        cost = newCost;
        callbackCost = newCallbackCost;
    }
    
    function changeOwner(address newOwner) external {
        require(msg.sender==owner);
        owner = newOwner;
    }
    
    function disableContract(bool enable) external {
        require(msg.sender==owner);
        enabled = enable;
    }
    
    function() payable {
        revert();
    }
    
    function request(string url, string method, string data) payable external returns (uint id) {
        require(msg.value==cost && enabled);
        sendToResponder(cost);
        sentAmount++;
        NewRequest(sentAmount, url, method, data);
        return sentAmount;
    }
    
    function requestCallback(string url, string method, string data, string variable, address toAddress) payable external returns (uint id) {
        require(msg.value==callbackCost && enabled);
        sendToResponder(callbackCost);
        sentAmount++;
        NewRequestCallback(sentAmount, url, method, data, variable, toAddress);
        return sentAmount;
    }
    
    function sendToResponder(uint amount) internal {
        responder.transfer(amount);
    }
    
    function kill() {
        require(msg.sender==owner);
        suicide(msg.sender);
    }
    
}
