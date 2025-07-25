@isTest
public class NonBSLAssetRegistrationControllerTest {
    
    @testSetup
    static void setupTestData() {
        
           // Disable triggers
        AccountTriggerHandler.TriggerDisabled = true;
        WorkOrderTriggerHandler.TriggerDisabled = true;
        WorkOrderLineItemTriggerHandler.TriggerDisabled = true;
        CaseTriggerHandler.TriggerDisabled = true;
        AssetTriggerHandler.TriggerDisabled = true;
        ContactTriggerHandler.TriggerDisabled = true;
        ContentDocumentLinkTriggerHandler.TriggerDisabled = true;

        
        
        // Create Product Families
        Product_Family__c parentFamily = new Product_Family__c(Name = 'Parent Family');
        insert parentFamily;

        Product_Family__c childFamily = new Product_Family__c(
            Name = 'Child Family', 
            Code__c = 'PF001', 
            Parent_Product_Family__c = parentFamily.Id
        );
        insert childFamily;

        // Create an Account
        Account acc = new Account(Name = 'Test Account', ShippingCity = 'Test City', ShippingStreet = 'Test Street',RecordTypeId = AccountConstant.RESIDENTIAL_ACCOUNT_RT);
        insert acc;

        // Create an Asset
        Asset existingAsset = new Asset(
            Name = 'Test Asset',
            AccountId = acc.Id,
            SerialNumber = '12345',
            Status = 'Active'
        );
        insert existingAsset;

        // Create a Product2 record
        Product2 product = new Product2(
            Name = 'Test Product',
            IsActive = true
        );
        //insert product;
    }
    
    @isTest
    static void testFetchProductFamilyWithSearchTerm() {
        Test.startTest();
        List<Product_Family__c> results = NonBSLAssetRegistrationController.fetchProductFamily('PF001');
        Test.stopTest();
        //System.assertNotEquals(0, results.size(), 'Product family list should not be empty');
        //System.assertEquals('PF001', results[0].Code__c, 'The Code should match the search term');
    }

    @isTest
    static void testFetchProductFamilyWithoutSearchTerm() {
        Test.startTest();
        List<Product_Family__c> results = NonBSLAssetRegistrationController.fetchProductFamily(null);
        Test.stopTest();
        //System.assertNotEquals(0, results.size(), 'Product family list should not be empty');
    }

    @isTest
    static void testCheckExistingNonBslAsset() {
        Test.startTest();
        Boolean exists = NonBSLAssetRegistrationController.checkExistingNonBslAsset('12345');
        Test.stopTest();
    }

    @isTest
    static void testCreateOrUpdateProductAndAsset() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
                AssetTriggerHandler.TriggerDisabled = true;
                AccountTriggerHandler.TriggerDisabled = true;


        NonBSLAssetRegistrationController.AssetWrapper result = NonBSLAssetRegistrationController.createOrUpdateProductAndAsset(
            acc.Id, 'Test Product', 'Test Make', 'Model001', '67890', 
            Date.today(), Date.today(), false, Date.today(), Date.today(), null, null, null, null,null,null
        );
        Test.stopTest();
       
    }

    @isTest
    static void testAttachFilesToAsset() {
        
                        ContentDocumentLinkTriggerHandler.TriggerDisabled = true;

        Asset asset = [SELECT Id FROM Asset LIMIT 1];
        ContentVersion cv = new ContentVersion(
            Title = 'Test File',
            VersionData = Blob.valueOf('Test file content'),
            PathOnClient = 'testfile.txt'
        );
        insert cv;

        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;

        Test.startTest();

        NonBSLAssetRegistrationController.attachFilesToAsset(asset.Id, new List<Id>{contentDocumentId});
        Test.stopTest();

        List<ContentDocumentLink> links = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :asset.Id];
    }

     @isTest
    static void testGetCapacityUOMPicklistValues() {
        // Test Setup
        // Add a custom metadata record or mock picklist field values if needed
        // Ensure you have the Capacity_UOM__c field defined on the Product2 object in your org

        Test.startTest();

        // Call the method
        List<String> picklistValues = NonBSLAssetRegistrationController.getCapacityUOMPicklistValues();

        Test.stopTest();

        // Assertions
        //System.assertNotEquals(null, picklistValues, 'Picklist values should not be null');
        //System.assert(picklistValues.size() > 0, 'Picklist values should have entries');
        System.debug('Picklist Values: ' + picklistValues);
    }
}