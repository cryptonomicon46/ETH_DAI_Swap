
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

import "./IFusionToken.sol";


contract FusionToken is IFusionToken {

    /// @notice totalSupply returns the total supply of the minted Fusion Token
    ///
        function totalSupply() external view override returns (uint) {}

    function decimal() external view override returns (uint) {}

    function balanceOf(address owner) external view override returns (uint) {}

    function allowance(
        address owner,
        address spender
    ) external view override returns (uint) {}

    function mint(address account, uint amount) external override {}

    function burn(address account, uint amount) external override {}

    function transferFrom(
        address owner,
        address recipient,
        uint amount
    ) external view override returns (bool) {}

    function transfer(
        address recipient,
        uint amount
    ) external view override returns (bool) {}

    function transferFrom_Wei(
        address owner,
        address recipient,
        uint amount,
        uint value
    ) external view override returns (bool) {}

    function transfer_Wei(
        address recipient,
        uint amount,
        uint value
    ) external view override returns (bool) {}

    function approve(
        address spender,
        uint amount
    ) external view override returns (bool) {}
}