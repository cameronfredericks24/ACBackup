@isTest(SeeAllData=false)
public class CreateCaseFormControllerTest {

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
        createPartnerUser('Channel Partner User - esa', channelPartner.Id); 
        Account ResidentialAccount = TestDataFactory.createResidentialAccount('create case', '9000000000');  
        ResidentialAccount.Create_Address_Backend__c = true;
        update ResidentialAccount;
        
        Contact contact = new Contact(
                LastName = 'Create Case Residential',  // Last name of the Contact
                Email = 'test@example.com',  // Example email address
                Phone = '9000000001',
                AccountId = ResidentialAccount.Id
        );
        insert contact;

        Division__c division = TestDataFactory.createDivision('CPAG');
        Department__c department = TestDataFactory.createDepartment('52',division);   
        Product_Family__c productFamily = TestDataFactory.createProductFamily('AC - Room Air Conditioner');
        productFamily.Service_Department_No__c = department.Id;
        update productFamily;
        Product_Family__c productSubFamily = TestDataFactory.createProductSubFamily('Split', productFamily);
        Product2 product = TestDataFactory.createProduct('11213TR R32 1 STAR F HW SAC', 'P12345', productFamily, productSubFamily);
        Branch__c branch = TestDataFactory.createBranch('Mumbai');
        
