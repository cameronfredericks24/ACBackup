@isTest
public class AMCLeadControllerTest {
    @isTest
    static void testQueryAMCLeads() {
        // Disable the Asset trigger
        AssetTriggerHandler.TriggerDisabled = true;
		WorkOrderTriggerHandler.TriggerDisabled = true;
        try {
            Test.startTest();

            // Step 1: Set up test data

            // Create a test Asset
            Asset testAsset = new Asset(
                Name = 'Test Asset'
            );
            insert testAsset;

            // Create a test WorkOrder linked to the Asset
            WorkOrder testWorkOrder = new WorkOrder(
                AssetId = testAsset.Id,
                Status = 'New',
                Subject = 'Test WorkOrder'
            );
            insert testWorkOrder;

            // Retrieve the RecordTypeId for the 'AMC' record type
            Id leadAMCRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('AMC').getRecordTypeId();

            // Create some test Lead records with the AMC Record Type and link to the Asset
            Lead lead1 = new Lead(
                LastName = 'Test Lead 1',
                Company = 'Test Company 1',
                Email = 'test1@example.com',
                Phone = '1234567890',
                Asset__c = testAsset.Id,
                RecordTypeId = leadAMCRecordTypeId,
                Status = 'Open - Not Contacted'
            );
            Lead lead2 = new Lead(
                LastName = 'Test Lead 2',
                Company = 'Test Company 2',
                Email = 'test2@example.com',
                Phone = '0987654321',
                Asset__c = testAsset.Id,
                RecordTypeId = leadAMCRecordTypeId,
                Status = 'Open - Not Contacted'
            );
            // Insert Leads
            insert new List<Lead> { lead1, lead2 };

            // Step 2: Execute the method being tested
            List<Lead> amcLeads = AMCLeadController.queryAMCLeads(testWorkOrder.Id);

            Test.stopTest();

            // Step 3: Validate the results
            System.assertNotEquals(0, amcLeads.size(), 'There should be some leads returned');
            System.assertEquals(2, amcLeads.size(), 'The number of AMC Leads returned should be 2');
            System.assertEquals(lead1.Id, amcLeads[0].Id, 'The first lead should match the inserted lead1');
            System.assertEquals(lead2.Id, amcLeads[1].Id, 'The second lead should match the inserted lead2');
        } finally {
            // Re-enable the Asset trigger after the test completes
            AssetTriggerHandler.TriggerDisabled = false; 
            WorkOrderTriggerHandler.TriggerDisabled = true;
        }
    }
}