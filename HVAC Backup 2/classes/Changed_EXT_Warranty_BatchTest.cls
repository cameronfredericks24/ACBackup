@isTest
public class Changed_EXT_Warranty_BatchTest {
    @isTest(seeAllData=true)
    static void testBatchExecutionWithOrgData() {
        // Step 1: Query data to simulate the start method
        
        String query = 'SELECT Id, Component_ID__c,Asset.Account.Id, WarrantyTerm.WarrantyTermName, StartDate, EndDate, ' +
        'LastModifiedBy.Name, LastModifiedDate, CreatedBy.Name, CreatedDate ' +
        'FROM AssetWarranty ' +
        'WHERE WarrantyTerm.WarrantyType = \'Extended\' ' + 
        'limit 200';

        List<AssetWarranty> assetWarrantyRecords = Database.query(query);
        //System.assert(!assetWarrantyRecords.isEmpty(), 'No valid AssetWarranty records found.');

        // Step 2: Create the batch instance
        String folderName='landing';
        Date customStartDate = null; // March 20, 2025
        Date customEndDate = null; 
        Changed_EXT_Warranty_Batch batch = new Changed_EXT_Warranty_Batch(false,'',customStartDate,customEndDate,folderName);
        batch.isTestContext = true; 

        // Step 3: Simulate batch execution
        Test.startTest();
        Integer batchSize = 200; // Simulating batch size
        Integer totalRecords = assetWarrantyRecords.size();
        Database.BatchableContext context = new MockBatchableContext();
        for (Integer i = 0; i < totalRecords; i += batchSize) {
            // Extract a sublist representing one batch scope
            List<AssetWarranty> scope = new List<AssetWarranty>();
            for (Integer j = i; j < Math.min(i + batchSize, totalRecords); j++) {
                scope.add(assetWarrantyRecords[j]);
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