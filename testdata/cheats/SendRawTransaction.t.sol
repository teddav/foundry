// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import "ds-test/test.sol";
import "./Cheats.sol";

contract SendRawTransactionTest is DSTest {
    Cheats constant cheats = Cheats(HEVM_ADDRESS);

    function test_revert_not_a_tx() public {
        cheats.expectRevert(
            "sendRawTransaction: error decoding transaction RlpExpectedToBeList"
        );
        cheats.sendRawTransaction(hex"0102");
    }

    function test_revert_missing_signature() public {
        cheats.expectRevert(
            "sendRawTransaction: error decoding transaction RlpIsTooShort"
        );
        cheats.sendRawTransaction(
            hex"dd806483030d40940993863c19b0defb183ca2b502db7d1b331ded757b80"
        );
    }

    function test_execute_signed_tx() public {
        cheats.fee(1);

        address from = 0x5316812db67073C4d4af8BB3000C5B86c2877e94;
        address to = 0x6Fd0A0CFF9A87aDF51695b40b4fA267855a8F4c6;

        cheats.deal(address(from), 1 ether);
        assertEq(address(from).balance, 1 ether);
        assertEq(address(to).balance, 0);

        /*
        Signed transaction:
        TransactionRequest { from: Some(0x5316812db67073c4d4af8bb3000c5b86c2877e94), to: Some(Address(0x6fd0a0cff9a87adf51695b40b4fa267855a8f4c6)), gas: Some(200000), gas_price: Some(100), value: Some(17), data: None, nonce: Some(0), chain_id: Some(1) }
        */
        cheats.sendRawTransaction(
            hex"f860806483030d40946fd0a0cff9a87adf51695b40b4fa267855a8f4c6118025a03ebeabbcfe43c2c982e99b376b5fb6e765059d7f215533c8751218cac99bbd80a00a56cf5c382442466770a756e81272d06005c9e90fb8dbc5b53af499d5aca856"
        );

        uint256 gasPrice = 100;
        assertEq(address(from).balance, 1 ether - (gasPrice * 21_000) - 17);
        assertEq(address(to).balance, 17);
    }

    function test_execute_multiple_tx() public {
        cheats.fee(1);

        address from = 0x5316812db67073C4d4af8BB3000C5B86c2877e94;
        address to = 0x6Fd0A0CFF9A87aDF51695b40b4fA267855a8F4c6;

        address random = address(
            uint160(uint256(keccak256(abi.encodePacked("random"))))
        );

        cheats.deal(address(from), 1 ether);
        assertEq(address(from).balance, 1 ether);
        assertEq(address(to).balance, 0);

        /*
        Signed transaction:
        TransactionRequest { from: Some(0x5316812db67073c4d4af8bb3000c5b86c2877e94), to: Some(Address(0x6fd0a0cff9a87adf51695b40b4fa267855a8f4c6)), gas: Some(200000), gas_price: Some(100), value: Some(17), data: None, nonce: Some(0), chain_id: Some(1) }
        */
        cheats.sendRawTransaction(
            hex"f860806483030d40946fd0a0cff9a87adf51695b40b4fa267855a8f4c6118025a03ebeabbcfe43c2c982e99b376b5fb6e765059d7f215533c8751218cac99bbd80a00a56cf5c382442466770a756e81272d06005c9e90fb8dbc5b53af499d5aca856"
        );

        uint256 gasPrice = 100;
        assertEq(address(from).balance, 1 ether - (gasPrice * 21_000) - 17);
        assertEq(address(to).balance, 17);
        assertEq(address(random).balance, 0);

        uint256 value = 5;

        cheats.prank(to);
        (bool success, ) = random.call{value: value}("");
        require(success);
        assertEq(address(random).balance, value);
    }
}
