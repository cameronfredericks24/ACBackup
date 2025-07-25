public class Changed_Service_Ticket_Batch implements Database.Batchable<sObject>,Database.stateful,  Database.AllowsCallouts {
    
    public List<Daily_Job_Documents__c> dailyJobDocumetList = new List<Daily_Job_Documents__c>();
    public String csvColumnHeader;
    String file = '';
    String fileName = '';
    public List<String> csvRowValues = new List<String>();
    public String query;
    // Flag to determine whether to enqueue the S3 job or not
    public Boolean isTestContext = false;  // Default is false
    public Date customStartDate;  // Custom start date for the file name
    public Date customEndDate; 
    public String folderName;
    // Constructor for dynamic query support
    public Changed_Service_Ticket_Batch(Boolean overrideQuery, String customQuery, Date customStartDate, Date customEndDate, String folderName) {
        query = 'SELECT Id, Ticket_Number_Read_Only__c, CreatedDate, CreatedBy.Name, WorkType.Name, Symptom_Comment__c, ' +
            'Customer_Id__c, Account.Name, Asset.Account.Name, Account.IsNamo__c, Account.Customer_ID__c, Case.Origin, ' +
            'Work_Type_Name__c,CaseId,TAT__c,Contact_Phone__c, Account.Customer_Code__c,Field_Work_Type__c , Contact_Email__c, Description, Payout__c, ' +
            'Travel_Amount__c, Asset_Obligation__c,Obligation__c,Asset.CP__r.Name,Asset.CP__r.CP_Code__c, Accepted_Date__c,First_Work_Started_Date__c,Account.Id, Latest_Work_Started_Date__c, ' +
            'First_Work_Completed_Date__c, Latest_Work_Completed_Date__c, Component_Id__c, CP__r.CP_Code__c, LastModifiedDate, ' +
            'Turn_Around_Time_TAT__c, Response_Time_RT__c,Close_From__c , RecordType.Name, Case.Repeated_Customer_Flag__c, StartDate, ' +
            'SlaStartDate, EndDate, SlaExitDate, Invoice_Date__c,ParentWorkOrder.Ticket_Number_Read_Only__c,Case.Caller_Phone__c, CP__r.Customer_Id_Formula__c, WorkTypeId, Priority, ' +
            'Response_Schedule_RS__c, Case.Source__c ' +
            'FROM WorkOrder WHERE RecordType.Name!=null and WorkType.Name!=null and LastModifiedDate = YESTERDAY';
        
        if (overrideQuery) {
            query = customQuery;
        }
        this.customStartDate = customStartDate;  // Store the custom start date
        this.customEndDate = customEndDate; 
        this.folderName = folderName;
    }
    public Changed_Service_Ticket_Batch(Boolean overrideQuery, String customQuery, String folderName) {
        this(overrideQuery, customQuery, null, null, folderName);  // Default to null for custom dates
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    // Utility method to handle enclosing values with quotes and replacing new lines
    private String encloseWithQuotes(String value) {
        if (value == null || value.trim() == '') {
            return null;  // Return empty quotes for null or empty values
        }
        // Replace newlines and carriage returns with a space to prevent row shifting
        value = value.replaceAll('[\\r\\n]+', ' ');
        
        // Enclose in quotes if it contains a comma or quotes
        if (value.contains(',') || value.contains('"')) {
            value = '"' + value.replaceAll('"', '""') + '"';  // Escape any existing quotes
        }
        return value;
    }
    
    private String formatDate(DateTime dateTimeValue) {
        if (dateTimeValue == null) {
            return null; // Return null for blank
        }
        return dateTimeValue.format('yyyy-MM-dd HH:mm:ss'); // Format DateTime
    }
    
    
    public void execute(Database.BatchableContext BC, List<WorkOrder> scope) {
        
        // Reset the csvRowValues and file variables for each execution
        csvRowValues.clear();
        file = '';
        List<Daily_Job_Documents__c> existingDocs = [SELECT Id, CreatedDate FROM Daily_Job_Documents__c WHERE CreatedDate = TODAY];
        
        if (existingDocs.isEmpty()) {
            Daily_Job_Documents__c newDoc = new Daily_Job_Documents__c();
            newDoc.Name = 'Daily Job ' + Date.today().year() + '-' + Date.today().month() + '-' + Date.today().day();
            insert newDoc;
            dailyJobDocumetList.add(newDoc);
        } else {
            dailyJobDocumetList = existingDocs;
        }
        
        // Collect CaseIds from WorkOrders
        Set<Id> caseIds = new Set<Id>();
        for (WorkOrder wo : scope) {
            if (wo.CaseId != null) {
                caseIds.add(wo.CaseId);
            }
        }
        
        // Query CaseMilestones related to the collected CaseIds
        Map<Id, Map<String, DateTime>> caseMilestoneMap = new Map<Id, Map<String, DateTime>>();
        if (!caseIds.isEmpty()) {
            List<CaseMilestone> milestones = [
                SELECT Id, MilestoneType.Name, CompletionDate, CaseId
                FROM CaseMilestone
                WHERE CaseId IN :caseIds
            ];
            
            // Organizing milestones by CaseId and MilestoneType
            for (CaseMilestone milestone : milestones) {
                if (!caseMilestoneMap.containsKey(milestone.CaseId)) {
                    caseMilestoneMap.put(milestone.CaseId, new Map<String, DateTime>());
                }
                caseMilestoneMap.get(milestone.CaseId).put(milestone.MilestoneType.Name, milestone.CompletionDate);
            }
        }
        
        for (WorkOrder wo : scope) {
            // Use encloseWithQuotes method to ensure proper quoting for all fields
            String ticketNumber = encloseWithQuotes(wo.Ticket_Number_Read_Only__c);
            String createdDate = encloseWithQuotes(formatDate(wo.CreatedDate));
            String createdBy = encloseWithQuotes(wo.CreatedBy.Name);
            String serviceType = encloseWithQuotes(
                wo.RecordType != null && !String.isBlank(wo.RecordType.Name) ? wo.RecordType.Name : ''
            );
            
            String symptom = encloseWithQuotes(wo.Symptom_Comment__c);
            String componentNo = encloseWithQuotes(wo.Component_Id__c);
            String customerId = encloseWithQuotes(
                wo.Account.Customer_Code__c != null ? wo.Account.Customer_Code__c :
                (wo.Account.Customer_ID__c != null ? wo.Account.Customer_ID__c : null)
            );
            String customerName = encloseWithQuotes(wo.Account.Name);
            String contactPhone = encloseWithQuotes(wo.Contact_Phone__c);
            String contactEmail = encloseWithQuotes(wo.Contact_Email__c);
            String description = encloseWithQuotes(wo.Description);
            String isNAMO = encloseWithQuotes(wo.Account.IsNamo__c != null && wo.Account.IsNamo__c ? 'Yes' : 'No');
            String tat = encloseWithQuotes(wo.TAT__c != null ? String.valueOf(wo.TAT__c) : 
                                           (wo.Turn_Around_Time_TAT__c != null ? String.valueOf(wo.Turn_Around_Time_TAT__c) : ''));
            
            String RT = encloseWithQuotes(wo.Response_Time_RT__c != null ? String.valueOf(wo.Response_Time_RT__c) : '');
            String retailer = encloseWithQuotes(wo.Asset.CP__r.Name);//asset.cp.name
            String channelPartnerNo = encloseWithQuotes(wo.CP__r.CP_Code__c);
            String payout = encloseWithQuotes(wo.Payout__c != null ? String.valueOf(wo.Payout__c) : '');
            String travelAmount = encloseWithQuotes(wo.Travel_Amount__c != null ? String.valueOf(wo.Travel_Amount__c) : '');
            String fieldWorkType = encloseWithQuotes(
                wo.WorkType != null && !String.isBlank(wo.WorkType.Name) ? wo.WorkType.Name : ''
            );
            
            String lastModifiedDate = encloseWithQuotes(formatDate(wo.LastModifiedDate));
            String assetObligation = encloseWithQuotes(
                wo.Asset_Obligation__c != null ? wo.Asset_Obligation__c :
                (wo.Obligation__c != null ? wo.Obligation__c : 'NIC')
            );
            String AlternatePhone=encloseWithQuotes(wo.Case.Caller_Phone__c);
            String RSCompletion = encloseWithQuotes('');
            String RTCompletion = encloseWithQuotes('');
            String TATCompletion = encloseWithQuotes(''); // "Turn Around Time"
            
            // Check if CaseId exists in caseMilestoneMap
            if (caseMilestoneMap.containsKey(wo.CaseId)) {
                Map<String, DateTime> milestones = caseMilestoneMap.get(wo.CaseId);
                
                // Check for RSCompletion milestone
                RSCompletion = milestones.containsKey('RS') ? encloseWithQuotes(formatDate(milestones.get('RS'))) : '';
                
                // Check for RTCompletion milestone
                RTCompletion = milestones.containsKey('RT') ? encloseWithQuotes(formatDate(milestones.get('RT'))) : '';
                
                // Check for TATCompletion milestone
                TATCompletion = milestones.containsKey('Turn Around Time') 
                    ? encloseWithQuotes(formatDate(milestones.get('Turn Around Time'))) 
                    : '';
            }
            
            if (String.isBlank(RSCompletion)) {
                RSCompletion = wo.Accepted_Date__c != null ? encloseWithQuotes(formatDate(wo.Accepted_Date__c)) : '';
            }
            
            if (String.isBlank(RTCompletion)) {
                RTCompletion = wo.First_Work_Started_Date__c != null ? encloseWithQuotes(formatDate(wo.First_Work_Started_Date__c)) : '';
            }
            
            if (String.isBlank(TATCompletion)) {
                TATCompletion = wo.First_Work_Completed_Date__c != null ? encloseWithQuotes(formatDate(wo.First_Work_Completed_Date__c)) : '';
            }
            
            
            
            
            String stSource = encloseWithQuotes(wo.Case != null ? wo.case.Origin : null);//take Origin
            String ParentTicket=encloseWithQuotes(wo.ParentWorkOrder != null ? wo.ParentWorkOrder.Ticket_Number_Read_Only__c : null);
            
            String rs = encloseWithQuotes(wo.Response_Schedule_RS__c != null ? String.valueOf(wo.Response_Schedule_RS__c) : '');
            //String ResponseDate=encloseWithQuotes(formatDate(wo.Response_Schedule__c));
            String isRepeatCall = encloseWithQuotes(wo.Case.Repeated_Customer_Flag__c == 'Red Flag' ? '1' : '0');
            
            String AccountId = wo != null && wo.Account != null && wo.Account.id != null 
                ? encloseWithQuotes(wo.Account.id) 
                : '""';
            
            String isCritical = encloseWithQuotes(wo.Priority == 'Critical' ? 'Y' : 'N'); // ISCRITICAL
            String callTypeId = encloseWithQuotes(wo.RecordType.Name); // CALL_TYPE_ID
            String retailerId = encloseWithQuotes(wo.CP__r.CP_Code__c); // RETAILER_ID
            
            
            String firstWorkStartedDate = encloseWithQuotes(formatDate(wo.First_Work_Started_Date__c)); // First_work_started_date
            String latestWorkStartedDate = encloseWithQuotes(formatDate(wo.Latest_Work_Started_Date__c)); // Latest_work_started_date
            String firstWorkCompletedDate = encloseWithQuotes(formatDate(wo.First_Work_Completed_Date__c)); // First_Work_completed_date
            String latestWorkCompletedDate = encloseWithQuotes(formatDate(wo.Latest_Work_Completed_Date__c)); // Latest_work_completed_Date
            String ClosedFrom = encloseWithQuotes(wo.Close_From__c );
            
            // Construct row string using commas to join values
            String rowStr = String.join(new List<String>{
                ticketNumber, createdDate, createdBy, serviceType, symptom, componentNo, customerId,
                    customerName, contactPhone, contactEmail, description, isNAMO, tat, retailer,
                    channelPartnerNo, payout, travelAmount, fieldWorkType, lastModifiedDate,
                    assetObligation, stSource, rs, RT, isRepeatCall, isCritical, callTypeId, retailerId,
                    firstWorkStartedDate, latestWorkStartedDate, firstWorkCompletedDate, latestWorkCompletedDate, AccountId, RSCompletion, RTCompletion, TATCompletion, AlternatePhone, ParentTicket,ClosedFrom 
                    }, ',');
            
            csvRowValues.add(rowStr);
        }
        
        // Define the CSV Header
        csvColumnHeader = 'ST No.,Created Date,Created By,Service Type,Symptom,Component No.,Customer ID,Customer Name,' +
            'Mobile No.,Customer Contact Email,Problem Description,Is NAMO?,TAT,Retailer,Channel Partner No.,' +
            'Payout,Travel Amt,Work Type,Updated Date,Obligation,ST Source,RS,RT,Is Repeat Call,Is Critical,Call Type ID,' +
            'Retailer ID,First Work Started Date,Latest Work Started Date,First Work Completed Date,Latest Work Completed Date,Account ID,RS Completed Date,Rt Completed Date,TAT Completed Date,Alternate phone,Parent Ticket Number,Ticket Closed from\n';
        
        String concatenatedStr = '\uFEFF'+csvColumnHeader + String.join(csvRowValues, '\n');
        file = concatenatedStr;
        
        // Use custom dates if provided, otherwise default to yesterday
        Date startDate = customStartDate != null ? customStartDate : Date.today().addDays(-1);
        Date endDate = customEndDate != null ? customEndDate : Date.today().addDays(-1);
        
        String formattedStartDate = String.format('{0}{1}{2}', new String[]{
            String.valueOf(startDate.year()),
                startDate.month() < 10 ? '0' + String.valueOf(startDate.month()) : String.valueOf(startDate.month()),
                    startDate.day() < 10 ? '0' + String.valueOf(startDate.day()) : String.valueOf(startDate.day())
                        });
        
        String formattedEndDate = String.format('{0}{1}{2}', new String[]{
            String.valueOf(endDate.year()),
                endDate.month() < 10 ? '0' + String.valueOf(endDate.month()) : String.valueOf(endDate.month()),
                    endDate.day() < 10 ? '0' + String.valueOf(endDate.day()) : String.valueOf(endDate.day())
                        });
        
        DateTime nowDateTime = DateTime.now();
        String formattedDateTime = String.format('{0}{1}{2}{3}{4}{5}', new String[]{
            String.valueOf(nowDateTime.year()),
                nowDateTime.month() < 10 ? '0' + String.valueOf(nowDateTime.month()) : String.valueOf(nowDateTime.month()),
                    nowDateTime.day() < 10 ? '0' + String.valueOf(nowDateTime.day()) : String.valueOf(nowDateTime.day()),
                        nowDateTime.hour() < 10 ? '0' + String.valueOf(nowDateTime.hour()) : String.valueOf(nowDateTime.hour()),
                            nowDateTime.minute() < 10 ? '0' + String.valueOf(nowDateTime.minute()) : String.valueOf(nowDateTime.minute()),
                                nowDateTime.second() < 10 ? '0' + String.valueOf(nowDateTime.second()) : String.valueOf(nowDateTime.second()),
                                    String.valueOf(nowDateTime.millisecond()).leftPad(3, '0')
                                    });
        formattedDateTime += String.valueOf(Math.abs(Math.mod(Crypto.getRandomInteger(), 100))).leftPad(2, '0');
        
        fileName = 'FNAME_TICKET_FROM_' + formattedStartDate + '_TO_' + formattedEndDate + '_EXTTS_' + formattedDateTime + '.csv';
        Blob csvBlob = Blob.valueOf(concatenatedStr);
        
        if (!dailyJobDocumetList.isEmpty()) {
            Attachment attachmentObj = new Attachment(
                Body = csvBlob,
                Name = fileName,
                ParentId = dailyJobDocumetList[0].Id
            );
            insert attachmentObj;
                 // Create a BS360__c record after attachment is created
        BS360__c bsRecord = new BS360__c();
        bsRecord.Name = fileName;                // Set the Name field to the fileName
        bsRecord.Count__c = csvRowValues.size(); // Set the Count__c field to the number of rows
        insert bsRecord;
            //System.debug('Attachment Id: ' + attachmentObj.Id);
        } else {
            //System.debug('No Daily Job Document found to attach the CSV.');
        }
        
        if ((!String.isBlank(file) && !isTestContext)) {
            
            System.enqueueJob(new S3FileUploadQueueable(dailyJobDocumetList[0].Id, fileName, file, folderName));
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        
    }
}