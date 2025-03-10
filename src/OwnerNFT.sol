// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OwnerNFT is ERC721, Ownable {
    mapping(uint256 => string) private _tokenURIs;
    uint256 private _tokenIdCounter;

    constructor() ERC721("OwnerNFT", "ONFT") Ownable(msg.sender) {}

    function _setTokenURI(uint256 tokenId, string memory uri) internal {
        _tokenURIs[tokenId] = uri;
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        require(_ownerOf(tokenId) != address(0), "Token does not exist"); // Check via _ownerOf
        return _tokenURIs[tokenId];
    }

    function mintNFT(address to, string memory uri) public onlyOwner {
        _tokenIdCounter++;
        uint256 tokenId = _tokenIdCounter;
        _mint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }
}
