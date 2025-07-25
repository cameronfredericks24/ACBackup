public class Changed_FGR_batch implements Database.Batchable<sObject>,Database.Stateful, Database.AllowsCallouts {
    
    public List<Daily_Job_Documents__c> dailyJobDocumentList = new List<Daily_Job_Documents__c>();
    public String csvColumnHeader;
    public String query;
    String file = '';
    String fileName = '';
    public Boolean isTestContext = false; 
    public Date customStartDate;  // Custom start date for the file name
    public Date customEndDate; 
    public String folderName;
    
    public List<String> csvRowValues = new List<String>();
    
    // Constructor to allow dynamic query override
    public Changed_FGR_batch(Boolean overrideQuery, String query2,Date customStartDate, Date customEndDate, String folderName) {
        Id RecordtypeId = Schema.SObjectType.ReturnOrder.getRecordTypeInfosByName().get('FGR').getRecordTypeId();
        query ='SELECT Id, CreatedBy.Name, Estimated_Repair_Cost__c, DA_Reference_of_New_Equipment__c,Age__c, Return_OBD_No__c, Return_Invoice_No__c, ' +
            'Return_SO_No__c, Action_Taken_On_Defective_Machine__c,Work_Order__r.Account.Customer_ID__c,Work_Order__r.Account.SAP_Customer_Id__c, Billed_Dealer_No__c,Reason_of_Rejection__c, Billed_Dealer_Name__c, Work_Order__r.Account.Customer_Code__c, CreatedDate, ' +
            'FGR_Number__c, External_ID__c, Status, CaptureApprovalSentDatTime__c,Work_Order__r.Branchh__r.Name, CP_Code__c,Account.Branch__r.Name, CP_Name__r.CP_Code__c, ' +
            'Branch_Name__r.Branch_Code__c, CP_Name__r.Type, LastModifiedBy.Name, Damage_Type__c, SDE__r.EmployeeNumber, SDE__r.Name, Sales_AM__r.Name, ' +
            'Sales_AM__r.EmployeeNumber, Sales_RM__r.EmployeeNumber, Sales_RM__r.Name, AIDH__r.EmployeeNumber, AIDH__r.Name, CFS__r.EmployeeNumber, CFS__r.Name, ' +
            'Service_AM__r.EmployeeNumber, Service_AM__r.Name, Service_RM__r.EmployeeNumber, Service_RM__r.Name, AIH__r.EmployeeNumber, Division__c,AIH__r.Name, CP_Name__r.Name, Account.Name, ' +
            'Equipment_Type_General__c, Failure_Observed_At__c, FGR_Reason__c, Main_Defect_General__c,Dispatch_To__c,Case.Service_Division__r.Department_Number__c, Sub_Defect_1_General__c, Sub_Defect_2_General__c, Failure_Observed_At_SDE__c, ' +
            'Equipment_Type_New_SDE__c, Main_Defect_New_SDE__c, Sub_Defect_1_New_SDE__c,Account.Branch__r.Branch_Code__c, Sub_Defect_2_New_SDE__c, Recommend_Sales_Return__c, Classification_Type__c,Work_Order__r.Obligation__c, Invoice_Date__c, ' +
            'Invoice_Number__c, Branch_Name__r.Name, Asset__r.Asset_Obligation__c, Case.Branch__r.Name,Description, Work_Order__r.Ticket_Number_Read_Only__c, Account.IsNamo__c, CP_Name__r.Parent.CP__r.CP_Code__c, ' +
            'Branch_Name__r.Region__c, LastModifiedDate,Branch__c,Case.Branch__r.Branch_Code__c, Asset__r.Product2.Name, Product_Name__r.ProductCode, Model_Number__c, Asset__r.Product_Family__r.Code__c,Service_Department__c, Product_Name__r.Product_Family__r.Code__c, ' +
            'Asset__r.Product_Family__r.Name,Work_Order__r.Branchh__r.Branch_Code__c, Product_Name__r.Product_Family__r.Name,Case.Sales_Division__r.Name, Asset__r.Product_Sub_Family__r.Code__c,Work_Order__r.Asset_Obligation__c, Product_Name__r.Product_Sub_Family__r.Code__c, Asset__r.Product_Sub_Family__r.Name, ' +
            'Product_Name__r.Product_Sub_Family__r.Name, Product_Serial_Number__c,Asset__r.Service_Department_L__r.Name,Invoice_Ageing__c,Work_Order__r.Asset.InstallDate,Asset__r.Sales_Department_L__r.Name, Asset__r.SerialNumber, Asset__r.Component_Id__c, Purchased_Date__c ' +
            'FROM ReturnOrder WHERE RecordTypeId IN (\'' + RecordtypeId + '\') and LastModifiedDate = YESTERDAY ';
        
        if (overrideQuery) { 
            query = query2;   
        }
        this.customStartDate = customStartDate;  // Store the custom start date
        this.customEndDate = customEndDate; 
        this.folderName = folderName;
    }
    public Changed_FGR_batch(Boolean overrideQuery, String customQuery, String folderName) {
        this(overrideQuery, customQuery, null, null, folderName);  // Default to null for custom dates
    }
    
    // QueryLocator for batch execution
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    
    // Utility method to enclose values with quotes
    private String encloseWithQuotes(String value) {
        if (value == null || value.trim() == '') {
            return '';  
        }
        value = value.replaceAll('[\\r\\n]+', ' ');  
        String originalValue = String.valueOf(value);
        if (originalValue.contains(',') || originalValue.contains('"')) {
            originalValue = '"' + originalValue.replaceAll('"', '""') + '"';
        }
        return originalValue;
    }
    
    // Execute method processing records
    public void execute(Database.BatchableContext BC, List<ReturnOrder> scope) {
        csvRowValues.clear();
            file = '';
        // Retrieve or create Daily Job Document
        List<Daily_Job_Documents__c> existingDocs = [SELECT Id, CreatedDate FROM Daily_Job_Documents__c WHERE CreatedDate = TODAY];
        
        if (existingDocs.isEmpty()) {
            Daily_Job_Documents__c newDoc = new Daily_Job_Documents__c();
            newDoc.Name = 'Daily Job ' + Date.today().year() + '-' + Date.today().month() + '-' + Date.today().day();
            insert newDoc;
            dailyJobDocumentList.add(newDoc);
            //System.debug('New Daily Job Document created with ID: ' + newDoc.Id);
        } else {
            dailyJobDocumentList = existingDocs;
            //System.debug('Reusing existing Daily Job Document with ID: ' + dailyJobDocumentList[0].Id);
        }
        
        for (ReturnOrder obj : scope) {
            
            // Initializing all fields with empty values using encloseWithQuotes('')
            String purchaseOrderId = encloseWithQuotes('0');
            String poItemId = encloseWithQuotes('0');
            String createdBy = encloseWithQuotes(obj.CreatedBy.Name != null ? obj.CreatedBy.Name : null);
            
            String requestType = encloseWithQuotes('ReturnRequest');
            String estimatedRepairCost = encloseWithQuotes(obj.Estimated_Repair_Cost__c != null ? String.valueOf(obj.Estimated_Repair_Cost__c) : null);
            
            String daReference = encloseWithQuotes(obj.DA_Reference_of_New_Equipment__c != null ? obj.DA_Reference_of_New_Equipment__c : null);
            String returnObdNo = encloseWithQuotes(obj.Return_OBD_No__c != null ? obj.Return_OBD_No__c : null);
            String returnInvoiceNo = encloseWithQuotes(obj.Return_Invoice_No__c != null ? obj.Return_Invoice_No__c : null);
            String returnSoNo = encloseWithQuotes(obj.Return_SO_No__c != null ? obj.Return_SO_No__c : null);
            String extn05Value = encloseWithQuotes(obj.Action_Taken_On_Defective_Machine__c != null ? obj.Action_Taken_On_Defective_Machine__c : null);
            String actionTaken = encloseWithQuotes(obj.Action_Taken_On_Defective_Machine__c != null ? obj.Action_Taken_On_Defective_Machine__c : null);
            String billedDealerNo = encloseWithQuotes(obj.Billed_Dealer_No__c != null ? obj.Billed_Dealer_No__c : null);
            String billedDealerName = encloseWithQuotes(obj.Billed_Dealer_Name__c != null ? obj.Billed_Dealer_Name__c : null);
            String customerId = encloseWithQuotes(
                obj.Work_Order__r != null && obj.Work_Order__r.Account != null ? 
                (obj.Work_Order__r.Account.Customer_Code__c != null ? obj.Work_Order__r.Account.Customer_Code__c :
                 obj.Work_Order__r.Account.SAP_Customer_Id__c != null ? obj.Work_Order__r.Account.SAP_Customer_Id__c :
                 obj.Work_Order__r.Account.Customer_ID__c != null ? obj.Work_Order__r.Account.Customer_ID__c : '') 
                : ''
            );
            String dispatchAddress = encloseWithQuotes(obj.Dispatch_To__c != null ? obj.Dispatch_To__c : null);
            String fgrCreatedDate = encloseWithQuotes(obj.CreatedDate != null ? obj.CreatedDate.format('yyyy-MM-dd HH:mm:ss') : '');
            String lastUpdateDate = encloseWithQuotes(obj.LastModifiedDate != null ? obj.LastModifiedDate.format('yyyy-MM-dd HH:mm:ss') : '');
            String failureMonth = '';
            String monthName = '';
            
            if (obj.CreatedDate != null) {
                DateTime fgrDateTime = obj.CreatedDate;
                Date fgrDate = fgrDateTime.date();
                
                failureMonth = encloseWithQuotes(String.valueOf(fgrDate.month()));  // Month Number
                monthName = encloseWithQuotes(fgrDateTime.format('MMMM', 'en_US'));  // Month Name
            } else {
                failureMonth = encloseWithQuotes('');
                monthName = encloseWithQuotes('');
            }
            
            String failureYear = '';
            
            if (obj.CreatedDate != null) {
                DateTime fgrDateTime = obj.CreatedDate;  
                Date fgrDate = fgrDateTime.date();  
                
                failureYear = encloseWithQuotes(String.valueOf(fgrDate.year()));  // Extract Year
            } else {
                failureYear = encloseWithQuotes('');
            }
            
            String odCreatedQuarter = '';
            
            if (obj.CreatedDate != null) {
                DateTime fgrDateTime = obj.CreatedDate;
                Date fgrDate = fgrDateTime.date();
                
                Integer monthNum = fgrDate.month();  // Extract month number (1-12)
                
                // Determine Quarter
                if (monthNum >= 1 && monthNum <= 3) {
                    odCreatedQuarter = encloseWithQuotes('Q4');
                } else if (monthNum >= 4 && monthNum <= 6) {
                    odCreatedQuarter = encloseWithQuotes('Q1');
                } else if (monthNum >= 7 && monthNum <= 9) {
                    odCreatedQuarter = encloseWithQuotes('Q2');
                } else if (monthNum >= 10 && monthNum <= 12) {
                    odCreatedQuarter = encloseWithQuotes('Q3');
                }
            } else {
                odCreatedQuarter = encloseWithQuotes('');
            }
            
            String fgrNo = encloseWithQuotes(
                obj.External_ID__c != null ? obj.External_ID__c : 
                (obj.FGR_Number__c != null ? obj.FGR_Number__c : null)
            );
            
            String orderStatus = encloseWithQuotes(obj.Status != null ? obj.Status : null);
            String pendingSdeApprovalDate = encloseWithQuotes(
                obj.CreatedBy != null && obj.CreatedBy.Name == 'Data Migration User' && obj.CaptureApprovalSentDatTime__c != null 
                ? obj.CaptureApprovalSentDatTime__c.format('yyyy-MM-dd HH:mm:ss') 
                : (obj.CreatedDate != null ? obj.CreatedDate.format('yyyy-MM-dd HH:mm:ss') : '')
            );
            String requesterBeCode = encloseWithQuotes(
                obj.CP_Code__c != null ? obj.CP_Code__c : 
                (obj.CP_Name__r != null && obj.CP_Name__r.CP_Code__c != null ? obj.CP_Name__r.CP_Code__c : 
                 (obj.Branch_Name__r != null && obj.Branch_Name__r.Branch_Code__c != null ? obj.Branch_Name__r.Branch_Code__c : null))
            );
            
            
            String requesterBeTypeCode = encloseWithQuotes('');
            if (!String.isBlank(obj.CP_Code__c) || (obj.CP_Name__r != null && obj.CP_Name__r.CP_Code__c != null)) {
                // If CP_Code__c or CP_Name__r.CP_Code__c exists, set requesterBeTypeCode to "dealer"
                requesterBeTypeCode = encloseWithQuotes('dealer');
            } else if (obj.Branch_Name__r != null && obj.Branch_Name__r.Branch_Code__c != null) {
                // If Branch_Name__r.Branch_Code__c exists, set requesterBeTypeCode to "Branch"
                requesterBeTypeCode = encloseWithQuotes('Branch');
            }
            String requesterBeSubTypeCode = encloseWithQuotes(obj.CP_Name__r.Type != null ? obj.CP_Name__r.Type : null);
            String updatedBy = encloseWithQuotes(obj.LastModifiedBy.Name != null ? obj.LastModifiedBy.Name : null);
            
            String workqueueCode = encloseWithQuotes('');
            String workqueueName = encloseWithQuotes('');
            String fgrPendingWith = encloseWithQuotes('');  // Declare fgrPendingWith
            
            // Check for Damage_Type__c
            if (obj.Damage_Type__c == 'Transit Damage') {
                if (obj.Status == 'Draft') {
                    workqueueCode = encloseWithQuotes(obj.CreatedBy.EmployeeNumber);
                    workqueueName = encloseWithQuotes(obj.CreatedBy.Name);  // Replace EmployeeNumber with Name
                } else if (obj.Status == 'Awaiting Approval From SDE') {
                    workqueueCode = encloseWithQuotes(obj.SDE__r.EmployeeNumber);
                    workqueueName = encloseWithQuotes(obj.SDE__r.Name);  // Replace EmployeeNumber with Name
                } else if (obj.Status == 'Awaiting Approval From AM') {
                    workqueueCode = encloseWithQuotes(obj.Sales_AM__r.EmployeeNumber);
                    workqueueName = encloseWithQuotes(obj.Sales_AM__r.Name);  // Replace EmployeeNumber with Name
                } else if (obj.Status == 'Awaiting Approval From RM') {
                    workqueueCode = encloseWithQuotes(obj.Sales_RM__r.EmployeeNumber);
                    workqueueName = encloseWithQuotes(obj.Sales_RM__r.Name);  // Replace EmployeeNumber with Name
                } else if (obj.Status == 'Awaiting Approval From AIH/AIDH' || obj.Status == 'Approval Pending From AIDH') {
                    workqueueCode = encloseWithQuotes(obj.AIDH__r.EmployeeNumber);
                    workqueueName = encloseWithQuotes(obj.AIDH__r.Name);  // Replace EmployeeNumber with Name
                } else if (obj.Status == 'PendingCFSApproval' || obj.Status == 'Approval Pending From CFS') {
                    workqueueCode = encloseWithQuotes(obj.CFS__r.EmployeeNumber);
                    workqueueName = encloseWithQuotes(obj.CFS__r.Name);  // Replace EmployeeNumber with Name
                }
            } else if (obj.Damage_Type__c == 'Non Transit Damage') {
                if (obj.Status == 'Draft') {
                    workqueueCode = encloseWithQuotes(obj.CreatedBy.EmployeeNumber);
                    workqueueName = encloseWithQuotes(obj.CreatedBy.Name);  // Replace EmployeeNumber with Name
                } else if (obj.Status == 'Awaiting Approval From SDE') {
                    workqueueCode = encloseWithQuotes(obj.SDE__r.EmployeeNumber);
                    workqueueName = encloseWithQuotes(obj.SDE__r.Name);  // Replace EmployeeNumber with Name
                } else if (obj.Status == 'Awaiting Approval From AM') {
                    workqueueCode = encloseWithQuotes(obj.Service_AM__r.EmployeeNumber);
                    workqueueName = encloseWithQuotes(obj.Service_AM__r.Name);  // Replace EmployeeNumber with Name
                } else if (obj.Status == 'Awaiting Approval From RM') {
                    workqueueCode = encloseWithQuotes(obj.Service_RM__r.EmployeeNumber);
                    workqueueName = encloseWithQuotes(obj.Service_RM__r.Name);  // Replace EmployeeNumber with Name
                } else if (obj.Status == 'Awaiting Approval From AIH/AIDH' || obj.Status == 'Approval Pending From AISDH' || obj.Status == 'Awaiting Approval From AISDH') {
                    workqueueCode = encloseWithQuotes(obj.AIH__r.EmployeeNumber);
                    workqueueName = encloseWithQuotes(obj.AIH__r.Name);  // Replace EmployeeNumber with Name
                } else if (obj.Status == 'PendingCFSApproval' || obj.Status == 'Approval Pending From CFS') {
                    workqueueCode = encloseWithQuotes(obj.CFS__r.EmployeeNumber);
                    workqueueName = encloseWithQuotes(obj.CFS__r.Name);  // Replace EmployeeNumber with Name
                }
            }
            String requesterBeName = encloseWithQuotes(obj.CreatedBy.Name!= null ? obj.CreatedBy.Name : null);
            String channelPartnerName = encloseWithQuotes(obj.CP_Name__r.Name != null ? obj.CP_Name__r.Name : null);
            String channelPartnerNo = encloseWithQuotes(obj.CP_Name__r.CP_Code__c != null ? obj.CP_Name__r.CP_Code__c : null);
            fgrPendingWith = workqueueName;
            String channelPartnerType = encloseWithQuotes(obj.CP_Name__r.Type != null ? obj.CP_Name__r.Type : null);
            String customerName = encloseWithQuotes(obj.Account.Name != null ? obj.Account.Name : null);
            String equipmentType = encloseWithQuotes(obj.Equipment_Type_General__c != null ? obj.Equipment_Type_General__c : null);
            String failureObservedAt = encloseWithQuotes(obj.Failure_Observed_At__c != null ? obj.Failure_Observed_At__c : null);
            String failureReason = encloseWithQuotes(obj.FGR_Reason__c != null ? obj.FGR_Reason__c : null);
            String fgrStatus = encloseWithQuotes(obj.Status != null ? obj.Status : null);
            String mainDefect = encloseWithQuotes(obj.Main_Defect_General__c != null ? obj.Main_Defect_General__c : null);
            String subDefect1 = encloseWithQuotes(obj.Sub_Defect_1_General__c != null ? obj.Sub_Defect_1_General__c : null);
            String subDefect2 = encloseWithQuotes(obj.Sub_Defect_2_General__c != null ? obj.Sub_Defect_2_General__c : null);
            String sdeFailureObservedAt = encloseWithQuotes(obj.Failure_Observed_At_SDE__c != null ? obj.Failure_Observed_At_SDE__c : null);
            String sdeEquipmentType = encloseWithQuotes(obj.Equipment_Type_New_SDE__c != null ? obj.Equipment_Type_New_SDE__c : null);
            String sdeMainDefect = encloseWithQuotes(obj.Main_Defect_New_SDE__c != null ? obj.Main_Defect_New_SDE__c : null);
            String sdeSubDefect1 = encloseWithQuotes(obj.Sub_Defect_1_New_SDE__c != null ? obj.Sub_Defect_1_New_SDE__c : null);
            String sdeSubDefect2 = encloseWithQuotes(obj.Sub_Defect_2_New_SDE__c != null ? obj.Sub_Defect_2_New_SDE__c : null);
            String recommendSalesReturn = encloseWithQuotes(obj.Recommend_Sales_Return__c != null ? obj.Recommend_Sales_Return__c : null);
            String fgrNoteRemark =  encloseWithQuotes(obj.Classification_Type__c != null ? obj.Classification_Type__c : null);
            String classificationType = encloseWithQuotes(obj.Classification_Type__c != null ? obj.Classification_Type__c : null);
            String invoiceDate = encloseWithQuotes(
                obj.Invoice_Date__c != null 
                ? DateTime.newInstance(obj.Invoice_Date__c, Time.newInstance(11, 0, 0, 0)).format('MM/dd/yyyy HH:mm:ss')
                : ''
            );
            
            String salesInvoiceNo = encloseWithQuotes(obj.Invoice_Number__c != null ? obj.Invoice_Number__c : null);
            String itemSerialId = encloseWithQuotes(obj.Product_Serial_Number__c  != null ? obj.Product_Serial_Number__c  : null);
            
            
            String branchName = '';
            
            // Priority 1: Account.Branch__r.Name
            if (obj.Account != null && obj.Account.Branch__r != null && obj.Account.Branch__r.Name != null) {
                branchName = encloseWithQuotes(obj.Account.Branch__r.Name);
            }
            // Priority 2: Work_Order__r.Branchh__r.Name
            else if (obj.Work_Order__r != null && obj.Work_Order__r.Branchh__r != null && obj.Work_Order__r.Branchh__r.Name != null) {
                branchName = encloseWithQuotes(obj.Work_Order__r.Branchh__r.Name);
            }
            // Priority 3: Case.Branch__r.Name
            else if (obj.Case != null && obj.Case.Branch__r != null && obj.Case.Branch__r.Name != null) {
                branchName = encloseWithQuotes(obj.Case.Branch__r.Name);
            }
            // Priority 4: Branch_Name__r.Name
            else if (obj.Branch_Name__r != null && obj.Branch_Name__r.Name != null) {
                branchName = encloseWithQuotes(obj.Branch_Name__r.Name);
            }
            // Fallback if all are null
            else {
                branchName = encloseWithQuotes('');
            }
            
            String branch =  '';
            String branchNo = '';
            
            // Priority 1: Account.Branch__r.Branch_Code__c
            if (obj.Account != null && obj.Account.Branch__r != null && obj.Account.Branch__r.Branch_Code__c != null) {
                branchNo = encloseWithQuotes(obj.Account.Branch__r.Branch_Code__c);
                branch = encloseWithQuotes(obj.Account.Branch__r.Branch_Code__c);
            }
            // Priority 2: Work_Order__r.Branchh__r.Branch_Code__c
            else if (obj.Work_Order__r != null && obj.Work_Order__r.Branchh__r != null && obj.Work_Order__r.Branchh__r.Branch_Code__c != null) {
                branchNo = encloseWithQuotes(obj.Work_Order__r.Branchh__r.Branch_Code__c);
                branch = encloseWithQuotes(obj.Work_Order__r.Branchh__r.Branch_Code__c);
            }
            // Priority 3: Case.Branch__r.Branch_Code__c
            else if (obj.Case != null && obj.Case.Branch__r != null && obj.Case.Branch__r.Branch_Code__c != null) {
                branchNo = encloseWithQuotes(obj.Case.Branch__r.Branch_Code__c);
                branch = encloseWithQuotes(obj.Case.Branch__r.Branch_Code__c);
            }
            // Priority 4: Branch_Name__r.Branch_Code__c
            else if (obj.Branch_Name__r != null && obj.Branch_Name__r.Branch_Code__c != null) {
                branchNo = encloseWithQuotes(obj.Branch_Name__r.Branch_Code__c);
                branch = encloseWithQuotes(obj.Branch_Name__r.Branch_Code__c);
            }
            // Fallback if all are null
            else {
                branchNo = encloseWithQuotes('');
                branch=encloseWithQuotes('');
            }
            
            String departmentName = null;
            String department = null;
            String serviceDepartment = null;
            
            if (obj.Case.Service_Division__r != null && 
                !String.isBlank(obj.Case.Service_Division__r.Department_Number__c)) {
                    departmentName = encloseWithQuotes(obj.Case.Service_Division__r.Department_Number__c);
                } else if (obj.Asset__r != null && obj.Asset__r.Service_Department_L__r != null) {
                    departmentName = encloseWithQuotes(obj.Asset__r.Service_Department_L__r.Name);
                } else {
                    departmentName = null;
                }
            
            // Assign the same value to department and serviceDepartment
            department = departmentName;
            serviceDepartment = departmentName;
            
            
            String departmentCode = encloseWithQuotes(obj.Service_Department__c != null ? obj.Service_Department__c : null);
            String sde = encloseWithQuotes(obj.SDE__r.EmployeeNumber != null ? obj.SDE__r.EmployeeNumber : null);
            String sdeName = encloseWithQuotes(obj.SDE__r.Name != null ? obj.SDE__r.Name : null);
            String salesDepartment = null;
            
            if (obj.Case.Sales_Division__r != null && !String.isBlank(obj.Case.Sales_Division__r.Name)) {
                salesDepartment = encloseWithQuotes(obj.Case.Sales_Division__r.Name);
            } 
            
            else if (obj.Asset__r != null && obj.Asset__r.Sales_Department_L__r != null && !String.isBlank(obj.Asset__r.Sales_Department_L__r.Name)) {
                salesDepartment = encloseWithQuotes(obj.Asset__r.Sales_Department_L__r.Name);
            } 
            
            else {
                salesDepartment = null;
            }
            
            String division = encloseWithQuotes(obj.Division__c != null ? obj.Division__c : null);
            String division1 = encloseWithQuotes('');
            String dateOfInstallation = encloseWithQuotes(
                obj.Work_Order__r.Asset.InstallDate != null 
                ? DateTime.newInstance(obj.Work_Order__r.Asset.InstallDate,Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd HH:mm:ss') 
                : ''
            );
            String daysCount = encloseWithQuotes(obj.Invoice_Ageing__c != null ? String.valueOf(obj.Invoice_Ageing__c) : null);
            
            String daysElapsed = encloseWithQuotes(obj.Age__c != null ? String.valueOf(obj.Age__c) : null);
            String dealerName = (obj.CP_Name__r != null && obj.CP_Name__r.Name != null) ? obj.CP_Name__r.Name :
            (obj.Branch__c != null) ? obj.Branch__c :
            (obj.Branch_Name__r != null && obj.Branch_Name__r.Name != null) ? obj.Branch_Name__r.Name :
            null;
            
            String srExtn02Code = (obj.Work_Order__r != null && obj.Work_Order__r.Obligation__c != null) ? obj.Work_Order__r.Obligation__c :
            (obj.Work_Order__r != null && obj.Work_Order__r.Asset_Obligation__c != null) ? obj.Work_Order__r.Asset_Obligation__c :
            (obj.Asset__r != null && obj.Asset__r.Asset_Obligation__c != null) ? obj.Asset__r.Asset_Obligation__c :
            null;
            
            String reasonCode = encloseWithQuotes(obj.FGR_Reason__c != null ? obj.FGR_Reason__c : null);
            String reasonDesc = encloseWithQuotes(obj.Description != null ? obj.Description : null);
            String reasonType = encloseWithQuotes(obj.Reason_of_Rejection__c != null ? obj.Reason_of_Rejection__c : null);
            String ticketNumber = encloseWithQuotes(obj.Work_Order__r.Ticket_Number_Read_Only__c != null ? obj.Work_Order__r.Ticket_Number_Read_Only__c : null);
            String isNamo = (obj.Account != null && obj.Account.IsNamo__c) ? 'Y' : 'N';
            
            String parentCode = encloseWithQuotes(obj.CP_Name__r.Parent.CP__r.CP_Code__c != null ? obj.CP_Name__r.Parent.CP__r.CP_Code__c : null);
            String region = encloseWithQuotes(obj.Branch_Name__r.Region__c != null ? obj.Branch_Name__r.Region__c : null);
            String lastUpdatedDate = encloseWithQuotes(
                obj.Lastmodifieddate != null 
                ? obj.Lastmodifieddate.format('yyyy-MM-dd HH:mm:ss') 
                : ''
            );
            
            String modelName = encloseWithQuotes(obj.Asset__r.Product2.Name != null ? obj.Asset__r.Product2.Name : null);
            String modelNo = encloseWithQuotes(
                obj.Product_Name__r != null && obj.Product_Name__r.ProductCode != null 
                ? obj.Product_Name__r.ProductCode 
                : (obj.Model_Number__c != null 
                   ? obj.Model_Number__c 
                   : null)
            );
            
            String productFamily = encloseWithQuotes(
                obj.Asset__r != null && obj.Asset__r.Product_Family__r != null && obj.Asset__r.Product_Family__r.Code__c != null 
                ? obj.Asset__r.Product_Family__r.Code__c 
                : (obj.Product_Name__r != null && obj.Product_Name__r.Product_Family__r != null && obj.Product_Name__r.Product_Family__r.Code__c != null 
                   ? obj.Product_Name__r.Product_Family__r.Code__c 
                   : '')
            );
            String productFamilyName = encloseWithQuotes(
                obj.Asset__r != null && obj.Asset__r.Product_Family__r != null && obj.Asset__r.Product_Family__r.Name != null 
                ? obj.Asset__r.Product_Family__r.Name 
                : (obj.Product_Name__r != null && obj.Product_Name__r.Product_Family__r != null && obj.Product_Name__r.Product_Family__r.Name != null 
                   ? obj.Product_Name__r.Product_Family__r.Name 
                   : '')
            );
            String productSubFamily = encloseWithQuotes(
                obj.Asset__r != null && obj.Asset__r.Product_Sub_Family__r != null && obj.Asset__r.Product_Sub_Family__r.Code__c != null 
                ? obj.Asset__r.Product_Sub_Family__r.Code__c 
                : (obj.Product_Name__r != null && obj.Product_Name__r.Product_Sub_Family__r != null && obj.Product_Name__r.Product_Sub_Family__r.Code__c != null 
                   ? obj.Product_Name__r.Product_Sub_Family__r.Code__c 
                   : '')
            );
            String productSubFamilyName = encloseWithQuotes(
                obj.Asset__r != null && obj.Asset__r.Product_Sub_Family__r != null && obj.Asset__r.Product_Sub_Family__r.Name != null 
                ? obj.Asset__r.Product_Sub_Family__r.Name 
                : (obj.Product_Name__r != null && obj.Product_Name__r.Product_Sub_Family__r != null && obj.Product_Name__r.Product_Sub_Family__r.Name != null 
                   ? obj.Product_Name__r.Product_Sub_Family__r.Name 
                   : '')
            );
            String productSerialNo = encloseWithQuotes(
                obj.Product_Serial_Number__c != null ? obj.Product_Serial_Number__c
                : (obj.Asset__r.SerialNumber != null 
                   ? obj.Asset__r.SerialNumber 
                   : null)
            );
            String createdDate = encloseWithQuotes(obj.CreatedDate != null ? obj.CreatedDate.format('yyyy-MM-dd HH:mm:ss') : '');
            String updatedDate = encloseWithQuotes(obj.LastModifiedDate != null ? obj.LastModifiedDate.format('yyyy-MM-dd HH:mm:ss') : '');
            String component = encloseWithQuotes(obj.Asset__r.Component_Id__c != null ? obj.Asset__r.Component_Id__c : null);
            String purchaseDate = encloseWithQuotes(
                obj.Purchased_Date__c != null 
                ? DateTime.newInstance(obj.Purchased_Date__c,Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd HH:mm:ss') 
                : ''
            );
            
            // Construct row string
            String rowStr = String.join(new List<String>{
                purchaseOrderId, poItemId, createdBy, requestType, estimatedRepairCost, daReference, returnObdNo, returnInvoiceNo, returnSoNo, extn05Value,
                    actionTaken, billedDealerNo, billedDealerName, customerId, dispatchAddress, fgrCreatedDate, lastUpdateDate, failureMonth, monthName, failureYear,
                    odCreatedQuarter, fgrNo, orderStatus, pendingSdeApprovalDate, requesterBeCode, requesterBeTypeCode, requesterBeSubTypeCode, updatedBy,
                    workqueueCode, workqueueName, requesterBeName, channelPartnerName, channelPartnerNo, fgrPendingWith, channelPartnerType, customerName, 
                    equipmentType, failureObservedAt, failureReason, fgrStatus, mainDefect, subDefect1, subDefect2, sdeFailureObservedAt, sdeEquipmentType, 
                    sdeMainDefect, sdeSubDefect1, sdeSubDefect2, recommendSalesReturn, fgrNoteRemark, classificationType, invoiceDate, salesInvoiceNo, 
                    itemSerialId, branchName, branch, branchNo, departmentName, department, serviceDepartment, departmentCode, sde, sdeName, salesDepartment, 
                    division, division1, dateOfInstallation, daysCount, daysElapsed, dealerName, srExtn02Code, reasonCode, reasonDesc, reasonType, ticketNumber, 
                    isNamo, parentCode, region, lastUpdatedDate, modelName, modelNo, productFamily, productFamilyName, productSubFamily, productSubFamilyName, 
                    productSerialNo, createdDate, updatedDate, component, purchaseDate
                    }, ',');
            
            
            csvRowValues.add(rowStr);
        }
        
        csvColumnHeader = '\uFEFF' + String.join(new List<String>{
            'purchase_order_04_id', 'po_item_id', 'created_by', 'request_type', 'estimated_repair_cost', 
                'da_reference_of_new_equipment', 'return_obd_no', 'return_invoice_no', 'return_so_no', 'extn05Value',
                'action_taken_on_defective_machine', 'billed_dealer_no', 'billed_dealer_name', 'customer_id', 
                'dispatch_address', 'fgr_created_date', 'last_update_date', 'failure_month', 'month_name', 'failure_year',
                'od_created_quarter', 'fgr_no', 'order_status', 'pending_sde_approval_date', 'requester_be_code', 
                'requester_be_type_code', 'requester_be_sub_type_code', 'updated_by', 'workqueue_code', 'workqueue_name', 
                'requester_be_name', 'channel_partner_name', 'channel_partner_no', 'fgr_pending_with', 'channel_partner_type', 
                'customer_name', 'equipment_type', 'failure_observed_at', 'failure_reason', 'fgr_status', 'main_defect_extn06Code_name',
                'sub_defect_1', 'sub_defect_2', 'sde_failure_observed_at', 'sde_equipment_type', 'sde_main_defect', 'sde_sub_defect_1', 
                'sde_sub_defect_2', 'recommend_sales_return', 'fgr_note_remark', 'classification_type', 'invoice_date', 'sales_invoice_no', 
                'item_serial_id', 'branch_name', 'branch', 'branch_no', 'department_name', 'department', 'service_department', 'department_code', 
                'sde', 'sde_name', 'sales_department', 'division', 'division1', 'date_of_installation', 'days_count', 'days_elapsed', 'dealer_name', 
                'sr_extn02Code', 'reason_code', 'reason_desc', 'reason_type', 'ticket_number', 'is_namo', 'parent_code', 'region', 'last_updated_date', 
                'model_name', 'model_no', 'product_family', 'product_family_name', 'product_sub_family', 'product_sub_family_name', 'product_serial_no', 
                'created_date', 'updated_date', 'component', 'purchase_date'
                }, ',') + '\n';
        
        
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
        fileName = 'FNAME_FGR_FROM_' + formattedStartDate + '_TO_' + formattedEndDate + '_EXTTS_' + formattedDateTime + '.csv';
        
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
        
    }
}