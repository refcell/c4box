// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.11;

import {DSTestPlus} from "./utils/DSTestPlus.sol";

import {MaliciousDelegator} from "../MaliciousDelegator.sol";

contract MaliciousDelegatorTest is DSTestPlus {
    MaliciousDelegator md;

    function setUp() public {
        md = new MaliciousDelegator();
    }
}
