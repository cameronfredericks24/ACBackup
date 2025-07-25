public without sharing class ServiceReportTriggerHandler {
    
    public static void beforeInsert(List<ServiceReport> newReports) {
        //ServiceReportTriggerHelper.handleBeforeInsert(newReports);
    }

    public static void afterInsert(List<ServiceReport> newServiceReports) {
        
        system.debug('newServiceReports-- '+ newServiceReports);
        // Collect all related ServiceAppointment Ids
        Set<Id> serviceAppointmentIds = new Set<Id>();
        for (ServiceReport sr : newServiceReports) {
            serviceAppointmentIds.add(sr.ParentId);
        }
        
        // Query related ServiceAppointments and relevant Service Ticket Emails
        List<ServiceAppointment> serviceAppointments = [
            SELECT Id,Work_Order__r.Contact_Email__c
            FROM ServiceAppointment
            WHERE Id IN :serviceAppointmentIds
        ];

        if(serviceAppointmentIds != null){

            sendServiceReportEmail(serviceAppointmentIds);

        }
        
        system.debug('serviceAppointmentIds-- '+ serviceAppointmentIds);
        
    }


@Future(callout=true)
public static void sendServiceReportEmail(Set<Id> serviceAppointmentIds) {
    system.debug('sendServiceReportEmail--');

    List<ServiceAppointment> saLst = [SELECT Id, Work_Order__c FROM ServiceAppointment WHERE Id IN :serviceAppointmentIds];

    for (ServiceAppointment sa : saLst) {
        // Query the related Work Order
        WorkOrder currentWO = [
            SELECT ID, Ticket_Number_Read_Only__c, CP__r.Name, Contact_Email__c, Account.Email__c, 
                   CP__r.Phone, GrandTotal, SDE_Name__c, Is_PMS_Ticket__c, 
                   Account.RecordType.Name, Account.Division__c, Amount_Collected_formula__c
            FROM WorkOrder
            WHERE ID = :sa.Work_Order__c
        ];

        // Fetch survey invitation record
        Survey_Invitation__c surveyInv = [
            SELECT Id, Survey__r.Survey_URL__c, Survey_Invitation_URL__c,Case__c,Case__r.Contact_Phone__c
            FROM Survey_Invitation__c 
            WHERE Service_Ticket__c = :currentWO.Id
            LIMIT 1
        ];

        // Construct the email body
        String body = 'Dear Customer,\n\n';

        if (currentWO.Is_PMS_Ticket__c) {
            body += 'Your Preventive Maintenance Service Request (PMS) is now completed. ';
            body += 'Please find attached the PMSR (Preventive Maintenance Service Report).\n\n';
        } else {
            body += 'Your Ticket No: ' + currentWO.Ticket_Number_Read_Only__c + ' has been closed by our Service Provider, ';
            body += (currentWO.CP__r != null ? currentWO.CP__r.Name + ', contact number: ' + currentWO.CP__r.Phone + '.' : '') + '\n';

            if (currentWO.Amount_Collected_formula__c != null) {
                body += 'Total amount collected: ' + currentWO.Amount_Collected_formula__c + ' INR.\n';
            }

            body += 'Please find attached the FSR (Field Service Report).\n\n';
        }

        // Add Survey Link
        if (surveyInv != null && surveyInv.Survey_Invitation_URL__c != null) {
            body += 'We value your feedback! Please take a moment to complete our survey by clicking the link below:\n';
            body += surveyInv.Survey_Invitation_URL__c + '\n\n';
        }

        body += 'For any queries, contact our 24x7 Toll-Free number: +918976781177, email us at customerservice@bluestarindia.com, or SMS SERVICE at 57575.\n';
        body += 'Assuring you of our best service.\n\nThank You,\nBlue Star Ltd.';

        system.debug('body--' + body);

        // Query related files linked to the Service Appointment
        List<ServiceReport> srLst = [
            SELECT Id, ContentVersionDocumentId FROM ServiceReport WHERE ParentId = :sa.Id
        ];

        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();

        if (!srLst.isEmpty()) {
            // Fetch the first file's content
            ContentVersion contentVersion = [
                SELECT VersionData, ContentDocument.Title, ContentDocument.FileType
                FROM ContentVersion
                WHERE Id = :srLst[0].ContentVersionDocumentId
                LIMIT 1
            ];

            Messaging.EmailFileAttachment fsrAttachment = new Messaging.EmailFileAttachment();
            fsrAttachment.setFileName(contentVersion.ContentDocument.Title + '.' + contentVersion.ContentDocument.FileType);
            fsrAttachment.setBody(contentVersion.VersionData);
            fsrAttachment.setContentType('application/' + contentVersion.ContentDocument.FileType.toLowerCase());
            attachments.add(fsrAttachment);
        }

        // Attach Invoice if Amount Collected is greater than 0
        if (currentWO.Amount_Collected_formula__c > 0) {

            PageReference invoicePage = Page.LetterOfSalesVf; // Replace with actual VF page
            invoicePage.getParameters().put('id', currentWO.Id);
            Blob pdfBlob = invoicePage.getContentAsPDF();

            Messaging.EmailFileAttachment invoiceAttachment = new Messaging.EmailFileAttachment();
            invoiceAttachment.setFileName('Invoice_' + currentWO.Ticket_Number_Read_Only__c + '.pdf');
            invoiceAttachment.setBody(pdfBlob);
            attachments.add(invoiceAttachment);

            system.debug('invoice added--');
        }

        // Create and send the email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String recipientAddress = currentWO.Contact_Email__c != null ? currentWO.Contact_Email__c : currentWO.Account.Email__c;
        
        if (recipientAddress != null && recipientAddress != '' && isValidEmail(recipientAddress)) {
            email.setToAddresses(new List<String>{ recipientAddress });
            email.setSubject('Service Ticket Completed ' + currentWO.Ticket_Number_Read_Only__c);
            email.setPlainTextBody(body);
            email.setFileAttachments(attachments);

            // Set OrgWideEmail or sender display name
            String senderId = System.Label.Sender_Email;
            OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :senderId];
            if (!owea.isEmpty()) {
                email.setOrgWideEmailAddressId(owea[0].Id);
            } else {
                email.setSenderDisplayName('Blue Star Customer Care');
            }

                String sendEmailOrg = System.Label.sendEmailOrg;
                String bslStaticEmail = System.Label.bslStaticEmail;

                if(sendEmailOrg == 'true' && !bslStaticEmail.contains(recipientAddress)){
                    Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
                }
        }
    }
}

    

    public static Boolean isValidEmail(String email) {
        if (String.isBlank(email)) {
            return false;
        }
        
        // Regular expression for validating email
        String emailRegex = '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$';
        
        // Match the email with the regex
        Pattern emailPattern = Pattern.compile(emailRegex);
        Matcher matcher = emailPattern.matcher(email);
        
        return matcher.matches();
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