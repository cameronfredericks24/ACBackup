public class Changed_sales_batch implements Database.Batchable<sObject>, Database.AllowsCallouts  {
    
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
    
    public Changed_sales_batch(Boolean overrideQuery, String query2,Date customStartDate, Date customEndDate, String folderName) {
    query = 'SELECT ' +
        'Id, ListPrice, Previous_Contract_Price__c, Sell_Price__c, Revised_Download_Value__c, ' +
        'Standard_Downloading_Value__c, Asset__c, ' +
        'Quote.Account.Id, Quote.Account.Name,Quote.QuoteNumber,Quote.Proposed_Period_From__c,Quote.Status,Quote.Proposed_Period_To__c, Quote.Account.Group__c, Quote.Account.BillingStreet, Quote.Account.BillingCity, ' +
        'Quote.Account.BillingState,Asset__r.Account.SAP_Customer_Id__c,Asset__r.Product2.Capacity__c, Quote.Account.BillingPostalCode, Quote.Account.BillingCountry, ' +
        'Quote.Account.BillingCountryCode, Quote.Account.BillingStateCode,Asset__r.CP__r.CP_Code__c,Asset__r.Product2.Product_Sub_Family__r.Name, ' +
        'Quote.Opportunity.Name, Quote.Opportunity.Branch_Commericial__r.EmployeeNumber,Quote.Ship_to_Party__r.SAP_Customer_Id__c,Quote.Account.Parent.SAP_Customer_Id__c,Asset__r.Product2.Product_Sub_Family__r.Code__c, Quote.Opportunity.Branch_Commericial__r.Name, ' +
        'Quote.Contact.Email, Quote.Contact.Department_lookup__r.Department_Number__c,Quote.Account.SAP_Customer_Id__c,Asset__r.Product2.Product_Family__r.Name,Quote.Account.Parent.Customer_ID__c, Quote.Contact.Phone, ' +
        'Quote.Contact.FirstName, Quote.Contact.LastName,Asset__r.Branch__r.Name, ' +
        'Quote.Account.Industry,Quote.GrandTotal, Quote.Account.Sub_Segment__c, Asset__r.CP__r.Type, Quote.Ship_to_Party__r.Customer_Code__c,Quote.Ship_to_Party__r.Customer_ID__c, ' +
        'Quote.Opportunity.SDE__r.EmployeeNumber, Quote.Opportunity.SDE__r.Name, ' +
        'Asset__r.Account.Customer_ID__c, Asset__r.Account.Customer_Code__c, Asset__r.Account.Name, ' +
        'Quote.Service_Contract__r.ContractNumber, Quote.Service_Contract__r.SAP_Contract_Number__c, ' +
        'Quote.BSL_AM__r.EmployeeNumber, Quote.BSL_AM__r.Name, Asset__r.SerialNumber, Asset__r.Product_Family__r.Code__c, Quote.Account.Customer_Code__c, ' +
        'Quote.BSL_AICH__r.Name, Quote.BSL_AICH__r.EmployeeNumber,Quote.Service_Contract__r.External_Id__c, ' +
        'Quote.BSL_AIH__r.Name, Quote.BSL_AIH__r.EmployeeNumber, ' +
        'Quote.CGST__c, Quote.IGST__c, Quote.SGST__c, Quote.UGST__c, ' +
        'Quote.Kerala_Cess__c, Quote.Terms_of_Payment_Customer__c, Asset__r.Product_Family__r.Name, ' +
        'Quote.Billing_Due_Period__c, Quote.Billing_Frequency_Period__c,Asset__r.Product2.Product_Family__r.Code__c, ' +
        'Quote.Branch__r.Name, Quote.Branch__r.Branch_Code__c, ' +
        'Quote.Branch__r.Warehouse__r.Name, Quote.Branch__r.Warehouse__r.Warehouse_Code__c, ' +
        'Quote.Name, Quote.Proposed_Contract_Value_Formula__c, Asset__r.Component_Id__c, ' +
        'Quote.BSL_RM__r.EmployeeNumber, Quote.BSL_RM__r.Name,Quote.Plant__r.Warehouse_Code__c, ' +
        'Quote.BSL_SME__r.EmployeeNumber, Quote.BSL_SME__r.Name, ' +
        'Quote.BSL_SMH__r.EmployeeNumber, Quote.BSL_SMH__r.Name,Quote.Plant__r.Name, ' +
        'Quote.HSN_SAC_code__c, ' +
        'Quote.Total_Price__c,Quote.TotalPrice,TotalPrice, Quote.Grand_Total__c,Asset__r.Branch__r.Branch_Code__c, ' +
        'Quote.Last_Year_Price_for_Asset__c, Asset__r.Age_Of_Machine__c, Quote.Hike_compared_to_last_year__c, ' +
        'Quote.Previous_Downloading_Value__c, Quote.EGM_Formula__c, Quote.EGM_Percent_Formula__c, ' +
        'Quote.Number_of_Events__c, Quote.Quote_Number_Backend__c, Quote.Final_Net_Contract_Value_Curr__c, ' +
        'Quote.Gross_Contract_Value_Currency__c, Quote.Kerala_Cess_Currency__c,Quote.Account.Customer_ID__c, ' +
        'Quote.Discount__c, Quote.Net_Contract_Value_Currency__c, ' +
        'Quote.Overall_Price_Change_Formula__c, Quote.Opportunity.PO_Receipt_Date__c, ' +
        'Quote.Account.Phone, Quote.Account.Parent.Customer_Code__c, ' +
        'Quote.Revise_Total_Downloading_Value__c, Quote.Total_Download_Value_Rollup__c, ' +
        'Product2.Name, Product2.Capacity_UOM__c, Asset__r.Product_Model__c, ' +
        'Asset__r.Product_Sub_Family__r.Code__c, Asset__r.Product_Sub_Family__r.Name, ' +
        'Quote.CP__r.Type, Quote.CP__r.CP_Code__c, Quote.CP__r.Name, ' +
        'Asset__r.Capacity__c, Asset__r.Actual_Capacity__c, ' +
        'Quote.Comment__c, Quote.Contract_Catgory__c, Quote.Contract_Type__c, ' +
        'CreatedBy.Name, CreatedDate, ' +
        'Quote.Opportunity.Customer_Invoice_Text__c, Quote.PO_Date__c, Quote.PO_Number__c, ' +
        'Quote.Opportunity.PO_Total_Value__c, Quote.Department__r.Name, Quote.Department__r.Department_Number__c, ' +
        'Quote.Opportunity.Document_List__c, Quote.Opportunity.Document_Required__c, LineNumber, ' +
        'Quote.Payment_Credit_Days__c, Quote.Opportunity.Amount, Asset__r.CP__r.Name, ' +
        'LastModifiedBy.Name, LastModifiedDate ' +
        'FROM QuoteLineItem ' +
        'WHERE Quote.Opportunity.StageName!=\'Closed - Won\' and Quote.Service_Contract__c =null and LastModifiedDate=Yesterday';



        if (overrideQuery) {
            query = query2;
        }
        this.customStartDate = customStartDate;  // Store the custom start date
        this.customEndDate = customEndDate; 
        this.folderName = folderName;
    }
    public Changed_sales_batch(Boolean overrideQuery, String query2, String folderName) {
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
    
    
    public void execute(Database.BatchableContext BC, List<QuoteLineItem> scope) {
        
        
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
        // Step 1: Initialize a map to store PMS_Schedule__c records by Opportunity__c and a map for event counts
        Map<Id, Boolean> pmsScheduleMap = new Map<Id, Boolean>();
        Map<Id, Integer> pmsEventCountMap = new Map<Id, Integer>();  // To store event counts for each Opportunity
        
        // Collect all related Opportunity IDs from QuoteLineItem
        Set<Id> opportunityIds = new Set<Id>();
        for (QuoteLineItem quoteLine : scope) {
            if (quoteLine.Quote != null && quoteLine.Quote.OpportunityId != null) {
                opportunityIds.add(quoteLine.Quote.OpportunityId);
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
        
        Set<Id> assetIds = new Set<Id>();
        for (QuoteLineItem quoteLine : scope) {
            if (quoteLine.Asset__c != null) {
                assetIds.add(quoteLine.Asset__c);
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
        
        
        for (QuoteLineItem quoteLine : scope) {
            String accountID = '';
            
            if (quoteLine.Quote != null && quoteLine.Quote.Account != null) {
                String accountIdRaw = quoteLine.Quote.Account.Id;
                
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
                quoteLine.Quote.Opportunity != null ? quoteLine.Quote.Opportunity.Name : ''
            );
            
            // Service Contract Information
            String amc = encloseWithQuotes(
                quoteLine.Quote.Service_Contract__r != null ? quoteLine.Quote.Service_Contract__r.External_Id__c : ''
            );
            String sfdcamcid = encloseWithQuotes(
                quoteLine.Quote.Service_Contract__r != null ? quoteLine.Quote.Service_Contract__r.ContractNumber : ''
            );
            String erpContractNo = encloseWithQuotes(
                quoteLine.Quote.Service_Contract__r != null ? quoteLine.Quote.Service_Contract__r.SAP_Contract_Number__c : ''
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
            
            if (quoteLine.Quote != null && quoteLine.Quote.BSL_AM__r != null) {
                // Area Head Employee Number
                if (quoteLine.Quote.BSL_AM__r.EmployeeNumber != null) {
                    areaHead = encloseWithQuotes(String.valueOf(quoteLine.Quote.BSL_AM__r.EmployeeNumber));
                } else {
                    areaHead = encloseWithQuotes('');
                }
                
                // Area Head Name
                if (quoteLine.Quote.BSL_AM__r.Name != null) {
                    areaHeadName = encloseWithQuotes(quoteLine.Quote.BSL_AM__r.Name);
                } else {
                    areaHeadName = encloseWithQuotes('');
                }
            } else {
                // Fallback for null Area Head or Quote
                areaHead = encloseWithQuotes('');
                areaHeadName = encloseWithQuotes('');
            }
            String billToPartyCustomerGroup = '';
            
            if (quoteLine.Quote != null && quoteLine.Quote.Account != null) {
                if ('NAMO'.equals(quoteLine.Quote.Account.Group__c)) {
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
            
            if (quoteLine.Quote != null && quoteLine.Quote.Account != null) {
                billToPartyFirstName = encloseWithQuotes(quoteLine.Quote.Account.Name != null
                                                         ? quoteLine.Quote.Account.Name
                                                         : ''
                                                        );
            } else {
                // Null scenario
                billToPartyFirstName = encloseWithQuotes('');
            }
            
            String billToPartyLastName = encloseWithQuotes('');
            String billToPartyEmail = '';
            
            if (quoteLine.Quote != null && quoteLine.Quote.Contact != null) {
                billToPartyEmail = encloseWithQuotes(
                    quoteLine.Quote.Contact.Email != null 
                    ? quoteLine.Quote.Contact.Email 
                    : ''
                );
            } else {
                // Null scenario
                billToPartyEmail = encloseWithQuotes('');
            }
            String bms = encloseWithQuotes('');
            String commercialExecutive = '';
            
            if (quoteLine.Quote != null && quoteLine.Quote.Opportunity != null &&
                quoteLine.Quote.Opportunity.Branch_Commericial__r != null) {
                    commercialExecutive = encloseWithQuotes(
                        quoteLine.Quote.Opportunity.Branch_Commericial__r.EmployeeNumber != null
                        ? quoteLine.Quote.Opportunity.Branch_Commericial__r.EmployeeNumber
                        : ''
                    );
                } else {
                    // Null scenario
                    commercialExecutive = encloseWithQuotes('');
                }
            
            String commercialExecutiveName = '';
            
            if (quoteLine.Quote != null && quoteLine.Quote.Opportunity != null &&
                quoteLine.Quote.Opportunity.Branch_Commericial__r != null) {
                    commercialExecutiveName = encloseWithQuotes(
                        quoteLine.Quote.Opportunity.Branch_Commericial__r.Name != null
                        ? quoteLine.Quote.Opportunity.Branch_Commericial__r.Name
                        : ''
                    );
                } else {
                    // Null scenario
                    commercialExecutiveName = encloseWithQuotes('');
                }
            
            String contactDepartment = '';
            
            if (quoteLine.Quote != null && 
                quoteLine.Quote.Contact != null && 
                quoteLine.Quote.Contact.Department_lookup__r != null) {
                    contactDepartment = encloseWithQuotes(
                        quoteLine.Quote.Contact.Department_lookup__r.Department_Number__c != null
                        ? quoteLine.Quote.Contact.Department_lookup__r.Department_Number__c
                        : ''
                    );
                } else {
                    // Null scenario
                    contactDepartment = encloseWithQuotes('');
                }
            
            String customerSector = '';
            
            if (quoteLine.Quote != null && quoteLine.Quote.Account != null) {
                customerSector = encloseWithQuotes(
                    quoteLine.Quote.Account.Industry != null 
                    ? quoteLine.Quote.Account.Industry 
                    : ''
                );
            } else {
                // Null scenario
                customerSector = encloseWithQuotes('');
            }
            
            String customerSubSegment = '';
            
            if (quoteLine.Quote != null && quoteLine.Quote.Account != null) {
                customerSubSegment = encloseWithQuotes(
                    quoteLine.Quote.Account.Sub_Segment__c != null 
                    ? quoteLine.Quote.Account.Sub_Segment__c 
                    : ''
                );
            } else {
                // Null scenario
                customerSubSegment = encloseWithQuotes('');
            }
            String deliveryExecutive = '';
            
            if (quoteLine.Quote != null && 
                quoteLine.Quote.Opportunity != null && 
                quoteLine.Quote.Opportunity.SDE__r != null) {
                    deliveryExecutive = encloseWithQuotes(
                        quoteLine.Quote.Opportunity.SDE__r.EmployeeNumber != null
                        ? quoteLine.Quote.Opportunity.SDE__r.EmployeeNumber
                        : ''
                    );
                } else {
                    // Null scenario
                    deliveryExecutive = encloseWithQuotes('');
                }
            
            String deliveryExecutiveName = '';
            
            if (quoteLine.Quote != null && 
                quoteLine.Quote.Opportunity != null && 
                quoteLine.Quote.Opportunity.SDE__r != null) {
                    deliveryExecutiveName = encloseWithQuotes(
                        quoteLine.Quote.Opportunity.SDE__r.Name != null
                        ? quoteLine.Quote.Opportunity.SDE__r.Name
                        : ''
                    );
                } else {
                    // Null scenario
                    deliveryExecutiveName = encloseWithQuotes('');
                }
            
            String downloadingDeviation = encloseWithQuotes('');
            String dutyUsage = encloseWithQuotes('');
            String gstRate = '';
            
            // GST Rate Calculation
            Decimal cgst = null, igst = null, sgst = null, ugst = null;
            
            // Retrieve GST values from Quote
            if (quoteLine.Quote != null) {
                cgst = quoteLine.Quote.CGST__c;
                igst = quoteLine.Quote.IGST__c;
                sgst = quoteLine.Quote.SGST__c;
                ugst = quoteLine.Quote.UGST__c;
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
            
            // Individual GST Values
            String cgstValue = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.CGST__c != null
                ? String.valueOf(quoteLine.Quote.CGST__c)
                : ''
            );
            
            String sgstValue = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.SGST__c != null
                ? String.valueOf(quoteLine.Quote.SGST__c)
                : ''
            );
            
            String ugstValue = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.UGST__c != null
                ? String.valueOf(quoteLine.Quote.UGST__c)
                : ''
            );
            
            String igstValue = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.IGST__c != null
                ? String.valueOf(quoteLine.Quote.IGST__c)
                : ''
            );
            String isCustomEvents = encloseWithQuotes(''); // Default value
            String events = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.Number_of_Events__c != null
                ? String.valueOf(quoteLine.Quote.Number_of_Events__c)
                : ''
            );
            
            // Check if the Quote and Opportunity exist
            if (quoteLine.Quote != null && quoteLine.Quote.OpportunityId != null) {
                Id oppId = quoteLine.Quote.OpportunityId;
                
                // Check if the Opportunity has related PMS schedules
                if (pmsScheduleMap.containsKey(oppId) && pmsScheduleMap.get(oppId)) {
                    isCustomEvents = encloseWithQuotes('Y'); // Yes, related PMS schedules exist
                    
                    // If PMS schedules exist, set the events to the number of PMS events
                    Integer eventCount = pmsEventCountMap.get(oppId);
                    events = encloseWithQuotes(String.valueOf(eventCount)); // Use the count of PMS events
                } else {
                    isCustomEvents = encloseWithQuotes('N'); // No related PMS schedules
                    
                    // Fallback to Number_of_Events__c from quoteLine.Quote if PMS schedules do not exist
                    if (quoteLine.Quote.Number_of_Events__c != null) {
                        events = encloseWithQuotes(String.valueOf(quoteLine.Quote.Number_of_Events__c));
                    } else {
                        events = encloseWithQuotes(''); // Default to empty string if no event data
                    }
                }
            }
            
            String keralaCessPercent = '';
            if (quoteLine.Quote != null) {
                // Check for Kerala Cess Percent at the Quote level
                if (quoteLine.Quote.Kerala_Cess__c != null) {
                    keralaCessPercent = encloseWithQuotes(String.valueOf(quoteLine.Quote.Kerala_Cess__c));
                } else {
                    // Default to empty string if value is null
                    keralaCessPercent = encloseWithQuotes('');
                }
            } else {
                // Fallback if Quote is null
                keralaCessPercent = encloseWithQuotes('');
            }
            
            String lastYearPaymentReceived = encloseWithQuotes('');
            
            String lastYearTOP = '';
            if (quoteLine.Quote != null) {
                if (quoteLine.Quote.Terms_of_Payment_Customer__c != null) {
                    lastYearTOP = encloseWithQuotes(quoteLine.Quote.Terms_of_Payment_Customer__c);
                } else {
                    lastYearTOP = encloseWithQuotes(''); // Default to empty string if null
                }
            } else {
                lastYearTOP = encloseWithQuotes(''); // Fallback for null Quote
            }
            String newEndDate=encloseWithQuotes('');
            String planRegistrationNo = encloseWithQuotes('');
            String planRegistrationStatus = encloseWithQuotes('');
            
            
            String policyName = encloseWithQuotes(''); // Default value
            
            if (quoteLine.Asset__c != null && assetWarrantyMap.containsKey(quoteLine.Asset__c)) {
                policyName = encloseWithQuotes(assetWarrantyMap.get(quoteLine.Asset__c));
            }
            // Initialize variables
            String previousOutstandingIfAny = encloseWithQuotes('');
            
            String productCustomerNo =  encloseWithQuotes(quoteLine.Asset__r != null && quoteLine.Asset__r.Account.SAP_Customer_Id__c != null ? quoteLine.Asset__r.Account.SAP_Customer_Id__c  : '');
            String productSapCustomerNo=  encloseWithQuotes(quoteLine.Asset__r != null && quoteLine.Asset__r.Account.SAP_Customer_Id__c != null ? quoteLine.Asset__r.Account.SAP_Customer_Id__c : '');
            String productSFCustomerNo=  encloseWithQuotes(quoteLine.Asset__r != null && quoteLine.Asset__r.Account.Customer_ID__c != null ? quoteLine.Asset__r.Account.Customer_ID__c : '');
            String productStarCustomerNo=  encloseWithQuotes(quoteLine.Asset__r != null && quoteLine.Asset__r.Account.Customer_Code__c != null ? quoteLine.Asset__r.Account.Customer_Code__c : '');
            // Other fields (default values or placeholders)
            String reasonForDeviationDownloading = encloseWithQuotes(''); // Placeholder for future logic
            String reasonForDeviationPrice = encloseWithQuotes(''); // Placeholder for future logic
            String reasonForDeviationTOP = encloseWithQuotes(''); // Placeholder for future logic
            String reject = encloseWithQuotes('');
            String distance = encloseWithQuotes('');
            String salesOrganizationName = encloseWithQuotes('BSL'); // Static value
            String salesOrganizationNo = encloseWithQuotes('1000'); // Static value
            
            
            // SubType
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
            
            // Terms of Payment Deviation
            String termsOfPaymentDeviation = encloseWithQuotes('');
            
            // This Year Margin Percent
            String thisYearMarginPercent = encloseWithQuotes(
                quoteLine.Quote != null 
                ? (quoteLine.Quote.Hike_compared_to_last_year__c != null 
                   ? String.valueOf(quoteLine.Quote.Hike_compared_to_last_year__c) 
                   : null // Fallback if `Hike_compared_to_last_year__c` is null
                  )
                : null // Fallback if `Quote` is null
            );
            
            // Water Management and Factor Amount
            String waterManagement = encloseWithQuotes('');
            String factorAmount = encloseWithQuotes('0');
            
            
            String billToParty = encloseWithQuotes(quoteLine.Quote != null && quoteLine.Quote.Account.SAP_Customer_Id__c != null ? quoteLine.Quote.Account.SAP_Customer_Id__c : '');
            String billToPartySap=encloseWithQuotes(quoteLine.Quote != null && quoteLine.Quote.Account.SAP_Customer_Id__c != null ? quoteLine.Quote.Account.SAP_Customer_Id__c : '');
            string billtopartySF=encloseWithQuotes(quoteLine.Quote != null && quoteLine.Quote.Account.Customer_ID__c != null ? quoteLine.Quote.Account.Customer_ID__c : '');
            String billtopartyStar=encloseWithQuotes(quoteLine.Quote != null && quoteLine.Quote.Account.Customer_Code__c != null ? quoteLine.Quote.Account.Customer_Code__c : '');
            String Shiptoparty = encloseWithQuotes(
                quoteLine.Quote != null 
                ? (quoteLine.Quote.Ship_to_Party__r != null && quoteLine.Quote.Ship_to_Party__r.SAP_Customer_Id__c != null 
                   ? quoteLine.Quote.Ship_to_Party__r.SAP_Customer_Id__c 
                   : (quoteLine.Quote.Account != null && quoteLine.Quote.Account.SAP_Customer_Id__c != null 
                      ? quoteLine.Quote.Account.SAP_Customer_Id__c 
                      : ''
                     )
                  )
                : ''
            );
            String ShiptopartySap=encloseWithQuotes(quoteLine.Quote != null && quoteLine.Quote.Ship_to_Party__r.SAP_Customer_Id__c != null ? quoteLine.Quote.Ship_to_Party__r.SAP_Customer_Id__c : '');
            String ShiptopartySF=encloseWithQuotes(quoteLine.Quote != null && quoteLine.Quote.Ship_to_Party__r.Customer_ID__c != null ? quoteLine.Quote.Ship_to_Party__r.Customer_ID__c : '');
            String ShiptopartyStar=encloseWithQuotes(quoteLine.Quote != null && quoteLine.Quote.Ship_to_Party__r.Customer_Code__c != null ? quoteLine.Quote.Ship_to_Party__r.Customer_Code__c : '');
            
            // Contract Period
            String contractPeriodFrom = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.Proposed_Period_From__c != null
                ? DateTime.newInstance(quoteLine.Quote.Proposed_Period_From__c, Time.newInstance(0, 0, 0, 0)).format('dd-MMM-yyyy')
                : '' // Default to empty string if null
            );
            
            String contractPeriodTo = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.Proposed_Period_To__c != null
                ? DateTime.newInstance(quoteLine.Quote.Proposed_Period_To__c, Time.newInstance(0, 0, 0, 0)).format('dd-MMM-yyyy')
                : '' // Default to empty string if null
            );
            
            
            // Component Number
            String componentNo = encloseWithQuotes(
                quoteLine.Asset__r != null && quoteLine.Asset__r.Component_Id__c != null
                ? quoteLine.Asset__r.Component_Id__c
                : ''
            );
            
            // Model
            String model = encloseWithQuotes(
                quoteLine.Asset__r != null && quoteLine.Asset__r.Product_Model__c != null 
                ? quoteLine.Asset__r.Product_Model__c 
                : ''
            );
            
            // Product Serial Number
            String productSerialNo = encloseWithQuotes(
                quoteLine.Asset__r != null && quoteLine.Asset__r.SerialNumber != null 
                ? quoteLine.Asset__r.SerialNumber 
                : ''
            );
            
            // Product Family
            String productFamily = encloseWithQuotes(
                quoteLine.Asset__r != null 
                ? (quoteLine.Asset__r.Product_Family__r != null && quoteLine.Asset__r.Product_Family__r.Code__c != null 
                   ? quoteLine.Asset__r.Product_Family__r.Code__c // First Choice: Asset's Product Family Code
                   : (quoteLine.Asset__r.Product2 != null && quoteLine.Asset__r.Product2.Product_Family__r != null && quoteLine.Asset__r.Product2.Product_Family__r.Code__c != null 
                      ? quoteLine.Asset__r.Product2.Product_Family__r.Code__c // Second Choice: Asset's Product2 Family Code
                      : '')) // Fallback: Empty string if none available
                : ''
            );
            
            // Product Family Name
            String productFamilyName = encloseWithQuotes(
                quoteLine.Asset__r != null 
                ? (quoteLine.Asset__r.Product_Family__r != null && quoteLine.Asset__r.Product_Family__r.Name != null 
                   ? quoteLine.Asset__r.Product_Family__r.Name // First Choice: Asset's Product Family Name
                   : (quoteLine.Asset__r.Product2 != null && quoteLine.Asset__r.Product2.Product_Family__r != null && quoteLine.Asset__r.Product2.Product_Family__r.Name != null 
                      ? quoteLine.Asset__r.Product2.Product_Family__r.Name // Second Choice: Asset's Product2 Family Name
                      : '')) // Fallback: Empty string if none available
                : ''
            );
            
            // Product Sub Family Code
            String productSubFamily = encloseWithQuotes(
                quoteLine.Asset__r != null 
                ? (quoteLine.Asset__r.Product_Sub_Family__r != null && quoteLine.Asset__r.Product_Sub_Family__r.Code__c != null 
                   ? quoteLine.Asset__r.Product_Sub_Family__r.Code__c // First Choice: Asset's Product Sub Family Code
                   : (quoteLine.Asset__r.Product2 != null && quoteLine.Asset__r.Product2.Product_Sub_Family__r != null && quoteLine.Asset__r.Product2.Product_Sub_Family__r.Code__c != null 
                      ? quoteLine.Asset__r.Product2.Product_Sub_Family__r.Code__c // Second Choice: Asset's Product2 Sub Family Code
                      : '')) // Fallback: Empty string if none available
                : ''
            );
            
            // Product Sub Family Name
            String productSubFamilyName = encloseWithQuotes(
                quoteLine.Asset__r != null 
                ? (quoteLine.Asset__r.Product_Sub_Family__r != null && quoteLine.Asset__r.Product_Sub_Family__r.Name != null 
                   ? quoteLine.Asset__r.Product_Sub_Family__r.Name // First Choice: Asset's Product Sub Family Name
                   : (quoteLine.Asset__r.Product2 != null && quoteLine.Asset__r.Product2.Product_Sub_Family__r != null && quoteLine.Asset__r.Product2.Product_Sub_Family__r.Name != null 
                      ? quoteLine.Asset__r.Product2.Product_Sub_Family__r.Name // Second Choice: Asset's Product2 Sub Family Name
                      : '')) // Fallback: Empty string if none available
                : ''
            );
            
            // Determine Channel Partner Type
            String channelPartnerType = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.CP__r != null && quoteLine.Quote.CP__r.Type != null
                ? quoteLine.Quote.CP__r.Type // Take from Quote.CP__r if available
                : (quoteLine.Quote != null && quoteLine.Quote.Branch__r != null
                   ? 'Branch' // Use "Branch" if Quote.Branch__r exists
                   : null) // Default to null if both CP__r and Branch__r are unavailable
            );
            
            // Determine Channel Partner Number
            String channelPartnerNo = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.CP__r != null && quoteLine.Quote.CP__r.CP_Code__c != null
                ? quoteLine.Quote.CP__r.CP_Code__c // Take from Quote.CP__r if available
                : (quoteLine.Quote != null && quoteLine.Quote.Branch__r != null && quoteLine.Quote.Branch__r.Branch_Code__c != null
                   ? quoteLine.Quote.Branch__r.Branch_Code__c // Fallback to Branch__r if CP__r is not available
                   : null) // Default to null if both CP__r and Branch__r are unavailable
            );
            
            // Determine Channel Partner Name
            String channelPartnerName = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.CP__r != null && quoteLine.Quote.CP__r.Name != null
                ? quoteLine.Quote.CP__r.Name // Take from Quote.CP__r if available
                : (quoteLine.Quote != null && quoteLine.Quote.Branch__r != null && quoteLine.Quote.Branch__r.Name != null
                   ? quoteLine.Quote.Branch__r.Name // Fallback to Branch__r if CP__r is not available
                   : null) // Default to null if both CP__r and Branch__r are unavailable
            );
            
            
            // Activated Date (Default as blank)
            String activatedDate = encloseWithQuotes('');
            
            // Address Line 1
            String addressLine1 = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.Account != null
                ? (quoteLine.Quote.Account.BillingStreet != null ? quoteLine.Quote.Account.BillingStreet : '') + ' ' +
                (quoteLine.Quote.Account.BillingCity != null ? quoteLine.Quote.Account.BillingCity : '') + ' ' +
                (quoteLine.Quote.Account.BillingState != null ? quoteLine.Quote.Account.BillingState : '') + ' ' +
                (quoteLine.Quote.Account.BillingPostalCode != null ? quoteLine.Quote.Account.BillingPostalCode : '') + ' ' +
                (quoteLine.Quote.Account.BillingCountry != null ? quoteLine.Quote.Account.BillingCountry : '') + ' ' +
                (quoteLine.Quote.Account.BillingCountryCode != null ? quoteLine.Quote.Account.BillingCountryCode : '') + ' ' +
                (quoteLine.Quote.Account.BillingStateCode != null ? quoteLine.Quote.Account.BillingStateCode : '')
                : ''
            );
            
            // Address Line 2 (Default as blank)
            String addressLine2 = encloseWithQuotes('');
            
            // AICH Details
            String aichName = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.BSL_AICH__r != null && quoteLine.Quote.BSL_AICH__r.Name != null 
                ? quoteLine.Quote.BSL_AICH__r.Name 
                : ''
            );
            
            String allIndiaCommercialHead = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.BSL_AICH__r != null && quoteLine.Quote.BSL_AICH__r.EmployeeNumber != null 
                ? String.valueOf(quoteLine.Quote.BSL_AICH__r.EmployeeNumber) 
                : ''
            );
            
            // AIH Details
            String allIndiaHead = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.BSL_AIH__r != null && quoteLine.Quote.BSL_AIH__r.EmployeeNumber != null 
                ? String.valueOf(quoteLine.Quote.BSL_AIH__r.EmployeeNumber) 
                : ''
            );
            
            String allIndiaHeadName = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.BSL_AIH__r != null && quoteLine.Quote.BSL_AIH__r.Name != null 
                ? quoteLine.Quote.BSL_AIH__r.Name 
                : ''
            );
            
            // Bill to Party Mobile Number
            String billToPartyMobileNo = encloseWithQuotes(
                quoteLine.Quote != null && 
                quoteLine.Quote.Contact != null && 
                quoteLine.Quote.Contact.Phone != null 
                ? quoteLine.Quote.Contact.Phone 
                : ''
            );
            
            // Billing Due Period
            String billingDuePeriod = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.Billing_Due_Period__c != null 
                ? quoteLine.Quote.Billing_Due_Period__c 
                : ''
            );
            
            // Billing Frequency Period
            String billingFrequencyPeriod = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.Billing_Frequency_Period__c != null 
                ? quoteLine.Quote.Billing_Frequency_Period__c 
                : ''
            );
            
            // Branch Details
            String branchName = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.Branch__r != null 
                ? quoteLine.Quote.Branch__r.Name 
                : ''
            );
            
            String branchNo = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.Branch__r != null 
                ? quoteLine.Quote.Branch__r.Branch_Code__c 
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
            
            // Comments
            String comments = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.Comment__c != null 
                ? quoteLine.Quote.Comment__c 
                : '' // Default to an empty string if null
            );
            
            // Contract Category
            String contractCategory = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.Contract_Catgory__c != null 
                ? quoteLine.Quote.Contract_Catgory__c 
                : '' // Default to an empty string if null
            );
            // Map for Contract Types
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
                    'IEW' => 'Inverter Extended Warranty Contract' // Added missing entry for Inverter Extended Warranty Contract
                    };
                        
                        // Get the short code from Quote and convert it
                        String contractType = encloseWithQuotes(
                            (quoteLine.Quote != null && quoteLine.Quote.Contract_Type__c != null && contractTypeMap.containsKey(quoteLine.Quote.Contract_Type__c)) 
                            ? contractTypeMap.get(quoteLine.Quote.Contract_Type__c) 
                            : ''
                        );
            
            String contract_type_short_name = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.Contract_Type__c != null 
                ? quoteLine.Quote.Contract_Type__c 
                : ''
            );
            
            // Created By Information
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
                quoteLine.Quote != null && 
                quoteLine.Quote.Opportunity != null && 
                quoteLine.Quote.Opportunity.Customer_Invoice_Text__c != null 
                ? quoteLine.Quote.Opportunity.Customer_Invoice_Text__c 
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
                quoteLine.Quote != null && quoteLine.Quote.PO_Date__c != null 
                ? DateTime.newInstance(quoteLine.Quote.PO_Date__c, Time.newInstance(0, 0, 0, 0)).format('dd-MMM-yyyy') 
                : ''
            );
            
            // Retrieve Customer PO Number
            String customerPONo = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.PO_Number__c != null 
                ? quoteLine.Quote.PO_Number__c 
                : ''
            );
            
            // Retrieve Customer PO Amount
            String customerPOAmount = encloseWithQuotes(
                quoteLine.Quote != null && 
                quoteLine.Quote.Opportunity != null && 
                quoteLine.Quote.Opportunity.PO_Total_Value__c != null 
                ? String.valueOf(quoteLine.Quote.Opportunity.PO_Total_Value__c) 
                : ''
            );
            
            // Retrieve Customer PO Value
            String customerPOValue = encloseWithQuotes('');
            
            // Retrieve Department Name
            String departmentName = encloseWithQuotes(
                quoteLine.Quote != null && 
                quoteLine.Quote.Department__r != null 
                ? quoteLine.Quote.Department__r.Name 
                : ''
            );
            
            // Retrieve Department Number
            String departmentNo = encloseWithQuotes(
                quoteLine.Quote != null && 
                quoteLine.Quote.Department__r != null 
                ? quoteLine.Quote.Department__r.Department_Number__c 
                : ''
            );
            
            // Retrieve Document List
            String documentList = encloseWithQuotes(
                quoteLine.Quote != null && 
                quoteLine.Quote.Opportunity != null && 
                quoteLine.Quote.Opportunity.Document_List__c != null 
                ? quoteLine.Quote.Opportunity.Document_List__c 
                : ''
            );
            
            // Retrieve Documents Required
            String documentsRequired = encloseWithQuotes(
                quoteLine.Quote != null && 
                quoteLine.Quote.Opportunity != null && 
                quoteLine.Quote.Opportunity.Document_Required__c != null 
                ? String.valueOf(quoteLine.Quote.Opportunity.Document_Required__c) 
                : ''
            );
            
            // Current Year Downloading Price
            String currentYearDownloadingPrice = encloseWithQuotes('');
            if (quoteLine.Quote != null) {
                currentYearDownloadingPrice = encloseWithQuotes(String.valueOf(
                    quoteLine.Quote.Revise_Total_Downloading_Value__c > 0 
                    ? quoteLine.Quote.Revise_Total_Downloading_Value__c 
                    : quoteLine.Quote.Total_Download_Value_Rollup__c
                ));
            }
            
            // Ensure values are initialized
            Decimal finalNetValue = null;
            Decimal downloadingPrice = null;
            Decimal marginPercent = null;
            
            // Extract final net contract value from the Quote
            if (quoteLine.Quote != null) {
                finalNetValue = quoteLine.Quote.Final_Net_Contract_Value_Curr__c;
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
            
            // Calculate Last Year Margin Downloading
            String lastYearMarginDownloading = encloseWithQuotes('');
            
            // Ensure the Quote and necessary fields are not null
            if (quoteLine.Quote != null &&
                quoteLine.Quote.Total_Download_Value_Rollup__c != null &&
                quoteLine.Quote.Previous_Downloading_Value__c != null) {
                    
                    try {
                        // Retrieve the Decimal values directly or convert from String
                        Decimal totalDownloadingValue = quoteLine.Quote.Total_Download_Value_Rollup__c;
                        Decimal previousDownloadingValue = Decimal.valueOf(quoteLine.Quote.Previous_Downloading_Value__c);
                        
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
                quoteLine.Quote != null && quoteLine.Quote.TotalPrice != null 
                ? String.valueOf(quoteLine.Quote.TotalPrice) 
                : (quoteLine.Quote.Total_Price__c != null ? String.valueOf(quoteLine.Quote.Total_Price__c) : '')
            );
            String thisYearFinalPriceBasic = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.GrandTotal != null 
                ? String.valueOf(quoteLine.Quote.GrandTotal) 
                : (quoteLine.Quote.Grand_Total__c != null ? String.valueOf(quoteLine.Quote.Grand_Total__c) : '')
            );

            
            // Last Year Price Basic
            String lastYearPriceBasic = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.Last_Year_Price_for_Asset__c != null
                ? String.valueOf(quoteLine.Quote.Last_Year_Price_for_Asset__c)
                : ''
            );
            
            // Last Year Margin Price
            String lastYearMarginPrice = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.Hike_compared_to_last_year__c != null
                ? String.valueOf(quoteLine.Quote.Hike_compared_to_last_year__c)
                : ''
            );
            
            String lastYearDownloadingPrice = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.Previous_Downloading_Value__c != null
                ? String.valueOf(quoteLine.Quote.Previous_Downloading_Value__c)
                : ''
            );
            
            String componentProposalPrice = encloseWithQuotes(
                quoteLine.ListPrice != null ? String.valueOf(quoteLine.ListPrice) : ''
            );
            
            String quoteLineNumber = encloseWithQuotes(
                quoteLine.LineNumber != null ? quoteLine.LineNumber : ''
            );
            
            String previousPrice = encloseWithQuotes(
                quoteLine.Previous_Contract_Price__c != null ? String.valueOf(quoteLine.Previous_Contract_Price__c) : ''
            );
            
            String contractPrice = encloseWithQuotes(
                quoteLine.TotalPrice != null ? String.valueOf(quoteLine.TotalPrice) : ''
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
                if (quoteLine.ListPrice != null && quoteLine.ListPrice > 0) {
                    listPrice = quoteLine.ListPrice; // Priority 1: Use ListPrice
                }
                
                // Step 2: Calculate Contract Duration in Months using Proposed_Period_From__c and Proposed_Period_To__c
                if (quoteLine.Quote.Proposed_Period_From__c != null && quoteLine.Quote.Proposed_Period_To__c != null) {
                    Date contractStartDate = quoteLine.Quote.Proposed_Period_From__c; // Start date from Proposed_Period_From__c
                    Date contractEndDate = quoteLine.Quote.Proposed_Period_To__c;     // End date from Proposed_Period_To__c
                    
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
                    // Handle any exceptions gracefully
                    priceChangePercent = encloseWithQuotes('');
                }
            } else {
                priceChangePercent = encloseWithQuotes(''); // Default to empty string if either value is null
            }
            
            String egmEstimatedGrossMargin = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.EGM_Formula__c != null 
                ? String.valueOf(quoteLine.Quote.EGM_Formula__c)
                : ''
            );
            
            String egmPercent = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.EGM_Percent_Formula__c != null 
                ? String.valueOf(quoteLine.Quote.EGM_Percent_Formula__c)
                : ''
            );
            
            String emailId = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.Contact != null && quoteLine.Quote.Contact.Email != null
                ? quoteLine.Quote.Contact.Email
                : ''
            );
            
            
            
            String Quotenumberbackend = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.Quote_Number_Backend__c != null
                ? String.valueOf(quoteLine.Quote.Quote_Number_Backend__c)
                : ''
            );
            
            String finalNetContractValue = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.Final_Net_Contract_Value_Curr__c != null
                ? String.valueOf(quoteLine.Quote.Final_Net_Contract_Value_Curr__c)
                : ''
            );
            
            String firstName = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.Contact != null && quoteLine.Quote.Contact.FirstName != null
                ? quoteLine.Quote.Contact.FirstName
                : ''
            );
            
            String grossContractValue = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.Gross_Contract_Value_Currency__c != null
                ? String.valueOf(quoteLine.Quote.Gross_Contract_Value_Currency__c)
                : ''
            );
            
            String keralaCess = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.Kerala_Cess_Currency__c != null
                ? String.valueOf(quoteLine.Quote.Kerala_Cess_Currency__c)
                : ''
            );
            
            String lastName = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.Contact != null && quoteLine.Quote.Contact.LastName != null
                ? quoteLine.Quote.Contact.LastName
                : ''
            );
            
            String discountPercent = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.Discount__c != null
                ? String.valueOf(quoteLine.Quote.Discount__c)
                : ''
            );
            
            String mobile = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.Account != null && quoteLine.Quote.Account.Phone != null
                ? quoteLine.Quote.Account.Phone
                : ''
            );
            
            String netContractValue = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.Net_Contract_Value_Currency__c != null
                ? String.valueOf(quoteLine.Quote.Net_Contract_Value_Currency__c)
                : ''
            );
            
            String overallPriceChange = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.Overall_Price_Change_Formula__c != null
                ? String.valueOf(quoteLine.Quote.Overall_Price_Change_Formula__c)
                : ''
            );
            
            String poReceiptDate = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.Opportunity != null && quoteLine.Quote.Opportunity.PO_Receipt_Date__c != null
                ? DateTime.newInstance(
                    quoteLine.Quote.Opportunity.PO_Receipt_Date__c, 
                    Time.newInstance(0, 0, 0, 0)
                ).format('dd-MMM-yyyy')
                : ''
            );
            
            
            String parentCustomerId = encloseWithQuotes(quoteLine.Quote != null &&  quoteLine.Quote.Account.Parent.SAP_Customer_Id__c != null ?  quoteLine.Quote.Account.Parent.SAP_Customer_Id__c : '');
            String parentSAPCustomerId=encloseWithQuotes( quoteLine.Quote != null &&  quoteLine.Quote.Account.Parent.SAP_Customer_Id__c != null ?  quoteLine.Quote.Account.Parent.SAP_Customer_Id__c : '');
            String parentSFCustomerId=encloseWithQuotes( quoteLine.Quote != null &&  quoteLine.Quote.Account.Parent.Customer_ID__c != null ?  quoteLine.Quote.Account.Parent.Customer_ID__c : '');
            String parentStarCustomerId=encloseWithQuotes( quoteLine.Quote != null &&  quoteLine.Quote.Account.Parent.Customer_Code__c != null ?  quoteLine.Quote.Account.Parent.Customer_Code__c : '');
            String paymentCreditDays = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.Payment_Credit_Days__c != null
                ? String.valueOf(quoteLine.Quote.Payment_Credit_Days__c)
                : ''
            );
            
            String productName = encloseWithQuotes(
                quoteLine.Product2 != null && quoteLine.Product2.Name != null
                ? quoteLine.Product2.Name
                : ''
            );
            
            String uom = encloseWithQuotes(
                quoteLine.Product2 != null && quoteLine.Product2.Capacity_UOM__c != null
                ? quoteLine.Product2.Capacity_UOM__c
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
                quoteLine.Quote != null && quoteLine.Quote.Plant__r != null && quoteLine.Quote.Plant__r.Name != null
                ? quoteLine.Quote.Plant__r.Name
                : ''
            );
            
            String warehouseNo = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.Plant__r != null && quoteLine.Quote.Plant__r.Warehouse_Code__c != null
                ? quoteLine.Quote.Plant__r.Warehouse_Code__c
                : ''
            );
            
            String quoteno = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.QuoteNumber != null
                ? quoteLine.Quote.QuoteNumber
                : ''
            );
            
            String paymentAmount = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.Opportunity != null && quoteLine.Quote.Opportunity.Amount != null 
                ? String.valueOf(quoteLine.Quote.Opportunity.Amount) 
                : ''
            );
            String paymentDate = encloseWithQuotes('');
            // Determine Product's Channel Partner Name with fallback logic
            String productChannelPartnerName = encloseWithQuotes(
                quoteLine.Asset__r != null && quoteLine.Asset__r.CP__r != null && quoteLine.Asset__r.CP__r.Name != null
                ? quoteLine.Asset__r.CP__r.Name // Take from Asset__r.CP__r if available
                : (quoteLine.Asset__r != null && quoteLine.Asset__r.Branch__r != null && quoteLine.Asset__r.Branch__r.Name != null
                   ? quoteLine.Asset__r.Branch__r.Name // Fallback to Asset__r.Branch__r.Name
                   : '') // Default to an empty string if both are null
            );
            // Determine Product's Channel Partner Number with fallback logic
            String productChannelPartnerNumber = encloseWithQuotes(
                quoteLine.Asset__r != null && quoteLine.Asset__r.CP__r != null && quoteLine.Asset__r.CP__r.CP_Code__c != null
                ? quoteLine.Asset__r.CP__r.CP_Code__c // Take from Asset__r.CP__r if available
                : (quoteLine.Asset__r != null && quoteLine.Asset__r.Branch__r != null && quoteLine.Asset__r.Branch__r.Branch_Code__c != null
                   ? quoteLine.Asset__r.Branch__r.Branch_Code__c // Fallback to Asset__r.Branch__r.Branch_Code__c
                   : '') // Default to an empty string if both are null
            );
            
            String productCustomerName = encloseWithQuotes(
                quoteLine.Asset__r != null && quoteLine.Asset__r.Account != null && quoteLine.Asset__r.Account.Name != null 
                ? quoteLine.Asset__r.Account.Name 
                : ''
            );
            String proposalPrice = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.Proposed_Contract_Value_Formula__c != null 
                ? String.valueOf(quoteLine.Quote.Proposed_Contract_Value_Formula__c) 
                : ''
            );
            String regionalManager = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.BSL_RM__r != null && quoteLine.Quote.BSL_RM__r.EmployeeNumber != null 
                ? String.valueOf(quoteLine.Quote.BSL_RM__r.EmployeeNumber) 
                : ''
            );
            
            String regionalManagerName = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.BSL_RM__r != null && quoteLine.Quote.BSL_RM__r.Name != null 
                ? quoteLine.Quote.BSL_RM__r.Name 
                : ''
            );
            
            String sac = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.HSN_SAC_code__c != null 
                ? quoteLine.Quote.HSN_SAC_code__c 
                : ''
            );
            
            String sme = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.BSL_SME__r != null && quoteLine.Quote.BSL_SME__r.EmployeeNumber != null 
                ? String.valueOf(quoteLine.Quote.BSL_SME__r.EmployeeNumber) 
                : ''
            );
            
            String smeName = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.BSL_SME__r != null && quoteLine.Quote.BSL_SME__r.Name != null 
                ? quoteLine.Quote.BSL_SME__r.Name 
                : ''
            );
            
            String smh = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.BSL_SMH__r != null && quoteLine.Quote.BSL_SMH__r.EmployeeNumber != null 
                ? String.valueOf(quoteLine.Quote.BSL_SMH__r.EmployeeNumber) 
                : ''
            );
            
            String smhName = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.BSL_SMH__r != null && quoteLine.Quote.BSL_SMH__r.Name != null 
                ? quoteLine.Quote.BSL_SMH__r.Name 
                : ''
            );
            
            String state = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.Account != null && quoteLine.Quote.Account.BillingState != null 
                ? quoteLine.Quote.Account.BillingState 
                : ''
            );
            
            String status = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.Status != null
                ? quoteLine.Quote.Status
                : '' // Default to empty string if null
            );

            String totalAdjustedDownloadingValue = encloseWithQuotes(
                quoteLine.Quote != null 
                ? (
                    quoteLine.Quote.Revise_Total_Downloading_Value__c != null && quoteLine.Quote.Revise_Total_Downloading_Value__c > 0 
                    ? String.valueOf(quoteLine.Quote.Revise_Total_Downloading_Value__c) 
                    : (quoteLine.Quote.Total_Download_Value_Rollup__c != null 
                       ? String.valueOf(quoteLine.Quote.Total_Download_Value_Rollup__c) 
                       : ''
                      )
                )
                : ''
            );
            String totalDownloadingValue = encloseWithQuotes(
                quoteLine.Quote != null && quoteLine.Quote.Total_Download_Value_Rollup__c != null 
                ? String.valueOf(quoteLine.Quote.Total_Download_Value_Rollup__c) 
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
        
        fileName = 'FNAME_SalesQuote_FROM_' + formattedStartDate + '_TO_' + formattedEndDate + '_EXTTS_' + formattedDateTime + '.csv';
        Blob csvBlob = Blob.valueOf(concatenatedStr);
        
        if (!dailyJobDocumetList.isEmpty()) {
            Attachment attachmentObj = new Attachment(
                Body = csvBlob,
                Name = fileName,
                ParentId = dailyJobDocumetList[0].Id
            );
            insert attachmentObj;
            //System.debug('Attachment created with ID: ' + attachmentObj.Id + ' and ParentId: ' + attachmentObj.ParentId);
        } else {
            //System.debug('No Daily Job Document found to attach the CSV.');
        }
         if (!String.isBlank(file) && !isTestContext)  {
            
            System.enqueueJob(new S3FileUploadQueueable(dailyJobDocumetList[0].Id, fileName, file, folderName));
        }
    }
    
    
    public void finish(Database.BatchableContext BC) {
       
    }
}