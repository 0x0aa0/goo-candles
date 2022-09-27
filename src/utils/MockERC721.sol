// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solmate/tokens/ERC721.sol";

contract MockERC721 is ERC721 {
    constructor() ERC721("TEST_721", "TEST") {}

    function tokenURI(uint256) public pure virtual override returns (string memory) {
        return "TEST";
    }

    function mint(address to, uint256 tokenId) public virtual {
        _mint(to, tokenId);
    }

    function burn(uint256 tokenId) public virtual {
        _burn(tokenId);
    }
}
