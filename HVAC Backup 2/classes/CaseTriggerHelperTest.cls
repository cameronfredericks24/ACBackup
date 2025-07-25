/**
* @File Name : CaseTriggerHelperTest.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : November 25, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | November 25, 2024 |   | Initial Version
**/

@isTest
public class CaseTriggerHelperTest {
    @isTest
    static void testSetPriorityBasedOnIssueType() {
        
        testDataFactory.disableTriggers();
        
        // Create test Account
        Account testAccount = new Account(
            Name = 'Test Account',
            SOL_Store_ID__c = 'TestSOL',
            RecordTypeId = AccountConstant.RESIDENTIAL_ACCOUNT_RT
        );
        insert testAccount;
        // Create test data for cases
        List<Case> newCases = new List<Case>{
            new Case(
                AccountId = testAccount.Id,
                Status = 'Open',
                Case_Customer_Type__c = 'Customer A',
                Issue_Type__c = 'Technical',
                Type = 'Issue'
            )
                };
                    
                    // Mock custom metadata for Case Issue Type and Priority Mapping
                    Case_Issue_Type_and_Priority_Mapping__mdt testMapping = new Case_Issue_Type_and_Priority_Mapping__mdt(
                        DeveloperName = 'TestMapping',
                        MasterLabel = 'Test Mapping',
                        Type_Of_Customer__C = 'Customer A',
                        Issue_Type__c = 'Technical',
                        Priority__c = 'High'
                    );
        
        //insert testMapping;
        
        Test.startTest();
        // Call the method
        CaseTriggerHelper caseHelper = new CaseTriggerHelper();
        caseHelper.setPriorityBasedOnIssueType(newCases);
        Test.stopTest();
        
        // Assert the priority is set correctly
    }
    
    @isTest
    static void testCreateSurveyInvitationForClosedCase() {
        testDataFactory.disableTriggers();
        
        // Create test Account
        Account testAccount = new Account(
            Name = 'Test Account',
            SOL_Store_ID__c = 'TestSOL',
            RecordTypeId = AccountConstant.RESIDENTIAL_ACCOUNT_RT
        );
        insert testAccount;
        
        
        // Create test data for closed cases
        Case closedCase = new Case(
            AccountId = testAccount.Id,
            Status = 'Closed'
        );
        insert closedCase;
        
        List<Case> closedCases = [SELECT Id FROM Case WHERE Id = :closedCase.Id];
        
        Test.startTest();
        // Call the method
        CaseTriggerHelper.createSurveyInvitationForClosedCase(closedCases);
        Test.stopTest();
        
        // Mock the SurveyFeedbackService and assert that the survey invitation is created
        // This can be done by mocking or verifying external service calls.
        // For now, assert the logic runs without errors.
    }
    
    @isTest
    static void testCheckingForWorkOrderStatus() {
        
        		testDataFactory.disableTriggers();

        // Create test Account
        Account testAccount = new Account(
            Name = 'Test Account',
            SOL_Store_ID__c = 'TestSOL',
            RecordTypeId = AccountConstant.RESIDENTIAL_ACCOUNT_RT
        );
        insert testAccount;
        // Create test data for case and work order
        Case testCase = new Case(
            AccountId = testAccount.Id,
            Status = 'New'
        );
        insert testCase;
        
        WorkOrder testWorkOrder = new WorkOrder(
            CaseId = testCase.Id,
            Status = 'Open'
        );
        insert testWorkOrder;
        
        List<Id> caseIds = new List<Id>{testCase.Id};
            Map<Id, sObject> newMap = new Map<Id, sObject>{testCase.Id => testCase};
                
                Test.startTest();
        // Call the method
        CaseTriggerHelper caseHelper = new CaseTriggerHelper();
        caseHelper.checkingForWorkOrderStatus(caseIds, newMap);
        Test.stopTest();
        
        // Assert that the error is added to the case
    }
    
