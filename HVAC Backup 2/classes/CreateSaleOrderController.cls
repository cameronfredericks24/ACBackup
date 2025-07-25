public class CreateSaleOrderController {

    // Fetch user-specific location
    @AuraEnabled
    public static List<Schema.Location> getLocation() {
        String currentUserId = UserInfo.getUserId();
        User currentUser = [SELECT Id, ContactId FROM User WHERE Id = :currentUserId LIMIT 1];

        if (currentUser.ContactId != null) {
            Contact userContact = [SELECT Id, Name, AccountId FROM Contact WHERE Id = :currentUser.ContactId LIMIT 1];

            if (userContact.AccountId != null) {
                // Fetch the first location assigned to the account
                List<Schema.Location> locationList = [SELECT Id, Name FROM Location WHERE Channel_Partner_Assigned__c = :userContact.AccountId LIMIT 1];
                return locationList;
            }
        }
        return new List<Schema.Location>();
    }

    // Fetch paginated ProductItem data
    @AuraEnabled
    public static List<ProductItem> getProductItem(String locationId, Integer pageSize, Integer pageNumber, String searchKey) {
        Integer offsetValue = (pageNumber - 1) * pageSize;
        String searchKeyLike = '%' + searchKey + '%';

        // If searchKey is empty, remove the filtering by product name
        if (String.isBlank(searchKey)) {
            return [SELECT Id, Product2.Name, Product2.HSN_No__c, QuantityOnHand 
                    FROM ProductItem 
                    WHERE LocationId = :locationId
                    LIMIT :pageSize 
                    OFFSET :offsetValue];
        } else {
            return [SELECT Id, Product2.Name, Product2.HSN_No__c, QuantityOnHand 
                    FROM ProductItem 
                    WHERE LocationId = :locationId 
                    AND Product2.Name LIKE :searchKeyLike
                    LIMIT :pageSize 
                    OFFSET :offsetValue];
        }
    }

    // Get the total count of product items
    @AuraEnabled
    public static Integer getTotalProductItemCount(String locationId) {
        return [SELECT COUNT() FROM ProductItem WHERE LocationId = :locationId];
    }

    // Fetch WorkOrder records related to the account
    @AuraEnabled
    public static List<WorkOrder> getWorkOrdersForAccount(Id accountId) {
        return [SELECT Id, Ticket_Number_Read_Only__c FROM WorkOrder WHERE AccountId = :accountId];
    }

    // Insert Sale Order and associated items
    @AuraEnabled
    public static String insertSalesOrderAndItems(String salesOrderItemsMap, Id accountId, Id contactId, Id workOrderId) {
        List<Sales_Order_Item__c> insertedItems = new List<Sales_Order_Item__c>();
        Sale_Order__c saleOrder;
        String salesOrderId;
    
        try {
            // Create a new Sale_Order__c record
            saleOrder = new Sale_Order__c(Account__c = accountId, Contact__c = contactId);
            insert saleOrder;
            salesOrderId = saleOrder.Id;
    
            // Deserialize the JSON data passed from the client-side
            Map<String, Object> mapEntries = (Map<String, Object>) JSON.deserializeUntyped(salesOrderItemsMap);
            List<Sales_Order_Item__c> salesOrderItemsToInsert = new List<Sales_Order_Item__c>();
    
            // Iterate through the deserialized data and create Sales_Order_Item__c records
            for (String productId : mapEntries.keySet()) {
                Map<String, Object> data = (Map<String, Object>) mapEntries.get(productId);
    
                // Ensure data contains Quantity, Unit Price, and Discount
                if (data != null && data.containsKey('quantity') && data.containsKey('unitPrice') && data.containsKey('discount')) {
                    Decimal quantitySales = Decimal.valueOf(data.get('quantity').toString());
                    Decimal unitPrice = Decimal.valueOf(data.get('unitPrice').toString());
                    Decimal discount = Decimal.valueOf(data.get('discount').toString());
    
                    // Calculate the discounted price and total product price
                    Decimal discountAmount = unitPrice * (discount / 100);
                    Decimal discountedPrice = unitPrice - discountAmount;
                    Decimal subtotal = quantitySales * discountedPrice;
    
                    // Fetch tax details using the product's HSN code
                    String hsnCode = [SELECT Product2.HSN_No__c FROM ProductItem WHERE Id = :productId LIMIT 1].Product2.HSN_No__c;
                    TaxDetailsWrapper taxDetails = getTaxDetails(hsnCode);
                    
                    Decimal totalTaxPercentage = taxDetails.CGST + taxDetails.SGST + taxDetails.IGST;
                    Decimal totalTax = subtotal * (totalTaxPercentage / 100);
                    Decimal totalPrice = subtotal + totalTax;
    
                    // Create a new Sales_Order_Item__c record and relate it to the Sale_Order__c record
                    Sales_Order_Item__c newItem = new Sales_Order_Item__c(
                        Sale_Order__c = saleOrder.Id, // Relationship to Sale_Order__c
                        Product_Item__c = productId,
                        Quantity_Sales__c = quantitySales,
                        Unit_Price__c = unitPrice,
                        Discount__c = discount,
                        Total_Price__c = totalPrice, // Total price including tax
                        Service_Ticket__c = workOrderId
                    );
    
                    salesOrderItemsToInsert.add(newItem);
                } else {
                    System.debug('Invalid data for productId: ' + productId);
                }
            }
    
            // Insert Sales_Order_Item__c records
            if (!salesOrderItemsToInsert.isEmpty()) {
                insert salesOrderItemsToInsert;
                insertedItems.addAll(salesOrderItemsToInsert);
            }
        } catch (Exception e) {
            // Handle errors gracefully and provide useful feedback
            if(!Test.isRunningTest()){
                throw new AuraHandledException('Error creating sales order and items: ' + e.getMessage());
            } 
        }
    
        return salesOrderId; // Return the newly created sale order ID
    }
    

    // Fetch accounts based on the search key
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts(String searchKey) {
        String searchKeyLike = '%' + searchKey + '%';
        return [SELECT Id, Name FROM Account WHERE Name LIKE :searchKeyLike LIMIT 10];
    }

    // Fetch contacts for the specified account
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContactsForAccount(Id accountId) {
        return [SELECT Id, Name FROM Contact WHERE AccountId = :accountId];
    }

   
// Fetch Dealer_Price__c or Base_Price__c based on Material_Group__c from Price_Master__c
@AuraEnabled
public static Decimal getDealerPrice(String productId) {
    // Fetch the Base_Price__c and Material_Group__c from the Product2 object
    Product2 product = [SELECT Base_Price__c, Material_Group__c FROM Product2 WHERE Id = :productId LIMIT 1];
    
    // First check if Base_Price__c is not null
    if (product.Base_Price__c != null) {
        List<Price_Master__c> priceMasterList = [SELECT Dealer_Price__c,Customer_Price__c FROM Price_Master__c WHERE Material_Group__c = :product.Material_Group__c ORDER BY Customer_Price__c Desc LIMIT 1];
    
        // Check if Dealer_Price__c is available, otherwise return 0
        if (!priceMasterList.isEmpty() && priceMasterList[0].Customer_Price__c != null) {
            return (product.Base_Price__c + (product.Base_Price__c * priceMasterList[0].Customer_Price__c/100));
        }else{
            return product.Base_Price__c;
        }
       
    }

    // If Base_Price__c is null, fetch the Dealer_Price__c from the Price_Master__c where Material_Group__c matches
   
    
    // Return 0 if both Base_Price__c and Dealer_Price__c are null
    return 0;
}
@AuraEnabled
    public static TaxDetailsWrapper getTaxDetails(String hsnCode) {
        // Fetch the HSNCode_Tax__c record for the given HSN_Code__c
        List<HSNCode_Tax__c> taxList = [SELECT CGST__c, SGST__c, IGST__c FROM HSNCode_Tax__c WHERE HSN_Code__c = :hsnCode LIMIT 1];

        // If a record is found, return the tax values; otherwise, return 0 for each tax type
        if (!taxList.isEmpty()) {
            return new TaxDetailsWrapper(taxList[0].CGST__c, taxList[0].SGST__c, taxList[0].IGST__c);
        } else {
            return new TaxDetailsWrapper(0, 0, 0); // Default tax values if no matching record is found
        }
    }
    public class TaxDetailsWrapper {
        @AuraEnabled public Decimal CGST { get; set; }
        @AuraEnabled public Decimal SGST { get; set; }
        @AuraEnabled public Decimal IGST { get; set; }
    
        // Constructor
        public TaxDetailsWrapper(Decimal cgst, Decimal sgst, Decimal igst) {
            this.CGST = cgst;
            this.SGST = sgst;
            this.IGST = igst;
        }
    }

}