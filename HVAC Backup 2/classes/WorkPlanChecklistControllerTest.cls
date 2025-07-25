@IsTest
private class WorkPlanChecklistControllerTest {

    @TestSetup
    static void setupTestData() {
        // List of trigger setting names to disable
        List<String> triggerObjectNames = new List<String>{
            'AllTriggers', 'TR022_WorkOrder_AfterInsert', 'WorkOrderTrigger', 'CaseTrigger', 'AccountBefore', 'AccountTrigger', 'TR022_WorkOrder_AfterUpdate', 'TR022_WorkOrder_BeforeInsert', 'TR022_WorkOrder_BeforeUpdate'
        };

        // Create and insert Trigger_Setting__c records with IsActive__c set to false to disable triggers
        List<Trigger_Setting__c> triggerSettings = new List<Trigger_Setting__c>();
        for (String objectString : triggerObjectNames) {
            Trigger_Setting__c triggerSetting = new Trigger_Setting__c(Name = objectString, IsActive__c = false);
            triggerSettings.add(triggerSetting);
        }
        insert triggerSettings;

        // Create a test Account
        Account testAccount = new Account(Name = 'Test Account',Is_Active__c=false);
        insert testAccount;

        // Create a test Case linked to the Account
        Case testCase = new Case(
            AccountId = testAccount.Id,
            Subject = 'Test Case for Work Order'
        );
        insert testCase;

        // Create a test WorkOrder linked to the Case
        WorkOrder testWorkOrder = new WorkOrder(
            CaseId = testCase.Id,
            Subject = 'Test Work Order',
            Ticket_Number_Read_Only__c = 'TICKET123'
        );
        insert testWorkOrder;

        // Create test WorkPlans linked to the WorkOrder
        List<WorkPlan> workPlans = new List<WorkPlan>{
            new WorkPlan(Name = 'Work Plan 1', WorkOrderId = testWorkOrder.Id),
            new WorkPlan(Name = 'Work Plan 2', WorkOrderId = testWorkOrder.Id)
        };
        insert workPlans;

        // Create test WorkSteps linked to the WorkPlans
        List<WorkStep> workSteps = new List<WorkStep>{
            new WorkStep(Name = 'Work Step 1', Input_Value__c = 'Input Value 1', WorkPlanId = workPlans[0].Id),
            new WorkStep(Name = 'Work Step 2', Input_Value__c = 'Input Value 2', WorkPlanId = workPlans[0].Id),
            new WorkStep(Name = 'Work Step 3', Input_Value__c = 'Input Value 3', WorkPlanId = workPlans[1].Id)
        };
        insert workSteps;

        // Re-enable triggers after test setup
        for (Trigger_Setting__c triggerSetting : triggerSettings) {
            triggerSetting.IsActive__c = true;
        }
        update triggerSettings;
    }

    @IsTest
    static void testWorkPlanChecklistController() {
        // List of trigger setting names to disable
        List<String> triggerObjectNames = new List<String>{
            'AllTriggers', 'TR022_WorkOrder_AfterInsert', 'WorkOrderTrigger', 'CaseTrigger', 'AccountBefore', 'AccountTrigger', 'TR022_WorkOrder_AfterUpdate', 'TR022_WorkOrder_BeforeInsert', 'TR022_WorkOrder_BeforeUpdate'
        };

        // Create and insert Trigger_Setting__c records with IsActive__c set to false to disable triggers
        List<Trigger_Setting__c> triggerSettings = new List<Trigger_Setting__c>();
        for (String objectString : triggerObjectNames) {
            Trigger_Setting__c triggerSetting = new Trigger_Setting__c(Name = objectString, IsActive__c = false);
            triggerSettings.add(triggerSetting);
        }
        insert triggerSettings;

        try {
            // Query the test WorkOrder created in @TestSetup
            WorkOrder testWorkOrder = [SELECT Id FROM WorkOrder LIMIT 1];

            // Set up the page parameters with the WorkOrder ID
            ApexPages.currentPage().getParameters().put('id', testWorkOrder.Id);

            // Initialize the controller
            Test.startTest();
            WorkPlanChecklistController controller = new WorkPlanChecklistController();
            Test.stopTest();

            // Assertions to verify that the controller retrieves and organizes data correctly
            System.assertNotEquals(null, controller.workOrder, 'The workOrder should not be null');
            System.assertEquals(testWorkOrder.Id, controller.workOrder.Id, 'The retrieved workOrder ID should match the test WorkOrder ID');

            System.assertNotEquals(null, controller.workPlans, 'The workPlans list should not be null');
            System.assertEquals(2, controller.workPlans.size(), 'The workPlans list should contain 2 work plans');

            System.assertNotEquals(null, controller.checklistItemsByWorkPlan, 'The checklistItemsByWorkPlan map should not be null');
            System.assertEquals(2, controller.checklistItemsByWorkPlan.size(), 'The checklistItemsByWorkPlan map should have entries for 2 work plans');

            // Check that each WorkPlan has the correct WorkSteps
            for (WorkPlan wp : controller.workPlans) {
                List<WorkStep> steps = controller.checklistItemsByWorkPlan.get(wp.Id);
                System.assertNotEquals(null, steps, 'Each work plan should have associated work steps');
                
                if (wp.Name == 'Work Plan 1') {
                    System.assertEquals(2, steps.size(), 'Work Plan 1 should have 2 work steps');
                } else if (wp.Name == 'Work Plan 2') {
                    System.assertEquals(1, steps.size(), 'Work Plan 2 should have 1 work step');
                }
            }
        } finally {
            // Re-enable triggers after the test method
            for (Trigger_Setting__c triggerSetting : triggerSettings) {
                triggerSetting.IsActive__c = true;
            }
            update triggerSettings;
        }
    }
}