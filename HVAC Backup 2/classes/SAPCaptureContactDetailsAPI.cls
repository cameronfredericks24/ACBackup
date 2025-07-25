@RestResource(urlMapping='/sap/capturecontact')
global class SAPCaptureContactDetailsAPI {
    @HttpPost
    global static List<SAPCaptureContactAPIResponseWrapper> captureContactDetails() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        List<SAPCaptureContactAPIResponseWrapper> responseWrappers = new List<SAPCaptureContactAPIResponseWrapper>();

        // Retrieve the JSON request body from the incoming request.
        String reqBody = req.requestBody.toString();

        SAPCaptureContactAPIRequestWrapper reqWrap;

        try {
            reqWrap = (SAPCaptureContactAPIRequestWrapper)JSON.deserialize(reqBody, SAPCaptureContactAPIRequestWrapper.class);

            Map<String, Account> accountMap = new Map<String, Account>();
            Map<String, Contact> contactMap = new Map<String, Contact>();

            List<String> sapCustomerIds = new List<String>();
            List<String> sapContactIds = new List<String>();

            for (SAPCaptureContactAPIRequestWrapper.contactDetail jsonReqBody : reqWrap.contactDetails) {
                if (jsonReqBody.SAP_Customer_Unique_Id != null) {
                    sapCustomerIds.add(jsonReqBody.SAP_Customer_Unique_Id);
                }
                if (jsonReqBody.SAP_Contact_Unique_Id != null) {
                    sapContactIds.add(jsonReqBody.SAP_Contact_Unique_Id);
                }
            }
            system.debug('sapCustomerIds - '+ sapCustomerIds);

            // Fetch Accounts by SAP Customer IDs
            if (!sapCustomerIds.isEmpty()) {
                List<Account> accounts = [SELECT Id, SAP_Customer_ID__c FROM Account WHERE SAP_Customer_ID__c IN :sapCustomerIds];
                system.debug('accounts - '+ accounts);
                for (Account acc : accounts) {
                    accountMap.put(acc.SAP_Customer_ID__c, acc); // Assuming SAP_Customer_ID__c is a unique field on Account
                }
            }

                // Fetch Contacts by SAP Contact IDs
                if (!sapContactIds.isEmpty()) {
                    List<Contact> contacts = [SELECT Id, SAP_Contact_Id__c FROM Contact WHERE SAP_Contact_Id__c IN :sapContactIds];
                    system.debug('contacts - '+ contacts);
                    for (Contact con : contacts) {
                        contactMap.put(con.SAP_Contact_Id__c, con); // Assuming SAP_Customer_ID__c is a unique field on Account
                    }
                }

            List<Contact> contactsToInsert = new List<Contact>();
            List<Contact> contactsToUpdate = new List<Contact>();
            List<SAPCaptureContactAPIRequestWrapper.contactDetail> contactsForInsert = new List<SAPCaptureContactAPIRequestWrapper.contactDetail>();
            List<SAPCaptureContactAPIRequestWrapper.contactDetail> contactsForUpdate = new List<SAPCaptureContactAPIRequestWrapper.contactDetail>();

            for (SAPCaptureContactAPIRequestWrapper.contactDetail jsonReqBody : reqWrap.contactDetails) {
                Contact newContact = IntegrationAPIHelper.createContactFromSAP(jsonReqBody, accountMap, contactMap);

                // if (newContact != null) {
                //     if (jsonReqBody.Flag == 'Insert') {

                //         contactsToInsert.add(newContact);
                //         contactsForInsert.add(jsonReqBody);
                //     } else if (jsonReqBody.Flag == 'Update') {
                //         List<Contact> existingContacts = ContactSelector.getContactBySAPId(jsonReqBody.SAP_Contact_Unique_Id);
                //         if (!existingContacts.isEmpty()) {
                //             newContact.Id = existingContacts[0].Id;
                //             contactsToUpdate.add(newContact);
                //             contactsForUpdate.add(jsonReqBody);
                //         } else {
                //             SAPCaptureContactAPIResponseWrapper resp = new SAPCaptureContactAPIResponseWrapper();
                //             resp.result = IntegrationAPIHelper.RESP_FAILURE_RESULT;
                //             resp.message = 'No Contact found for update';
                //             resp.SF_Contact_Id = null;
                //             responseWrappers.add(resp);
                //         }
                //     }
                // }


                if (newContact != null) {
                    if (newContact.Id == null) {

                        system.debug('con to insert - '+newContact);
                        contactsToInsert.add(newContact);
                        contactsForInsert.add(jsonReqBody);
                    } else {
                        system.debug('con to update - '+newContact);

                            contactsToUpdate.add(newContact);
                            contactsForUpdate.add(jsonReqBody);
                        
                    }
                }


            }
            system.debug('contactsToUpdate - '+ contactsToUpdate);
            system.debug('contactsToInsert - '+ contactsToInsert);



            handleInsertDML(contactsToInsert, responseWrappers);
            handleUpdateDML(contactsToUpdate, responseWrappers);

        } catch (Exception e) {
            SAPCaptureContactAPIResponseWrapper resp = new SAPCaptureContactAPIResponseWrapper();
            resp.result = IntegrationAPIHelper.RESP_FAILURE_RESULT;
            resp.message = 'Unable to capture Contact details: ' + e.getMessage();
            resp.SF_Contact_Id = null;
            responseWrappers.add(resp);
        }

        return responseWrappers;
    }

    private static void handleInsertDML(List<Contact> contactsToInsert, List<SAPCaptureContactAPIResponseWrapper> responseWrappers) {
        if (!contactsToInsert.isEmpty()) {
            Database.SaveResult[] insertResults = Database.insert(contactsToInsert, false);
            
            List<Id> contactIds = new List<Id>();
            for (Database.SaveResult result : insertResults) {
                if (result.isSuccess()) {
                    contactIds.add(result.getId());
                }
            }
            
            Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, SF_Contact_Unique_Id__c FROM Contact WHERE Id IN :contactIds]);

            system.debug('contactMap - '+ contactMap);
    
            for (Integer i = 0; i < insertResults.size(); i++) {
                SAPCaptureContactAPIResponseWrapper resp = new SAPCaptureContactAPIResponseWrapper();
                if (insertResults[i].isSuccess()) {
                    Contact insertedContact = contactMap.get(insertResults[i].getId());
                    resp.result = IntegrationAPIHelper.RESP_SUCCESS_RESULT;
                    resp.message = 'Contact Details captured successfully';
                    resp.SF_Contact_Id = insertedContact.SF_Contact_Unique_Id__c;
                } else {
                    resp.result = IntegrationAPIHelper.RESP_FAILURE_RESULT;
                    resp.message = 'Unable to capture Contact details: ' + insertResults[i].getErrors()[0].getMessage();
                    resp.SF_Contact_Id = null;
                }
                responseWrappers.add(resp);
            }
        }
    }
    
    private static void handleUpdateDML(List<Contact> contactsToUpdate, List<SAPCaptureContactAPIResponseWrapper> responseWrappers) {
        if (!contactsToUpdate.isEmpty()) {
            Database.SaveResult[] updateResults = Database.update(contactsToUpdate, false);
            
            List<Id> contactIds = new List<Id>();
            for (Database.SaveResult result : updateResults) {
                if (result.isSuccess()) {
                    contactIds.add(result.getId());
                }
            }
            
            Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, SF_Contact_Unique_Id__c FROM Contact WHERE Id IN :contactIds]);
    
            system.debug('contactMap updated- '+ contactMap);

            for (Integer i = 0; i < updateResults.size(); i++) {
                SAPCaptureContactAPIResponseWrapper resp = new SAPCaptureContactAPIResponseWrapper();
                if (updateResults[i].isSuccess()) {
                    Contact updatedContact = contactMap.get(updateResults[i].getId());
                    resp.result = IntegrationAPIHelper.RESP_SUCCESS_RESULT;
                    resp.message = 'Contact Details updated successfully';
                    resp.SF_Contact_Id = updatedContact.SF_Contact_Unique_Id__c;
                } else {
                    resp.result = IntegrationAPIHelper.RESP_FAILURE_RESULT;
                    resp.message = 'Unable to update Contact details: ' + updateResults[i].getErrors()[0].getMessage();
                    resp.SF_Contact_Id = null;
                }
                responseWrappers.add(resp);
            }
        }
    }
    
}