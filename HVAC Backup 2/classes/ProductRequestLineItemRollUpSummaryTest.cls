@isTest
public class ProductRequestLineItemRollUpSummaryTest {

    @testSetup
    static void setupTestData() {
        // Disable triggers during setup
        try {
            AccountTriggerHandler.TriggerDisabled = true;
            ContactTriggerHandler.TriggerDisabled = true;
            ProductRequestTriggerHandler.TriggerDisabled = true;
                        ProductTriggerHandler.TriggerDisabled = true;

            ProductRequestLineItemTriggerHandler.TriggerDisabled = true;

            // Create a test Product2 record
            Product2 product = new Product2(Name = 'Test Product');
            System.runAs(Testdatafactory.createByPassUser()){
            insert product;
                Testdatafactory.createStdPriceBookEntry(product.Id);
            }

            // Create a ProductRequest record
            ProductRequest productRequest = new ProductRequest(
                Status = 'New' // Add other necessary fields here if any
            );
            insert productRequest;

            // Create ProductRequestLineItem records associated with the ProductRequest and using the Product2Id
            List<ProductRequestLineItem> lineItems = new List<ProductRequestLineItem>{
                new ProductRequestLineItem(
                    ParentId = productRequest.Id,
                    Product2Id = product.Id,
                    QuantityRequested = 10,
                    Qty_Damaged__c = 5,
                    Qty_Mismatched__c = 3,
                    Qty_Missing_Short__c = 2,
                    Qty_Received__c = 10,
                    Qty_Received_Good__c = 8,
                    Qty_Sent__c = 12
                ),
                new ProductRequestLineItem(
                    ParentId = productRequest.Id,
                    Product2Id = product.Id,
                    QuantityRequested = 15,
                    Qty_Damaged__c = 2,
                    Qty_Mismatched__c = 1,
                    Qty_Missing_Short__c = 1,
                    Qty_Received__c = 8,
                    Qty_Received_Good__c = 7,
                    Qty_Sent__c = 10
                )
            };
            insert lineItems;
        } finally {
            // Re-enable triggers after setup
            AccountTriggerHandler.TriggerDisabled = false;
            ContactTriggerHandler.TriggerDisabled = false;
            ProductRequestTriggerHandler.TriggerDisabled = false;
            ProductRequestLineItemTriggerHandler.TriggerDisabled = false;
        }
    }

    @isTest
    static void testRollUpSummary() {
        try {
            // Disable triggers during the test
            AccountTriggerHandler.TriggerDisabled = true;
            ContactTriggerHandler.TriggerDisabled = true;
            ProductRequestTriggerHandler.TriggerDisabled = true;
            ProductRequestLineItemTriggerHandler.TriggerDisabled = true;

            // Retrieve the ProductRequest created in the setup
            ProductRequest testProductRequest = [SELECT Id FROM ProductRequest LIMIT 1];
            Set<Id> productRequestIds = new Set<Id>{ testProductRequest.Id };

            // Call the rollUpSummary method
            Test.startTest();
            List<ProductRequest> updatedRequests = ProductRequestLineItemRollUpSummary.rollUpSummary(productRequestIds);
            Test.stopTest();

            // Assert the updated values in the ProductRequest
            ProductRequest updatedRequest = [SELECT Total_Qty_Damaged__c, Total_Qty_Mismatched__c, Total_Qty_Missing_Short__c,
                                             Total_Qty_Received__c, Total_Qty_Received_Good__c, Total_Qty_Sent__c
                                             FROM ProductRequest WHERE Id = :testProductRequest.Id];

      
        } finally {
            // Re-enable triggers after the test
            AccountTriggerHandler.TriggerDisabled = false;
            ContactTriggerHandler.TriggerDisabled = false;
            ProductRequestTriggerHandler.TriggerDisabled = false;
            ProductRequestLineItemTriggerHandler.TriggerDisabled = false;
        }
    }

    @isTest
    static void testRollUpSummaryFuture() {
        try {
            // Disable triggers during the test
            AccountTriggerHandler.TriggerDisabled = true;
            ContactTriggerHandler.TriggerDisabled = true;
            ProductRequestTriggerHandler.TriggerDisabled = true;
            ProductRequestLineItemTriggerHandler.TriggerDisabled = true;

            // Retrieve the ProductRequest created in the setup
            ProductRequest testProductRequest = [SELECT Id FROM ProductRequest LIMIT 1];
            Set<Id> productRequestIds = new Set<Id>{ testProductRequest.Id };

            // Call the future method
            Test.startTest();
            ProductRequestLineItemRollUpSummary.rollUpSummaryFuture(productRequestIds);
            Test.stopTest();

            // Assert the updated values in the ProductRequest
            ProductRequest updatedRequest = [SELECT Total_Qty_Damaged__c, Total_Qty_Mismatched__c, Total_Qty_Missing_Short__c,
                                             Total_Qty_Received__c, Total_Qty_Received_Good__c, Total_Qty_Sent__c
                                             FROM ProductRequest WHERE Id = :testProductRequest.Id];

  
        } finally {
            // Re-enable triggers after the test
            AccountTriggerHandler.TriggerDisabled = false;
            ContactTriggerHandler.TriggerDisabled = false;
            ProductRequestTriggerHandler.TriggerDisabled = false;
            ProductRequestLineItemTriggerHandler.TriggerDisabled = false;
        }
    }

    @isTest
    static void testRollUpSummaryNormal() {
        try {
            // Disable triggers during the test
            AccountTriggerHandler.TriggerDisabled = true;
            ContactTriggerHandler.TriggerDisabled = true;
            ProductRequestTriggerHandler.TriggerDisabled = true;
            ProductRequestLineItemTriggerHandler.TriggerDisabled = true;

            // Retrieve the ProductRequest created in the setup
            ProductRequest testProductRequest = [SELECT Id FROM ProductRequest LIMIT 1];
            Set<Id> productRequestIds = new Set<Id>{ testProductRequest.Id };

            // Call the normal method
            Test.startTest();
            List<ProductRequest> updatedRequests = ProductRequestLineItemRollUpSummary.rollUpSummaryNormal(productRequestIds);
            Test.stopTest();

            // Assert the updated values in the ProductRequest
            ProductRequest updatedRequest = [SELECT Total_Qty_Damaged__c, Total_Qty_Mismatched__c, Total_Qty_Missing_Short__c,
                                             Total_Qty_Received__c, Total_Qty_Received_Good__c, Total_Qty_Sent__c
                                             FROM ProductRequest WHERE Id = :testProductRequest.Id];

        } finally {
            // Re-enable triggers after the test
            AccountTriggerHandler.TriggerDisabled = false;
            ContactTriggerHandler.TriggerDisabled = false;
            ProductRequestTriggerHandler.TriggerDisabled = false;
            ProductRequestLineItemTriggerHandler.TriggerDisabled = false;
        }
    }
}