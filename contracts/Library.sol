// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
pragma abicoder v2;
import "./LibraryBase.sol";

contract Library is LibraryBase {
    function addBook(string memory name, uint16 quantity)
        public
        onlyOwner
        quantityCheck(quantity)
        nameCheck(name)
    {
        bool bookExist = bytes(bookNameMap[name].name).length > 0;
        uint256 bookId = booksIds[generateId(name)];

        if (bookExist) {
            Book storage selectedBook = books[bookId];
            internalUpdateBook(bookId, quantity);
            emit BookUpdated(bookId, selectedBook.name, selectedBook.quantity);
        } else {
            bookId = books.length;
            internalAddBook(books.length, name, quantity);
            emit BookAdded(bookId, name, quantity);
        }
    }

    function updateBookQuantity(uint256 id, uint16 quantity)
        public
        onlyOwner
        bookExist(id, books.length)
    {
        internalUpdateBook(id, quantity);

        Book storage selectedBook = books[id];
        emit BookUpdated(id, selectedBook.name, selectedBook.quantity);
    }

    function rentBook(uint256 id)
        public
        quantityCheck(books[id].quantity)
        bookExist(id, books.length)
    {
        address client = msg.sender;
        Book storage selectedBook = books[id];

        bool alreadyRentedByClient = internalCheckRenter(id, client);
        require(
            !alreadyRentedByClient,
            "You cannot rent the same Book more than once!"
        );
        require(
            IERC20(LIBToken).transferFrom(msg.sender, address(this), rentPrice)
        );
        internalAddRenter(id, client);
        selectedBook.quantity--;

        emit BookRented(id, client);
    }

    function returnBook(uint256 id) public bookExist(id, books.length) {
        address client = msg.sender;

        internalReturn(id, client);
        Book storage selectedBook = books[id];
        selectedBook.quantity++;
        emit BookReturn(id);
    }

    function getBookByName(string memory name)
        public
        view
        nameCheck(name)
        returns (Book memory)
    {
        bool BookExist = bytes(bookNameMap[name].name).length > 0;
        require(BookExist, "This Book does not exist!");

        uint256 bookId = booksIds[generateId(name)];
        Book storage selectedBook = books[bookId];
        return selectedBook;
    }

    function getBookById(uint256 id)
        public
        view
        bookExist(id, books.length)
        returns (Book memory)
    {
        Book storage selectedBook = books[id];
        return selectedBook;
    }

    function getBookRentersById(uint256 id)
        public
        view
        bookExist(id, books.length)
        returns (address[] memory)
    {
        return bookRenters[id];
    }

    function getAllBooks() public view returns (Book[] memory) {
        return books;
    }

    function setLIBTokenAddress(address token) public onlyOwner {
        LIBToken = token;
    }

    function setRentPrice(uint256 price) public onlyOwner {
        rentPrice = price;
    }

    function setLIBWrapperAddress(address wrapper) public onlyOwner {
        LIBWrapper = wrapper;
    }

    function unwrapProfit() public onlyOwner {
        IERC20(LIBToken).approve(
            LIBWrapper,
            IERC20(LIBToken).balanceOf(address(this))
        );
        Wrapper(LIBWrapper).unwrap(IERC20(LIBToken).balanceOf(address(this)));
    }

    function withdraw() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
