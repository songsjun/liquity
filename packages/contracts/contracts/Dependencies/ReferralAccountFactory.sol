// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

import "./ReferralAccount.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract ReferralAccountFactory {
    using Clones for address; 
    using Counters for Counters.Counter;

    struct ReferentAccountData {
        address accountAddress;
        uint accountId;
    }

    Counters.Counter idCounter;
    // ReferralAccount Owner => ReferralAccount
    mapping(address => ReferentAccountData) public referralAccounts;
    mapping(uint256 => address) public referralAccountFinder;

    address public referralAccountTemplate;

    event ReferralAccountCreated(address owner, address accountAddress, uint accountId);

    constructor(address _referralAccountTemplate) public {
        referralAccountTemplate = _referralAccountTemplate;
    }

    function createReferralAccount() external {
        address referralAccountOwner = msg.sender;
        require(referralAccounts[referralAccountOwner].accountAddress == address(0), "Referral account already exists");

        address referralAccount = referralAccountTemplate.clone();
        ReferralAccount(referralAccount).initialize(referralAccountOwner);

        idCounter.increment();
        uint currentId = idCounter.current();
        referralAccountFinder[idCounter.current()] = referralAccount;
        referralAccounts[referralAccountOwner] = ReferentAccountData(referralAccount, currentId);

        emit ReferralAccountCreated(referralAccountOwner, referralAccount, currentId);
    }
}