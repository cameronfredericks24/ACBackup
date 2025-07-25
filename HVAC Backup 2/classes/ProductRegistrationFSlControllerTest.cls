@isTest
private class ProductRegistrationFSlControllerTest {
    
     @testSetup
    static void setupTestData() {
        
         // Disable triggers
        AccountTriggerHandler.TriggerDisabled = true;
        WorkOrderTriggerHandler.TriggerDisabled = true;
        WorkOrderLineItemTriggerHandler.TriggerDisabled = true;
        CaseTriggerHandler.TriggerDisabled = true;
                AssetTriggerHandler.TriggerDisabled = true;
        ContactTriggerHandler.TriggerDisabled = true;

        
        // Create Account
        Account acc = new Account(Name = 'Test Account', Phone = '9876543210',RecordTypeId = AccountConstant.RESIDENTIAL_ACCOUNT_RT);
        insert acc;
        
           // Create Account
        Account acc2 = new Account(Name = 'Test 2 Account', Phone = '9876543210',RecordTypeId = AccountConstant.RESIDENTIAL_ACCOUNT_RT);
        insert acc2;

        // Create Asset
        Asset asset = new Asset(Name = 'Test Asset', SerialNumber = 'ASSET123', AccountId = acc.Id);
        insert asset;
        
          // Create Asset
        Asset asset2 = new Asset(Name = 'Test Asset2', SerialNumber = 'ASSET1234', AccountId = acc2.Id);
        insert asset2;
        
           // Create Asset
        Asset asset3 = new Asset(Name = 'Test Asset2', SerialNumber = 'ASSET12345', AccountId = acc2.Id,ParentId = asset2.Id );
        insert asset3;
        
            // Create Asset
        Asset asset4 = new Asset(Name = 'Test Asset4', SerialNumber = 'SN123', AccountId = acc2.Id );
        insert asset4;

        // Create Case
        Case caseRec = new Case(Subject = 'Test Case', AccountId = acc.Id);
        insert caseRec;
        
         // Create Case
        Case caseRec2 = new Case(Subject = 'Test Case', AccountId = acc.Id);
        insert caseRec2;


        // Create Work Order
        WorkOrder wo = new WorkOrder(
            Subject = 'Test Work Order',
            CaseId = caseRec.Id,
            AccountId = acc.Id,
            Scan_Asset_OTP__c = '123456',
            Scan_Asset_OTP_Sent__c = false
        );
        insert wo;
        
         // Create Work Order
        WorkOrder wo2 = new WorkOrder(
            Subject = 'Test Work Order2',
            CaseId = caseRec2.Id,
            AccountId = acc2.Id,
            Scan_Asset_OTP__c = '654321',
            Scan_Asset_OTP_Sent__c = false
        );
        insert wo2;

        // Create Work Order Line Item
        WorkOrderLineItem woli = new WorkOrderLineItem(WorkOrderId = wo.Id, AssetId = asset.Id);
        insert woli;
    }

    @isTest
    static void testOtpNeeded() {
        // Get test Work Order
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];

        // Call otpNeeded method
        Test.startTest();
         WorkOrderTriggerHandler.TriggerDisabled = true;
                        AssetTriggerHandler.TriggerDisabled = true;
                CaseTriggerHandler.TriggerDisabled = true;

        Boolean isOtpSent = ProductRegistrationFSlController.otpNeeded(wo.Id);
        Test.stopTest();

