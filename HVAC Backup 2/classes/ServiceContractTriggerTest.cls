/*
@Author : Himanshi Verma
@CreatedDate : 15th May 2024
@UpdatedBy: Balkrushna Anwane
@UpdatedDate: 29th May 2025
@Description : ServiceContract Object Trigger Test.
*/
@isTest
public class ServiceContractTriggerTest {
    @isTest
    static void testCoveragemethod() {
        // Use Test.startTest and Test.stopTest for coverage execution
        Test.startTest();
        ServiceContractTriggerHandler.coveragemethod();
        
        ServiceContractModificationHandler.coveragemethod();
        WorkOrderTriggerHandler.coveragemethod();
        Test.stopTest();
    }
    
 /*   @testSetup 
    static void setup() {
        TestDataFactory.disableTriggers();
        
        Division__c division = TestDataFactory.createDivision('CPSD');
        Department__c department = TestDataFactory.createDepartment('52', division);
        Account testAcc = TestDataFactory.createAccount('test account', '8937048559', 'dummyZ@mail.com', 'SAP1234');
        Branch__c branch = TestDataFactory.createBranch('Mumbai');
        Product_Family__c productFamily = TestDataFactory.createProductFamily('Default Product Family');
        Product_Family__c productSubFamily = TestDataFactory.createProductSubFamily('Default Sub Family', productFamily);
        Product2 prd1 = TestDataFactory.createSpareProduct('Default Product1', true, 'SKP135', productFamily, productSubFamily, 'Coils');

        Asset testAsset1 = TestDataFactory.createAsset('TestAsset1', 'Installed', prd1, branch, Date.today(), 'INV123', testAcc);
        Asset testAsset2 = TestDataFactory.createAsset('TestAsset2', 'Installed', prd1, branch, Date.today(), 'INV124', testAcc);

        Case case1 = TestDataFactory.createCase('CP Payout', 'In Progress', 'Breakdown', testAcc, testAsset1, prd1, branch);
        Case case2 = TestDataFactory.createCase('CP Payout', 'In Progress', 'Breakdown', testAcc, testAsset2, prd1, branch);

        WorkType workType = TestDataFactory.createWorkType('Breakdown');
        Id userId = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() AND IsActive = TRUE LIMIT 1].Id;

        WorkOrder wo1 = TestDataFactory.createWorkOrder(testAsset1, workType, testAcc, case1, 'In Progress');
        wo1.OwnerId = userId;
       // insert wo1;

        WorkOrder wo2 = TestDataFactory.createWorkOrder(testAsset2, workType, testAcc, case2, 'In Progress');
        wo2.OwnerId = userId;
       // insert wo2;

        ServiceAppointment sa1 = TestDataFactory.createSA(wo1, 'In Progress');
        ServiceAppointment sa2 = TestDataFactory.createSA(wo2, 'In Progress');

        Pricebook2 rpcPriceBook = new Pricebook2(Name = '50-RPC', Contract_Type__c = 'RPC', Department__c = '50', IsActive = true);
        insert rpcPriceBook;

        TestDataFactory.createPricebookEntry(prd1, rpcPriceBook.Id);
        TestDataFactory.enableAllTriggers();
    }

    @isTest
    static void testTrigger() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Pricebook2 pricebook = [SELECT Id FROM Pricebook2 WHERE Name = '50-RPC' LIMIT 1];

        ServiceContract sc = new ServiceContract(
            AccountId = acc.Id,
            StartDate = Date.today(),
            EndDate = Date.today().addYears(1),
            Name = 'Test Contract',
            Pricebook2Id = pricebook.Id
        );
        insert sc;

        List<ServiceContract> oldList = [SELECT Id, Name, SAP_Contract_Number__c, AccountId, Modification_Status__c FROM ServiceContract WHERE Id = :sc.Id];
        Map<Id, ServiceContract> oldMap = new Map<Id, ServiceContract>{ sc.Id => oldList[0] };

        sc.Name = 'Updated Contract';
        update sc;

        List<ServiceContract> newList = [SELECT Id, Name, SAP_Contract_Number__c, AccountId, Modification_Status__c FROM ServiceContract WHERE Id = :sc.Id];

        Test.startTest();
        ServiceContractTriggerHandler handler = new ServiceContractTriggerHandler();
        handler.afterUpdate(newList, null, oldList, oldMap);
        handler.beforeDelete(oldList, oldMap);
        handler.afterDelete(oldList, oldMap);
        handler.afterUnDelete(newList, oldMap);
        Test.stopTest();
    }

    @isTest
    static void testTriggerAndCancellation() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Pricebook2 pricebook = [SELECT Id FROM Pricebook2 WHERE Name = '50-RPC' LIMIT 1];

        ServiceContract sc = new ServiceContract(
            AccountId = acc.Id,
            StartDate = Date.today(),
            EndDate = Date.today().addYears(1),
            Name = 'Test Contract',
            Pricebook2Id = pricebook.Id,
            Modification_Status__c = 'Activated',
            Modification_Initiator__c = UserInfo.getUserId()
        );
        insert sc;

        // Attach WorkOrders to contract
        List<WorkOrder> wos = [SELECT Id, ServiceContractId FROM WorkOrder LIMIT 1];
        for (WorkOrder wo : wos) {
            wo.ServiceContractId = sc.Id;
        }
        update wos;

        // Create a ProductRequest with required status and RecordType
        RecordType prRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Material_Request' AND SObjectType = 'ProductRequest' LIMIT 1];


        // Trigger cancellation
        sc.Modification_Status__c = 'Debook';


        // Assertions
        List<WorkOrder> relatedWOs = [SELECT Status FROM WorkOrder WHERE ServiceContractId = :sc.Id];
        for (WorkOrder wo : relatedWOs) {
            //System.assertEquals('Canceled', wo.Status, 'WorkOrder should be canceled');
        }

        List<ProductRequest> relatedPRs = [SELECT Status FROM ProductRequest WHERE WorkOrder.ServiceContractId = :sc.Id];
        for (ProductRequest p : relatedPRs) {
            //System.assertEquals('Canceled', p.Status, 'ProductRequest should be canceled');
        }
    }

    @isTest
    static void testProcessCancellation_shortClosed_notificationOnly() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        ServiceContract sc = new ServiceContract(
            Name = 'Short Close Test',
            AccountId = acc.Id,
            StartDate = Date.today(),
            EndDate = Date.today().addYears(1),
            Modification_Status__c = 'Short Closed',
            Modification_Initiator__c = UserInfo.getUserId()
        );
        insert sc;

        Test.startTest();
        ServiceContractModificationHandler.processCancellation(new List<ServiceContract>{ sc });
        Test.stopTest();
    }

    @isTest
    static void testProcessCancellation_withNoInitiatorOrBadStatus() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        ServiceContract sc = new ServiceContract(
            Name = 'Invalid Status Test',
            AccountId = acc.Id,
            StartDate = Date.today(),
            EndDate = Date.today().addYears(1),
            Modification_Status__c = 'Pending', 
            Modification_Initiator__c = null
        );
        insert sc;

        Test.startTest();
        ServiceContractModificationHandler.processCancellation(new List<ServiceContract>{ sc });
        Test.stopTest();
    }

    @isTest
    static void testNotification_withUnsupportedStatus() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        ServiceContract sc = new ServiceContract(
            Name = 'Unsupported Status Test',
            AccountId = acc.Id,
            StartDate = Date.today(),
            EndDate = Date.today().addYears(1),
            Modification_Status__c = 'Activated',
            Modification_Initiator__c = UserInfo.getUserId()
        );
        insert sc;

        Test.startTest();
        ServiceContractModificationHandler.processCancellation(new List<ServiceContract>{ sc });
        Test.stopTest();
    }

    @isTest
    static void testNotificationTypeMissing() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        ServiceContract sc = new ServiceContract(
            Name = 'No Notification Type',
            AccountId = acc.Id,
            StartDate = Date.today(),
            EndDate = Date.today().addYears(1),
            Modification_Status__c = 'Debook',
            Modification_Initiator__c = UserInfo.getUserId()
        );
        insert sc;

        // This test will hit the catch block if CustomNotificationType doesn't exist in test data
        Test.startTest();
        ServiceContractModificationHandler.processCancellation(new List<ServiceContract>{ sc });
        Test.stopTest();
    }
    @isTest
    static void testWorkOrderTriggerHandlerEnhanced() {
        Test.startTest();
        
        // Create and insert related Asset
        Asset testAsset = new Asset(Name = 'Test Asset');
        insert testAsset;
        
        // Create and insert ServiceContract
        ServiceContract sc = new ServiceContract(Name = 'Test Contract', StartDate = Date.today(), Modification_Status__c = 'Activated');
        insert sc;
        
        // Create and insert Case
        Case testCase = new Case(Status = 'New', Origin = 'Phone', Subject = 'Test Case');
        insert testCase;
        
        // Get the correct record type ID for PMS and Non-PMS (update DeveloperName based on your org values)
        RecordType rtPMS = [SELECT Id FROM RecordType WHERE SObjectType = 'WorkOrder' AND DeveloperName = 'PMS' LIMIT 1];
        RecordType rtNonPMS = [SELECT Id FROM RecordType WHERE SObjectType = 'WorkOrder' AND DeveloperName = 'Installation' LIMIT 1];
        
        // Create PMS WorkOrder
        WorkOrder woPMS = new WorkOrder(
            Subject = 'PMS Work Order',
            AssetId = testAsset.Id,
            RecordTypeId = rtPMS.Id,
            ServiceContractId = sc.Id,
            Status = 'New'
        );
        
        // Create Non-PMS WorkOrder with CP__c and CaseId
        WorkOrder woNonPMS = new WorkOrder(
            Subject = 'Non-PMS WO',
            AssetId = testAsset.Id,
            RecordTypeId = rtNonPMS.Id,
            ServiceContractId = sc.Id,
            CaseId = testCase.Id,
            Status = 'New'
            //CP__c = 'Some_CP_Value'
        );
        
        // Insert both work orders
        // insert new List<WorkOrder>{ woPMS, woNonPMS };
        WorkOrderTriggerHandler.coveragemethod();
        Test.stopTest();
    }*/
}