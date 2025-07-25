public without sharing class SalesOrderItemTriggerHelper {
    public SalesOrderItemTriggerHelper() {
        System.debug('Inside AccountTriggerHelper Constructor');
    }

/*
@Author :Rishabh Sahu
@CreatedDate : 08th Apr 2024
@Description :Inserting Product Item Transaction Record
*/
public static void insertProductItemTransaction(List<Sales_Order_Item__c> newSalesOrderItems) {
    try {
        Set<Id> productItemIds = new Set<Id>();
        List<ProductItemTransaction> transactionsToInsert = new List<ProductItemTransaction>();

        // Collect all Product Item Ids associated with the inserted Sales Order Item records
        for (Sales_Order_Item__c sales : newSalesOrderItems) {
            if (sales.Product_Item__c != null) {
                productItemIds.add(sales.Product_Item__c);
            }
        }

        // Query Product Items 
        Map<Id, ProductItem> productItemMap = new Map<Id, ProductItem>(ProductItemSelector.getProductItemId(productItemIds));

        // Update QuantityOnHand based on Quantity_Sales__c from related Product Sales records
        for (Sales_Order_Item__c sales : newSalesOrderItems) {
            if (productItemMap.containsKey(sales.Product_Item__c)) {
                ProductItem item = productItemMap.get(sales.Product_Item__c);

                // Create a new transaction record
                ProductItemTransaction pitransaction = new ProductItemTransaction();
                pitransaction.ProductItemId = item.Id;
                pitransaction.Quantity = Decimal.valueOf('-' + sales.Quantity_Sales__c);
                pitransaction.TransactionType = 'Adjusted';
                pitransaction.Sales_Record__c = sales.Id; 
                transactionsToInsert.add(pitransaction);
            }
        }

        // Insert the new transaction records
        if (!transactionsToInsert.isEmpty()) {
            insert transactionsToInsert;
        }
        
    } catch (DmlException e) {
        System.debug('DML Exception occurred: ' + e.getMessage());
    } catch (QueryException e) {
        System.debug('Query Exception occurred: ' + e.getMessage());
    } catch (Exception e) {
        System.debug('An error occurred: ' + e.getMessage());
    } 
}

}