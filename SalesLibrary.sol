// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

library SalesLibrary {
    // Funzione per ottenere i prodotti acquistati da un determinato cliente
    function getPurchasedProducts(Sale[] memory sales, address customer) public pure returns (uint256[] memory) {
        uint256[] memory purchasedProducts = new uint256[](sales.length);
        uint256 count = 0;
        for (uint256 i = 0; i < sales.length; i++) {
            if (sales[i].buyer == customer) {
                purchasedProducts[count] = sales[i].productId;
                count++;
            }
        }

        // Ridimensionare l'array per restituire solo gli acquisti effettivi
        uint256[] memory result = new uint256[](count);
        for (uint256 j = 0; j < count; j++) {
            result[j] = purchasedProducts[j];
        }

        return result;
    }

    // Funzione per calcolare il totale delle vendite in Ether dato un periodo di tempo
    function calculateTotalSales(Sale[] memory sales, uint256 startTime, uint256 endTime, Product[] memory products) public pure returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < sales.length; i++) {
            if (sales[i].timestamp >= startTime && sales[i].timestamp <= endTime) {
                total += products[sales[i].productId].priceInWei;
            }
        }
        return total;
    }
}
