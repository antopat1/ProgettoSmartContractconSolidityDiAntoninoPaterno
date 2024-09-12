// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./SalesLibrary.sol";

contract CourseCommerceManager {
    using SalesLibrary for SalesLibrary.Sale[]; // Utilizza la libreria per l'array di vendite

    address public owner;
    uint256 public totalSalesCount;
    uint256 public totalProductsCount;

    struct Product {
        uint256 id;
        string name;
        uint256 priceInWei; // Prezzo espresso in Wei
    }

    Product[] public products;
    SalesLibrary.Sale[] public sales;

    event ProductAdded(uint256 indexed id, string name, uint256 priceInWei);
    event SaleMade(
        uint256 indexed productId,
        address indexed buyer,
        uint256 timestamp
    );

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Solo il proprietario del contratto puo' eseguire questa funzione."
        );
        _;
    }

    // Funzione per aggiungere un nuovo prodotto
    function addProduct(
        string memory _name,
        uint256 _priceInWei
    ) public onlyOwner returns (uint256) {
        require(
            bytes(_name).length > 0,
            "Il nome del prodotto deve essere specificato."
        );
        require(_priceInWei > 0, "Il prezzo deve essere maggiore di 0.");

        // Aggiungi il prodotto
        products.push(Product(totalProductsCount, _name, _priceInWei));

        // Incrementa il contatore dei prodotti
        totalProductsCount++;

        // Emetti l'evento
        emit ProductAdded(totalProductsCount - 1, _name, _priceInWei);

        // Restituisci l'ID del prodotto appena creato
        return totalProductsCount - 1;
    }

    // Funzione per acquistare un prodotto
    function purchaseProduct(uint256 _productId) public payable {
        require(_productId < products.length, "Il prodotto non esiste.");
        Product memory productToBuy = products[_productId];
        require(
            msg.value == productToBuy.priceInWei,
            "L'importo inviato non corrisponde al prezzo del prodotto."
        );

        // Registra la vendita
        sales.push(SalesLibrary.Sale(_productId, msg.sender, block.timestamp));
        totalSalesCount++;

        emit SaleMade(_productId, msg.sender, block.timestamp);
    }

    // Funzione per ottenere le informazioni su un prodotto specifico
    function getProduct(
        uint256 _productId
    ) public view returns (Product memory) {
        require(_productId < products.length, "Il prodotto non esiste.");
        return products[_productId];
    }

    // Funzione per ottenere le informazioni su una vendita specifica
    function getSale(
        uint256 _saleId
    ) public view returns (SalesLibrary.Sale memory) {
        require(_saleId < sales.length, "La vendita non esiste.");
        return sales[_saleId];
    }

    // *** Utilizzo delle funzioni della libreria SalesLibrary ***

    // Restituisce i prodotti acquistati da un cliente
    function getCustomerPurchases(
        address _customer
    ) public view returns (uint256[] memory) {
        return sales.getPurchasedProducts(_customer); // Usa la funzione della libreria
    }

    // Calcola il totale delle vendite in Wei in un dato intervallo di tempo
    function getSalesInPeriod(
        uint256 _startTimestamp,
        uint256 _endTimestamp
    ) public view returns (uint256) {
        // Creiamo un array dei prezzi dei prodotti per passarlo alla libreria
        uint256[] memory productPrices = new uint256[](products.length);
        for (uint256 i = 0; i < products.length; i++) {
            productPrices[i] = products[i].priceInWei;
        }
        return
            sales.calculateTotalSales(
                _startTimestamp,
                _endTimestamp,
                productPrices
            ); // Usa la funzione della libreria
    }

    // Funzione per il proprietario per prelevare i fondi dal contratto
    function withdrawFunds() public onlyOwner {
        require(address(this).balance > 0, "Non ci sono fondi da prelevare.");
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success, "Prelievo dei fondi fallito.");
    }
}
