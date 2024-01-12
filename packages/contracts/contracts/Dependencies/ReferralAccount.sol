// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;
import "./IERC20.sol";
import "./Initializable.sol";

contract ReferralAccount is Initializable {
    address public owner;

    event Withdraw(address token, address to, uint amount);

    constructor() public {
        _disableInitializers();
    }

    function initialize(address _owner) initializer external {
        owner = _owner;
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
}