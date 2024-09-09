// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./SalesLibrary.sol";  // Libreria per operazioni sulle vendite

contract CourseCommerceManager is ReentrancyGuard {
    address public owner;

    struct Product {
        uint256 id;
        string name;
        uint256 priceInWei; 
        bool exists;
    }

    struct Sale {
        uint256 productId;
        address buyer;
        uint256 timestamp;
    }

    // Array per tenere traccia di tutti i prodotti disponibili.
    Product[] public products;

    // contatore per vendite effettuate
    uint256 public totalSales;

    // Array vendite effettuate
    Sale[] public sales;

    // Evento per notificare quando una nuova vendita viene registrata.
    event SaleRegistered(address buyer, uint256 productId, uint256 timestamp);

    
    modifier onlyOwner() {
        require(msg.sender == owner, "Solo il proprietario puo' eseguire questa funzione.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Funzione per aggiungere un nuovo prodotto disponibile per la vendita
    function addProduct(string memory _name, uint256 _priceInEther) public onlyOwner {
        require(bytes(_name).length > 0, "Il nome del prodotto non puo' essere vuoto.");
        require(_priceInEther > 0, "Il prezzo deve essere positivo.");
        
        uint256 productId = products.length;
        products.push(Product(productId, _name, etherToWei(_priceInEther), true));
    }

    // Funzione per permettere a un cliente di acquistare un prodotto e di registrare la vendita
    function purchaseProduct(uint256 _productId) public payable nonReentrant {
        require(_productId < products.length, "Prodotto non valido.");
        Product memory product = products[_productId];
        require(msg.value == product.priceInWei, "Importo non corrisponde al prezzo del prodotto.");

        // Aggiungi dettagli vendita all'array di tutte le vendite effettuate
        sales.push(Sale(_productId, msg.sender, block.timestamp));
        totalSales++;

        // Emissione evento che traccia nuova vendita 
        emit SaleRegistered(msg.sender, _productId, block.timestamp);
    }

    // Funzione per prelevare fondi dal contratto
    function withdrawFunds() public onlyOwner nonReentrant {
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "Nessun fondo disponibile per il prelievo.");
        
        (bool success, ) = owner.call{value: contractBalance}("");
        require(success, "Trasferimento dei fondi fallito.");
    }

    // Funzione per ottenere le informazioni di un prodotto
    function getProduct(uint256 _productId) public view returns (Product memory) {
        require(_productId < products.length, "Prodotto non valido.");
        return products[_productId];
    }

    // Funzione per ottenere le informazioni di una vendita
    function getSale(uint256 _saleId) public view returns (Sale memory) {
        require(_saleId < sales.length, "Vendita non valida.");
        return sales[_saleId];
    }

    // Funzione per convertire Ether in Wei (1 Ether = 1 * 10^18 Wei)
    function etherToWei(uint256 amountInEther) internal pure returns (uint256) {
        return amountInEther * 1 ether;
    }
}
