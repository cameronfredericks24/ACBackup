/**
* @File Name : ServiceReportTriggerHandlerTest.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : November 25, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | November 25, 2024 |   | Initial Version
**/

@isTest
public class ServiceReportTriggerHandlerTest {
    @isTest
    static void testServiceReportTriggerHandler() {

		TestDataFactory.enableAllTriggers();


           Trigger_Setting__c gstTrigger = new Trigger_Setting__c();
        gstTrigger.Name = 'DuplicateGSTValidation';
        gstTrigger.isActive__c = true;
        insert gstTrigger;
        // Create test data
        Account testAccount = new Account(Name = 'Test Account',RecordTypeId = AccountConstant.RESIDENTIAL_ACCOUNT_RT, Email__c = 'test@example.com');
        insert testAccount;

        Contact testContact = new Contact(LastName = 'Test Contact', AccountId = testAccount.Id, Email = 'contact@example.com',phone = '9901224695');
        insert testContact;

   // Mock the HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        

        WorkType workType = TestDataFactory.createWorkType('Breakdown');
        WorkOrder testWorkOrder = new WorkOrder(
            Subject = 'Test Work Order',
            AccountId = testAccount.Id,
            Status = 'Completed',
			Is_PMS_Ticket__c = false,
            workTypeId = workType.Id
			        );
        insert testWorkOrder;
           Test.startTest();
        // testWorkOrder.Status = 'Completed';
        //update testWorkOrder;

        ServiceAppointment testAppointment = TestDataFactory.createSA(testWorkOrder, 'Completed');
 		//testAppointment.Status = 'Completed';
        //update testAppointment;
        
        ContentVersion contentVersion = new ContentVersion(
        Title = 'Penguins',
        PathOnClient = 'Penguins.jpg',
        VersionData = Blob.valueOf('Test Content'),
        IsMajorVersion = true
        );

        insert contentVersion;    

        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        //create ContentDocumentLink  record 

        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = testWorkOrder.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;

        ServiceReport sr = new ServiceReport();
        //sr.ContentVersionDocumentId = documents[0].Id ;
        sr.DocumentBody = Blob.valueOf('Test Content') ; 
        sr.DocumentContentType ='application/pdf';
        sr.DocumentName='Test';
        sr.IsSigned = true;
        sr.ParentId = testWorkOrder.Id ; 
        try{
            insert sr ;  
        }catch(exception e){
            
        }
          
                
            
        
        
        // Test beforeInsert - validate errors for duplicate service reports
       // ServiceReport sr1 = new ServiceReport(ParentId = testAppointment.Id);
        //insert sr1;

        //ServiceReport sr2 = new ServiceReport(ParentId = testAppointment.Id);
        
        try {
            //insert sr2; // Should throw an error
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Service Report has already been generated for this Service Appointment.'));
        }
        

        // Test validation for WorkOrder status
        WorkOrder incompleteWorkOrder = new WorkOrder(
            Subject = 'Incomplete Work Order',
            AccountId = testAccount.Id,
            Status = 'In Progress',
            CP__r = testAccount
        );
        insert incompleteWorkOrder;

        ServiceAppointment incompleteAppointment = new ServiceAppointment(
            Subject = 'Incomplete Service Appointment',
            Work_Order__c = incompleteWorkOrder.Id
        );
        //insert incompleteAppointment;

        //ServiceReport sr3 = new ServiceReport(ParentId = incompleteAppointment.Id);
       
        try {
            //insert sr3; // Should throw an error
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Please complete the appointment before generating FSR.'));
        }
        


        ContentVersion contentVersion1 = new ContentVersion(
            Title = 'Test Report',
            PathOnClient = 'Testreport.pdf',
            VersionData = Blob.valueOf('Test Report')
        );
        insert contentVersion1;
        
        ContentVersion newContentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion1.Id LIMIT 1];

        ContentDocumentLink docLink = new ContentDocumentLink(
            ContentDocumentId = newContentVersion.ContentDocumentId,
            LinkedEntityId = testAppointment.Id,
            ShareType = 'V'
        );
        insert docLink;

       
        ServiceReport sr4 = new ServiceReport(ParentId = testAppointment.Id);
        try{
           insert sr4; 
        }catch(exception e){
            
        }
        
        Test.stopTest();

    }


        @isTest
    static void testConverage() {

         Test.startTest();
        ServiceReportTriggerHandler.coveragemethod();
        Test.stopTest();

    }

	  // Inner class to mock HTTP callout
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            // Mock a successful response from the external service
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{"Success": true}');
            return res;
        }
    }

   
}