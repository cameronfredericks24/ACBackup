@isTest
public class SAPCaptureSaleorderHelperTest {
    @isTest
    static void testCaptureSaleorderWithMultipleRequests() {
                TestDataFactory.disableTriggers();
        // Prepare test data (two JSON requests)
        String testJson1 = ' { ' +
            '"SalesOrder": "SALE91123", ' +
            '"PRNumber": "PR-27817", ' +
            '"PRDate": "2024-11-16", ' +
            '"OBDNumber": "OBD23534", ' +
            '"InvoiceNumber": "INV24345", ' +
            '"InvoiceItemList": [ ' +
                '{ "ItemNo": "000010", "Material": "DLC-16", "BilledQuantity": "14", "BilledQtyUoM": "Each" }, ' +
                '{ "ItemNo": "000020", "Material": "DLC-18", "BilledQuantity": "18", "BilledQtyUoM": "Each" } ' +
            '] ' +
        '}';

        String testJson2 = ' { ' +
            '"SalesOrder": "SALE91124", ' +
            '"PRNumber": "PR-27818", ' +
            '"PRDate": "2024-11-17", ' +
            '"OBDNumber": "OBD23535", ' +
            '"InvoiceNumber": "INV24346", ' +
            '"InvoiceItemList": [ ' +
                '{ "ItemNo": "000030", "Material": "DLC-20", "BilledQuantity": "10", "BilledQtyUoM": "Each" }, ' +
                '{ "ItemNo": "000040", "Material": "DLC-22", "BilledQuantity": "12", "BilledQtyUoM": "Each" } ' +
            '] ' +
        '}';

        // Deserialize JSON 
        SAPCaptureSaleorderRequestWrapper reqWrapper1 = (SAPCaptureSaleorderRequestWrapper)JSON.deserialize(testJson1, SAPCaptureSaleorderRequestWrapper.class);
        SAPCaptureSaleorderRequestWrapper reqWrapper2 = (SAPCaptureSaleorderRequestWrapper)JSON.deserialize(testJson2, SAPCaptureSaleorderRequestWrapper.class);

        // Create mock data for Product2 objects
        Product2 product1 = new Product2(ProductCode = 'DLC-16', Name = 'Product DLC-16');
        Product2 product2 = new Product2(ProductCode = 'DLC-18', Name = 'Product DLC-18');
        Product2 product3 = new Product2(ProductCode = 'DLC-20', Name = 'Product DLC-20');
        Product2 product4 = new Product2(ProductCode = 'DLC-22', Name = 'Product DLC-22');
        List<Product2> prodlIst = new List<Product2> { product1, product2, product3, product4 };
        
        System.runAs(Testdatafactory.createByPassUser()){
            insert prodlIst;
                Testdatafactory.createStdPriceBookEntryList(prodlIst);
            }

        // Call the captureSaleorder method for both requests
        Test.startTest();
        SAPCaptureSaleorderResponseWrapper responseWrapper1 = SAPCaptureSaleorderHelper.captureSaleorder(reqWrapper1);
        SAPCaptureSaleorderResponseWrapper responseWrapper2 = SAPCaptureSaleorderHelper.captureSaleorder(reqWrapper2);
        Test.stopTest();

        // Assertions for the first request
        //System.assertEquals('SUCCESS', responseWrapper1.result, 'First response result should be SUCCESS');
        //System.assertEquals('Sale order processed successfully.', responseWrapper1.message, 'First response message should match');
        ProductRequest createdRequest1 = [SELECT Id, PR_Number__c, Order_Number__c FROM ProductRequest WHERE PR_Number__c = :reqWrapper1.PRNumber];
        //System.assertNotEquals(null, createdRequest1, 'First ProductRequest should be created');
        //System.assertEquals('SALE91123', createdRequest1.Order_Number__c, 'First order number should match');

        // Assertions for the second request
        //System.assertEquals('SUCCESS', responseWrapper2.result, 'Second response result should be SUCCESS');
        //System.assertEquals('Sale order processed successfully.', responseWrapper2.message, 'Second response message should match');
        ProductRequest createdRequest2 = [SELECT Id, PR_Number__c, Order_Number__c FROM ProductRequest WHERE PR_Number__c = :reqWrapper2.PRNumber];
        //System.assertNotEquals(null, createdRequest2, 'Second ProductRequest should be created');
        //System.assertEquals('SALE91124', createdRequest2.Order_Number__c, 'Second order number should match');

        // Validate ProductRequestLineItem creation for the first request
        List<ProductRequestLineItem> lineItems1 = [
            SELECT Item_Number_API__c, QuantityRequested, QuantityUnitOfMeasure, Product2Id 
            FROM ProductRequestLineItem 
            WHERE ParentId = :createdRequest1.Id
        ];
        //System.assertEquals(2, lineItems1.size(), 'There should be two line items for the first request');

        // Validate ProductRequestLineItem creation for the second request
        List<ProductRequestLineItem> lineItems2 = [
            SELECT Item_Number_API__c, QuantityRequested, QuantityUnitOfMeasure, Product2Id 
            FROM ProductRequestLineItem 
            WHERE ParentId = :createdRequest2.Id
        ];
        //System.assertEquals(2, lineItems2.size(), 'There should be two line items for the second request');
                TestDataFactory.enableTriggers();
    }
}