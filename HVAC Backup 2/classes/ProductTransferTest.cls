@isTest
private class ProductTransferTest {

    @isTest
    static void testCreateDefectiveProductLineItems() {
        TestDataFactory.disableTriggers();
        Product_Family__c productFamily = TestDataFactory.createProductFamily('AC - Room Air Conditioner');
        Product_Family__c productSubFamily = TestDataFactory.createProductSubFamily('Split', productFamily);
        Product2 product = TestDataFactory.createProduct('1TR R32 1 STAR F HW SAC', 'GHTY89', productFamily, productSubFamily);
        Schema.Location locationRecord = TestDataFactory.createLocation('locationName-1', 'RPC');
        Branch__c branch = TestDataFactory.createBranch('Mumbai');
        Account account = TestDataFactory.createResidentialAccount('Test Residential Account', '6677889977');
        //Asset asset = TestDataFactory.createAsset('Test Asset', 'Active', product, branch, Date.today(), 'INV12345', account);
        //Case caseRecord = TestDataFactory.createCase('Test Case', 'New', 'Issue', account, asset, product, branch);
        //WorkType workType = TestDataFactory.createWorkType('Installation');
       // WorkOrder parentWorkOrder = TestDataFactory.createWorkOrder(asset, workType, account, caseR
        ProductRequest prodRequest =  new ProductRequest();
        prodRequest.Product__c =product.id;
        insert prodRequest;
        GRN__c grnRecord = TestDataFactory.createGRN(prodRequest, 'Approved','RMR');
        ProductRequestLineItem prodReqLineItem = TestDataFactory.createProductRequestLineItem(prodRequest, account, product, locationRecord);
        ProductTransfer productTransfer = TestDataFactory.createProductTransfer(product,locationRecord,grnRecord, prodReqLineItem);
        

        List<ProductTransfer> transferList = [
            SELECT Id, Quantity_Damaged__c, Part_Request_MR__c, ProductRequestId, Product2Id, DestinationLocationId,ProductRequestLineItemId 
            FROM ProductTransfer 
            WHERE Id = :productTransfer.Id
        ];


        Test.startTest();
        ProductTransferTriggerHandler handler = new ProductTransferTriggerHandler();
        handler.beforeInsert(transferList);
        handler.afterInsert(transferList, Null);
        handler.beforeUpdate(transferList, Null, NULL, NULL);
        handler.afterUpdate(transferList, Null, NULL, NULL);
        handler.beforeDelete(NULL, NULL);
        handler.afterDelete(NULL, NULL);
        Test.stopTest();
    
        List<Defective_Product_Item__c> defectItems = [
            SELECT Id, Product_Name__c, Location__c, Quantity_On_Hand__c, Product_Transfer__c, Part_Request__c, 
                   Channel_Partner__c, SDE__c, Defective_Category__c, Part_Request_Line_Item__c
            FROM Defective_Product_Item__c
        ];
        

        System.assertEquals(1, defectItems.size(), 'Expected 1 Defective Product Item');
        Defective_Product_Item__c defectItem = defectItems[0];
        /*
         System.assertEquals(product.Id, defectItem.Product_Name__c, 'Product should match');
         System.assertEquals(productTransfer.DestinationLocationId, defectItem.Location__c, 'Location should match');
         System.assertEquals(productTransfer.Quantity_Damaged__c, defectItem.Quantity_On_Hand__c, 'Quantity should match');
         System.assertEquals('RMR', defectItem.Defective_Category__c, 'Defective Category should be RMR');
*/
        TestDataFactory.enableTriggers();
    }
    

}