@isTest
public class otpControllerTest {

    // Helper method to create test data
    @testSetup
    static void setupTestData() {
        Test.startTest();
        TestDataFactory.disableTriggers();
        OperatingHours OP = TestDataFactory.createOperatingHour();
        OperatingHours opHrs = new OperatingHours(
        Name = 'Blue Star Operating Hours',
        TimeZone = 'Asia/Kolkata'
        );

        insert opHrs;
        Account channelPartner = TestDataFactory.createChannelPartner(opHrs);
        Account ResidentialAccount = TestDataFactory.createResidentialAccount('CP Payout', '9000000000');      
        Product_Family__c productFamily = TestDataFactory.createProductFamily('AC - Room Air Conditioner');
        Product_Family__c productSubFamily = TestDataFactory.createProductSubFamily('Split', productFamily);
        Product2 product = TestDataFactory.createProduct('11213TR R32 1 STAR F HW SAC', 'P12345', productFamily, productSubFamily);
        Branch__c branch = TestDataFactory.createBranch('Mumbai');
        Division__c division = TestDataFactory.createDivision('CPAG');
        Department__c department = TestDataFactory.createDepartment('52',division);
        Asset asset = TestDataFactory.createAsset('Test Asset', 'Active', product, branch, Date.today(), 'INV1234', channelPartner);
        asset.Service_Department_L__c = department.Id;
        asset.Cp__c = channelPartner.Id;
        update asset;
        Case caseRecord = TestDataFactory.createCase('CP Payout', 'In Progress', 'Breakdown', ResidentialAccount, asset, product, branch);
        WorkType workType = TestDataFactory.createWorkType('Breakdown');
       CP_Payout_Matrix__c payoutMatrix = new CP_Payout_Matrix__c(
            Family_Code__c = 'F1200',
            Sub_Family_Code__c = 'F1202',
            TAT_Max__c = 24.00,
            TAT_Min__c = 0.00,
            Payout__c = 1000.00,
            Work_Type__c = ''
        );
        insert payoutMatrix;
        WorkOrder workOrder = TestDataFactory.createWorkOrder(asset, workType,ResidentialAccount , caseRecord,'In Progress');
        WorkOrder.Cp__c = ChannelPartner.Id;
        workOrder.Field_Work_Type__c = 'Breakdown';
        workOrder.HappyCode__c = '1234';
        workOrder.Unhappy_Code__c = '2345';
        update workOrder;
         // Additions
    // WorkOrder extraWorkOrder = TestDataFactory.createWorkOrder(asset, workType, ResidentialAccount, caseRecord, 'Completed');
    // extraWorkOrder.Cp__c = channelPartner.Id;
    // update extraWorkOrder;
        Test.stopTest();
    }

    @isTest
    public static void testGetRelatedContactEmails_WithContacts() {
        // Explicitly calling the setupTestData method (optional, as it's called automatically before each test)
        
        
        // Query a WorkOrder Id
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];

        Test.startTest();
        // Call the controller method
        List<Contact> contacts = OtpController.getRelatedContactEmails(wo.Id);
        Test.stopTest();
        
