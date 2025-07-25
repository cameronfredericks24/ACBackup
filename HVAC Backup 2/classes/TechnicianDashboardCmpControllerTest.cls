@IsTest
public class TechnicianDashboardCmpControllerTest {
    @TestSetup
    static void setupTestData() {
        TestDataFactory.disableTriggers();
        try {
            // Use provided test data setup
            Product_Family__c productFamily = TestDataFactory.createProductFamily('AC - Room Air Conditioner');
            Product_Family__c productSubFamily = TestDataFactory.createProductSubFamily('Split', productFamily);
            Product2 product = TestDataFactory.createProduct('1TR R32 1 STAR F HW SAC', 'GHTY89', productFamily, productSubFamily);
            Schema.Location locationRecord = TestDataFactory.createLocation('locationName-1', 'RPC');
            Branch__c branch = TestDataFactory.createBranch('Mumbai');
            Account account = TestDataFactory.createResidentialAccount('Test Residential Account', '6677889977');
            OperatingHours opHrs2 = TestDataFactory.createOperatingHour2('Blue Star Operating Hours');
            //Account channelPartnerAccount = TestDataFactory.createChannelPartner(opHrs2);
            //Contact portalContact = TestDataFactory.createContactCP('Jojo','KK', 'testjojo67@gmail.com', channelPartnerAccount.Id);
            //ServiceTerritory serviceTerritoryData = TestDataFactory.createServiceTrt(channelPartnerAccount, opHrs2);
            //User cpUser = TestDataFactory.createChannelPartnerUser('Jojo', 'KK', portalContact);
            // Assign the CP User to the Account
            String currentUserId = UserInfo.getUserId();
            //Account updateAccountCP = new Account();
           // updateAccountCP.Id = channelPartnerAccount.Id;
            //updateAccountCP.CP_User__c = currentUserId;
            //update updateAccountCP;
            Asset asset = TestDataFactory.createAsset('Test Asset', 'Active', product, branch, Date.today(), 'INV12345', account);
            Case caseRecord = TestDataFactory.createCase('Test Case', 'New', 'Issue', account, asset, product, branch);
            WorkType workType = TestDataFactory.createWorkType('Installation');
            WorkOrder serviceTicket = TestDataFactory.createWorkOrder(asset, workType, account, caseRecord, 'Accepted');
            ServiceAppointment serviceApp = TestDataFactory.createSA(serviceTicket, 'In Progress');
            Account technicianAccount = TestDataFactory.createChannelPartner(opHrs2);
            Contact technicianContact = TestDataFactory.createContactCP('Technician','Test', 'test67@gmail.com', technicianAccount.Id);
            ServiceTerritory serviceTerritoryData1 = TestDataFactory.createServiceTrt(technicianAccount, opHrs2);
            User technician = TestDataFactory.createTechnicianUser('Technician', 'Test', technicianContact);
            ServiceResource serviceRes = new ServiceResource(
            Name = 'Technician KK',
            IsActive = true,
            RelatedRecordId = currentUserId
            );
            insert serviceRes;
             ServiceAppointment updateServiceApp = new ServiceAppointment();
              updateServiceApp.Id = serviceApp.Id;
              updateServiceApp.FSSK__FSK_Assigned_Service_Resource__c = serviceRes.Id;
              updateServiceApp.OwnerId = serviceRes.RelatedRecordId;
              update updateServiceApp;
            Customer_Feedback__c customerFeedback = new Customer_Feedback__c(
                Please_Rate_Technician__c = 4,
                Service_Appointment__c = updateServiceApp.Id,
                Service_Resource1__c = serviceRes.Id
            );
            insert customerFeedback;
            Customer_Feedback__c customerFeedback2 = new Customer_Feedback__c(
                Please_Rate_Technician__c = 5,
                Service_Appointment__c = updateServiceApp.Id,
                Service_Resource1__c = serviceRes.Id
            );
            insert customerFeedback2;
        } finally {
            TestDataFactory.enableTriggers();
        }
    }
    @IsTest
    static void testGetWorkTypes() {
        TestDataFactory.disableTriggers();
        try {
            Test.startTest();
            List<String> workTypes = TechnicianDashboardCmpController.getWorkTypes();
            Test.stopTest();
         System.assert(workTypes.size() > 0, 'There should be at least one work type returned.');
        } finally {
            TestDataFactory.enableTriggers();
        }
    }
    @IsTest
    static void testGetWorkOrdersByType() {
        TestDataFactory.disableTriggers();
        try {
            String workTypeName = [SELECT Name FROM WorkType LIMIT 1].Name;
            WorkOrder wo = [Select Id, RecordType.Name  From WorkOrder LIMIT 1];
            String recordTypeName = wo.RecordType.Name;
             System.debug('recordTypeName in testGetWorkOrdersByType: ' + recordTypeName);
            System.debug('Work Type Name in testGetWorkOrdersByType: ' + workTypeName);
            Test.startTest();
            Map<String, Map<String, Integer>> workOrdersByType = TechnicianDashboardCmpController.getWorkOrdersByType(workTypeName);
            Test.stopTest();
            //System.assert(workOrdersByType.containsKey(workTypeName), 'Work orders should be grouped by work type.');
            Map<String, Integer> stats = workOrdersByType.get(workTypeName);
        } finally {
            TestDataFactory.enableTriggers();
        }
    }
    @IsTest
    static void testGetWorkOrdersByTimeFrame() {
        TestDataFactory.disableTriggers();
        try {
            Test.startTest();
            Map<String, Map<String, Integer>> workOrdersToday = TechnicianDashboardCmpController.getWorkOrdersByTimeFrame('Today');
            Map<String, Map<String, Integer>> workOrdersLastWeek = TechnicianDashboardCmpController.getWorkOrdersByTimeFrame('Last Week');
            Map<String, Map<String, Integer>> workOrdersLastMonth = TechnicianDashboardCmpController.getWorkOrdersByTimeFrame('Last Month');
            Map<String, Map<String, Integer>> workOrdersLast90Days = TechnicianDashboardCmpController.getWorkOrdersByTimeFrame('3 Months');
            Map<String, Map<String, Integer>> workOrdersLast180Days = TechnicianDashboardCmpController.getWorkOrdersByTimeFrame('6 Months');
            Map<String, Map<String, Integer>> workOrdersLastYear = TechnicianDashboardCmpController.getWorkOrdersByTimeFrame('Last 1 Year');
            Test.stopTest();
        } finally {
            TestDataFactory.enableTriggers();
        }
    }
    @IsTest
    static void testGetTotalWorkOrders() {
        TestDataFactory.disableTriggers();
        try {
            Test.startTest();
            Integer totalWorkOrders = TechnicianDashboardCmpController.getTotalWorkOrders();
            Test.stopTest();
           // System.assertEquals(5, totalWorkOrders, 'There should be 5 total work orders.');
        } finally {
            TestDataFactory.enableTriggers();
        }
    }
    @IsTest
    static void testGetTechnicianName() {
        TestDataFactory.disableTriggers();
        try {
            Test.startTest();
            String technicianName = TechnicianDashboardCmpController.getTechnicianName();
            Test.stopTest();
            //System.assertEquals('Test Technician', technicianName, 'Technician name should be "Test Technician".');
        } finally {
            TestDataFactory.enableTriggers();
        }
    }
    @IsTest
    static void testGetTechnicianRating() {
        TestDataFactory.disableTriggers();
        try {
            Test.startTest();
            Decimal technicianRating = TechnicianDashboardCmpController.getTechnicianRating();
            Test.stopTest();
            //System.assert(technicianRating > 0, 'Technician should have a rating greater than 0.');
            //System.assertEquals(2.00, technicianRating, 'The average rating should be 2.00.');
        } finally {
            TestDataFactory.enableTriggers();
        }
    }
}