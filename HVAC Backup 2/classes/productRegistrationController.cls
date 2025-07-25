/*
@Author : Deepanshu Tyagi
@CreatedDate : 24th Jan 2024
@Description : For creation of Bulk Product Registration this class is used.
 */
public without sharing class productRegistrationController implements Callable  {
    
    
    public static   List<GenericFileUploaderController.fileResultWrapper> createProductRegistration(List<Map<String, String>>ListMap, map<String,string> mapOfAPiAndFields , map<String,string> mapOfAPiAndDataType  ){
        List<Bulk_Product_Request__c> listOfBPR = new List<Bulk_Product_Request__c>();
        List<Bulk_Product_Request__c> listOfBPR2 = new List<Bulk_Product_Request__c>();
        List<String> sapList= new List<String>();
        List<String> modelNumberList = new List<string>();
        List<String> serialNumberList = new List<string>();
        set<String> customerphoneLst = new set<string>();
        set<String> pincodeLst = new set<string>();
        
        Map<String,string> duplicateSerialNumberMap = new map<string,string>();
        Map<String,Account> mapIdWithAcc = new Map<String,Account>();
        Map<String,string> mapIdWithProd = new Map<String,string>();
        List<GenericFileUploaderController.fileResultWrapper> AllRecords = new List<GenericFileUploaderController.fileResultWrapper>();
        List<Account> ListOfAccount = new List<Account>();
        //creating  Bulk Upload Job
        Bulk_Upload_Job__c BUJ = new Bulk_Upload_Job__c();
        BUJ.Type__c= UtilityClass.getOrgConstantValue('Product_Registration');
        insert BUJ;
        
        system.debug('BUJ initial-- '+ BUJ);
        
        
        system.debug('ListMap-- '+ ListMap);
        
        
        Map<String,String> requiredfieldMap = new Map<String, String>();
        List<Parent_CSV_Mapping__mdt> parentCSV = GenericFileUploaderController.getListOfMapping('Product Registration');
        system.debug('parentCSV'+parentCSV);
        system.debug('parentCSV'+parentCSV[0].CSV_Uploading_Mappings__r);
        if(parentCSV.size()>0){
            for(CSV_Uploading_Mapping__mdt cu:parentCSV[0].CSV_Uploading_Mappings__r){
                if(cu.Is_Required__c==true){
                    requiredfieldMap.put(cu.Field_API_Name__c,cu.Column_Name__c);
                }
            }
        }
        
        system.debug('requiredfieldMap-- '+ requiredfieldMap);
        
        system.debug('requiredfieldMap-- '+ requiredfieldMap.values());
        
        String requiredfields = '';
        
        system.debug('mapOfAPiAndDataType-- '+ mapOfAPiAndDataType);
        for (Map<String, String> fieldMap : listMap) {
            
            
            system.debug('fieldMap-- '+ fieldMap);
            Bulk_Product_Request__c BPR = new Bulk_Product_Request__c();
            /// asset.AccountId = '001Bi00000CPrjxIAD';
            BPR.Bulk_Upload_Job__c = BUJ.id;
            for (String key : fieldMap.keySet()) {
                system.debug('key 35-- '+ key);


                // String value = String.isBlank(fieldMap.get(key)) ? '' : fieldMap.get(key);

                String value = fieldMap.get(key);

                String fieldAPIName = mapOfAPIAndFields.get(key);
                String dataType = mapOfAPIAndDataType.get(fieldAPIName);


                if(requiredfieldMap.get(fieldAPIName)!=null && (value==null || value=='')){
                    system.debug('value required'+value);
                    system.debug('fieldAPIName required'+fieldAPIName);
                    
                    requiredfields+= key+', ';
                }
                
                
                // Your processing logic for each field and header
                if (dataType == 'Text') {
                    BPR.put(fieldAPIName, value);
                    
                }
                else if (dataType == 'Decimal' && (value != null && value != '')) {
                    BPR.put(fieldAPIName, Decimal.valueOf(value));
                }
                
                else if (dataType == 'Integer' && (value != null && value != '') ) {
                    system.debug('code value --'+ value);
                    BPR.put(fieldAPIName, Integer.valueOf(value));
                }
                else if (dataType == 'Date' && (value != null && value != '')) {
                    system.debug('fieldAPIName Date --' + fieldAPIName);
                    system.debug('Date value --' + value);
                    
                    Date parsedDate;
                    
                    // Replace slashes with hyphens to standardize the input
                    String standardizedValue = value.replace('/', '-');
                    
                    // Split the date string by the hyphen (after replacing slashes)
                    List<String> dateParts = standardizedValue.split('-');
                    
                    // Handle 'dd-MM-yyyy' or 'dd/MM/yyyy' format
                    if (dateParts.size() == 3 && dateParts[2].length() == 4 && dateParts[0].length() == 2) {
                        Integer day = Integer.valueOf(dateParts[0]);
                        Integer month = Integer.valueOf(dateParts[1]);
                        Integer year = Integer.valueOf(dateParts[2]);
                        parsedDate = Date.newInstance(year, month, day);
                    } 
                    // Handle 'yyyy-MM-dd' or 'yyyy/MM/dd' format
                    else if (dateParts.size() == 3 && dateParts[0].length() == 4 && dateParts[2].length() == 2) {
                        parsedDate = Date.valueOf(standardizedValue); // Default yyyy-MM-dd format
                    } 
                    // Handle 'MM/dd/yyyy' or 'MM-dd-yyyy' format
                    else if (dateParts.size() == 3 && dateParts[0].length() == 1 || dateParts[0].length() == 2 && dateParts[2].length() == 4) {
                        Integer month = Integer.valueOf(dateParts[0]);
                        Integer day = Integer.valueOf(dateParts[1]);
                        Integer year = Integer.valueOf(dateParts[2]);
                        parsedDate = Date.newInstance(year, month, day);
                    }
                    
                    // Now parsedDate is in yyyy-MM-dd format
                    if (parsedDate != null) {
                        BPR.put(fieldAPIName, parsedDate);
                    } else {
                        // Handle invalid date format
                        system.debug('Invalid date format for value: ' + value);
                        // You can throw an exception or provide a fallback mechanism
                    }
                }
                
                system.debug('UtilityClass.getOrgConstantValue SAP_External_Id --'+ UtilityClass.getOrgConstantValue('SAP_External_Id'));
                
                system.debug('key 56 --'+ key );
                
                if (key == 'Customer ID**') {
                    sapList.add(value);
                    
                }
                system.debug('UtilityClass.getOrgConstantValue Model_Number --'+ UtilityClass.getOrgConstantValue('Model_Number'));
                
                if(key== 'Model**'){
                    modelNumberList.add(value);
                }
                
                system.debug('utility class value --'+ UtilityClass.getOrgConstantValue('Serial_Number'));
                
                if(key== 'Product Serial No.**'){
                    serialNumberList.add(value);
                }
                
                if(key == 'Installation Date**'){
                    
                    system.debug('Installation Date --'+ value);
                    
                }
                
                system.debug('sapList --'+ sapList);
                
                system.debug('BPR --'+ BPR);
                
                system.debug('value -- '+value);
                
                system.debug('fieldAPIName -- '+fieldAPIName);
                
              
                
            }
            listOfBPR.add(BPR);
            
        }
        
        
        system.debug('listOfBPR --'+ listOfBPR);
        
        
        
        system.debug('requiredfields --'+ requiredfields);
        
        if(requiredfields != null && requiredfields != ''){
            
            system.debug('requiredfields not null- '+ requiredfields);
            
            return null;
        }
        
        system.debug('serialNumberList --'+ serialNumberList);
        
        GenericFileUploaderController.fileResultWrapper  FRW = new GenericFileUploaderController.fileResultWrapper();
        
        
        if(AllRecords.Size()>0){
            // BUJ2.Success_Record_Count__c = successcase.size();
            // BUJ2.Failed_Record_Count__c = AllRecords.size() BUJ2.Total_Record_Count__c - BUJ2.Success_Record_Count__c;
            return AllRecords;
        }
        

        
        
        
        if(listOfBPR.size()>0){
            
            if(sapList.size()>0){
                
                list<Account> accList = [SELECT Id,Branch__c,ShippingPostalCode,ShippingStreet,ShippingCity,ShippingState,
                                            Customer_ID__c,SAP_Customer_Id__c FROM Account 
                                            WHERE Customer_ID__c IN: sapList OR SAP_Customer_Id__c IN:sapList];

                system.debug('accList -- '+ accList); 
                
                System.debug('accList size -- '+ accList.size());
                if(accList != null && accList.size()>0){
                    for(account acc:accList){
                                                
                        if(acc.SAP_Customer_Id__c != null){
                            mapIdWithAcc.put(acc.SAP_Customer_Id__c,acc);
                        }
                        if(acc.Customer_ID__c != null){
                            mapIdWithAcc.put(acc.Customer_ID__c,acc);
                        }
                    }
                }
            }

                system.debug('mapIdWithAcc -- '+ mapIdWithAcc); 

            
            if(modelNumberList.size()>0){
                List<Product2> prodList =[select id,ProductCode from Product2 where ProductCode=:modelNumberList];
                
                if(prodList != null && prodList.size()>0){
                    for(Product2 prod:prodList){
                        mapIdWithProd.put(prod.ProductCode,prod.Id);
                    }
                }
            }
     
            
            System.debug('duplicateSerialNumberMap--->' + duplicateSerialNumberMap);
            
            // Temporary map to track newly created accounts within the loop
            Map<String, Account> tempMapIdWithAcc = new Map<String, Account>();
            
            for(Bulk_Product_Request__c BPR:listOfBPR){
                
                System.debug('BPR--->' + BPR);

                System.debug('BPR Account__c--->' + BPR.Account__c);
                
                //tag account
                if(BPR.Account__c == null){
                    System.debug('mapIdWithAcc--->' + mapIdWithAcc);
                    System.debug('BPR.SAP_External_Id__c--->' + BPR.SAP_External_Id__c);

                    if(mapIdWithAcc.containsKey(BPR.SAP_External_Id__c)){
                        System.debug('BPR.SAP_External_Id__c--->' + BPR.SAP_External_Id__c);
                        
                        BPR.Account__c=mapIdWithAcc.get(BPR.SAP_External_Id__c).Id;
                    }
                }
                
                //for Product
                if(BPR.Model_Number__c != null && BPR.Product__c == null){
                    if(mapIdWithProd.containsKey(BPR.Model_Number__c )){
                        BPR.Product__c=mapIdWithProd.get(BPR.Model_Number__c );
                    }
                }

                    listOfBPR2.add(BPR);
                
                system.debug('tempMapIdWithAcc -- '+ tempMapIdWithAcc);

                
            }
            
            // Database.UpsertResult[] SR = Database.upsert(listOfBPR, false);
            Database.SaveResult[] SR = Database.insert(listOfBPR2, false);
            //List<String> allRecordsWithMessages = new List<String>();
            
            
            System.debug('sr--' + SR);
            System.debug('sr size--' +SR.size());
            //getting name of Bulk Uploading Job
            
            // Iterate over the SaveResult array to find and display errors
            for (Database.SaveResult srs : SR) {
                if (!srs.isSuccess()) {
                    // If there are errors, get them
                    Database.Error[] errors = srs.getErrors();
                    
                    for (Database.Error error : errors) {
                        // Display each error message and its status code
                        System.debug('Error Status Code: ' + error.getStatusCode());
                        System.debug('Error Message: ' + error.getMessage());
                        System.debug('Fields with Error: ' + error.getFields());
                    }
                } else {
                    // If successful, display the success message or Id
                    System.debug('Insert Successful: Record Id - ' + srs.getId());
                }
            }
        }
        return AllRecords;
    }
    
    // Dispatch actual methods
    public List<GenericFileUploaderController.fileResultWrapper> call(String action, Map<String,Object> args ) {
        List<GenericFileUploaderController.fileResultWrapper> AllRecords = new List<GenericFileUploaderController.fileResultWrapper>();
        switch on action {
            when 'createProductRegistration' {
                AllRecords =createProductRegistration((List<Map<String, String>>)args.get('ListMap'),(map<String,string>)args.get('mapOfAPiAndFields'),(map<String,string>)args.get('mapOfAPiAndDataType')  );
                
            }
            
            
        }
        return AllRecords;
    }
    
    
}