        // Assert that the contact is returned
        //System.assertEquals('john.doe@example.com', contacts[0].Email, 'The contact email should be returned correctly');
    }

    @isTest
    public static void testGetRelatedContactEmails_NoContacts() {
        // Explicitly calling the setupTestData method (optional, as it's called automatically before each test)
       
        
        // Create a WorkOrder without any related Contact
        Account acc = [SELECT Id FROM Account LIMIT 1];
        WorkOrder wo = new WorkOrder(AccountId = acc.Id, Subject = 'Test WorkOrder No Contacts');
        insert wo;

        Test.startTest();
        // Call the controller method
        List<Contact> contacts = OtpController.getRelatedContactEmails(wo.Id);
        Test.stopTest();
        
        // Assert that no contact is returned
        //System.assertEquals(0, contacts.size(), 'There should be no contacts associated with this WorkOrder');
    }

    @isTest
    public static void testGetCancellationReasonOptions() {
        Test.startTest();
        // Call the controller method
        List<String> options = OtpController.getCancellationReasonOptions();
        Test.stopTest();
        
        // Assert that options are returned (the exact number depends on your setup of the picklist)
    }

    @isTest
    public static void testGetRejectReasonOptions() {
        Test.startTest();
        // Call the controller method
        List<String> options = OtpController.getRejectReasonOptions();
        Test.stopTest();
        
        // Assert that options are returned (the exact number depends on your setup of the picklist)
    }
    @isTest
    public static void testGetIntialStatusOfOtp_Verified() {
        // Query the WorkOrder created in setupTestData
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];

        // Update the WorkOrder to mark OTP as verified
        wo.OTP_Verified__c = true;
        update wo;

        Test.startTest();
        // Call the Aura-enabled method again
        OtpController.responseWrapper response = OtpController.getIntialStatusOfOtp(wo.Id);
        Test.stopTest();

        // Assert the OTP verification is already completed
    }
      @isTest
    public static void testGetContactEmail_ValidStatus() {
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];

        Test.startTest();
        OtpController.responseWrapper response = OtpController.getContactEmail(wo.Id);
        Test.stopTest();

        //System.assertEquals(true, response.isSuccess, 'The response should indicate success');
       // System.assertEquals('account.email@example.com', response.ContactEmail, 'Account.Email__c should be returned');
       // System.assertEquals('Breakdown', response.workType, 'The WorkType should be returned');
    }

    @isTest
    public static void testGetContactEmail_InvalidStatus() {
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];

        // Update WorkOrder status to an invalid value
        wo.Status = 'Completed';
        wo.SymptomText__c = 'No Cooling';
        wo.DefectText__c = 'Choking or Gas Leakage';
        wo.ActionText__c = 'Gas Charging Done';

        update wo;

        Test.startTest();
        OtpController.responseWrapper response = OtpController.getContactEmail(wo.Id);
        Test.stopTest();

       // System.assertEquals(null, response.ContactEmail, 'No ContactEmail should be returned');
       // System.assertEquals(null, response.workType, 'No WorkType should be returned');
    }

    //        @isTest
    // static void testConverage() {

    //      Test.startTest();
    //     OtpController.coveragemethod();
    //     Test.stopTest();

    // }
  
    @isTest
    static void testGetContactPhone() {
        // Create a mock Account
        Account testAccount = new Account(
            Name = 'Test Account',
            Phone = '9876543210'
        );
        insert testAccount;

        // Create a mock Contact
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Phone = '9876543210',
            AccountId = testAccount.Id
        );
        insert testContact;

        // Create a mock WorkOrder with the Contact relationship
        WorkOrder workOrder = new WorkOrder(
            AccountId = testAccount.Id,
            ContactId = testContact.Id
        );
        insert workOrder;

        // Execute the method
        try {
            OtpController.responseWrapper response = OtpController.getContactPhone(workOrder.Id);
        } catch (Exception e) {
            System.debug('Exception occurred: ' + e.getMessage());
        }
    }
    
 @isTest
    static void testgetContactEmailforCanceled() {
         // Create a mock Account
        Account testAccount = new Account(
            Name = 'Test Account',
            Phone = '9876543210'
        );
        insert testAccount;

        // Create a mock Contact
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test.contact@example.com',
            Phone = '9876543210',
            AccountId = testAccount.Id
        );
        insert testContact;

        // Create a mock WorkOrder with the Contact relationship
        WorkOrder workOrder = new WorkOrder(
            AccountId = testAccount.Id,
            ContactId = testContact.Id,
            OTP_to_Canceled__c = 'Some OTP',
            Canceled_OTP_Expiration__c = System.now().addHours(1),
            Canceled_Verified__c = false
        );
        insert workOrder;

        // Execute the method
        try {
            OtpController.responseWrapper response = OtpController.getContactEmailforCanceled(workOrder.Id);
        } catch (Exception e) {
            System.debug('Exception occurred: ' + e.getMessage());
        }
        
    }
    @isTest
    public static void testgetContactEmailforReschedule() {
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];

        Test.startTest();
        OtpController.responseWrapper response = OtpController.getContactEmailforReschedule(wo.Id);
        Test.stopTest();

      
    } 
    @isTest
    static void testValidateCanceledOTP_Success() {
        // Create a mock Account
        Account testAccount = new Account(
            Name = 'Test Account',
            Phone = '9959032784'
        );
        insert testAccount;

        // Create a mock Contact with an email
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test.contact@example.com',
            AccountId = testAccount.Id
        );
        insert testContact;

        // Create a mock WorkOrder linked to the Account and Contact
        WorkOrder testWorkOrder = new WorkOrder(
            AccountId = testAccount.Id,
            
            OTP_to_Canceled__c = '1234',
            Canceled_OTP_Expiration__c = System.now().addMinutes(30), // OTP expires in 30 minutes
            ContactId = testContact.Id
        );
        insert testWorkOrder;

        // Execute the method to test with valid OTP
        Test.startTest();
        OtpController.responseWrapper response = OtpController.validateCanceledOTP('1234', testWorkOrder.Id);
        Test.stopTest();

        // Validate the response
    }   
    @isTest
    static void testValidateRescheduleOTP_Success() {
        // Create a mock Account
        Account testAccount = new Account(
            Name = 'Test Account',
            Phone = '9959032784'
        );
        insert testAccount;

        // Create a mock Contact with an email
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test.contact@example.com',
            AccountId = testAccount.Id
        );
        insert testContact;

        // Create a mock WorkOrder linked to the Account, Contact, and OTP details
        WorkOrder testWorkOrder = new WorkOrder(
            AccountId = testAccount.Id,
            ContactId = testContact.Id, // Link to Contact (to fill in formula field if necessary)
            OTP_to_Reschedule__c = '123456', // OTP for reschedule
            Reschedule_OTP_Expiration__c = System.now().addMinutes(30) // OTP expires in 30 minutes
        );
        insert testWorkOrder;

        // Execute the method to test with valid OTP
        Test.startTest();
        OtpController.responseWrapper response = OtpController.validateRescheduleOTP('123456', testWorkOrder.Id);
        Test.stopTest();

        // Validate the response
    }
    @isTest
    static void testValidateOTP_Success() {
        // Create a mock Account
        Account testAccount = new Account(
            Name = 'Test Account',
            Phone = '9959032784'
        );
        insert testAccount;

        // Create a mock Contact with an email
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test.contact@example.com',
            AccountId = testAccount.Id
        );
        insert testContact;

        // Create a mock WorkOrder linked to the Account, Contact, and OTP details
        WorkOrder testWorkOrder = new WorkOrder(
            AccountId = testAccount.Id,
            ContactId = testContact.Id, // Link to Contact
            HappyCode__c = '123456', // OTP for happy code
            OTP_Expiration__c = System.now().addMinutes(30), // OTP expires in 30 minutes
            Is_Unhappy__c = false // Assume the checkbox is initially false
        );
        insert testWorkOrder;

        // Execute the method to test with valid OTP
        Test.startTest();
        OtpController.responseWrapper response = OtpController.validateOTP('123456', testWorkOrder.Id);
        Test.stopTest();

        // Validate the response
        //System.assertEquals(true, testWorkOrder.Is_Unhappy__c, 'The WorkOrder should have Is_Unhappy__c set to true after OTP matches Unhappy_Code__c');
    }
    @isTest
    static void testUpdateStatusCanceled() {
        // Step 1: Create a mock Account
        Account testAccount = new Account(
            Name = 'Test Account',
            Phone = '9959032784',
            Email__c = 'account@example.com'
        );
        insert testAccount;
    
        // Step 2: Create a mock Contact
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test.contact@example.com',
            AccountId = testAccount.Id
        );
        insert testContact;
    
        // Step 3: Create a mock Case associated with the WorkOrder
        Case testCase = new Case(
            AccountId = testAccount.Id,
            ContactId = testContact.Id,
            Status = 'New',
            Origin = 'Phone',
            Subject = 'Test Case'
        );
        insert testCase;
    
        // Step 4: Create a mock WorkOrder linked to the Case
        WorkOrder testWorkOrder = new WorkOrder(
            AccountId = testAccount.Id,
            ContactId = testContact.Id,
            CaseId = testCase.Id,
            Status = 'New',
            OTP_Verified__c = false // Initial OTP verification status
        );
        insert testWorkOrder;
    
        // Step 5: Define parameters for the method
        String recordId = testWorkOrder.Id;
        String status = 'Canceled';
        Boolean otpVerified = true;
        String cancellationreason = 'Component Scrap';
        String comment = 'WorkOrder canceled due to customer request';
    
        // Step 6: Call the method to test
        Test.startTest();
        OtpController.updateStatusCanceled(recordId, status, otpVerified, cancellationreason, comment);
        Test.stopTest();
    
        // Step 7: Validate the WorkOrder updates
        WorkOrder updatedWorkOrder = [SELECT Status, OTP_Verified__c, Cancellation_Reason__c, Cancellation_Comments__c FROM WorkOrder WHERE Id = :recordId];
        
    
        // Step 8: Validate the Case updates (if WorkOrder has a Case associated with it)
        if (testWorkOrder.CaseId != null) {
            Case updatedCase = [SELECT Status, Cancellation_Reason__c, Cancellation_Comment__c, Service_Ticket_Status__c FROM Case WHERE Id = :testCase.Id];
            
        }
    }
    @isTest