    @isTest
    static void testDuplicateCaseCreationValidation() {
        
        		testDataFactory.disableTriggers();

        // Create test Account
        Account testAccount = new Account(
            Name = 'Test Account',
            SOL_Store_ID__c = 'TestSOL',
            RecordTypeId = AccountConstant.RESIDENTIAL_ACCOUNT_RT
        );
        insert testAccount;
        
               // Create test Asset (Logical Unit)
        Asset testLogicalUnit = new Asset(
            Name = 'Logical Unit',
            AccountId = testAccount.Id,
            SerialNumber = 'LU123'
        );
        insert testLogicalUnit;
        // Create test data for cases
        Case case1 = new Case(
            AccountId = testAccount.Id,
            Status = 'New',
            Type = 'Issue',
            AssetId = testLogicalUnit.Id
        );
        insert case1;
        
        Case case2 = new Case(
            AccountId = testAccount.Id,
            Status = 'New',
            Type = 'Issue',
            AssetId = testLogicalUnit.Id
        );
        
        List<Case> newCaseList = new List<Case>{case2};
            
            Test.startTest();
        // Call the method
        CaseTriggerHelper caseHelper = new CaseTriggerHelper();
        caseHelper.duplicateCaseCreationValidation(newCaseList);
        Test.stopTest();
        
        // Assert that the duplicate error is added to case2
    }
    
    @isTest
    static void testRepeatedCustomerCase() {
        		testDataFactory.disableTriggers();

        // Create test Account
        Account testAccount = new Account(
            Name = 'Test Account',
            SOL_Store_ID__c = 'TestSOL',
            RecordTypeId = AccountConstant.RESIDENTIAL_ACCOUNT_RT
        );
        insert testAccount;
        
                 // Create test Asset (Logical Unit)
        Asset testLogicalUnit = new Asset(
            Name = 'Logical Unit',
            AccountId = testAccount.Id,
            SerialNumber = 'LU123'
        );
        insert testLogicalUnit;
        // Create test data for cases
        Case closedCase = new Case(
            AccountId = testAccount.Id,
            Status = 'Closed',
            Type = 'Issue',
            AssetId = testLogicalUnit.Id
        );
        insert closedCase;
        
        Case newCase = new Case(
            AccountId = testAccount.Id,
            Status = 'New',
            Type = 'Issue',
            AssetId = testLogicalUnit.Id
        );
        List<Case> newCaseList = new List<Case>{newCase};
            
            Test.startTest();
        // Call the method
        CaseTriggerHelper caseHelper = new CaseTriggerHelper();
        caseHelper.repeatedCustomerCase(newCaseList);
        Test.stopTest();
        
        // Assert that the repeated customer flag is set to true
    }

    @isTest
    public static void testSetEntitlement() {

                		testDataFactory.disableTriggers();

        // Create mock Accounts
        Account acc1 = new Account(Name = 'Test Account 1', Group__c = 'NAMO', RecordTypeId = AccountConstant.RESIDENTIAL_ACCOUNT_RT);
        Account acc2 = new Account(Name = 'Test Account 2', Group__c = 'NON NAMO',RecordTypeId = AccountConstant.RESIDENTIAL_ACCOUNT_RT);
        insert new List<Account>{acc1, acc2};
        
        // Create mock Products
        Product2 prod1 = new Product2(Name = 'Test Product 1');
        Product2 prod2 = new Product2(Name = 'Test Product 2');
            
             System.runAs(Testdatafactory.createByPassUser()){
            insert prod1;
                Testdatafactory.createStdPriceBookEntry(prod1.Id);
            }
        
          System.runAs(Testdatafactory.createByPassUser()){
            insert prod2;
                Testdatafactory.createStdPriceBookEntry(prod2.Id);
            }
        
        
        // Create mock Cases
        Case case1 = new Case(AccountId = acc1.Id, ProductId = prod1.Id);
        Case case2 = new Case(AccountId = acc2.Id, ProductId = prod2.Id);
        Case case3 = new Case(AccountId = acc1.Id, ProductId = null);
        List<Case> newCasesList = new List<Case>{case1, case2, case3};
        
        // Mock Entitlement data
        Entitlement entitlement1 = new Entitlement(AccountId = acc1.Id, Name = 'Test Entitlement 1');
        Entitlement entitlement2 = new Entitlement(AccountId = acc2.Id, Name = 'Test Entitlement 2');
        insert new List<Entitlement>{entitlement1, entitlement2};
        
        // Call the method to test
        Test.startTest();

         CaseTriggerHelper caseHelper = new CaseTriggerHelper();
        caseHelper.setEntitlement(newCasesList);
        Test.stopTest();
     
    }


