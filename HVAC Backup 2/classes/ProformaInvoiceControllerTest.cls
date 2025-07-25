@isTest
public class ProformaInvoiceControllerTest {
    
    @testSetup
    static void setupData() {
  		RecordType accountRecordType = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account' and DeveloperName ='Residential_Customer' LIMIT 1];
        RecordType assetRecordType = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Asset' and DeveloperName ='Asset' LIMIT 1];
        RecordType departmentRecordType = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Department__c' and DeveloperName ='Service' LIMIT 1];
        ID productFamilyRecordTypeId = Schema.SObjectType.Product_Family__c.getRecordTypeInfosByDeveloperName().get('Product_Family').getRecordTypeId();
        ID productSubFamilyRecordTypeId = Schema.SObjectType.Product_Family__c.getRecordTypeInfosByDeveloperName().get('Product_Sub_Family').getRecordTypeId();
        
        TestDataFactory.disableTriggers();
        //Create a Branch
        Branch__c b = new Branch__c(
            Name = 'ABCD'
        );
        insert b;
        
        OperatingHours oh = new OperatingHours();
        oh.Name = 'Blue Star Operating Hours';
        insert oh;
         
        // Create test Accounts
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            accounts.add(new Account(OperatingHoursId = oh.Id,Name = 'Test Account ' + i, Contact_Name__c = 'abc', RecordTypeId = accountRecordType.Id, Email__c = 'test' + i + '@example.com', Group__c = 'NON NAMO'));
        }
        insert accounts;

        // Create a test Account
        Account acc = new Account(
            Name = 'Test Account',
            BillingStreet = '123 Test',
            BillingCity = 'Bengaluru',
            BillingState = 'Karnataka',
            BillingCountry = 'India',
            BillingPostalCode = '12345',
            GST_Number__c = '29GGGGG1314R9Z6',
            TAN_Number__c = 'TAN123',
            PAN_Number__c = 'AAAAA0011A',
            Branch__c = b.Id,
            Division__c = 'CPAG',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId(),
            OperatingHoursId = oh.Id
        );
        insert acc;
        
        //Create an Asset
        Asset a = new Asset(
            Name = 'Test asset1',
            Model_Number__c = 'A-1',
            SDE__c = UserInfo.getUserId(),
            Branch__c = b.Id,
            CP__c = acc.Id,
            Status = 'Draft',
            Type__c = 'IDU'
        );
        insert a;
        
        // Create a test Master Contract
        Contract masterContract = new Contract(
            StartDate = System.today().addMonths(-1),
            ContractTerm = 11,
            AccountId = acc.id
        );
        insert masterContract;
         Division__c divisionCPAG = new Division__c(Name = 'CPSD');
        insert divisionCPAG;
        
