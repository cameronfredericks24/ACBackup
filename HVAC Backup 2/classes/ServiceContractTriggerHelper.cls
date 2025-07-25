/*
@Author : Himanshi Verma
@CreatedDate : 15th May 2024
@Description : ServiceContract Object Trigger Helper.
*/

public with sharing class ServiceContractTriggerHelper {

    public void notifyUsers(Id serviceContractId) {
        System.debug('Executed........!');

        // Query ServiceContract with Opportunity and recipient fields
        ServiceContract serviceContract = [
            SELECT Id, SAP_Contract_Number__c, Opportunity__c, Account.Group__c, Opportunity__r.Name, Opportunity__r.SME__c, 
                   Opportunity__r.SDE__c, Opportunity__r.Regional_Commercial_Head__c, 
                   Opportunity__r.KAM__c, Modification_Status__c
            FROM ServiceContract
            WHERE Id = :serviceContractId
            LIMIT 1
        ];
    
        // Ensure Modification_Status__c is 'Activated'
        if (serviceContract.SAP_Contract_Number__c == null) {
            System.debug('Service Contract can not be null.');
            return;
        }
    
        // Collect recipient user IDs based on Account.Group__c condition
        Set<String> recipientIds = new Set<String>();
        
        if (serviceContract.Opportunity__c != null) {
            if (serviceContract.Account.Group__c == 'NAMO') {
                // If Group__c is 'NAMO', add only KAM
                if (serviceContract.Opportunity__r.KAM__c != null) {
                    recipientIds.add(serviceContract.Opportunity__r.KAM__c);
                }
            } else {
                // If Group__c is not 'NAMO', add all recipients except KAM
                if (serviceContract.Opportunity__r.SME__c != null) recipientIds.add(serviceContract.Opportunity__r.SME__c);
                if (serviceContract.Opportunity__r.SDE__c != null) recipientIds.add(serviceContract.Opportunity__r.SDE__c);
                if (serviceContract.Opportunity__r.Regional_Commercial_Head__c != null) recipientIds.add(serviceContract.Opportunity__r.Regional_Commercial_Head__c);
            }
        }
    
        // Only proceed if we have recipients
        if (recipientIds.isEmpty()) {
            System.debug('No recipients found for notification.');
            return;
        }
    
        // Retrieve custom notification type
        CustomNotificationType notificationType = [
            SELECT Id 
            FROM CustomNotificationType 
            WHERE DeveloperName = 'Contract_Activation_Notification'
            LIMIT 1
        ];
    
        if (notificationType == null) {
            System.debug('Custom Notification Type "Contract_Activation_Notification" not found.');
            return;
        }
    
        // Set up and send the notification
        try {
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle('Contract Activation');
            notification.setBody('Your Contract has been Generated: ' + serviceContract.Opportunity__r.Name);
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(serviceContract.Id);
            notification.send(recipientIds);
        } catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }
    }

    public static void sendFileEmails(String accountId, List<Id> fileIds) {
        try {
            Account ac = [SELECT Id, Email__c FROM Account WHERE Id = :accountId LIMIT 1];
    
            List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
    
            if (fileIds.size() > 0) {
                List<ContentVersion> contentVersionList = [
                    SELECT VersionData, Title, PathOnClient, FileExtension
                    FROM ContentVersion
                    WHERE Id IN :fileIds
                ];
    
                for (ContentVersion contentVersion : contentVersionList) {
                    if (contentVersion.VersionData != null && contentVersion.FileExtension.toLowerCase() == 'pdf') {
                        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                        attachment.setFileName(contentVersion.Title);
                        attachment.setBody(contentVersion.VersionData);
                        attachment.setContentType('application/pdf'); // Explicitly set MIME type for PDF
                        attachments.add(attachment);
                    }
                }
            }
    
            if (!attachments.isEmpty()) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setSubject('Contract Activation and Invoice Report');
                email.setHtmlBody(buildEmailBody());
                email.setToAddresses(new String[] { ac.Email__c });
                email.setFileAttachments(attachments);
    
                String senderId = System.Label.Sender_Email;
                OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :senderId];
                if (owea.size() > 0) {
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                } else {
                    email.setSenderDisplayName('Blue Star Customer Care');
                }
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                // Email sent successfully
            } else {
                System.debug('No PDF attachments found for account');
                // No attachments found
            }
        } catch (Exception e) {
            System.debug('Error sending email: ' + e.getMessage());
            // Email sending failed
        }
    }
    
    // Method to build the email body
    public static String buildEmailBody() {
        String emailBody = '<html><body>';
        emailBody += 'Dear Customer,';
        emailBody += '<p>We are pleased to provide you with the requested files related to your Bluestar account. Please find the attached PDF documents for your reference.</p>';
        emailBody += '<p>If you have any questions or need further assistance, please do not hesitate to contact us.</p>';
        emailBody += '<p>Thanks,<br>Bluestar Customer Service Team</p>';
        emailBody += '</body></html>';
        return emailBody;
    }
    
    public void getRelatedFiles(Id accountId) {
        Set<Id> contentDocumentIds = new Set<Id>();
        Set<Id> linkedEntityIds = new Set<Id>();
    
        // Query only ServiceContracts and Invoice__c related to the Account
        List<Account> accounts = [
            SELECT Id,
                   (SELECT Id FROM ServiceContracts), 
                   (SELECT Id FROM Invoices__r) 
            FROM Account 
            WHERE Id = :accountId
        ];
    
        // Add the Account's related ServiceContracts and Invoice__c to linkedEntityIds
        for (Account ac : accounts) {
            linkedEntityIds.add(ac.Id); // Add the Account ID
    
            // Check and add ServiceContract IDs if ServiceContracts is not null
            if (ac.ServiceContracts != null && !ac.ServiceContracts.isEmpty()) {
                for (ServiceContract record : ac.ServiceContracts) {
                    linkedEntityIds.add(record.Id);
                }
            }
    
            // Check and add Invoice__c IDs if Invoices__r is not null
            if (ac.Invoices__r != null && !ac.Invoices__r.isEmpty()) {
                for (Invoice__c record : ac.Invoices__r) {
                    linkedEntityIds.add(record.Id);
                }
            }
        }
    
        // Fetch ContentDocumentIds linked to the Account, ServiceContracts, and Invoice__c
        List<ContentDocumentLink> links = [
            SELECT ContentDocumentId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN :linkedEntityIds
        ];
    
        // Collect ContentDocumentIds from the links
        for (ContentDocumentLink link : links) {
            if (link.ContentDocumentId != null) {
                contentDocumentIds.add(link.ContentDocumentId);
            }
        }
    
        System.debug('Content Document IDs: ' + contentDocumentIds);
    
        // Fetch ContentVersion records from the collected ContentDocumentIds
        List<ContentVersion> files = new List<ContentVersion>();
        if (!contentDocumentIds.isEmpty()) {
            files = [
                SELECT Id, Title, ContentDocumentId, VersionData, PathOnClient
                FROM ContentVersion 
                WHERE ContentDocumentId IN :contentDocumentIds
            ];
        }
    
        if (files != null && !files.isEmpty()) {
            // Extract ContentVersion IDs and pass to sendFileEmails
            List<Id> fileIds = new List<Id>();
            for (ContentVersion file : files) {
                fileIds.add(file.Id);
            }
    
            sendFileEmails(accountId, fileIds);
        }
    }
       

}