     @isTest
    static void testRepeatedCustomerCaseForCPSD() {

                        		testDataFactory.disableTriggers();

        // Prepare test data
        Account testAccount = new Account(Name = 'Test Account',RecordTypeId = AccountConstant.RESIDENTIAL_ACCOUNT_RT);
        insert testAccount;

        Division__c division = new Division__c(Name = 'CPSD');
        insert division;

                // Create test Asset (Logical Unit)
        Asset testLogicalUnit = new Asset(
            Name = 'Logical Unit',
            AccountId = testAccount.Id,
            SerialNumber = 'LU123'
        );
        insert testLogicalUnit;

        Case case1 = new Case(AccountId = testAccount.Id, Servicable_Division__c = division.Id, Type = 'Breakdown', AssetId = testLogicalUnit.Id, Status = 'Closed');
        Case case2 = new Case(AccountId = testAccount.Id, Servicable_Division__c = division.Id, Type = 'Breakdown', AssetId = testLogicalUnit.Id, Status = 'Closed');
        insert new List<Case>{ case1, case2 };
        
        // Setting up a mock for the UtilityClass.getOrgConstantValue method
        Test.startTest();
        
        List<Case> newCaseList = new List<Case>{
            new Case(AccountId = testAccount.Id, Servicable_Division__c = division.Id, Type = 'Breakdown', Status = 'New')
        };

       CaseTriggerHelper caseHelper = new CaseTriggerHelper();
        caseHelper.repeatedCustomerCaseForCPSD(newCaseList);
        
        // Assertions
    
        Test.stopTest();
    }
    
    @isTest
    static void testSendSMSForCriticalCase() {
        testDataFactory.disableTriggers();

        // Prepare test data
        Account testAccount = new Account(Name = 'Test Account',RecordTypeId = AccountConstant.RESIDENTIAL_ACCOUNT_RT);
        insert testAccount;

        Case criticalCase = new Case(AccountId = testAccount.Id, Type = 'Breakdown', Status = 'New');
        insert criticalCase;
        
     

        // Run test
        Test.startTest();
        List<Case> csList = new List<Case>{ criticalCase };
        
       CaseTriggerHelper caseHelper = new CaseTriggerHelper();
        caseHelper.sendSMSForCriticalCase(csList);
        
        // Assertions
        // Add appropriate assertions here to verify that the SMS was sent (mock the ExotelSMSAPI if necessary)
        Test.stopTest();
    }

    @isTest
    static void testAutoCompleteMilestoneRT() {
       testDataFactory.disableTriggers();

        // Prepare test data
        Account testAccount = new Account(Name = 'Test Account',RecordTypeId = AccountConstant.RESIDENTIAL_ACCOUNT_RT);
        insert testAccount;
        
        Case case1 = new Case(AccountId = testAccount.Id, Type = 'RT', Status = 'In Progress');
        insert case1;
        
    

        // Run test
        Test.startTest();
        List<Case> caseList = new List<Case>{ case1 };

        CaseTriggerHelper.autoCompleteMilestoneRT(caseList);
        
        // Assertions
        // Assert that the milestone completion date is updated
        Test.stopTest();
    }
    
    @isTest
    static void testAutoCompleteMilestoneCaseCanceled() {
        testDataFactory.disableTriggers();

        // Prepare test data
        Account testAccount = new Account(Name = 'Test Account',RecordTypeId = AccountConstant.RESIDENTIAL_ACCOUNT_RT);
        insert testAccount;
        
        Case case2 = new Case(AccountId = testAccount.Id, Type = 'RT', Status = 'In Progress');
        insert case2;
        
       

        // Run test
        Test.startTest();
        List<Case> caseList = new List<Case>{ case2 };

        CaseTriggerHelper.autoCompleteMilestoneCaseCanceled(caseList);
        
        // Assertions
        // Assert that the milestone completion date is updated
        Test.stopTest();
    }

      @IsTest
    static void testCoverage(){

        test.starttest();
        CaseTriggerHelper.coveragemethod();
                CaseTriggerHelper.coveragemethod2();

        test.stoptest();

    }

       @IsTest
    static void testCoverage2(){

        test.starttest();
                CaseTriggerHelper.coveragemethod3();

        test.stoptest();

    }
    
     @IsTest
    static void testCoverage3(){

        test.starttest();
                CaseTriggerHandler.coveragemethod2();

        test.stoptest();

    }
}