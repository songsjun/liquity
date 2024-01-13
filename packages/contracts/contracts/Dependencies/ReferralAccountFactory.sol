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

    Counters.Counter public idCounter;
    // ReferralAccount Owner => ReferralAccount
    mapping(address => ReferentAccountData) public referralAccounts;
    mapping(uint256 => address) public referralAccountFinder;

    address public referralAccountTemplate;
    address public stabilityPool;

    event ReferralAccountCreated(address owner, address accountAddress, uint accountId);

    constructor(address _referralAccountTemplate, address _stabilityPool) public {
        referralAccountTemplate = _referralAccountTemplate;
        stabilityPool = _stabilityPool;
    }

    function registerReferralAccount(uint _kickbackRate) external {
        address referralAccountOwner = msg.sender;
        require(referralAccounts[referralAccountOwner].accountAddress == address(0), "Referral account already exists");

        address referralAccount = referralAccountTemplate.clone();
        ReferralAccount(referralAccount).initialize(referralAccountOwner, stabilityPool);
        ReferralAccount(referralAccount).registerReferralAccount(_kickbackRate);

        idCounter.increment();
        uint currentId = idCounter.current();
        referralAccountFinder[idCounter.current()] = referralAccount;
        referralAccounts[referralAccountOwner] = ReferentAccountData(referralAccount, currentId);

        emit ReferralAccountCreated(referralAccountOwner, referralAccount, currentId);
    }
}