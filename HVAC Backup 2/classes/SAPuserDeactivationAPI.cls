@RestResource(urlMapping='/sap/userdeactivate')
global class SAPuserDeactivationAPI {
    
    @HttpPost
    global static List<SAPuserDeactivationAPIResponseWrapper> deactivateUsers() {
        
        // Obtain the incoming REST request and response objects.
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        system.debug('initial req - ' + req);
        
        // Initialize the response wrapper list for the API.
        List<SAPuserDeactivationAPIResponseWrapper> responses = new List<SAPuserDeactivationAPIResponseWrapper>();
        
        try {
            // Retrieve the JSON request body from the incoming request.
            String jsonReqBody = req.requestBody.toString();
            
            // Deserialize the JSON request body into a list of request wrappers.
            List<SAPuserDeactivationAPIRequestWrapper> reqWraps = (List<SAPuserDeactivationAPIRequestWrapper>) JSON.deserialize(jsonReqBody, List<SAPuserDeactivationAPIRequestWrapper>.class);
            
            // Gather all users to be updated in a list.
            List<User> usersToUpdate = new List<User>();
            Map<String, Boolean> employeeStatusMap = new Map<String, Boolean>();
            Set<String> providedEmployeeNumbers = new Set<String>();
            Map<Id, String> userIdToEmployeeNumberMap = new Map<Id, String>();


            for (SAPuserDeactivationAPIRequestWrapper reqWrap : reqWraps) {
                Boolean isActive = reqWrap.isActive.equalsIgnoreCase('Yes');
                employeeStatusMap.put(reqWrap.employee_number, isActive);
                providedEmployeeNumbers.add(reqWrap.employee_number);
            }

            // Query Salesforce Users based on the employee numbers.
            List<User> users = UserSelector.getUserFromEmployeeNumber(providedEmployeeNumbers);
            Set<String> foundEmployeeNumbers = new Set<String>();
            for (User u : users) {
                foundEmployeeNumbers.add(u.Employee_Number__c);
                userIdToEmployeeNumberMap.put(u.Id, u.Employee_Number__c);

            }

            if (users != null && !users.isEmpty()) {
                for (User u : users) {
                    // Check if the Salesforce User status matches the received isActive status.
                    Boolean isActive = employeeStatusMap.get(u.Employee_Number__c);
                    if (isActive != null && u.IsActive != isActive) {
                        // If statuses don't match, update Salesforce User status.
                        u.IsActive = isActive;
                        usersToUpdate.add(u);
                    }
                }

                if (!usersToUpdate.isEmpty()) {
                    // Perform a bulk update with partial success handling.
                    Database.SaveResult[] saveResults = Database.update(usersToUpdate, false);

                    for (Database.SaveResult saveResult : saveResults) {
                        SAPuserDeactivationAPIResponseWrapper resp = new SAPuserDeactivationAPIResponseWrapper();
                        String employeeNumber = userIdToEmployeeNumberMap.get(saveResult.getId());
            
                        if (saveResult.isSuccess()) {
                            resp.result = 'Success';
                            resp.message = 'User : ' + employeeNumber + ' status updated successfully.';
                        } else {
                            for (Database.Error error : saveResult.getErrors()) {
                                resp.result = 'Failure';
                                resp.message = 'User with employee number ' + employeeNumber + ' - ' + error.getMessage();
                            }
                        }
                        responses.add(resp);
                    }
                } else {
                    SAPuserDeactivationAPIResponseWrapper resp = new SAPuserDeactivationAPIResponseWrapper();
                    resp.result = 'Info';
                    resp.message = 'No users required updates.';
                    responses.add(resp);
                }
            }

            // Handle users not found in Salesforce
            Set<String> notFoundEmployeeNumbers = providedEmployeeNumbers.clone();
            notFoundEmployeeNumbers.removeAll(foundEmployeeNumbers);
            for (String employeeNumber : notFoundEmployeeNumbers) {
                SAPuserDeactivationAPIResponseWrapper resp = new SAPuserDeactivationAPIResponseWrapper();
                resp.result = 'failure';
                resp.message = 'No user found with employee number ' + employeeNumber + ' in Salesforce.';
                responses.add(resp);
            }

        } catch (Exception e) {
            system.debug('exception--' + e.getMessage());
            SAPuserDeactivationAPIResponseWrapper resp = new SAPuserDeactivationAPIResponseWrapper();
            resp.result = 'failure';
            resp.message = 'An error occurred while processing the request.';
            responses.add(resp);
        }
        return responses;
    }
}