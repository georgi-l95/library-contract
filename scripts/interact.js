const hre = require("hardhat");
const Library = require("../artifacts/contracts/Library.sol/Library.json");
const walletKey =
  "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";
const contractAddress = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";
const provider = new hre.ethers.providers.JsonRpcProvider(
  "http://localhost:8545"
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

const run = async function () {
  const wallet = new hre.ethers.Wallet(walletKey, provider);
  const libraryContract = new hre.ethers.Contract(
    contractAddress,
    Library.abi,
    wallet
  );

  await addBooks(libraryContract);

  const getAllBooks = await libraryContract.getAllBooks();

  console.log(getAllBooks);
};

run();
//npx hardhat run --network localhost scripts/interact.js
