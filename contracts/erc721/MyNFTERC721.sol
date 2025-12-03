// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IERC721Metadata} from "./IERC721Metadata.sol";
import {IERC721} from "./IERC721.sol";

error OnlyOwner();

error ERC721InvalidOwner(address owner);
error ERC721NonexistentToken(uint256 tokenId);
error ERC721MintExistentToken(uint256 tokenId);
error ERC721InvalidReceiver(address receiver);
error ERC721NotApprovedOrOwner(address sender, uint256 tokenId);
error ERC721OperatorIsOwner(address operator);

interface IERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

contract MyNFTERC721 is IERC721, IERC721Metadata, IERC165 {
    string private _name;
    string private _symbol;
    address private immutable _collectionOwner;
    uint256 public totalSupply;

    modifier onlyOwner() {
        if (msg.sender != _collectionOwner) revert OnlyOwner();
        _;
    }

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _collectionOwner = msg.sender;
    }

    mapping(address owner => uint256) private _balanceOf;
    mapping(uint256 tokenId => string uri) private _tokenURI;
    mapping(uint256 tokenId => address owner) private _ownerOf;
    mapping(uint256 tokenId => address approved) private _tokenApprovals;
    mapping(address owner => mapping(address operator => bool))
        private _operatorApprovals;

    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
        return
            interfaceId == 0x01ffc9a7 ||
            interfaceId == 0x80ac58cd ||
            interfaceId == 0x5b5e139f;
    }

    function balanceOf(address owner) public view override returns (uint256) {
        if (owner == address(0)) revert ERC721InvalidOwner(owner);

        return _balanceOf[owner];
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {
        address owner = _ownerOf[tokenId];
        if (!_exists(tokenId)) revert ERC721NonexistentToken(tokenId);

        return owner;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function collectionOwner() public view virtual returns (address) {
        return _collectionOwner;
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        return _ownerOf[tokenId] != address(0);
    }

    function _isApprovedOrOwner(
        address spender,
        uint256 tokenId
    ) internal view returns (bool) {
        address owner = _ownerOf[tokenId];
        if (
            spender == owner ||
            getApproved(tokenId) == spender ||
            isApprovedForAll(owner, spender)
        ) {
            return true;
        }

        return false;
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal returns (bool success) {
        if (!(ownerOf(tokenId) == from)) {
            revert ERC721InvalidOwner(from);
        }

        if (to == address(0)) {
            revert ERC721InvalidReceiver(to);
        }

        // clear approve
        _approve(address(0), tokenId);
        // update balance
        _balanceOf[from] -= 1;
        _balanceOf[to] += 1;
        // update owner
        _ownerOf[tokenId] = to;
        // emit event
        emit Transfer(from, to, tokenId);

        return true;
    }

    function _mint(address to, uint256 tokenId, string calldata uri) internal {
        if (to == address(0)) {
            revert ERC721InvalidReceiver(to);
        }

        if (_exists(tokenId)) revert ERC721MintExistentToken(tokenId);
        _ownerOf[tokenId] = to;
        _balanceOf[to] += 1;
        totalSupply += 1;

        _tokenURI[tokenId] = uri;

        emit Transfer(address(0), to, tokenId);
    }

    function mintOwner(
        address to,
        uint256 tokenId,
        string calldata uri
    ) external onlyOwner {
        _mint(to, tokenId, uri);
    }

    function _approve(address to, uint256 tokenId) internal {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    function _isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (!(_isContract(to))) return true;
        bytes4 selector = bytes4(
            keccak256("onERC721Received(address,address,uint256,bytes)")
        );
        (bool success, bytes memory returnData) = to.call(
            abi.encodeWithSelector(selector, msg.sender, from, tokenId, data)
        );
        if (!success) return false;
        if (returnData.length < 4) return false;
        bytes4 returned = abi.decode(returnData, (bytes4));
        return returned == selector;
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal {
        if (!_isApprovedOrOwner(msg.sender, tokenId))
            revert ERC721NotApprovedOrOwner(msg.sender, tokenId);

        _transfer(from, to, tokenId);
        require(
            _checkOnERC721Received(from, to, tokenId, data),
            "transfer to non ERC721Receiver"
        );
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        _safeTransfer(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) public override {
        _safeTransfer(from, to, tokenId, data);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external override {
        if (!(_isApprovedOrOwner(msg.sender, tokenId)))
            revert ERC721NotApprovedOrOwner(from, tokenId);
        _transfer(from, to, tokenId);
    }

    function approve(address to, uint256 tokenId) external override {
        if (!_exists(tokenId)) revert ERC721NonexistentToken(tokenId);

        address owner = ownerOf(tokenId);
        if (!(msg.sender == owner || isApprovedForAll(owner, msg.sender))) {
            revert ERC721InvalidOwner(owner);
        }

        _approve(to, tokenId); // sets _tokenApprovals[tokenId] and emits Approval(owner, to, tokenId)
    }

    function setApprovalForAll(
        address operator,
        bool approved
    ) external override {
        if (operator == msg.sender) revert ERC721OperatorIsOwner(operator);

        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function getApproved(
        uint256 tokenId
    ) public view override returns (address) {
        if (!(_exists(tokenId))) {
            revert ERC721NonexistentToken(tokenId);
        }

        return _tokenApprovals[tokenId];
    }

    function isApprovedForAll(
        address owner,
        address operator
    ) public view override returns (bool) {
        if (_operatorApprovals[owner][operator]) {
            return true;
        }

        return false;
    }

    function tokenURI(
        uint256 tokenId
    ) external view override returns (string memory) {
        if (!_exists(tokenId)) revert ERC721NonexistentToken(tokenId);

        return _tokenURI[tokenId];
    }
}
