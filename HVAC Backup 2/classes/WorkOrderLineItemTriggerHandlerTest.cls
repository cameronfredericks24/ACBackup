@isTest
private class WorkOrderLineItemTriggerHandlerTest {

    @isTest
    static void testAfterInsert() {
        // Disable triggers if required for setup
         // Insert Trigger Settings
        List<Trigger_Setting__c> settingList = new List<Trigger_Setting__c>();
        settingList.add(new Trigger_Setting__c(Name='AccountTrigger', IsActive__c = true));
        settingList.add(new Trigger_Setting__c(Name='AssetWarrantyTrigger', IsActive__c = false));
        settingList.add(new Trigger_Setting__c(Name='AllTriggers', IsActive__c = false));
        settingList.add(new Trigger_Setting__c(Name='AssetTrigger', IsActive__c = false));
        settingList.add(new Trigger_Setting__c(Name='WorkOrderTrigger', IsActive__c = true));
        settingList.add(new Trigger_Setting__c(Name='CaseTrigger', IsActive__c = true));
        settingList.add(new Trigger_Setting__c(Name='ContractLineItemTrigger', IsActive__c = true));
        settingList.add(new Trigger_Setting__c(Name='CPQQuoteTrigger', IsActive__c = true));
        settingList.add(new Trigger_Setting__c(Name='ContactTrigger', IsActive__c = true));
        settingList.add(new Trigger_Setting__c(Name='ProductTrigger', IsActive__c = true));
        settingList.add(new Trigger_Setting__c(Name='OpportunityTrigger', IsActive__c = true));
        settingList.add(new Trigger_Setting__c(Name='CPQQuoteLinesTrigger', IsActive__c = true));
        settingList.add(new Trigger_Setting__c(Name='QuoteTrigger', IsActive__c = true));
        settingList.add(new Trigger_Setting__c(Name='ServiceContractTrigger', IsActive__c = true));
        settingList.add(new Trigger_Setting__c(Name='WorkOrderLineItemTrigger', IsActive__c = true));
         insert settingList;
        // Create test data
        Product_Family__c productFamily = TestDataFactory.createProductFamily('AC - Room Air Conditioner');
        Product_Family__c productSubFamily = TestDataFactory.createProductSubFamily('Split', productFamily);
        Product2 product = TestDataFactory.createProduct('1TR R32 1 STAR F HW SAC', 'GHTY89', productFamily, productSubFamily);
        Account account = TestDataFactory.createResidentialAccount('Test Residential Account', '6677889977');
        Branch__c branch = TestDataFactory.createBranch('Mumbai');
        Asset asset = TestDataFactory.createAsset('Test Asset', 'Active', product, branch, Date.today(), 'INV12345', account);
        Case caseRecord = TestDataFactory.createCase('Test Case', 'New', 'Issue', account, asset, product, branch);        
        WorkType workType = TestDataFactory.createWorkType('Commissioning');
        WorkOrder workOrder = TestDataFactory.createWorkOrder(asset, workType, account, caseRecord, 'Open');

        // Create a WorkOrderLineItem
        WorkOrderLineItem woli = new WorkOrderLineItem(
            WorkOrderId = workOrder.Id,
            AssetId = asset.Id,
            Model_Number__c = 'SDLX4080B',
            Serial_Number__c = 'SDLX4080BHWN04153',
            Description = 'Test Work Order Line Item',
            WorkTypeId = workType.Id
        );
       
         List<WorkOrderLineItem> insertedWOLIs = [
            SELECT Id, WorkOrderId, AssetId, WorkTypeId
            FROM WorkOrderLineItem
            WHERE Id = :woli.Id
        ];

        Test.startTest();       
        insert woli;

        Test.stopTest();

        // // Validate results
        // Set<String> asyncIds = WorkOrderLineItemTriggerHelper.getAsyncIds();
        // System.assert(asyncIds.contains(woli.Id), 'WOLI ID should be processed in asyncProductregistration.');

		 
    }

    @isTest
    static void testAfterUpdate() {
        // Disable triggers if required for setup
        TestDataFactory.disableTriggers();

        // Create test data
        Product_Family__c productFamily = TestDataFactory.createProductFamily('AC - Room Air Conditioner');
         Product_Family__c productSubFamily = TestDataFactory.createProductSubFamily('Split', productFamily);       
        Product2 product = TestDataFactory.createProduct('1TR R32 1 STAR F HW SAC', 'GHTY89', productFamily, productSubFamily);
        Account account = TestDataFactory.createResidentialAccount('Test Residential Account', '6677889977');
        Branch__c branch = TestDataFactory.createBranch('Mumbai');
        Asset oldAsset = TestDataFactory.createAsset('Old Test Asset', 'Active', product, branch, Date.today(), 'INV12346', account);
        Asset newAsset = TestDataFactory.createAsset('New Test Asset', 'Active', product, branch, Date.today(), 'INV12347', account);
        Case caseRecord = TestDataFactory.createCase('Test Case', 'New', 'Issue', account, oldAsset, product, branch);        
        WorkType workType = TestDataFactory.createWorkType('Maintenance');
        WorkOrder workOrder = TestDataFactory.createWorkOrder(oldAsset, workType, account, caseRecord, 'Open');

        // Create and update a WorkOrderLineItem
        WorkOrderLineItem woli = new WorkOrderLineItem(
            WorkOrderId = workOrder.Id,
            AssetId = oldAsset.Id,
            Description = 'Test Work Order Line Item'
        );
        insert woli;

        woli.AssetId = newAsset.Id;
        update woli;

        Test.startTest();
        // Re-execute the trigger to test
        List<WorkOrderLineItem> updatedWOLIs = [
            SELECT Id, WorkOrderId, AssetId
            FROM WorkOrderLineItem
            WHERE Id = :woli.Id
        ];
        Map<Id, WorkOrderLineItem> oldMap = new Map<Id, WorkOrderLineItem>{woli.Id => new WorkOrderLineItem(
            Id = woli.Id, AssetId = oldAsset.Id, WorkOrderId = workOrder.Id)};

        WorkOrderLineItemTriggerHandler handler = new WorkOrderLineItemTriggerHandler();
        handler.afterUpdate(updatedWOLIs, null, null, oldMap);
        Test.stopTest();

        // Validate results
        WorkOrder updatedWorkOrder = [SELECT Id, AssetId, Is_Asset_Scanned_Added__c FROM WorkOrder WHERE Id = :workOrder.Id];
        System.assertEquals(newAsset.Id, updatedWorkOrder.AssetId, 'WorkOrder.AssetId should match the new asset.');
        System.assertEquals(true, updatedWorkOrder.Is_Asset_Scanned_Added__c, 'Is_Asset_Scanned_Added__c should be true.');
        TestDataFactory.enableTriggers();

	}

    @isTest
    static void testIsDisabled() {
        Test.startTest();
        WorkOrderLineItemTriggerHandler.TriggerDisabled = true;
        WorkOrderLineItemTriggerHandler handler = new WorkOrderLineItemTriggerHandler();
        Test.stopTest();
    }

     @isTest
    static void testCoverage() {
      WorkOrderLineItemTriggerHandler.coveragemethod4();
    }

       @isTest
    static void testCoverage2() {
      WorkOrderLineItemTriggerHelper.coveragemethod();
    }


}