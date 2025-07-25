public class Changed_Service_Contract_Line_Batch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts  {
    
    public List<Daily_Job_Documents__c> dailyJobDocumetList = new List<Daily_Job_Documents__c>();
    public String csvColumnHeader;
    public String query ;
    String file = '';
    String fileName = '';
    public List<String> csvRowValues = new List<String>();
    // Flag to determine whether to enqueue the S3 job or not
    public Boolean isTestContext = false;
    public Date customStartDate;  // Custom start date for the file name
    public Date customEndDate;  
    public String folderName;
    
    
    public Changed_Service_Contract_Line_Batch(Boolean overrideQuery, String query2,Date customStartDate, Date customEndDate, String folderName ) {
        
        query = 'SELECT Id,ServiceContract.Original_End_Date__c, ' +
            'ServiceContract.Quote1__r.Last_Year_Price_for_Asset__c,ServiceContract.Department__r.Name,Asset.Model_Number__c,ServiceContract.Contract_Category__c,ServiceContract.GrandTotal,ServiceContract.TotalPrice,ServiceContract.Quote0__r.Last_Year_Price_for_Asset__c, ServiceContract.Opportunity__r.Department__r.Department_Number__c,ServiceContract.ContractNumber,ServiceContract.Quote1__c,ServiceContract.Quote0__c,ServiceContract.Quote0__r.QuoteNumber,ServiceContract.Quote1__r.Name,Asset.Product_Family__r.Name,ServiceContract.Id,ServiceContract.BillingStateCode,ServiceContract.Opportunity__r.Document_Required__c,ServiceContract.Opportunity__r.Document_List__c,Asset.Account.Name,Asset.CP__r.Type, Asset.Product_Family__r.Code__c, Asset.Product_Sub_Family__r.Name, Asset.Product_Sub_Family__r.Code__c, ' +
            'CreatedBy.Name, ServiceContract.Total_Download_Value__c,Asset.Branch__r.Branch_Code__c,ServiceContract.Billing_Due_Period__c,ServiceContract.Total_price__c,ServiceContract.LastModifiedBy.Name,LastModifiedBy.Name,ServiceContract.CreatedDate,ServiceContract.CreatedBy.Name,ServiceContract.Account.Industry, CreatedDate,ServiceContract.SAP_Contract_Number__c,LastModifiedDate, ' +
            'ServiceContract.StartDate,ServiceContract.Account.Name,Asset.CP__r.CP_Code__c,Asset.Account.SAP_Customer_Id__c,ServiceContract.Quote0__r.Kerala_Cess__c,ServiceContract.Ship_to_Party__r.Customer_ID__c,ServiceContract.Account.Parent.SAP_Customer_Id__c,ServiceContract.Kerla_Cess__c,Asset.Account.Customer_ID__c,ServiceContract.Quote1__r.Overall_Price_Change__c, ServiceContract.EndDate,Asset.Product2.Name,ServiceContract.Account.Parent.Customer_Code__c,ServiceContract.Account.Sub_Segment__c,Channel_Partner_Type__c, ' +
            'ServiceContract.Name,ServiceContract.Standard_Downloading_Value__c,Standard_Downloading_Value__c,ServiceContract.PO_Total_Value__c,ServiceContract.Custom_AMC_PMS_Events__c,ServiceContract.Account.Parent.Customer_ID__c,ServiceContract.Quote0__r.Overall_Price_Change_Formula__c,ServiceContract.Account.Group__c,ServiceContract.Ship_to_Party__r.Customer_Code__c,ServiceContract.Opportunity__r.Name,ServiceContract.CP__r.Type,ServiceContract.Quote1__r.Proposed_Contract_Value_Formula__c,ServiceContract.Quote0__r.Proposed_Contract_Value_Formula__c,ServiceContract.Quote1__r.HSN_SAC_code__c,ServiceContract.Quote0__r.HSN_SAC_code_New__c,ServiceContract.Comment__c, ' +
            'ServiceContract.Contract_Type__c,ServiceContract.EGM__c,ServiceContract.Opportunity__r.Department__r.Name,ServiceContract.Kerela_Cess__c,ServiceContract.Plant__r.Warehouse_Code__c,ServiceContract.Discount__c,ServiceContract.Plant__r.Name,ServiceContract.Quote0__r.Quote_Number_Backend__c, ' +
            'ServiceContract.PO_Date__c, Asset.Actual_Capacity__c,UnitPrice,ListPrice,ServiceContract.Quote0__r.Discount__c,Asset.Branch__r.Name,ServiceContract.Account.Customer_ID__c,Asset.Product2.Product_Sub_Family__r.Code__c,ServiceContract.Quote1__r.Discount__c,ServiceContract.EGM_Estimated_Gross_Margin__c,ServiceContract.PO_Number__c,  ' +
            'ServiceContract.ActivationDate,ServiceContract.Opportunity__r.SDE__r.Name,ServiceContract.Contact.FirstName,ServiceContract.Billing_Frequency_Period__c,ServiceContract.Contact.LastName, ' +
            'ServiceContract.Quote1__r.Quote_Number_Backend__c,ServiceContract.Quote0__r.Overall_Price_Change_Currency__c,Asset.Product2.Product_Sub_Family__r.Name,ServiceContract.Quote0__r.EGM_Formula__c,ServiceContract.Quote1__r.EGM_Formula__c,ServiceContract.Modification_Status__c,ServiceContract.Quote0__r.EGM_Percent_Formula__c,ServiceContract.Quote1__r.EGM_Percent_Formula__c,ServiceContract.Quote0__r.Net_Contract_Value_Currency__c ,ServiceContract.Opportunity__r.Contact__r.Email,ServiceContract.Quote1__r.Net_Contract_Value_Currency__c ,ServiceContract.Quote1__r.Overall_Price_Change_Currency__c , ' +
            'ServiceContract.Branch__r.Name,Asset.Capacity__c, ServiceContract.Branch__r.Branch_Code__c, ' +
            'ServiceContract.Branch__r.Warehouse__r.Name,Asset.Product2.Capacity__c,Unit_Price__c,ServiceContract.Ship_to_Party__r.SAP_Customer_Id__c,ServiceContract.Account.SAP_Customer_Id__c, ServiceContract.Branch__r.Warehouse__r.Warehouse_Code__c, ' +
            'ServiceContract.Division__r.AICH__r.Name, ' +
            'ServiceContract.Opportunity__r.Contract_Category__c,ServiceContract.Grand_Total__c,ServiceContract.Opportunity__r.Branch_Commericial__r.EmployeeNumber,ServiceContract.Erp_Contract_No__c, ServiceContract.Opportunity__r.Customer_Invoice_Text__c, ' +
            'ServiceContract.Opportunity__r.PO_Receipt_Date__c,TotalPrice, ' +
            'ServiceContract.Opportunity__r.All_India_Commericial_Head__r.Name,ServiceContract.Account.GST_Number__c,ServiceContract.Download_Value_For_Last_Year__c, ServiceContract.Opportunity__r.All_India_Commericial_Head__r.EmployeeNumber, ' +
            'ServiceContract.Opportunity__r.All_India_Head__r.Name,ServiceContract.Opportunity__r.All_India_Head__r.EmployeeNumber, ' +
            'ServiceContract.Opportunity__r.Regional_Manager__r.Name,Download_Value1__c,Download_Value__c,ServiceContract.Opportunity__r.Area_Manager__r.Name, ServiceContract.Opportunity__r.Regional_Manager__r.EmployeeNumber, ' +
            'Asset.CP__r.Name,assetId, ' +
            'ServiceContract.Contact.Phone, ServiceContract.Opportunity__r.Amount,ServiceContract.Opportunity__r.Channel_Partner_Account__c,ServiceContract.CP__r.Name,   ' +
            'ServiceContract.Quote0__r.Billing_Due_Period__c,ServiceContract.External_Id__c,ServiceContract.Quote1__r.Billing_Due_Period__c,Asset.Product2.Product_Family__r.Name,ServiceContract.CP__r.CP_Code__c,ServiceContract.Opportunity__r.PO_Total_Value__c,ServiceContract.Opportunity__r.Area_Manager__r.EmployeeNumber,ServiceContract.Opportunity__r.Branch_Commericial__r.Name, ServiceContract.Quote0__r.Billing_Frequency_Period__c,ServiceContract.Quote1__r.Billing_Frequency_Period__c, ' +
            'ServiceContract.Account.Customer_Code__c,ServiceContract.Quote1__r.Payment_Credit_Days__c,Asset.Product2.Product_Family__r.Code__c,ServiceContract.Quote0__r.Payment_Credit_Days__c,ServiceContract.Quote0__r.Final_Net_Contract_Value_Curr__c, ' +
            'ServiceContract.Quote0__r.Kerala_Cess_Currency__c, ' +
            'ServiceContract.Opportunity__r.SMH__r.Name,ServiceContract.Quote1__r.Kerela_Cess__c,ServiceContract.Opportunity__r.SMH__r.EmployeeNumber, ' +
            'ServiceContract.Opportunity__r.SME__r.Name,ServiceContract.Department__r.Department_Number__c,ServiceContract.Contact.Department_lookup__r.Department_Number__c, ServiceContract.Opportunity__r.SME__r.EmployeeNumber, ' + 
            'Asset.SerialNumber, Asset.Component_Id__c, Asset.Product_Model__c, ' + 
            'Asset.Account.Customer_Code__c,ServiceContract.Opportunity__r.SDE__r.EmployeeNumber,ServiceContract.Quote1__r.Kerela_Cess_Percent__c, Asset.Account.CP_Code__c, Asset.Account.CP_Name__c, ' +
            'ServiceContract.Contact.Email,Asset.Age_Of_Machine__c,ServiceContract.Quote1__r.CGST__c,ServiceContract.Quote0__r.UGST__c,ServiceContract.Quote0__r.SGST__c,ServiceContract.Quote0__r.IGST__c,ServiceContract.Quote0__r.CGST__c,ServiceContract.Quote1__r.UGST__c,ServiceContract.Quote1__r.SGST__c,ServiceContract.Quote1__r.IGST__c, Asset.Account.Phone, ' +
            'ServiceContract.BillingStreet,ServiceContract.Quote0__r.Revise_Total_Downloading_Value__c,ServiceContract.Quote1__r.Revise_Total_Downloading_Value__c,ServiceContract.Quote1__r.Total_Downloading_Value_RollUp__c,ServiceContract.Quote0__r.Total_Download_Value_Rollup__c,ServiceContract.BillingCity,ServiceContract.BillingState,ServiceContract.BillingPostalCode,ServiceContract.BillingCountryCode,ServiceContract.BillingCountry, ' +
            'Asset.Account.FirstName, Asset.Account.LastName, ' +
            'Product2.Capacity_UOM__c,Product2.Name,ServiceContract.Quote1__r.Id,ServiceContract.Quote0__r.Id, ' +
            'ServiceContract.HSN_SAC_code__c,ServiceContract.Quote0__r.Hike_compared_to_last_year__c,ServiceContract.Terms_of_Payment_Customer__c,ServiceContract.Quote1__r.Hike_compared_to_last_year__c,ServiceContract.Quote1__r.Gross_Contract_Value_Currency__c,ServiceContract.Quote1__r.Final_Net_Contract_Value_Currency__c,ServiceContract.Quote0__r.Gross_Contract_Value_Currency__c,ServiceContract.Events_Created__c ' +
            'FROM ContractLineItem where (LastModifiedDate=Yesterday or ServiceContract.LastModifiedDate =YESTERDAY) and ServiceContract.Opportunity__r.Do_Not_Extract__c=false';
        
        if(overrideQuery){ 
            query=query2;   
        }
        this.customStartDate = customStartDate;  // Store the custom start date
        this.customEndDate = customEndDate;
        this.folderName = folderName;
    }
    public Changed_Service_Contract_Line_Batch(Boolean overrideQuery, String customQuery, String folderName) {
        this(overrideQuery, customQuery, null, null, folderName);  // Default to null for custom dates
    }
    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        
        
        
        return Database.getQueryLocator(query);
        // Utility method to handle enclosing values with quotes and replacing new lines
        
    }
    private String encloseWithQuotes(String value) {
        // Handle null and empty values
        if (value == null || value.trim() == '') {
            return '';  // Return empty quotes for null or empty values
        }
        // Replace newlines and carriage returns with a space to prevent row shifting
        value = value.replaceAll('[\\r\\n]+', ' ');
        
        // Preserve the original string formatting exactly as it is from Salesforce
        String originalValue = String.valueOf(value);
        
        // Enclose in quotes if it contains a comma or quotes
        if (originalValue.contains(',') || originalValue.contains('"')) {
            originalValue = '"' + originalValue.replaceAll('"', '""') + '"';  // Escape any existing quotes
        }
        return originalValue;
    }
    
    public void execute(Database.BatchableContext BC, List<ContractLineItem> scope) {
        
        // Reset the csvRowValues and file variables for each execution
        csvRowValues.clear();
        file = '';
        // Retrieve or create a Daily Job Document
        List<Daily_Job_Documents__c> existingDocs = [SELECT Id, CreatedDate FROM Daily_Job_Documents__c WHERE CreatedDate = TODAY];
        
        if (existingDocs.isEmpty()) {
            Daily_Job_Documents__c newDoc = new Daily_Job_Documents__c();
            newDoc.Name = 'Daily Job ' + Date.today().year() + '-' + Date.today().month() + '-' + Date.today().day();
            insert newDoc;
            dailyJobDocumetList.add(newDoc);
            //System.debug('New Daily Job Document created with ID: ' + newDoc.Id);
        } else {
            dailyJobDocumetList = existingDocs;
            //System.debug('Reusing existing Daily Job Document with ID: ' + dailyJobDocumetList[0].Id);
        }
        
        // Step 1: Retrieve all ServiceContract Ids from ContractLineItem records
        Set<Id> serviceContractIds = new Set<Id>();
        for (ContractLineItem cli : scope) {
            if (cli.ServiceContract != null) {
                serviceContractIds.add(cli.ServiceContract.Id);
            }
        }
        
        // Initialize a map to store Warranty_Term_Name__c for each ServiceContract
        Map<Id, String> serviceContractWarrantyMap = new Map<Id, String>();
        
        // Step 2: Query Asset_Warranties__r for the ServiceContracts
        if (!serviceContractIds.isEmpty()) {
            List<AssetWarranty> warranties = [SELECT Warranty_Term_Name__c, Service_Contract__c FROM AssetWarranty WHERE Service_Contract__c IN :serviceContractIds and WarrantyTerm.WarrantyType='AMC'];
            
            // Map the ServiceContract Ids to their corresponding Warranty_Term_Name__c
            for (AssetWarranty warranty : warranties) {
                if (warranty.Warranty_Term_Name__c != null) {
                    serviceContractWarrantyMap.put(warranty.Service_Contract__c, warranty.Warranty_Term_Name__c);
                }
            }
        }
        
        // Initialize maps for PMS events and counts
        Map<Id, Boolean> pmsScheduleMap = new Map<Id, Boolean>();
        Map<Id, Integer> pmsEventCountMap = new Map<Id, Integer>();
        
        // Step 1: Collect Opportunity IDs from the scope
        Set<Id> opportunityIds = new Set<Id>();
        for (ContractLineItem cli : scope) {
            if (cli.ServiceContract != null && cli.ServiceContract.Opportunity__c != null) {
                opportunityIds.add(cli.ServiceContract.Opportunity__c);
            }
        }
        
        // Step 2: Query PMS_Schedule__c for the collected Opportunity IDs
        if (!opportunityIds.isEmpty()) {
            List<PMS_Schedule__c> pmsSchedules = [
                SELECT Id, Opportunity__c 
                FROM PMS_Schedule__c 
                WHERE Opportunity__c IN :opportunityIds
            ];
            
            // Populate the maps with data from PMS_Schedule__c
            for (PMS_Schedule__c pms : pmsSchedules) {
                pmsScheduleMap.put(pms.Opportunity__c, true); // Mark Opportunity as having PMS schedules
                if (!pmsEventCountMap.containsKey(pms.Opportunity__c)) {
                    pmsEventCountMap.put(pms.Opportunity__c, 0);
                }
                pmsEventCountMap.put(pms.Opportunity__c, pmsEventCountMap.get(pms.Opportunity__c) + 1); // Increment event count
            }
        }
        
        // Step 1: Retrieve related QuoteLineItem and SBQQ__QuoteLine__c records outside the loop
        Set<Id> quoteIds = new Set<Id>();
        Set<Id> assetIds = new Set<Id>();
        for (ContractLineItem cli : scope) {
            if (cli.ServiceContract != null) {
                quoteIds.add(cli.ServiceContract.Quote0__c);  // Add Sales Quote Id
                quoteIds.add(cli.ServiceContract.Quote1__c);  // Add CPQ Quote Id
            }
            if (cli.AssetId != null) {
                assetIds.add(cli.AssetId);  // Collect Asset IDs
            }
        }
        
        
        // Initialize maps to hold the results of SOQL queries
        Map<String, List<QuoteLineItem>> quoteLineItemsMap = new Map<String, List<QuoteLineItem>>();
        Map<String, List<SBQQ__QuoteLine__c>> sbqqQuoteLineMap = new Map<String, List<SBQQ__QuoteLine__c>>();
        
        // Step 2: Query QuoteLineItems and SBQQ__QuoteLine__c with Asset filter
        if (!quoteIds.isEmpty() && !assetIds.isEmpty()) {
            // Query for QuoteLineItem and map by QuoteId
            List<QuoteLineItem> quoteLineItems = [
                SELECT Id, ListPrice, UnitPrice, Discount, Asset__c, Revised_Download_Value__c, Previous_Contract_Price__c, 
                Sell_Price__c, Standard_Price_for_Asset__c, Hike_compared_to_last_year__c, Last_Year_Price_for_Asset__c, 
                TotalPrice, Downloading_Value_for_Last_Year__c, LineNumber, Current_Year_Margin__c, 
                last_year_margin_downloading__c, Standard_Downloading_Value__c, QuoteId 
                FROM QuoteLineItem 
                WHERE QuoteId IN :quoteIds AND Asset__c IN :assetIds
            ];
            for (QuoteLineItem qli : quoteLineItems) {
                if (!quoteLineItemsMap.containsKey(qli.QuoteId)) {
                    quoteLineItemsMap.put(qli.QuoteId, new List<QuoteLineItem>());
                }
                quoteLineItemsMap.get(qli.QuoteId).add(qli);
            }
            
            
            // Query for SBQQ__QuoteLine__c and map by SBQQ__Quote__c
            List<SBQQ__QuoteLine__c> sbqqQuoteLines = [
                SELECT Id, Asset__c, Total__c, SBQQ__Discount__c, Standard_Price_for_Asset__c, Previous_Contract_Price__c, 
                Revised_Download_Value__c, Last_Year_Price_for_Asset__c, Hike_compared_to_last_year__c, SBQQ__NetPrice__c, 
                SBQQ__NetTotal__c, Downloading_Value_for_Last_Year__c, SBQQ__ListPrice__c, Name, Current_Year_Margin__c, 
                last_year_margin_downloading__c, Sell_Price__c, Standard_Downloading_Value__c, SBQQ__Quote__c
                FROM SBQQ__QuoteLine__c 
                WHERE SBQQ__Quote__c IN :quoteIds AND Asset__c IN :assetIds
            ];
            for (SBQQ__QuoteLine__c sq : sbqqQuoteLines) {
                if (!sbqqQuoteLineMap.containsKey(sq.SBQQ__Quote__c)) {
                    sbqqQuoteLineMap.put(sq.SBQQ__Quote__c, new List<SBQQ__QuoteLine__c>());
                }
                sbqqQuoteLineMap.get(sq.SBQQ__Quote__c).add(sq);
            }
            
            
        }
        
        for (ContractLineItem cli : scope) {
            
            
            //System.debug('New Daily Job Document created with ID: ' + cli.ServiceContract.Quote0__r.QuoteNumber);
            //System.debug('New Daily Job Document created with ID: ' + cli.ServiceContract.Quote1__r.Name );
            
            //System.debug('New Daily Job Document created with ID: ' + quoteno);
            String AccountID = '';
            
            if (cli.ServiceContract != null && cli.ServiceContract.Account != null) {
                String accountIdRaw = cli.ServiceContract.Account.Id;
                
                
                
                // Validate ID length to ensure it's a valid Salesforce ID
                if (accountIdRaw != null && (accountIdRaw.length() == 15 || accountIdRaw.length() == 18)) {
                    AccountID = encloseWithQuotes(accountIdRaw);
                } else {
                    // Log invalid ID scenario
                    
                    AccountID = encloseWithQuotes(''); // Fallback to empty quotes for invalid IDs
                }
            } else {
                // Log null Account or ServiceContract scenario
                
                AccountID = encloseWithQuotes('');
            }
            
            
            String oppname = encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.Opportunity__r.Name != null ? cli.ServiceContract.Opportunity__r.Name : '');
            String amc= encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.External_Id__c != null ? cli.ServiceContract.External_Id__c : '');
            String sfdcamcid=encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.ContractNumber != null ? cli.ServiceContract.ContractNumber : '');
            //encloseWithQuotes(cli.ServiceContract.External_Id__c != null ? cli.ServiceContract.External_Id__c : ''); 
            String erpContractNo = encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.SAP_Contract_Number__c != null ? cli.ServiceContract.SAP_Contract_Number__c : '');
            String actuators = encloseWithQuotes('');
            String additionalEquipment = encloseWithQuotes('');
            String additionalEquipmentAmount = encloseWithQuotes('');
            String advanceReceived = encloseWithQuotes('');
            String age =encloseWithQuotes(String.valueOf(cli.Asset.Age_Of_Machine__c != null  ? cli.Asset.Age_Of_Machine__c : 0));
            String areaHead = encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.Opportunity__r != null && cli.ServiceContract.Opportunity__r.Area_Manager__r.EmployeeNumber != null ? String.valueOf(cli.ServiceContract.Opportunity__r.Area_Manager__r.EmployeeNumber) : '');
            String areaHeadName = encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.Opportunity__r != null && cli.ServiceContract.Opportunity__r.Area_Manager__r.Name != null ? String.valueOf(cli.ServiceContract.Opportunity__r.Area_Manager__r.Name) : '');
            String billToPartyCustomerGroup = '';
            if ('NAMO'.equals(cli.ServiceContract.Account.Group__c)) {
                billToPartyCustomerGroup = '01';  // Set to '01' if the Group is NAMO
            } else {
                billToPartyCustomerGroup = '';  // Set to blank for anything else
            }
            billToPartyCustomerGroup = encloseWithQuotes(billToPartyCustomerGroup);
            
            String billToPartyFirstName = encloseWithQuotes(
                String.valueOf(
                    cli.ServiceContract != null && cli.ServiceContract.Account != null 
                    ? cli.ServiceContract.Account.Name 
                    : ''
                )
            );
            //encloseWithQuotes(cli.ServiceContract.Contact.FirstName != null ? cli.ServiceContract.Contact.FirstName : '');
            String billToPartyLastName =encloseWithQuotes('');// encloseWithQuotes(cli.ServiceContract.Contact.LastName != null ? cli.ServiceContract.Contact.LastName : '');
            String billToPartyEmail = encloseWithQuotes(cli.ServiceContract.Opportunity__r.Contact__r.Email != null ? cli.ServiceContract.Opportunity__r.Contact__r.Email : '');
            
            String bms = encloseWithQuotes('');//
            String commercialExecutive = encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.Opportunity__r.Branch_Commericial__r.EmployeeNumber != null ? cli.ServiceContract.Opportunity__r.Branch_Commericial__r.EmployeeNumber : '');
            String commercialExecutiveName = encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.Opportunity__r.Branch_Commericial__r.Name != null ? cli.ServiceContract.Opportunity__r.Branch_Commericial__r.Name : '');
            
            String contactDepartment =encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.Contact.Department_lookup__r.Department_Number__c != null ? cli.ServiceContract.Contact.Department_lookup__r.Department_Number__c : '');
            
            
            
            String customerSector = encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.Account.Industry != null ? cli.ServiceContract.Account.Industry : '');
            String customerSubSegment = encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.Account.Sub_Segment__c != null ? cli.ServiceContract.Account.Sub_Segment__c : '');
            String deliveryExecutive = encloseWithQuotes(cli.ServiceContract.Opportunity__r.SDE__r.EmployeeNumber != null ? cli.ServiceContract.Opportunity__r.SDE__r.EmployeeNumber : '');
            String deliveryExecutiveName = encloseWithQuotes(cli.ServiceContract.Opportunity__r.SDE__r.Name != null ? cli.ServiceContract.Opportunity__r.SDE__r.Name : '');
            
            String downloadingDeviation = encloseWithQuotes('');
            String dutyUsage = encloseWithQuotes('');
            String gstRate = encloseWithQuotes('');
            
            if (cli.ServiceContract != null) {
                Decimal cgst = null, igst = null, sgst = null, ugst = null;
                
                // Check and retrieve from Quote1__r (CPQ Quote)
                if (cli.ServiceContract.Quote1__r != null) {
                    cgst = cli.ServiceContract.Quote1__r.CGST__c;
                    igst = cli.ServiceContract.Quote1__r.IGST__c;
                    sgst = cli.ServiceContract.Quote1__r.SGST__c;
                    ugst = cli.ServiceContract.Quote1__r.UGST__c;
                } 
                // Check and retrieve from Quote0__r (Sales Quote)
                else if (cli.ServiceContract.Quote0__r != null) {
                    cgst = cli.ServiceContract.Quote0__r.CGST__c;
                    igst = cli.ServiceContract.Quote0__r.IGST__c;
                    sgst = cli.ServiceContract.Quote0__r.SGST__c;
                    ugst = cli.ServiceContract.Quote0__r.UGST__c;
                }
                
                // Calculate total GST rate if at least one value is present
                if (cgst != null || igst != null || sgst != null || ugst != null) {
                    Decimal totalGstRate = (cgst != null ? cgst : 0) + (igst != null ? igst : 0) + 
                        (sgst != null ? sgst : 0) + (ugst != null ? ugst : 0);
                    gstRate = encloseWithQuotes(String.valueOf(totalGstRate));
                }
            }
            
            String cgstValue = encloseWithQuotes(
                cli.ServiceContract != null && cli.ServiceContract.Quote1__r != null && cli.ServiceContract.Quote1__r.CGST__c != null
                ? String.valueOf(cli.ServiceContract.Quote1__r.CGST__c)
                : cli.ServiceContract != null && cli.ServiceContract.Quote0__r != null && cli.ServiceContract.Quote0__r.CGST__c != null
                ? String.valueOf(cli.ServiceContract.Quote0__r.CGST__c)
                : ''
            );
            
            String sgstValue = encloseWithQuotes(
                cli.ServiceContract != null && cli.ServiceContract.Quote1__r != null && cli.ServiceContract.Quote1__r.SGST__c != null
                ? String.valueOf(cli.ServiceContract.Quote1__r.SGST__c)
                : cli.ServiceContract != null && cli.ServiceContract.Quote0__r != null && cli.ServiceContract.Quote0__r.SGST__c != null
                ? String.valueOf(cli.ServiceContract.Quote0__r.SGST__c)
                : ''
            );
            
            String ugstValue = encloseWithQuotes(
                cli.ServiceContract != null && cli.ServiceContract.Quote1__r != null && cli.ServiceContract.Quote1__r.UGST__c != null
                ? String.valueOf(cli.ServiceContract.Quote1__r.UGST__c)
                : cli.ServiceContract != null && cli.ServiceContract.Quote0__r != null && cli.ServiceContract.Quote0__r.UGST__c != null
                ? String.valueOf(cli.ServiceContract.Quote0__r.UGST__c)
                : ''
            );
            
            String igstValue = encloseWithQuotes(
                cli.ServiceContract != null && cli.ServiceContract.Quote1__r != null && cli.ServiceContract.Quote1__r.IGST__c != null
                ? String.valueOf(cli.ServiceContract.Quote1__r.IGST__c)
                : cli.ServiceContract != null && cli.ServiceContract.Quote0__r != null && cli.ServiceContract.Quote0__r.IGST__c != null
                ? String.valueOf(cli.ServiceContract.Quote0__r.IGST__c)
                : ''
            );
            
            
            
            String keralaCessPercent = encloseWithQuotes(
                cli.ServiceContract != null && cli.ServiceContract.Kerla_Cess__c != null
                ? String.valueOf(cli.ServiceContract.Kerla_Cess__c) // Use ServiceContract's value
                : (
                    cli.ServiceContract != null && cli.ServiceContract.Quote0__r != null && cli.ServiceContract.Quote0__r.Kerala_Cess__c != null
                    ? String.valueOf(cli.ServiceContract.Quote0__r.Kerala_Cess__c) // Fallback to Quote0__r.Kerala_Cess__c
                    : (
                        cli.ServiceContract != null && cli.ServiceContract.Quote1__r != null && cli.ServiceContract.Quote1__r.Kerela_Cess_Percent__c != null
                        ? String.valueOf(cli.ServiceContract.Quote1__r.Kerela_Cess_Percent__c) // Fallback to Quote1__r.Kerela_Cess_Percent__c
                        : '' // Default to empty string if all are null
                    )
                )
            );
            
            
            
            //encloseWithQuotes('');
            String lastYearPaymentReceived = encloseWithQuotes('');
            String lastYearTOP = encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.Terms_of_Payment_Customer__c != null ? cli.ServiceContract.Terms_of_Payment_Customer__c : '');
            String newEndDate = encloseWithQuotes(
                cli.ServiceContract != null && cli.ServiceContract.EndDate != null 
                ? DateTime.newInstance(cli.ServiceContract.EndDate, Time.newInstance(0, 0, 0, 0)).format('dd-MMM-yyyy')
                : ''
            );
            String paymentAmount = encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.Opportunity__r != null && cli.ServiceContract.Opportunity__r.Amount != null ? String.valueOf(cli.ServiceContract.Opportunity__r.Amount) : '');
            String paymentDate = encloseWithQuotes('');
            String planRegistrationNo = encloseWithQuotes('');
            String planRegistrationStatus = encloseWithQuotes('');
            String policyName = encloseWithQuotes(''); // Default value
            
            // Check if ServiceContract is present
            if (cli.ServiceContract != null) {
                // Retrieve the policy name for the ServiceContract from the map
                if (serviceContractWarrantyMap.containsKey(cli.ServiceContract.Id)) {
                    policyName = encloseWithQuotes(serviceContractWarrantyMap.get(cli.ServiceContract.Id));
                }
            }
            String previousOutstandingIfAny = encloseWithQuotes('');
            
            // encloseWithQuotes(''); 
            //change to quote line item
            String productCustomerNo =  encloseWithQuotes(cli.Asset != null && cli.Asset.Account.SAP_Customer_Id__c != null ? cli.Asset.Account.SAP_Customer_Id__c : '');
            String productSapCustomerNo=  encloseWithQuotes(cli.Asset != null && cli.Asset.Account.SAP_Customer_Id__c != null ? cli.Asset.Account.SAP_Customer_Id__c : '');
            String productSFCustomerNo=  encloseWithQuotes(cli.Asset != null && cli.Asset.Account.Customer_ID__c != null ? cli.Asset.Account.Customer_ID__c : '');
            String productStarCustomerNo=  encloseWithQuotes(cli.Asset != null && cli.Asset.Account.Customer_Code__c != null ? cli.Asset.Account.Customer_Code__c : '');
            String reasonForDeviationDownloading = encloseWithQuotes('');//need to check
            String reasonForDeviationPrice = encloseWithQuotes('');// need to check
            String reasonForDeviationTOP = encloseWithQuotes('');//need to check
            String reject = encloseWithQuotes('');
            String distance = encloseWithQuotes('');
            String salesOrganizationName = encloseWithQuotes('BSL');
            String salesOrganizationNo = encloseWithQuotes('1000');
            String subType = encloseWithQuotes(cli.Asset != null && cli.Asset.CP__r.Type != null ? cli.Asset.CP__r.Type : '');
            String termsOfPaymentDeviation = encloseWithQuotes('');//need to check
            String thisYearMarginPercent = encloseWithQuotes(
                cli.ServiceContract != null 
                ? (cli.ServiceContract.Quote0__r != null && cli.ServiceContract.Quote0__r.Hike_compared_to_last_year__c != null
                   ? String.valueOf(cli.ServiceContract.Quote0__r.Hike_compared_to_last_year__c) 
                   : (cli.ServiceContract.Quote1__r != null && cli.ServiceContract.Quote1__r.Hike_compared_to_last_year__c != null
                      ? String.valueOf(cli.ServiceContract.Quote1__r.Hike_compared_to_last_year__c)
                      : null
                     )
                  )
                : null
            );
            
            String waterManagement = encloseWithQuotes('');
            String factorAmount = encloseWithQuotes('0'); 
            String billToParty = encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.Account.SAP_Customer_Id__c != null ? cli.ServiceContract.Account.SAP_Customer_Id__c : '');
            String billToPartySap=encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.Account.SAP_Customer_Id__c != null ? cli.ServiceContract.Account.SAP_Customer_Id__c : '');
            string billtopartySF=encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.Account.Customer_ID__c != null ? cli.ServiceContract.Account.Customer_ID__c : '');
            String billtopartyStar=encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.Account.Customer_Code__c != null ? cli.ServiceContract.Account.Customer_Code__c : '');
            String Shiptoparty = encloseWithQuotes(
                cli.ServiceContract != null 
                ? (cli.ServiceContract.Ship_to_Party__r != null && cli.ServiceContract.Ship_to_Party__r.SAP_Customer_Id__c != null 
                   ? cli.ServiceContract.Ship_to_Party__r.SAP_Customer_Id__c 
                   : (cli.ServiceContract.Account != null && cli.ServiceContract.Account.SAP_Customer_Id__c != null 
                      ? cli.ServiceContract.Account.SAP_Customer_Id__c 
                      : ''
                     )
                  )
                : ''
            );
            String ShiptopartySap=encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.Ship_to_Party__r.SAP_Customer_Id__c != null ? cli.ServiceContract.Ship_to_Party__r.SAP_Customer_Id__c : '');
            String ShiptopartySF=encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.Ship_to_Party__r.Customer_ID__c != null ? cli.ServiceContract.Ship_to_Party__r.Customer_ID__c : '');
            String ShiptopartyStar=encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.Ship_to_Party__r.Customer_Code__c != null ? cli.ServiceContract.Ship_to_Party__r.Customer_Code__c : '');
            
            
            String componentNo = encloseWithQuotes(cli.Asset != null ? cli.Asset.Component_Id__c : ''); 
            
            String model = encloseWithQuotes(cli.Asset != null ? 
                                             (cli.Asset.Model_Number__c != null ? cli.Asset.Model_Number__c : 
                                              (cli.Asset.Product_Model__c != null ? cli.Asset.Product_Model__c : null)) 
                                             : null);
            
            String productSerialNo = encloseWithQuotes(cli.Asset != null ? cli.Asset.SerialNumber : '');
            // Product Family
            String productFamily = encloseWithQuotes(
                cli.Asset != null && cli.Asset.Product_Family__r != null && cli.Asset.Product_Family__r.Code__c != null
                ? cli.Asset.Product_Family__r.Code__c
                : (cli.Asset != null && cli.Asset.Product2 != null && cli.Asset.Product2.Product_Family__r != null && cli.Asset.Product2.Product_Family__r.Code__c != null
                   ? cli.Asset.Product2.Product_Family__r.Code__c
                   : '') // Default to an empty string if both are null
            );
            
            // Product Family Name
            String productFamilyName = encloseWithQuotes(
                cli.Asset != null && cli.Asset.Product_Family__r != null && cli.Asset.Product_Family__r.Name != null
                ? cli.Asset.Product_Family__r.Name
                : (cli.Asset != null && cli.Asset.Product2 != null && cli.Asset.Product2.Product_Family__r != null && cli.Asset.Product2.Product_Family__r.Name != null
                   ? cli.Asset.Product2.Product_Family__r.Name
                   : '') // Default to an empty string if both are null
            );
            
            // Product Sub Family
            String productSubFamily = encloseWithQuotes(
                cli.Asset != null && cli.Asset.Product_Sub_Family__r != null && cli.Asset.Product_Sub_Family__r.Code__c != null
                ? cli.Asset.Product_Sub_Family__r.Code__c
                : (cli.Asset != null && cli.Asset.Product2 != null && cli.Asset.Product2.Product_Sub_Family__r != null && cli.Asset.Product2.Product_Sub_Family__r.Code__c != null
                   ? cli.Asset.Product2.Product_Sub_Family__r.Code__c
                   : '') // Default to an empty string if both are null
            );
            
            // Product Sub Family Name
            String productSubFamilyName = encloseWithQuotes(
                cli.Asset != null && cli.Asset.Product_Sub_Family__r != null && cli.Asset.Product_Sub_Family__r.Name != null
                ? cli.Asset.Product_Sub_Family__r.Name
                : (cli.Asset != null && cli.Asset.Product2 != null && cli.Asset.Product2.Product_Sub_Family__r != null && cli.Asset.Product2.Product_Sub_Family__r.Name != null
                   ? cli.Asset.Product2.Product_Sub_Family__r.Name
                   : '') // Default to an empty string if both are null
            );
            
            // Determine Channel Partner Type
            String channelPartnerType = encloseWithQuotes(
                cli.ServiceContract != null && cli.ServiceContract.CP__r != null && cli.ServiceContract.CP__r.Type != null
                ? cli.ServiceContract.CP__r.Type // Take from ServiceContract.CP__r if available
                : (cli.ServiceContract != null && cli.ServiceContract.Branch__r != null
                   ? 'Branch' // Use "Branch" if ServiceContract.Branch__r exists
                   : null) // Default to null if both CP__r and Branch__r are unavailable
            );
            
            
            // Determine Channel Partner Number
            String channelPartnerNo = encloseWithQuotes(
                cli.ServiceContract != null && cli.ServiceContract.CP__r != null && cli.ServiceContract.CP__r.CP_Code__c != null
                ? cli.ServiceContract.CP__r.CP_Code__c // Take from ServiceContract.CP__r if available
                : (cli.ServiceContract != null && cli.ServiceContract.Branch__r != null && cli.ServiceContract.Branch__r.Branch_Code__c != null
                   ? cli.ServiceContract.Branch__r.Branch_Code__c // Fallback to Branch__r if CP__r is not available
                   : null) // Default to null if both CP__r and Branch__r are unavailable
            );
            
            // Determine Channel Partner Name
            String channelPartnerName = encloseWithQuotes(
                cli.ServiceContract != null && cli.ServiceContract.CP__r != null && cli.ServiceContract.CP__r.Name != null
                ? cli.ServiceContract.CP__r.Name // Take from ServiceContract.CP__r if available
                : (cli.ServiceContract != null && cli.ServiceContract.Branch__r != null && cli.ServiceContract.Branch__r.Name != null
                   ? cli.ServiceContract.Branch__r.Name // Fallback to Branch__r if CP__r is not available
                   : null) // Default to null if both CP__r and Branch__r are unavailable
            );
            
            
            
            String activatedDate = encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.ActivationDate != null ? cli.ServiceContract.ActivationDate.format() : ''); 
            String addressLine1 = encloseWithQuotes(
                cli.ServiceContract != null 
                ? (cli.ServiceContract.BillingStreet != null ? cli.ServiceContract.BillingStreet : '') + ' ' +
                (cli.ServiceContract.BillingCity != null ? cli.ServiceContract.BillingCity : '') + ' ' +
                (cli.ServiceContract.BillingState != null ? cli.ServiceContract.BillingState : '') + ' ' +
                (cli.ServiceContract.BillingPostalCode != null ? cli.ServiceContract.BillingPostalCode : '') + ' ' +
                (cli.ServiceContract.BillingCountry != null ? cli.ServiceContract.BillingCountry : '') + ' ' +
                (cli.ServiceContract.BillingCountryCode != null ? cli.ServiceContract.BillingCountryCode : '') + ' ' +
                (cli.ServiceContract.BillingStateCode != null ? cli.ServiceContract.BillingStateCode : '') 
                : ''
            );
            
            
            
            
            String addressLine2 = encloseWithQuotes('');
            
            String aichName = encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.Opportunity__r != null && cli.ServiceContract.Opportunity__r.All_India_Commericial_Head__r != null ? cli.ServiceContract.Opportunity__r.All_India_Commericial_Head__r.Name : ''); 
            String allIndiaCommercialHead = encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.Opportunity__r != null && cli.ServiceContract.Opportunity__r.All_India_Commericial_Head__r != null ? String.valueOf(cli.ServiceContract.Opportunity__r.All_India_Commericial_Head__r.EmployeeNumber) : ''); 
            String allIndiaHead = encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.Opportunity__r != null && cli.ServiceContract.Opportunity__r.All_India_Head__r != null ? String.valueOf(cli.ServiceContract.Opportunity__r.All_India_Head__r.EmployeeNumber) : ''); 
            String allIndiaHeadName = encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.Opportunity__r != null && cli.ServiceContract.Opportunity__r.All_India_Head__r != null ? cli.ServiceContract.Opportunity__r.All_India_Head__r.Name : ''); 
            
            String billToPartyMobileNo = encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.Contact.Phone != null ? cli.ServiceContract.Contact.Phone : '');
            String billingDuePeriod = encloseWithQuotes(
                cli.ServiceContract != null 
                ? (cli.ServiceContract.Billing_Due_Period__c != null 
                   ? cli.ServiceContract.Billing_Due_Period__c 
                   : (cli.ServiceContract.Quote0__r != null && cli.ServiceContract.Quote0__r.Billing_Due_Period__c != null 
                      ? cli.ServiceContract.Quote0__r.Billing_Due_Period__c 
                      : (cli.ServiceContract.Quote1__r != null && cli.ServiceContract.Quote1__r.Billing_Due_Period__c != null 
                         ? cli.ServiceContract.Quote1__r.Billing_Due_Period__c 
                         : ''
                        )
                     )
                  ) 
                : ''
            );
            
            String billingFrequencyPeriod = encloseWithQuotes(cli.ServiceContract != null  && cli.ServiceContract.Billing_Frequency_Period__c != null ? cli.ServiceContract.Billing_Frequency_Period__c : ''); 
            String branchName = encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.Branch__r != null ? cli.ServiceContract.Branch__r.Name : '');
            String branchNo = encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.Branch__r != null ? cli.ServiceContract.Branch__r.Branch_Code__c : '');
            
            // Determine Actual Capacity
            String actualCapacity = encloseWithQuotes(
                cli.Asset != null && cli.Asset.Actual_Capacity__c != null
                ? String.valueOf(cli.Asset.Actual_Capacity__c) // Use Asset.Actual_Capacity__c if available
                : '' // Default to empty string if null
            );
            
            
            // Determine Capacity
            String capacity = encloseWithQuotes(
                cli.Asset != null && cli.Asset.Product2 != null && cli.Asset.Product2.Capacity__c != null
                ? String.valueOf(cli.Asset.Product2.Capacity__c) // Use Asset.Product2.Capacity__c if available
                : '' // Default to empty string if null
            );
            
            
            
            String comments = encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.Comment__c != null ? cli.ServiceContract.Comment__c : ''); 
            String contractCategory = encloseWithQuotes(cli.ServiceContract != null  && cli.ServiceContract.Contract_Category__c != null ? cli.ServiceContract.Contract_Category__c : ''); 
            Map<String, String> contractTypeMap = new Map<String, String>{
                'EFM' => 'Engineering Facility Management Contract',
                    'RPC' => 'Risk Protection Contract',
                    'PMC' => 'Preventive Maintenance Contract',
                    'ORC' => 'Operating & Risk Protection Contract',
                    'OPR' => 'Operating Contract',
                    'OLC' => 'Operating & Labour Contract',
                    'LBR' => 'Labour Contract',
                    'CEC' => 'Compressor Excluded Contract',
                    'EW'  => 'Extended Warranty Contract',
                    'IEW' => 'Inverter Extended Warranty Contract'  // Added missing entry for Inverter Extended Warranty Contract
                    };
                        
                        // Get the short code from the ServiceContract and convert it
                        String contractType = encloseWithQuotes(
                            (cli.ServiceContract != null && cli.ServiceContract.Contract_Type__c != null && contractTypeMap.containsKey(cli.ServiceContract.Contract_Type__c)) 
                            ? contractTypeMap.get(cli.ServiceContract.Contract_Type__c) 
                            : ''
                        );
            String contract_type_short_name=encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.Contract_Type__c != null ? cli.ServiceContract.Contract_Type__c : ''); 
            String createdBy = encloseWithQuotes(cli.CreatedBy != null ? cli.CreatedBy.Name : '');
            String createdDate = encloseWithQuotes(cli.CreatedDate != null ? cli.CreatedDate.format('yyyy-MM-dd hh:mm:ss') : '');
            String customerInvoiceText = encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.Opportunity__r != null && cli.ServiceContract.Opportunity__r.Customer_Invoice_Text__c != null ? cli.ServiceContract.Opportunity__r.Customer_Invoice_Text__c : ''); 
            String customerName = encloseWithQuotes(cli.Asset != null && cli.Asset.Account != null ? cli.Asset.Account.Name : ''); 
            String customerPODate = encloseWithQuotes(
                cli.ServiceContract != null && cli.ServiceContract.PO_Date__c != null 
                ? DateTime.newInstance(cli.ServiceContract.PO_Date__c, Time.newInstance(0, 0, 0, 0)).format('dd-MMM-yyyy')
                : ''
            );
            
            
            String customerPONo = encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.PO_Number__c != null ? cli.ServiceContract.PO_Number__c : '');
            String customerPOAmount = encloseWithQuotes(
                cli.ServiceContract != null && cli.ServiceContract.PO_Total_Value__c != null 
                ? String.valueOf(cli.ServiceContract.PO_Total_Value__c) 
                : ''
            );
            
            String customerPOValue = encloseWithQuotes('');
            String departmentName = encloseWithQuotes(
                cli.ServiceContract != null && cli.ServiceContract.Opportunity__r != null &&
                cli.ServiceContract.Opportunity__r.Department__r != null &&
                cli.ServiceContract.Opportunity__r.Department__r.Name != null
                ? cli.ServiceContract.Opportunity__r.Department__r.Name
                : (cli.ServiceContract.Department__r != null ? cli.ServiceContract.Department__r.Name : '')
            );
            
            String departmentNo = encloseWithQuotes(
                cli.ServiceContract != null && cli.ServiceContract.Opportunity__r != null &&
                cli.ServiceContract.Opportunity__r.Department__r != null &&
                cli.ServiceContract.Opportunity__r.Department__r.Department_Number__c != null
                ? cli.ServiceContract.Opportunity__r.Department__r.Department_Number__c
                : (cli.ServiceContract.Department__r != null ? cli.ServiceContract.Department__r.Department_Number__c : '')
            );
            
            
            String documentList = encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.Opportunity__r != null && cli.ServiceContract.Opportunity__r.Document_List__c != null ? cli.ServiceContract.Opportunity__r.Document_List__c : ''); 
            String documentsRequired = encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.Opportunity__r != null && cli.ServiceContract.Opportunity__r.Document_Required__c != null ? String.valueOf(cli.ServiceContract.Opportunity__r.Document_Required__c) : '');
            // Initialize fields including QuoteLineNumber
            /* String componentProposalPrice = encloseWithQuotes(
String.valueOf(
cli.ServiceContract != null && cli.ServiceContract.Quote0__r != null && cli.ServiceContract.Quote0__r.TotalPrice != null 
? String.valueOf(cli.ServiceContract.Quote0__r.TotalPrice) 
: String.valueOf((cli.ServiceContract != null && cli.ServiceContract.Quote1__r != null && cli.ServiceContract.Quote1__r.Total_Price__c != null
? cli.ServiceContract.Quote1__r.Total_Price__c 
: 0))
) 
);  */
            String currentYearDownloadingPrice = null;
            if (cli.ServiceContract.Quote0__c != null) {
                Decimal revisedValue = cli.ServiceContract.Quote0__r.Revise_Total_Downloading_Value__c;
                Decimal totalValue = cli.ServiceContract.Quote0__r.Total_Download_Value_Rollup__c;
                
                if (revisedValue != null && revisedValue != 0) {
                    currentYearDownloadingPrice = encloseWithQuotes(String.valueOf(revisedValue));
                } else if (totalValue != null) {
                    currentYearDownloadingPrice = encloseWithQuotes(String.valueOf(totalValue));
                } else if (revisedValue != null) {
                    currentYearDownloadingPrice = encloseWithQuotes(String.valueOf(revisedValue));
                }
            } else if (cli.ServiceContract.Quote1__c != null) {
                Decimal revisedValue = cli.ServiceContract.Quote1__r.Revise_Total_Downloading_Value__c;
                Decimal totalValue = cli.ServiceContract.Quote1__r.Total_Downloading_Value_RollUp__c;
                
                if (revisedValue != null && revisedValue != 0) {
                    currentYearDownloadingPrice = encloseWithQuotes(String.valueOf(revisedValue));
                } else if (totalValue != null) {
                    currentYearDownloadingPrice = encloseWithQuotes(String.valueOf(totalValue));
                } else if (revisedValue != null) {
                    currentYearDownloadingPrice = encloseWithQuotes(String.valueOf(revisedValue));
                }
            }
            
            
            
            
            // Ensure values are initialized
            Decimal finalNetValue = null;
            Decimal downloadingPrice = null;
            Decimal marginPercent = null;
            
            // Extract final net contract value from CPQ or Quote
            if (cli.ServiceContract.Quote0__c != null && cli.ServiceContract.Quote0__r != null) {
                finalNetValue = cli.ServiceContract.Quote0__r.Final_Net_Contract_Value_Curr__c;
            } else if (cli.ServiceContract.Quote1__c != null && cli.ServiceContract.Quote1__r != null) {
                finalNetValue = cli.ServiceContract.Quote1__r.Final_Net_Contract_Value_Currency__c;
            }
            
            // Direct conversion of currentYearDownloadingPrice to Decimal
            if (!String.isEmpty(currentYearDownloadingPrice)) {
                try {
                    downloadingPrice = Decimal.valueOf(currentYearDownloadingPrice.replace('"', '')); // Remove quotes if any
                } catch (Exception e) {
                    // Log an error or fallback to null if parsing fails
                    //System.debug('Failed to convert currentYearDownloadingPrice to Decimal: ' + e.getMessage());
                    downloadingPrice = null;
                }
            }
            
            // Apply formula only if finalNetValue and downloadingPrice are not null and finalNetValue > 0
            if (finalNetValue != null && downloadingPrice != null && finalNetValue > 0) {
                marginPercent = ((finalNetValue - downloadingPrice) * 100) / finalNetValue;
            }
            
            // Convert to string and enclose with quotes, keeping default as null (blank) if marginPercent is null
            String currentYearMarginPercent = marginPercent != null 
                ? encloseWithQuotes(String.valueOf(marginPercent.setScale(2))) 
                : encloseWithQuotes('');
            
            
            
            
            String lastYearMarginDownloading = encloseWithQuotes('');
            
            if (cli.ServiceContract != null && 
                cli.ServiceContract.Standard_Downloading_Value__c != null && 
                cli.ServiceContract.Download_Value_For_Last_Year__c != null && 
                cli.ServiceContract.Download_Value_For_Last_Year__c != 0) { // Prevent division by zero
                    
                    Decimal lastYearMargin = 
                        ((cli.ServiceContract.Standard_Downloading_Value__c - cli.ServiceContract.Download_Value_For_Last_Year__c) 
                         / cli.ServiceContract.Download_Value_For_Last_Year__c) * 100;
                    
                    lastYearMarginDownloading = encloseWithQuotes(String.valueOf(lastYearMargin.setScale(2))); // Format to 2 decimal places
                }
            String contractPeriodFrom = encloseWithQuotes(
                cli.ServiceContract != null && cli.ServiceContract.StartDate != null 
                ? DateTime.newInstance(cli.ServiceContract.StartDate, Time.newInstance(0, 0, 0, 0)).format('dd-MMM-yyyy') 
                : ''
            );
            
            String contractPeriodTo = encloseWithQuotes(
                cli.ServiceContract != null 
                ? (cli.ServiceContract.Original_End_Date__c != null 
                   ? DateTime.newInstance(cli.ServiceContract.Original_End_Date__c, Time.newInstance(0, 0, 0, 0)).format('dd-MMM-yyyy') 
                   : (cli.ServiceContract.EndDate != null 
                      ? DateTime.newInstance(cli.ServiceContract.EndDate, Time.newInstance(0, 0, 0, 0)).format('dd-MMM-yyyy') 
                      : ''
                     )
                  ) 
                : ''
            );
            
            String priceDeviation = null;  // Default value for price deviation
            
            Decimal cliListPrice = null;  // Unique variable name for list price
            Decimal cliAdjustedListPrice = null;  // Unique variable name for adjusted list price
            Decimal cliSalesPrice = null;  // Unique variable name for sales price
            Integer cliContractMonths = 12;  // Default contract period is 12 months
            
            if (cli != null) {
                // Step 1: Determine the List Price
                if (cli.Unit_Price__c != null && cli.Unit_Price__c > 0) {
                    cliListPrice = cli.Unit_Price__c; // Priority 1: Use Unit_Price__c
                } else if (cli.ListPrice != null) {
                    cliListPrice = cli.ListPrice; // Priority 2: Fallback to ListPrice
                }
                
                // Step 2: Calculate Contract Duration in Months
                if (cli.ServiceContract != null && cli.ServiceContract.StartDate != null && cli.ServiceContract.EndDate != null) {
                    // Use distinct variable names for start and end dates
                    Date contractStartDate = cli.ServiceContract.StartDate; // StartDate from ServiceContract
                    Date contractEndDate = cli.ServiceContract.EndDate;     // EndDate from ServiceContract
                    
                    // Calculate the number of months between contractStartDate and contractEndDate
                    cliContractMonths = ((contractEndDate.year() - contractStartDate.year()) * 12) + (contractEndDate.month() - contractStartDate.month());
                    
                    // Add 1 if the contractEndDate's day is greater than or equal to contractStartDate's day
                    if (contractEndDate.day() >= contractStartDate.day()) {
                        cliContractMonths += 1;
                    }
                }
                
                // Step 3: Adjust List Price for Contract Duration
                if (cliListPrice != null) { // Ensure the list price is not null
                    if (cliContractMonths != 12) { // Only adjust if the duration is not exactly 12 months
                        cliAdjustedListPrice = (cliListPrice / 12) * cliContractMonths; // Prorate list price
                    } else {
                        cliAdjustedListPrice = cliListPrice; // Use the list price as-is for a 1-year contract
                    }
                }
                
                // Step 4: Get the Sales Price
                if (cli.UnitPrice != null) {
                    cliSalesPrice = cli.UnitPrice;
                }
                
                // Step 5: Determine Price Deviation
                if (cliAdjustedListPrice != null && cliSalesPrice != null) {
                    priceDeviation = (cliAdjustedListPrice != cliSalesPrice) ? 'Y' : 'N';
                }
            }
            
            // Enclose the result in quotes if not null
            priceDeviation = encloseWithQuotes(priceDeviation);
            
            
            
            String thisYearStandardPriceBasic = null;
            if (cli.ServiceContract != null) {
                Decimal totalPrice = cli.ServiceContract.TotalPrice;
                Decimal fallbackPrice = cli.ServiceContract.Total_price__c;
                
                if (totalPrice != null && totalPrice != 0) {
                    thisYearStandardPriceBasic = encloseWithQuotes(String.valueOf(totalPrice));
                } else if (fallbackPrice != null) {
                    thisYearStandardPriceBasic = encloseWithQuotes(String.valueOf(fallbackPrice));
                } else if (totalPrice != null) {
                    thisYearStandardPriceBasic = encloseWithQuotes(String.valueOf(totalPrice));
                }
            }
            
            
            
            String thisYearFinalPriceBasic = null;
            if (cli.ServiceContract != null) {
                Decimal grandTotal = cli.ServiceContract.GrandTotal;
                Decimal fallbackTotal = cli.ServiceContract.Grand_Total__c;
                
                if (grandTotal != null && grandTotal != 0) {
                    thisYearFinalPriceBasic = encloseWithQuotes(String.valueOf(grandTotal));
                } else if (fallbackTotal != null) {
                    thisYearFinalPriceBasic = encloseWithQuotes(String.valueOf(fallbackTotal));
                } else if (grandTotal != null) {
                    thisYearFinalPriceBasic = encloseWithQuotes(String.valueOf(grandTotal));
                }
            }
            
            
            
            
            String lastYearPriceBasic =encloseWithQuotes(String.valueOf(cli.ServiceContract != null && cli.ServiceContract.Quote0__r != null && cli.ServiceContract.Quote0__r.Last_Year_Price_for_Asset__c != null ? cli.ServiceContract.Quote0__r.Last_Year_Price_for_Asset__c :cli.ServiceContract != null && cli.ServiceContract.Quote1__r != null && cli.ServiceContract.Quote1__r.Last_Year_Price_for_Asset__c!= null? cli.ServiceContract.Quote1__r.Last_Year_Price_for_Asset__c:null)); 
            String lastYearMarginPrice =encloseWithQuotes(String.valueOf(cli.ServiceContract != null && cli.ServiceContract.Quote0__r != null && cli.ServiceContract.Quote0__r.Hike_compared_to_last_year__c != null ? cli.ServiceContract.Quote0__r.Hike_compared_to_last_year__c :cli.ServiceContract != null && cli.ServiceContract.Quote1__r != null && cli.ServiceContract.Quote1__r.Hike_compared_to_last_year__c!= null? cli.ServiceContract.Quote1__r.Hike_compared_to_last_year__c:null)); 
            String lastYearDownloadingPrice =encloseWithQuotes(cli.ServiceContract.Download_Value_For_Last_Year__c != null ? String.valueOf(cli.ServiceContract.Download_Value_For_Last_Year__c) : ''); 
            String componentProposalPrice=encloseWithQuotes('');
            String quoteLineNumber = encloseWithQuotes(''); // New field initialization
            String previousPrice = encloseWithQuotes('');//encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.Previous_Price__c != null ? String.valueOf(cli.ServiceContract.Previous_Price__c) : ''); 
            String contractPrice = encloseWithQuotes('');//encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.Total_Contract_Amount__c != null ? String.valueOf(cli.ServiceContract.Total_Contract_Amount__c) : '');
            String downloadingValue = null;
            
            Decimal reviseValue = cli.Download_Value1__c;
            Decimal downloadingVal = cli.Download_Value__c;
            Decimal standardValue = cli.Standard_Downloading_Value__c;
            
            if (reviseValue != null && reviseValue != 0) {
                downloadingValue = encloseWithQuotes(String.valueOf(reviseValue));
            } else if (downloadingVal != null && downloadingVal != 0) {
                downloadingValue = encloseWithQuotes(String.valueOf(downloadingVal));
            } else if (standardValue != null && standardValue > 0) {
                downloadingValue = encloseWithQuotes(String.valueOf(standardValue));
            } else {
                // fallback to revised, even if 0
                downloadingValue = encloseWithQuotes(String.valueOf(reviseValue));
            }
            
            
            
            
            
            String priceChangePercent =  encloseWithQuotes('');
            if (cli.ServiceContract != null) {
                // Retrieve the Quote Ids
                String quote0Id = cli.ServiceContract.Quote0__c;  // Sales Quote
                String quote1Id = cli.ServiceContract.Quote1__c;  // CPQ Quote
                Decimal listPrice = null;
                Decimal sellPrice = null;
                
                // Check CPQ Quote Lines
                if (quote1Id != null && sbqqQuoteLineMap.containsKey(quote1Id)) {
                    List<SBQQ__QuoteLine__c> sbqqQuoteLines = sbqqQuoteLineMap.get(quote1Id);
                    if (!sbqqQuoteLines.isEmpty()) {
                        SBQQ__QuoteLine__c quoteLine = sbqqQuoteLines[0];
                        
                        // Assigning values from CPQ Quote Line
                        // listPrice = quoteLine.SBQQ__ListPrice__c;
                        //sellPrice = quoteLine.Sell_Price__c;
                        // lastYearPriceBasic = encloseWithQuotes(String.valueOf(quoteLine.Last_Year_Price_for_Asset__c));
                        //lastYearMarginPrice = encloseWithQuotes(String.valueOf(quoteLine.Hike_compared_to_last_year__c));
                        //lastYearDownloadingPrice = encloseWithQuotes(String.valueOf(quoteLine.Downloading_Value_for_Last_Year__c));
                        //contractPrice = encloseWithQuotes(String.valueOf(quoteLine.Sell_Price__c));
                        componentProposalPrice = encloseWithQuotes(String.valueOf(quoteLine.SBQQ__ListPrice__c));
                        // lastYearMarginDownloading = encloseWithQuotes(String.valueOf(quoteLine.last_year_margin_downloading__c));
                        quoteLineNumber = encloseWithQuotes(quoteLine.Name);
                        // Update downloadingValue if current value is blank or zero
                        /*if (String.isBlank(downloadingValue) || Decimal.valueOf(downloadingValue) == 0) {
downloadingValue = encloseWithQuotes(
quoteLine.Revised_Download_Value__c != null && quoteLine.Revised_Download_Value__c > 0
? String.valueOf(quoteLine.Revised_Download_Value__c)
: String.valueOf(quoteLine.Standard_Downloading_Value__c)
);
}*/
                        // Assign Previous Price from CPQ Quote Line
                        if (quoteLine.Previous_Contract_Price__c != null) {
                            previousPrice = encloseWithQuotes(String.valueOf(quoteLine.Previous_Contract_Price__c));
                        }
                        /*priceDeviation = encloseWithQuotes(
(quoteLine.SBQQ__ListPrice__c != null && quoteLine.Sell_Price__c != null &&
quoteLine.SBQQ__ListPrice__c != quoteLine.Sell_Price__c) ? 'Y' : 'N'
);*/
                    }
                } 
                // Check Sales Quote Lines if CPQ Quote is not present
                else if (quote0Id != null && quoteLineItemsMap.containsKey(quote0Id)) {
                    List<QuoteLineItem> quoteLineItems = quoteLineItemsMap.get(quote0Id);
                    if (!quoteLineItems.isEmpty()) {
                        QuoteLineItem quoteLine = quoteLineItems[0];
                        
                        // Assigning values from Sales Quote Line
                        //listPrice = quoteLine.UnitPrice;
                        //sellPrice = quoteLine.UnitPrice;
                        // lastYearPriceBasic = encloseWithQuotes(String.valueOf(quoteLine.Last_Year_Price_for_Asset__c));
                        //lastYearMarginPrice = encloseWithQuotes(String.valueOf(quoteLine.Hike_compared_to_last_year__c));
                        //lastYearDownloadingPrice = encloseWithQuotes(String.valueOf(quoteLine.Downloading_Value_for_Last_Year__c));
                        //contractPrice = encloseWithQuotes(String.valueOf(quoteLine.Sell_Price__c));
                        componentProposalPrice = encloseWithQuotes(String.valueOf(quoteLine.ListPrice));
                        //lastYearMarginDownloading = encloseWithQuotes(String.valueOf(quoteLine.last_year_margin_downloading__c));
                        quoteLineNumber = encloseWithQuotes(String.valueOf(quoteLine.LineNumber));
                        // Update downloadingValue if still blank or zero
                        /* if (String.isBlank(downloadingValue) || Decimal.valueOf(downloadingValue) == 0) {
downloadingValue = encloseWithQuotes(
quoteLine.Revised_Download_Value__c != null && quoteLine.Revised_Download_Value__c > 0
? String.valueOf(quoteLine.Revised_Download_Value__c)
: String.valueOf(quoteLine.Standard_Downloading_Value__c)
);
}
*/
                        if (quoteLine.Previous_Contract_Price__c != null) {
                            previousPrice = encloseWithQuotes(String.valueOf(quoteLine.Previous_Contract_Price__c));
                        }
                        /*priceDeviation = encloseWithQuotes(
(quoteLine.ListPrice != null && quoteLine.UnitPrice != null &&
quoteLine.ListPrice != quoteLine.UnitPrice) ? 'Y' : 'N'
);*/
                    }
                }
                // Calculate Price Change Percent between componentProposalPrice and contractPrice
                contractPrice = encloseWithQuotes(cli.ServiceContract != null && cli.TotalPrice != null 
                                                  ? String.valueOf(cli.TotalPrice) 
                                                  : '');
                
                if (componentProposalPrice != null && contractPrice != null) {
                    try {
                        // Remove quotes and convert the String values to Decimal
                        Decimal componentPriceDecimal = Decimal.valueOf(componentProposalPrice.replace('"', '').trim());
                        Decimal contractPriceDecimal = Decimal.valueOf(contractPrice.replace('"', '').trim());
                        
                        // Calculate percentage difference only if componentPriceDecimal > 0
                        if (componentPriceDecimal > 0) {
                            Decimal priceChange = ((componentPriceDecimal - contractPriceDecimal) / componentPriceDecimal) * 100;
                            priceChangePercent = encloseWithQuotes(String.valueOf(priceChange.setScale(2))); // Format to 2 decimal places
                        } else {
                            priceChangePercent = encloseWithQuotes(''); // Default to empty string if componentProposalPrice is 0
                        }
                    } catch (Exception e) {
                        System.debug('Error calculating priceChangePercent: ' + e.getMessage());
                        priceChangePercent = encloseWithQuotes(''); // Handle any exceptions gracefully
                    }
                } else {
                    priceChangePercent = encloseWithQuotes(''); // Default to empty string if either value is null
                }
                
                
                
                
            }
            
            
            //encloseWithQuotes(String.valueOf(cli.ServiceContract != null && cli.ServiceContract.Quote0__r != null && cli.ServiceContract.Quote0__r.Hike_compared_to_last_year__c != null ? cli.ServiceContract.Quote0__r.Hike_compared_to_last_year__c :cli.ServiceContract != null && cli.ServiceContract.Quote1__r != null && cli.ServiceContract.Quote1__r.Hike_compared_to_last_year__c!= null? cli.ServiceContract.Quote1__r.Hike_compared_to_last_year__c:'')); 
            String egmEstimatedGrossMargin = encloseWithQuotes(
                cli.ServiceContract != null && cli.ServiceContract.EGM_Estimated_Gross_Margin__c != null
                ? String.valueOf(cli.ServiceContract.EGM_Estimated_Gross_Margin__c)
                : (
                    cli.ServiceContract != null && cli.ServiceContract.Quote0__r != null && cli.ServiceContract.Quote0__r.EGM_Formula__c != null
                    ? String.valueOf(cli.ServiceContract.Quote0__r.EGM_Formula__c)
                    : (
                        cli.ServiceContract != null && cli.ServiceContract.Quote1__r != null && cli.ServiceContract.Quote1__r.EGM_Formula__c != null
                        ? String.valueOf(cli.ServiceContract.Quote1__r.EGM_Formula__c)
                        : '' // Default to '0' if no values are present
                    )
                )
            );
            
            
            String egmPercent = encloseWithQuotes(
                cli.ServiceContract != null && cli.ServiceContract.EGM__c != null
                ? String.valueOf(cli.ServiceContract.EGM__c)
                : (
                    cli.ServiceContract != null && cli.ServiceContract.Quote0__r != null && cli.ServiceContract.Quote0__r.EGM_Percent_Formula__c != null
                    ? String.valueOf(cli.ServiceContract.Quote0__r.EGM_Percent_Formula__c)
                    : (
                        cli.ServiceContract != null && cli.ServiceContract.Quote1__r != null && cli.ServiceContract.Quote1__r.EGM_Percent_Formula__c != null
                        ? String.valueOf(cli.ServiceContract.Quote1__r.EGM_Percent_Formula__c)
                        : '' // Default to '0' if all values are null
                    )
                )
            );
            
            
            // encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.EGM_Formula__c != null ? String.valueOf(cli.ServiceContract.EGM_Formula__c) : '');
            String emailId = encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.Contact.Email != null ? cli.ServiceContract.Contact.Email: '');
            
            String isCustomEvents = null;  // Default value is null
            String events = encloseWithQuotes('');  // Default to empty string
            
            // Check if the ServiceContract and Opportunity exist
            if (cli.ServiceContract != null && cli.ServiceContract.Opportunity__c != null) {
                Id oppId = cli.ServiceContract.Opportunity__c;
                
                // Check if the Opportunity has PMS schedules
                if (pmsScheduleMap.containsKey(oppId)) {
                    isCustomEvents = encloseWithQuotes('Y'); // Opportunity has PMS events
                    Integer eventCount = pmsEventCountMap.get(oppId);
                    events = encloseWithQuotes(String.valueOf(eventCount)); // Use the count of PMS events
                } else {
                    isCustomEvents = encloseWithQuotes('N'); // No PMS events
                    // Fallback to Events_Created__c or Custom_AMC_PMS_Events__c
                    if (cli.ServiceContract.Events_Created__c != null) {
                        events = encloseWithQuotes(String.valueOf(cli.ServiceContract.Events_Created__c));
                    } else if (cli.ServiceContract.Custom_AMC_PMS_Events__c != null) {
                        events = encloseWithQuotes(String.valueOf(cli.ServiceContract.Custom_AMC_PMS_Events__c));
                    } else {
                        events = encloseWithQuotes(''); // Default to empty string
                    }
                }
            }
            
            
            String Quotenumberbackend = encloseWithQuotes(
                cli.ServiceContract != null 
                ? (cli.ServiceContract.Quote0__r != null && cli.ServiceContract.Quote0__r.Quote_Number_Backend__c != null
                   ? String.valueOf(cli.ServiceContract.Quote0__r.Quote_Number_Backend__c) 
                   : (cli.ServiceContract.Quote1__r != null && cli.ServiceContract.Quote1__r.Quote_Number_Backend__c != null
                      ? String.valueOf(cli.ServiceContract.Quote1__r.Quote_Number_Backend__c)
                      : null
                     )
                  )
                : null
            ); 
            String finalNetContractValue = encloseWithQuotes(
                cli.ServiceContract != null 
                ? (cli.ServiceContract.Quote0__r != null && cli.ServiceContract.Quote0__r.Final_Net_Contract_Value_Curr__c != null
                   ? String.valueOf(cli.ServiceContract.Quote0__r.Final_Net_Contract_Value_Curr__c) 
                   : (cli.ServiceContract.Quote1__r != null && cli.ServiceContract.Quote1__r.Final_Net_Contract_Value_Currency__c != null
                      ? String.valueOf(cli.ServiceContract.Quote1__r.Final_Net_Contract_Value_Currency__c)
                      : null
                     )
                  )
                : null
            ); 
            String firstName = encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.ContactId != null ? cli.ServiceContract.Contact.FirstName : ''); 
            String grossContractValue = encloseWithQuotes(
                cli.ServiceContract != null 
                ? (cli.ServiceContract.Quote0__r != null && cli.ServiceContract.Quote0__r.Gross_Contract_Value_Currency__c != null
                   ? String.valueOf(cli.ServiceContract.Quote0__r.Gross_Contract_Value_Currency__c) 
                   : (cli.ServiceContract.Quote1__r != null && cli.ServiceContract.Quote1__r.Gross_Contract_Value_Currency__c != null
                      ? String.valueOf(cli.ServiceContract.Quote1__r.Gross_Contract_Value_Currency__c)
                      : null
                     )
                  )
                : null
            ); 
            String keralaCess = encloseWithQuotes(
                cli.ServiceContract != null && cli.ServiceContract.Kerela_Cess__c != null
                ? String.valueOf(cli.ServiceContract.Kerela_Cess__c) // Use ServiceContract.Kerela_Cess__c
                : (
                    cli.ServiceContract != null && cli.ServiceContract.Quote0__r != null && cli.ServiceContract.Quote0__r.Kerala_Cess_Currency__c != null
                    ? String.valueOf(cli.ServiceContract.Quote0__r.Kerala_Cess_Currency__c) // Fallback to Quote0__r.Kerala_Cess_Currency__c
                    : (
                        cli.ServiceContract != null && cli.ServiceContract.Quote1__r != null && cli.ServiceContract.Quote1__r.Kerela_Cess__c != null
                        ? String.valueOf(cli.ServiceContract.Quote1__r.Kerela_Cess__c) // Fallback to Quote1__r.Kerela_Cess__c
                        : '' // Default to an empty string
                    )
                )
            );
            
            String lastName = encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.ContactId != null ? cli.ServiceContract.Contact.LastName : '');
            String discountPercent = encloseWithQuotes(
                cli.ServiceContract != null && cli.ServiceContract.Discount__c != null
                ? String.valueOf(cli.ServiceContract.Discount__c)
                : (
                    cli.ServiceContract.Quote0__r != null && cli.ServiceContract.Quote0__r.Discount__c != null
                    ? String.valueOf(cli.ServiceContract.Quote0__r.Discount__c)
                    : (
                        cli.ServiceContract.Quote1__r != null && cli.ServiceContract.Quote1__r.Discount__c != null
                        ? String.valueOf(cli.ServiceContract.Quote1__r.Discount__c)
                        : ''
                    )
                )
            );
            
            //encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.Opportunity__r != null && cli.ServiceContract.Opportunity__r.Last_Year_Price__c != null ? String.valueOf(cli.ServiceContract.Opportunity__r.Last_Year_Price__c) : ''); 
            String mobile = encloseWithQuotes(cli.Asset != null && cli.Asset.Account != null ? cli.Asset.Account.Phone : '');
            String netContractValue = encloseWithQuotes(
                cli.ServiceContract != null 
                ? (cli.ServiceContract.Quote0__r != null && cli.ServiceContract.Quote0__r.Net_Contract_Value_Currency__c != null
                   ? String.valueOf(cli.ServiceContract.Quote0__r.Net_Contract_Value_Currency__c) 
                   : (cli.ServiceContract.Quote1__r != null && cli.ServiceContract.Quote1__r.Net_Contract_Value_Currency__c != null
                      ? String.valueOf(cli.ServiceContract.Quote1__r.Net_Contract_Value_Currency__c)
                      : null
                     )
                  )
                : null
            );
            String overallPriceChange = encloseWithQuotes(
                cli.ServiceContract != null 
                ? (cli.ServiceContract.Quote0__r != null && cli.ServiceContract.Quote0__r.Overall_Price_Change_Formula__c != null
                   ? String.valueOf(cli.ServiceContract.Quote0__r.Overall_Price_Change_Formula__c) 
                   : (cli.ServiceContract.Quote1__r != null && cli.ServiceContract.Quote1__r.Overall_Price_Change__c != null
                      ? String.valueOf(cli.ServiceContract.Quote1__r.Overall_Price_Change__c)
                      : '' // Default to '0' instead of an empty string
                     )
                  )
                : '' // Default to '0' if ServiceContract is null
            );
            
            String poReceiptDate = encloseWithQuotes(
                cli.ServiceContract != null && cli.ServiceContract.Opportunity__r != null && cli.ServiceContract.Opportunity__r.PO_Receipt_Date__c != null 
                ? DateTime.newInstance(cli.ServiceContract.Opportunity__r.PO_Receipt_Date__c, Time.newInstance(0, 0, 0, 0)).format('dd-MMM-yyyy') 
                : ''
            ); 
            
            String parentCustomerId = encloseWithQuotes(cli.Asset != null && cli.ServiceContract.Account.Parent.SAP_Customer_Id__c != null ? cli.ServiceContract.Account.Parent.SAP_Customer_Id__c : '');
            String parentSAPCustomerId=encloseWithQuotes(cli.Asset != null && cli.ServiceContract.Account.Parent.SAP_Customer_Id__c != null ? cli.ServiceContract.Account.Parent.SAP_Customer_Id__c : '');
            String parentSFCustomerId=encloseWithQuotes(cli.Asset != null && cli.ServiceContract.Account.Parent.Customer_ID__c != null ? cli.ServiceContract.Account.Parent.Customer_ID__c : '');
            String parentStarCustomerId=encloseWithQuotes(cli.Asset != null && cli.ServiceContract.Account.Parent.Customer_Code__c != null ? cli.ServiceContract.Account.Parent.Customer_Code__c : '');
            String paymentCreditDays = encloseWithQuotes(
                String.valueOf(
                    cli.ServiceContract != null && cli.ServiceContract.Quote0__r != null && cli.ServiceContract.Quote0__r.Payment_Credit_Days__c != null
                    ? cli.ServiceContract.Quote0__r.Payment_Credit_Days__c
                    : (cli.ServiceContract != null && cli.ServiceContract.Quote1__r != null && cli.ServiceContract.Quote1__r.Payment_Credit_Days__c != null
                       ? cli.ServiceContract.Quote1__r.Payment_Credit_Days__c
                       : null)  // Ensure '0' is treated as a string
                )
            );
            
            
            
            String productName = encloseWithQuotes(cli.Asset != null && cli.Asset.Product2 != null ? cli.Asset.Product2.Name : '');
            // Determine Product's Channel Partner Name
            String productChannelPartnerName = encloseWithQuotes(
                cli.Asset != null && cli.Asset.CP__r != null && cli.Asset.CP__r.Name != null
                ? cli.Asset.CP__r.Name // Take from Asset.CP__r if available
                : (cli.Asset != null && cli.Asset.Branch__r != null && cli.Asset.Branch__r.Name != null
                   ? cli.Asset.Branch__r.Name // Fallback to Asset.Branch__r.Name
                   : '') // Default to an empty string if both are null
            );
            
            // Determine Product's Channel Partner Number
            String productChannelPartnerNumber = encloseWithQuotes(
                cli.Asset != null && cli.Asset.CP__r != null && cli.Asset.CP__r.CP_Code__c != null
                ? cli.Asset.CP__r.CP_Code__c // Take from Asset.CP__r if available
                : (cli.Asset != null && cli.Asset.Branch__r != null && cli.Asset.Branch__r.Branch_Code__c != null
                   ? cli.Asset.Branch__r.Branch_Code__c // Fallback to Asset.Branch__r.Branch_Code__c
                   : '') // Default to an empty string if both are null
            );
            
            String productCustomerName = encloseWithQuotes(cli.Asset != null && cli.Asset.Account != null ? cli.Asset.Account.Name : ''); 
            String proposalPrice = encloseWithQuotes('');
            
            if (cli.ServiceContract != null) {
                Decimal proposedValue = null;
                
                // Check Sales Quote (Quote0__r) first
                if (cli.ServiceContract.Quote0__r != null && cli.ServiceContract.Quote0__r.Proposed_Contract_Value_Formula__c != null) {
                    proposedValue = cli.ServiceContract.Quote0__r.Proposed_Contract_Value_Formula__c;
                }
                // If not found, check CPQ Quote (Quote1__r)
                else if (cli.ServiceContract.Quote1__r != null && cli.ServiceContract.Quote1__r.Proposed_Contract_Value_Formula__c != null) {
                    proposedValue = cli.ServiceContract.Quote1__r.Proposed_Contract_Value_Formula__c;
                }
                
                // Only assign if a value is found, otherwise it remains blank
                if (proposedValue != null) {
                    proposalPrice = encloseWithQuotes(String.valueOf(proposedValue));
                }
            }
            
            
            String regionalManager = encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.Opportunity__r != null && cli.ServiceContract.Opportunity__r.Regional_Manager__r != null ? String.valueOf(cli.ServiceContract.Opportunity__r.Regional_Manager__r.EmployeeNumber) : ''); 
            String regionalManagerName = encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.Opportunity__r != null && cli.ServiceContract.Opportunity__r.Regional_Manager__r != null ? cli.ServiceContract.Opportunity__r.Regional_Manager__r.Name : ''); 
            String sac = encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.Quote0__r != null && cli.ServiceContract.Quote0__r.HSN_SAC_code_New__c != null ? cli.ServiceContract.Quote0__r.HSN_SAC_code_New__c :cli.ServiceContract != null && cli.ServiceContract.Quote1__r != null && cli.ServiceContract.Quote1__r.HSN_SAC_code__c!= null? cli.ServiceContract.Quote1__r.HSN_SAC_code__c:''); 
            String sme = encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.Opportunity__r != null ? String.valueOf(cli.ServiceContract.Opportunity__r.SME__r.EmployeeNumber) : ''); 
            String smeName = encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.Opportunity__r != null ? cli.ServiceContract.Opportunity__r.SME__r.Name : ''); 
            String smh = encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.Opportunity__r != null && cli.ServiceContract.Opportunity__r.SMH__r != null ? String.valueOf(cli.ServiceContract.Opportunity__r.SMH__r.EmployeeNumber) : ''); 
            String smhName = encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.Opportunity__r != null && cli.ServiceContract.Opportunity__r.SMH__r != null ? cli.ServiceContract.Opportunity__r.SMH__r.Name : ''); 
            String state = encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.BillingState != null ? cli.ServiceContract.BillingState : '');
            String status = '';
            
            if (cli.ServiceContract != null && cli.ServiceContract.Modification_Status__c != null) {
                // Extract the original value
                String extractedStatus = cli.ServiceContract.Modification_Status__c;
                
                // Replace specific values
                if (extractedStatus == 'Debook') {
                    status = 'Debooked';
                } else if (extractedStatus == 'Extended') {
                    status = 'Contract Extended';
                } else {
                    status = extractedStatus; // Keep other values the same 
                }
            }
            
            // Enclose the result in quotes (null will remain null)
            status = encloseWithQuotes(status);
            
            String totalAdjustedDownloadingValue = null;
            if (cli.ServiceContract.Quote0__c != null) {
                Decimal revisedValue = cli.ServiceContract.Quote0__r.Revise_Total_Downloading_Value__c;
                Decimal totalValue = cli.ServiceContract.Quote0__r.Total_Download_Value_Rollup__c;
                
                if (revisedValue != null && revisedValue != 0) {
                    totalAdjustedDownloadingValue = encloseWithQuotes(String.valueOf(revisedValue));
                } else if (totalValue != null) {
                    totalAdjustedDownloadingValue = encloseWithQuotes(String.valueOf(totalValue));
                } else if (revisedValue != null) {
                    totalAdjustedDownloadingValue = encloseWithQuotes(String.valueOf(revisedValue));
                }
            } else if (cli.ServiceContract.Quote1__c != null) {
                Decimal revisedValue = cli.ServiceContract.Quote1__r.Revise_Total_Downloading_Value__c;
                Decimal totalValue = cli.ServiceContract.Quote1__r.Total_Downloading_Value_RollUp__c;
                
                if (revisedValue != null && revisedValue != 0) {
                    totalAdjustedDownloadingValue = encloseWithQuotes(String.valueOf(revisedValue));
                } else if (totalValue != null) {
                    totalAdjustedDownloadingValue = encloseWithQuotes(String.valueOf(totalValue));
                } else if (revisedValue != null) {
                    totalAdjustedDownloadingValue = encloseWithQuotes(String.valueOf(revisedValue));
                }
            }
            
            
            String totalDownloadingValue = encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.Total_Download_Value__c != null ? String.valueOf(cli.ServiceContract.Total_Download_Value__c) : '');
            
            
            String uom = encloseWithQuotes(cli.Product2 != null && cli.Product2.Capacity_UOM__c != null ? cli.Product2.Capacity_UOM__c : ''); 
            String updatedBy = encloseWithQuotes(cli.LastModifiedBy != null ? cli.LastModifiedBy.Name : '');
            String updatedDate = encloseWithQuotes(cli.LastModifiedDate != null ? cli.LastModifiedDate.format('yyyy-MM-dd hh:mm:ss') : '');
            String warehouseName = encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.Plant__r != null && cli.ServiceContract.Plant__r.Name != null ? cli.ServiceContract.Plant__r.Name : ''); 
            String warehouseNo = encloseWithQuotes(cli.ServiceContract != null && cli.ServiceContract.Plant__r != null && cli.ServiceContract.Plant__r.Warehouse_Code__c != null ? cli.ServiceContract.Plant__r.Warehouse_Code__c : ''); 
            String quoteno = encloseWithQuotes( cli.ServiceContract != null && cli.ServiceContract.Quote0__r != null && cli.ServiceContract.Quote0__r.QuoteNumber != null 
                                               ? cli.ServiceContract.Quote0__r.QuoteNumber
                                               : cli.ServiceContract != null && cli.ServiceContract.Quote1__r != null && cli.ServiceContract.Quote1__r.Name != null
                                               ? cli.ServiceContract.Quote1__r.Name 
                                               : '');
            
            
            String quoteNoFormatted = '';
            if (!quoteNo.startsWith('Q') && quoteNo!= '') {
                quoteNoFormatted = '\'' + quoteNo;
            } else {
                quoteNoFormatted = quoteNo; // Use quoteNo as it is
            }
            String quoteLineNoFormatted = '';
            if (!quoteLineNumber.startsWith('Q') && quoteLineNumber!= '') {
                quoteLineNoFormatted = '\'' + quoteLineNumber;
            } else {
                quoteLineNoFormatted = quoteLineNumber; // Use quoteLineNumber as it is
            }
            
            // Construct the row string with all the required fields
            String rowStr = String.join(new List<String>{
                quoteNoFormatted, oppname, amc, sfdcamcid, quoteLineNoFormatted, Quotenumberbackend, erpContractNo, contractPeriodFrom, contractPeriodTo, componentNo,
                    contractPrice, model, productSerialNo, productFamily, productFamilyName,
                    productSubFamily, productSubFamilyName, channelPartnerType, channelPartnerNo,
                    channelPartnerName, activatedDate, actuators, additionalEquipment,
                    additionalEquipmentAmount, addressLine1, addressLine2, advanceReceived, age,
                    aichName, allIndiaCommercialHead, allIndiaHead, allIndiaHeadName, areaHead,
                    areaHeadName, billToPartyCustomerGroup, billToParty, billToPartySap, billtopartySF, billtopartyStar, billToPartyEmail,
                    billToPartyFirstName, billToPartyLastName, billToPartyMobileNo, billingDuePeriod,
                    billingFrequencyPeriod, bms, branchName, branchNo, capacity, actualCapacity, comments,
                    commercialExecutive, commercialExecutiveName, componentProposalPrice, contactDepartment,
                    contractCategory, contractType, contract_type_short_name, createdBy, createdDate, currentYearDownloadingPrice,
                    currentYearMarginPercent, customerInvoiceText, customerName, customerPOAmount,
                    customerPODate, customerPONo, customerPOValue, customerSector, customerSubSegment,
                    deliveryExecutive, deliveryExecutiveName, departmentName, departmentNo, discountPercent,
                    distance,documentList, documentsRequired, downloadingDeviation, downloadingValue, 
                    dutyUsage, egmEstimatedGrossMargin, egmPercent, emailId, events, factorAmount,
                    finalNetContractValue, firstName, grossContractValue, gstRate, cgstValue, sgstValue, igstValue, ugstValue, isCustomEvents,
                    keralaCess, keralaCessPercent, lastName, lastYearDownloadingPrice, lastYearMarginDownloading,
                    lastYearMarginPrice, lastYearPaymentReceived, lastYearPriceBasic, lastYearTOP,
                    mobile, netContractValue,newEndDate, overallPriceChange, poReceiptDate,
                    parentCustomerId, parentSAPCustomerId, parentSFCustomerId, parentStarCustomerId, paymentAmount, paymentCreditDays, paymentDate, planRegistrationNo,
                    planRegistrationStatus, policyName, previousOutstandingIfAny, previousPrice, priceChangePercent,
                    priceDeviation, productName, productChannelPartnerName, productChannelPartnerNumber, productCustomerName, productCustomerNo, productSapCustomerNo, productSFCustomerNo, productStarCustomerNo,
                    proposalPrice, reasonForDeviationDownloading, reasonForDeviationPrice, reasonForDeviationTOP,
                    regionalManager, regionalManagerName, reject, sac, salesOrganizationName, salesOrganizationNo,
                    sme, smeName, smh, smhName, state, status, subType, termsOfPaymentDeviation,
                    thisYearFinalPriceBasic, thisYearMarginPercent, thisYearStandardPriceBasic, totalAdjustedDownloadingValue,
                    totalDownloadingValue, uom, updatedBy, updatedDate, warehouseName, warehouseNo, waterManagement, Shiptoparty, ShiptopartySap, ShiptopartySF, ShiptopartyStar, AccountID
                    }, ',');
            
            
            csvRowValues.add(rowStr);
        }
        // Define the new CSV Header based on the fields used in the execute method
        String csvColumnHeader = '\uFEFF'+String.join(new List<String>{
            'Quote Number', 'Opportunity', 'AMC', 'sfdc_amc_id', 'Quote line number', 'Quote Number Backend', 'ERP Contract No.', 'Contract Period From', 'Contract Period To', 'Component No.',
                'Contract Price', 'Model', 'Product Serial No.', 'Product Family', 'Product Family Name',
                'Product Sub Family', 'Product Sub Family Name', 'Channel Partner Type', 'Channel Partner No.',
                'Channel Partner Name', 'Activated Date', 'Actuators', 'Additional Equipment',
                'Additional Equipment Amount', 'Address Line 1', 'Address Line 2', 'Advance Received', 'Age',
                'AICH Name', 'All India Commercial Head', 'All India Head', 'All India Head Name', 'Area Head',
                'Area Head Name', 'Bill To Party Customer Group', 'Bill-To Party', 'Bill-To Party SAP Customer ID', 'Bill-To Party Salseforce Customer ID', 'Bill-To Party Starserve Customer ID', 'Bill-To Party Email Id',
                'Bill-To Party First Name', 'Bill-To Party Last Name', 'Bill-To Party Mobile No.', 'Billing Due Period',
                'Billing Frequency Period', 'BMS', 'Branch Name', 'Branch No.', 'Capacity', 'Actual Capacity', 'Comments',
                'Commercial Executive', 'Commercial Executive Name', 'Component Proposal Price', 'Contact Department',
                'Contract Category', 'Contract Type', 'contract_type_short_name', 'Created By', 'Created Date', 'Current Year Downloading Price',
                'Current Year Margin %', 'Customer Invoice Text', 'Customer Name', 'Customer P.O. Amount',
                'Customer P.O. Date', 'Customer P.O. No.', 'Customer P.O. Value', 'Customer Sector', 'Customer Sub Segment',
                'Delivery Executive', 'Delivery Executive Name', 'Department Name', 'Department No.', 'Discount (%)',
                'Distance', 'Document List', 'Documents Required', 'Downloading Deviation', 'Downloading Value',
                'Duty/ Usage', 'EGM (Estimated Gross Margin)', 'EGM%', 'Email Id', 'Events', 'Factor Amount',
                'Final Net Contract Value', 'First Name', 'Gross Contract Value', 'GST Rate', 'CGST Rate', 'SGST Rate', 'IGST Rate', 'UGST Rate', 'Is Custom Events',
                'Kerala Cess', 'Kerela Cess Percent', 'Last Name', 'Last Year Downloading Price', 'Last Year Margin %(Downloading)',
                'Last Year Margin %(Price)', 'Last Year Payment Received', 'Last Year Price (Basic)', 'Last Year TOP',
                'Mobile', 'Net Contract Value', 'New End Date', 'Overall Price Change', 'P.O. Receipt Date',
                'Parent Customer ID','Parent SAP Customer ID','Parent Salesforce Customer ID','Parent Starserve Customer ID', 'Payment Amount', 'Payment Credit Days', 'Payment Date', 'Plan Registration No.',
                'Plan Registration Status', 'Policy Name', 'Previous Outstanding If Any', 'Previous Price', 'Price Change %',
                'Price Deviation', 'Product Name', 'Product\'s Channel Partner Name', 'Product\'s Channel Partner Number', 'Product\'s Customer Name', 'Product\'s Customer No.','Product\'s SAP Customer No.','Product\'s Salseforce Customer No.','Product\'s Starserve Customer No.',
                'Proposal Price', 'Reason for Deviation(Downloading)', 'Reason for Deviation(Price)', 'Reason for Deviation(TOP)',
                'Regional Manager', 'Regional Manager Name', 'Reject', 'SAC', 'Sales Organization Name', 'Sales Organization No.',
                'SME', 'SME Name', 'SMH', 'SMH Name', 'State', 'Status', 'Sub Type', 'Terms of Payment Deviation',
                'This Year Final Price (Basic)', 'This Year Margin %', 'This Year Standard Price (Basic)', 'Total Adjusted Downloading Value',
                'Total Downloading Value', 'UOM', 'Updated By', 'Updated Date', 'Warehouse Name', 'Warehouse No.', 'Water Management', 'Ship to party' ,'Ship to party SAP Customer ID' ,'Ship to party Salesforce Customer ID' ,'Ship to party Starserve Customer ID' , 'Account ID'
                }, ',') + '\n';
        
        
        
        
        // Combine header and row values into the final CSV content
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
        
        fileName = 'FNAME_AMC_FROM_' + formattedStartDate + '_TO_' + formattedEndDate + '_EXTTS_' + formattedDateTime + '.csv';
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
            // System.debug('Attachment created with ID: ' + attachmentObj.Id + ' and ParentId: ' + attachmentObj.ParentId);
        } else {
            // System.debug('No Daily Job Document found to attach the CSV.');
        }
        if (!String.isBlank(file) && !isTestContext) {
            System.enqueueJob(new S3FileUploadQueueable(dailyJobDocumetList[0].Id, fileName, file, folderName));
        }
    }
    
    
    public void finish(Database.BatchableContext BC) {
        
    }
}