// SPDX-Identifier-License: MIT
pragma solidity ^0.8.19;
import {Test} from "forge-std/Test.sol";
import {OwnerNFT} from "../src/OwnerNFT.sol";

contract OwnerNFTTest is Test {
    OwnerNFT private nftContract;
    address private owner;
    address private unauthorizedUser;
    string private constant TOKEN_URI = "ipfs://example-token-uri";

    function setUp() public {
        owner = vm.addr(1);
        unauthorizedUser = vm.addr(2);
        vm.prank(owner);
        nftContract = new OwnerNFT();
    }

    function testOnlyOwnerCanMint() public {
        vm.prank(owner);
        nftContract.mintNFT(owner, TOKEN_URI);
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

        nftContract.mintNFT(unauthorizedUser, TOKEN_URI);
    }

    function testSetTokenUriandRetrievingIt() public {
        vm.prank(owner);
        nftContract.mintNFT(owner, TOKEN_URI);
        assertEq(nftContract.tokenURI(1), TOKEN_URI);
    }

    function testTokenURINonExistentTokenShouldRevert() public {
        vm.expectRevert(
            abi.encodeWithSelector(OwnerNFT.TokenDoesNotExist.selector, 9999)
        );
        nftContract.tokenURI(9999);
    }
}
