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
    event NewResponse(string response);
    
    string private url;
    
    
    function RemoteContract() {
        http = HTTPcontract(0xD0387B1F266da78d604446AF5744BeC4D0996987);
        validSender = http.getResponder();
        url = "https://www.random.org/integers/?num=1&min=1&max=100&col=1&base=10&format=plain&rnd=new";
    }
    
    function SendIt() external {
        url = "https://www.random.org/integers/?num=1&min=1&max=100&col=1&base=10&format=plain&rnd=new";
        
        http.requestCallback(url, "POST", "", "all", this);
        
    }
    
    function callback(string response) external {
        require(msg.sender == validSender);
        NewResponse(response);
    }
    
    
}
