@isTest
private class BulkProductTransferControllerTest {

    // Utility method to create a test Product2 record and return its Id
    private static Id createTestProduct() {
        Product2 product = new Product2(Name = 'Test Product');
         System.runAs(Testdatafactory.createByPassUser()){
            insert product;
                Testdatafactory.createStdPriceBookEntry(product.Id);
            }
        System.debug('Created Product2 with Id: ' + product.Id);
        return product.Id;
    }

    // Utility method to prepare mock input data
    private static List<Map<String, String>> prepareMockInputData(Id productId1, Id productId2) {
        List<Map<String, String>> mockData = new List<Map<String, String>>();

        Map<String, String> record1 = new Map<String, String>{
            'Product2Id' => productId1,
            'QuantitySent' => '100',
            'Description' => 'Test transfer for product 1'
        };
        mockData.add(record1);

        Map<String, String> record2 = new Map<String, String>{
            'Product2Id' => productId2,
            'QuantitySent' => '200',
            'Description' => 'Test transfer for product 2'
        };
        mockData.add(record2);

        System.debug('Mock Input Data: ' + mockData);
        return mockData;
    }

    // Utility method to prepare field mappings
    private static Map<String, String> prepareFieldMappings() {
        Map<String, String> fieldMappings = new Map<String, String>{
            'Product2Id' => 'Product2Id',
            'QuantitySent' => 'QuantitySent',
            'Description' => 'Description'
        };
        System.debug('Field Mappings: ' + fieldMappings);
        return fieldMappings;
    }

    // Utility method to prepare data type mappings
    private static Map<String, String> prepareDataTypeMappings() {
        Map<String, String> dataTypeMappings = new Map<String, String>{
            'Product2Id' => 'Text',
            'QuantitySent' => 'Decimal',
            'Description' => 'Text'
        };
        System.debug('Data Type Mappings: ' + dataTypeMappings);
        return dataTypeMappings;
    }

    // Test method for successful product transfer creation
    @isTest
    static void testProductTransferCreation_Success() {
        TestDataFactory.disableTriggers(); // Disable triggers
        try {
            System.debug('Starting testProductTransferCreation_Success');
            BulkProductTransferController.isTest = true;
            Id productId1 = createTestProduct();
            Id productId2 = createTestProduct();

            List<Map<String, String>> mockData = prepareMockInputData(productId1, productId2);
            Map<String, String> fieldMappings = prepareFieldMappings();
            Map<String, String> dataTypeMappings = prepareDataTypeMappings();

            Test.startTest();
            List<GenericFileUploaderController.fileResultWrapper> results = BulkProductTransferController.ProductTransferCreationMethod(
                mockData, fieldMappings, dataTypeMappings
            );
            Test.stopTest();

            System.debug('Results from ProductTransferCreationMethod: ' + results);

            // Assertions
            System.assertEquals(2, results.size(), 'There should be two results');
            for (GenericFileUploaderController.fileResultWrapper result : results) {
                System.debug('Result ID: ' + result.Id);
                System.assertNotEquals(null, result.Id, 'The result ID should not be null');
            }

            // Verify Bulk_Upload_Job__c record creation
            List<Bulk_Upload_Job__c> bulkJobs = [SELECT Id, Total_Record_Count__c, Success_Record_Count__c FROM Bulk_Upload_Job__c];
            System.assertEquals(1, bulkJobs.size(), 'One Bulk_Upload_Job__c record should be created');
            System.assertEquals(2, bulkJobs[0].Total_Record_Count__c, 'Total_Record_Count__c should be 2');
            System.assertEquals(2, bulkJobs[0].Success_Record_Count__c, 'Success_Record_Count__c should be 2');
        } finally {
            TestDataFactory.enableTriggers(); // Re-enable triggers
        }
    }

    // Test method for handling failure cases
    @isTest
    static void testProductTransferCreation_Failure() {
        TestDataFactory.disableTriggers(); // Disable triggers
        try {
            System.debug('Starting testProductTransferCreation_Failure');
            BulkProductTransferController.isTest = true;
            Id productId1 = createTestProduct();
            Id productId2 = createTestProduct();

            List<Map<String, String>> mockData = prepareMockInputData(productId1, productId2);
            Map<String, String> fieldMappings = prepareFieldMappings();
            Map<String, String> dataTypeMappings = prepareDataTypeMappings();

            // Introduce a validation error in the data
            mockData[0].put('QuantitySent', '0.0'); // Non-numeric value for QuantitySent
            System.debug('Modified Mock Data with Invalid QuantitySent: ' + mockData);

            Test.startTest();
            List<GenericFileUploaderController.fileResultWrapper> results = BulkProductTransferController.ProductTransferCreationMethod(
                mockData, fieldMappings, dataTypeMappings
            );
            Test.stopTest();

            System.debug('Results from ProductTransferCreationMethod (Failure Test): ' + results);

            // Assertions
            System.assertEquals(2, results.size(), 'There should be two results');

            // Verify Bulk_Upload_Job__c record counts
            List<Bulk_Upload_Job__c> bulkJobs = [SELECT Id, Success_Record_Count__c, Failed_Record_Count__c FROM Bulk_Upload_Job__c];
            System.assertEquals(1, bulkJobs.size(), 'One Bulk_Upload_Job__c record should be created');
            
        } finally {
            TestDataFactory.enableTriggers(); // Re-enable triggers
        }
    }

    // Test method for verifying the call method
    @isTest
    static void testCallMethod() {
        TestDataFactory.disableTriggers(); // Disable triggers
        try {
            System.debug('Starting testCallMethod');
            BulkProductTransferController controller = new BulkProductTransferController();
            Id productId1 = createTestProduct();
            Id productId2 = createTestProduct();

            Map<String, Object> args = new Map<String, Object>{
                'ListMap' => prepareMockInputData(productId1, productId2),
                'mapOfAPiAndFields' => prepareFieldMappings(),
                'mapOfAPiAndDataType' => prepareDataTypeMappings()
            };

            Test.startTest();
            List<GenericFileUploaderController.fileResultWrapper> results = controller.call('ProductTransferCreationMethod', args);
            Test.stopTest();

            System.debug('Results from call method: ' + results);

            // Assertions
            System.assertEquals(2, results.size(), 'There should be two results from the call method');
            for (GenericFileUploaderController.fileResultWrapper result : results) {
                System.debug('Result ID: ' + result.Id);
                System.assertNotEquals(null, result.Id, 'The result ID should not be null');
            }
        } finally {
            TestDataFactory.enableTriggers(); // Re-enable triggers
        }
    }
}