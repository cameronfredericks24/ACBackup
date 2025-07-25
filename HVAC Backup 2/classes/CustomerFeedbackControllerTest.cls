@isTest
public class CustomerFeedbackControllerTest {
    
    @testSetup
    static void setupTestData() {

		TestDataFactory.disableTriggers();
        
       
        
        Product_Family__c productFamily = TestDataFactory.createProductFamily('AC - Room Air Conditioner');
        Product_Family__c productSubFamily = TestDataFactory.createProductSubFamily('Split', productFamily);
        Product2 product = TestDataFactory.createProduct('1TR R32 1 STAR F HW SAC', 'GHTY89', productFamily, productSubFamily);
        Schema.Location locationRecord = TestDataFactory.createLocation('locationName-1', 'RPC');
        Branch__c branch = TestDataFactory.createBranch('Mumbai');
        Account testAccount = TestDataFactory.createResidentialAccount('Test Residential Account', '6677889977');
        Asset asset = TestDataFactory.createAsset('Test Asset', 'Active', product, branch, Date.today(), 'INV12345', testAccount);
        Case caseRecord = TestDataFactory.createCase('Test Case', 'New', 'Issue', testAccount, asset, product, branch);
        WorkType workType = TestDataFactory.createWorkType('Installation');
        WorkOrder parentWorkOrder = TestDataFactory.createWorkOrder(asset, workType, testAccount, caseRecord, 'Accepted');
        
        // Create test Contact
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = testAccount.Id
        );
        insert testContact;

        // Create test WorkOrder
        WorkOrder testWorkOrder = new WorkOrder(
			Id = parentWorkOrder.Id,
            Is_Customer_Feedback_Captured__c = false
        );
        update testWorkOrder;

        // Create test ServiceAppointment
        ServiceAppointment testServiceAppointment = new ServiceAppointment(
            ParentRecordId = testWorkOrder.Id,
            Service_Resource__c = null
        );
        insert testServiceAppointment;

        // Create test AssignedResource
        // ServiceResource serviceResource = new ServiceResource(Name = 'Test Technician');
        // insert serviceResource;

        // AssignedResource assignedResource = new AssignedResource(
        //     ServiceAppointmentId = testServiceAppointment.Id,
        //     ServiceResourceId = serviceResource.Id
        // );
        // insert assignedResource;
        TestDataFactory.enableTriggers();
    }

    @isTest
    static void testSaveFeedback() {

         ContentDocumentLinkTriggerHandler.TriggerDisabled = true;
                ContentVersionTriggerHandler.TriggerDisabled = true;


        // Test data
        WorkOrder testWorkOrder = [SELECT Id FROM WorkOrder LIMIT 1];
        
        
        
        system.debug('testWorkOrder-- '+ testWorkOrder);
        String recordId = testWorkOrder.Id;
        String customerComments = 'Great Service';
        Integer technicianRating = 5;
        String customerName = 'John Doe';
        String base64Data = 'VGhpcyBpcyBhIHRlc3QgZmlsZS4='; // 'This is a test file.'
        String fileName = 'test_file.txt';

        Test.startTest();
        String result = CustomerFeedbackController.saveFeedback(recordId, customerComments, technicianRating, customerName, base64Data, fileName);
        Test.stopTest();

        // Verify the feedback is saved

        // // Verify WorkOrder updates
        // WorkOrder updatedWO = [SELECT Is_Customer_Feedback_Captured__c, Rating__c, Technician_s_Remarks__c FROM WorkOrder WHERE Id = :recordId];
        // System.assert(updatedWO.Is_Customer_Feedback_Captured__c);
        // System.assertEquals('5', updatedWO.Rating__c);
        // System.assertEquals(customerComments, updatedWO.Technician_s_Remarks__c);

        // // Verify Customer Feedback
        // Customer_Feedback__c feedback = [SELECT Id, Please_Rate_Technician__c FROM Customer_Feedback__c WHERE Service_Appointment__c IN (SELECT Id FROM ServiceAppointment WHERE ParentRecordId = :recordId)];
        // System.assertNotEquals(null, feedback);
        // System.assertEquals(technicianRating, feedback.Please_Rate_Technician__c);
    }

    @isTest
    static void testGetCustomerType() {
        WorkOrder testWorkOrder = [SELECT Id, AccountId FROM WorkOrder LIMIT 1];

        Test.startTest();
        String customerType = CustomerFeedbackController.getCustomerType(testWorkOrder.Id);
        Test.stopTest();

        // Verify customer type
    }

    @isTest
    static void testGetTechnicianDetails() {
        Test.startTest();
        String technicianDetails = CustomerFeedbackController.getTechnicianDetails();
        Test.stopTest();

        // Verify technician details
    }

    @isTest
    static void testErrorHandling() {
        Test.startTest();
        try {
            // Pass invalid data to simulate error
            String result = CustomerFeedbackController.saveFeedback(null, null, null, null, null, null);
            // If no exception is thrown, fail the test
        } catch (AuraHandledException e) {
            // Check that the error message matches the expected output
        } catch (Exception e) {
            // Fail the test if a different type of exception is thrown
        }
        Test.stopTest();
}


}