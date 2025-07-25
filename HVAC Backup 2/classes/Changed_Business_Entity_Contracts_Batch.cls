public class Changed_Business_Entity_Contracts_Batch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    
    public List<Daily_Job_Documents__c> dailyJobDocumentList = new List<Daily_Job_Documents__c>();
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
    
    // Constructor to allow query override
    public Changed_Business_Entity_Contracts_Batch(Boolean overrideQuery, String customQuery, Date customStartDate, Date customEndDate, String folderName) {
        Id commercialCustomerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Commercial Customer').getRecordTypeId();
        Id residentialCustomerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Residential Customer').getRecordTypeId();
        
        // Removed the subquery from the query
        query = 'SELECT Id, Customer_Code__c, Customer_ID__c, Salutation__c, SAP_Customer_Id__c, Name, Phone, Primary_Phone_No__c, ' +
                'Email__c, CreatedDate, LastModifiedDate, Gender__c, Age__pc ' +
                'FROM Account ' +
                'WHERE RecordTypeId IN (\'' + commercialCustomerRecordTypeId + '\', \'' + residentialCustomerRecordTypeId + '\') ' +
                'AND LastModifiedDate = YESTERDAY';
        
        if (overrideQuery) {
            query = customQuery;
        }
        this.customStartDate = customStartDate;  // Store the custom start date
        this.customEndDate = customEndDate; 
        this.folderName = folderName;
    }
    
    public Changed_Business_Entity_Contracts_Batch(Boolean overrideQuery, String customQuery, String folderName) {
        this(overrideQuery, customQuery, null, null, folderName);  // Default to null for custom dates
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
    
    // Utility method to format DateTime values in the "dd-MMM-yyyy" format (e.g., "12-Jun-2024")
    private String formatDate(DateTime dateTimeValue) {
        if (dateTimeValue == null) {
            return '""';  // Return empty quotes for null DateTime
        }
        return dateTimeValue.format('dd-MMM-yyyy');  // Format DateTime to "dd-MMM-yyyy"
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        // Reset the csvRowValues and file variables for each execution
        csvRowValues.clear();
        file = '';
        List<Account> accounts = (List<Account>)scope;
        
        // Query Daily_Job_Documents__c records
        dailyJobDocumentList = [SELECT Id, CreatedDate FROM Daily_Job_Documents__c WHERE CreatedDate = TODAY];
        
        if (dailyJobDocumentList.isEmpty()) {
            Daily_Job_Documents__c newDoc = new Daily_Job_Documents__c();
            newDoc.Name = 'Daily Job ' + Date.today().year() + '-' + Date.today().month() + '-' + Date.today().day();
            dailyJobDocumentList.add(newDoc);
            insert dailyJobDocumentList;
        }
        
        // Collect Account IDs from the scope
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : accounts) {
            accountIds.add(acc.Id);
        }
        
        // Query related Contacts outside the for loop
        List<Contact> relatedContacts = [
            SELECT Id, AccountId, SAP_Contact_Id__c, Age__c, LastName, Email, FirstName, Title, GenderIdentity, LastModifiedDate
            FROM Contact
            WHERE AccountId IN :accountIds
            AND Is_Primary__c = true
        ];
        
        // Create a map of AccountId to Contact for efficient lookup
        Map<Id, Contact> accountIdToContactMap = new Map<Id, Contact>();
        for (Contact con : relatedContacts) {
            accountIdToContactMap.put(con.AccountId, con);
        }
        
        // Process each Account and its related Contact
        for (Account acc : accounts) {
            String BusinessEntityNo = encloseWithQuotes(
                acc.Customer_Code__c != null ? acc.Customer_Code__c :
                (acc.Customer_ID__c != null ? acc.Customer_ID__c : null)
            );
            String mobileNo = encloseWithQuotes(acc.Phone != null ? acc.Phone.trim() : '');
            String mobile2 = encloseWithQuotes(acc.Primary_Phone_No__c != null ? acc.Primary_Phone_No__c.trim() : '');
            String createdDate = encloseWithQuotes(formatDate(acc.CreatedDate));
            String updatedDate = encloseWithQuotes(formatDate(acc.LastModifiedDate));
            String AccountID = acc != null && acc.Id != null 
                ? encloseWithQuotes(acc.Id) 
                : '""';
            
            // Get the related Contact from the map
            Contact contact = accountIdToContactMap.get(acc.Id);
            if (contact != null) {
                // Extract contact-specific details
                String ERPContactNo = encloseWithQuotes(contact.SAP_Contact_Id__c != null ? contact.SAP_Contact_Id__c : '');
                String age = encloseWithQuotes(contact.Age__c != null ? String.valueOf(contact.Age__c) : '');
                String gender = encloseWithQuotes(contact.GenderIdentity != null ? contact.GenderIdentity : '');
                String firstName = encloseWithQuotes(contact.FirstName != null ? contact.FirstName : '');
                String lastName = encloseWithQuotes(contact.LastName != null ? contact.LastName : '');
                String title = encloseWithQuotes(contact.Title != null ? contact.Title.trim() : '');
                String emailId = encloseWithQuotes(contact.Email != null ? contact.Email : '');
                
                // Create a row for this contact
                String rowStr = BusinessEntityNo + ',' + title + ',' + firstName + ',' + lastName + ',' + mobileNo + ',' + mobile2 + ',' + emailId + ',' + createdDate + ',' + updatedDate + ',' + gender + ',' + age + ',' + ERPContactNo + ',' + AccountID;
                csvRowValues.add(rowStr);
            }
        }
        
        // CSV Header
        csvColumnHeader = 'Business Entity No.,Title,First Name,Last Name,Mobile No.,Mobile 2,Email Id,Created Date,Updated Date,Gender,Age,ERP Contact No.,Account ID\n';
        
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

        fileName = 'FNAME_CONTACTPERSONMASTER_FROM_' + formattedStartDate + '_TO_' + formattedEndDate + '_EXTTS_' + formattedDateTime + '.csv';
        
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
        // System.debug('CSV Attachment Created with Id: ' + attachmentObj.Id);
    }
    
    public void finish(Database.BatchableContext BC) {
        //System.debug('Batch job finished.');
    }
}