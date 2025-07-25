@isTest
public class Changed_ProductFamily_BatchTest {
    @isTest(seeAllData=true)
    static void testBatchExecutionWithOrgData() {
        // Step 1: Query data to simulate the start method
        Id recordTypeId = Schema.SObjectType.Product_Family__c.getRecordTypeInfosByName().get('Product Family').getRecordTypeId();
        String query = 'SELECT Code__c, Name, Is_Critical__c, Sales_Department_No__r.Department_Number__c, Sales_Department_No__c, Service_Department_No__r.Department_Number__c, Service_Department_No__c, LastModifiedDate FROM Product_Family__c WHERE RecordTypeId = :recordTypeId limit 200';
        
        List<Product_Family__c> productFamilyRecords = Database.query(query);
        //System.assert(!productFamilyRecords.isEmpty(), 'No valid Product Family records found.');

        // Step 2: Create the batch instance
        String folderName='landing';

        Changed_ProductFamily_Batch batch = new Changed_ProductFamily_Batch(false,'',folderName);
        batch.isTestContext = true; 

        // Step 3: Simulate batch execution
        Test.startTest();
        Integer batchSize = 200; // Simulating batch size
        Integer totalRecords = productFamilyRecords.size();
        Database.BatchableContext context = new MockBatchableContext();
        for (Integer i = 0; i < totalRecords; i += batchSize) {
            // Extract a sublist representing one batch scope
            List<Product_Family__c> scope = new List<Product_Family__c>();
            for (Integer j = i; j < Math.min(i + batchSize, totalRecords); j++) {
                scope.add(productFamilyRecords[j]);
            }
            batch.execute(context, scope);
        }
        Test.stopTest();


    }

    // Mock Batchable Context for Simulated Execution
    public class MockBatchableContext implements Database.BatchableContext {
        public String getJobId() {
            return '707xx0000FakeJobId'; // Fake Job ID for testing purposes
        }
        
        public Id getChildJobId() {
            return null; // Mock implementation, return null as no child jobs exist in this context
        }
    }
}