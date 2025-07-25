@isTest
public class ChangedBusinessEntityContractsBatchTest {
    @isTest(seeAllData=true)
    static void testBatchExecutionWithOrgData() {
        // Step 1: Query data to simulate the start method
        Id commercialCustomerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Commercial Customer').getRecordTypeId();
        Id residentialCustomerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Residential Customer').getRecordTypeId();
        
        List<Account> accountRecords = [
            SELECT Id, Customer_Code__c, Salutation__c, SAP_Customer_Id__c,Customer_ID__c, Name, Phone, Primary_Phone_No__c, 
            Email__c, CreatedDate, LastModifiedDate, Gender__c, Age__pc, 
            (SELECT ERP_Id__c, Age__c, LastName, Email, FirstName, Title, GenderIdentity, LastModifiedDate 
             FROM Contacts WHERE Is_Primary__c = true ORDER BY LastModifiedDate DESC LIMIT 1)
            FROM Account 
            WHERE RecordTypeId IN (:commercialCustomerRecordTypeId, :residentialCustomerRecordTypeId) 
            limit 200
            
        ];
        
        //System.assert(!accountRecords.isEmpty(), 'No valid Account records found.');
        
        // Step 2: Create the batch instanc
        
String folderName='landing';
        Date customStartDate = null; // March 20, 2025
        Date customEndDate = null; 
        Changed_Business_Entity_Contracts_Batch batch = new Changed_Business_Entity_Contracts_Batch(false,'',customStartDate,customEndDate,folderName);
        batch.isTestContext = true; 
        
        // Step 3: Simulate batch execution
        Test.startTest();
        Integer batchSize = 200; // Simulating batch size
        Integer totalRecords = accountRecords.size();
        Database.BatchableContext context = new MockBatchableContext();
        for (Integer i = 0; i < totalRecords; i += batchSize) {
            // Extract a sublist representing one batch scope
            List<Account> scope = new List<Account>();
            for (Integer j = i; j < Math.min(i + batchSize, totalRecords); j++) {
                scope.add(accountRecords[j]);
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