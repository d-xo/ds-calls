pragma solidity ^0.5.6;

import "ds-test/test.sol";

import "./DsCalls.sol";

contract DsCallsTest is DSTest {
    DsCalls calls;

    function setUp() public {
        calls = new DsCalls();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
