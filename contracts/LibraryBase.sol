// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
pragma abicoder v2;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Validation.sol";
import "./BookCheck.sol";

contract LibraryBase is Ownable, BookCheck, Validation {
    struct Book {
        string name;
        uint16 quantity;
    }

    Book[] public books;

    mapping(bytes32 => uint256) booksIds;
    mapping(string => Book) bookNameMap;
    mapping(address => mapping(uint256 => bool)) buyers;
    mapping(uint256 => address[]) bookBuyers;

    event BookAdded(uint256 id, string name, uint256 quantity);
    event BookUpdated(uint256 id, string name, uint256 quantity);
    event BookBought(uint256 id, address buyer);
    event BookRefund(uint256 id);

    function internalAddBook(
        uint256 id,
        string memory name,
        uint16 quantity
    ) internal {
        Book memory newBook = Book({name: name, quantity: quantity});
        bytes32 idHash = generateId(name);
        booksIds[idHash] = id;
        books.push(newBook);
        bookNameMap[name] = newBook;
    }

    function internalUpdateBook(uint256 id, uint16 quantity) internal {
        books[id].quantity = quantity;
    }

    function internalAddBuyer(uint256 id, address client) internal {
        buyers[client][id] = true;
        bookBuyers[id].push(client);
    }

    function internalRefund(uint256 id, address client) internal {
        bool bought = buyers[client][id];

        require(
            bought,
            "You've already returned your Book or didn't even bought it."
        );
        buyers[client][id] = false;
    }

    function internalCheckBuyers(uint256 id, address client)
        internal
        view
        returns (bool)
    {
        return buyers[client][id];
    }

    function generateId(string memory name) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(name));
    }
}
