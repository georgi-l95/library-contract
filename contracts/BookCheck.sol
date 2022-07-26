// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
pragma abicoder v2;

contract BookCheck {
    modifier quantityCheck(uint16 quantity) {
        require(quantity > 0, "Quantity can't be 0!");
        _;
    }

    modifier bookExist(uint256 id, uint256 booksLength) {
        require(id < booksLength, "This book does not exist!");
        _;
    }
}
