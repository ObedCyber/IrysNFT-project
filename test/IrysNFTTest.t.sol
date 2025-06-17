// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {IrysNFT} from "../src/IrysNFT.sol";

contract IrysNFTTest is Test {
    IrysNFT nft;
    address admin1 = address(0xAB);
    address admin2 = address(0xCD);
    address user1 = address(0x1);
    address user2 = address(0x2);
    uint256 maxMintsPerAddress = 2;

    function setUp() public {
        vm.prank(admin1);
        nft = new IrysNFT(maxMintsPerAddress, admin1, admin2);
    }

    function test_CreateAndMintNFT() public {
        vm.prank(user1);
        uint256 tokenId = nft.createAndMintNFT("cat.png");

        assertEq(nft.ownerOf(tokenId), user1);
        assertEq(nft.getTokenURI(tokenId), "cat.png");
        assertEq(nft.getNFTMintCount("cat.png"), 1);
        assertEq(nft.getMintsPerAddress(user1, "cat.png"), 1);

        string[] memory uris = nft.getCreatorURIs(user1);
        assertEq(uris.length, 1);
        assertEq(uris[0], "cat.png");
    }

    function test_CreateAndMintNFT_RevertOnDuplicateURI() public {
        vm.startPrank(user1);
        nft.createAndMintNFT("cat.png");
        vm.expectRevert(IrysNFT.IrysNFT__URIAlreadyExists.selector);
        nft.createAndMintNFT("cat.png");
        vm.stopPrank();
    }

    function test_CreateAndMintNFT_RevertOnEmptyURI() public {
        vm.prank(user1);
        vm.expectRevert(IrysNFT.IrysNFT__EmptyTokenURI.selector);
        nft.createAndMintNFT("");
    }

    function test_MintExistingNFT() public {
        vm.prank(user1);
        nft.createAndMintNFT("lion.png");

        vm.prank(user2);
        uint256 tokenId = nft.mintExistingNFT("lion.png");

        assertEq(nft.ownerOf(tokenId), user2);
        assertEq(nft.getNFTMintCount("lion.png"), 2);
        assertEq(nft.getMintsPerAddress(user2, "lion.png"), 1);
    }

    function test_MintExistingNFT_RevertOnMaxMintsExceeded() public {
        vm.startPrank(user1);
        nft.createAndMintNFT("tiger.png");
        nft.mintExistingNFT("tiger.png");
        vm.expectRevert(IrysNFT.IrysNFT__MaxMintsPerAddressExceeded.selector);
        nft.mintExistingNFT("tiger.png");
        vm.stopPrank();
    }

    function test_MintExistingNFT_RevertOnBlacklisted() public {
        vm.prank(admin1);
        nft.setBlacklist("dog.png", true);

        vm.prank(user1);
        vm.expectRevert(IrysNFT.IrysNFT__NFTIsBlacklisted.selector);
        nft.mintExistingNFT("dog.png");
    }

    function test_SetBlacklist_OnlyAdminCanCall() public {
        vm.prank(user1);
        vm.expectRevert();
        nft.setBlacklist("rat.png", true);

        vm.prank(admin2);
        nft.setBlacklist("rat.png", true);
        assertEq(nft.isNFTblacklisted("rat.png"), true);
    }

    function test_GetTokenURI() public {
        vm.prank(user1);
        uint256 tokenId = nft.createAndMintNFT("bat.png");

        assertEq(nft.getTokenURI(tokenId), "bat.png");
    }
}
