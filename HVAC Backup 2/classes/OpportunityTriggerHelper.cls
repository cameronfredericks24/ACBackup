public class OpportunityTriggerHelper {
    // Static variable to prevent recursion
    private static Boolean isAfterUpdateTriggerExecuted = false;

    public  void prepopulateFields(list<Opportunity> oppList){
        set<Id> accountIds = New set<Id>();
        set<Id> branchIds = New set<Id>();
        set<Id> departmentIds = New set<Id>();
        set<string> contractType = New set<string>();
        set<string> deptNumber = New set<string>();
        map<string, string> deptIdToDeptNumber = New map<string, string>();
        map<string, string> deptIdToDeptName = New map<string, string>();
        map<string, Id> keyToPricebook = New map<string, Id>();
        Set<Id> shipToAccountIds = New Set<Id>();
        
        for(Opportunity opp : oppList){
            accountIds.add(opp.AccountId);
            if(opp.Ship_to_Party__c != null){
                shipToAccountIds.add(opp.Ship_to_Party__c);
            }
            branchIds.add(opp.Branch__c);
            departmentIds.add(opp.Department__c);
            contractType.add(opp.Contract_Type__c);
        }  
        
        for(Department__c dept : [SELECT ID, department_number__c,Name FROM Department__c WHERE Id IN : departmentIds]){
            deptNumber.add(dept.department_number__c);
            deptIdToDeptNumber.put(dept.Id, dept.Department_Number__c); 
            deptIdToDeptName.put(dept.Id, dept.Name);
        }
        
        for(Pricebook2 pb : [SELECT ID, Contract_Type__c,Department__c  FROM Pricebook2 WHERE Contract_Type__c IN : contractType And IsActive = true]){
            string key = pb.Contract_Type__c/* + pb.Department__c*/;
            keyToPricebook.put(key, pb.Id); 
        }
        
        
        list<Branch_Division__c> branchDepartments = [SELECT Id,AIH__c,Branch__r.Id, Department__r.Id,AICH__c,
                                                      Branch_Commercial__c,AIDH__c,Department__r.Division__c,
                                                      Service_AM__c,Service_RM__c,AISDH__c,Regional_Commercial_Head__c,SMH__c,SME__c,Central_Commercial_Manager__c,Service_SDE__c, (SELECT Id,Warehouse__r.Id FROM Associated_Warehouses__r) FROM Branch_Division__c WHERE Branch__c IN : branchIds AND Department__c IN :departmentIds ];
        
        map<string,Branch_Division__c> keyToBranchDepartment = New map<string,Branch_Division__c>();
        
        for(Branch_Division__c bd : branchDepartments){
            string key = bd.Branch__r.Id + '-'+ bd.Department__r.Id;
            keyToBranchDepartment.put(key, bd); 
        } 
        String CBOId = System.label.BSL_CBO;
        map<Id,Account> accountIdToAccount = New map<Id, Account>([SELECT ID,Shipping_House_Flat_BlockNo__c,Billing_House_Flat_BlockNo__c, Industry,Sub_Segment__c,Group__c,kam__c, BillingStreet, BillingStateCode, BillingState, BillingPostalCode, BillingCountryCode, BillingCountry, BillingCity, ShippingStreet,ShippingStateCode, ShippingState, ShippingPostalCode, ShippingCountryCode, ShippingCountry, ShippingCity FROM Account WHERE ID IN : accountIds]);
        Map<Id,Account> shipToAccountIdToAccount = New map<Id, Account>();
        if(shipToAccountIds.size() > 0){
       		shipToAccountIdToAccount = new map<Id, Account>([SELECT ID,Shipping_House_Flat_BlockNo__c,Billing_House_Flat_BlockNo__c, Industry,Sub_Segment__c,Group__c,kam__c, BillingStreet, BillingStateCode, BillingState, BillingPostalCode, BillingCountryCode, BillingCountry, BillingCity, ShippingStreet,ShippingStateCode, ShippingState, ShippingPostalCode, ShippingCountryCode, ShippingCountry, ShippingCity FROM Account WHERE ID IN : shipToAccountIds]);
       
        }
        String departmentNumber='';
        for(Opportunity opp : oppList){
            system.debug('Opp list '+opp);
            if(opp.AccountId != null && (accountIdToAccount.containsKey(opp.AccountId))){
                departmentNumber =deptIdToDeptName.get(opp.Department__c);
                system.debug('Department Name '+departmentNumber);
                if((departmentNumber != null || departmentNumber !='') && departmentNumber.contains('51') || departmentNumber.contains('50') || departmentNumber.contains('56')){
                    opp.NAMO_Head__c = System.label.X50_51_56_NAMO_Head;
                }
                else if((departmentNumber != null || departmentNumber !='') && departmentNumber.contains('52') || departmentNumber.contains('43')){
                    opp.NAMO_Head__c = System.label.X43_52_NAMO_Head;
                }
                else if((departmentNumber != null || departmentNumber !='') && departmentNumber.contains('53') || departmentNumber.contains('58')){
                    opp.NAMO_Head__c = System.label.X53_58_NAMO_Head;
                }
                else{
                    opp.NAMO_Head__c = null;
                }
                opp.Draft_NAMO_Head__c = System.label.Draft_NAMO_Head;
                opp.Name = 'OPP-'+Date.Today().year()+Integer.valueof(Math.random() * 100)+Date.Today().month()+Integer.valueof(Math.random() * 100)+Date.Today().day()+Integer.valueof((Math.random() * 100));
                if(opp.Ship_to_Party__c == null){
                   opp.Ship_to_Party__c = opp.AccountId; 
                }                
                opp.Industry__c = accountIdToAccount.get(opp.AccountId).Industry;  
                opp.Sub_Industry__c = accountIdToAccount.get(opp.AccountId).Sub_Segment__c;
                opp.Is_NAMO__c = accountIdToAccount.get(opp.AccountId).Group__c == 'NAMO' ? TRUE : FALSE;                                
                opp.KAM__c = accountIdToAccount.get(opp.AccountId).kam__c;
                opp.Billing_Address__City__s = accountIdToAccount.get(opp.AccountId).BillingCity;
                opp.Billing_Address__PostalCode__s = accountIdToAccount.get(opp.AccountId).BillingPostalCode;
                opp.Billing_Address__StateCode__s = accountIdToAccount.get(opp.AccountId).BillingStateCode;
                opp.Billing_Address__Street__s = accountIdToAccount.get(opp.AccountId).Billing_House_Flat_BlockNo__c!= null? accountIdToAccount.get(opp.AccountId).Billing_House_Flat_BlockNo__c + ' ' + accountIdToAccount.get(opp.AccountId).BillingStreet:accountIdToAccount.get(opp.AccountId).BillingStreet;
                opp.Billing_Address__CountryCode__s = accountIdToAccount.get(opp.AccountId).BillingCountryCode;
             //   if(accountIdToAccount.get(opp.AccountId).Group__c != 'NAMO'){
                    opp.Shipping_Address__City__s = shipToAccountIdToAccount.get(opp.Ship_to_Party__c) != null ? shipToAccountIdToAccount.get(opp.Ship_to_Party__c).ShippingCity : accountIdToAccount.get(opp.AccountId).ShippingCity;
                    opp.Shipping_Address__PostalCode__s = shipToAccountIdToAccount.get(opp.Ship_to_Party__c) != null ? shipToAccountIdToAccount.get(opp.Ship_to_Party__c).ShippingPostalCode : accountIdToAccount.get(opp.AccountId).ShippingPostalCode;
                    opp.Shipping_Address__StateCode__s = shipToAccountIdToAccount.get(opp.Ship_to_Party__c) != null ? shipToAccountIdToAccount.get(opp.Ship_to_Party__c).ShippingStateCode : accountIdToAccount.get(opp.AccountId).ShippingStateCode;
                    opp.Shipping_Address__Street__s =  shipToAccountIdToAccount.get(opp.Ship_to_Party__c) != null ? (shipToAccountIdToAccount.get(opp.Ship_to_Party__c).Shipping_House_Flat_BlockNo__c!= null ? shipToAccountIdToAccount.get(opp.Ship_to_Party__c).Shipping_House_Flat_BlockNo__c + ' ' + shipToAccountIdToAccount.get(opp.Ship_to_Party__c).ShippingStreet : shipToAccountIdToAccount.get(opp.Ship_to_Party__c).ShippingStreet) : (accountIdToAccount.get(opp.AccountId).Shipping_House_Flat_BlockNo__c!= null ? accountIdToAccount.get(opp.AccountId).Shipping_House_Flat_BlockNo__c + ' ' + accountIdToAccount.get(opp.AccountId).ShippingStreet:accountIdToAccount.get(opp.AccountId).ShippingStreet);
                    opp.Shipping_Address__CountryCode__s =  shipToAccountIdToAccount.get(opp.Ship_to_Party__c) != null ? shipToAccountIdToAccount.get(opp.Ship_to_Party__c).ShippingCountryCode : accountIdToAccount.get(opp.AccountId).ShippingCountryCode ; 
             //   }
            }
            if(opp.Branch__c != null && Opp.Department__c != null && keyToBranchDepartment.containskey(opp.Branch__c + '-'+ Opp.Department__c)){
                opp.Branch_Commericial__c  = keyToBranchDepartment.get(opp.Branch__c + '-'+ Opp.Department__c).Branch_Commercial__c;
                opp.Area_Manager__c  = keyToBranchDepartment.get(opp.Branch__c + '-'+ Opp.Department__c).Service_AM__c; 
                opp.Regional_Manager__c  = keyToBranchDepartment.get(opp.Branch__c + '-'+ Opp.Department__c).Service_RM__c; 
                opp.All_India_Head__c  = keyToBranchDepartment.get(opp.Branch__c + '-'+ Opp.Department__c).AIDH__c;
                opp.Regional_Commercial_Head__c  = keyToBranchDepartment.get(opp.Branch__c + '-'+ Opp.Department__c).Regional_Commercial_Head__c; 
                opp.Central_Commercial_Manager__c  = keyToBranchDepartment.get(opp.Branch__c + '-'+ Opp.Department__c).Central_Commercial_Manager__c; 
                opp.SMH__c = keyToBranchDepartment.get(opp.Branch__c + '-'+ Opp.Department__c).SMH__c;
                if(keyToBranchDepartment.get(opp.Branch__c + '-'+ Opp.Department__c).Associated_Warehouses__r.size() > 0){
                    opp.Plant__c = keyToBranchDepartment.get(opp.Branch__c + '-'+ Opp.Department__c).Associated_Warehouses__r[0].Warehouse__r.Id; 
                }
                opp.SME__c = keyToBranchDepartment.get(opp.Branch__c + '-'+ Opp.Department__c).SME__c;
                opp.SDE__c = keyToBranchDepartment.get(opp.Branch__c + '-'+ Opp.Department__c).Service_SDE__c; 
                opp.Division__c =  keyToBranchDepartment.get(opp.Branch__c + '-'+ Opp.Department__c).Department__r.Division__c;
                opp.All_India_Commericial_Head__c = keyToBranchDepartment.get(opp.Branch__c + '-'+ Opp.Department__c).AICH__c;
            }
            opp.CBO__c = CBOId;
            opp.StageName='Prospecting';
            opp.SubStatus__c = 'Not Contacted';
            if(keyToPricebook.containsKey(opp.Contract_Type__c)){
                opp.Pricebook2Id = keyToPricebook.get(opp.Contract_Type__c/*+deptIdToDeptNumber.get(opp.Department__c)*/);
            }
            
            opp.SBQQ__QuotePricebookId__c = opp.Pricebook2Id;
            if(opp.Opportunity_start_Date__c == null && opp.Opportunity_End_Date__c == null){
               	opp.Opportunity_start_Date__c = (opp.CloseDate != null?opp.CloseDate.addDays(1):System.TODAY()+1);
            	opp.Opportunity_End_Date__c = (opp.CloseDate != null?opp.CloseDate.addYears(1):System.TODAY().addYears(1)); 
         
            }
            }
    }
    /*
    //Assign default Pricebook to RPC if it is null or blank or RPC
public static void updateOpportunityPricebooks(List<Opportunity> opportunities) {
        // Prevent recursion with a static variable
        if (isAfterUpdateTriggerExecuted) {
            return; // Exit if this method has already been executed in this context
        }
        
        isAfterUpdateTriggerExecuted = true; // Set to true to indicate execution has started

        // Query for the Pricebook2 record with Name 'RPC'
        Pricebook2 rpcPricebook;
        try {
            rpcPricebook = [SELECT Id FROM Pricebook2 WHERE Name = 'RPC' LIMIT 1];
        } catch (Exception e) {
            // Handle the case where Pricebook with name 'RPC' does not exist
            System.debug('RPC Pricebook not found: ' + e.getMessage());
            return; // Exit early if the RPC pricebook is not available
        }

        // Create a list to hold Opportunities to be updated
        List<Opportunity> oppsToUpdate = new List<Opportunity>();

        // Loop through the opportunities to find those that need the Pricebook2 assignment
        for (Opportunity opp : opportunities) {
            // Only update if Contract_Type__c is null or 'RPC' and the Pricebook2Id is not already set
            if ((opp.Contract_Type__c == null || opp.Contract_Type__c == 'RPC') && opp.Pricebook2Id != rpcPricebook.Id) {
                Opportunity updatedOpp = new Opportunity(Id = opp.Id);
                updatedOpp.Pricebook2Id = rpcPricebook.Id;
                oppsToUpdate.add(updatedOpp);
            }
        }

        // Update the opportunities if there are any changes
        if (!oppsToUpdate.isEmpty()) {
            update oppsToUpdate;
        }
    }
        */
}