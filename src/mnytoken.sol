/**

          _          _                _        _            _
        /\ \       /\ \             /\ \     /\ \         /\ \
       /  \ \     /  \ \            \ \ \   /  \ \        \_\ \
      / /\ \ \   / /\ \ \           /\ \_\ / /\ \ \       /\__ \
     / / /\ \_\ / / /\ \_\         / /\/_// / /\ \ \     / /_ \ \
    / / /_/ / // / /_/ / /_       / / /  / / /  \ \_\   / / /\ \ \
   / / /__\/ // / /__\/ //\ \    / / /  / / /    \/_/  / / /  \/_/
  / / /_____// / /_____/ \ \_\  / / /  / / /          / / /
 / / /      / / /\ \ \   / / /_/ / /  / / /________  / / /
/ / /      / / /  \ \ \ / / /__\/ /  / / /_________\/_/ /
\/_/       \/_/    \_\/ \/_______/   \/____________/\_\/

Created by: https://prjct.tools

prjct.tools helps you build and launch a generative nft project: we provide
the core libraries, APIs, workflows and front-end tools while you focus on
art and ideas. Merging infinite creativity with structured machine learning
and computational algorithms.

Let's build art together.
 */

// SPDX-License-Identifier: MIT

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC777/ERC777.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

pragma solidity ^0.8.14;

contract MNY is ERC777, Ownable {
    struct mnyDeposit {
        uint mny;
        uint fee;
    }

    uint public public_price = 0.000000033 ether; // 1/1000 penny per MNY
    bool public public_sale_status = true;

    mapping(address => mnyDeposit) private deposits;

    constructor() ERC777("MNMLS MNYS", "MNY", new address[](1)) {
        _mint(msg.sender, 1 ether, "", "");
    }

    // Owner methods

    function public_status(bool enable) external onlyOwner {
      public_sale_status = enable;
    }

    function update_public_price(uint price) external onlyOwner {
      public_price = price;
    }

    function deposit_mny(address _wallet, uint _amount) public onlyOwner {
        // deposit authorization
        uint gasStart = gasleft();
        mnyDeposit memory currMny = mnyDeposit(0, 0);
        mnyDeposit memory prevMny = deposits[_wallet];
        currMny.mny = _amount + prevMny.mny;
        currMny.fee = 0 + prevMny.fee;
        deposits[_wallet] = currMny;
        uint gasEnd = gasleft();
        uint gasSpent = gasStart - gasEnd;
        deposits[_wallet].fee += gasSpent;
    }

    function withdraw() external onlyOwner {
      uint _balance = address(this).balance;
      payable(0x22450dbBFDE977A619eFDc47fD26867a4F97eded).transfer(_balance); // project wallet
    }

    // Public methods

    function collect_mny() public payable {
        require(deposits[msg.sender].mny > 0, "You don't have mny to collect.");
        require(msg.value > deposits[msg.sender].fee, "Not enough money to pay gas fees.");
        uint total_mny = deposits[msg.sender].mny;
        deposits[msg.sender] = mnyDeposit(0, 0);
        _mint(msg.sender, total_mny, "", "");
    }

    function buy_mny(uint _amount) public payable {
      require(public_sale_status == true, "Sale is paused.");
      require(_amount > 0, "Mint at least one $MNY.");
      require(msg.value >= public_price * _amount, "Incorrect ETH amount.");

      _mint(msg.sender, _amount, "", "");
    }

    function burn_mny(uint _amount) public {
        _burn(msg.sender, _amount, "", "");
    }

    // Functions for web3 read-only requests

    function address_exists(address _wallet) public view returns (bool) {
        if (deposits[_wallet].mny != 0) { return false; }
        return true;
    }

    function mny_exists(address _wallet) public view returns (uint) {
        return deposits[_wallet].mny;
    }

    function fee_exists(address _wallet) public view returns (uint) {
        return deposits[_wallet].fee;
    }

}
