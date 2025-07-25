public with sharing class SendChargesController {

    // Method to send email with attachment
    @AuraEnabled
    public static String sendEmailWithAttachment(String attachmentName, String emailAddress) {
        try {
            // Retrieve attachment from static resource
            //Blob attachmentBody = getAttachmentBody(attachmentName);

            // Create email message with attachment
           /* Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
            emailAttachment.setFileName('PDF_Attachment.pdf');
            emailAttachment.setBody(attachmentBody);*/

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[]{emailAddress});
            email.setTemplateId(getTemplateId());
            email.setTargetObjectId(userinfo.getuserId());
            email.setSaveAsActivity(false);
            email.setReplyTo('no-reply@company.com');
            String senderId = System.Label.Sender_Email;
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = : senderId];
            if ( owea.size() > 0 ) {
                email.setOrgWideEmailAddressId(owea.get(0).Id);
            } else{
                email.setSenderDisplayName('Blue Star Customer Care');
            }

            // Send email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});

            return 'Email sent successfully.';
        } catch (Exception ex) {			
           throw ex;
        }
    }
    /*@AuraEnabled
    public static String sendSMSWithLink(String attachmentName, String phoneNumber) {
        String response = 'Unable to Delivered the Message';
        if(phoneNumber!=null && attachmentName != ''){

        List<String> phoneNumbers = new List<String>();
        phoneNumbers.add(phoneNumber);
        String base64FileData = StaticResourceUrlGenerator.getFileDataAsBase64(attachmentName);
        String linkOfdoc = StaticResourceUrlGenerator.createContentVersionAndPublicLink(attachmentName, base64FileData);

        ExotelSMSAPI.sendSMS(phoneNumbers,userinfo.getuserId(), 'ST-PMS-Work Completed-Customer');
        response = 'Message delivered Sucessfully';
                    
    }
    return response;
*/
    //}

    // Method to retrieve attachment body from static resource
   /* private static Blob getAttachmentBody(String attachmentName) {
        Blob attachmentBody;

        // Retrieve attachment from static resource
        try {
            attachmentBody = [SELECT Body FROM StaticResource WHERE Name = 'RateCardTemplate'].Body;
        } catch (Exception ex) {
            throw new AuraHandledException('Error retrieving attachment: ' + ex.getMessage());
        }

        return attachmentBody;
    }*/

    // Method to get email template Id
    private static Id getTemplateId() {
        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Standard_Charges'];
        return template.Id;
    }
}