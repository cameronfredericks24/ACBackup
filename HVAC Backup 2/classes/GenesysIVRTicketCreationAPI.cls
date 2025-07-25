/**
 * @Author : Sumukha N S
    @CreatedDate : 8th Feb 2024
    @Description : 
    @Last Modified By : Sumukha N S

 */@RestResource(urlMapping='/ivr/createticket')
global with sharing class GenesysIVRTicketCreationAPI {

    @HttpPost
    global static GenesysIVRTicketCreationAPIRespWrapper createTicket() {
      
        String ticketNumber;
        
          // Obtain the incoming REST request and response objects.
          RestRequest req = RestContext.request;
          RestResponse res = RestContext.response;
  
          // Initialize the response wrapper for the API.
          GenesysIVRTicketCreationAPIRespWrapper resp = new GenesysIVRTicketCreationAPIRespWrapper();

        try {
            // Retrieve the JSON request body from the incoming request.
            String jsonReqBody = req.requestBody.toString();
            
            // Attempt to create a new case based on the provided JSON request body.
            ticketNumber = GenesysIVRCaseCreationClass.createNewCase(jsonReqBody);

            

            // Check if case creation was successful.
            if(ticketNumber != null){
                resp.result = IntegrationAPIHelper.RESP_SUCCESS_RESULT;
                resp.message = IntegrationAPIHelper.RESP_SUCCESS_RESPONSE;
                resp.ticket_number = ticketNumber;
            }
            else {
                // Case creation failed.
                resp.result = IntegrationAPIHelper.RESP_FAILURE_RESULT;
                resp.message = IntegrationAPIHelper.RESP_FAILURE_RESPONSE + ticketNumber;
                resp.ticket_number = null;
            }
        } 
        catch (Exception e) {
            // Exception occurred during case creation.

            //insert exception log in the system
            //Exception_Log__c log = new Exception_Log__c();

            //log.Cause__c = String.valueOf(e.getCause());
            //log.Line_Number__c = String.valueOf(e.getLineNumber());
            //log.Logged_At__c = System.now();
            //log.Logged_By__c = UserInfo.getUserId();
            //log.Stack_Trace__c = e.getStackTraceString();
            //log.Error_Message__c = e.getTypeName() + e.getMessage();
            // insert log;

            //send the failed response
            resp.result = IntegrationAPIHelper.RESP_FAILURE_RESULT;
            resp.message = IntegrationAPIHelper.RESP_FAILURE_RESPONSE + '-' +e.getTypeName() + e.getMessage(); 
            resp.ticket_number = ticketNumber;

            System.debug('Exception' + e.getTypeName() + e.getMessage());

        }

        // Return the response wrapper.
        return resp;   

    }
}