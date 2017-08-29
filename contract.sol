pragma solidity ^0.4.16;

/*
    Copyright 2017, Hunter Long
    
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
    
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    
    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

/// @title HTTPcontract
/// @author Hunter Long
/// @dev This contract allows other contracts to do a HTTP POST or GET requests
/// and sends the response back to the contract. Much like Oraclize, but much 
/// cheaper and easier to use.
///
/// Example: 
/// http.request("http://md5.jsontest.com/?text=HelloEthereum", "GET", "", "md5", msg.sender);
///
/// Callback to contract (msg.sender)
/// Callback Response: "1ee615d87a9e555655b245f6d39bebc2"
///
/// Callback Function to include in your contract
/*
  function callback(uint id, string response) {
    require(msg.sender==http.getResponder());
    // your functionality inside of here!
  }
*/


contract HTTP {
    
    address public owner;
    address public responder;
    uint public callbackCost;
    uint public cost;
    uint private sentAmount;
    bool public enabled;

    event NewRequestCallback(uint id, string url, string method, string data, string variable, address toAddress);
    event NewRequest(uint id, string url, string method, string data);
    
    // @notice initialize HTTP contract and insert initial parameters
    function HTTP() {
        owner = msg.sender;
        enabled = true;
        cost = 0;
        callbackCost = 0;
        responder = 0xa82ee9C06b39bdE11653aEB5671FB97B2267d3Cd;
    }
    
    // @notice only allow owner to change contract details
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    // @notice get the HTTPcontract callback cost for a callback() back to your contract address (in wei)
    function getCallbackCost() constant returns (uint){
        return callbackCost;
    }
    
    // @notice get the cost for sending a HTTP request without callback (in wei)
    function getCost() constant returns (uint){
        return cost;
    }
    
    // @notice check if contract is enabled
    function isEnabled() constant returns (bool){
        return enabled;
    }
    
    // @notice get the address for the HTTP responder
    // be sure to verify msg.sender with this address inside your callback() function
    function getResponder() constant returns (address) {
        return responder;
    }
    
    // @notice change responder address
    function changeResponder(address newResponder) onlyOwner external {
        responder = newResponder;
    }
    
    // @notice change cost for a callback response
    function changeCost(uint newCost, uint newCallbackCost) onlyOwner external {
        cost = newCost;
        callbackCost = newCallbackCost;
    }
    
    // @notice change owner of contract
    function changeOwner(address newOwner) onlyOwner external {
        owner = newOwner;
    }
    
    // @notice disable contract from submitting any transactions
    function disableContract(bool enable) onlyOwner external {
        enabled = enable;
    }
    
    // @notice do not allow contract to just send ETH without contract call
    function() payable {
        revert();
    }
    
    /// @notice HTTP Request with POST or GET without callback() function
    /// @param url => the URL for your HTTP request
    /// @param method => choose "POST" or "GET"
    /// @param data => POST data to send to URL
    function request(string url, string method, string data) payable external returns (uint id) {
        require(msg.value==cost && enabled);
        sendToResponder(cost);
        sentAmount++;
        NewRequest(sentAmount, url, method, data);
        return sentAmount;
    }
    
    /// @notice HTTP Request with POST or GET with a callback() back to your contract address
    ///     This will require you to have a callback() function inside your contract
    ///     The callback() function looks like: function callback(uint id, string data) { }
    ///     Be sure to include "require(msg.sender==http.getResponder);" inside your callback function
    /// @param url => the URL for your HTTP request
    /// @param method => choose "POST" or "GET"
    /// @param data => POST data to send to URL
    /// @param variable => allows your contract to get 1 response from a JSON array from HTTP request
    /// Example: http.request("http://echo.jsontest.com/key/value/one/two", "GET", "", "one", msg.sender);
    function requestCallback(string url, string method, string data, string variable, address toAddress) payable external returns (uint id) {
        require(msg.value==callbackCost && enabled);
        sendToResponder(callbackCost);
        sentAmount++;
        NewRequestCallback(sentAmount, url, method, data, variable, toAddress);
        return sentAmount;
    }
    
    /// @notice send ETH to responder, responder will use ETH to pay for it's own gas for callback()
    function sendToResponder(uint amount) internal {
        responder.transfer(amount);
    }
    
    /// @notice kill the contract if needed, only by owner
    function kill() onlyOwner {
        suicide(msg.sender);
    }
    
}
