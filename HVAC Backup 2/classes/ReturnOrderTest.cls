@isTest
public class ReturnOrderTest {   
  
    @isTest
    public static void testCreateChildWorkOrder1() {
        TestDataFactory.disableTriggers();

        Product_Family__c productFamily = TestDataFactory.createProductFamily('AC - Room Air Conditioner');
        Product_Family__c productSubFamily = TestDataFactory.createProductSubFamily('Split', productFamily);
        Product2 product = TestDataFactory.createProduct('1TR R32 1 STAR F HW SAC', 'GHTY89', productFamily, productSubFamily);
        Branch__c branch = TestDataFactory.createBranch('Mumbai');
        Account account = TestDataFactory.createResidentialAccount('Test Residential Account', '6677889977');
        Asset asset = TestDataFactory.createAsset('Test Asset', 'Active', product, branch, Date.today(), 'INV12345', account);
        Case caseRecord = TestDataFactory.createCase('Test Case', 'New', 'Issue', account, asset, product, branch);
        WorkType workType = TestDataFactory.createWorkType('Installation');
        WorkOrder parentWorkOrder = TestDataFactory.createWorkOrder(asset, workType, account, caseRecord, 'Completed');
        WorkOrder workOrder = TestDataFactory.createChildWorkOrder(parentWorkOrder);
        ReturnOrder returnOrder = TestDataFactory.createReturnOrder(parentWorkOrder, 'Transit Damage', 'Finish Good Received');

        // Act: Execute the logic
        Map<String, ReturnOrder> mapOfRO = new Map<String, ReturnOrder>([SELECT Id, Work_Order__c, CaseId, Invoice_Date__c FROM ReturnOrder]);
        
        Test.startTest();
        ReturnOrderTriggerHelper.createChildWorkOrder(mapOfRO);
        ReturnOrderTriggerHandler handler = new ReturnOrderTriggerHandler();
        handler.beforeInsert(new List<ReturnOrder>{returnOrder});
        handler.afterInsert(new List<ReturnOrder>{returnOrder}, null);
        handler.afterUpdate(new List<ReturnOrder>{returnOrder}, new Map<Id, SObject>{returnOrder.Id => returnOrder}, null, null);
        handler.beforeUpdate(new List<ReturnOrder>{returnOrder}, new Map<Id, SObject>{returnOrder.Id => returnOrder}, null, null);
        handler.beforeDelete(null, null);
        handler.afterDelete(null, null);
        handler.afterUnDelete(null, null);
        Test.stopTest();

        System.assert(!mapOfRO.isEmpty(), 'ReturnOrder records should exist.');
        List<WorkOrder> childWorkOrders = [SELECT Id, ParentWorkOrderId, WorkTypeId, Status, Invoice_Date__c, CaseId FROM WorkOrder WHERE ParentWorkOrderId = :parentWorkOrder.Id];

        System.assertEquals(1, childWorkOrders.size(), 'One child WorkOrder should be created.');
        WorkOrder childWO = childWorkOrders[0];
        System.assertEquals(parentWorkOrder.Id, childWO.ParentWorkOrderId, 'Child WorkOrder should have the correct ParentWorkOrderId.');
        System.assertEquals('Accepted', childWO.Status, 'Child WorkOrder should have the correct status.');
        System.assertEquals(returnOrder.Invoice_Date__c, childWO.Invoice_Date__c, 'Invoice_Date__c should match.');
        System.assertEquals(returnOrder.CaseId, childWO.CaseId, 'Child WorkOrder should have the correct CaseId.');

        WorkOrder updatedParentWorkOrder = [SELECT Id, Status FROM WorkOrder WHERE Id = :parentWorkOrder.Id LIMIT 1];
        
        TestDataFactory.enableTriggers();
    } 

}