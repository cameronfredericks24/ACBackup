@isTest
public class Changed_Part_CSV_Export_BatchTest {
    @isTest(seeAllData=true)
    static void testBatchExecutionWithOrgData() {
        Id productRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Spare').getRecordTypeId();
        String query ='SELECT ProductCode,Name,Dealer_Price__c, CreatedBy.Name, ' +
                'LastModifiedBy.Name, CreatedDate, LastModifiedDate ' +
                'FROM Product2 ' +
                'WHERE RecordTypeId = \'' + productRecordTypeId + '\' ' +
                'limit 300';
        
        List<Product2> productRequestRecords = Database.query(query);
        //System.assert(!productRequestRecords.isEmpty(), 'No valid ProductRequest records found.');

        // Step 2: Create the batch instance
        String folderName='landing';
        Date customStartDate = null; // March 20, 2025
        Date customEndDate = null; 
        Changed_Part_CSV_Export_Batch batch = new Changed_Part_CSV_Export_Batch(false,'',customStartDate,customEndDate,folderName);
        batch.isTestContext = true; 

        // Step 3: Simulate batch execution
        Test.startTest();
        Integer batchSize = 200; // Simulating batch size
        Integer totalRecords = productRequestRecords.size();
        Database.BatchableContext context = new MockBatchableContext();
        for (Integer i = 0; i < totalRecords; i += batchSize) {
            // Extract a sublist representing one batch scope
            List<Product2> scope = new List<Product2>();
            for (Integer j = i; j < Math.min(i + batchSize, totalRecords); j++) {
                scope.add(productRequestRecords[j]);
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