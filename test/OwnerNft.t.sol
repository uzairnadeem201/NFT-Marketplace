// SPDX-Identifier-License: MIT
pragma solidity ^0.8.19;
import {Test} from "forge-std/Test.sol";
import {OwnerNFT} from "../src/OwnerNFT.sol";

contract OwnerNFTTest is Test {
    OwnerNFT private nftContract;
    address private owner;
    address private unauthorizedUser;
    address private buyer;
    string private constant TOKEN_URI = "ipfs://example-token-uri";

    function setUp() public {
        owner = vm.addr(1);
        unauthorizedUser = vm.addr(2);
        buyer = vm.addr(3);
        vm.prank(owner);
        nftContract = new OwnerNFT();
    }

    function testOnlyOwnerCanMint() public {
        vm.prank(owner);
        nftContract.mintNFT(owner, TOKEN_URI, 500);
        assertEq(nftContract.ownerOf(1), owner);
    }

    function testUnauthorizedUserCannotMint() public {
        vm.prank(unauthorizedUser);
        vm.expectRevert(
            abi.encodeWithSelector(
                OwnerNFT.NotOwner.selector,
                "Unautorized User is requesting to Mint"
            )
        );

        nftContract.mintNFT(unauthorizedUser, TOKEN_URI, 500);
    }

    function testSetTokenUriandRetrievingIt() public {
        vm.prank(owner);
        nftContract.mintNFT(owner, TOKEN_URI, 500);
        assertEq(nftContract.tokenURI(1), TOKEN_URI);
    }

    function testTokenURINonExistentTokenShouldRevert() public {
        vm.expectRevert(
            abi.encodeWithSelector(OwnerNFT.TokenDoesNotExist.selector, 9999)
        );
        nftContract.tokenURI(9999);
    }

    function testListNFT() public {
        vm.startPrank(owner);
        nftContract.mintNFT(owner, TOKEN_URI, 500);
        nftContract.listNFT(1, 1 ether);
        vm.stopPrank();
        (
            uint256 price,
            address seller,
            bool isListed,
            uint256 royaltyPercentage,
            address originalCreator
        ) = nftContract.listings(1);
        assertEq(price, 1 ether);
        assertEq(seller, owner);
        assertEq(isListed, true);
        assertEq(originalCreator, owner);
        assertEq(royaltyPercentage, 500);
    }

    function testInauthorizedUserCannotListNFT() public {
        vm.startPrank(owner);
        nftContract.mintNFT(owner, TOKEN_URI, 500);
        vm.stopPrank();
        vm.prank(unauthorizedUser);
        vm.expectRevert(
            abi.encodeWithSelector(
                OwnerNFT.NotOwner.selector,
                "Only the owner can list the NFT for sale"
            )
        );
        nftContract.listNFT(1, 1 ether);
    }

    function testBuyNFTSuccessfully() public {
        vm.startPrank(owner);
        nftContract.mintNFT(owner, TOKEN_URI, 500);
        nftContract.listNFT(1, 1 ether);
        vm.stopPrank();

        vm.deal(buyer, 2 ether);

        vm.startPrank(buyer);
        nftContract.buyNFT{value: 1 ether}(1);
        vm.stopPrank();

        assertEq(nftContract.ownerOf(1), buyer);
    }

    function testListNFTWithZeroPriceShouldFail() public {
        vm.startPrank(owner);
        nftContract.mintNFT(owner, TOKEN_URI, 500);
        vm.expectRevert("Price must be greater than zero");
        nftContract.listNFT(1, 0);
        vm.stopPrank();
    }

    function testBuyUnlistedNFTShouldFail() public {
        vm.deal(buyer, 2 ether);
        vm.startPrank(buyer);
        vm.expectRevert(
            abi.encodeWithSelector(
                OwnerNFT.NotListed.selector,
                "NFT is not listed for sale"
            )
        );
        nftContract.buyNFT{value: 1 ether}(1);
        vm.stopPrank();
    }

    function testBuyNFTWithInsufficientFundsShouldFail() public {
        vm.startPrank(owner);
        nftContract.mintNFT(owner, TOKEN_URI, 500);
        nftContract.listNFT(1, 1 ether);
        vm.stopPrank();

        vm.deal(buyer, 0.5 ether);

        vm.startPrank(buyer);
        vm.expectRevert(
            abi.encodeWithSelector(
                OwnerNFT.InsufficientFunds.selector,
                "Insufficient Funds"
            )
        );
        nftContract.buyNFT{value: 0.5 ether}(1);
        vm.stopPrank();
    }
}
