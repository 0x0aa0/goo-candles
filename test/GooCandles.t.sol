// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {GooCandles, ArtGobblers, Goo} from "../src/GooCandles.sol";
import {MockERC721} from "../src/utils/MockERC721.sol";
import {MockERC20} from "../src/utils/MockERC20.sol";
import "forge-std/Test.sol";

contract GooCandlesTest is Test {
    GooCandles gooCandles;
    MockERC721 nft;
    MockERC20 token;

    address bob = vm.addr(0xb0b);
    address alice = vm.addr(0xa11ce);

    function setUp() public {
        nft = new MockERC721();
        token = new MockERC20();
        gooCandles = new GooCandles(address(nft), address(token), 0);
    }

    function testURI() public {
        nft.mint(address(this), 1);
        gooCandles.mint(1);
        string memory uri = gooCandles.tokenURI(1);
        console.log(uri);
    }

    function testSmellURI() public {
        nft.mint(bob, 1);

        vm.startPrank(bob);
        gooCandles.mint(1);
        gooCandles.smell(1);
        vm.stopPrank();

        string memory uri = gooCandles.tokenURI(1);
        console.log(uri);
    }

    function testBadURI() public {
        vm.expectRevert(bytes("I HAVENT MADE THAT ONE YET!"));
        gooCandles.tokenURI(1);
    }

    function testBadMint() public {
        nft.mint(address(this), 1);
        vm.prank(bob);
        vm.expectRevert(bytes("THATS NOT YO GOBBLER!"));
        gooCandles.mint(1);
    }

    function testSmell() public {
        nft.mint(bob, 1);
        vm.prank(bob);
        gooCandles.mint(1);

        gooCandles.smell(1);

        assertEq(gooCandles.gooSmelledBy(1), address(this));
    }

    function testBadSmell() public {
        nft.mint(address(this), 1);
        gooCandles.mint(1);
        vm.prank(bob);
        vm.expectRevert(bytes("CANDLE IS SECURE!"));
        gooCandles.smell(1);
    }

    function testTransfer() public {
        nft.mint(address(this), 1);
        gooCandles.mint(1);
        gooCandles.transferFrom(address(this), alice, 1);
    }

    function testSmellTransfer() public {
        nft.mint(bob, 1);

        vm.startPrank(bob);
        gooCandles.mint(1);
        gooCandles.smell(1);
        vm.stopPrank();

        vm.expectRevert(bytes("THATS BURNED YO!"));
        gooCandles.transferFrom(bob, alice, 1);
    }
}
