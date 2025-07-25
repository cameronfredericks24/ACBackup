public class Changed_Branches_Batch implements Database.Batchable<sObject>,Database.stateful, Database.AllowsCallouts {
    
    public List<Daily_Job_Documents__c> dailyJobDocumentList = new List<Daily_Job_Documents__c>();
    public String csvColumnHeader;
    String file = ''; 
    String fileName = '';
    String query;
    public List<String> csvRowValues = new List<String>();
    // Flag to determine whether to enqueue the S3 job or not
    public Boolean isTestContext = false; 
    public String folderName;// Default is false
     
    // Constructor to allow overriding the query
    public Changed_Branches_Batch(Boolean overrideQuery, String customQuery, String folderName) {
        // Default query
        query = 'SELECT Branch_Code__c, Address__r.City, Region__c, Name FROM Branch__c WHERE Branch_Code__c != null';
        
        // Override query if specified
        if (overrideQuery) {
            query = customQuery;
        }
        this.folderName = folderName;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    // Utility method to handle enclosing values with quotes and replacing new lines
    private String encloseWithQuotes(String value) {
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
    
    public void execute(Database.BatchableContext BC, List<Branch__c> scope) {
         // Reset the csvRowValues and file variables for each execution
        csvRowValues.clear();
        file = '';
        dailyJobDocumentList = [SELECT Id, CreatedDate FROM Daily_Job_Documents__c WHERE CreatedDate = TODAY];
        
        if (dailyJobDocumentList.isEmpty()) {
            Daily_Job_Documents__c newDoc = new Daily_Job_Documents__c();
            newDoc.Name = 'Daily Job ' + Date.today().year() + '-' + Date.today().month() + '-' + Date.today().day();
            dailyJobDocumentList.add(newDoc);
            system.debug(newDoc.Name);
            insert dailyJobDocumentList;
        }
          
        for (Branch__c branch : scope) {
            // Apply encloseWithQuotes to all fields 
            String businessEntityNumber = encloseWithQuotes(branch.Branch_Code__c);
            String businessEntityName = encloseWithQuotes(branch.Name);
            String primaryCity =  encloseWithQuotes(branch.Address__r.City); 
            String isActive = encloseWithQuotes('Y');
            
            // Construct the row
            String rowStr = businessEntityNumber + ',' + businessEntityName + ',' + primaryCity + ',' + isActive;
            csvRowValues.add(rowStr);
        }
        
        // Correctly format the CSV Header without extra spaces
        csvColumnHeader = 'Business Entity No.,Business Entity Name,Primary City,Is Active\n';
        
        // Concatenate header and row data
        String concatenatedStr = csvColumnHeader + String.join(csvRowValues, '\n');
        file = concatenatedStr;
        
        // Use LastModifiedDate range for the filename
        Date startDate = Date.today(); // Start date of range
        Date endDate = Date.today().addDays(-1);   // End date of range
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
        String formattedDateTime = String.format('{0}{1}{2}{3}{4}{5}{6}', new String[]{
            String.valueOf(nowDateTime.year()),
                nowDateTime.month() < 10 ? '0' + String.valueOf(nowDateTime.month()) : String.valueOf(nowDateTime.month()),
                    nowDateTime.day() < 10 ? '0' + String.valueOf(nowDateTime.day()) : String.valueOf(nowDateTime.day()),
                        nowDateTime.hour() < 10 ? '0' + String.valueOf(nowDateTime.hour()) : String.valueOf(nowDateTime.hour()),
                            nowDateTime.minute() < 10 ? '0' + String.valueOf(nowDateTime.minute()) : String.valueOf(nowDateTime.minute()),
                                nowDateTime.second() < 10 ? '0' + String.valueOf(nowDateTime.second()) : String.valueOf(nowDateTime.second()),
                                    String.valueOf(nowDateTime.millisecond()).leftPad(3, '0')
                                    });
        formattedDateTime += String.valueOf(Math.abs(Math.mod(Crypto.getRandomInteger(), 100))).leftPad(2, '0');
        
        
        
        
        fileName = 'FNAME_BRANCHMASTER_FROM_full_TO_' + formattedStartDate + '_EXTTS_' + formattedDateTime + '.csv';
        
        Blob csvBlob = Blob.valueOf(concatenatedStr);
        
        Attachment attachmentObj = new Attachment(
            Body = csvBlob,
            Name = fileName,
            ParentId = dailyJobDocumentList[0].Id
        );
        
        insert attachmentObj;
            // Create a BS360__c record after attachment is created
        BS360__c bsRecord = new BS360__c();
        bsRecord.Name = fileName;                // Set the Name field to the fileName
        bsRecord.Count__c = csvRowValues.size(); // Set the Count__c field to the number of rows
        insert bsRecord;
         // Check if test flag is set to ignore the enqueue job in test context
        if ((!String.isBlank(file) && !isTestContext)) {
            System.enqueueJob(new S3FileUploadQueueable(dailyJobDocumentList[0].Id, fileName, file, folderName));
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        //System.debug('file contains'+file);
        
    }
}