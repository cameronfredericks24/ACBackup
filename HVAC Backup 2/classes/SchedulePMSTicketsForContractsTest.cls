@isTest
public class SchedulePMSTicketsForContractsTest {
    @testSetup
    static void setupTestData() {
        // Disable triggers
        TestDataFactory.disableTriggers();

        // Retrieve Record Types
        Id productFamilyRecordTypeId = Schema.SObjectType.Product_Family__c.getRecordTypeInfosByDeveloperName().get('Product_Family').getRecordTypeId();
        Id productSubFamilyRecordTypeId = Schema.SObjectType.Product_Family__c.getRecordTypeInfosByDeveloperName().get('Product_Sub_Family').getRecordTypeId();
        Id commercialAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Commercial_Customer').getRecordTypeId();
        Id residentialAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Residential_Customer').getRecordTypeId();

        // Query or create Pricebook with name 'RPC'
        Pricebook2 standardPricebook;
        try {
            standardPricebook = [SELECT Id, Name FROM Pricebook2 WHERE Name = 'RPC' AND IsActive = TRUE LIMIT 1];
        } catch (System.QueryException e) {
            // Create Pricebook2 record if not found
            standardPricebook = new Pricebook2(
                Name = 'RPC',
                IsActive = TRUE
            );
            insert standardPricebook;
        }

        // Query Standard Pricebook
        //Pricebook2 standardPricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = TRUE LIMIT 1];

        // Create Product Family and Sub-Family
        Product_Family__c productFamily = new Product_Family__c(
            Name = 'Air Conditioners',
            Code__c = 'AC01',
            RecordTypeId = productFamilyRecordTypeId
        );
        insert productFamily;

        Product_Family__c productSubFamily = new Product_Family__c(
            Name = 'Split AC',
            Code__c = 'AC02',
            Parent_Product_Family__c = productFamily.Id,
            RecordTypeId = productSubFamilyRecordTypeId
        );
        insert productSubFamily;

        // Create Product
        Product2 product = new Product2(
            Name = 'Split AC',
            ProductCode = 'SKU12345',
            Product_Family__c = productFamily.Id,
            Product_Sub_Family__c = productSubFamily.Id,
            Status__c = 'Active'
        );
        
        System.runAs(Testdatafactory.createByPassUser()){
            insert product;
                Testdatafactory.createStdPriceBookEntry(product.Id);
            }

        // Create Standard Pricebook Entry
        PricebookEntry standardPricebookEntry = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = product.Id,
            UnitPrice = 100,
            IsActive = TRUE
        );
        insert standardPricebookEntry;

        // Create Residential Account
        Account testResidentialAccount = new Account(
            Name = 'Test Residential Account',
            Phone = '9089087678',
            BillingStreet = '123 Residential Street',
            BillingCity = 'Residential City',
            BillingState = 'Karnataka',
            BillingPostalCode = '560060',
            BillingCountry = 'India',
            RecordTypeId = residentialAccountRecordTypeId
        );
        insert testResidentialAccount;

        // Create Contact
        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            AccountId = testResidentialAccount.Id
        );
        insert testContact;

        // Create Asset
        Asset testAsset = new Asset(
            Name = 'Test Asset',
            Status = 'Active',
            Product2Id = product.Id,
            Product_Family__c = productFamily.Id,
            Product_Sub_Family__c = productSubFamily.Id,
            AccountId = testResidentialAccount.Id,
            Invoice_Date__c = Date.today(),
            Invoice_Number__c = 'INV12345'
            
        );
        insert testAsset;

        // Create Commercial Account
        Account testCommercialAccount = new Account(
            Name = 'Test Commercial Account',
            Phone = '9876543210',
            BillingStreet = '123 Commercial Street',
            BillingCity = 'Commercial City',
            BillingState = 'Karnataka',
            BillingPostalCode = '560060',
            BillingCountry = 'India',
            RecordTypeId = commercialAccountRecordTypeId
        );
        insert testCommercialAccount;

        // Create Service Contract
        ServiceContract testContract = new ServiceContract(
            Name = 'Test Service Contract',
            AccountId = testResidentialAccount.Id,
            Pricebook2Id = standardPricebook.Id // Assign Pricebook ID
        );
        insert testContract;

        // Create PMS Event
        PMS_Event__c pmsEvent = new PMS_Event__c(
            Start_Date__c = Date.today().addDays(5),
            PMS_Completion_SLA__c = Date.today().addDays(10),
            Service_Contract__c = testContract.Id,
            Asset__c = testAsset.Id,
            Contact__c = testContact.Id,
            Account__c = testResidentialAccount.Id,
            Subject__c = 'Test PMS Event',
            Status__c = 'Planned'
        );
        insert pmsEvent;

        // Enable triggers
        TestDataFactory.enableTriggers();
    }


    @isTest
    static void testCreatePMSTicketsManual() {
        TestDataFactory.disableTriggers();
        try {
            // Retrieve the test PMS Event
            PMS_Event__c pmsEvent = [SELECT Id FROM PMS_Event__c LIMIT 1];

            // Call the invocable method
            SchedulePMSTicketsForContracts.createPMSTicketsManual(new List<Id>{pmsEvent.Id});

          
        } finally {
            TestDataFactory.enableTriggers();
        }
    }
    

    @isTest
    static void testBatchExecution() {
        TestDataFactory.disableTriggers();
        try {
            // Retrieve the test PMS Event
            PMS_Event__c pmsEvent = [SELECT Id FROM PMS_Event__c LIMIT 1];

         

            // Validate batch execution results
            Test.startTest();
               // Run the batch
            SchedulePMSTicketsForContracts batchJob = new SchedulePMSTicketsForContracts(pmsEvent.Id);
            Id batchJobId = Database.executeBatch(batchJob);
            Test.stopTest();

          
        } finally {
            TestDataFactory.enableTriggers();
        }
    }

    @isTest
    static void testBatchWithSpecificEvent() {
        TestDataFactory.disableTriggers();
        try {
            // Retrieve the test PMS Event
            PMS_Event__c pmsEvent = [SELECT Id FROM PMS_Event__c LIMIT 1];

            // Execute batch for a specific PMS Event
            SchedulePMSTicketsForContracts batchJob = new SchedulePMSTicketsForContracts(pmsEvent.Id);
            Database.executeBatch(batchJob);

            // Validate the PMS Event status and created WorkOrder
        } finally {
            TestDataFactory.enableTriggers();
        }
    }
    @isTest
    static void testBatchWithidSet() {
        TestDataFactory.disableTriggers();
        try {
            // Retrieve the test PMS Event
            PMS_Event__c pmsEvent = [SELECT Id FROM PMS_Event__c LIMIT 1];
                Set<id> idSet = new set <id>{pmsEvent.id};

            // Execute batch for a specific PMS Event
            SchedulePMSTicketsForContracts batchJob = new SchedulePMSTicketsForContracts(idSet);
            Database.executeBatch(batchJob);

            // Validate the PMS Event status and created WorkOrder
        } finally {
            TestDataFactory.enableTriggers();
        }
    }
}