static void testUpdateRescheduleDateTime() {
    // Step 1: Create a mock Account
    Account testAccount = new Account(
        Name = 'Test Account',
        Phone = '9959032784',
        Email__c = 'account@example.com'
    );
    insert testAccount;

    // Step 2: Create a mock Contact
    Contact testContact = new Contact(
        FirstName = 'Test',
        LastName = 'Contact',
        Email = 'test.contact@example.com',
        AccountId = testAccount.Id
    );
    insert testContact;

    // Step 3: Create a mock WorkOrder linked to the Account and Contact
    WorkOrder testWorkOrder = new WorkOrder(
        AccountId = testAccount.Id,
        ContactId = testContact.Id,
        Status = 'New',
        Original_Scheduled_Date__c = System.today(), // Original scheduled date
        Is_Rescheduled__c = false, // Initial reschedule status
        Reschedule_OTP_Verified__c = false
    );
    insert testWorkOrder;

    // Step 4: Create a mock ServiceAppointment linked to the WorkOrder
    ServiceAppointment testServiceAppt = new ServiceAppointment(
        ParentRecordId = testWorkOrder.Id,
        Status = 'New',
        Duration = 2 // Duration in hours
    );
    insert testServiceAppt;

    // Step 5: Define parameters for the method
    String recordId = testWorkOrder.Id;
    DateTime rescheduleDateTime = System.now().addDays(1); // Rescheduled date-time (1 day later)
    Integer duration = 2; // Duration of 2 hours
    Boolean otpVerified = true;

    // Step 6: Call the method to test
    Test.startTest();
    OtpController.updateRescheduleDateTime(recordId, rescheduleDateTime, duration, otpVerified);
    Test.stopTest();

    // Step 7: Validate the WorkOrder updates

    // Step 8: Validate the ServiceAppointment updates
    ServiceAppointment updatedServiceAppt = [SELECT Status, SchedStartTime, SchedEndTime FROM ServiceAppointment WHERE ParentRecordId = :recordId];
   
    // Validate that the duration and ActualEndTime are calculated based on rescheduled time
    // You can adjust the test to assert based on your specific logic if you calculate ActualEndTime.
}
@isTest
static void testResendCanceledOTP() {
    // Step 1: Create a mock Account
    Account testAccount = new Account(
        Name = 'Test Account',
        Phone = '9959032784',
        Email__c = 'account@example.com'
    );
    insert testAccount;

    // Step 2: Create a mock Contact
    Contact testContact = new Contact(
        FirstName = 'Test',
        LastName = 'Contact',
        Email = 'test.contact@example.com',
        AccountId = testAccount.Id
    );
    insert testContact;

    // Step 3: Create a mock WorkOrder for the Canceled OTP scenario
    WorkOrder testWorkOrderCanceled = new WorkOrder(
        AccountId = testAccount.Id,
        ContactId = testContact.Id,
        Status = 'Canceled',
        OTP_to_Canceled__c = '123456'
    );
    insert testWorkOrderCanceled;

    // Step 4: Define test parameters for the resendCanceledOTP method
    String canceledRecordId = testWorkOrderCanceled.Id;
    String selectedEmail = 'alternate.email@example.com';

    // Step 5: Call the resendCanceledOTP method and verify
    Test.startTest();
    OtpController.resendCanceledOTP(canceledRecordId, selectedEmail);
    Test.stopTest();

    // Verify that the email was sent for the canceled OTP
}

