// Copyright (C) 2019 David Terry <me@xwvvvvwx.com>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

pragma solidity >=0.5.0 <0.6.0;

contract DSDelegatecall {
    // --- math ---
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-delegatecall-sub-underflow");
    }

    // --- util ---
    function max_call_gas(uint gas) internal pure returns (uint) {
        return sub(gas, gas / 64);
    }
    function codesize(address usr) internal view returns (uint size) {
        assembly { size := extcodesize(usr) }
    }

    // --- calls ---
    // sag == gas. required due to name collision with the GAS opcode.
    function delegatecall(address usr, bytes memory fax, uint sag)
        internal
        returns (bytes memory response)
    {
        // EIP-150: details on the gas calculation
        // EIP-161: details on existent vs non-existent accounts
        require(codesize(usr) > 0,                        "ds-delegatecall-usr-missing-code");
        require(sag < sub(max_call_gas(gasleft()), 5000), "ds-delegatecall-insufficient-gas");

        assembly {
            let succeeded := delegatecall(sag, usr, add(fax, 0x20), mload(fax), 0, 0)
            let size := returndatasize

            response := mload(0x40)
            mstore(0x40, add(response, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            mstore(response, size)
            returndatacopy(add(response, 0x20), 0, size)

            switch iszero(succeeded)
            case 1 {
                revert(add(response, 0x20), size)
            }
        }
    }
}
