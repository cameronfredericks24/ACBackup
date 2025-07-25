@isTest
public class ServiceAppointmentSelectorTest {
    
    @testSetup
    static void setupTestData() {
        // Disable triggers during setup using try-finally block
        try {
            AccountTriggerHandler.TriggerDisabled = true;
            ContactTriggerHandler.TriggerDisabled = true; // Disable Contact trigger
            WorkOrderTriggerHandler.TriggerDisabled = true;
            ServiceAppointmentTriggerHandler.TriggerDisabled = true; // Disable ServiceAppointment trigger
            
            
            // Create an Account
            Account account = new Account(Name = 'Test Account', Is_Active__c = false);
            insert account;
            
            // Create CP (Contact) records
            Contact cp1 = new Contact(FirstName = 'CP1', LastName = 'Test', AccountId = account.Id);
            Contact cp2 = new Contact(FirstName = 'CP2', LastName = 'Test', AccountId = account.Id);
            insert new List<Contact> { cp1, cp2 };
                
                // Create WorkOrders linked to Account records instead of Contact records
                WorkOrder wo1 = new WorkOrder(Status = 'New', AccountId = account.Id, CP__c = account.Id, OwnerId = UserInfo.getUserId());
            WorkOrder wo2 = new WorkOrder(Status = 'In Progress', AccountId = account.Id, CP__c = account.Id, OwnerId = UserInfo.getUserId());
            insert new List<WorkOrder> { wo1, wo2 };
                
                
                // Create ServiceAppointment records linked to WorkOrders with both start and end times
                DateTime startTime = DateTime.now().addDays(1);
            DateTime endTime = startTime.addHours(2); // Example: End time set 2 hours after start time
            
            ServiceAppointment sa1 = new ServiceAppointment(
                ParentRecordId = wo1.Id,
                SchedStartTime = startTime,
                SchedEndTime = endTime // Add end time
            );
            
            ServiceAppointment sa2 = new ServiceAppointment(
                ParentRecordId = wo2.Id,
                SchedStartTime = startTime,
                SchedEndTime = endTime // Add end time
            );
            
            insert new List<ServiceAppointment> { sa1, sa2 };
                
                
                } finally {
                    // Reset trigger flags after setup
                    AccountTriggerHandler.TriggerDisabled = false;
                    ContactTriggerHandler.TriggerDisabled = false; // Reset Contact trigger
                    WorkOrderTriggerHandler.TriggerDisabled = false;
                    ServiceAppointmentTriggerHandler.TriggerDisabled = false; // Reset ServiceAppointment trigger
                    
                }
    }
    
    @isTest
    static void testGetServiceAppointmentCount() {
        try {
            ServiceAppointmentTriggerHandler.TriggerDisabled = true; // Disable ServiceAppointment trigger during test
            
            Set<Date> preferredSlotsList = new Set<Date> { Date.today().addDays(1) };
                
                // Use Account IDs instead of Contact IDs
                Set<Id> cpIds = new Set<Id>();
            List<Account> accounts = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
            for (Account account : accounts) {
                cpIds.add(account.Id);
            }
            
            System.debug('Cp ids=========='+cpIds);
            System.debug('preferredSlotsList=========='+preferredSlotsList);
            
            Test.startTest();
            Map<String, Integer> result = ServiceAppointmentSelector.getServiceAppointmentCount(preferredSlotsList, cpIds);
            Test.stopTest();
            
       
        } finally {
            ServiceAppointmentTriggerHandler.TriggerDisabled = false; // Reset after test
        }
    }
    
    
    @isTest
    static void testGetServiceAppointment() {
        try {
            ServiceAppointmentTriggerHandler.TriggerDisabled = true; // Disable ServiceAppointment trigger during test
            
            Id serviceAppointmentId = [SELECT Id FROM ServiceAppointment LIMIT 1].Id;
            
            Test.startTest();
            List<ServiceAppointment> appointments = ServiceAppointmentSelector.getServiceAppointment(serviceAppointmentId);
            Test.stopTest();
            
           
        } finally {
            ServiceAppointmentTriggerHandler.TriggerDisabled = false; // Reset after test
        }
    }
    
    @isTest
    static void testGetServiceAppt() {
        try {
            WorkOrderTriggerHandler.TriggerDisabled = true; // Disable WorkOrder trigger during test
            ServiceAppointmentTriggerHandler.TriggerDisabled = true; // Disable ServiceAppointment trigger during test
            
            Id workOrderId = [SELECT Id FROM WorkOrder LIMIT 1].Id;
            
            Test.startTest();
            List<ServiceAppointment> serviceAppointments = ServiceAppointmentSelector.getServiceAppt(workOrderId);
            Test.stopTest();
            
            System.assertNotEquals(null, serviceAppointments, 'Expected non-null result');
            System.assert(serviceAppointments.size() > 0, 'Expected at least one ServiceAppointment');
        } finally {
            WorkOrderTriggerHandler.TriggerDisabled = false; // Reset after test
            ServiceAppointmentTriggerHandler.TriggerDisabled = false; // Reset after test
        }
    }
}