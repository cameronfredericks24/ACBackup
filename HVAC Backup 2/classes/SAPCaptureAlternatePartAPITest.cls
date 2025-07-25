@isTest
private class SAPCaptureAlternatePartAPITest {

     @testSetup 
    static void setupTestData() {
        TestDataFactory.disableTriggers();
        ID productRecordId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Product').getRecordTypeId();
                ID spareProductRecordId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Spare').getRecordTypeId();

        system.debug('productRecordId' + productRecordId);

        ID productFamilyRecordTypeId = Schema.SObjectType.Product_Family__c.getRecordTypeInfosByDeveloperName().get('Product_Family').getRecordTypeId();
        ID productSubFamilyRecordTypeId = Schema.SObjectType.Product_Family__c.getRecordTypeInfosByDeveloperName().get('Product_Sub_Family').getRecordTypeId();
 
        Product_Family__c testProductFamily = New Product_Family__c(
            Name = 'testProductFamily',
            RecordTypeId = productFamilyRecordTypeId
        );
        Insert testProductFamily;
        // Query the inserted record to get the RecordType.Name
testProductFamily = [SELECT Id, Name, RecordType.Name FROM Product_Family__c WHERE Id = :testProductFamily.Id];

        
        system.debug('recordtypename' + testProductFamily.RecordType.name);
        
        Product_Family__c testProductSubFamily = New Product_Family__c(
            Name = 'testProductSubFamily',
            RecordTypeId = productSubFamilyRecordTypeId,
            PMS_Events__c = 2,
            PMS_Events_Days__c = '30,60',
            Parent_Product_Family__c = testProductFamily.Id
        );
        Insert testProductSubFamily;
        
        Product2 testProduct = New Product2(
            Name = 'testProduct',
            RecordTypeId = spareProductRecordId,
            Product_Type__c = 'Durable',
            ProductCode ='BSL_Model_1',
            Product_Family__c = testProductFamily.Id,
            Product_Sub_Family__c = testProductSubFamily.Id
                        
        );       
        System.runAs(Testdatafactory.createByPassUser()){
            insert testProduct;
                Testdatafactory.createStdPriceBookEntry(testProduct.Id);
            }
                system.debug('testProduct' + testProduct);
        
        Product2 testProduct2 = New Product2(
            Name = 'testProduct2',
            RecordTypeId = spareProductRecordId,
            Product_Type__c = 'Durable',
            ProductCode ='BSL_Model_2',
            Product_Family__c = testProductFamily.Id,
            Product_Sub_Family__c = testProductSubFamily.Id
                        
        );       
        System.runAs(Testdatafactory.createByPassUser()){
            insert testProduct2;
                Testdatafactory.createStdPriceBookEntry(testProduct2.Id);
            }
        TestDataFactory.enableTriggers();
    }
    
    @isTest
    static void testCaptureAlternatePart() {
        
 	String jsonReqBody = '{"alternate_parts": [' +
                         '{"product_code": "BSL_Model_1", "alternate_product_code": "BSL_Model_2"},' +
                         '{"product_code": "BSL_Model_2", "alternate_product_code": "BSL_Model_1"}]}';

        // Set up mock REST request
        RestRequest request = new RestRequest();
        request.requestBody = Blob.valueOf(jsonReqBody);
        RestContext.request = request;

        // Call the API method
        Test.startTest();
        list<SAPCaptureAlternatePartAPIResWrapper> responseWrapper = SAPCaptureAlternatePartAPI.captureAlternatePart();
        Test.stopTest();

        // Verify response
        System.assertEquals('Success', responseWrapper[0].result, 'Result should be success');
    }
    
    @isTest
    static void testCaptureAlternatePart_Existing() {
        
 	String jsonReqBody = '{"alternate_parts": [' +
                         '{"product_code": "BSL_Model_1", "alternate_product_code": "BSL_Model_2"},' +
                         '{"product_code": "BSL_Model_1", "alternate_product_code": "BSL_Model_2"}]}';

        // Set up mock REST request
        RestRequest request = new RestRequest();
        request.requestBody = Blob.valueOf(jsonReqBody);
        RestContext.request = request;

        // Call the API method
        Test.startTest();
        list<SAPCaptureAlternatePartAPIResWrapper> responseWrapper = SAPCaptureAlternatePartAPI.captureAlternatePart();
        Test.stopTest();

        // Verify response
        System.assertEquals('Success', responseWrapper[0].result, 'Result should be success');
    }
    @isTest
	static void testCaptureAlternatePart_Exception() {
    // Create a mock request body with invalid JSON format to trigger an exception
	String jsonReqBody = '{"alternate_parts": [' +
                         '[{"product_code": 1234, "alternate_product_code": "BSL_Model_2"},' +
                         '{"product_code": "BSL_Model_1", "alternate_product_code": "BSL_Model_2"}]]}';
    // Set up mock REST request
    RestRequest request = new RestRequest();
    request.requestBody = Blob.valueOf(jsonReqBody);
    RestContext.request = request;

    // Call the API method
    Test.startTest();
    List<SAPCaptureAlternatePartAPIResWrapper> responseWrapper = SAPCaptureAlternatePartAPI.captureAlternatePart();
    Test.stopTest();

  

    // Additional assertions on the error response can be added based on the expected behavior
}

}