/**
* Email services are automated processes that use Apex classes
* to process the contents, headers, and attachments of inbound
* email.
*/
global class EmailClass implements Messaging.InboundEmailHandler {
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,Messaging.InboundEnvelope envelope) {
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        
        String myPlainText= '';
        
        // Add the email plain text into the local variable 
        myPlainText = email.plainTextBody;
        
        // New Task object to be created
        Task[] newTask = new Task[0];
        
        // Try to look up any contacts based on the email from address
        // If there is more than one contact with the same email address,
        // an exception will be thrown and the catch statement will be called.
        try {
            Contact vCon = [SELECT Id, Name, Email
                            FROM Contact
                            WHERE Email = :email.fromAddress
                            WITH USER_MODE
                            LIMIT 1 ];
            // Create a new email message
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            // Set the recipients of the email
            String[] toAddresses = new String[] {'Himanshi@warpdrivetech.in'};
                mail.setToAddresses(toAddresses);
            
            // Set the email subject
            mail.setSubject('Test Email from Salesforce');
            
            // Set the email body
            mail.setPlainTextBody('This is a test email sent from Salesforce Apex.');
            
            // Optionally, you can set the sender email address
            // mail.setOrgWideEmailAddressId('your_org_wide_email_address_id');
            
            // Send the email
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
             System.debug('Failed to send email: ' + results[0].getErrors()[0].getMessage());
        
            // Check the result of the email send operation
            if (results[0].isSuccess()) {
                System.debug('Email sent successfully.');
            } else {
                System.debug('Failed to send email: ' + results[0].getErrors()[0].getMessage());
            }
            
            
        }
        // If an exception occurs when the query accesses 
        // the contact record, a QueryException is called.
        // The exception is written to the Apex debug log.
        catch (QueryException e) {
            System.debug('Query Issue: ' + e);
        }
        
        // Set the result to true. No need to send an email back to the user 
        // with an error message
        result.success = true;
        
        // Return the result for the Apex Email Service
        return result;
    }
}