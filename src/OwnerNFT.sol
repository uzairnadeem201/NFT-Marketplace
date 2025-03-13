// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OwnerNFT is ERC721, Ownable {
    event NFTBought(
        uint256 indexed tokenId,
        address indexed buyer,
        uint256 price
    );

    error NotOwner(string message);
    error TokenDoesNotExist(uint256 tokenId);
    error NotListed(string message);
    error InsufficientFunds(string message);
    struct Listing {
        uint256 price;
        address seller;
        bool isListed;
    }

    mapping(uint256 => string) private _tokenURIs;
    mapping(uint256 => Listing) public listings;
    uint256 private _tokenIdCounter;

    constructor() ERC721("OwnerNFT", "ONFT") Ownable(msg.sender) {}

    function _setTokenURI(uint256 tokenId, string memory uri) internal {
        _tokenURIs[tokenId] = uri;
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        if (_ownerOf(tokenId) == address(0)) {
            revert TokenDoesNotExist(tokenId);
        }
        return _tokenURIs[tokenId];
    }

    function mintNFT(address to, string memory uri) public {
        if (msg.sender != owner()) {
            revert NotOwner("Unautorized User is requesting to Mint");
        }
        _tokenIdCounter++;
        uint256 tokenId = _tokenIdCounter;
        _mint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function listNFT(uint256 tokenId, uint256 price) public {
        if (ownerOf(tokenId) != msg.sender) {
            revert NotOwner("Only the owner can list the NFT for sale");
        }
        require(price > 0, "Price must be greater than zero");
        listings[tokenId] = Listing(price, msg.sender, true);
    }

    function buyNFT(uint256 tokenId) public payable {
        Listing memory listing = listings[tokenId];
        if (!listing.isListed) {
            revert NotListed("NFT is not listed for sale");
        }
        if (msg.value < listing.price) {
            revert InsufficientFunds("Insufficient Funds");
        }
        address seller = listing.seller;
        safeTransferFrom(seller, msg.sender, tokenId);
        payable(seller).transfer(msg.value);
        listings[tokenId].isListed = false;
        emit NFTBought(tokenId, msg.sender, msg.value);
    }
}
