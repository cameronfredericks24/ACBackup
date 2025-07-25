public with sharing class CreateWarrantyController {

    @AuraEnabled
    public static id insertPolicy(string data, date startDate, date endDate, string policyName, string effectiveStartDate, string policyType, integer duration){
        
       Map<String, List<String>> deserializedMap = (Map<String, List<String>>)JSON.deserialize(data, Map<String, List<String>>.class);
        string productFamily = '';
        string productSubFamily = '';
        string Product = '';
        string Branch = '';
        string Customer = '';
         for(string key :deserializedMap.keySet()){
           if(key == 'ProductFamily' && deserializedMap.get(key).size()>0){
              for(string s : deserializedMap.get(key)){
                productFamily = productFamily + ',' + s;
              }
           }else if(key == 'ProductSubFamily'  && deserializedMap.get(key).size()>0){
            for(string s : deserializedMap.get(key)){
                productSubFamily = productSubFamily + ',' + s;
            }
         }else if(key == 'Product'  && deserializedMap.get(key).size()>0){
            for(string s : deserializedMap.get(key)){
                Product = Product + ',' + s;
            }
         }else if(key == 'Branch'  && deserializedMap.get(key).size()>0){
            for(string s : deserializedMap.get(key)){
                Branch = Branch + ',' + s;
            }
         }else if(key == 'Customer'  && deserializedMap.get(key).size()>0){
            for(string s : deserializedMap.get(key)){
                Customer = Customer + ',' + s;
            }
         }
        }
        if(productFamily != ''){
            productFamily = productFamily.substring(1);
        } if(productSubFamily != ''){
            productSubFamily = productSubFamily.substring(1);
        } if(Product != ''){
            Product = Product.substring(1);
        } if(Branch != ''){
            Branch = Branch.substring(1);
        } if(Customer != ''){
            Customer = Customer.substring(1);
        } 
        WarrantyTerm wt = New WarrantyTerm();
        wt.EffectiveStartDate = effectiveStartDate;
        wt.WarrantyTermName = policyName;
        wt.WarrantyUnitOfTime = 'Months';
        wt.WarrantyDuration = duration;
        wt.Start_Date__c = startDate;
        wt.End_Date__c = endDate;
        wt.WarrantyType = policyType;
        wt.Products__c = Product;
        wt.Product_Families__c = productFamily;
        wt.Product_Sub_Families__c = productSubFamily;
        wt.Branches__c = Branch;
        wt.Customers__c = Customer;
        wt.Approval_Status__c = 'Approved';
        wt.IsActive = true;
        insert wt;
        return wt.id;
    }


    @AuraEnabled
    public static void insertPartScope(List<Map<String, String>> data, string id) {
        list<Part_Scope__c> partScopeToBeInserted = New list <Part_Scope__c>();
        for (Map<String, Object> record : data) {
            Part_Scope__c ps = New Part_Scope__c();
            ps.Obligation__c = (String) record.get('Obligation');
            ps.Material_group__c = (String) record.get('MaterialGroup');
            ps.Scope__c = (String) record.get('scope');
            ps.Sub_Type__c = (String) record.get('Subtype');
            ps.Department__c = (String) record.get('Department');
            ps.Policy__c = id;
            partScopeToBeInserted.add(ps);
        }
        if(! partScopeToBeInserted.isEmpty()){
           insert partScopeToBeInserted;
        }
    }

    @AuraEnabled(Cacheable=true)
    public static list<Product_Family__c> getProductFamily() {
        ID productFamilyRecordTypeId = ProductFamilyConstants.productFamilyRecordTypeId;
        return[SELECT Name FROM Product_Family__c WHERE recordTypeId =: productFamilyRecordTypeId ];
    }
    @AuraEnabled(Cacheable=true)
    public static list<Product_Family__c> getProductSubFamily() {
        ID productSubFamilyRecordTypeId = ProductFamilyConstants.productSubFamilyRecordTypeId;
        return[SELECT Name FROM Product_Family__c WHERE recordTypeId =: productSubFamilyRecordTypeId];
    }
    @AuraEnabled(Cacheable=true)
    public static list<Product2> getProduct() {
        return[SELECT Name FROM Product2];
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getOptions() {
        List<Map<String, Object>> optionsList = new List<Map<String, Object>>();
        Id commercialAccountRT = AccountConstant.COMMERCIAL_ACCOUNT_RT;
        Id residentialAccountRT = AccountConstant.RESIDENTIAL_ACCOUNT_RT;
        ID productFamilyRecordTypeId = ProductFamilyConstants.productFamilyRecordTypeId;
        ID productSubFamilyRecordTypeId = ProductFamilyConstants.productSubFamilyRecordTypeId;
        // Query Salesforce objects using SOQL queries
        List<Product_Family__c> productFamilies = [SELECT Id, Name FROM Product_Family__c WHERE recordTypeId =: productFamilyRecordTypeId];
        List<Product_Family__c> productSubFamilies = [SELECT Id, Name FROM Product_Family__c WHERE recordTypeId =: productSubFamilyRecordTypeId];
        List<Product2> products = [SELECT Id, Name, ProductCode FROM Product2 WHERE ProductCode != null LIMIT 5000];
        list<Branch__c> branches = [SELECT Id,Name  FROM Branch__c];
        list<Account> customers = [SELECT Id,Name,Customer_ID__c  FROM Account WHERE (RecordTypeId =: residentialAccountRT OR RecordTypeId =: commercialAccountRT) AND Customer_ID__c != null LIMIT 5000 ];
        // Add more queries for other objects as needed

        // Construct the data structure
        optionsList.add(constructOptionSection('ProductSubFamily', productSubFamilies));
        optionsList.add(constructOptionSection('ProductFamily', productFamilies));
        optionsList.add(constructOptionSection('Product', products));
        optionsList.add(constructOptionSection('Branch', branches));
        optionsList.add(constructOptionSection('Customer', customers));

        return optionsList;
    }

    private static Map<String, Object> constructOptionSection(String sectionId, List<SObject> records) {
        Map<String, Object> section = new Map<String, Object>();
        section.put('id', sectionId);
        List<Map<String, Object>> options = new List<Map<String, Object>>();
        for (SObject record : records) {
            Map<String, Object> option = new Map<String, Object>();
            If(sectionId == 'Product' ){
                option.put('value', record.get('ProductCode'));
                option.put('label', record.get('ProductCode')); 
            }else If(sectionId == 'Customer' ){
                option.put('value', record.get('Customer_ID__c'));
                option.put('label', record.get('Customer_ID__c')); 
            }else{
                option.put('label', record.get('Name'));
                option.put('value', record.get('Name'));
            }
            option.put('checked', false);
            option.put('show', true);
            options.add(option);
        }
        section.put('options', options);
        return section;
    }

    // @AuraEnabled
    // public static void submitForApproval(string warrantyTermId){
    //     // Create an approval request for the Opportunity
    //     Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
    //     req1.setComments('Submitting request for approval automatically using Trigger');
    //     req1.setObjectId(warrantyTermId);
    //     req1.setNextApproverIds(new Id[] {'005Bi000002J2TBIA0'});
    //     // Submit the approval request for the Opportunity
    //     Approval.ProcessResult result = Approval.process(req1);
    // }
}