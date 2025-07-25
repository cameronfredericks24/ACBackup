@isTest
public class PMSInsertQueueableTest {
 
    @testSetup 
    static void setup() { 
        RecordType accountRecordType = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account' and DeveloperName ='Residential_Customer' LIMIT 1];
        RecordType assetRecordType = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Asset' and DeveloperName ='Asset' LIMIT 1];
        RecordType departmentRecordType = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Department__c' and DeveloperName ='Service' LIMIT 1];
        ID productFamilyRecordTypeId = Schema.SObjectType.Product_Family__c.getRecordTypeInfosByDeveloperName().get('Product_Family').getRecordTypeId();
        ID productSubFamilyRecordTypeId = Schema.SObjectType.Product_Family__c.getRecordTypeInfosByDeveloperName().get('Product_Sub_Family').getRecordTypeId();
        
        // Insert Trigger Settings
        List<Trigger_Setting__c> settingList = new List<Trigger_Setting__c>();
        settingList.add(new Trigger_Setting__c(Name='AccountTrigger', IsActive__c = false));
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
        insert settingList;
        
        // Insert other required setup data
        Branch__c testBranch = new Branch__c(Name= 'Test Branch');
        insert testBranch;
        
        Division__c divisionCPAG = new Division__c(Name = 'CPSD');
        insert divisionCPAG;
        
        Department__c dep = new Department__c(Department_Number__c = '58', Name = '58-RPD',RecordTypeId = departmentRecordType.Id );
        insert dep;
        Department__c dep1 = new Department__c(Department_Number__c = '50', Name = '50-ACPD',RecordTypeId = departmentRecordType.Id );
        insert dep1;
        
        OperatingHours oh = New OperatingHours(
            Name = 'Test OP'
        );
        insert oh;
        // Create test Accounts
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            accounts.add(new Account(OperatingHoursId = oh.Id,Name = 'Test Account ' + i, Contact_Name__c = 'abc', RecordTypeId = accountRecordType.Id, Email__c = 'test' + i + '@example.com'));
        }
        insert accounts;
        
        Account testAccount = New Account(
            Name = 'Test&Account',
            IsNamo__c = false,
            RecordTypeId = accountRecordType.Id,
            OperatingHoursId = oh.Id
        );
        insert testAccount;
        
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
        
        // Create a test Product2
        Product2 product = new Product2(Name = 'Test Product', IsActive = true);
        System.runAs(Testdatafactory.createByPassUser()){
            insert product;
            Testdatafactory.createStdPriceBookEntry(product.Id);
        }
        
