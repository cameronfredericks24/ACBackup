public class Changed_User_Employee_Batch implements Database.Batchable<sObject>,Database.Stateful,  Database.AllowsCallouts {
    
    public static Boolean isTestMode = false;
    
    public List<Daily_Job_Documents__c> dailyJobDocumentList = new List<Daily_Job_Documents__c>();
    public String csvColumnHeader;
    public String file = '';
    public String fileName = '';
    public List<String> csvRowValues = new List<String>();
    public string query;
    public Boolean isTestContext = false; 
    public Date customStartDate;  // Custom start date for the file name
    public Date customEndDate; 
    public String folderName;
    // Constructor for dynamic query support
    public Changed_User_Employee_Batch(Boolean overrideQuery, String customQuery,Date customStartDate, Date customEndDate, String folderName) {
        query = 'SELECT Profile.Name, EmployeeNumber, UserRole.Name, Profile_Name__c, CreatedBy.Name, CreatedDate, LastModifiedDate, Division, ' +
                'UserRoleId, Username, Title, MobilePhone, Email,Name, IsActive ' +
                'FROM User ' +
                'WHERE EmployeeNumber != null ' +
                'AND LastModifiedDate = YESTERDAY ' +
                'AND Profile.Name NOT IN (\'BSL Technician\', \'Channel Partner User - BA\', \'Channel Partner User - esa\', \'Channel Partner User - ssd\', \'Partner Community User\') ';

        if (overrideQuery) {
            query = customQuery;
        }
        this.customStartDate = customStartDate;  // Store the custom start date
        this.customEndDate = customEndDate; 
        this.folderName = folderName;
    }
    public Changed_User_Employee_Batch(Boolean overrideQuery, String customQuery, String folderName) {
        this(overrideQuery, customQuery, null, null, folderName);  // Default to null for custom dates
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    private String encloseWithQuotes(String value) {
        
        if (value == null || value.trim() == '') {
            return '""'; // Return empty quotes for null or empty values
        }
        value = value.replaceAll('[\\r\\n]+', ' '); // Replace newlines and carriage returns with spaces
        
        if (value.contains(',') || value.contains('"')) {
            value = '"' + value.replaceAll('"', '""') + '"'; // Escape any existing quotes
        }
        return value;
    }
    
    private String formatDate(DateTime dateTimeValue) {
        if (dateTimeValue == null) {
            return '""'; // Return empty quotes for null DateTime
        }
        return dateTimeValue.format('dd-MMM-yyyy'); // Format DateTime to "dd-MMM-yyyy"
    }
    
    public void execute(Database.BatchableContext BC, List<User> scope) {
          // Reset the csvRowValues and file variables for each execution
        csvRowValues.clear();
        file = '';
        if (isTestMode) {
            System.debug('Test Mode Active: Skipping execute logic.');
            return;
        }
        //System.debug('Changed_User_Employee_Batch - Starting Execute Method');
        
        // Get today's document (create one if needed)
        List<Daily_Job_Documents__c> existingDocs = [SELECT Id, CreatedDate FROM Daily_Job_Documents__c WHERE CreatedDate = TODAY];
        
        if (existingDocs.isEmpty()) {
            Daily_Job_Documents__c newDoc = new Daily_Job_Documents__c();
            newDoc.Name = 'Daily Job ' + Date.today().year() + '-' + Date.today().month() + '-' + Date.today().day();
            insert newDoc;
            dailyJobDocumentList.add(newDoc);
        } else {
            dailyJobDocumentList = existingDocs;
        }
        
        // Separate query to get the branch information for the user from Branch__c
        Map<Id, String> userBranchMap = new Map<Id, String>();
        List<Branch__c> branches = [SELECT Id, User__c, Branch_Code__c FROM Branch__c WHERE User__c IN :scope];
        
        // Separate query to get branch information from Branch_Division__c
        Map<Id, String> userBranchDivisionMap = new Map<Id, String>();
        List<Branch_Division__c> branchDivisions = [SELECT User__c, Branch_Code__c FROM Branch_Division__c WHERE User__c IN :scope];
        
        // Map branch information to users
        for (Branch__c branch : branches) {
            userBranchMap.put(branch.User__c, branch.Branch_Code__c);
        }
        
        // Map branch information from Branch_Division__c to users
        for (Branch_Division__c branchDivision : branchDivisions) {
            userBranchDivisionMap.put(branchDivision.User__c, branchDivision.Branch_Code__c);
        }
        
        for (User user : scope) {
            String branchId = userBranchMap.containsKey(user.Id) ? userBranchMap.get(user.Id) : 
            (userBranchDivisionMap.containsKey(user.Id) ? userBranchDivisionMap.get(user.Id) : '');
                String branchIdFormatted = encloseWithQuotes(branchId);
            
            
            String OrganizationNo = 'Branch';  // Default value, you can change this logic as needed
            
            // Map fields to the CSV columns
            String employeeId = encloseWithQuotes(user.EmployeeNumber);
            String roleId = encloseWithQuotes(user.UserRole.Name);
            String mobile1 = encloseWithQuotes(user.MobilePhone);
            String email1 = encloseWithQuotes(user.Email);
            String active = encloseWithQuotes(user.IsActive ? 'Y' : 'N');
            String createdBy = encloseWithQuotes(user.CreatedBy.Name);
            String createdOn = encloseWithQuotes(formatDate(user.CreatedDate));
            String updatedOn = encloseWithQuotes(formatDate(user.LastModifiedDate));
            String UserType = encloseWithQuotes(user.Profile.Name);
            
			String Name=encloseWithQuotes(user.Name);
            // Create the row for the CSV
            String rowStr = employeeId + ',' + OrganizationNo + ',' + branchIdFormatted + ',' + UserType + ',' + roleId + ',' + mobile1 + ',' + email1 + ',' + active + ',' + createdBy + ',' + createdOn + ',' + updatedOn + ',' + Name;
            
            csvRowValues.add(rowStr);
        }
        
        csvColumnHeader = 'User Id,Organization Type,Organization No.,User Type,Role,MOBILE,EMAIL Id,Is Active,Created By,Created Date,Updated Date,Name\n';
        
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

        
        fileName = 'FNAME_EMPLOYEEMASTER_FROM_' + formattedStartDate + '_TO_' + formattedEndDate + '_EXTTS_' + formattedDateTime + '.csv';
        
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
        
    }
    
    public void finish(Database.BatchableContext BC) {
        if (isTestMode) {
            
            return;
        }
       
    }
}