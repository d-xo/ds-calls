<h1 align="center">
ds-calls
</h1>

<p align="center">
<i>ergonomic <code>delegatecall</code> wrapper</i>
</p>

This implementation differs from solidity's in the following ways:

- reverts if the `delegatecall` fails
- reverts if the called address has no code
- reverts if insufficient gas has been provided
- propogates error messages from reverts during execution of the target contract

## Usage

```solidity
import 'ds-calls/calls.sol';

contract Delegator is DSDelegatecall {
    function delegate(address usr, bytes memory fax, uint gas)
        public
        returns (bytes memory)
    {
        return delegatecall(usr, fax, gas);
    }
}
```

## Specification

The following is an executable `K` specification written in the klab `act` format. You can verify
that the implementation in this repo correctly implements this specification by running `dapp build
&& klab build && klab prove-all` from the repo root.

The bare `DSDelegateCall` contract by itself is not very interesting as all functions are internal,
so we instead write a specification for the simplest possible consumer contract: the `Delegator`
defined in the usage section above.

Additionally we cannot use K to make statements about calls into arbitrary code. We therefore
specify the behaviour of the `Delegator` when calling into  various contracts that exercise the
behaviour described in the features section above.

This limits the strength of the correctness claims that we can make about this component in
isolation, and additional verification work specific to your particular context is encouraged.

Implementations of the `Delegator` and the various target contracts are provided in
[`src/harness.sol`](./src/harness.sol)

### Trivial Call

We begin by describing a call into a contract that always returns 0.

```act
behaviour delegate of Delegator
interface delegate(address usr, bytes fax, uint gas)

calls

  Trivial.returns_zero

iff
  fax == #generateSignature("returns_zero()")
  VCallDepth < 1024

returns 0
```

```act
behaviour returns_zero of Trivial
interface returns_zero()

returns 0
```

### TODO

- specify basic delegatecall behaviour
- specify handling of returndata
- specify calls to an EOA
- specify error message propogation
- specify gas semantics
- extend to include a `call` implementation
