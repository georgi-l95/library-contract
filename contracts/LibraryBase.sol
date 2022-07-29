// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
pragma abicoder v2;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Validation.sol";
import "./BookCheck.sol";

interface IERC20 {
    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

interface Wrapper {
    function wrap() external payable;

    function unwrap(uint256 value) external;
}

contract LibraryBase is Ownable, BookCheck, Validation {
    struct Book {
        string name;
        uint16 quantity;
    }

    Book[] public books;
    address public LIBToken;
    address public LIBWrapper;
    uint256 public rentPrice = 100000000000000000;
    mapping(bytes32 => uint256) booksIds;
    mapping(string => Book) bookNameMap;
    mapping(address => mapping(uint256 => bool)) borrower;
    mapping(uint256 => address[]) bookBorrowers;

    event BookAdded(uint256 id, string name, uint256 quantity);
    event BookUpdated(uint256 id, string name, uint256 quantity);
    event BookBorrowed(uint256 id, address borrower);
    event BookReturn(uint256 id);

    receive() external payable {}

    fallback() external payable {}

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

    function internalAddBorrower(uint256 id, address client) internal {
        borrower[client][id] = true;
        bookBorrowers[id].push(client);
    }

    function internalReturn(uint256 id, address client) internal {
        bool rented = borrower[client][id];

        require(
            rented,
            "You've already returned your Book or didn't even rent it."
        );
        borrower[client][id] = false;
    }

    function internalCheckBorrower(uint256 id, address client)
        internal
        view
        returns (bool)
    {
        return borrower[client][id];
    }

    function generateId(string memory name) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(name));
    }
}
