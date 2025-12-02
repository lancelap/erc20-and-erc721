// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IERC721Metadata} from "./IERC721Metadata.sol";
import {IERC721} from "./IERC721.sol";

error OnlyOwner();

contract MyNFT is IERC721, IERC721Metadata {
    string private _name;
    string private _symbol;
    address private immutable _ownerContract;

    modifier onlyOwner {
        if (msg.sender != _ownerContract) revert OnlyOwner();
        _;
    }

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _ownerContract = msg.sender;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    mapping(address _owner => uint256) public override balanceOf;
    mapping(uint256 _tokenId => address) public override ownerOf;

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes calldata data
    ) external payable override {}

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable override {}

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable override {}

    function approve(
        address _approved,
        uint256 _tokenId
    ) external payable override {}

    function setApprovalForAll(
        address _operator,
        bool _approved
    ) external override {}

    function getApproved(
        uint256 _tokenId
    ) external view override returns (address) {}

    function isApprovedForAll(
        address _owner,
        address _operator
    ) external view override returns (bool) {}

    function tokenURI(
        uint256 tokenId
    ) external view override returns (string memory) {}
}
