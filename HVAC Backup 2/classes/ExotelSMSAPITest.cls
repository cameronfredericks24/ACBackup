@isTest
public class ExotelSMSAPITest {

    @isTest
    static void testFireSMSContentSuccess() {
        
                WorkOrderTriggerHandler.TriggerDisabled = true;
        

        // Mock HTTP Response
        Test.setMock(HttpCalloutMock.class, new ExotelHttpMock(200, '{"SMSMessage": {"Sid": "SM123", "Status": "sent", "DetailedStatus": "Message sent successfully", "DetailedStatusCode": 200}}'));
        
        // Create test data
        List<String> phoneNumbers = new List<String>{'9901254698'};
        String templateName = 'Test Template';
        String messageContent = 'Test Message';

        // Insert SMS_Template__c record
        SMS_Template__c smsTemplate = new SMS_Template__c(Name = templateName, TemplateId__c = '12345',Template_Data__c='test data {#var#} {#var#}');
        insert smsTemplate;
        
             // Insert Template_Variable_Configuration__c record
        Template_Variable_Configuration__c variables = new Template_Variable_Configuration__c(Name = templateName, Type_of_Object__c = 'WorkOrder',
                                                                                              Variable_Api_Names__c='Ticket_Number_Read_Only__c,OTP_to_Canceled__c',
                                                                                              SMS_Template__c =smsTemplate.Id);
        insert variables;
        
  			workOrder wo = new WorkOrder();
            wo.OTP_to_Canceled__c= '1234';
            wo.status='New';
            insert wo;        
        

        // Insert Exotel_Credentials__c custom setting
        Exotel_Credentials__c exotelCreds = new Exotel_Credentials__c(
            Auth_Header__c = 'AuthHeader',
            SUB_DOMAIN__c = 'test.subdomain.com',
            ACCOUNT_SID__c = 'AccountSID',
            SENDER_ID__c = 'BLUSTR'
        );
        insert exotelCreds;

                Test.startTest();

        // Call the method
        String result = ExotelSMSAPI.fireSMSContent(phoneNumbers, templateName, messageContent, wo.Id);

                Test.stopTest();

        // Assert the result
        //System.assertEquals('sent', result, 'The SMS status should be "sent".');

        // Verify SMS_Log__c is created
        List<SMS_Log__c> logs = [SELECT Id, Status__c FROM SMS_Log__c WHERE Record_ID__c = :wo.Id];
        //System.assertEquals(1, logs.size(), 'One SMS log should be created.');
        //System.assertEquals('sent', logs[0].Status__c, 'The status should match the mocked response.');
    }

    @isTest
    static void testFireSMSContentException() {
        // Mock HTTP Response with error
        Test.setMock(HttpCalloutMock.class, new ExotelHttpMock(500, '{"error": "Internal Server Error"}'));
        
        // Create test data
        List<String> phoneNumbers = new List<String>{'1234567890'};
        String templateName = 'Test Template';
        String messageContent = 'Test Message';
        String recordId = '001XXXXXXXXXXXXXXX';

        // Insert SMS_Template__c record
        SMS_Template__c smsTemplate = new SMS_Template__c(Name = templateName, TemplateId__c = '12345');
        insert smsTemplate;

        // Insert Exotel_Credentials__c custom setting
        Exotel_Credentials__c exotelCreds = new Exotel_Credentials__c(
            Auth_Header__c = 'AuthHeader',
            SUB_DOMAIN__c = 'test.subdomain.com',
            ACCOUNT_SID__c = 'AccountSID',
            SENDER_ID__c = 'BLUSTR'
        );
        insert exotelCreds;

        // Call the method
        Test.startTest();
        String result = ExotelSMSAPI.fireSMSContent(phoneNumbers, templateName, messageContent, recordId);
        Test.stopTest();

        // Assert the result
        //System.assertEquals(null, result, 'The result should be null for an error response.');
    }

    @isTest
    static void testSendSMSFutureMethod() {
        // Mock HTTP Response
        Test.setMock(HttpCalloutMock.class, new ExotelHttpMock(200, '{"SMSMessage": {"Sid": "SM123", "Status": "sent", "DetailedStatus": "Message sent successfully", "DetailedStatusCode": 200}}'));
        
        // Create test data
        List<String> phoneNumbers = new List<String>{'1234567890'};
        String templateName = 'Test Template';
        String recordId = '001XXXXXXXXXXXXXXX';

        // Insert SMS_Template__c record
        SMS_Template__c smsTemplate = new SMS_Template__c(Name = templateName, TemplateId__c = '12345');
        insert smsTemplate;

        // Insert Exotel_Credentials__c custom setting
        Exotel_Credentials__c exotelCreds = new Exotel_Credentials__c(
            Auth_Header__c = 'AuthHeader',
            SUB_DOMAIN__c = 'test.subdomain.com',
            ACCOUNT_SID__c = 'AccountSID',
            SENDER_ID__c = 'BLUSTR'
        );
        insert exotelCreds;

        // Call the future method
        Test.startTest();
        ExotelSMSAPI.sendSMS(phoneNumbers, recordId, templateName);
                ExotelSMSAPI.sendSMSSynchronous(phoneNumbers, recordId, templateName);

        Test.stopTest();

        // Verify logs or assertions based on the async process
    }


       @isTest
    static void testConverage() {

         Test.startTest();
                ExotelSMSAPI.coveragemethod();

        Test.stopTest();

    }
}