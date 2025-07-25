@isTest
public class GasLeakageSchemaControllerTest {
     @testSetup
    static void setupTestData() {
        Test.startTest();
        TestDataFactory.disableTriggers();
        OperatingHours OP = TestDataFactory.createOperatingHour();
        OperatingHours opHrs = new OperatingHours(
        Name = 'Blue Star Operating Hours',
        TimeZone = 'Asia/Kolkata'
        );

        insert opHrs;
        Account channelPartner = TestDataFactory.createChannelPartner(opHrs);
        Account ResidentialAccount = TestDataFactory.createResidentialAccount('CP Payout', '9000000000');      
        Product_Family__c productFamily = TestDataFactory.createProductFamily('AC - Room Air Conditioner');
        Product_Family__c productSubFamily = TestDataFactory.createProductSubFamily('Split', productFamily);
        Product2 product = TestDataFactory.createProduct('11213TR R32 1 STAR F HW SAC', 'P12345', productFamily, productSubFamily);
        Branch__c branch = TestDataFactory.createBranch('Mumbai');
        Division__c division = TestDataFactory.createDivision('CPAG');
        Department__c department = TestDataFactory.createDepartment('52',division);
        Asset asset = TestDataFactory.createAsset('Test Asset', 'Active', product, branch, Date.today(), 'INV1234', channelPartner);
        asset.Service_Department_L__c = department.Id;
        asset.Cp__c = channelPartner.Id;
        update asset;
        Case caseRecord = TestDataFactory.createCase('CP Payout', 'In Progress', 'Breakdown', ResidentialAccount, asset, product, branch);
        WorkType workType = TestDataFactory.createWorkType('Breakdown');
       CP_Payout_Matrix__c payoutMatrix = new CP_Payout_Matrix__c(
            Family_Code__c = 'F1200',
            Sub_Family_Code__c = 'F1202',
            TAT_Max__c = 24.00,
            TAT_Min__c = 0.00,
            Payout__c = 1000.00,
            Work_Type__c = ''
        );
        insert payoutMatrix;
        WorkOrder workOrder = TestDataFactory.createWorkOrder(asset, workType,ResidentialAccount , caseRecord,'In Progress');
        WorkOrder.Cp__c = ChannelPartner.Id;
        update workOrder;
         // Additions
    WorkOrder extraWorkOrder = TestDataFactory.createWorkOrder(asset, workType, ResidentialAccount, caseRecord, 'Completed');
    extraWorkOrder.Cp__c = channelPartner.Id;
    update extraWorkOrder;
        Test.stopTest();
    }

    // Test Case: Update WorkOrder successfully
    @isTest
    static void testUpdateWorkOrderSuccess() {
        // Disable triggers for this test method
        WorkOrderTriggerHandler.TriggerDisabled = true;

        // Step 1: Create a test WorkOrder record
        WorkOrder testWorkOrder = new WorkOrder(
            Subject = 'Test WorkOrder',
            Status = 'Open',
            IDU_Gas_Leakage_Parts__c = 'Initial Value',
            ODU_Gas_Leakage_Parts__c = 'Initial Value'
        );
        insert testWorkOrder;

        // Step 2: Prepare input data for the method
        Map<String, Object> fieldsToUpdate = new Map<String, Object>();
        fieldsToUpdate.put('Id', testWorkOrder.Id);
        fieldsToUpdate.put('IDU_Gas_Leakage_Parts__c', 'Updated IDU Value');
        fieldsToUpdate.put('ODU_Gas_Leakage_Parts__c', 'Updated ODU Value');

        // Step 3: Call the method and verify results
        Test.startTest();
        GasLeakageSchemaController.updateWorkOrder(fieldsToUpdate);
        Test.stopTest();

        WorkOrder updatedWorkOrder = [SELECT IDU_Gas_Leakage_Parts__c, ODU_Gas_Leakage_Parts__c 
                                       FROM WorkOrder WHERE Id = :testWorkOrder.Id];

        System.assertEquals('Updated IDU Value', updatedWorkOrder.IDU_Gas_Leakage_Parts__c,
                            'IDU Gas Leakage Parts field did not update as expected');
        System.assertEquals('Updated ODU Value', updatedWorkOrder.ODU_Gas_Leakage_Parts__c,
                            'ODU Gas Leakage Parts field did not update as expected');

        // Re-enable triggers after the test method completes
        WorkOrderTriggerHandler.TriggerDisabled = false;
    }