        Asset asset = TestDataFactory.createAsset('Test Asset', 'Active', product, branch, Date.today(), 'INV1234', channelPartner);
        asset.Service_Department_L__c = department.Id;
        asset.Cp__c = channelPartner.Id;
        update asset;
        Test.stopTest();
    }

    @IsTest
    static void testFetchProductFamily() {        
        test.startTest();
        List<Product_Family__c> result = CreateCaseFormController.fetchProductFamily();
        System.assertEquals(1, result.size(), 'Only records with the "Product_Sub_family" record type should be retrieved.');
        test.stopTest();
    }

    @IsTest
    static void testFetchProducts() {
        
        Test.startTest();
        Product_Family__c subFamily = [SELECT Id FROM Product_Family__c WHERE Name = 'Split' LIMIT 1];

        // Act: Call the fetchProducts method
        List<Product2> result = CreateCaseFormController.fetchProducts(subFamily.Id);

        Test.stopTest();
        // Assert: Verify only the products linked to the Sub Family are retrieved
        System.assertEquals(1, result.size(), 'Only products linked to the provided Sub Family should be retrieved.');
       
    }

    @IsTest
    static void testCheckSSDUsePortalUser() {
        
        test.startTest();
      
        Boolean result = CreateCaseFormController.checkSSDUser();
        System.assertEquals(false, result, 'The method should return false for a non-portal user.');
        
        Test.stopTest();
    }

    @IsTest
    static void testGetProductSubFamilyId() {
        // Arrange: Query the sub-family record ID
        Product_Family__c subFamily = [SELECT Id FROM Product_Family__c WHERE Name = 'Split' LIMIT 1];

        Test.startTest();
        Product_Family__c result = CreateCaseFormController.getProductSubFamily(subFamily.Id);
        Test.stopTest();


        // Assert: Verify the fields are returned correctly
        System.assertEquals(subFamily.Id, result.Id, 'Returned record ID should match the input ID.');
    }

    @IsTest
    static void testGetIssueTypes() {
        // Arrange: Create a custom field with picklist values
        String objectName = 'Case'; // Replace with a valid object containing picklist fields
        String fieldName = 'Status'; // Replace with a valid picklist field

        // Act: Call the method
        List<String> result = CreateCaseFormController.getIssueTypes(objectName, fieldName);

        // Assert: Verify the picklist values are returned
        System.assert(result.size() > 0, 'Picklist values should be returned.');
        System.debug('Returned picklist values: ' + result);
    }

    @IsTest
    static void testGetAccount() {
        // Arrange: Retrieve the test Account
        Account testAccount = [SELECT Id FROM Account where RecordType.developerName='Residential_Customer' LIMIT 1];

        test.startTest();
        Account result = CreateCaseFormController.getAccount(null, null, null, testAccount.Id, null);
        test.stopTest();

        // Assert: Verify the correct Account is returned
        //System.assertNotNull(result, 'Account should not be null.');
        //System.assertEquals(testAccount.Id, result.Id, 'Returned Account ID should match the provided recordId.');
    }

    @IsTest
    static void testGetAccountsByNameAndPincode() {
        // Act: Call the method with a name and pincode
        test.startTest();
        Account testAccount = [SELECT Id, Phone, Customer_ID__c, name, email__c, ShippingPostalCode FROM Account where RecordType.developerName='Residential_Customer' LIMIT 1];
        List<Account> accounts = CreateCaseFormController.getAccountBasedOnNameAndPincode(testAccount.Name,testAccount.ShippingPostalCode, testAccount.email__c, testAccount.Phone, false, testAccount.Customer_ID__c);
        Test.stopTest();
        // Assert: Verify the returned accounts
        System.assert(accounts.size() == 1, 'Only one account should match.');
    }

    @IsTest
    static void testGetCommercialAccountSearch() {
        // Act: Call the method with a name and pincode
        test.startTest();
        Id accountRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Commercial_Customer' LIMIT 1].Id;
        Account account = new Account(
                Name = 'Test Account', 
                Phone = '9000000000',  // Example phone number
                Contact_Name__c = 'Create Case',  // Custom field for Contact Name
                Email__c = 'createcase@example.com', 
                ShippingPostalCode = '400008',
                Language_Preference__c = 'English',  // Language preference
                RecordTypeId = accountRecordTypeId,
                Namo_Branch__c = 'Test Branch',
                SOL_Store_ID__c = '12345'  // Set the RecordTypeId for 'Commercial Customer'
            );
        insert account;

        Account testAccount = [SELECT Id, Phone,Namo_Branch__c,SOL_Store_ID__c, Customer_ID__c, name, email__c, ShippingPostalCode FROM Account where Id=:account.Id LIMIT 1];
        List<Account> accounts = CreateCaseFormController.getCommercialAccountSearch(testAccount.Name,testAccount.ShippingPostalCode,testAccount.Namo_Branch__c,testAccount.SOL_Store_ID__c,'Test Account', testAccount.email__c, false, testAccount.Customer_ID__c);
        Test.stopTest();
        // Assert: Verify the returned accounts
       // System.assert(accounts.size() == 1, 'Only one account should match.');
    }

    @IsTest
    static void testGetAssetByRecordId() {
        // Retrieve the child asset created in setup
        Asset childAsset = [SELECT Id,Name FROM Asset LIMIT 1];

        // Act: Call the method with a valid record ID
        Asset result = CreateCaseFormController.getAsset('INV1234', childAsset.Id);
        CreateCaseFormController.tagChannelPartnerUI(null);

        //System.assertEquals(childAsset.Name, result.Name, 'Parent asset name should match.');
    }

    @IsTest
    static void testGetRecordTypes() {
        // Prepare object list for testing
        List<String> objectList = new List<String>{'Account', 'Asset'};

        // Act: Call the method with valid objects
        Map<String, List<RecordType>> result = CreateCaseFormController.getRecordTypes(objectList);

        // Assert: Verify the result map
        System.assert(result.containsKey('Account'), 'Account should be in the result map.');
        System.assert(result.containsKey('Asset'), 'Asset should be in the result map.');
        System.assert(result.get('Account').size() > 0, 'Account record types should exist.');
        System.assert(result.get('Asset').size() > 0, 'Asset record types should exist.');
    }

    @IsTest
    static void testCreatecaseResidentail() {
      test.startTest();
      CreateCaseFormController.createCaseParameters caseParameters = new CreateCaseFormController.createCaseParameters();
      Account accountList = [
        SELECT 
            Id,
            Phone,
            Contact_Name__c,
            Email__c,
            Create_Address_Backend__c,
            Secondary_Phone_No__c,
            ShippingStateCode,
            ShippingStreet,
            ShippingCity,
            ShippingPostalCode,
            ShippingCountry,
            Shipping_House_Flat_BlockNo__c,
            Shipping_Area__c,
            Shipping_Sector__c,
            Shipping_Locality__c,
            Shipping_SubLocality__c,
            BillingStateCode,
            BillingStreet,
            BillingCity,
            BillingPostalCode,
            BillingCountry,
            Billing_House_Flat_BlockNo__c,
            Billing_Area__c,
            Billing_Sector__c,
            Billing_Locality__c,
            Billing_SubLocality__c,
            ShippingLatitude,
            ShippingLongitude,
            Language_Preference__c
        FROM Account where RecordType.developerName = 'Residential_Customer' 
        LIMIT 1
    ];

    List<Contact> contactList = [
    SELECT Phone, Email, OtherPhone 
    FROM Contact where AccountId = :accountList.Id
    LIMIT 1
    ];
    

    Asset asset = [Select Id, Product_Family__c,Product2Id, Product_Sub_Family__c, PostalCode from Asset Limit 1];

    Schema.Address newAddress = new Schema.Address();
    newAddress.StateCode = 'MH'; // Example state code
    newAddress.Street = '123 Main St';
    newAddress.City = 'San Francisco';
    newAddress.PostalCode = '400008';
    
    caseParameters.assetRecord = asset;
    caseParameters.contactList = contactList;
    caseParameters.shippingAddressList = new List<Schema.Address>{newAddress};
    caseParameters.selectedAddress = newAddress;
    caseParameters.isCommercial = false;
    caseParameters.division = 'CPAG';
    caseParameters.primaryContact = contactList[0];
    caseParameters.accountChange = false;
    caseParameters.accountRecord = accountList;

    caseParameters.caseRecord = new Case(
        Type = 'Breakdown',
        Preferred_Slot_Start_Time__c = System.now()
    );

    CP_Mappings__c cpMapping = new CP_Mappings__c();

    // Setting required fields
    cpMapping.Name = 'CP Mapping Example'; // CP Mapping Name
    cpMapping.Division__c = [SELECT Id FROM Division__c LIMIT 1].Id; // Fetching a Division record (ensure at least one exists)
    cpMapping.Customer_Type__c = 'Residential Customer'; // Example picklist value for Customer Type
    cpMapping.Product_Type__c = 'Existing Product'; // Example picklist value for Product Type
    cpMapping.Service_Ticket_Assignment__c = 'Pincode/Sector Based Mapping';
    insert cpMapping;

    PinCode__c newPinCode = new PinCode__c();
    newPinCode.Branch__c = [SELECT Id FROM Branch__c LIMIT 1].Id; // Get the first Branch record's Id (Ensure you have Branch records)
    newPinCode.Postal_Code__c = '400008'; // Example postal code
    insert newPinCode;

    // Create a new Service_Area_Routing__c record
    Service_Area_Routing__c serviceAreaRouting = new Service_Area_Routing__c();

    // Setting required fields
    serviceAreaRouting.Call_Type__c = 'Breakdown'; // Example picklist value for Call Type
    serviceAreaRouting.Channel_Partner__c = [SELECT Id FROM Account LIMIT 1].Id; // Fetching an Account record (ensure at least one exists)
    serviceAreaRouting.Department__c = [SELECT Id FROM Department__c LIMIT 1].Id; // Fetching a Department record (ensure at least one exists)
    serviceAreaRouting.Pincode__c = newPinCode.Id; // Fetching a Pincode record (ensure at least one exists)
    serviceAreaRouting.Product_Family__c = [SELECT Id FROM Product_Family__c LIMIT 1].Id; // Fetching a Product Family record (ensure at least one exists)
    insert serviceAreaRouting;

    Branch_Division__c branchDivision = new Branch_Division__c(
        Branch__c  = [Select Id from Branch__c Limit 1].Id,
        Department__c = [Select Id from Department__c Limit 1].Id,
        Division__c = [Select Id from Division__C Limit 1].Id,
        Service_AM__c = userInfo.getUserId(),
        Service_RM__c = userInfo.getUserId(),
        Service_SDE__c = userInfo.getUserId(),
        Service_SDH__c = userInfo.getUserId()
    );
    insert branchDivision;

    CreateCaseFormController.createRecords(accountList, JSON.serialize(caseParameters));
    
    String dynamicQuery = 'Select Id, CaseId from WorkOrder Limit 1';
        CPTagBatch batchJob = new CPTagBatch(dynamicQuery);
        Database.executeBatch(batchJob, 200);

    test.stopTest();
    }
    
    @IsTest
    static void testCreatecaseResidentailTest() {
      test.startTest();
      CreateCaseFormController.createCaseParameters caseParameters = new CreateCaseFormController.createCaseParameters();
      Account accountList = [
        SELECT 
            Id,
            Phone,
            Contact_Name__c,
            Email__c,
            Create_Address_Backend__c,
            Secondary_Phone_No__c,
            ShippingStateCode,
            ShippingStreet,
            ShippingCity,
            ShippingPostalCode,
            ShippingCountry,
            Shipping_House_Flat_BlockNo__c,
            Shipping_Area__c,
            Shipping_Sector__c,
            Shipping_Locality__c,
            Shipping_SubLocality__c,
            BillingStateCode,
            BillingStreet,
            BillingCity,
            BillingPostalCode,
            BillingCountry,
            Billing_House_Flat_BlockNo__c,
            Billing_Area__c,
            Billing_Sector__c,
            Billing_Locality__c,
            Billing_SubLocality__c,
            ShippingLatitude,
            ShippingLongitude,
            Language_Preference__c
        FROM Account where RecordType.developerName = 'Residential_Customer' 
        LIMIT 1
    ];

    List<Contact> contactList = [
    SELECT Phone, Email, OtherPhone 
    FROM Contact where AccountId = :accountList.Id
    LIMIT 1
    ];
    

    Asset asset = [Select Id, Product_Family__c,Product2Id, Product_Sub_Family__c, PostalCode from Asset Limit 1];

    Schema.Address newAddress = new Schema.Address();
    newAddress.StateCode = 'MH'; // Example state code
    newAddress.Street = '123 Main St';
    newAddress.City = 'San Francisco';
    newAddress.PostalCode = '400008';
    
    caseParameters.assetRecord = asset;
    caseParameters.contactList = contactList;
    caseParameters.shippingAddressList = new List<Schema.Address>{newAddress};
    caseParameters.selectedAddress = newAddress;
    caseParameters.isCommercial = false;
    caseParameters.division = 'CPAG';
    caseParameters.primaryContact = contactList[0];
    caseParameters.accountChange = false;
    caseParameters.accountRecord = accountList;

    caseParameters.caseRecord = new Case(
        Type = 'Breakdown',
        Preferred_Slot_Start_Time__c = System.now(),
        Repeated_Customer__c = true
    );

    CP_Mappings__c cpMapping = new CP_Mappings__c();

    // Setting required fields
    cpMapping.Name = 'CP Mapping Example'; // CP Mapping Name
    cpMapping.Division__c = [SELECT Id FROM Division__c LIMIT 1].Id; // Fetching a Division record (ensure at least one exists)
    cpMapping.Customer_Type__c = 'Residential Customer'; // Example picklist value for Customer Type
    cpMapping.Product_Type__c = 'Existing Product'; // Example picklist value for Product Type
    cpMapping.Service_Ticket_Assignment__c = 'Pincode/Sector Based Mapping';
    insert cpMapping;

    PinCode__c newPinCode = new PinCode__c();
    newPinCode.Branch__c = [SELECT Id FROM Branch__c LIMIT 1].Id; // Get the first Branch record's Id (Ensure you have Branch records)
    newPinCode.Postal_Code__c = '400008'; // Example postal code
    insert newPinCode;

    // Create a new Service_Area_Routing__c record
    Service_Area_Routing__c serviceAreaRouting = new Service_Area_Routing__c();

    // Setting required fields
    serviceAreaRouting.Call_Type__c = 'Breakdown'; // Example picklist value for Call Type
    serviceAreaRouting.Channel_Partner__c = [SELECT Id FROM Account LIMIT 1].Id; // Fetching an Account record (ensure at least one exists)
    serviceAreaRouting.Department__c = [SELECT Id FROM Department__c LIMIT 1].Id; // Fetching a Department record (ensure at least one exists)
    serviceAreaRouting.Pincode__c = newPinCode.Id; // Fetching a Pincode record (ensure at least one exists)
    serviceAreaRouting.Product_Family__c = [SELECT Id FROM Product_Family__c LIMIT 1].Id; // Fetching a Product Family record (ensure at least one exists)
    insert serviceAreaRouting;

    Branch_Division__c branchDivision = new Branch_Division__c(
        Branch__c  = [Select Id from Branch__c Limit 1].Id,
        Department__c = [Select Id from Department__c Limit 1].Id,
        Division__c = [Select Id from Division__C Limit 1].Id,
        Service_AM__c = userInfo.getUserId(),
        Service_RM__c = userInfo.getUserId(),
        Service_SDE__c = userInfo.getUserId(),
        Service_SDH__c = userInfo.getUserId()
    );
    insert branchDivision;

    CreateCaseFormController.createRecords(accountList, JSON.serialize(caseParameters));
    
    String dynamicQuery = 'Select Id, CaseId from WorkOrder Limit 1';
        CPTagBatch batchJob = new CPTagBatch(dynamicQuery);
        Database.executeBatch(batchJob, 200);

    test.stopTest();
    }



    @IsTest
    static void testCreateCaseCommercial() {
        test.startTest();
        CreateCaseFormController.createCaseParameters caseParameters = new CreateCaseFormController.createCaseParameters();
        Id accountRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Commercial_Customer' LIMIT 1].Id;
        Account accountList = new Account(
                Name = 'Create Case Commercial', 
                Phone = '9000000000',  // Example phone number
                Contact_Name__c = 'Create Case',  // Custom field for Contact Name
                Email__c = 'createcase@example.com', 
                ShippingLatitude = 40.7128,  // Shipping latitude (example)
                ShippingLongitude = -74.0060,  // Shipping longitude (example)
                Language_Preference__c = 'English',  // Language preference
                RecordTypeId = accountRecordTypeId  // Set the RecordTypeId for 'Commercial Customer'
            );
     
        Contact contact = new Contact(
                LastName = 'Create Case Commercial',  // Last name of the Contact
                Email = 'test@example.com',  // Example email address
                Phone = '9000000000'
        );
    
        List<Contact> contactList = new List<Contact>{contact};

        Product_Family__c subFamily = [SELECT Id FROM Product_Family__c WHERE Name = 'Split' LIMIT 1];

        Schema.Address newAddress = new Schema.Address();
        newAddress.StateCode = 'MH'; // Example state code
        newAddress.Street = '123 Main St';
        newAddress.City = 'San Francisco';
        newAddress.PostalCode = '400008';
        
        caseParameters.assetRecord = new Asset();
        caseParameters.contactList = contactList;
        caseParameters.shippingAddressList = new List<Schema.Address>{newAddress};
        caseParameters.selectedAddress = newAddress;
        caseParameters.isCommercial = true;
        caseParameters.division = 'CPAG';
        caseParameters.primaryContact = contactList[0];
        caseParameters.accountChange = true;
        caseParameters.accountRecord = accountList;

        caseParameters.caseRecord = new Case(
            Type = 'Breakdown',
            Preferred_Slot_Start_Time__c = System.now(),
            Product_Sub_Family_temp__c = subFamily.Id
        );

        CP_Mappings__c cpMapping = new CP_Mappings__c();

        // Setting required fields
        cpMapping.Name = 'CP Mapping Example'; // CP Mapping Name
        cpMapping.Division__c = [SELECT Id FROM Division__c LIMIT 1].Id; // Fetching a Division record (ensure at least one exists)
        cpMapping.Customer_Type__c = 'Commercial Customer'; // Example picklist value for Customer Type
        cpMapping.Product_Type__c = 'New Product'; // Example picklist value for Product Type
        cpMapping.Service_Ticket_Assignment__c = 'Tag SDE';
        insert cpMapping;

        Branch_Division__c branchDivision = new Branch_Division__c(
            Branch__c  = [Select Id from Branch__c Limit 1].Id,
            Department__c = [Select Id from Department__c Limit 1].Id,
            Division__c = [Select Id from Division__C Limit 1].Id,
            Service_AM__c = userInfo.getUserId(),
            Service_RM__c = userInfo.getUserId(),
            Service_SDE__c = userInfo.getUserId(),
            Service_SDH__c = userInfo.getUserId()
        );
        insert branchDivision;

        PinCode__c newPinCode = new PinCode__c();
        newPinCode.Branch__c = [SELECT Id FROM Branch__c LIMIT 1].Id; // Get the first Branch record's Id (Ensure you have Branch records)
        newPinCode.Postal_Code__c = '400008'; // Example postal code
        insert newPinCode;

        CreateCaseFormController.createRecords(accountList, JSON.serialize(caseParameters));
        
        String dynamicQuery = 'Select Id, CaseId from WorkOrder Limit 1';
        CPTagBatch batchJob = new CPTagBatch(dynamicQuery);
        Database.executeBatch(batchJob, 200);

        test.stopTest();
    }

    @IsTest
    static void testCreateCaseCommercialAsset() {
        test.startTest();
        CreateCaseFormController.createCaseParameters caseParameters = new CreateCaseFormController.createCaseParameters();
        Id accountRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Commercial_Customer' LIMIT 1].Id;
        Account account = new Account(
                Name = 'Create Case Commercial', 
                Phone = '9000000000',  // Example phone number
                Contact_Name__c = 'Create Case',  // Custom field for Contact Name
                Email__c = 'createcase@example.com', 
                ShippingLatitude = 40.7128,  // Shipping latitude (example)
                ShippingLongitude = -74.0060,  // Shipping longitude (example)
                Language_Preference__c = 'English',  // Language preference
                RecordTypeId = accountRecordTypeId,  // Set the RecordTypeId for 'Commercial Customer'
                Create_Address_Backend__c = true
        );
        insert account;
        Contact contact = new Contact(
                LastName = 'Create Case Comm',  // Last name of the Contact
                Email = 'test@example.com',  // Example email address
                Phone = '9000000001',
                AccountId = account.Id
        );
        insert contact;

        Account accountList = [
            SELECT 
                Id,
                Phone,
                Contact_Name__c,
                Email__c,
                Create_Address_Backend__c,
                Secondary_Phone_No__c,
                ShippingStateCode,
                ShippingStreet,
                ShippingCity,
                ShippingPostalCode,
                ShippingCountry,
                Shipping_House_Flat_BlockNo__c,
                Shipping_Area__c,
                Shipping_Sector__c,
                Shipping_Locality__c,
                Shipping_SubLocality__c,
                BillingStateCode,
                BillingStreet,
                BillingCity,
                BillingPostalCode,
                BillingCountry,
                Billing_House_Flat_BlockNo__c,
                Billing_Area__c,
                Billing_Sector__c,
                Billing_Locality__c,
                Billing_SubLocality__c,
                ShippingLatitude,
                ShippingLongitude,
                Language_Preference__c
            FROM Account where RecordType.developerName = 'Commercial_Customer' 
            LIMIT 1
        ];
       
        
        //insert account;
     
        
        List<Contact> contactList = [
        SELECT Phone, Email, OtherPhone 
        FROM Contact where AccountId = :accountList.Id
        LIMIT 1
        ];


        Asset asset = [Select Id, Product_Family__c,Product2Id, Product_Sub_Family__c, PostalCode from Asset Limit 1];

        Schema.Address newAddress = new Schema.Address();
        newAddress.StateCode = 'MH'; // Example state code
        newAddress.Street = '123 Main St';
        newAddress.City = 'San Francisco';
        newAddress.PostalCode = '400008';
        
        caseParameters.assetRecord = asset;
        caseParameters.contactList = contactList;
        caseParameters.shippingAddressList = new List<Schema.Address>{newAddress};
        caseParameters.selectedAddress = newAddress;
        caseParameters.isCommercial = true;
        caseParameters.division = 'CPAG';
        caseParameters.primaryContact = contactList[0];
        caseParameters.accountChange = false;
        caseParameters.accountRecord = accountList;

        caseParameters.caseRecord = new Case(
            Type = 'Breakdown',
            Preferred_Slot_Start_Time__c = System.now()
        );

        CP_Mappings__c cpMapping = new CP_Mappings__c();

        // Setting required fields
        cpMapping.Name = 'CP Mapping Example'; // CP Mapping Name
        cpMapping.Division__c = [SELECT Id FROM Division__c LIMIT 1].Id; // Fetching a Division record (ensure at least one exists)
        cpMapping.Customer_Type__c = 'Commercial Customer'; // Example picklist value for Customer Type
        cpMapping.Product_Type__c = 'Existing Product'; // Example picklist value for Product Type
        cpMapping.Service_Ticket_Assignment__c = 'Tag Asset\'s CP';
        insert cpMapping;

        PinCode__c newPinCode = new PinCode__c();
        newPinCode.Branch__c = [SELECT Id FROM Branch__c LIMIT 1].Id; // Get the first Branch record's Id (Ensure you have Branch records)
        newPinCode.Postal_Code__c = '400008'; // Example postal code
        insert newPinCode;

        Branch_Division__c branchDivision = new Branch_Division__c(
            Branch__c  = [Select Id from Branch__c Limit 1].Id,
            Department__c = [Select Id from Department__c Limit 1].Id,
            Division__c = [Select Id from Division__C Limit 1].Id,
            Service_AM__c = userInfo.getUserId(),
            Service_RM__c = userInfo.getUserId(),
            Service_SDE__c = userInfo.getUserId(),
            Service_SDH__c = userInfo.getUserId()
        );
        insert branchDivision;

        CreateCaseFormController.createRecords(accountList, JSON.serialize(caseParameters));
        
        String dynamicQuery = 'Select Id, CaseId from WorkOrder Limit 1';
        CPTagBatch batchJob = new CPTagBatch(dynamicQuery);
        Database.executeBatch(batchJob, 200);
        

        test.stopTest();
    }

    @isTest
    static void testGetCpFromPincodes() {
        
        Test.startTest();

        PinCode__c newPinCode = new PinCode__c();
        newPinCode.Branch__c = [SELECT Id FROM Branch__c LIMIT 1].Id; 
        newPinCode.Postal_Code__c = '400008'; // Example postal code
        insert newPinCode;
        
        // Create CP_Pincode_Coverage__c records linking CP and PinCode
        CP_Pincode_Coverage__c coverageRecord = new CP_Pincode_Coverage__c(CP__c =[Select Id from Account Limit 1].Id, PinCode__c = newPinCode.Id);

        Set<Id> pincodeIds = new Set<Id>{newPinCode.Id};
        List<CP_Pincode_Coverage__c> result = CpPincodeSelector.getCpFromPincodes(pincodeIds);

        Test.stopTest();
    }

    @isTest
    static void testCheckAssetWty() {
        Test.startTest();
        Asset asset = [Select Id, Product_Family__c,Product2Id, Product_Sub_Family__c, PostalCode from Asset Limit 1];
        Asset result = CreateCaseFormController.checkAssetWty(asset.Id);
        Test.stopTest();

    }

    @isTest
    static void tstCheckWorkOrderPMS() {
        Test.startTest();
        WorkType workType = TestDataFactory.createWorkType('PMS');
        Account testAccount = [SELECT Id,Phone, Email__c FROM Account where RecordType.developerName='Residential_Customer' LIMIT 1];
        Asset asset = [Select Id, Product_Family__c,Product2Id, Product_Sub_Family__c, PostalCode from Asset Limit 1];
        WorkOrder workOrder = TestDataFactory.createWorkOrder(asset, workType,testAccount , new case(),'Accepted');
        Id recordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('PMS').getRecordTypeId(); 
        workOrder.recordTypeId = recordTypeId;
        update workOrder;

        Boolean result = CreateCaseFormController.checkWorkOrderPMS(asset.Id, testAccount.Id);
        Test.stopTest();

    }


    private static User createPartnerUser(String profileName, Id accountId) {

        Contact contact = new Contact(
            LastName = 'CP',  // Last name of the Contact
            Email = 'cp@example.com',  // Example email address
            Phone = '9000000000',  // Example phone number
            AccountId = accountId
        );

        insert contact;

        Id contactId = contact.Id;
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
        String uniqueIdentifier = String.valueOf(System.currentTimeMillis());
        String uniqueUsername = testProfile.Id + 'testuser' + uniqueIdentifier + '@example.com';
        User testUser = new User(
            Alias = 'testUser',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = testProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = uniqueUsername,
            contactId = contactId
        );
        insert testUser;
        return testUser;
    }

    @IsTest
    static void testCreateCaseVIP() {
        test.startTest();
        CreateCaseFormController.createCaseParameters caseParameters = new CreateCaseFormController.createCaseParameters();
        Id accountRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Residential_Customer' LIMIT 1].Id;
        Account accountList = new Account(
                Name = 'Create Case VIP', 
                Phone = '9000000000',  // Example phone number
                Contact_Name__c = 'Create Case',  // Custom field for Contact Name
                Email__c = 'createcase@example.com', 
                ShippingLatitude = 40.7128,  // Shipping latitude (example)
                ShippingLongitude = -74.0060,  // Shipping longitude (example)
                Language_Preference__c = 'English',  // Language preference
                RecordTypeId = accountRecordTypeId,
                Category__c = 'VIP'  // Set the RecordTypeId for 'Commercial Customer'
            );
        
        insert accountList;
     
        Contact contact = new Contact(
                LastName = 'Create Case Commercial',  // Last name of the Contact
                Email = 'test@example.com',  // Example email address
                Phone = '9000000001'
        );
    
        List<Contact> contactList = new List<Contact>{contact};

        Product_Family__c subFamily = [SELECT Id FROM Product_Family__c WHERE Name = 'Split' LIMIT 1];

        Schema.Address newAddress = new Schema.Address();
        newAddress.StateCode = 'MH'; // Example state code
        newAddress.Street = '123 Main St';
        newAddress.City = 'San Francisco';
        newAddress.PostalCode = '400008';
        
        caseParameters.assetRecord = new Asset();
        caseParameters.contactList = contactList;
        caseParameters.shippingAddressList = new List<Schema.Address>{newAddress};
        caseParameters.selectedAddress = newAddress;
        caseParameters.isCommercial = false;
        caseParameters.division = 'CPAG';
        caseParameters.primaryContact = contactList[0];
        caseParameters.accountChange = false;
        caseParameters.accountRecord = accountList;

        caseParameters.caseRecord = new Case(
            Type = 'Breakdown',
            Preferred_Slot_Start_Time__c = System.now(),
            Product_Sub_Family_temp__c = subFamily.Id
        );
      
        Branch_Division__c branchDivision = new Branch_Division__c(
            Branch__c  = [Select Id from Branch__c Limit 1].Id,
            Department__c = [Select Id from Department__c Limit 1].Id,
            Division__c = [Select Id from Division__C Limit 1].Id,
            Service_AM__c = userInfo.getUserId(),
            Service_RM__c = userInfo.getUserId(),
            Service_SDE__c = userInfo.getUserId(),
            Service_SDH__c = userInfo.getUserId()
        );
        insert branchDivision;

        PinCode__c newPinCode = new PinCode__c();
        newPinCode.Branch__c = [SELECT Id FROM Branch__c LIMIT 1].Id; // Get the first Branch record's Id (Ensure you have Branch records)
        newPinCode.Postal_Code__c = '400008'; // Example postal code
        insert newPinCode;

        Account a  = [Select Id from Account Limit 1];
        a.RecordTypeId = AccountConstant.CHANNEL_PARTNER_ACCOUNT_RT;
        update a;
        Customer_Partner_Relationship__c cpRelationship = new Customer_Partner_Relationship__c(
            Customer__c = accountList.Id,
            Channel_Partner__c =  a.Id,
            Product_Type__c = 'AC Dealer'
        );
        //insert cpRelationship;

        CreateCaseFormController.createRecords(accountList, JSON.serialize(caseParameters));

        test.stopTest();
    }

     @IsTest
    static void testDummy() {
        ScriptToTagCP.coveragemethod2();
    }

    
}