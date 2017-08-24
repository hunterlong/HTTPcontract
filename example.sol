pragma solidity ^0.4.15;


contract HTTPcontract {
    function getCallbackCost() constant returns (uint);
    function getCost() constant returns (uint);
    function isEnabled() constant returns (bool);
    function getResponder() constant returns (address);
    function request(string url, string method, string data) payable external returns (uint id);
    function requestCallback(string url, string method, string data, string variable, address toAddress) payable external returns (uint id);
}

contract RemoteContract {
    
    HTTPcontract public http;
    address private validSender;
    string private url;
    
    event NewResponse(string response);
        
    function RemoteContract() {
        http = HTTPcontract(0xD0387B1F266da78d604446AF5744BeC4D0996987);
        validSender = http.getResponder();
        url = "https://www.random.org/integers/?num=1&min=1&max=100&col=1&base=10&format=plain&rnd=new";
    }
    
        
    function changeUrl(string _url) {
        url = _url;
    }
    
    function doHTTP() payable external {
        uint cost = http.getCallbackCost();
        require(msg.value >= cost);
        url = "https://www.random.org/integers/?num=1&min=1&max=100&col=1&base=10&format=plain&rnd=new";
        validSender = http.getResponder();
        http.requestCallback.value(cost).gas(80000)(url, "POST", "", "all", this);
    }
    
    function callback(string response) external {
        require(msg.sender == validSender);
        NewResponse(response);
    }
    
    function kill() {
        suicide(msg.sender);
    }
    
    
}
