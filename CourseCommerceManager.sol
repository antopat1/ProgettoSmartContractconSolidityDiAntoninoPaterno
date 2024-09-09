// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Importa la libreria SalesLibrary
import "./SalesLibrary.sol";

contract CourseCommerceManager {
    using SalesLibrary for SalesLibrary.Sale[]; // Utilizza la libreria per array di vendite

    address public owner;
    uint256 public totalSalesCount;
    uint256 public totalProductsCount;

    struct Product {
        uint256 id;
        string name;
        uint256 price; // Prezzo in Wei
    }

    struct Sale {
        Product product;
        address buyer;
        uint256 timestamp;
    }

    Product[] public products;
    SalesLibrary.Sale[] public sales;

    event ProductAdded(uint256 indexed id, string name, uint256 price);
    event SaleMade(uint256 indexed productId, address indexed buyer, uint256 timestamp);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Solo il proprietario del contratto puo' eseguire questa funzione.");
        _;
    }

    // Funzione per aggiungere un nuovo prodotto
    function addProduct(string memory _name, uint256 _priceInEther) public onlyOwner {
        require(bytes(_name).length > 0, "Il nome del prodotto deve essere specificato.");
        require(_priceInEther > 0, "Il prezzo deve essere maggiore di 0.");

        uint256 priceInWei = _priceInEther * 1 ether;
        products.push(Product(totalProductsCount, _name, priceInWei));
        totalProductsCount++;

        emit ProductAdded(totalProductsCount, _name, priceInWei);
    }

    // Funzione per acquistare un prodotto
    function purchaseProduct(uint256 _productId) public payable {
        require(_productId < products.length, "Il prodotto non esiste.");
        Product memory productToBuy = products[_productId];
        require(msg.value == productToBuy.price, "L'importo inviato non corrisponde al prezzo del prodotto.");

        // Registra la vendita
        sales.push(SalesLibrary.Sale(productToBuy, msg.sender, block.timestamp));
        totalSalesCount++;

        emit SaleMade(_productId, msg.sender, block.timestamp);
    }

    // Funzione per ottenere le informazioni su un prodotto specifico
    function getProduct(uint256 _productId) public view returns (Product memory) {
        require(_productId < products.length, "Il prodotto non esiste.");
        return products[_productId];
    }

    // Funzione per ottenere le informazioni su una vendita specifica
    function getSale(uint256 _saleId) public view returns (Sale memory) {
        require(_saleId < sales.length, "La vendita non esiste.");
        return sales[_saleId];
    }

    // *** Integrazione delle funzioni della libreria SalesLibrary ***
    
    // Restituisce i prodotti acquistati da un cliente
    function getCustomerPurchases(address _customer) public view returns (SalesLibrary.Sale[] memory) {
        return sales.getPurchasesByCustomer(_customer); // Usa la funzione della libreria
    }

    // Calcola il totale delle vendite in Ether in un dato intervallo di tempo
    function getSalesInPeriod(uint256 _startTimestamp, uint256 _endTimestamp) public view returns (uint256) {
        return sales.getTotalSalesInPeriod(_startTimestamp, _endTimestamp); // Usa la funzione della libreria
    }

    // Funzione per il proprietario per prelevare i fondi dal contratto
    function withdrawFunds() public onlyOwner {
        require(address(this).balance > 0, "Non ci sono fondi da prelevare.");
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success, "Prelievo dei fondi fallito.");
    }
}
