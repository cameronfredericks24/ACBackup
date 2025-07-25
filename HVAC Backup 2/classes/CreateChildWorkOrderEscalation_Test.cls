@isTest
public class CreateChildWorkOrderEscalation_Test {
    
    @isTest
    static void testWorkOrderCreation() {
        // Disable triggers before test
        TestDataFactory.disableTriggers();

        // Create necessary test data
        Product_Family__c productFamily = TestDataFactory.createProductFamily('AC - Room Air Conditioner');
        Product_Family__c productSubFamily = TestDataFactory.createProductSubFamily('Split AC', productFamily);
        Product2 product = TestDataFactory.createProduct('Blue Star AC', 'BSAC123', productFamily, productSubFamily);
        Branch__c branch = TestDataFactory.createBranch('Mumbai Branch');
        Account account = TestDataFactory.createResidentialAccount('Test Account', '9876543210');
        Asset asset = TestDataFactory.createAsset('AC Unit', 'Active', product, branch, Date.today(), 'INV123456', account);
        Case caseRecord = TestDataFactory.createCase('Test Case', 'Open', 'Repair', account, asset, product, branch);
        WorkType workType = TestDataFactory.createWorkType('Repair Work Type');
        WorkOrder parentWorkOrder = TestDataFactory.createWorkOrder(asset, workType, account, caseRecord, 'New');

        // Call the method you want to test (example: CreateChildWorkOrderEscalation)
        List<CreateChildWorkOrderEscalation.WorkOrderDetails> workOrderDetails = new List<CreateChildWorkOrderEscalation.WorkOrderDetails>();
        CreateChildWorkOrderEscalation.WorkOrderDetails detail = new CreateChildWorkOrderEscalation.WorkOrderDetails();
        detail.recordId = parentWorkOrder.Id;
        workOrderDetails.add(detail);

        Test.startTest();
        CreateChildWorkOrderEscalation.CreateChildWorkOrder(workOrderDetails);
        Test.stopTest();

        // Validate the results
        List<WorkOrder> childWorkOrders = [SELECT Id, ParentWorkOrderId, Subject FROM WorkOrder WHERE ParentWorkOrderId = :parentWorkOrder.Id];
        System.assertEquals(1, childWorkOrders.size(), 'Child Work Order should have been created.');
        System.assertEquals(parentWorkOrder.Id, childWorkOrders[0].ParentWorkOrderId, 'ParentWorkOrderId should match.');
        
        // Enable triggers after test
        TestDataFactory.enableTriggers();
    }
}