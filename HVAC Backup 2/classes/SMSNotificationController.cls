/*
@Author : Himanshi Verma
@CreatedDate : 26th Mar 2024
@Description : It is a controller class for SMSNotification LWC.
*/

public without sharing class  SMSNotificationController {
    @AuraEnabled(cacheable=true)
    public static List<SMS_Template__c> getSMSTemplates(Id recordId) {
        try {
            // Null check for recordId
            if (recordId == null) {
                return null;
            }
            // Retrieve object name
            Schema.DescribeSObjectResult objDescribe = recordId.getSObjectType().getDescribe();
            String objectName = objDescribe.getName();
            //  String query = 'SELECT Name, Template_Data__c, (SELECT Type_of_Object__c, Variable_Api_Names__c FROM Template_Variable_Configurations__r Where Type_of_Object__c =: objectName) FROM SMS_Template__c Where Manual_Trigger__c = TRUE';// this need to be used only commenting for now only
            //  String query = 'SELECT Name, Template_Data__c, (SELECT Type_of_Object__c, Variable_Api_Names__c FROM Template_Variable_Configurations__r) FROM SMS_Template__c';
             String query = 'SELECT Name, Template_Data__c, (SELECT Type_of_Object__c, Variable_Api_Names__c FROM Template_Variable_Configurations__r) FROM SMS_Template__c Where Manual_Trigger__c = TRUE';// this need to be used only commenting for now only
            List<SMS_Template__c> templates = Database.query(query);
            // Log query results
            // System.debug('Query results: ' + templates);
            List<SMS_Template__c> filteredTemplates = new List<SMS_Template__c>();
            for(SMS_Template__c template : templates) {
                if(template.Template_Variable_Configurations__r.size() > 0) {
                    filteredTemplates.add(template);
                }
            }
            if(!filteredTemplates.isEmpty()) {
                return filteredTemplates;
            } else {
                return null;
            }
        } catch (Exception e) {
            // Log error
            System.debug('Error in getSMSTemplates: ' + e.getMessage());
            return null;
        }
    }
    @AuraEnabled(cacheable=true)
   public static String getMessage(String templateName, Id recordId) {
        try { 
            return ExotelSMSmessageCreation.createMessage(recordId, templateName);
        } catch (Exception e) {
            // Log error
            System.debug('Error in fetchRecordFields: ' + e.getMessage());
            return null;
        }
    }
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getPhoneNumbers(Id recordId) {
    Map<String, String> phoneMap = new Map<String, String>();
    try {
        List<WOrkOrder> workOrders = [SELECT Case.Contact_Phone__c, Case.Contact.Phone, Case.Contact.MobilePhone,  
                                       Case.Account.Phone, Case.Contact.Account.Secondary_Phone_No__c,  
                                       Case.Contact.Account.Landline__c, Case.Contact.LastName, Case.Contact.Account.Name 
                                       FROM WOrkOrder WHERE Id = :recordId LIMIT 1];
        if (!workOrders.isEmpty()) {
            WOrkOrder order = workOrders[0];
            System.debug('Query results: ' + order);
            if (order.Case.Contact.Phone != null) {
                phoneMap.put(order.Case.Contact.Phone, order.Case.Contact.LastName);
            }
            if (order.Case.Contact.MobilePhone != null) {
                phoneMap.put(order.Case.Contact.MobilePhone, order.Case.Contact.LastName);
            }
            // if (order.Case.Contact.MobilePhone != null) {
            //     phoneMap.put(order.Contact.MobilePhone, order.Case.Contact.LastName);
            // }

            if (order.Case.Account.Phone != null) {
                phoneMap.put(order.Case.Account.Phone, order.Case.Account.Name);
            }
            if (order.Case.Contact.Account.Secondary_Phone_No__c != null) {
                phoneMap.put(order.Case.Contact.Account.Secondary_Phone_No__c, order.Case.Contact.Account.Name);
            }
            if (order.Case.Contact.Account.Landline__c != null) {
                phoneMap.put(order.Case.Contact.Account.Landline__c, order.Case.Contact.Account.Name);
            }
        }
 System.debug('Query results: ' + phoneMap);
    } catch (Exception e) {
        // Log error
        System.debug('Error in getPhoneNumbers: ' + e.getMessage());
    }

    return phoneMap;
}

//    public static List<WOrkOrder> getPhoneNumbers(Id recordId) {
//         try { 
//              List<WOrkOrder> obj = Database.query('SELECT Case.Contact_Phone__c,Case.Contact.Phone, Case.Contact.MobilePhone,  Case.Contact.Account.Phone,  Case.Contact.Account.Secondary_Phone_No__c,  Case.Contact.Account.Landline__c, Case.Contact.LastName, Case.Contact.Account.Name FROM WOrkOrder WHERE Id = \'' + recordId + '\' LIMIT 1');
//               return obj;
//         } catch (Exception e) {
//             // Log error
//             System.debug('Error in fetchRecordFields: ' + e.getMessage());
//             return null;
//         }
//     }
     @AuraEnabled(cacheable=true)
    public static String sendSMS(List<String> phoneNumber, String recordId, String templateName) {
        try {
            system.debug('sendSMS 103');
            // Null check for phoneNumber, recordId, and templateName
            if (phoneNumber == null || recordId == null || templateName == null) {
                return null;
            }
            // Call ExotelSMSAPI to send SMS
            ExotelSMSAPI.sendSMS(phoneNumber, recordId, templateName);
            return 'success';
        } catch (Exception e) {
            // Log error
            System.debug('Error in sendSMS: ' + e.getMessage());
            return null;
        }
    }
}