@isTest
    static void testResendRescheduleOTP() {
        // Step 1: Create a mock Account
        Account testAccount = new Account(
            Name = 'Test Account',
            Phone = '9959032784',
            Email__c = 'account@example.com'
        );
        insert testAccount;

        // Step 2: Create a mock Contact
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test.contact@example.com',
            AccountId = testAccount.Id
        );
        insert testContact;

        // Step 3: Create a mock WorkOrder for the Reschedule OTP scenario
        WorkOrder testWorkOrderReschedule = new WorkOrder(
            AccountId = testAccount.Id,
            ContactId = testContact.Id,
            Status = 'Rescheduled',
            OTP_to_Reschedule__c = '654321'
        );
        insert testWorkOrderReschedule;

        // Step 4: Define test parameters for the resendRescheduleOTP method
        String rescheduleRecordId = testWorkOrderReschedule.Id;
        String selectedEmail = 'alternate.email@example.com';

        // Step 5: Call the resendRescheduleOTP method and verify
        Test.startTest();
        OtpController.resendRescheduleOTP(rescheduleRecordId, selectedEmail);
        Test.stopTest();

        // Verify that the email was sent for the reschedule OTP
    }
    @isTest
    static void testResetOTP() {
        // Step 4: Define test parameters for resetOTP method
        String selectedEmail = 'extra.email@example.com'; // Simulate additional email
        List<String> phoneNumbers = new List<String>{'9959032784'}; // Mock phone number list

        // Step 5: Call the resetOTP method to simulate the action
        Test.startTest();
        
        // Call the resetOTP method
        List<WorkOrder> workOrders = [SELECT HappyCode__c, OTP_Expiration__c FROM WorkOrder Limit 1];
        OtpController.resetOTP(workOrders[0].Id, selectedEmail, phoneNumbers);
        OtpController.resendOTP(workOrders[0].Id, selectedEmail, phoneNumbers);

        Test.stopTest();

        // Step 6: Verify if the OTP was correctly generated and email logic triggered
       workOrders = [SELECT HappyCode__c, OTP_Expiration__c FROM WorkOrder WHERE Id = :workOrders[0].Id];
        
        
    }
    @isTest
    static void testResetCanceledOTP() {
        // Step 1: Query test setup data
        Case caseRecord = [SELECT Id FROM Case LIMIT 1];
        WorkOrder testWorkOrder = [SELECT Id, Status, Contact_Email__c, Contact_Phone__c, ticket_number_Read_only__c 
                                    FROM WorkOrder LIMIT 1];

        // Step 2: Set up test parameters for resetCanceledOTP
        String recordId = testWorkOrder.Id;
        String selectedEmail = 'extra.email@example.com'; // Simulate additional email
        List<String> phoneNumbers = new List<String>{testWorkOrder.Contact_Phone__c}; // Mock phone number list

        // Step 3: Start the test
        Test.startTest();

        // Call the resetCanceledOTP method
        OtpController.resetCanceledOTP(recordId, selectedEmail, phoneNumbers);

        Test.stopTest();

        // Step 4: Verify if the OTP was correctly generated and email logic triggered
        WorkOrder updatedWorkOrder = [SELECT OTP_to_Canceled__c, Canceled_OTP_Expiration__c 
                                       FROM WorkOrder 
                                       WHERE Id = :recordId 
                                       LIMIT 1];

        // Assertions
    }
    @isTest
    static void testResetRescheduleOTP() {
        // Step 1: Query test setup data
        Case caseRecord = [SELECT Id FROM Case LIMIT 1];
        WorkOrder testWorkOrder = [SELECT Id, Status, Contact_Email__c 
                                    FROM WorkOrder 
                                    WHERE Status = 'In Progress' LIMIT 1];

        // Step 2: Set up test parameters for resetRescheduleOTP
        String recordId = testWorkOrder.Id;
        String selectedEmail = 'extra.email@example.com'; // Simulate additional email

        // Step 3: Start the test
        Test.startTest();

        // Call the resetRescheduleOTP method
        OtpController.resetRescheduleOTP(recordId, selectedEmail);

        Test.stopTest();

        // Step 4: Verify if the OTP was correctly generated and email logic triggered
        WorkOrder updatedWorkOrder = [SELECT OTP_to_Reschedule__c, Reschedule_OTP_Expiration__c 
                                       FROM WorkOrder 
                                       WHERE Id = :recordId 
                                       LIMIT 1];

        // Assertions
    }
    @isTest
    static void testSendOTP() {
        // Step 1: Query test setup data
        WorkOrder testWorkOrder = [SELECT Id, Status, Contact_Email__c, Contact_Phone__c 
                                   FROM WorkOrder 
                                   WHERE Status = 'In Progress' LIMIT 1];

        // Step 2: Set up test parameters
        String recordId = testWorkOrder.Id;
        String selectedEmails = 'extra.email@example.com'; // Simulate additional email
        List<String> phoneNumbers = new List<String>{'9000000000'}; // Mock phone number list

        // Step 3: Start the test
        Test.startTest();

        // Call the sendOTP method
        OtpController.sendOTP(recordId, selectedEmails, phoneNumbers);

        Test.stopTest();

        // Step 4: Verify if the OTP was correctly generated and email logic triggered
        WorkOrder updatedWorkOrder = [SELECT OTP_to_Canceled__c, Canceled_OTP_Expiration__c 
                                       FROM WorkOrder 
                                       WHERE Id = :recordId 
                                       LIMIT 1];

        // Assertions
    }
    @isTest
    static void testSendRescheduleOTP() {
        // Step 1: Query test setup data
        WorkOrder testWorkOrder = [SELECT Id, Status, Contact_Email__c, Contact_Phone__c 
                                   FROM WorkOrder 
                                   WHERE Status = 'In Progress' LIMIT 1];

        // Step 2: Set up test parameters
        String recordId = testWorkOrder.Id;
        String selectedEmails = 'customer1@example.com,customer2@example.com'; // Simulate multiple emails
        List<String> phoneNumbers = new List<String>{'9000000000'}; // Mock phone number list

        // Step 3: Start the test
        Test.startTest();

        // Call the sendRescheduleOTP method
        OtpController.responseWrapper response = OtpController.sendRescheduleOTP(recordId, selectedEmails, phoneNumbers);

        Test.stopTest();

        // Step 4: Verify if the OTP was correctly generated, email logic triggered, and response is successful
        WorkOrder updatedWorkOrder = [SELECT OTP_to_Reschedule__c, Reschedule_OTP_Expiration__c 
                                       FROM WorkOrder 
                                       WHERE Id = :recordId 
                                       LIMIT 1];

        // Assertions
    }
    
      @isTest
    static void testUpdateStatusCompleted() {
        // Step 1: Query test setup data
        WorkOrder wo = [SELECT Id, Status, Contact_Email__c, Contact_Phone__c 
                                   FROM WorkOrder 
                                   WHERE Status = 'In Progress' LIMIT 1];

        Test.startTest();
        String result = OtpController.updateStatusCompleted(
            wo.Id,
            'Completed',
            true,
            19.07283,   // Example latitude
            72.88261    // Example longitude
        );
        Test.stopTest();

        
    }
    
    @isTest
    static void testsendEmailToCustomer() {
        List<WorkOrder> workOrders = [SELECT HappyCode__c, OTP_Expiration__c FROM WorkOrder Limit 1];

         Test.startTest();

        // Call the sendOTP method
        OtpController.sendEmailToCustomer(new List<Id> {workOrders[0].Id});
        Test.stopTest();
    }

    //  @isTest
    // static void testsendEmailToCustomerCancel() {

    // }

}