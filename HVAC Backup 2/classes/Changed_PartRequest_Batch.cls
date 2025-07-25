public class Changed_PartRequest_Batch implements Database.Batchable<sObject>,Database.Stateful,  Database.AllowsCallouts {
    
    public List<Daily_Job_Documents__c> dailyJobDocumentList = new List<Daily_Job_Documents__c>();
    public String csvColumnHeader;
    String file = ''; 
    String fileName = '';
    public List<String> csvRowValues = new List<String>();
    public String query;
    public Boolean isTestContext = false; 
    public Date customStartDate;  // Custom start date for the file name
    public Date customEndDate;   
    public String folderName;
    // Constructor to allow query override
    public Changed_PartRequest_Batch(Boolean overrideQuery, String customQuery,Date customStartDate, Date customEndDate, String folderName) {
         Id materialRequestRecordTypeId = Schema.SObjectType.ProductRequest.getRecordTypeInfosByName().get('Material Request').getRecordTypeId();
        
        query = 'SELECT Id, External_ID__c, WorkOrder.Ticket_Number_Read_Only__c, Dispatch_Date__c, Material_Code__c, Quantity__c, ' +
                'Order_Received_Date__c, CreatedDate, RecordType.Name, CreatedBy.Name, LastModifiedDate, LastModifiedBy.Name, Part_Request_No__c, ' +
                '(SELECT Id, Product_Name_Text__c FROM Defective_Product_Items__r), Product__r.Name ' +
                'FROM ProductRequest WHERE RecordTypeId IN (\'' + materialRequestRecordTypeId + '\') AND LastModifiedDate = YESTERDAY ';

        if (overrideQuery) {
            query = customQuery;
        }
        this.customStartDate = customStartDate;  // Store the custom start date
        this.customEndDate = customEndDate;  
        this.folderName = folderName;
    }
     public Changed_PartRequest_Batch(Boolean overrideQuery, String customQuery, String folderName) {
        this(overrideQuery, customQuery, null, null, folderName);  // Default to null for custom dates
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    // Utility method to handle enclosing values with quotes and replacing new lines
    private String encloseWithQuotes(String value) {
        if (value == null || value.trim() == '') {
            return '""';
        }
        // Replace newlines and carriage returns with a space to prevent row shifting
        value = value.replaceAll('[\\r\\n]+', ' ');
        
        // Enclose in quotes if it contains a comma or quotes
        if (value.contains(',') || value.contains('"')) {
            value = '"' + value.replaceAll('"', '""') + '"';
        }
        return value;
    }
    
    public void execute(Database.BatchableContext BC, List<ProductRequest> scope) {
          // Reset the csvRowValues and file variables for each execution
        csvRowValues.clear();
        file = '';
        List<Daily_Job_Documents__c> dailyJobDocumentList = [SELECT Id, CreatedDate FROM Daily_Job_Documents__c WHERE CreatedDate = TODAY];
        
        if (dailyJobDocumentList.isEmpty()) {
            Daily_Job_Documents__c newVar = new Daily_Job_Documents__c();
            newVar.Name = 'Daily Job ' + Date.today().year() + '-' + Date.today().month() + '-' + Date.today().day();
            dailyJobDocumentList.add(newVar);
            insert dailyJobDocumentList;
        }
        
        for (ProductRequest asw : scope) {
            // Use encloseWithQuotes for each field
            String mrNumber = encloseWithQuotes(asw.Part_Request_No__c);
            String externalId =  encloseWithQuotes(asw.External_ID__c);           
            // Fetch Product__r.Name as the new partName
            String partName = encloseWithQuotes(asw.Product__r != null && asw.Product__r.Name != null ? asw.Product__r.Name : '');
            
            String serviceTicketNumber = encloseWithQuotes(asw.WorkOrder.Ticket_Number_Read_Only__c);
            String partNo = encloseWithQuotes(asw.Material_Code__c);
            String quantity = encloseWithQuotes(asw.Quantity__c != null ? String.valueOf(asw.Quantity__c) : '');
            
            // Format the Dispatch_Date__c field properly as DateTime
            String processedDate = encloseWithQuotes(asw.CreatedDate != null ? asw.CreatedDate.format('dd-MM-yyyy hh:mm:ss') : '');
            
            String createdBy = encloseWithQuotes(asw.CreatedBy.Name);
            String updatedBy = encloseWithQuotes(asw.LastModifiedBy.Name);
            String createDate = encloseWithQuotes(asw.CreatedDate != null ? asw.CreatedDate.format('dd-MMM-yyyy') : '');
            String lastUpdatedDate = encloseWithQuotes(asw.LastModifiedDate != null ? asw.LastModifiedDate.format('dd-MMM-yyyy') : '');
            
            
            // Construct the row string
            String rowStr = mrNumber + ','+ externalId + ','+ partName + ',' + serviceTicketNumber + ',' + partNo + ',' + quantity + ',' + processedDate + ',' + createdBy + ',' + updatedBy + ',' + createDate + ',' + lastUpdatedDate;
            csvRowValues.add(rowStr);
        }
        
        // Define the CSV Header without spaces before the values
        csvColumnHeader = 'MR No.,SAP MR Number,Part Name,Service Ticket,Part No.,Qty,Processed Date,Created By,Updated By,Created Date,Updated Date\n';
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

        
        fileName = 'FNAME_MATERIALREQUEST_FROM_' + formattedStartDate + '_TO_' + formattedEndDate + '_EXTTS_' + formattedDateTime + '.csv';
        
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
         if ((!String.isBlank(file) && !isTestContext)) {
            
            System.enqueueJob(new S3FileUploadQueueable(dailyJobDocumentList[0].Id, fileName, file, folderName));
        }
       // System.debug('Attachment ID: ' + attachmentObj.Id);
    }
    
    
    public void finish(Database.BatchableContext BC) {
       
        // Perform any additional final actions if needed
    }
}