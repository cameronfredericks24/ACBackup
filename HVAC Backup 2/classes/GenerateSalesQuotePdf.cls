public without sharing class GenerateSalesQuotePdf {  
    
    public static void createPDF(String quoteId , String recipientEmail) {
        try {
            System.debug('createPDF method called');
            System.debug('quoteIds: ' + quoteId);
            System.debug('recipientEmail: ' + recipientEmail);
            
            String quoteUrl = '/quote/quoteTemplateDataViewer.apexp?';            
            String quoteTemplateId = label.QuoteTemplateId;            
            List<QuoteDocument> lstQuoteDoc = new List<QuoteDocument>();
            
            if(quoteId != null) {               
                //for(Id quoteId :quoteIds) {
                System.debug('Processing quoteId: ' + quoteId);
                quoteUrl += 'id=' + quoteId;                    
                quoteUrl += '&headerHeight=197&footerHeight=10';                    
                quoteUrl += '&summlid=' + quoteTemplateId;
                PageReference pageRef = new PageReference(quoteUrl);
                Blob quoteBlob;
                
                if(Test.isRunningTest()) {
                    quoteBlob = Blob.valueOf('Generate Pdf');
                } else {
                    try {
                        quoteBlob = pageRef.getContentAsPDF();
                        System.debug('Generated PDF for Quote ID: ' + quoteId);
                    } catch (Exception pdfEx) {
                        System.debug('Failed to generate PDF for Quote ID: ' + quoteId + ' with error: ' + pdfEx.getMessage());
                        // continue;
                    }
                }
                
                QuoteDocument quoteDoc = new QuoteDocument();
                quoteDoc.Document = quoteBlob;
                quoteDoc.QuoteId = quoteId;                    
                lstQuoteDoc.add(quoteDoc);
                // }                
            }            
            insert lstQuoteDoc;
            sendEmailWithAttachment(lstQuoteDoc, recipientEmail);
        } catch (Exception e) {
            System.debug('Error in createPDF: ' + e.getMessage());
            System.debug('Error in createPDF: ' + e.getLineNumber());
        }
    }
    @TestVisible
    private static void sendEmailWithAttachment(List<QuoteDocument> docList, String recipientEmail) {
        System.debug('sendEmailWithAttachment called');
        System.debug('docList: ' + docList);
        System.debug('recipientEmail: ' + recipientEmail);
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        owea = [SELECT Id, Address, DisplayName FROM 
                OrgWideEmailAddress WHERE DisplayName='Blue Star Customer Experience'];
        //Added by Akash on 03.09.24 to send mail outside the loop
        List<Messaging.SingleEmailMessage> listOfEmail = new List<Messaging.SingleEmailMessage>();
        
        if (!docList.isEmpty()) {
            for (QuoteDocument doc : docList) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] { recipientEmail });
                mail.setSubject('Your Quote Document');
                mail.setPlainTextBody('Please find the attached quote document for Quote ID: ' + doc.QuoteId);
                if(owea!= null){
                    mail.setOrgWideEmailAddressId(owea[0].Id);
                }
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName('Quote_' + doc.QuoteId + '.pdf');
                attachment.setBody(doc.Document);
                
                try {
                    mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
                    listOfEmail.add(mail);
                    //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    //System.debug('Email sent successfully for Quote ID: ' + doc.QuoteId);
                } catch (Exception e) {
                    System.debug('Error while sending email for Quote ID: ' + doc.QuoteId + ' - ' + e.getMessage());
                }
            }
            
            //Added by Akash on 03.09.24 to bulkify the email call
            try
            {
                if(!listOfEmail.isEmpty())
                {
                    Messaging.sendEmail(listOfEmail);
                    System.debug('Email sent successfully');
                }
            }
            catch(Exception e)
            {
                System.debug('Error while sending email >> ' + e.getMessage());
            }
        }
    }
    
    //Created By Soniya 
    @InvocableMethod
    public static void createPDFAMTCoupon(List<PDFParams> paramsList) {
        for(PDFParams params : paramsList) {
            CreateAMTPdf(params.quoteId, params.recipientEmail);
        }
    }
    
    
    @future(callout=true)
    public static void CreateAMTPdf(String quoteId, String recipientEmail){
        try {
            System.debug('createPDF method called');
            System.debug('quoteIds: ' + quoteId);
            System.debug('recipientEmail: ' + recipientEmail);
            
            String quoteUrl = '/quote/quoteTemplateDataViewer.apexp?';            
            String quoteTemplateId = '0EH9I0000004lgH';            
            List<ContentVersion> lstQuoteDoc = new List<ContentVersion>();
            
            if(quoteId != null) {               
                //for(Id quoteId :quoteIds) {
                System.debug('Processing quoteId: ' + quoteId);
                
                quoteUrl += 'headerHeight=197&footerHeight=10';                    
                quoteUrl += '&summlid=' + quoteTemplateId;
                quoteUrl += '&id=' + quoteId; 
                system.debug('quoteUrl'+quoteUrl );
                PageReference pageRef = Page.QuoteTemplate ;
                pageRef.getParameters().put('Id', quoteId);
                Blob quoteBlob;
                try {
                    
                    
                    if (Test.isRunningTest()) {
                        quoteBlob = Blob.valueOf('Generate Pdf');
                    } else {
                        try {
                            quoteBlob = pageRef.getContentAsPDF();
                            System.debug('Generated PDF Blob size: ' + quoteBlob.size());
                        } catch (Exception pdfEx) {
                            System.debug('Failed to generate PDF: ' + pdfEx.getMessage());
                            return; // Stop further processing if PDF generation fails.
                        }
                    }
                    
                    System.debug('quoteBlob: ' + quoteBlob);
                    // Continue with ContentVersion creation and email sending.
                } catch (Exception e) {
                    System.debug('Error in createPDF: ' + e.getMessage());
                }
                
                
                String filename ='Quote';
                Id networkId = [SELECT Id FROM Network LIMIT 1].Id;
                ContentVersion conVer = new ContentVersion();
                
                conVer.ContentLocation = 'S'; 
                
                conVer.PathOnClient = filename+'.pdf'; 
                
                conVer.Title = filename; 
                
                conVer.VersionData = quoteBlob; 
                conVer.NetworkId = '0DB9I0000000HbxWAE'; 
                
                
                lstQuoteDoc.add(conVer);
                
                if(!lstQuoteDoc.isEmpty()){
                    insert lstQuoteDoc;
                    
                    Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
                    
                    ContentDocumentLink conDocLink = New ContentDocumentLink();
                    
                    conDocLink.LinkedEntityId = quoteId; 
                    
                    conDocLink.ContentDocumentId = conDoc;  
                    
                    insert conDocLink;
                    
                    
                }
                
                /*
                QuoteDocument quoteDoc = new QuoteDocument();
                quoteDoc.Document = quoteBlob;
                quoteDoc.QuoteId = quoteId;*/
                //quoteDoc.ContentVersionDocumentId=
                //lstQuoteDoc.add(quoteDoc);
                // }     
                // 
                sendEmailAttachment(lstQuoteDoc, recipientEmail,quoteBlob );           
            }            
            // insert lstQuoteDoc;
            
        } catch (Exception e) {
            System.debug('Error in createPDF: ' + e.getMessage());
        }
    }
    
    @TestVisible
    private static void sendEmailAttachment(List<ContentVersion> docList, String recipientEmail,blob quoteBlob ) {
        System.debug('sendEmailWithAttachment called');
        System.debug('docList: ' + docList);
        System.debug('recipientEmail: ' + recipientEmail);
        OrgWideEmailAddress owea = new OrgWideEmailAddress();
       owea = [SELECT Id, Address, DisplayName FROM 
               OrgWideEmailAddress WHERE Address=:Label.Sender_Email];
        
        //Added by Akash on 03.09.24 to send mail outside the loop
        List<Messaging.SingleEmailMessage> listOfEmail = new List<Messaging.SingleEmailMessage>();
        
        if (!docList.isEmpty()) {
            for (ContentVersion doc : docList) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] { recipientEmail });
                mail.setSubject('Your Quote Document');
                mail.setPlainTextBody('Please find the attached quote document'  );
                 mail.setOrgWideEmailAddressId(owea.id);
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName('Quote_' + '.pdf');
                attachment.setBody(quoteBlob);
                
                try {
                    mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
                    listOfEmail.add(mail);
                    system.debug('listOfEmail'+ listOfEmail);
                    //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    System.debug('Email sent successfully');
                    //System.debug('Email sent successfully for Quote ID: ' + doc.QuoteId);
                } catch (Exception e) {
                    System.debug('Error while sending email for Quote ID: ' + e.getMessage());
                }
            }
            
            //Added by Akash on 03.09.24 to bulkify the email call
            try
            {
                // Send email and capture result - note the array brackets around listOfEmail
                Messaging.SendEmailResult[] results = Messaging.sendEmail(listOfEmail);
                
                // Check the result and log any errors
                for (Messaging.SendEmailResult result : results) {
                    if (result.isSuccess()) {
                        System.debug('Email sent successfully.');
                    } else {
                        System.debug('Failed to send email.');
                        for (Messaging.SendEmailError error : result.getErrors()) {
                            System.debug('Error code: ' + error.getStatusCode());
                            System.debug('Error message: ' + error.getMessage());
                        }
                    }
                }
            }
            catch(Exception e)
            {
                System.debug('Error while sending email >> ' + e.getMessage());
            }
        }
    }
    
    
    public class PDFParams {
        
        @InvocableVariable(required=true)
        public String quoteId;
        
        @InvocableVariable(required=true)
        public String recipientEmail;
    }
    
    
    
}