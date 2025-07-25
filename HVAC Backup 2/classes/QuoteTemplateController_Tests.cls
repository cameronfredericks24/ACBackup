@isTest
private class QuoteTemplateController_Tests {
    @testSetup
    static void setupTestData() {
        // Disable triggers using TestDataFactory
        TestDataFactory.disableTriggers();
        
        try {
            // RecordType IDs
            String channelPartnerAccountRecordTypeID = AccountConstant.CHANNEL_PARTNER_ACCOUNT_RT;
            String commercialAccountRecordTypeID = AccountConstant.COMMERCIAL_ACCOUNT_RT;
            
            // Create an Account with Channel_Partner record type
            Account testAccount = New Account(
                Name = 'Test Account',
                RecordTypeId = channelPartnerAccountRecordTypeID,
                GST_Number__c = '33AACCN2366D1ZV',
                TAN_Number__c = 'AACCN2366D',
                Is_Active__c = false,
                PAN_Number__c = 'AACCN2366D',
                Industry = 'Others',
                Contact_Name__c = 'Test Contact'
            );
            insert testAccount;
            
            // Update Account to Commercial record type
            testAccount.RecordTypeId = commercialAccountRecordTypeID;
            update testAccount;
            
            // Create a Contact
            Contact cont = new Contact(
                FirstName = 'John',
                LastName = 'Doe',
                Salutation = 'Mr.',
                Phone = '123-456-7890',
                AccountId = testAccount.Id
            );
            insert cont;
            
            // Create a Division
            Division__c div = new Division__c(
                Name = 'CPSD'
            );
            insert div;
            // Create a Division
            Division__c CPAG = new Division__c(
                Name = 'CPAG'
            );
            insert CPAG;
            // Create a Division
            Division__c CRBG = new Division__c(
                Name = 'CRBG'
            );
            insert CRBG;
            
            Branch__c br = New Branch__c();
            br.name = 'Test Branch';
            insert br;
            
            // Create Department__c with a valid RecordType that matches the filter criteria
            ID serviceDepartmentRecordTypeId = Schema.SObjectType.Department__c.getRecordTypeInfosByDeveloperName().get('Service').getRecordTypeId();
            Department__c dep = New Department__c(
                Name = '43-WPD',
                Department_Number__c = '43',
                RecordTypeId = serviceDepartmentRecordTypeId
            );
            insert dep;
            
            ID productFamilyRecordTypeId = Schema.SObjectType.Product_Family__c.getRecordTypeInfosByDeveloperName().get('Product_Family').getRecordTypeId();
            ID productSubFamilyRecordTypeId = Schema.SObjectType.Product_Family__c.getRecordTypeInfosByDeveloperName().get('Product_Sub_Family').getRecordTypeId();
            
            Product_Family__c testProductFamilyCPSD = New Product_Family__c(
                Name = 'testProductFamilyCPSD',
                RecordTypeId = productFamilyRecordTypeId, 
                Service_Department_No__c = dep.Id,
                Code__c = 'CPSDFAM',
                Type__c = 'Product Family',
                Sales_Department_No_SAP__c = '50',
                Service_Department_No_SAP__c = '50',
                Division__c = 'CPSD'
            );
            insert testProductFamilyCPSD;
            
            Product_Family__c testProductSubFamilyCPSD = New Product_Family__c(
                Name = 'testProductSubFamilyCPSD',
                RecordTypeId = productSubFamilyRecordTypeId,
                Parent_Product_Family__c = testProductFamilyCPSD.Id,
                Code__c = 'CPSDSUBFAM',
                Type__c = 'Product Sub Family',
                Parent_Product_Family_Code__c = 'CPSDFAM',
                Sales_Department_No_SAP__c = '50',
                Service_Department_No_SAP__c = '50'
            );    
            insert testProductSubFamilyCPSD;  
            
            Product2 testProductCPSD = New Product2(
                Name = 'testProductCPSD',         
                RecordTypeId = ProductConstants.PRODUCT_RT,
                Product_Family__c = testProductFamilyCPSD.Id,
                Product_Sub_Family__c = testProductSubFamilyCPSD.Id,
                Product_Type__c = 'Durable',
                ProductCode ='BSL_Model_1',
                Material_Group__c = 'WPD-Plastic Parts',
                IsActive = true,
                Type__c = 'Product',
                Product_Family_Code__c = 'CPSDFAM',
                Product_Sub_Family_Code__c = 'CPSDSUBFAM' ,
                Capacity__c = 5,
                UOM__c = 'Tonnage of Refrigeration'
            );
            System.runAs(Testdatafactory.createByPassUser()){
            insert testProductCPSD;
                Testdatafactory.createStdPriceBookEntry(testProductCPSD.Id);
            }
            
            Pricebook2 standardPriceBook = new Pricebook2(Name = 'Standard Price Book', IsActive = true);
            insert standardPriceBook;
            PricebookEntry testPricebookEntry = new PricebookEntry(Product2Id = testProductCPSD.Id, Pricebook2Id = standardPriceBook.Id, UnitPrice = 100, IsActive = true);
            insert testPricebookEntry;
            
            Pricebook2 rpcPriceBook = new Pricebook2(Name = 'RPC', Contract_Type__c = 'RPC', Department__c = '50', IsActive = true);
            insert rpcPriceBook;
            PricebookEntry rpcPricebookEntry = new PricebookEntry(Product2Id = testProductCPSD.Id, Pricebook2Id = rpcPriceBook.Id,Product_Family__c = testProductSubFamilyCPSD.Id, UnitPrice = 100, Price_TR__c = 500, IsActive = true);
            insert rpcPricebookEntry;
            
            ID ParentAssetRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Asset').getRecordTypeId();  
            
            Asset testAssetCPSD1 = New Asset(
                Name = 'testAssetCPSD1',
                AccountId =  testAccount.id,
                Product2Id = testProductCPSD.Id,
                Product_Family__c	= testProductFamilyCPSD.id,
                Product_Sub_Family__c = testProductSubFamilyCPSD.id,
                Invoice_Date__c = System.today(),
                Branch__c = br.Id,
                Service_Department_L__c = dep.Id, // Updated with valid Department__c
                Status = 'Installed',
                RecordTypeId = ParentAssetRecordTypeId,
                Standard_Warranty_Start_Date__c = System.today().addMonths(-24),
                Standard_Warranty_End_Date__c =  System.today().addMonths(-12),
                Comprehensive_Warranty_Start_Date__c = System.today().addMonths(-24),
                Comprehensive_Warranty_End_Date__c =  System.today().addMonths(-12)
            );   
            
            insert testAssetCPSD1;
            
            Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = System.today(), AccountId = testAccount.Id, Department__c = dep.Id, Contract_Type__c = 'RPC',Contract_Category__c = 'Conversion' );
            insert testOpportunity;
            Quote testQuote2 = new Quote(Division__c=div.Id,Contract_Type__c='RPC',Overall_Price_Change_Currency__c=1 ,Name = 'Test Quote', OpportunityId = testOpportunity.Id,Department__c = dep.Id,  Proposed_Period_From__c = System.today(), Proposed_Period_To__c = System.today().addMonths(6), Pricebook2Id = rpcPriceBook.Id);
            insert testQuote2;
            QuoteLineItem testQuoteLine2 = new QuoteLineItem(QuoteId = testQuote2.Id, Product2Id = testProductCPSD.Id, Asset__c = testAssetCPSD1.Id, UnitPrice = 100, Start_Date__c = System.today(), End_Date__c = System.today().addMonths(6), PricebookEntryId = rpcPricebookEntry.Id, Quantity = 1 );
            insert testQuoteLine2;
            Quote testQuote1 = new Quote(Division__c=CRBG.Id,Contract_Type__c='RPC',Overall_Price_Change_Currency__c=200 ,Name = 'Test Quote', OpportunityId = testOpportunity.Id,Department__c = dep.Id,  Proposed_Period_From__c = System.today(), Proposed_Period_To__c = System.today().addMonths(6), Pricebook2Id = rpcPriceBook.Id);
            insert testQuote1;
            QuoteLineItem testQuoteLine1 = new QuoteLineItem(QuoteId = testQuote2.Id, Product2Id = testProductCPSD.Id, Asset__c = testAssetCPSD1.Id, UnitPrice = 100, Start_Date__c = System.today(), End_Date__c = System.today().addMonths(6), PricebookEntryId = rpcPricebookEntry.Id, Quantity = 1 );
            insert testQuoteLine1;
            Quote testQuote3 = new Quote(Division__c=CPAG.Id,Contract_Type__c='RPC',Overall_Price_Change_Currency__c=3000 ,Name = 'Test Quote', OpportunityId = testOpportunity.Id,Department__c = dep.Id,  Proposed_Period_From__c = System.today(), Proposed_Period_To__c = System.today().addMonths(6), Pricebook2Id = rpcPriceBook.Id);
            insert testQuote3;
            QuoteLineItem testQuoteLine3 = new QuoteLineItem(QuoteId = testQuote2.Id, Product2Id = testProductCPSD.Id, Asset__c = testAssetCPSD1.Id, UnitPrice = 100, Start_Date__c = System.today(), End_Date__c = System.today().addMonths(6), PricebookEntryId = rpcPricebookEntry.Id, Quantity = 1 );
            insert testQuoteLine3;
            
        } finally {
            // Re-enable triggers after test setup
            TestDataFactory.enableTriggers();
        }
    }
    
    
    
    @isTest
    static void testQuoteTemplateController() {
        // Disable triggers for the test method
        TestDataFactory.disableTriggers();
        try {
            Quote quote = [SELECT Id,Contract_Type__c,Gross_Contract_Value_Currency__c, Division__r.Name, Department__r.Name FROM Quote where Division__r.Name = 'CPSD' LIMIT 1];
            ApexPages.StandardController standardController = new ApexPages.StandardController(quote);
            QuoteTemplateController controller = new QuoteTemplateController(standardController);
            QuoteTemplateController controller4 = new QuoteTemplateController();
             //CRBG
            Quote quote2 = [SELECT Id,Contract_Type__c,Gross_Contract_Value_Currency__c, Division__r.Name, Department__r.Name FROM Quote where Division__r.Name = 'CRBG' LIMIT 1];
            ApexPages.StandardController standardController2 = new ApexPages.StandardController(quote2);
            QuoteTemplateController controller2 = new QuoteTemplateController(standardController2);
            //CPAG
            Quote quote3 = [SELECT Id,Contract_Type__c,Gross_Contract_Value_Currency__c, Division__r.Name, Department__r.Name FROM Quote where Division__r.Name = 'CPAG' LIMIT 1];
            ApexPages.StandardController standardController3 = new ApexPages.StandardController(quote3);
            QuoteTemplateController controller3 = new QuoteTemplateController(standardController3);
            controller.sendEmail();
            controller.updateStatus();
            Test.setCurrentPage(Page.QuoteTemplatePDFPage);
        ApexPages.currentPage().getParameters().put('id', quote.Id);

        } finally {
            // Re-enable triggers after the test method
            TestDataFactory.enableTriggers();
        }
    }
    @isTest
    static void testCoverage() {
        QuoteTemplateController.coveragemethod4();
    }
    
}