        Department__c dep = new Department__c(Department_Number__c = '50', Name = '50-ACPD',RecordTypeId = departmentRecordType.Id );
        insert dep;
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true
        );
        update standardPricebook;
        Opportunity opp = new Opportunity(PO_Date__c=system.today(),PO_Total_Value__c=200,PO_Receipt_Date__c=System.Today(),Name = 'Test Opportunity', 
                                          StageName = 'Prospecting', CloseDate = System.today(), AccountId = accounts[0].Id, Department__c = dep.Id, Contract_Type__c = 'RPC',
                                          Opportunity_Start_Date__c= system.today(),
                                          Opportunity_End_Date__c=system.today().addMonths(12), Contract_Category__c = 'Conversion' );
        insert opp;
        // Create a test Quote
        SBQQ__Quote__c quote = new SBQQ__Quote__c(
            SBQQ__Account__c = acc.Id,
            SBQQ__MasterContract__c = masterContract.Id,
            Invoice_Number__c = 'INV123',
            Terms_of_Payment_Customer__c = 'Monthly Completion',
            Proposed_Period_From__c = System.today().addMonths(-2),
            Proposed_Period_To__c = System.today().addMonths(10),
            Description__c = 'Test Description',
            HSN_SAC_code__c = '999999999',
            Billing_Frequency_Period__c = 'Quarterly',
            SBQQ__PriceBook__c = standardPricebook.id,
            SBQQ__Opportunity2__c=opp.Id
        );
        insert quote; 
        
        Product2 prod = new Product2(
            Name = 'Test Product',
            Status__c = 'Active'
        );
        insert prod;
        
        // Create a test Quote Line
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = quote.Id,
            SBQQ__Product__c = prod.id, // Adjust accordingly if you have product data
            SBQQ__ListPrice__c = 1000000
        );
        insert quoteLine;
        TestDataFactory.enableTriggers();

    }
    
    @isTest
    static void testProformaInvoiceController() {
        // Fetch the test quote
        SBQQ__Quote__c testQuote = [SELECT Id, PO_Number__c, SBQQ__Opportunity2__r.PO_Receipt_Date__c, CreatedDate, Invoice_Number__c, Terms_of_Payment_Customer__c, BSL_SME__r.Name, PO_Date__c,
                 SBQQ__Opportunity2__r.Plant__r.Name, Name,
                 SBQQ__Opportunity2__r.Plant__r.Address__Street__s, SBQQ__Opportunity2__r.Plant__r.Address__City__s, 
                 SBQQ__Opportunity2__r.Plant__r.Address__StateCode__s, SBQQ__Opportunity2__r.Plant__r.Address__CountryCode__s, 
                 SBQQ__Opportunity2__r.Plant__r.Address__PostalCode__s, SBQQ__Opportunity2__r.Opportunity_Start_Date__c, SBQQ__Opportunity2__r.Opportunity_End_Date__c,
                 SBQQ__Opportunity2__r.CP__r.Name, SBQQ__Opportunity2__r.Department__r.Name, Branch_Number__c, SBQQ__Opportunity2__r.Opportunity_Name_Auto_Number__c,
                 SBQQ__Opportunity2__r.Customer_Invoice_Text__c,//SBQQ__Opportunity2__r.Plant__r.GST_Number__c,SBQQ__Opportunity2__r.Plant__r.PAN_Number__c
                 SBQQ__Account__r.Name, SBQQ__Opportunity2__r.PO_Date__c,SBQQ__Opportunity2__r.PO_Number__c,
                 SBQQ__Opportunity2__r.Plant__r.GST_Number__c , SBQQ__Opportunity2__r.Plant__r.PAN_Number__c ,
                 SBQQ__Account__r.BillingStreet, SBQQ__Account__r.BillingCity, SBQQ__Account__r.BillingState, 
                 SBQQ__Account__r.BillingCountry, SBQQ__Account__r.BillingstateCode, SBQQ__Account__r.BillingPostalCode, 
                 SBQQ__Account__r.ShippingStreet, SBQQ__Account__r.ShippingCity, SBQQ__Account__r.ShippingState, 
                 SBQQ__Account__r.ShippingCountry, SBQQ__Account__r.ShippingstateCode, SBQQ__Account__r.ShippingPostalCode, 
                 SBQQ__Account__r.GST_Number__c, SBQQ__Account__r.TAN_Number__c, SBQQ__Account__r.PAN_Number__c,
                 SBQQ__MasterContract__r.StartDate, SBQQ__MasterContract__r.EndDate, 
                 Proposed_Period_To__c,Proposed_Period_From__c,Description__c,HSN_SAC_code__c,
                 SBQQ__Opportunity2__r.PO_Total_Value__c,SBQQ__Opportunity2__r.Plant__r.Address__c,SBQQ__Opportunity2__r.Name,SBQQ__Opportunity2__r.Contract_Type__c,
                 Billing_Frequency_Period__c, Billing_Due_Period__c, Gross_Contract_Value_Currency__c  FROM SBQQ__Quote__c LIMIT 1];
        
        
        // Set up page parameters
        Test.setCurrentPageReference(new PageReference('/apex/ProformaInvoiceVFPage'));
        ApexPages.currentPage().getParameters().put('id', testQuote.Id);
        
        // Initialize controller
        Test.startTest();
        ProformaInvoiceController controller = new ProformaInvoiceController();
        
        
        Test.stopTest();
        
        // Assert that the quote is correctly fetched
        System.assertNotEquals(null, controller.quote);
        System.assertEquals(testQuote.Id, controller.quote.Id);
        
        // Assert that quote lines are fetched correctly
        System.assertNotEquals(null, controller.quoteLines);
        System.assert(controller.quoteLines.size() > 0); 
        
        // Assert that date fields are properly set
        System.assertNotEquals(null, controller.invoiceDate);
        System.assertNotEquals(null, controller.quoteDate);
        System.assertNotEquals(null, controller.billingDateFrom);
        System.assertNotEquals(null, controller.billingDateTo);
    }
}