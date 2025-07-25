public class Changed_cpq_batch implements Database.Batchable<sObject>, Database.AllowsCallouts  {
    
    public List<Daily_Job_Documents__c> dailyJobDocumetList = new List<Daily_Job_Documents__c>();
    public String csvColumnHeader;
    public String query ;
    String file = '';
    String fileName = '';
    public List<String> csvRowValues = new List<String>();
    public Boolean isTestContext = false;  
    public Date customStartDate;  // Custom start date for the file name
    public Date customEndDate; 
    public String folderName;

    
    public Changed_cpq_batch(Boolean overrideQuery, String query2,Date customStartDate, Date customEndDate, String folderName) {
     query = 'SELECT Id, ' +
        'SBQQ__Quote__r.SBQQ__Account__r.Id, ' +
        'SBQQ__Quote__r.SBQQ__Account__r.Name, ' +
        'SBQQ__Quote__r.SBQQ__Opportunity2__r.Name, ' +  // Ensure Opportunity2 Name is included
        'SBQQ__Quote__r.Service_Contract__r.ContractNumber, ' +
        'SBQQ__Quote__r.Service_Contract__r.SAP_Contract_Number__c,SBQQ__Quote__r.CP__r.Name,SBQQ__Quote__r.CP__r.CP_Code__c,SBQQ__Quote__r.SBQQ__NetAmount__c,SBQQ__Quote__r.HSN_SAC_code__c, ' +
        'SBQQ__Quote__r.BSL_AM__r.EmployeeNumber,SBQQ__Quote__r.Plant__r.Warehouse_Code__c,SBQQ__Quote__r.SBQQ__Account__r.Parent.Customer_Code__c ,SBQQ__Quote__r.SBQQ__Status__c,Asset__r.Capacity__c,CreatedBy.Name,CreatedDate,SBQQ__Quote__r.SBQQ__PrimaryContact__r.Department_lookup__r.Department_Number__c, SBQQ__Quote__r.BSL_AM__r.Name, ' +
        'SBQQ__Quote__r.SBQQ__Account__r.Group__c,SBQQ__Quote__r.Name,SBQQ__Quote__r.Plant__r.Name ,SBQQ__Quote__r.SBQQ__Account__r.Parent.SAP_Customer_Id__c ,SBQQ__Quote__r.SBQQ__Account__r.SAP_Customer_Id__c ,SBQQ__Quote__r.Proposed_Period_From__c,SBQQ__Quote__r.Proposed_Period_To__c,Asset__r.Product2.Product_Family__r.Code__c,Asset__r.Actual_Capacity__c,Previous_Contract_Price__c,SBQQ__Quote__r.SBQQ__Opportunity2__r.Amount,SBQQ__Quote__r.Kerela_Cess__c,SBQQ__Quote__r.Billing_Due_Period__c, SBQQ__Quote__r.SBQQ__Account__r.Customer_Code__c, ' +
        'SBQQ__Quote__r.SBQQ__PrimaryContact__r.Email,Asset__r.Account.Name,SBQQ__Quote__r.SBQQ__Account__r.Parent.Customer_ID__c ,Asset__r.Account.SAP_Customer_Id__c, ' +
        'SBQQ__Quote__r.SBQQ__PrimaryContact__r.Phone,SBQQ__Quote__r.Ship_to_Party__r.SAP_Customer_Id__c,SBQQ__Quote__r.Ship_to_Party__r.Customer_ID__c, ' +
        'SBQQ__Quote__r.SBQQ__PrimaryContact__r.FirstName,Name, SBQQ__Quote__r.SBQQ__PrimaryContact__r.LastName, ' +
        'SBQQ__Quote__r.SBQQ__Opportunity2__r.Branch_Commericial__r.EmployeeNumber,Asset__r.Branch__r.Name, ' +
        'SBQQ__Quote__r.SBQQ__Opportunity2__r.Branch_Commericial__r.Name,SBQQ__Quote__r.Billing_Frequency_Period__c, ' +
        'SBQQ__Quote__r.SBQQ__Opportunity2__r.SDE__r.EmployeeNumber,LastModifiedDate, SBQQ__Quote__r.SBQQ__Opportunity2__r.SDE__r.Name, ' +
        'SBQQ__Quote__r.SBQQ__Opportunity2__r.Document_List__c, ' +
        'SBQQ__Quote__r.SBQQ__Opportunity2__r.Document_Required__c, ' +
        'SBQQ__Quote__r.SBQQ__Opportunity2__r.PO_Total_Value__c, ' +
        'SBQQ__Quote__r.SBQQ__Opportunity2__r.PO_Receipt_Date__c,SBQQ__Quote__r.PO_Number__c, ' +
        'SBQQ__Quote__r.CGST__c, SBQQ__Quote__r.IGST__c, SBQQ__Quote__r.SGST__c, SBQQ__Quote__r.UGST__c, ' +
        'SBQQ__Quote__r.Kerela_Cess_Percent__c, SBQQ__Quote__r.Terms_of_Payment_Customer__c, ' +
        'SBQQ__Quote__r.SBQQ__Account__r.BillingStreet, SBQQ__Quote__r.SBQQ__Account__r.BillingCity, SBQQ__Quote__r.SBQQ__Account__r.BillingState, ' +
        'SBQQ__Quote__r.SBQQ__Account__r.BillingPostalCode, SBQQ__Quote__r.SBQQ__Account__r.BillingCountry, SBQQ__Quote__r.SBQQ__Account__r.BillingCountryCode, SBQQ__Quote__r.SBQQ__Account__r.BillingStateCode, ' +
        'SBQQ__Quote__r.Ship_to_Party__r.Customer_Code__c, ' +
        'SBQQ__Quote__r.BSL_AICH__r.Name, SBQQ__Quote__r.BSL_AICH__r.EmployeeNumber,SBQQ__Quote__r.SBQQ__Account__r.Customer_ID__c, ' +
        'SBQQ__Quote__r.BSL_AIH__r.Name, SBQQ__Quote__r.BSL_AIH__r.EmployeeNumber, ' +
        'SBQQ__Quote__r.BSL_RM__r.Name, SBQQ__Quote__r.BSL_RM__r.EmployeeNumber, ' +
        'SBQQ__Quote__r.BSL_SMH__r.Name, SBQQ__Quote__r.BSL_SMH__r.EmployeeNumber, ' +
        'SBQQ__Quote__r.BSL_SME__r.Name, SBQQ__Quote__r.BSL_SME__r.EmployeeNumber,SBQQ__Quote__r.Service_Contract__r.External_Id__c, ' +
        'SBQQ__Quote__r.Department__r.Name,Asset__r.CP__r.CP_Code__c, SBQQ__Quote__r.Department__r.Department_Number__c, ' +
        'SBQQ__Quote__r.Hike_compared_to_last_year__c, ' +
        'SBQQ__Quote__r.Number_of_Events__c, ' +  // For isCustomEvents logic
        'SBQQ__Quote__r.Total_Downloading_Value_RollUp__c, SBQQ__Quote__r.Revise_Total_Downloading_Value__c, ' +
        'SBQQ__Quote__r.Previous_Downloading_Value__c,Asset__r.Product2.Product_Family__r.Name, SBQQ__Quote__r.EGM_Formula__c, SBQQ__Quote__r.EGM_Percent_Formula__c, ' +
        'SBQQ__Quote__r.Comment__c, SBQQ__Quote__r.Contract_Category__c, ' +
        'SBQQ__Quote__r.Contract_Type__c, SBQQ__Quote__r.Total_Price1__c,SBQQ__Quote__r.SBQQ__Opportunity2__r.Customer_Invoice_Text__c,Asset__r.Branch__r.Branch_Code__c, SBQQ__Quote__r.Grand_Total__c, ' +
        'SBQQ__Quote__r.Last_Year_Price_for_Asset__c, SBQQ__Quote__r.Quote_Number_Backend__c, ' +
        'SBQQ__Quote__r.Proposed_Contract_Value_Formula__c, SBQQ__Quote__r.Final_Net_Contract_Value_Currency__c, ' +
        'SBQQ__Quote__r.Gross_Contract_Value_Currency__c, SBQQ__Quote__r.Net_Contract_Value_Currency__c, ' +
        'SBQQ__Quote__r.Overall_Price_Change__c, SBQQ__Quote__r.Payment_Credit_Days__c, ' +
        'SBQQ__Quote__r.Branch__r.Name, SBQQ__Quote__r.Branch__r.Branch_Code__c, ' +
        'SBQQ__Quote__r.Branch__r.Warehouse__r.Name, SBQQ__Quote__r.Branch__r.Warehouse__r.Warehouse_Code__c, ' +
        'SBQQ__Quote__r.SBQQ__Account__r.FirstName, SBQQ__Quote__r.SBQQ__Account__r.LastName, SBQQ__Quote__r.SBQQ__Account__r.Phone, SBQQ__Quote__r.SBQQ__Account__r.Industry, ' +
        'SBQQ__Quote__r.SBQQ__Account__r.Sub_Segment__c, ' +
        'SBQQ__ListPrice__c, SBQQ__NetTotal__c,Total__c, Sell_Price__c, SBQQ__NetPrice__c, SBQQ__Discount__c, ' +
        'Revised_Download_Value__c, Standard_Downloading_Value__c,SBQQ__Quote__r.Discount__c, Asset__r.Age_Of_Machine__c,Asset__r.Product2.Product_Sub_Family__r.Name,SBQQ__Quote__r.PO_Date__c, ' +
        'Asset__r.Account.Customer_Code__c,LastModifiedBy.Name, Asset__r.Account.Customer_ID__c, Asset__r.Component_Id__c, ' +
        'Asset__r.Product_Model__c, Asset__r.SerialNumber, Asset__r.Product_Family__r.Code__c,Asset__r.Product2.Capacity__c, ' +
        'Asset__r.Product_Family__r.Name, Asset__r.Product_Sub_Family__r.Code__c,Asset__r.Product2.Product_Sub_Family__r.Code__c, Asset__r.Product_Sub_Family__r.Name, ' +
        'SBQQ__Product__r.Name, SBQQ__Product__r.Capacity_UOM__c,SBQQ__Quote__r.CP__r.Type, Asset__r.CP__r.Name, Asset__r.CP__r.Type ' +
        'FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__r.SBQQ__Opportunity2__r.StageName!=\'Closed - Won\' and SBQQ__Quote__r.Service_Contract__c =null and LastModifiedDate=Yesterday';
        
        if (overrideQuery) {
            query = query2;
        }
        this.customStartDate = customStartDate;  // Store the custom start date
        this.customEndDate = customEndDate; 
        this.folderName = folderName;
    }
    public Changed_cpq_batch(Boolean overrideQuery, String query2, String folderName) {
        this(overrideQuery, query2, null, null, folderName);  // Default to null for custom dates
    }
    
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
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
    
    public void execute(Database.BatchableContext BC, List<SBQQ__QuoteLine__c> scope) {
        
        
        // Retrieve or create a Daily Job Document
        List<Daily_Job_Documents__c> existingDocs = [SELECT Id, CreatedDate FROM Daily_Job_Documents__c WHERE CreatedDate = TODAY];
        
        if (existingDocs.isEmpty()) {
            Daily_Job_Documents__c newDoc = new Daily_Job_Documents__c();
            newDoc.Name = 'Daily Job ' + Date.today().year() + '-' + Date.today().month() + '-' + Date.today().day();
            insert newDoc;
            dailyJobDocumetList.add(newDoc);
           // System.debug('New Daily Job Document created with ID: ' + newDoc.Id);
        } else {
            dailyJobDocumetList = existingDocs;
            //System.debug('Reusing existing Daily Job Document with ID: ' + dailyJobDocumetList[0].Id);
        }
        
        // Step 1: Initialize a map to store PMS_Schedule__c records by Opportunity__c and a map for event counts
        Map<Id, Boolean> pmsScheduleMap = new Map<Id, Boolean>();
        Map<Id, Integer> pmsEventCountMap = new Map<Id, Integer>();  // To store event counts for each Opportunity
        
        // Collect all related Opportunity IDs from SBQQ__QuoteLine__c
        Set<Id> opportunityIds = new Set<Id>();
        for (SBQQ__QuoteLine__c quoteLine : scope) {
            if (quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__c != null) {
                opportunityIds.add(quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__c);
            }
        }
        
        // Step 2: Query related PMS_Schedule__c records and populate the map
        if (!opportunityIds.isEmpty()) {
            List<PMS_Schedule__c> pmsSchedules = [
                SELECT Opportunity__c FROM PMS_Schedule__c WHERE Opportunity__c IN :opportunityIds
            ];
            
            // Populate the maps with data from PMS_Schedule__c
            for (PMS_Schedule__c pms : pmsSchedules) {
                // Mark the Opportunity__c as having related PMS schedules
                pmsScheduleMap.put(pms.Opportunity__c, true);
                
                // Initialize the event count for the Opportunity if not already present
                if (!pmsEventCountMap.containsKey(pms.Opportunity__c)) {
                    pmsEventCountMap.put(pms.Opportunity__c, 0);
                }
                
                // Increment the event count for this Opportunity
                pmsEventCountMap.put(pms.Opportunity__c, pmsEventCountMap.get(pms.Opportunity__c) + 1);
            }
        }
        
        // Initialize Asset IDs and the Warranty Map
        Set<Id> assetIds = new Set<Id>();
        for (SBQQ__QuoteLine__c quoteLine : scope) {
            if (quoteLine.Asset__c  != null) {
                assetIds.add(quoteLine.Asset__c );
            }
        }
        
        Map<Id, String> assetWarrantyMap = new Map<Id, String>();
        
        if (!assetIds.isEmpty()) {
            List<AssetWarranty> warranties = [
                SELECT Warranty_Term_Name__c, AssetId 
                FROM AssetWarranty 
                WHERE AssetId IN :assetIds AND WarrantyTerm.WarrantyType = 'AMC'
            ];
            for (AssetWarranty warranty : warranties) {
                if (warranty.Warranty_Term_Name__c != null) {
                    assetWarrantyMap.put(warranty.AssetId, warranty.Warranty_Term_Name__c);
                }
            }
        }
        
        for (SBQQ__QuoteLine__c quoteLine : scope) {
            String accountID = '';
            
            if (quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.SBQQ__Account__r != null) {
                String accountIdRaw = quoteLine.SBQQ__Quote__r.SBQQ__Account__r.Id;
                
                // Validate ID length to ensure it's a valid Salesforce ID
                if (accountIdRaw != null && (accountIdRaw.length() == 15 || accountIdRaw.length() == 18)) {
                    accountID = encloseWithQuotes(accountIdRaw);
                } else {
                    // Log invalid ID scenario
                    accountID = encloseWithQuotes(''); // Fallback to empty quotes for invalid IDs
                }
            } else {
                // Log null Account or Quote scenario
                accountID = encloseWithQuotes('');
            }
            
            String oppName = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r != null ? quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name : ''
            );
            
            // Service Contract Information
            String amc = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r.Service_Contract__r != null ? quoteLine.SBQQ__Quote__r.Service_Contract__r.External_Id__c : ''
            );
            String sfdcamcid = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r.Service_Contract__r != null ? quoteLine.SBQQ__Quote__r.Service_Contract__r.ContractNumber : ''
            );
            String erpContractNo = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r.Service_Contract__r != null ? quoteLine.SBQQ__Quote__r.Service_Contract__r.SAP_Contract_Number__c : ''
            );
            
            String actuators = encloseWithQuotes('');
            String additionalEquipment = encloseWithQuotes('');
            String additionalEquipmentAmount = encloseWithQuotes('');
            String advanceReceived = encloseWithQuotes('');
            String age = '';
            
            if (quoteLine.Asset__r != null && quoteLine.Asset__r.Age_Of_Machine__c != null) {
                age = encloseWithQuotes(String.valueOf(quoteLine.Asset__r.Age_Of_Machine__c));
            } else {
                // If Age_Of_Machine__c is null or Asset__r is null, set to an empty value
                age = encloseWithQuotes('');
            }
            
            // Area Head Information
            String areaHead = '';
            String areaHeadName = '';
            
            if (quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.BSL_AM__r != null) {
                // Area Head Employee Number
                if (quoteLine.SBQQ__Quote__r.BSL_AM__r.EmployeeNumber != null) {
                    areaHead = encloseWithQuotes(String.valueOf(quoteLine.SBQQ__Quote__r.BSL_AM__r.EmployeeNumber));
                } else {
                    areaHead = encloseWithQuotes('');
                }
                
                // Area Head Name
                if (quoteLine.SBQQ__Quote__r.BSL_AM__r.Name != null) {
                    areaHeadName = encloseWithQuotes(quoteLine.SBQQ__Quote__r.BSL_AM__r.Name);
                } else {
                    areaHeadName = encloseWithQuotes('');
                }
            } else {
                // Fallback for null Area Head or Quote
                areaHead = encloseWithQuotes('');
                areaHeadName = encloseWithQuotes('');
            }
            
            String billToPartyCustomerGroup = '';
            
            if (quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.SBQQ__Account__r != null) {
                if ('NAMO'.equals(quoteLine.SBQQ__Quote__r.SBQQ__Account__r.Group__c)) {
                    billToPartyCustomerGroup = '01';  // Set to '01' if the Group is NAMO
                } else {
                    billToPartyCustomerGroup = '';  // Set to blank for anything else
                }
            } else {
                // Null scenario
                billToPartyCustomerGroup = '';
            }
            
            // Enclose the result in quotes
            billToPartyCustomerGroup = encloseWithQuotes(billToPartyCustomerGroup);
            
            String billToPartyFirstName = '';
            
            if (quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.SBQQ__Account__r != null) {
                billToPartyFirstName = encloseWithQuotes(quoteLine.SBQQ__Quote__r.SBQQ__Account__r.Name != null
                                                         ? quoteLine.SBQQ__Quote__r.SBQQ__Account__r.Name
                                                         : ''
                                                        );
            } else {
                // Null scenario
                billToPartyFirstName = encloseWithQuotes('');
            }
            String billToPartyLastName =encloseWithQuotes('');
            String billToPartyEmail = '';
            
            if (quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.SBQQ__PrimaryContact__r != null) {
                billToPartyEmail = encloseWithQuotes(
                    quoteLine.SBQQ__Quote__r.SBQQ__PrimaryContact__r.Email != null 
                    ? quoteLine.SBQQ__Quote__r.SBQQ__PrimaryContact__r.Email 
                    : ''
                );
            } else {
                // Null scenario
                billToPartyEmail = encloseWithQuotes('');
            }
            String bms = encloseWithQuotes('');
            
            
            String commercialExecutive = '';
            
            if (quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r != null &&
                quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.Branch_Commericial__r != null) {
                    commercialExecutive = encloseWithQuotes(
                        quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.Branch_Commericial__r.EmployeeNumber != null
                        ? quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.Branch_Commericial__r.EmployeeNumber
                        : ''
                    );
                } else {
                    // Null scenario
                    commercialExecutive = encloseWithQuotes('');
                }
            String commercialExecutiveName = '';
            
            if (quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r != null &&
                quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.Branch_Commericial__r != null) {
                    commercialExecutiveName = encloseWithQuotes(
                        quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.Branch_Commericial__r.Name != null
                        ? quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.Branch_Commericial__r.Name
                        : ''
                    );
                } else {
                    // Null scenario
                    commercialExecutiveName = encloseWithQuotes('');
                }
            
            String contactDepartment = '';
            
            if (quoteLine.SBQQ__Quote__r != null && 
                quoteLine.SBQQ__Quote__r.SBQQ__PrimaryContact__r != null && 
                quoteLine.SBQQ__Quote__r.SBQQ__PrimaryContact__r.Department_lookup__r != null) {
                    contactDepartment = encloseWithQuotes(
                        quoteLine.SBQQ__Quote__r.SBQQ__PrimaryContact__r.Department_lookup__r.Department_Number__c != null
                        ? quoteLine.SBQQ__Quote__r.SBQQ__PrimaryContact__r.Department_lookup__r.Department_Number__c
                        : ''
                    );
                } else {
                    // Null scenario
                    contactDepartment = encloseWithQuotes('');
                }
            String customerSector = '';
            
            if (quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.SBQQ__Account__r != null) {
                customerSector = encloseWithQuotes(
                    quoteLine.SBQQ__Quote__r.SBQQ__Account__r.Industry != null 
                    ? quoteLine.SBQQ__Quote__r.SBQQ__Account__r.Industry 
                    : ''
                );
            } else {
                // Null scenario
                customerSector = encloseWithQuotes('');
            }
            String customerSubSegment = '';
            
            if (quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.SBQQ__Account__r != null) {
                customerSubSegment = encloseWithQuotes(
                    quoteLine.SBQQ__Quote__r.SBQQ__Account__r.Sub_Segment__c != null 
                    ? quoteLine.SBQQ__Quote__r.SBQQ__Account__r.Sub_Segment__c 
                    : ''
                );
            } else {
                // Null scenario
                customerSubSegment = encloseWithQuotes('');
            }
            String deliveryExecutive = '';
            
            if (quoteLine.SBQQ__Quote__r != null && 
                quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r != null && 
                quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.SDE__r != null) {
                    deliveryExecutive = encloseWithQuotes(
                        quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.SDE__r.EmployeeNumber != null
                        ? quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.SDE__r.EmployeeNumber
                        : ''
                    );
                } else {
                    // Null scenario
                    deliveryExecutive = encloseWithQuotes('');
                }
            String deliveryExecutiveName = '';
            
            if (quoteLine.SBQQ__Quote__r != null && 
                quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r != null && 
                quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.SDE__r != null) {
                    deliveryExecutiveName = encloseWithQuotes(
                        quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.SDE__r.Name != null
                        ? quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.SDE__r.Name
                        : ''
                    );
                } else {
                    // Null scenario
                    deliveryExecutiveName = encloseWithQuotes('');
                }
            String downloadingDeviation = encloseWithQuotes('');
            String dutyUsage = encloseWithQuotes('');
            String gstRate = '';
            
            Decimal cgst = null, igst = null, sgst = null, ugst = null;
            
            // Retrieve GST values from SBQQ__Quote__r
            if (quoteLine.SBQQ__Quote__r != null) {
                cgst = quoteLine.SBQQ__Quote__r.CGST__c;
                igst = quoteLine.SBQQ__Quote__r.IGST__c;
                sgst = quoteLine.SBQQ__Quote__r.SGST__c;
                ugst = quoteLine.SBQQ__Quote__r.UGST__c;
            }
            
            // Calculate total GST rate if at least one value is present
            if (cgst != null || igst != null || sgst != null || ugst != null) {
                Decimal totalGstRate = (cgst != null ? cgst : 0) +
                    (igst != null ? igst : 0) +
                    (sgst != null ? sgst : 0) +
                    (ugst != null ? ugst : 0);
                gstRate = encloseWithQuotes(String.valueOf(totalGstRate));
            } else {
                gstRate = encloseWithQuotes(''); // Set to blank if no GST values are present
            }
            
            String cgstValue = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.CGST__c != null
                ? String.valueOf(quoteLine.SBQQ__Quote__r.CGST__c)
                : ''
            );
            String sgstValue = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.SGST__c != null
                ? String.valueOf(quoteLine.SBQQ__Quote__r.SGST__c)
                : ''
            );
            String ugstValue = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.UGST__c != null
                ? String.valueOf(quoteLine.SBQQ__Quote__r.UGST__c)
                : ''
            );
            String igstValue = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.IGST__c != null
                ? String.valueOf(quoteLine.SBQQ__Quote__r.IGST__c)
                : ''
            );
            String isCustomEvents = encloseWithQuotes(''); // Default value
            String events = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.Number_of_Events__c != null
                ? String.valueOf(quoteLine.SBQQ__Quote__r.Number_of_Events__c)
                : ''
            );
            
            // Check if the Quote and Opportunity exist
            if (quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__c != null) {
                Id oppId = quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__c;
                
                // Check if the Opportunity has related PMS schedules
                if (pmsScheduleMap.containsKey(oppId) && pmsScheduleMap.get(oppId)) {
                    isCustomEvents = encloseWithQuotes('Y'); // Yes, related PMS schedules exist
                    
                    // If PMS schedules exist, set the events to the number of PMS events
                    Integer eventCount = pmsEventCountMap.get(oppId);
                    events = encloseWithQuotes(String.valueOf(eventCount)); // Use the count of PMS events
                } else {
                    isCustomEvents = encloseWithQuotes('N'); // No related PMS schedules
                    
                    // Fallback to Number_of_Events__c from quoteLine.SBQQ__Quote__r if PMS schedules do not exist
                    if (quoteLine.SBQQ__Quote__r.Number_of_Events__c != null) {
                        events = encloseWithQuotes(String.valueOf(quoteLine.SBQQ__Quote__r.Number_of_Events__c));
                    } else {
                        events = encloseWithQuotes(''); // Default to empty string if no event data
                    }
                }
            }
            
            String keralaCessPercent = '';
            if (quoteLine.SBQQ__Quote__r != null) {
                // Check for Kerala Cess Percent at the Quote level
                if (quoteLine.SBQQ__Quote__r.Kerela_Cess_Percent__c != null) {
                    keralaCessPercent = encloseWithQuotes(String.valueOf(quoteLine.SBQQ__Quote__r.Kerela_Cess_Percent__c));
                } else {
                    // Default to empty string if value is null
                    keralaCessPercent = encloseWithQuotes('');
                }
            } else {
                // Fallback if SBQQ__Quote__r is null
                keralaCessPercent = encloseWithQuotes('');
            }
            String lastYearPaymentReceived = encloseWithQuotes('');
            String lastYearTOP = '';
            if (quoteLine.SBQQ__Quote__r != null) {
                if (quoteLine.SBQQ__Quote__r.Terms_of_Payment_Customer__c != null) {
                    lastYearTOP = encloseWithQuotes(quoteLine.SBQQ__Quote__r.Terms_of_Payment_Customer__c);
                } else {
                    lastYearTOP = encloseWithQuotes(''); // Default to empty string if null
                }
            } else {
                lastYearTOP = encloseWithQuotes(''); // Fallback for null SBQQ__Quote__r
            }
            String newEndDate=encloseWithQuotes('');
            String planRegistrationNo = encloseWithQuotes('');
            String planRegistrationStatus = encloseWithQuotes('');
            String policyName = encloseWithQuotes(''); // Default value
            
            if (quoteLine.Asset__c != null && assetWarrantyMap.containsKey(quoteLine.Asset__c)) {
                policyName = encloseWithQuotes(assetWarrantyMap.get(quoteLine.Asset__c));
            }
            String previousOutstandingIfAny = encloseWithQuotes('');
            
            String productCustomerNo =  encloseWithQuotes(quoteLine.Asset__r != null && quoteLine.Asset__r.Account.SAP_Customer_Id__c != null ? quoteLine.Asset__r.Account.SAP_Customer_Id__c  : '');
            String productSapCustomerNo=  encloseWithQuotes(quoteLine.Asset__r != null && quoteLine.Asset__r.Account.SAP_Customer_Id__c != null ? quoteLine.Asset__r.Account.SAP_Customer_Id__c : '');
            String productSFCustomerNo=  encloseWithQuotes(quoteLine.Asset__r != null && quoteLine.Asset__r.Account.Customer_ID__c != null ? quoteLine.Asset__r.Account.Customer_ID__c : '');
            String productStarCustomerNo=  encloseWithQuotes(quoteLine.Asset__r != null && quoteLine.Asset__r.Account.Customer_Code__c != null ? quoteLine.Asset__r.Account.Customer_Code__c : '');
            
            String reasonForDeviationDownloading = encloseWithQuotes('');//need to check
            String reasonForDeviationPrice = encloseWithQuotes('');// need to check
            String reasonForDeviationTOP = encloseWithQuotes('');//need to check
            String reject = encloseWithQuotes('');
            String distance = encloseWithQuotes('');
            String salesOrganizationName = encloseWithQuotes('BSL');
            String salesOrganizationNo = encloseWithQuotes('1000');
            
            String subType = '';
            if (quoteLine.Asset__r != null && quoteLine.Asset__r.CP__r != null) {
                if (quoteLine.Asset__r.CP__r.Type != null) {
                    subType = encloseWithQuotes(quoteLine.Asset__r.CP__r.Type);
                } else {
                    subType = encloseWithQuotes(''); // Type is null
                }
            } else {
                subType = encloseWithQuotes(''); // Null Asset__r or CP__r
            }
            
            String termsOfPaymentDeviation = encloseWithQuotes('');
            
            String thisYearMarginPercent = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null 
                ? (quoteLine.SBQQ__Quote__r.Hike_compared_to_last_year__c != null 
                   ? String.valueOf(quoteLine.SBQQ__Quote__r.Hike_compared_to_last_year__c) 
                   : null // Fallback if `Hike_compared_to_last_year__c` is null
                  )
                : null // Fallback if `SBQQ__Quote__r` is null
            );
            
            String waterManagement = encloseWithQuotes('');
            String factorAmount = encloseWithQuotes('0'); 
            
            String billToParty = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.SBQQ__Account__r.SAP_Customer_Id__c != null 
                ? quoteLine.SBQQ__Quote__r.SBQQ__Account__r.SAP_Customer_Id__c 
                : ''
            );
            String billToPartySap = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.SBQQ__Account__r.SAP_Customer_Id__c != null 
                ? quoteLine.SBQQ__Quote__r.SBQQ__Account__r.SAP_Customer_Id__c 
                : ''
            );
            String billtopartySF = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.SBQQ__Account__r.Customer_ID__c != null 
                ? quoteLine.SBQQ__Quote__r.SBQQ__Account__r.Customer_ID__c 
                : ''
            );
            String billtopartyStar = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.SBQQ__Account__r.Customer_Code__c != null 
                ? quoteLine.SBQQ__Quote__r.SBQQ__Account__r.Customer_Code__c 
                : ''
            );
            
            String Shiptoparty = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null 
                ? (quoteLine.SBQQ__Quote__r.Ship_to_Party__r != null && quoteLine.SBQQ__Quote__r.Ship_to_Party__r.SAP_Customer_Id__c != null 
                   ? quoteLine.SBQQ__Quote__r.Ship_to_Party__r.SAP_Customer_Id__c 
                   : (quoteLine.SBQQ__Quote__r.SBQQ__Account__r != null && quoteLine.SBQQ__Quote__r.SBQQ__Account__r.SAP_Customer_Id__c != null 
                      ? quoteLine.SBQQ__Quote__r.SBQQ__Account__r.SAP_Customer_Id__c 
                      : ''
                     )
                  )
                : ''
            );
            String ShiptopartySap = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.Ship_to_Party__r.SAP_Customer_Id__c != null 
                ? quoteLine.SBQQ__Quote__r.Ship_to_Party__r.SAP_Customer_Id__c 
                : ''
            );
            String ShiptopartySF = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.Ship_to_Party__r.Customer_ID__c != null 
                ? quoteLine.SBQQ__Quote__r.Ship_to_Party__r.Customer_ID__c 
                : ''
            );
            String ShiptopartyStar = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.Ship_to_Party__r.Customer_Code__c != null 
                ? quoteLine.SBQQ__Quote__r.Ship_to_Party__r.Customer_Code__c 
                : ''
            );
            
            // Contract Period From
            String contractPeriodFrom = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.Proposed_Period_From__c != null
                ? DateTime.newInstance(quoteLine.SBQQ__Quote__r.Proposed_Period_From__c, Time.newInstance(0, 0, 0, 0)).format('dd-MMM-yyyy') 
                : ''
            );
            
            // Contract Period To
            String contractPeriodTo = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.Proposed_Period_To__c != null
                ? DateTime.newInstance(quoteLine.SBQQ__Quote__r.Proposed_Period_To__c, Time.newInstance(0, 0, 0, 0)).format('dd-MMM-yyyy') 
                : ''
            );
            
            
            String componentNo = encloseWithQuotes(
                quoteLine.Asset__r != null && quoteLine.Asset__r.Component_Id__c != null
                ? quoteLine.Asset__r.Component_Id__c
                : ''
            );
            
            String model = encloseWithQuotes(
                quoteLine.Asset__r != null && quoteLine.Asset__r.Product_Model__c != null 
                ? quoteLine.Asset__r.Product_Model__c 
                : ''
            );
            
            String productSerialNo = encloseWithQuotes(
                quoteLine.Asset__r != null && quoteLine.Asset__r.SerialNumber != null 
                ? quoteLine.Asset__r.SerialNumber 
                : ''
            );
            
            String productFamily = encloseWithQuotes(
                quoteLine.Asset__r != null 
                ? (quoteLine.Asset__r.Product_Family__r != null && quoteLine.Asset__r.Product_Family__r.Code__c != null 
                   ? quoteLine.Asset__r.Product_Family__r.Code__c 
                   : (quoteLine.Asset__r.Product2 != null && quoteLine.Asset__r.Product2.Product_Family__r != null && quoteLine.Asset__r.Product2.Product_Family__r.Code__c != null 
                      ? quoteLine.Asset__r.Product2.Product_Family__r.Code__c 
                      : '')) 
                : ''
            );
            
            
            // Product Family Name
            String productFamilyName = encloseWithQuotes(
                quoteLine.Asset__r != null 
                ? (quoteLine.Asset__r.Product_Family__r != null && quoteLine.Asset__r.Product_Family__r.Name != null 
                   ? quoteLine.Asset__r.Product_Family__r.Name 
                   : (quoteLine.Asset__r.Product2 != null && quoteLine.Asset__r.Product2.Product_Family__r != null && quoteLine.Asset__r.Product2.Product_Family__r.Name != null 
                      ? quoteLine.Asset__r.Product2.Product_Family__r.Name 
                      : ''))
                : ''
            );
            
            // Product Sub Family Code
            String productSubFamily = encloseWithQuotes(
                quoteLine.Asset__r != null 
                ? (quoteLine.Asset__r.Product_Sub_Family__r != null && quoteLine.Asset__r.Product_Sub_Family__r.Code__c != null 
                   ? quoteLine.Asset__r.Product_Sub_Family__r.Code__c 
                   : (quoteLine.Asset__r.Product2 != null && quoteLine.Asset__r.Product2.Product_Sub_Family__r != null && quoteLine.Asset__r.Product2.Product_Sub_Family__r.Code__c != null 
                      ? quoteLine.Asset__r.Product2.Product_Sub_Family__r.Code__c 
                      : ''))
                : ''
            );
            
            // Product Sub Family Name
            String productSubFamilyName = encloseWithQuotes(
                quoteLine.Asset__r != null 
                ? (quoteLine.Asset__r.Product_Sub_Family__r != null && quoteLine.Asset__r.Product_Sub_Family__r.Name != null 
                   ? quoteLine.Asset__r.Product_Sub_Family__r.Name 
                   : (quoteLine.Asset__r.Product2 != null && quoteLine.Asset__r.Product2.Product_Sub_Family__r != null && quoteLine.Asset__r.Product2.Product_Sub_Family__r.Name != null 
                      ? quoteLine.Asset__r.Product2.Product_Sub_Family__r.Name 
                      : ''))
                : ''
            );
            
            
            // Determine Channel Partner Type
            String channelPartnerType = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.CP__r != null && quoteLine.SBQQ__Quote__r.CP__r.Type != null
                ? quoteLine.SBQQ__Quote__r.CP__r.Type // Take from SBQQ__Quote__r.CP__r if available
                : (quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.Branch__r != null
                   ? 'Branch' // Use "Branch" if SBQQ__Quote__r.Branch__r exists
                   : null) // Default to null if both CP__r and Branch__r are unavailable
            );
            
            // Determine Channel Partner Number
            String channelPartnerNo = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.CP__r != null && quoteLine.SBQQ__Quote__r.CP__r.CP_Code__c != null
                ? quoteLine.SBQQ__Quote__r.CP__r.CP_Code__c // Take from SBQQ__Quote__r.CP__r if available
                : (quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.Branch__r != null && quoteLine.SBQQ__Quote__r.Branch__r.Branch_Code__c != null
                   ? quoteLine.SBQQ__Quote__r.Branch__r.Branch_Code__c // Fallback to Branch__r if CP__r is not available
                   : null) // Default to null if both CP__r and Branch__r are unavailable
            );
            
            // Determine Channel Partner Name
            String channelPartnerName = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.CP__r != null && quoteLine.SBQQ__Quote__r.CP__r.Name != null
                ? quoteLine.SBQQ__Quote__r.CP__r.Name // Take from SBQQ__Quote__r.CP__r if available
                : (quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.Branch__r != null && quoteLine.SBQQ__Quote__r.Branch__r.Name != null
                   ? quoteLine.SBQQ__Quote__r.Branch__r.Name // Fallback to Branch__r if CP__r is not available
                   : null) // Default to null if both CP__r and Branch__r are unavailable
            );
            
            
            
            String activatedDate = encloseWithQuotes('');
            
            String addressLine1 = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.SBQQ__Account__r != null
                ? (quoteLine.SBQQ__Quote__r.SBQQ__Account__r.BillingStreet != null ? quoteLine.SBQQ__Quote__r.SBQQ__Account__r.BillingStreet : '') + ' ' +
                (quoteLine.SBQQ__Quote__r.SBQQ__Account__r.BillingCity != null ? quoteLine.SBQQ__Quote__r.SBQQ__Account__r.BillingCity : '') + ' ' +
                (quoteLine.SBQQ__Quote__r.SBQQ__Account__r.BillingState != null ? quoteLine.SBQQ__Quote__r.SBQQ__Account__r.BillingState : '') + ' ' +
                (quoteLine.SBQQ__Quote__r.SBQQ__Account__r.BillingPostalCode != null ? quoteLine.SBQQ__Quote__r.SBQQ__Account__r.BillingPostalCode : '') + ' ' +
                (quoteLine.SBQQ__Quote__r.SBQQ__Account__r.BillingCountry != null ? quoteLine.SBQQ__Quote__r.SBQQ__Account__r.BillingCountry : '') + ' ' +
                (quoteLine.SBQQ__Quote__r.SBQQ__Account__r.BillingCountryCode != null ? quoteLine.SBQQ__Quote__r.SBQQ__Account__r.BillingCountryCode : '') + ' ' +
                (quoteLine.SBQQ__Quote__r.SBQQ__Account__r.BillingStateCode != null ? quoteLine.SBQQ__Quote__r.SBQQ__Account__r.BillingStateCode : '')
                : ''
            );
            
            String addressLine2 = encloseWithQuotes('');
            
            String aichName = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.BSL_AICH__r != null && quoteLine.SBQQ__Quote__r.BSL_AICH__r.Name != null 
                ? quoteLine.SBQQ__Quote__r.BSL_AICH__r.Name 
                : ''
            );
            
            String allIndiaCommercialHead = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.BSL_AICH__r != null && quoteLine.SBQQ__Quote__r.BSL_AICH__r.EmployeeNumber != null 
                ? String.valueOf(quoteLine.SBQQ__Quote__r.BSL_AICH__r.EmployeeNumber) 
                : ''
            );
            String allIndiaHead = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.BSL_AIH__r != null && quoteLine.SBQQ__Quote__r.BSL_AIH__r.EmployeeNumber != null 
                ? String.valueOf(quoteLine.SBQQ__Quote__r.BSL_AIH__r.EmployeeNumber) 
                : ''
            );
            
            String allIndiaHeadName = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.BSL_AIH__r != null && quoteLine.SBQQ__Quote__r.BSL_AIH__r.Name != null 
                ? quoteLine.SBQQ__Quote__r.BSL_AIH__r.Name 
                : ''
            );
            String billToPartyMobileNo = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && 
                quoteLine.SBQQ__Quote__r.SBQQ__PrimaryContact__r != null && 
                quoteLine.SBQQ__Quote__r.SBQQ__PrimaryContact__r.Phone != null 
                ? quoteLine.SBQQ__Quote__r.SBQQ__PrimaryContact__r.Phone 
                : ''
            );
            
            // Billing Due Period
            String billingDuePeriod = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.Billing_Due_Period__c != null 
                ? quoteLine.SBQQ__Quote__r.Billing_Due_Period__c 
                : ''
            );
            
            // Billing Frequency Period
            String billingFrequencyPeriod = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.Billing_Frequency_Period__c != null 
                ? quoteLine.SBQQ__Quote__r.Billing_Frequency_Period__c 
                : ''
            );
            // Branch Name
            String branchName = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.Branch__r != null 
                ? quoteLine.SBQQ__Quote__r.Branch__r.Name 
                : ''
            );
            
            // Branch Number
            String branchNo = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.Branch__r != null 
                ? quoteLine.SBQQ__Quote__r.Branch__r.Branch_Code__c 
                : ''
            );
            
            
               // Determine Actual Capacity
            String actualCapacity = encloseWithQuotes(
                quoteLine.Asset__r != null && quoteLine.Asset__r.Actual_Capacity__c != null
                ? String.valueOf(quoteLine.Asset__r.Actual_Capacity__c) // Use Asset.Actual_Capacity__c if available
                : '' // Default to empty string if null
            );
            
            
            // Determine Capacity
            String capacity = encloseWithQuotes(
               quoteLine.Asset__r != null && quoteLine.Asset__r.Product2 != null && quoteLine.Asset__r.Product2.Capacity__c != null
                ? String.valueOf(quoteLine.Asset__r.Product2.Capacity__c) // Use Asset.Product2.Capacity__c if available
                : '' // Default to empty string if null
            );
            String comments = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.Comment__c != null 
                ? quoteLine.SBQQ__Quote__r.Comment__c 
                : '' // Default to an empty string if null
            );
            
            String contractCategory = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.Contract_Category__c != null 
                ? quoteLine.SBQQ__Quote__r.Contract_Category__c 
                : '' // Default to an empty string if null
            );
            
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
                        
                        // Get the short code from SBQQ__Quote__r and convert it
                        String contractType = encloseWithQuotes(
                            (quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.Contract_Type__c != null && contractTypeMap.containsKey(quoteLine.SBQQ__Quote__r.Contract_Type__c)) 
                            ? contractTypeMap.get(quoteLine.SBQQ__Quote__r.Contract_Type__c) 
                            : ''
                        );
            String contract_type_short_name = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.Contract_Type__c != null 
                ? quoteLine.SBQQ__Quote__r.Contract_Type__c 
                : ''
            );
            
            String createdBy = encloseWithQuotes(
                quoteLine.CreatedBy != null 
                ? quoteLine.CreatedBy.Name 
                : ''
            );
            
            String createdDate = encloseWithQuotes(
                quoteLine.CreatedDate != null 
                ? quoteLine.CreatedDate.format('yyyy-MM-dd HH:mm:ss') // Corrected to 24-hour format
                : ''
            );
            
            // Retrieve Customer Invoice Text
            String customerInvoiceText = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && 
                quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r != null && 
                quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.Customer_Invoice_Text__c != null 
                ? quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.Customer_Invoice_Text__c 
                : ''
            );
            
            // Retrieve Customer Name
            String customerName = encloseWithQuotes(
                quoteLine.Asset__r != null && 
                quoteLine.Asset__r.Account != null 
                ? quoteLine.Asset__r.Account.Name 
                : ''
            );
            // Retrieve Customer PO Date
            String customerPODate = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.PO_Date__c != null 
                ? DateTime.newInstance(quoteLine.SBQQ__Quote__r.PO_Date__c, Time.newInstance(0, 0, 0, 0)).format('dd-MMM-yyyy') 
                : ''
            );
            
            // Retrieve Customer PO Number
            String customerPONo = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.PO_Number__c != null 
                ? quoteLine.SBQQ__Quote__r.PO_Number__c 
                : ''
            );
            
            // Retrieve Customer PO Amount
            String customerPOAmount = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && 
                quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r != null && 
                quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.PO_Total_Value__c != null 
                ? String.valueOf(quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.PO_Total_Value__c) 
                : ''
            );
            
            // Retrieve Customer PO Value
            String customerPOValue = encloseWithQuotes('');
            
            String departmentName = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && 
                quoteLine.SBQQ__Quote__r.Department__r != null 
                ? quoteLine.SBQQ__Quote__r.Department__r.Name 
                : ''
            );
            
            String departmentNo = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && 
                quoteLine.SBQQ__Quote__r.Department__r != null 
                ? quoteLine.SBQQ__Quote__r.Department__r.Department_Number__c 
                : ''
            );
            String documentList = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && 
                quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r != null && 
                quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.Document_List__c != null 
                ? quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.Document_List__c 
                : ''
            );
            
            String documentsRequired = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && 
                quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r != null && 
                quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.Document_Required__c != null 
                ? String.valueOf(quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.Document_Required__c) 
                : ''
            );
            // Current Year Downloading Price
            String currentYearDownloadingPrice = encloseWithQuotes('');
            if (quoteLine.SBQQ__Quote__r != null) {
                currentYearDownloadingPrice = encloseWithQuotes(String.valueOf(
                    quoteLine.SBQQ__Quote__r.Revise_Total_Downloading_Value__c > 0 
                    ? quoteLine.SBQQ__Quote__r.Revise_Total_Downloading_Value__c 
                    : quoteLine.SBQQ__Quote__r.Total_Downloading_Value_RollUp__c
                ));
            }
            
            // Ensure values are initialized
            Decimal finalNetValue = null;
            Decimal downloadingPrice = null;
            Decimal marginPercent = null;
            
            // Extract final net contract value from the quote
            if (quoteLine.SBQQ__Quote__r != null) {
                finalNetValue = quoteLine.SBQQ__Quote__r.Final_Net_Contract_Value_Currency__c;
            }
            
            // Direct conversion of currentYearDownloadingPrice to Decimal
            if (!String.isEmpty(currentYearDownloadingPrice)) {
                try {
                    downloadingPrice = Decimal.valueOf(currentYearDownloadingPrice.replace('"', '')); // Remove quotes if any
                } catch (Exception e) {
                    // Handle parsing failure, log if necessary
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
            
            // Ensure the quote and necessary fields are not null
            if (quoteLine.SBQQ__Quote__r != null &&
                quoteLine.SBQQ__Quote__r.Total_Downloading_Value_RollUp__c != null &&
                quoteLine.SBQQ__Quote__r.Previous_Downloading_Value__c != null) {
                    
                    try {
                        // Retrieve the Decimal values directly or convert from String
                        Decimal totalDownloadingValue = quoteLine.SBQQ__Quote__r.Total_Downloading_Value_RollUp__c;
                        Decimal previousDownloadingValue = Decimal.valueOf(quoteLine.SBQQ__Quote__r.Previous_Downloading_Value__c);
                        
                        // Prevent division by zero
                        if (previousDownloadingValue != 0) {
                            // Calculate the margin percentage
                            Decimal lastYearMargin = 
                                ((totalDownloadingValue - previousDownloadingValue) / previousDownloadingValue) * 100;
                            
                            // Format to 2 decimal places and enclose in quotes
                            lastYearMarginDownloading = encloseWithQuotes(String.valueOf(lastYearMargin.setScale(2)));
                        } else {
                            // Fallback to blank if previous value is zero
                            lastYearMarginDownloading = encloseWithQuotes('');
                        }
                    } catch (Exception e) {
                        // Log and fallback for conversion errors
                       // System.debug('Error processing lastYearMarginDownloading: ' + e.getMessage());
                        lastYearMarginDownloading = encloseWithQuotes('');
                    }
                } else {
                    // Fallback to blank if required fields are missing
                    lastYearMarginDownloading = encloseWithQuotes('');
                }

            
            
            
            String thisYearStandardPriceBasic = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.Total_Price1__c != null 
                ? String.valueOf(quoteLine.SBQQ__Quote__r.Total_Price1__c) 
                : ''
            );
            String thisYearFinalPriceBasic = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.Grand_Total__c != null 
                ? String.valueOf(quoteLine.SBQQ__Quote__r.Grand_Total__c) 
                : ''
            );
            // Last Year Price Basic
            String lastYearPriceBasic = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.Last_Year_Price_for_Asset__c != null
                ? String.valueOf(quoteLine.SBQQ__Quote__r.Last_Year_Price_for_Asset__c)
                : ''
            );
            
            // Last Year Margin Price
            String lastYearMarginPrice = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.Hike_compared_to_last_year__c != null
                ? String.valueOf(quoteLine.SBQQ__Quote__r.Hike_compared_to_last_year__c)
                : ''
            );
            String lastYearDownloadingPrice = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.Previous_Downloading_Value__c != null
                ? String.valueOf(quoteLine.SBQQ__Quote__r.Previous_Downloading_Value__c)
                : ''
            );
            String componentProposalPrice = encloseWithQuotes(
                quoteLine.SBQQ__ListPrice__c != null ? String.valueOf(quoteLine.SBQQ__ListPrice__c) : ''
            );
            
            String quoteLineNumber = encloseWithQuotes(
                quoteLine.Name != null ? quoteLine.Name : ''
            );
            
            String previousPrice = encloseWithQuotes(
                quoteLine.Previous_Contract_Price__c != null ? String.valueOf(quoteLine.Previous_Contract_Price__c) : ''
            );
            
            String contractPrice = encloseWithQuotes(
                quoteLine.Total__c != null ? String.valueOf(quoteLine.Total__c) :
                quoteLine.Sell_Price__c != null ? String.valueOf(quoteLine.Sell_Price__c) : ''
            );
            
            String downloadingValue = encloseWithQuotes(
                quoteLine.Revised_Download_Value__c != null && quoteLine.Revised_Download_Value__c > 0
                ? String.valueOf(quoteLine.Revised_Download_Value__c)
                : (quoteLine.Standard_Downloading_Value__c != null 
                   ? String.valueOf(quoteLine.Standard_Downloading_Value__c)
                   : ''
                  )
            );
            
            
            String priceDeviation = null;  // Default value for price deviation
            
            Decimal listPrice = null;  // Unique variable name for list price
            Decimal adjustedListPrice = null;  // Unique variable name for adjusted list price
            Decimal sellPrice = null;  // Unique variable name for sell price
            Integer contractMonths = 12;  // Default contract period is 12 months
            
            if (quoteLine != null) {
                // Step 1: Determine the List Price
                if (quoteLine.SBQQ__ListPrice__c != null && quoteLine.SBQQ__ListPrice__c > 0) {
                    listPrice = quoteLine.SBQQ__ListPrice__c; // Priority 1: Use ListPrice
                }
                
                // Step 2: Calculate Contract Duration in Months using Proposed_Period_From__c and Proposed_Period_To__c
                if (quoteLine.SBQQ__Quote__r.Proposed_Period_From__c != null && quoteLine.SBQQ__Quote__r.Proposed_Period_To__c != null) {
                    Date contractStartDate = quoteLine.SBQQ__Quote__r.Proposed_Period_From__c; // Start date from Proposed_Period_From__c
                    Date contractEndDate = quoteLine.SBQQ__Quote__r.Proposed_Period_To__c;     // End date from Proposed_Period_To__c
                    
                    // Calculate the number of months between contractStartDate and contractEndDate
                    contractMonths = ((contractEndDate.year() - contractStartDate.year()) * 12) + (contractEndDate.month() - contractStartDate.month());
                    
                    // Add 1 if the contractEndDate's day is greater than or equal to contractStartDate's day
                    if (contractEndDate.day() >= contractStartDate.day()) {
                        contractMonths += 1;
                    }
                }
                
                // Step 3: Adjust List Price for Contract Duration
                if (listPrice != null) { // Ensure the list price is not null
                    if (contractMonths != 12) { // Only adjust if the duration is not exactly 12 months
                        adjustedListPrice = (listPrice / 12) * contractMonths; // Prorate list price
                    } else {
                        adjustedListPrice = listPrice; // Use the list price as-is for a 1-year contract
                    }
                }
                
                // Step 4: Get the Sell Price
                if (quoteLine.Sell_Price__c != null) {
                    sellPrice = quoteLine.Sell_Price__c;
                }
                
                // Step 5: Determine Price Deviation
                if (adjustedListPrice != null && sellPrice != null) {
                    priceDeviation = (adjustedListPrice != sellPrice) ? 'Y' : 'N';
                }
            }
            
            // Enclose the result in quotes if not null
            priceDeviation = encloseWithQuotes(priceDeviation);
            
            String priceChangePercent = encloseWithQuotes('');
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
                    // System.debug('Error calculating priceChangePercent: ' + e.getMessage());
                    priceChangePercent = encloseWithQuotes(''); // Handle any exceptions gracefully
                }
            } else {
                priceChangePercent = encloseWithQuotes(''); // Default to empty string if either value is null
            }
            
            String egmEstimatedGrossMargin = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.EGM_Formula__c != null 
                ? String.valueOf(quoteLine.SBQQ__Quote__r.EGM_Formula__c) // Use the Quote's EGM if available
                : '' // Default to an empty string if no value is available
            );
            
            String egmPercent = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.EGM_Percent_Formula__c != null 
                ? String.valueOf(quoteLine.SBQQ__Quote__r.EGM_Percent_Formula__c) // Use EGM if available
                : '' // Default to an empty string if no value is available or Quote is null
            );
            
            String emailId = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.SBQQ__PrimaryContact__r != null 
                ? (quoteLine.SBQQ__Quote__r.SBQQ__PrimaryContact__r.Email != null 
                   ? quoteLine.SBQQ__Quote__r.SBQQ__PrimaryContact__r.Email 
                   : ''
                  )
                : ''
            );
            
            String Quotenumberbackend = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.Quote_Number_Backend__c != null
                ? String.valueOf(quoteLine.SBQQ__Quote__r.Quote_Number_Backend__c)
                : ''
            );       
            String finalNetContractValue = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.Final_Net_Contract_Value_Currency__c != null
                ? String.valueOf(quoteLine.SBQQ__Quote__r.Final_Net_Contract_Value_Currency__c)
                : ''
            );
            // First Name
            String firstName = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.SBQQ__PrimaryContact__r != null && quoteLine.SBQQ__Quote__r.SBQQ__PrimaryContact__r.FirstName != null
                ? quoteLine.SBQQ__Quote__r.SBQQ__PrimaryContact__r.FirstName
                : ''
            );
            
            // Gross Contract Value
            String grossContractValue = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.Gross_Contract_Value_Currency__c != null
                ? String.valueOf(quoteLine.SBQQ__Quote__r.Gross_Contract_Value_Currency__c)
                : ''
            );
            
            // Kerala Cess
            String keralaCess = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.Kerela_Cess__c != null
                ? String.valueOf(quoteLine.SBQQ__Quote__r.Kerela_Cess__c)
                : ''
            );
            
            // Last Name
            String lastName = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.SBQQ__PrimaryContact__r != null && quoteLine.SBQQ__Quote__r.SBQQ__PrimaryContact__r.LastName != null
                ? quoteLine.SBQQ__Quote__r.SBQQ__PrimaryContact__r.LastName
                : ''
            );
            
            // Discount Percent
            String discountPercent = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.Discount__c != null
                ? String.valueOf(quoteLine.SBQQ__Quote__r.Discount__c)
                : ''
            ); 
            String mobile = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.SBQQ__Account__r != null && quoteLine.SBQQ__Quote__r.SBQQ__Account__r.Phone != null
                ? quoteLine.SBQQ__Quote__r.SBQQ__Account__r.Phone
                : ''
            );
            String netContractValue = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.Net_Contract_Value_Currency__c != null
                ? String.valueOf(quoteLine.SBQQ__Quote__r.Net_Contract_Value_Currency__c)
                : '' // Default to an empty string if null
            );
            
            String overallPriceChange = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.Overall_Price_Change__c != null
                ? String.valueOf(quoteLine.SBQQ__Quote__r.Overall_Price_Change__c)
                : '' // Default to an empty string if null
            );
            String poReceiptDate = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && 
                quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r != null && 
                quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.PO_Receipt_Date__c != null 
                ? DateTime.newInstance(
                    quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.PO_Receipt_Date__c, 
                    Time.newInstance(0, 0, 0, 0)
                ).format('dd-MMM-yyyy') 
                : ''
            );
            String parentCustomerId = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && 
                quoteLine.SBQQ__Quote__r.SBQQ__Account__r != null && 
                quoteLine.SBQQ__Quote__r.SBQQ__Account__r.Parent != null && 
                quoteLine.SBQQ__Quote__r.SBQQ__Account__r.Parent.SAP_Customer_Id__c != null 
                ? quoteLine.SBQQ__Quote__r.SBQQ__Account__r.Parent.SAP_Customer_Id__c 
                : ''
            );
            String parentSAPCustomerId=encloseWithQuotes(quoteLine.SBQQ__Quote__r != null && 
                quoteLine.SBQQ__Quote__r.SBQQ__Account__r != null && 
                quoteLine.SBQQ__Quote__r.SBQQ__Account__r.Parent != null && 
                quoteLine.SBQQ__Quote__r.SBQQ__Account__r.Parent.SAP_Customer_Id__c != null 
                ? quoteLine.SBQQ__Quote__r.SBQQ__Account__r.Parent.SAP_Customer_Id__c 
                : '');
            String parentSFCustomerId=encloseWithQuotes(quoteLine.SBQQ__Quote__r != null && 
                quoteLine.SBQQ__Quote__r.SBQQ__Account__r != null && 
                quoteLine.SBQQ__Quote__r.SBQQ__Account__r.Parent != null && 
                quoteLine.SBQQ__Quote__r.SBQQ__Account__r.Parent.Customer_ID__c != null 
                ? quoteLine.SBQQ__Quote__r.SBQQ__Account__r.Parent.Customer_ID__c 
                : '');
            String parentStarCustomerId=encloseWithQuotes(quoteLine.SBQQ__Quote__r != null && 
                quoteLine.SBQQ__Quote__r.SBQQ__Account__r != null && 
                quoteLine.SBQQ__Quote__r.SBQQ__Account__r.Parent != null && 
                quoteLine.SBQQ__Quote__r.SBQQ__Account__r.Parent.Customer_Code__c != null 
                ? quoteLine.SBQQ__Quote__r.SBQQ__Account__r.Parent.Customer_Code__c 
                : '');
            String paymentCreditDays = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && 
                quoteLine.SBQQ__Quote__r.Payment_Credit_Days__c != null 
                ? String.valueOf(quoteLine.SBQQ__Quote__r.Payment_Credit_Days__c) 
                : ''
            );
            String productName = encloseWithQuotes(
                quoteLine.SBQQ__Product__r != null && quoteLine.SBQQ__Product__r.Name != null 
                ? quoteLine.SBQQ__Product__r.Name 
                : ''
            );
            String productChannelPartnerName = encloseWithQuotes(
                quoteLine.Asset__r != null && quoteLine.Asset__r.CP__r != null && quoteLine.Asset__r.CP__r.Name != null ? quoteLine.Asset__r.CP__r.Name :
                quoteLine.Asset__r != null && quoteLine.Asset__r.Branch__r != null && quoteLine.Asset__r.Branch__r.Name != null ? quoteLine.Asset__r.Branch__r.Name :
                ''
            );
            String productChannelPartnerNumber = encloseWithQuotes(
                quoteLine.Asset__r != null && quoteLine.Asset__r.CP__r != null && quoteLine.Asset__r.CP__r.CP_Code__c != null ? quoteLine.Asset__r.CP__r.CP_Code__c :
                quoteLine.Asset__r != null && quoteLine.Asset__r.Branch__r != null && quoteLine.Asset__r.Branch__r.Branch_Code__c != null ? quoteLine.Asset__r.Branch__r.Branch_Code__c :
                ''
            );
            String productCustomerName = encloseWithQuotes(
                quoteLine.Asset__r != null && quoteLine.Asset__r.Account != null && quoteLine.Asset__r.Account.Name != null 
                ? quoteLine.Asset__r.Account.Name 
                : ''
            );
            String proposalPrice = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.Proposed_Contract_Value_Formula__c != null 
                ? String.valueOf(quoteLine.SBQQ__Quote__r.Proposed_Contract_Value_Formula__c) 
                : ''
            );
            String regionalManager = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.BSL_RM__r != null && quoteLine.SBQQ__Quote__r.BSL_RM__r.EmployeeNumber != null 
                ? String.valueOf(quoteLine.SBQQ__Quote__r.BSL_RM__r.EmployeeNumber) 
                : ''
            );
            
            String regionalManagerName = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.BSL_RM__r != null && quoteLine.SBQQ__Quote__r.BSL_RM__r.Name != null 
                ? quoteLine.SBQQ__Quote__r.BSL_RM__r.Name 
                : ''
            );
            
            String sac = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.HSN_SAC_code__c != null 
                ? quoteLine.SBQQ__Quote__r.HSN_SAC_code__c 
                : ''
            );
            
            String sme = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.BSL_SME__r != null && quoteLine.SBQQ__Quote__r.BSL_SME__r.EmployeeNumber != null 
                ? String.valueOf(quoteLine.SBQQ__Quote__r.BSL_SME__r.EmployeeNumber) 
                : ''
            );
            
            String smeName = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.BSL_SME__r != null && quoteLine.SBQQ__Quote__r.BSL_SME__r.Name != null 
                ? quoteLine.SBQQ__Quote__r.BSL_SME__r.Name 
                : ''
            );
            
            String smh = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.BSL_SMH__r != null && quoteLine.SBQQ__Quote__r.BSL_SMH__r.EmployeeNumber != null 
                ? String.valueOf(quoteLine.SBQQ__Quote__r.BSL_SMH__r.EmployeeNumber) 
                : ''
            );
            
            String smhName = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.BSL_SMH__r != null && quoteLine.SBQQ__Quote__r.BSL_SMH__r.Name != null 
                ? quoteLine.SBQQ__Quote__r.BSL_SMH__r.Name 
                : ''
            );
            String state = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.SBQQ__Account__r != null && quoteLine.SBQQ__Quote__r.SBQQ__Account__r.BillingState != null 
                ? quoteLine.SBQQ__Quote__r.SBQQ__Account__r.BillingState 
                : ''
            );
            String status = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.SBQQ__Status__c != null
                ? quoteLine.SBQQ__Quote__r.SBQQ__Status__c
                : ''
            );
            
            String totalAdjustedDownloadingValue = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null 
                ? (
                    quoteLine.SBQQ__Quote__r.Revise_Total_Downloading_Value__c != null && quoteLine.SBQQ__Quote__r.Revise_Total_Downloading_Value__c > 0 
                    ? String.valueOf(quoteLine.SBQQ__Quote__r.Revise_Total_Downloading_Value__c) 
                    : (quoteLine.SBQQ__Quote__r.Total_Downloading_Value_RollUp__c != null 
                       ? String.valueOf(quoteLine.SBQQ__Quote__r.Total_Downloading_Value_RollUp__c) 
                       : ''
                      )
                )
                : ''
            );
            String paymentAmount = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null 
                ? (
                    quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r != null && quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.Amount != null 
                    ? String.valueOf(quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.Amount) 
                    : (
                        quoteLine.SBQQ__Quote__r.SBQQ__NetAmount__c != null 
                        ? String.valueOf(quoteLine.SBQQ__Quote__r.SBQQ__NetAmount__c) 
                        : ''
                    )
                )
                : ''
            );
            
            
            String totalDownloadingValue = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.Total_Downloading_Value_RollUp__c != null 
                ? String.valueOf(quoteLine.SBQQ__Quote__r.Total_Downloading_Value_RollUp__c) 
                : ''
            );
            String uom = encloseWithQuotes(
                quoteLine.SBQQ__Product__r != null && quoteLine.SBQQ__Product__r.Capacity_UOM__c != null 
                ? quoteLine.SBQQ__Product__r.Capacity_UOM__c 
                : ''
            );
            String updatedBy = encloseWithQuotes(
                quoteLine.LastModifiedBy != null 
                ? quoteLine.LastModifiedBy.Name 
                : ''
            );
            
            String updatedDate = encloseWithQuotes(
                quoteLine.LastModifiedDate != null 
                ? quoteLine.LastModifiedDate.format('yyyy-MM-dd hh:mm:ss') 
                : ''
            );
            String warehouseName = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && 
                quoteLine.SBQQ__Quote__r.Plant__r != null 
                ? quoteLine.SBQQ__Quote__r.Plant__r.Name 
                : ''
            );
            String paymentDate = encloseWithQuotes('');
            String warehouseNo = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && 
                quoteLine.SBQQ__Quote__r.Plant__r != null 
                ? quoteLine.SBQQ__Quote__r.Plant__r.Warehouse_Code__c 
                : ''
            );
            // Retrieve Quote Number from SBQQ__Quote__r
            String quoteno = encloseWithQuotes(
                quoteLine.SBQQ__Quote__r != null && quoteLine.SBQQ__Quote__r.Name != null 
                ? quoteLine.SBQQ__Quote__r.Name 
                : ''
            );
            
            // Format Quote Number (if necessary)
            String quoteNoFormatted = '';
            if (!quoteno.startsWith('Q') && !String.isBlank(quoteno)) {
                quoteNoFormatted = '\'' + quoteno;
            } else {
                quoteNoFormatted = quoteno; // Use quoteno as it is
            }
            
            // Format Quote Line Number (if necessary)
            String quoteLineNoFormatted = '';
            if (!quoteLineNumber.startsWith('Q') && !String.isBlank(quoteLineNumber)) {
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
                    mobile, netContractValue,newEndDate, overallPriceChange,poReceiptDate,
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
                'Parent Customer ID','Parent SAP Customer ID','Parent Salesforce Customer ID','Parent Starserve Customer ID','Payment Amount', 'Payment Credit Days', 'Payment Date', 'Plan Registration No.',
                'Plan Registration Status', 'Policy Name', 'Previous Outstanding If Any', 'Previous Price', 'Price Change %',
                'Price Deviation', 'Product Name', 'Product\'s Channel Partner Name', 'Product\'s Channel Partner Number', 'Product\'s Customer Name', 'Product\'s Customer No.','Product\'s SAP Customer No.','Product\'s Salseforce Customer No.','Product\'s Starserve Customer No.',
                'Proposal Price', 'Reason for Deviation(Downloading)', 'Reason for Deviation(Price)', 'Reason for Deviation(TOP)',
                'Regional Manager', 'Regional Manager Name', 'Reject', 'SAC', 'Sales Organization Name', 'Sales Organization No.',
                'SME', 'SME Name', 'SMH', 'SMH Name', 'State', 'Status', 'Sub Type', 'Terms of Payment Deviation',
                'This Year Final Price (Basic)', 'This Year Margin %', 'This Year Standard Price (Basic)', 'Total Adjusted Downloading Value',
                'Total Downloading Value', 'UOM', 'Updated By', 'Updated Date', 'Warehouse Name', 'Warehouse No.', 'Water Management', 'Ship to party' ,'Ship to party SAP Customer ID' ,'Ship to party Salesforce Customer ID' ,'Ship to party Starserve Customer ID', 'Account ID'
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
        
        fileName = 'FNAME_CPQQuote_FROM_' + formattedStartDate + '_TO_' + formattedEndDate + '_EXTTS_' + formattedDateTime + '.csv';
        Blob csvBlob = Blob.valueOf(concatenatedStr);
        
        if (!dailyJobDocumetList.isEmpty()) {
            Attachment attachmentObj = new Attachment(
                Body = csvBlob,
                Name = fileName,
                ParentId = dailyJobDocumetList[0].Id
            );
            insert attachmentObj;
           // System.debug('Attachment created with ID: ' + attachmentObj.Id + ' and ParentId: ' + attachmentObj.ParentId);
        } else {
            //System.debug('No Daily Job Document found to attach the CSV.');
        }
        if (!String.isBlank(file) && !isTestContext) {
            
            System.enqueueJob(new S3FileUploadQueueable(dailyJobDocumetList[0].Id, fileName, file, folderName));
        }
    }
    
    
    public void finish(Database.BatchableContext BC) {
        
    }
}