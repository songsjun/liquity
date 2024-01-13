// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;
import "./IERC20.sol";
import "./Initializable.sol";

interface SimpleStabilityPool {
    function registerFrontEnd(uint _kickbackRate) external;
}

contract ReferralAccount is Initializable {
    address public owner;
    address public stabilityPool;

    event Withdraw(address token, address to, uint amount);
    event RegisterReferralAccount(address owner, address referralAccount, uint _kickbackRate);

    constructor() public {
        _disableInitializers();
    }

    function initialize(address _owner, address _stabilityPool) initializer external {
        owner = _owner;
        stabilityPool = _stabilityPool;
    } 

    function withdraw(address token) external {
        uint amount = 0;
        if (token == address(0)) {
            amount = address(this).balance;
            (bool success, ) = owner.call{value: amount}("");
            require(success, "Failed to transfer");
        } else {
            amount = IERC20(token).balanceOf(address(this));
            IERC20(token).transfer(owner, amount);
        }

        emit Withdraw(token, owner, amount);
    }

    function registerReferralAccount(uint _kickbackRate) external {
        SimpleStabilityPool(stabilityPool).registerFrontEnd(_kickbackRate);

        emit RegisterReferralAccount(owner, address(this), _kickbackRate);
    }

}