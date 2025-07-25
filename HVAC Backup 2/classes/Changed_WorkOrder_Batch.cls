public class Changed_WorkOrder_Batch implements Database.Batchable<sObject>,Database.Stateful,  Database.AllowsCallouts {
    
    public List<Daily_Job_Documents__c> dailyJobDocumetList = new List<Daily_Job_Documents__c>();
    public String csvColumnHeader;
    String file = '';
    String fileName = '';
    public List<String> csvRowValues = new List<String>();
    public String query;
    public Boolean isTestContext = false; 
    public Date customStartDate;  // Custom start date for the file name
    public Date customEndDate; 
    public String folderName;
     // Constructor for dynamic query support
    public Changed_WorkOrder_Batch(Boolean overrideQuery, String customQuery, Date customStartDate, Date customEndDate, String folderName) {
        query = 'SELECT Id, LastModifiedBy.Name, LastModifiedDate, CreatedBy.Name, CreatedDate, ' +
                'Symptom_Comment__c, Defect_Comment__c, Action_Comment__c, Ticket_Number_Read_Only__c ' +
                'FROM WorkOrder WHERE RecordType.Name!=null and WorkType.Name!=null and LastModifiedDate = YESTERDAY';

        if (overrideQuery) {
            query = customQuery;
        }
        this.customStartDate = customStartDate;  // Store the custom start date
        this.customEndDate = customEndDate; 
        this.folderName = folderName;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    public Changed_WorkOrder_Batch(Boolean overrideQuery, String customQuery, String folderName) {
        this(overrideQuery, customQuery, null, null, folderName);  // Default to null for custom dates
    }
    
    // Utility method to handle enclosing values with quotes and replacing new lines
    private String encloseWithQuotes(String value) {
        // Handle null and empty values
        if (value == null || value.trim() == '') {
            return '""';  // Return empty quotes for null or empty values
        }
        // Replace newlines and carriage returns with a space to prevent row shifting
        value = value.replaceAll('[\\r\\n]+', ' ');
        
        // Enclose in quotes if it contains a comma or quotes
        if (value.contains(',') || value.contains('"')) {
            value = '"' + value.replaceAll('"', '""') + '"';  // Escape any existing quotes
        }
        return value;
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
        
        for (WorkOrder wo : scope) {
            // Apply the encloseWithQuotes method to all fields with null checks
            String ticketNumber = encloseWithQuotes(wo.Ticket_Number_Read_Only__c);
            String action = encloseWithQuotes(wo.Action_Comment__c);
            String defect = encloseWithQuotes(wo.Defect_Comment__c);
            String symptom = encloseWithQuotes(wo.Symptom_Comment__c);
            String createdBy = encloseWithQuotes(wo.CreatedBy != null ? wo.CreatedBy.Name : '');
            String updatedBy = encloseWithQuotes(wo.LastModifiedBy != null ? wo.LastModifiedBy.Name : '');
            
            String createdDate = encloseWithQuotes(wo.CreatedDate != null ? wo.CreatedDate.format('dd-MMM-yyyy H:mm:ss') : '');
            String updatedDate = encloseWithQuotes(wo.LastModifiedDate != null ? wo.LastModifiedDate.format('dd-MMM-yyyy H:mm:ss') : '');
            
            
            // Construct the row string with all the required fields
            String rowStr = ticketNumber + ',' + action + ',' + defect + ',' + symptom + ',' +
                createdBy + ',' + updatedBy + ',' + createdDate + ',' + updatedDate;
            
            csvRowValues.add(rowStr);
        }
        
        
        // Updated header to match the required format
        csvColumnHeader = 'ST No.,Action,Defect,Symptom,Created By,Updated By,Created Date,Updated Date\n';
        
        // Join the header and rows into the final CSV content
        String concatenatedStr = csvColumnHeader + String.join(csvRowValues, '\n');
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

        fileName = 'FNAME_RESOLUTIONDETAILS_FROM_' + formattedStartDate + '_TO_' + formattedEndDate + '_EXTTS_' + formattedDateTime + '.csv';
        
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