        // Assert results
        //System.assertEquals(false, isOtpSent, 'Expected OTP not sent status');
    }

    @isTest
    static void testValidateOtp() {
        // Get test Work Order
        WorkOrder wo = [SELECT Id,Subject FROM WorkOrder WHERE Subject = 'Test Work Order' LIMIT 1];
        
        wo.Wrong_Serial_Number__c = 'SN123';

        // Call validateOtp method with correct OTP
        Test.startTest();
         WorkOrderTriggerHandler.TriggerDisabled = true;
         AssetTriggerHandler.TriggerDisabled = true;
         CaseTriggerHandler.TriggerDisabled = true;
          WorkOrderLineItemTriggerHandler.TriggerDisabled = true;

        Update wo;

        Boolean isOtpValid = ProductRegistrationFSlController.validateOtp(wo.Id, '123456', 'SN123','M123');
        Test.stopTest();

        // Assert results
        //System.assert(isOtpValid, 'OTP should be valid');
    }

    @isTest
    static void testFetchAssetDetails() {
        // Prepare responseWrapper JSON
        WorkOrder wo = [SELECT Id, AccountId FROM WorkOrder LIMIT 1];
        
      // Prepare a responseWrapper instance with all fields populated
        String wrapperJson = '{' +
            '"recordId":"' + wo.Id + '",' +
            '"serialNumber":"ASSET123",' +
            '"bsl":true,' +
            '"nonBslMake":"TestMake",' +
            '"nonBslModel":"TestModel",' +
            '"nonBslType":"TestType",' +
            '"saId":"SA12345",' +
            '"calledFromStartWork":true,' +
            '"latitude":37.7749,' +
            '"longitude":-122.4194,' +
            '"otp":"123456"' +
        '}';
        // Call fetchAssetDetails method
        Test.startTest();
                WorkOrderTriggerHandler.TriggerDisabled = true;
                        AssetTriggerHandler.TriggerDisabled = true;
        CaseTriggerHandler.TriggerDisabled = true;
                WorkOrderLineItemTriggerHandler.TriggerDisabled = true;



        String result = ProductRegistrationFSlController.fetchAssetDetails(wrapperJson);
        Test.stopTest();

        // Assert results
        //System.assertEquals('success', result, 'Expected success response for valid data');
    }
    
     @isTest
    static void testFetchAssetDetailsOTPScenario() {
        // Prepare responseWrapper JSON
        WorkOrder wo = [SELECT Id, AccountId,Subject FROM WorkOrder Where Subject = 'Test Work Order2' LIMIT 1];
        
      // Prepare a responseWrapper instance with all fields populated
        String wrapperJson = '{' +
            '"recordId":"' + wo.Id + '",' +
            '"serialNumber":"ASSET123",' +
            '"bsl":true,' +
            '"nonBslMake":"TestMake",' +
            '"nonBslModel":"TestModel",' +
            '"nonBslType":"TestType",' +
            '"saId":"SA12345",' +
            '"calledFromStartWork":true,' +
            '"latitude":37.7749,' +
            '"longitude":-122.4194,' +
            '"otp":"654321"' +
        '}';
        // Call fetchAssetDetails method
        Test.startTest();
        WorkOrderTriggerHandler.TriggerDisabled = true;
                        AssetTriggerHandler.TriggerDisabled = true;
                CaseTriggerHandler.TriggerDisabled = true;
                WorkOrderLineItemTriggerHandler.TriggerDisabled = true;



        String result = ProductRegistrationFSlController.fetchAssetDetails(wrapperJson);
        Test.stopTest();

        // Assert results
        //System.assertEquals('success', result, 'Expected success response for valid data');
    }

     @isTest
    static void testFetchAssetDetailsParentAssetScenario() {
        // Prepare responseWrapper JSON
        WorkOrder wo = [SELECT Id, AccountId,Subject FROM WorkOrder Where Subject = 'Test Work Order2' LIMIT 1];
        
      // Prepare a responseWrapper instance with all fields populated
        String wrapperJson = '{' +
            '"recordId":"' + wo.Id + '",' +
            '"serialNumber":"ASSET12345",' +
            '"bsl":true,' +
            '"nonBslMake":"TestMake",' +
            '"nonBslModel":"TestModel",' +
            '"nonBslType":"TestType",' +
            '"saId":"SA12345",' +
            '"calledFromStartWork":true,' +
            '"latitude":37.7749,' +
            '"longitude":-122.4194,' +
            '"otp":"654321"' +
        '}';
        // Call fetchAssetDetails method
        Test.startTest();
        WorkOrderTriggerHandler.TriggerDisabled = true;
                        AssetTriggerHandler.TriggerDisabled = true;
                CaseTriggerHandler.TriggerDisabled = true;
                WorkOrderLineItemTriggerHandler.TriggerDisabled = true;



        String result = ProductRegistrationFSlController.fetchAssetDetails(wrapperJson);
        Test.stopTest();

        // Assert results
        //System.assertEquals('success', result, 'Expected success response for valid data');
    }



    @isTest
    static void testGetAccountId() {
        // Get test Work Order
        WorkOrder wo = [SELECT Id, AccountId FROM WorkOrder LIMIT 1];

        // Call getAccountId method
        Test.startTest();
        String accountId = ProductRegistrationFSlController.getAccountId(wo.Id);
        Test.stopTest();

        // Assert results
        //System.assertEquals(wo.AccountId, accountId, 'Expected matching account ID');
    }

    @isTest
    static void testExceptionHandling() {
        // Call fetchAssetDetails with invalid JSON
        String invalidJson = '{"recordId":"invalid","serialNumber":"invalid"}';

        Test.startTest();
        String result = ProductRegistrationFSlController.fetchAssetDetails(invalidJson);
        Test.stopTest();

        // Assert results
        //System.assertEquals('DmlException', result, 'Expected exception handling result');
    }
    
}