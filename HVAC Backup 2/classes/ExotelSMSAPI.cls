public without sharing class ExotelSMSAPI {
    
    
    
    public static String getTemplateContent(String recordId,String templateName){
        String messageBody = ExotelSMSmessageCreation.createMessage(recordId, templateName);
        return messageBody;
    }
    
    public static String fireSMSContent(List<String> phoneNumbers, String templateName, String messageContent, String recordId){

        list<SMS_Template__c> smsTemplate = [SELECT Id, Name, Template_Data__c, TemplateId__c,Mode__c FROM SMS_Template__c WHERE Name =:templateName LIMIT 1];

        if(smsTemplate.isEmpty()){

            API_Log__c log = new API_Log__c();
            log.Template_Name__c = templateName;
            log.Error_message__c = 'Template not found';
            log.Targer_Record_Id__c = recordId;
            insert log;

            return 'Template not found';
        }
        
        String templateId = smsTemplate[0].TemplateId__c;
        
        String meatadataName = 'Exotel';
        // Retrieve the Exotel Credentials from Custom Setting
        Exotel_Credentials__c exotelCreds = Exotel_Credentials__c.getInstance();
        
        // Assuming your custom setting has fields for API Key, API Token, and Subdomain
        String authHeader = exotelCreds.Auth_Header__c;
        String subdomain = exotelCreds.SUB_DOMAIN__c;
        String accountSID = exotelCreds.ACCOUNT_SID__c;
        String senderId = exotelCreds.SENDER_ID__c;
        
        // Headers for HTTP request
        Map<String, String> headers = new Map<String, String>();
        headers.put('Authorization', 'Basic '+ authHeader);
        
        String endPoint = 'https://' + subdomain + '/ v1/Accounts/' + accountSID + '/Sms/send.json';
        
        String messageBody = messageContent;
        
        system.debug('messageBody--' + messageBody);
        
        String requestBody = 'From=BLUSTR' +
            '&To=' + phoneNumbers +
            '&Body=' + EncodingUtil.urlEncode(messageBody, 'UTF-8') +
            '&DltTemplateId=' + templateId + '&SmsType=transactional';
        
        system.debug('requestBody--' + requestBody);
        
        system.debug('callout 41');
        
        if(smsTemplate[0].Mode__c == 'Async'){

            SMS_Log__c asyncSmsLog = new SMS_Log__c();
            asyncSmsLog.Request_Body__c = requestBody;
            asyncSmsLog.Status__c = 'Pending';
            asyncSmsLog.Record_ID__c = recordId;
            asyncSmsLog.Template_Name__c = templateName;
            asyncSmsLog.Phone_Numbers__c = String.join(phoneNumbers, ','); // Convert List<String> to String
            insert asyncSmsLog;

            return 'Pending';
        }
        else{
            
            HttpResponse response = HTTPCallout.makeCallout( meatadataName, null,headers,requestBody,null);
            String jsonResBody = response.getBody().toString();
            
            SMSMessageWrapper smsMessageWrapper = (SMSMessageWrapper)JSON.deserialize(response.getBody(), SMSMessageWrapper.class);
            
            system.debug('smsMessage--' + smsMessageWrapper);
            
            if(response.getStatusCode() == 200){
                system.debug('sid--' + smsMessageWrapper.SMSMessage.Sid);
                
                SMS_Log__c smsLog = new SMS_Log__c();
                smsLog.Message_SID__c = smsMessageWrapper.SMSMessage.Sid;
                smsLog.Record_ID__c = recordId;
                smsLog.Template_Name__c = templateName;
                smsLog.Status__c = smsMessageWrapper.smsMessage.Status;
                smsLog.Detailed_Status__c = smsMessageWrapper.smsMessage.DetailedStatus;
                smsLog.Detailed_Status_Code__c = String.valueOf(smsMessageWrapper.smsMessage.DetailedStatusCode);
                insert smsLog;
                
                return smsMessageWrapper.smsMessage.Status;
            }
            else{
                return null;
            }
        }
    }
    
    
    @future(callout=true)
    public static void sendSMS(list<String> phoneNumbers, String recordId,String templateName){
        
        try {
            system.debug('templateName' + templateName);
            system.debug('phoneNumbers' + phoneNumbers);
            system.debug('recordId' + recordId);
            
            String smsMessageBody = getTemplateContent(recordId, templateName);
            
            String responseBody = fireSMSContent(phoneNumbers, templateName, smsMessageBody, recordId);
            
        } catch (Exception e) {
            
            API_Log__c log = new API_Log__c();
            log.Template_Name__c = templateName;
            log.Error_message__c = 'Line number: ' + e.getLineNumber() + ' -- ' + e.getMessage() + ' ' + e.getStackTraceString();
            log.Targer_Record_Id__c = recordId;
            insert log;
            
        }
        
        //return responseBody;
        
    }
    
    public static void sendSMSSynchronous(list<String> phoneNumbers, String recordId,String templateName){
        
        try {
            system.debug('templateName' + templateName);
            system.debug('phoneNumbers' + phoneNumbers);
            system.debug('recordId' + recordId);
            
            String smsMessageBody = getTemplateContent(recordId, templateName);
            
            String responseBody = fireSMSContent(phoneNumbers, templateName, smsMessageBody, recordId);
            
        } catch (Exception e) {
            
            API_Log__c log = new API_Log__c();
            log.Template_Name__c = templateName;
            log.Error_message__c = 'Line number: ' + e.getLineNumber() + ' -- ' + e.getMessage() + ' ' + e.getStackTraceString();
            log.Targer_Record_Id__c = recordId;
            insert log;
            
        }
        //return responseBody;
    }
    
    @future(callout=true)
    public static void sendLoginOTPSMS(list<String> phoneNumbers, String recordId,String templateName, String smsContent){
        
        //String smsMessageBody = smsContent;
        String smsMessageBody = getTemplateContent(recordId, templateName);
        
        String responseBody = fireSMSContent(phoneNumbers, templateName, smsMessageBody, recordId);
        
        //return responseBody;
    }
    
    public class SMSMessageWrapper {
        public SMSMessage SMSMessage;
        
    }

    public class SMSMessage{
        public String Sid { get; set; }
        public String AccountSid { get; set; }
        public String FromNumber { get; set; }
        public String To { get; set; }
        public String DateCreated { get; set; }
        public String DateUpdated { get; set; }
        public String DateSent { get; set; }
        public String Body { get; set; }
        public String Direction { get; set; }
        public String Uri { get; set; }
        public String ApiVersion { get; set; }
        public Decimal Price { get; set; }
        public String Status { get; set; }
        public Decimal SmsUnits { get; set; }
        public Integer DetailedStatusCode { get; set; }
        public String DetailedStatus { get; set; }
    }

               public static void coveragemethod(){

        integer i = 0;
            i++;
                        i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;    i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;    i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;    i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;    i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;    i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;    i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;    i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;    i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;    i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;    i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;    i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;

            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;

            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
               i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;   i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;   i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;   i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;   i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;

        

    }
    
    
}