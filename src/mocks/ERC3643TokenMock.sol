// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Interface and other library === */
import {IERC3643Compliance} from "../interfaces/IERC3643Compliance.sol";

/**
 * @title ERC3643TokenMock
 * @notice Minimal ERC-3643 (T-REX) style token that drives a compliance contract exactly as the
 * reference implementation does, used to test the RuleEngine through the ERC-3643 entry points.
 * @dev The compliance interaction is modelled on `Token.sol` from the ERC-3643 reference
 * implementation (submodule `lib/ERC-3643`, tag 4.1.3):
 *
 * - `setCompliance`  unbinds the previous compliance, then binds itself to the new one
 * - `transfer`       calls `canTransfer(msg.sender, to, amount)` then `transferred(msg.sender, to, amount)`
 * - `mint`           calls `canTransfer(address(0), to, amount)` then `created(to, amount)`
 * - `burn`           calls `destroyed(from, amount)`
 *
 * NOTE: the reference token itself cannot be compiled into this test suite. It pins
 * `pragma solidity 0.8.17` (this project compiles with 0.8.36), depends on OpenZeppelin 4.8.x
 * (this project uses 5.7.0) and on the `onchain-id/solidity` package, which is not installed here.
 * This mock therefore reproduces the compliance-facing behaviour rather than vendoring the token.
 *
 * ERC-3643 compliance callbacks carry no spender, so this token never reaches the 4-argument
 * `transferred(spender, from, to, value)` overload.
 */
contract ERC3643TokenMock {
    /* ==== Errors === */
    error ERC3643TokenMock_ComplianceNotFollowed();
    error ERC3643TokenMock_InsufficientBalance();

    /* ==== Events === */
    /**
     * @notice Emitted when the compliance contract is changed.
     * @param compliance The address of the new compliance contract.
     */
    event ComplianceAdded(address indexed compliance);

    /* ==== State Variables === */
    /**
     * @notice Token balances.
     */
    mapping(address account => uint256 balance) public balanceOf;

    /**
     * @notice The compliance contract currently bound to this token.
     */
    IERC3643Compliance public compliance;

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Binds this token to a compliance contract, unbinding the previous one.
     * @dev Mirrors `Token.setCompliance` in the ERC-3643 reference implementation: the token
     * unbinds itself from the old compliance and binds itself to the new one. Both calls are
     * made by the token, so the compliance contract must have granted this token self-binding
     * approval beforehand.
     * @param compliance_ The address of the new compliance contract.
     */
    function setCompliance(address compliance_) public virtual {
        if (address(compliance) != address(0)) {
            compliance.unbindToken(address(this));
        }
        compliance = IERC3643Compliance(compliance_);
        compliance.bindToken(address(this));
        emit ComplianceAdded(compliance_);
    }

    /**
     * @notice Transfers tokens, applying the compliance rules.
     * @dev Mirrors `Token.transfer`: pre-checks with `canTransfer` then notifies with `transferred`.
     * @param to The destination address.
     * @param amount The number of tokens to transfer.
     */
    function transfer(address to, uint256 amount) public virtual {
        require(balanceOf[msg.sender] >= amount, ERC3643TokenMock_InsufficientBalance());
        require(compliance.canTransfer(msg.sender, to, amount), ERC3643TokenMock_ComplianceNotFollowed());
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        compliance.transferred(msg.sender, to, amount);
    }

    /**
     * @notice Mints tokens, applying the compliance rules.
     * @dev Mirrors `Token.mint`: pre-checks with `canTransfer(address(0), ...)` then notifies
     * with `created`. Note the pre-check passes `address(0)` as the origin.
     * @param to The address receiving the minted tokens.
     * @param amount The number of tokens to mint.
     */
    function mint(address to, uint256 amount) public virtual {
        require(compliance.canTransfer(address(0), to, amount), ERC3643TokenMock_ComplianceNotFollowed());
        balanceOf[to] += amount;
        compliance.created(to, amount);
    }

    /**
     * @notice Burns tokens, applying the compliance rules.
     * @dev Mirrors `Token.burn`: notifies the compliance with `destroyed`.
     * @param from The address whose tokens are burned.
     * @param amount The number of tokens to burn.
     */
    function burn(address from, uint256 amount) public virtual {
        require(balanceOf[from] >= amount, ERC3643TokenMock_InsufficientBalance());
        balanceOf[from] -= amount;
        compliance.destroyed(from, amount);
    }
}
