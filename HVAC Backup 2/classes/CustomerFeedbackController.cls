public without sharing class CustomerFeedbackController {


    
        /*
@Author : Mamta S
@CreatedDate : 8 March 2024
@Desciption : Capture Feedback from Customer
*/
    @AuraEnabled
    public static String saveFeedback(String recordId, String customerComments, Integer technicianRating,String customerName,String base64Data, String fileName) {
        try {
            Set<Id> setOfServiceApptIds = new Set<Id>();

            WorkOrder wo = [SELECT Id, Is_Customer_Feedback_Captured__c,Rating__c, Technician_s_Remarks__c FROM WorkOrder WHERE Id = :recordId LIMIT 1];


            List<ServiceAppointment> serviceApptList = [SELECT Id,ParentRecordId,Service_Resource__r.Id  FROM ServiceAppointment WHERE ParentRecordId=:recordId LIMIT 1];


            ServiceAppointment saToUpdate = serviceApptList[0];

            System.debug('customerName : ' + customerName);


            // Fetch ServiceAppointment details
            //List<ServiceAppointment> serviceApptList = ServiceAppointmentSelector.getServiceAppt(recordId);
            System.debug('ServiceAppointment List: ' + serviceApptList);
            for (ServiceAppointment sa : serviceApptList) {
                setOfServiceApptIds.add(sa.Id);
            }
            System.debug('setOfServiceApptIds : ' + setOfServiceApptIds);

            List<AssignedResource> assigResoucelist = New List<AssignedResource>();
            if(!setOfServiceApptIds.isEmpty()){
                // Fetch Assigned Resource 
               assigResoucelist = AssignedResourceSelector.getAssignedResources(setOfServiceApptIds);
            }
            
            List<Customer_Feedback__c> custFeedbackToInsert = new List<Customer_Feedback__c>();
            for (ServiceAppointment servAppt : serviceApptList) {
                Customer_Feedback__c feedback = new Customer_Feedback__c();
                if (!assigResoucelist.isEmpty()) {
                    feedback.Service_Resource1__c = assigResoucelist[0].ServiceResourceId;
                }
                feedback.Service_Appointment__c = servAppt.Id;
                feedback.Please_Rate_Technician__c = technicianRating;
                custFeedbackToInsert.add(feedback);
            }

            //insert the customer signature

                   // Decode the base64 string
        Blob fileBlob = EncodingUtil.base64Decode(base64Data);

        // Create a new ContentVersion
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = fileName;
        contentVersion.PathOnClient = fileName;
        contentVersion.VersionData = fileBlob;
        insert contentVersion;

        // Query the ContentDocumentId from the newly created ContentVersion
        ContentVersion newContentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1];

        // Create a new ContentDocumentLink
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.ContentDocumentId = newContentVersion.ContentDocumentId;
        contentDocumentLink.LinkedEntityId = recordId;
        contentDocumentLink.ShareType = 'V';  // Viewer
        contentDocumentLink.Visibility = 'AllUsers';
        insert contentDocumentLink;

        
        //store the image link in SA
        saToUpdate.Image_Link__c = '/sfc/servlet.shepherd/version/download/' + newContentVersion.Id;

        //ServiceAppointmentTriggerHandler.TriggerDisabled = true;
        //update saToUpdate;

        //add image link to work order
        wo.Image_Link__c = '/sfc/servlet.shepherd/version/download/' + newContentVersion.Id;

			 System.debug('Customer');
            // Insert the records
            if (!custFeedbackToInsert.isEmpty()) {
                Insert custFeedbackToInsert;
                wo.Is_Customer_Feedback_Captured__c = true;
                wo.Rating__c = String.valueOf(technicianRating);
                if(customerName != null){
                wo.Customer_Employee_Code__c = customerName;
                }
                System.debug('Customer Feedback' + wo);
                wo.Technician_s_Remarks__c = customerComments;
                update wo;
                System.debug('Customer Feedback Records Created');
                return 'success';
                
            }  else {
                return 'No records';
            }
        } catch (Exception e) {
            // Log the exception
            System.debug('Error saving feedback: ' + e.getMessage());
            System.debug('Errorline: ' + e.getLineNumber());

               Exception_Log__c exceptionLog = new Exception_Log__c();
            exceptionLog.Error_Message__c = e.getMessage();
            exceptionLog.Line_Number__c = string.valueOf(e.getLineNumber());
            exceptionLog.Logged_By__c = UserInfo.getUserId();
            exceptionLog.Source__c = 'CustomerFeedbackController-saveFeedback';
            
            insert exceptionLog;

                return null;

        }
    }

    @AuraEnabled
    public static string getCustomerType(Id recordId){
        try {

            if(recordId!=null){

                list<WorkOrder> woLst = [SELECT ID,AccountId,Account.RecordType.Name FROM WorkOrder WHERE Id=:recordId LIMIT 1];

                if(woLst!=null){

                    return woLst[0].Account.RecordType.Name;
    
                }
                else{
                    return null;
                }
            }
            else{
                return null;
            }
     

         
            
        } catch (Exception e) {
            System.debug('exception - ' + e.getMessage());
            return null;
        }
    }

    @AuraEnabled
    public static string getTechnicianDetails(){
        try {

            User currentUser = [SELECT Id, Name,Employee_Number__c FROM User WHERE Id = :UserInfo.getUserId()];
            return JSON.serialize(currentUser);
            
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}