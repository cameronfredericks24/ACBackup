@isTest
public class Changed_cpq_batchTest {
    @isTest(seeAllData=true)
    static void testBatchExecutionWithOrgData() {
         String query = 'SELECT Id, ' +
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
        'SBQQ__Quote__r.SBQQ__Opportunity2__r.Document_List__c,Total__c, ' +
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
        'SBQQ__ListPrice__c, SBQQ__NetTotal__c, Sell_Price__c, SBQQ__NetPrice__c, SBQQ__Discount__c, ' +
        'Revised_Download_Value__c, Standard_Downloading_Value__c,SBQQ__Quote__r.Discount__c, Asset__r.Age_Of_Machine__c,Asset__r.Product2.Product_Sub_Family__r.Name,SBQQ__Quote__r.PO_Date__c, ' +
        'Asset__r.Account.Customer_Code__c,LastModifiedBy.Name, Asset__r.Account.Customer_ID__c, Asset__r.Component_Id__c, ' +
        'Asset__r.Product_Model__c, Asset__r.SerialNumber, Asset__r.Product_Family__r.Code__c,Asset__r.Product2.Capacity__c, ' +
        'Asset__r.Product_Family__r.Name, Asset__r.Product_Sub_Family__r.Code__c,Asset__r.Product2.Product_Sub_Family__r.Code__c, Asset__r.Product_Sub_Family__r.Name, ' +
        'SBQQ__Product__r.Name, SBQQ__Product__r.Capacity_UOM__c,SBQQ__Quote__r.CP__r.Type, Asset__r.CP__r.Name, Asset__r.CP__r.Type ' +
        'FROM SBQQ__QuoteLine__c limit 200';

        List<SBQQ__QuoteLine__c> cliRecords = Database.query(query);
        //System.assert(!cliRecords.isEmpty(), 'No valid SBQQ__QuoteLine__c records found.');

        
        String folderName='landing';
        Date customStartDate = null; // March 20, 2025
        Date customEndDate = null;
        Changed_cpq_batch batch = new Changed_cpq_batch(false,'',customStartDate,customEndDate,folderName);
        batch.isTestContext = true; 

        // Step 3: Simulate batch execution
        Test.startTest();
        Integer batchSize = 200; // Simulating batch size
        Integer totalRecords = cliRecords.size();
        Database.BatchableContext context = new MockBatchableContext();
        for (Integer i = 0; i < totalRecords; i += batchSize) {
            // Extract a sublist representing one batch scope
            List<SBQQ__QuoteLine__c> scope = new List<SBQQ__QuoteLine__c>();
            for (Integer j = i; j < Math.min(i + batchSize, totalRecords); j++) {
                scope.add(cliRecords[j]);
            }
            batch.execute(context, scope);
        }
        Test.stopTest();

        // Step 4: Assert results after the batch is simulated
        List<Daily_Job_Documents__c> docs = [SELECT Id, Name FROM Daily_Job_Documents__c WHERE CreatedDate = TODAY];
        //System.assertEquals(1, docs.size(), 'Daily Job Document should have been created.');

        List<Attachment> attachments = [SELECT Id, Name FROM Attachment WHERE ParentId = :docs[0].Id];
        //System.assert(attachments.size() > 0, 'At least one attachment should have been created.');

    }

    // Mock Batchable Context for Simulated Execution
    public class MockBatchableContext implements Database.BatchableContext {
        public String getJobId() {
            return '707xx0000FakeJobId'; // Fake Job ID for testing purposes
        }
        
        public Id getChildJobId() {
            return null; // Mock implementation, return null as no child jobs exist in this context
        }
    }
}