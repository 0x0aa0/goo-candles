// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {ERC721} from "solmate/tokens/ERC721.sol";
import {ArtGobblers} from "artgobblers/ArtGobblers.sol";
import {Goo} from "artgobblers/Goo.sol";
import {Base64} from "./utils/Base64.sol";
import {LibString} from "solmate/utils/LibString.sol";

contract GooCandles is ERC721 {
    using LibString for uint8;
    using LibString for uint256;

    address immutable artGobblers;
    address immutable goo;
    address immutable candleMaker;
    uint256 price;

    mapping(uint256 => bytes32) public gobblerToSeed;
    mapping(uint256 => address) public gooSmelledBy;

    constructor(
        address _artGobblers,
        address _goo,
        uint256 _price
    ) ERC721("Goo Candle", "SMELL") {
        artGobblers = _artGobblers;
        goo = _goo;
        price = _price;
        candleMaker = msg.sender;
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        require(gobblerToSeed[id] != bytes32(0), "I HAVENT MADE THAT ONE YET!");
        return _uri(gobblerToSeed[id], id);
    }

    function mint(uint256 id) external {
        require(msg.sender == ArtGobblers(artGobblers).ownerOf(id), "THATS NOT YO GOBBLER!");
        require(Goo(goo).transferFrom(msg.sender, candleMaker, price), "YOU TRYNA STIFF ME?");
        gobblerToSeed[id] = keccak256(abi.encodePacked(ArtGobblers(artGobblers).tokenURI(id)));
        _mint(msg.sender, id);
    }

    function smell(uint256 id) external {
        require(ownerOf(id).code.length == 0, "CANDLE IS SECURE!");
        gooSmelledBy[id] = msg.sender;
    }

    function transferFrom(
        address from,
        address to,
        uint256 id
    ) public override {
        require(gooSmelledBy[id] == address(0), "THATS BURNED YO!");
        super.transferFrom(from, to, id);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) public override {
        require(gooSmelledBy[id] == address(0), "THATS BURNED YO!");
        super.safeTransferFrom(from, to, id);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes calldata data
    ) public override {
        require(gooSmelledBy[id] == address(0), "THATS BURNED YO!");
        super.safeTransferFrom(from, to, id, data);
    }

    function _uri(bytes32 seed, uint256 id) internal view returns (string memory) {
        string memory image = _image(seed, id);
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name": "GOO CANDLE #',
                                id.toString(),
                                '", "description": "SMELLS LIKE GOO", "image": "',
                                image,
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    function _image(bytes32 seed, uint256 id) internal view returns (string memory) {
        if (gooSmelledBy[id] != address(0)) {
            return
                string(
                    abi.encodePacked(
                        "data:image/svg+xml;base64,",
                        Base64.encode(abi.encodePacked(_candle(seed), _flame(seed), "</svg>"))
                    )
                );
        }

        return string(abi.encodePacked("data:image/svg+xml;base64,", Base64.encode(abi.encodePacked(_candle(seed), "</svg>"))));
    }

    function _candle(bytes32 seed) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<svg height="300" width="200" xmlns="http://www.w3.org/2000/svg"><defs><linearGradient id="Gradient" x1="0" x2="0" y1="0" y2="1"><stop offset="20%" stop-color="rgb(',
                    _offset(seed, 0),
                    ')"/><stop offset="65%" stop-color="rgb(',
                    _offset(seed, 10),
                    ')"/><stop offset="100%" stop-color="rgb(',
                    _offset(seed, 20),
                    ')"/></linearGradient></defs><rect width="200" height="300" rx="1000" ry="50" fill="url(\'#Gradient\')" stroke="#000"/><ellipse cx="100" cy="50" rx="100" ry="50" fill="rgb(',
                    _offset(seed, 0),
                    ')" stroke="#000"/><rect width="2" height="30" x="100" y="20"/><text fill="#000" font-size="25" font-family="Courier New" x="100" y="200" text-anchor="middle">GOO SMELL</text>'
                )
            );
    }

    function _flame(bytes32 seed) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<defs><linearGradient id="Gradient2" x1="0" x2="0" y1="0" y2="1"><stop offset="0%" stop-color="rgb(',
                    _offset(seed, 5),
                    ')"/><stop offset="70%" stop-color="rgb(',
                    _offset(seed, 15),
                    ')"/></linearGradient></defs><path fill="url(\'#Gradient2\')" d="M15 3 Q16.5 6.8 25 18 A12.8 12.8 0 1 1 5 18 Q13.5 6.8 15 3z" transform="translate(86,0)"/>'
                )
            );
    }

    function _offset(bytes32 seed, uint8 pos) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    uint8(seed[pos]).toString(),
                    ",",
                    uint8(seed[pos + 1]).toString(),
                    ",",
                    uint8(seed[pos + 2]).toString()
                )
            );
    }
}
