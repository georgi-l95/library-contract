const hre = require("hardhat");
const Library = require("../artifacts/contracts/Library.sol/Library.json");
const walletKey =
  "796e2930429e8606d9b4e3a635b649e31909413245097056d87bab9ae3bf098c";
const contractAddress = "0x15c69195AA2E3A90aaa8B8383E44630FeA8f07Bf";
const provider = new hre.ethers.providers.InfuraProvider(
  "ropsten",
  "40c2813049e44ec79cb4d7e0d18de173"
);

books = [
  { name: "test", quantity: 15 },
  {
    name: "test1",
    quantity: 13,
  },
  { name: "test2", quantity: 15 },
  {
    name: "test3",
    quantity: 13,
  },
];

const addBooks = async function (contract) {
  for (let i = 0; i < books.length; i++) {
    const addBook = await contract.addBook(books[i].name, books[i].quantity);
    const transactionReciept = await addBook.wait();
    if (transactionReciept.status != 1) {
      console.log("Transaction was unsuccessfull!");
      return;
    }
  }
};

const rentBook = async function (contract, bookId) {
  const rentBook = await contract.rentBook(bookId);
  const rentBookReciept = await rentBook.wait();
  if (rentBookReciept.status != 1) {
    console.log("Transaction was unsuccessfull!");
    return;
  }
};

const returnBook = async function (contract, bookId) {
  const returnBook = await contract.returnBook(bookId);
  const returnBookReciept = await returnBook.wait();
  if (returnBookReciept.status != 1) {
    console.log("Transaction was unsuccessfull!");
    return;
  }
};

const getAllBooks = async function (contract) {
  const getAllBooks = await contract.getAllBooks();
  return `All available books: ${getAllBooks}`;
};
const run = async function () {
  const wallet = new hre.ethers.Wallet(walletKey, provider);
  const libraryContract = new hre.ethers.Contract(
    contractAddress,
    Library.abi,
    wallet
  );

  await addBooks(libraryContract);

  let availableBooks = await getAllBooks(libraryContract);
  console.log(availableBooks);

  await rentBook(libraryContract, 0);

  const rentedBook = await libraryContract.getBookRentersById(0);
  console.log(`This book was rented by ${rentedBook}`);

  await returnBook(libraryContract, 0);

  availableBooks = await getAllBooks(libraryContract);
  console.log(availableBooks);
};

run();
//npx hardhat run --network localhost scripts/interact.js