        // Create Pricebooks and PricebookEntries
        Pricebook2 customPB = new Pricebook2(Name = 'Custom Pricebook', IsActive = true, Department__c = '51', Contract_Type__c = 'LBR');
        insert customPB;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = product.Id, UnitPrice = 100, IsActive = true);
        insert pbe;
        
        
        // Opportunity opp = new Opportunity( Asset__c = asst.Id,Pricebook2Id = customPB.Id, Name = 'Test Opportunity', StageName = 'Prospecting', SubStatus__c = 'Not Contacted', CloseDate = System.today(),Contract_Category__c = 'Conversion', AccountId = accounts[0].Id);
        // insert opp;
        // Update Asset with Serviceable Division
        Asset asst = new Asset(Name = 'Test Asset',Product2Id = product.Id,InstallDate=System.today(), Model_Number__c = '123456', Status = 'Registered', Source__c = 'Customer Care App', RecordTypeId = assetRecordType.Id, Serviceable_Division__c = divisionCPAG.Id);
        insert asst;
         Asset asstpms = new Asset(Name = 'Test Asset',Product2Id = product.Id,InstallDate=System.today(), Model_Number__c = '123456', Status = 'Registered', Source__c = 'Customer Care App', RecordTypeId = assetRecordType.Id, Serviceable_Division__c = divisionCPAG.Id);
        insert asstpms;
        
        // Updated Opportunity with additional fields
        
        
        Pricebook2 standardPriceBook = new Pricebook2(Name = 'Standard Price Book', IsActive = true);
        insert standardPriceBook;
        PricebookEntry testPricebookEntry = new PricebookEntry(Product2Id = product.Id, Pricebook2Id = standardPricebook.Id, UnitPrice = 100, IsActive = true);
        insert testPricebookEntry;
        Pricebook2 rpcPriceBook = new Pricebook2(Name = '50-RPC', Contract_Type__c = 'RPC', Department__c = '50', IsActive = true);
        insert rpcPriceBook;
        PricebookEntry rpcPricebookEntry = new PricebookEntry(Product2Id = product.Id, Pricebook2Id = rpcPriceBook.Id,Product_Family__c = testProductSubFamilyCPSD.Id, UnitPrice = 100, Price_TR__c = 500, IsActive = true);
        insert rpcPricebookEntry;
        Opportunity opp = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = System.today(), AccountId = accounts[0].Id, Department__c = dep.Id, Contract_Type__c = 'RPC',Contract_Category__c = 'Conversion' );
        insert opp;
        OpportunityLineItem oli = new OpportunityLineItem(
            PricebookEntryId = rpcPricebookEntry.Id,
            Quantity = 1,
            OpportunityId = opp.Id,
            UnitPrice = 100,
            Standard_Price_for_Asset__c = 100,
            Last_Year_Price_for_Asset__c = 100,
            ServiceDate = System.today(),
            Product2Id = product.Id,
            Asset__c = asst.Id,
            Product_Family_Id__c = testProductFamilyCPSD.Id
        );
        insert oli;
        
        
        
        
        
        
        // Create Service Contracts and Contract Line Items
        List<ServiceContract> serviceContracts = new List<ServiceContract>();
        for (Account acc : accounts) {
            ServiceContract sc = new ServiceContract(Department__c=  dep.Id,Renewal_Sent__c= false, Name = 'Test ServiceContract ' + acc.Name, AccountId = acc.Id, StartDate = Date.today(), EndDate = Date.today().addDays(90), Term = 12, Events_Created__c = 1, Pricebook2Id = customPB.Id, Opportunity__c = opp.Id);
            serviceContracts.add(sc);
        }
        insert serviceContracts;
        List<ServiceContract> serviceContracts1 = new List<ServiceContract>();
        
        for (Account acc : accounts) {
            ServiceContract sc = new ServiceContract(Is_Backdated_Contract__c=true,  Department__c=  dep1.Id,Renewal_Sent__c= false, Name = 'Test ServiceContract ' + acc.Name, AccountId = acc.Id, StartDate = Date.today(), EndDate = Date.today().addDays(120), Term = 12, Events_Created__c = 1, Pricebook2Id = customPB.Id, Opportunity__c = opp.Id);
            serviceContracts1.add(sc);
        } 
        insert serviceContracts1;
        
        List<ContractLineItem> contractLineItems = new List<ContractLineItem>();
        for (ServiceContract sc : serviceContracts) {
            contractLineItems.add(new ContractLineItem(ServiceContractId = serviceContracts1[0].Id, Quantity = 1, AssetId = asst.Id, PricebookEntryId = pbe.Id, UnitPrice = 100));
        }
        insert contractLineItems;
        // Create CPQ Quote and QuoteLineItem
        SBQQ__Quote__c cpqQuote = new SBQQ__Quote__c(Service_Contract__c=serviceContracts[0].Id,SBQQ__Opportunity2__c = opp.Id, SBQQ__Account__c = accounts[0].Id, SBQQ__Pricebook__c = customPB.Id, SBQQ__StartDate__c = Date.today(), SBQQ__EndDate__c = Date.today().addYears(1));
        insert cpqQuote;
        
        SBQQ__QuoteLine__c cpqQuoteLineItem = new SBQQ__QuoteLine__c(SBQQ__ListPrice__c=1,SBQQ__Quote__c = cpqQuote.Id, SBQQ__Product__c = product.Id, SBQQ__Quantity__c = 10, Asset__c=asst.Id);
        insert cpqQuoteLineItem;
        PMS_Event__c pm= new PMS_Event__c();
        pm.Asset__c= asstpms.Id;
        pm.Account__c= accounts[0].id;
        pm.Subject__c='abc';
        pm.Service_Contract__c = serviceContracts1[0].Id;
        insert pm;
        
    } 
    
    
    @isTest
    static void testEarlyExitIfNotDraft() {
         RecordType accountRecordType = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account' and DeveloperName ='Residential_Customer' LIMIT 1];
        RecordType assetRecordType = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Asset' and DeveloperName ='Asset' LIMIT 1];
        RecordType departmentRecordType = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Department__c' and DeveloperName ='Service' LIMIT 1];
        ID productFamilyRecordTypeId = Schema.SObjectType.Product_Family__c.getRecordTypeInfosByDeveloperName().get('Product_Family').getRecordTypeId();
        ID productSubFamilyRecordTypeId = Schema.SObjectType.Product_Family__c.getRecordTypeInfosByDeveloperName().get('Product_Sub_Family').getRecordTypeId();
        
        // Insert Trigger Settings
        List<Trigger_Setting__c> settingList = new List<Trigger_Setting__c>();
        settingList.add(new Trigger_Setting__c(Name='AccountTrigger', IsActive__c = false));
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
        insert settingList;
        
        // Insert other required setup data
        Branch__c testBranch = new Branch__c(Name= 'Test Branch');
        insert testBranch;
        
        Division__c divisionCPAG = new Division__c(Name = 'CPSD');
        insert divisionCPAG;
        
        Department__c dep = new Department__c(Department_Number__c = '58', Name = '58-RPD',RecordTypeId = departmentRecordType.Id );
        insert dep;
        Department__c dep1 = new Department__c(Department_Number__c = '50', Name = '50-ACPD',RecordTypeId = departmentRecordType.Id );
        insert dep1;
        
        OperatingHours oh = New OperatingHours(
            Name = 'Test OP'
        );
        insert oh;
        // Create test Accounts
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            accounts.add(new Account(OperatingHoursId = oh.Id,Name = 'Test Account ' + i, Contact_Name__c = 'abc', RecordTypeId = accountRecordType.Id, Email__c = 'test' + i + '@example.com'));
        }
        insert accounts;
        
        Account testAccount = New Account(
            Name = 'Test&Account',
            IsNamo__c = false,
            RecordTypeId = accountRecordType.Id,
            OperatingHoursId = oh.Id
        );
        insert testAccount;
        
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
        
        // Create a test Product2
        Product2 product = new Product2(Name = 'Test Product', IsActive = true);
        System.runAs(Testdatafactory.createByPassUser()){
            insert product;
            Testdatafactory.createStdPriceBookEntry(product.Id);
        }
        
        // Create Pricebooks and PricebookEntries
        Pricebook2 customPB = new Pricebook2(Name = 'Custom Pricebook', IsActive = true, Department__c = '51', Contract_Type__c = 'LBR');
        insert customPB;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = product.Id, UnitPrice = 100, IsActive = true);
        insert pbe;
        
        
        // Opportunity opp = new Opportunity( Asset__c = asst.Id,Pricebook2Id = customPB.Id, Name = 'Test Opportunity', StageName = 'Prospecting', SubStatus__c = 'Not Contacted', CloseDate = System.today(),Contract_Category__c = 'Conversion', AccountId = accounts[0].Id);
        // insert opp;
        // Update Asset with Serviceable Division
        Asset asst = new Asset(Name = 'Test Asset',Product2Id = product.Id,InstallDate=System.today(), Model_Number__c = '123456', Status = 'Registered', Source__c = 'Customer Care App', RecordTypeId = assetRecordType.Id, Serviceable_Division__c = divisionCPAG.Id);
        insert asst;
         Asset asstpms = new Asset(Name = 'Test Asset',Product2Id = product.Id,InstallDate=System.today(), Model_Number__c = '123456', Status = 'Registered', Source__c = 'Customer Care App', RecordTypeId = assetRecordType.Id, Serviceable_Division__c = divisionCPAG.Id);
        insert asstpms;
        
        // Updated Opportunity with additional fields
        
        
        Pricebook2 standardPriceBook = new Pricebook2(Name = 'Standard Price Book', IsActive = true);
        insert standardPriceBook;
        PricebookEntry testPricebookEntry = new PricebookEntry(Product2Id = product.Id, Pricebook2Id = standardPricebook.Id, UnitPrice = 100, IsActive = true);
        insert testPricebookEntry;
        Pricebook2 rpcPriceBook = new Pricebook2(Name = '50-RPC', Contract_Type__c = 'RPC', Department__c = '50', IsActive = true);
        insert rpcPriceBook;
        PricebookEntry rpcPricebookEntry = new PricebookEntry(Product2Id = product.Id, Pricebook2Id = rpcPriceBook.Id,Product_Family__c = testProductSubFamilyCPSD.Id, UnitPrice = 100, Price_TR__c = 500, IsActive = true);
        insert rpcPricebookEntry;
        Opportunity opp = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = System.today(), AccountId = accounts[0].Id, Department__c = dep.Id, Contract_Type__c = 'RPC',Contract_Category__c = 'Conversion' );
        insert opp;
        OpportunityLineItem oli = new OpportunityLineItem(
            PricebookEntryId = rpcPricebookEntry.Id,
            Quantity = 1,
            OpportunityId = opp.Id,
            UnitPrice = 100,
            Standard_Price_for_Asset__c = 100,
            Last_Year_Price_for_Asset__c = 100,
            ServiceDate = System.today(),
            Product2Id = product.Id,
            Asset__c = asst.Id,
            Product_Family_Id__c = testProductFamilyCPSD.Id
        );
        insert oli;
        
        
        
        
        
        
        // Create Service Contracts and Contract Line Items
        List<ServiceContract> serviceContracts = new List<ServiceContract>();
        for (Account acc : accounts) {
            ServiceContract sc = new ServiceContract(Department__c=  dep.Id,Renewal_Sent__c= false, Name = 'Test ServiceContract ' + acc.Name, AccountId = acc.Id, StartDate = Date.today(), EndDate = Date.today().addDays(90), Term = 12, Events_Created__c = 1, Pricebook2Id = customPB.Id, Opportunity__c = opp.Id);
            serviceContracts.add(sc);
        }
        insert serviceContracts;
        List<ServiceContract> serviceContracts1 = new List<ServiceContract>();
        
        for (Account acc : accounts) {
            ServiceContract sc = new ServiceContract(Is_Backdated_Contract__c=true,  Department__c=  dep1.Id,Renewal_Sent__c= false, Name = 'Test ServiceContract ' + acc.Name, AccountId = acc.Id, StartDate = Date.today(), EndDate = Date.today().addDays(120), Term = 12, Events_Created__c = 1, Pricebook2Id = customPB.Id, Opportunity__c = opp.Id);
            serviceContracts1.add(sc);
        } 
        insert serviceContracts1;
        
        List<ContractLineItem> contractLineItems = new List<ContractLineItem>();
        for (ServiceContract sc : serviceContracts) {
            contractLineItems.add(new ContractLineItem(ServiceContractId = serviceContracts1[0].Id, Quantity = 1, AssetId = asst.Id, PricebookEntryId = pbe.Id, UnitPrice = 100));
        }
        insert contractLineItems;
        // Create CPQ Quote and QuoteLineItem
        SBQQ__Quote__c cpqQuote = new SBQQ__Quote__c(Service_Contract__c=serviceContracts[0].Id,SBQQ__Opportunity2__c = opp.Id, SBQQ__Account__c = accounts[0].Id, SBQQ__Pricebook__c = customPB.Id, SBQQ__StartDate__c = Date.today(), SBQQ__EndDate__c = Date.today().addYears(1));
        insert cpqQuote;
        
        SBQQ__QuoteLine__c cpqQuoteLineItem = new SBQQ__QuoteLine__c(SBQQ__ListPrice__c=1,SBQQ__Quote__c = cpqQuote.Id, SBQQ__Product__c = product.Id, SBQQ__Quantity__c = 10, Asset__c=asst.Id);
        insert cpqQuoteLineItem;
        PMS_Event__c pm= new PMS_Event__c();
        pm.Asset__c= asstpms.Id;
        pm.Account__c= accounts[0].id;
        pm.Subject__c='abc';
        pm.Service_Contract__c = serviceContracts1[0].Id;
        insert pm;
          PMS_Event__c pe= new PMS_Event__c();
        pe.Start_Date__c=System.today();
        pe.Asset__c=asstpms.Id;
        pe.Subject__c= 'test';
        pe.Account__c=accounts[0].id;
       // insert pe;
        List<PMS_Event__c> pms = new  List<PMS_Event__c>();
pms.add(pe);        
        Test.startTest();
        System.enqueueJob(new PMSInsertQueueable(pms));
        //  PMSDraftSyncQueueable.coveragemethod2();
        Test.stopTest();
    }
}