@isTest
public class ChangeWorkOrderRecordTypeControllerTest {

    @testSetup
    static void setupTestData() {
        // Disable triggers during setup
        WorkOrderTriggerHandler.TriggerDisabled = true;
        try {
            // Query existing Record Types for WorkOrder
            RecordType breakdownRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'WorkOrder' AND DeveloperName = 'Breakdown' LIMIT 1];
            RecordType regularServiceRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'WorkOrder' AND DeveloperName = 'Regular_Service' LIMIT 1];

            // Create test Work Types
            WorkType breakdownWorkType = new WorkType(
                Name = 'Breakdown',
                DurationType = 'Hours',
                EstimatedDuration = 1
            );
            WorkType regularServiceWorkType = new WorkType(
                Name = 'Regular Service',
                DurationType = 'Hours',
                EstimatedDuration = 1
            );
            insert new List<WorkType> { breakdownWorkType, regularServiceWorkType };

            // Create a test WorkOrder with 'Breakdown' Record Type
            WorkOrder testWorkOrder = new WorkOrder(
                Subject = 'Test Work Order',
                RecordTypeId = breakdownRecordType.Id,
                WorkTypeId = breakdownWorkType.Id,
                Status = 'Open'
            );
            insert testWorkOrder;

        } finally {
            // Re-enable triggers after setup
            WorkOrderTriggerHandler.TriggerDisabled = false;
        }
    }

    @isTest
    static void testGetRecordTypeName() {
        // Disable WorkOrder triggers for this test
        WorkOrderTriggerHandler.TriggerDisabled = true;
        try {
            // Retrieve the test WorkOrder
            WorkOrder testWorkOrder = [SELECT Id FROM WorkOrder WHERE Subject = 'Test Work Order' LIMIT 1];

            // Call the getRecordTypeName method
            Test.startTest();
            String recordTypeName = ChangeWorkOrderRecordTypeController.getRecordTypeName(testWorkOrder.Id);
            Test.stopTest();

            // Verify the result
            System.assertEquals('Breakdown', recordTypeName, 'The initial RecordType should be Breakdown');
        } finally {
            // Re-enable triggers after the test
            WorkOrderTriggerHandler.TriggerDisabled = false;
        }
    }

    @isTest
    static void testToggleRecordType() {
        // Disable WorkOrder triggers for this test
        WorkOrderTriggerHandler.TriggerDisabled = true;
        try {
            // Retrieve the test WorkOrder
            WorkOrder testWorkOrder = [SELECT Id, RecordType.DeveloperName, WorkType.Name FROM WorkOrder WHERE Subject = 'Test Work Order' LIMIT 1];

            // Verify initial state
            System.assertEquals('Breakdown', testWorkOrder.RecordType.DeveloperName, 'The initial RecordType should be Breakdown');
            System.assertEquals('Breakdown', testWorkOrder.WorkType.Name, 'The initial WorkType should be Breakdown');

            // Perform both toggles within a single startTest/stopTest block
            Test.startTest();
            // First toggle to 'Regular_Service'
            ChangeWorkOrderRecordTypeController.toggleRecordType(testWorkOrder.Id);

            // Retrieve the updated WorkOrder
            WorkOrder updatedWorkOrder = [SELECT Id, RecordType.DeveloperName, WorkType.Name FROM WorkOrder WHERE Id = :testWorkOrder.Id];

            // Second toggle back to 'Breakdown'
            ChangeWorkOrderRecordTypeController.toggleRecordType(updatedWorkOrder.Id);

            // Retrieve the reverted WorkOrder
            WorkOrder revertedWorkOrder = [SELECT Id, RecordType.DeveloperName, WorkType.Name FROM WorkOrder WHERE Id = :updatedWorkOrder.Id];
            Test.stopTest();

            // Verify the first toggle to 'Regular_Service'
            System.assertEquals('Regular_Service', updatedWorkOrder.RecordType.DeveloperName, 'The RecordType should be Regular_Service after first toggle');
            System.assertEquals('Regular Service', updatedWorkOrder.WorkType.Name, 'The WorkType should be Regular Service after first toggle');

            // Verify the second toggle back to 'Breakdown'
            System.assertEquals('Breakdown', revertedWorkOrder.RecordType.DeveloperName, 'The RecordType should be Breakdown after toggling back');
            System.assertEquals('Breakdown', revertedWorkOrder.WorkType.Name, 'The WorkType should be Breakdown after toggling back');
        } finally {
            // Re-enable triggers after the test
            WorkOrderTriggerHandler.TriggerDisabled = false;
        }
    }
}