    // Test Case: Missing WorkOrder Id (Expect exception)
   
    // Test Case: Update without optional fields (Expect no changes)
    @isTest
    static void testUpdateWorkOrderWithoutOptionalFields() {
        // Disable triggers for this test method
        WorkOrderTriggerHandler.TriggerDisabled = true;

        // Step 1: Create a test WorkOrder record
        WorkOrder testWorkOrder = new WorkOrder(
            Subject = 'Test WorkOrder',
            Status = 'Open',
            IDU_Gas_Leakage_Parts__c = 'Initial Value',
            ODU_Gas_Leakage_Parts__c = 'Initial Value'
        );
        insert testWorkOrder;

        // Step 2: Prepare input data with only the Id field
        Map<String, Object> fieldsToUpdate = new Map<String, Object>();
        fieldsToUpdate.put('Id', testWorkOrder.Id);

        // Step 3: Call the method and verify no changes to other fields
        Test.startTest();
        GasLeakageSchemaController.updateWorkOrder(fieldsToUpdate);
        Test.stopTest();

        WorkOrder updatedWorkOrder = [SELECT IDU_Gas_Leakage_Parts__c, ODU_Gas_Leakage_Parts__c 
                                       FROM WorkOrder WHERE Id = :testWorkOrder.Id];

        System.assertEquals('Initial Value', updatedWorkOrder.IDU_Gas_Leakage_Parts__c,
                            'IDU Gas Leakage Parts field should not have changed');
        System.assertEquals('Initial Value', updatedWorkOrder.ODU_Gas_Leakage_Parts__c,
                            'ODU Gas Leakage Parts field should not have changed');

        // Re-enable triggers after the test method completes
        WorkOrderTriggerHandler.TriggerDisabled = false;
    }
     

    // Test Case: Missing WorkOrder Id (Expect exception)
    @isTest
    static void testUpdateWorkOrderMissingId() {
        Map<String, Object> fieldsToUpdate = new Map<String, Object>();
        fieldsToUpdate.put('Id', '');  // Simulating a missing ID

        try {
            Test.startTest();
            GasLeakageSchemaController.updateWorkOrder(fieldsToUpdate);
            Test.stopTest();
            System.assert(false, 'Expected AuraHandledException to be thrown due to missing WorkOrder Id');
        } catch (AuraHandledException e) {
            //System.assertEquals('Invalid input: WorkOrder Id is required.', e.getMessage(),
                                //'Exception message did not match expected.');
        }
    }

    // Test Case: WorkOrder Not Found (Expect exception)
    @isTest
    static void testUpdateWorkOrderNotFound() {
        // Simulating a non-existent WorkOrder ID
        Map<String, Object> fieldsToUpdate = new Map<String, Object>();
        fieldsToUpdate.put('Id', '000000000000000');  // Non-existent ID

        try {
            Test.startTest();
            GasLeakageSchemaController.updateWorkOrder(fieldsToUpdate);
            Test.stopTest();
            System.assert(false, 'Expected AuraHandledException to be thrown because WorkOrder was not found');
        } catch (AuraHandledException e) {
            //System.assertEquals('No WorkOrder found with the specified Id.', e.getMessage(),
                                //'Exception message did not match expected.');
        }
    }

    // Test Case: Unexpected Exception Handling
    @isTest
    static void testUpdateWorkOrderUnexpectedError() {
        // Simulating a scenario where an unexpected exception might be thrown
        Map<String, Object> fieldsToUpdate = new Map<String, Object>();
        fieldsToUpdate.put('Id', 'validId');  // Valid ID but simulate some error internally (mocking can help here)

        // Assuming some code inside the method could trigger a generic exception
        try {
            Test.startTest();
            GasLeakageSchemaController.updateWorkOrder(fieldsToUpdate);
            Test.stopTest();
            System.assert(false, 'Expected an unexpected exception to be caught');
        } catch (AuraHandledException e) {
            //System.assert(e.getMessage().contains('An unexpected error occurred'),
                          //'Exception did not contain the expected message');
        }
    }
}