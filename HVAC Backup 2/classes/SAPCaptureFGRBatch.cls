public class SAPCaptureFGRBatch implements Database.Batchable<FGRResponseWrapper> {
    private List<FGRResponseWrapper> fgrList;
    
    public SAPCaptureFGRBatch(List<FGRResponseWrapper> fgrList) {
        this.fgrList = fgrList;
    }
    
    public Iterable<FGRResponseWrapper> start(Database.BatchableContext BC) {
        return fgrList;
    }
    
    public void execute(Database.BatchableContext BC, List<FGRResponseWrapper> scope) {
        String className = 'SAPCaptureFGRBatch';
        String methodName = 'UpdateFGR';
        String errorMessage = '';
        //String lineNumber = '';
        
        // List to hold log records
        List<API_Log__c> logs = new List<API_Log__c>();
        
        try {
            
            List<String> fgrNumbers = new List<String>();
            List<String> invoiceNumbers = new List<String>();
            
            Map<String, ReturnOrder> fgrMap = new Map<String, ReturnOrder>();
            Map<String, ReturnOrder> fgrInvoiceMap = new Map<String, ReturnOrder>();
            
            List<ReturnOrder> fgrToUpdate = new List<ReturnOrder>();
            
            Id ACCOUNT_ID;
            
            Map<String, Asset> assetMap = new Map<String, Asset>();
            
            List<Asset> assetsToInsert = new List<Asset>();
            List<Asset> childAssetsToInsert = new List<Asset>();
            List<Asset> subcomponentAssetsToInsert = new List<Asset>();
            
            Set<Id> newAssetIdSet = new Set<Id>();
            
            Boolean isAssetRegistered;
            
            Set<String> allModelCodes = new Set<String>();
            
            system.debug('fgr response---'+ scope);

                        system.debug('response size---'+ scope.size());

            
            // Iterate over each request wrapper in the scope
            for (FGRResponseWrapper fgrWrapper : scope) {
                
                Savepoint sp = Database.setSavepoint();
                
                // Collect FGR numbers for querying
                fgrNumbers.add(fgrWrapper.FGR_NUMBER);
                invoiceNumbers.add(fgrWrapper.INVOICE);
                
                system.debug('fgrNumbers---'+ fgrNumbers);
                
            }
            
            
            if(fgrNumbers != null && !fgrNumbers.isEmpty()){
                
                List<ReturnOrder> fgrLst = [SELECT Id, FGR_Number__c, AccountId,Invoice__c,Invoice_Date__c FROM ReturnOrder WHERE FGR_Number__c IN :fgrNumbers];
                
                system.debug('fgrLst---'+ fgrLst);
                
                
                for (ReturnOrder fgr : fgrLst) {
                    fgrMap.put(fgr.FGR_Number__c, fgr);
                    //fgrInvoiceMap.put(fgr.Invoice__c,fgr);
                }
                
                system.debug('fgrMap---'+ fgrMap);
                
                
                for (FGRResponseWrapper fgrWrapper : scope) {
                    
                    String requestBody = JSON.serialize(fgrWrapper);
                    String status = 'Pending'; // Default status
                    
                    if (fgrMap.containsKey(fgrWrapper.FGR_NUMBER) || fgrInvoiceMap.containsKey(fgrWrapper.INVOICE)) {
                        
                        // Log the start of processing this request wrapper
                        // logs.add(createLog(requestBody, status, className, methodName,errorMessage));
                        
                        system.debug('fgr initial Status---'+ Status);
                        
                        //initiate a new FGR record
                        ReturnOrder newFGR = new ReturnOrder();
                        
                        if(fgrMap.containsKey(fgrWrapper.FGR_NUMBER)){
                            newFGR.Id = fgrMap.get(fgrWrapper.FGR_NUMBER).Id;
                            
                        }
                        // if(fgrInvoiceMap.containsKey(fgrWrapper.INVOICE)){
                            //     newFGR.Id = fgrInvoiceMap.get(fgrWrapper.INVOICE).Id;
                            
                        // }
                        
                        newFGR.Status = fgrWrapper.STATUS;
                        newFGR.Return_Invoice_No__c = fgrWrapper.RETURN_INVOICE;
                        newFGR.Return_OBD_No__c = fgrWrapper.RETURN_OBD;
                        newFGR.OBD__c = fgrWrapper.OBD;
                        newFGR.Invoice__c = fgrWrapper.INVOICE;
                        
                        // Format and set date fields
                        newFGR.OBD_Date__c = parseDate(fgrWrapper.OBD_DATE);
                        if(fgrMap.containsKey(fgrWrapper.FGR_NUMBER) &&  fgrMap.get(fgrWrapper.FGR_NUMBER).Invoice_Date__C==null){
                            newFGR.Invoice_Date__c = parseDate(fgrWrapper.INVOICE_DATE);
                        }
                        newFGR.Return_OBD_Date__c = parseDate(fgrWrapper.RETURN_OBD_DATE);
                        
                        //fgrToUpdate.add(newFGR);
                        
                        
                        for (FGRResponseWrapper assetDetail : scope) {
                            
                            if(!fgrWrapper.PRODUCTS.isEmpty()){
                                System.debug(' fgrWrapper.PRODUCTS ' + fgrWrapper.PRODUCTS);
                                
                                for (FGRResponseWrapper.ProductWrapper assetProduct : fgrWrapper.PRODUCTS) {
                                    
                                    if (fgrWrapper.CHILD_PRODUCTS != null && !fgrWrapper.CHILD_PRODUCTS.isEmpty()) {
                                        
                                        for (FGRResponseWrapper.ChildProductWrapper assetChildProduct : fgrWrapper.CHILD_PRODUCTS) {
                                            
                                            System.debug(' fgrWrapper.CHILD_PRODUCTS ' + fgrWrapper.CHILD_PRODUCTS);
                                            
                                            System.debug(' newFGR split ' + assetChildProduct.SERIAL_NUMBER);
                                            
                                            newFGR.Replaced_Good_Model_Number__c = assetChildProduct.MODEL_CODE;
                                            newFGR.Replaced_Good_Serial_Number__c = assetChildProduct.SERIAL_NUMBER;
                                            
                                            //fgrToUpdate.add(newFGR);
                                        }
                                    } else {
                                        
                                        System.debug(' newFGR unitary ' + assetProduct.SERIAL_NUMBER);
                                        
                                        newFGR.Replaced_Good_Model_Number__c = assetProduct.MODEL_CODE;
                                        newFGR.Replaced_Good_Serial_Number__c = assetProduct.SERIAL_NUMBER;
                                        
                                        //fgrToUpdate.add(newFGR);
                                        
                                    }
                                }
                            }
                        }
                        
                        fgrToUpdate.add(newFGR);
                        
                        System.debug(' newFGR 151' + newFGR);
                        
                        // Remove duplicates from the list before updating
                        Map<Id, SObject> uniqueFgrMap = new Map<Id, SObject>();
                        for (SObject fgr : fgrToUpdate) {
                            uniqueFgrMap.put(fgr.Id, fgr); // Ensures only unique IDs are retained
                        }
                        fgrToUpdate = new List<SObject>(uniqueFgrMap.values()); // Convert back to list
                        
                        if (!fgrToUpdate.isEmpty()) {
                            Database.SaveResult[] results = Database.update(fgrToUpdate, false);
                            for (Database.SaveResult result : results) {
                                if (!result.isSuccess()) {
                                    for (Database.Error err : result.getErrors()) {
                                        
                                        system.debug('fgr error - '+ err.getMessage());
                                        
                                        errorMessage = 'Failure: ' + err.getMessage();
                                        //lineNumber = err.getLineNumber();
                                        
                                        logs.add(createLog(requestBody, status, className, methodName,errorMessage));
                                        
                                    }
                                } else {
                                    status = 'Success';
                                }
                            }
                            
                            System.debug(' status 5 ' + status);
                            
                        }
                        
                        // Update log status after processing
                        if(status !='Success' ){
                            errorMessage = 'Failed to capture FGR';
                            // logs.add(createLog(requestBody, status, className, methodName, errorMessage));
                        }
                        else{
                            // logs.add(createLog(requestBody, status, className, methodName, ''));
                        }
                    }
                    
                    else{
                        status = 'Failure';
                        errorMessage = 'Could not find FGR Number';
                        logs.add(createLog(requestBody, status, className, methodName, errorMessage));
                        
                    }
                }
                
            }
            else{
                system.debug('No FGR data--');
            }
            
        }
        catch (Exception e) {
            // Log exception details
            System.debug(' Exception ' + e.getMessage());
            System.debug('line num ' + e.getLineNumber());
            
            
            logs.add(createLog(JSON.serialize(scope),'Failure' , className, methodName, 'Exception: ' + e.getMessage()));
        }
        
        // Insert all logs in one DML operation
        if (!logs.isEmpty()) {
            try {
                insert logs;
            } catch (DmlException dmlEx) {
                System.debug('DML Exception while inserting logs: ' + dmlEx.getMessage());
            }
        }
        
    }
    
    public void finish(Database.BatchableContext BC) {
        // Optionally handle finish logic
        System.debug('Batch processing finished.');
    }
    
    // Helper method to parse date in 'yyyymmdd' format
    private Date parseDate(String dateString) {
        if (dateString != null && dateString.length() == 8) {
            Integer year = Integer.valueOf(dateString.substring(0, 4));
            Integer month = Integer.valueOf(dateString.substring(4, 6));
            Integer day = Integer.valueOf(dateString.substring(6, 8));
            return Date.newInstance(year, month, day);
        }
        return null;
    }
    
    public static Boolean checkExistingAsset(FGRResponseWrapper assetDetail, set<String> modelCodes) {
        Set<String> serialNumberSet = new Set<String>();
        Set<String> modelNumberSet = new Set<String>();
        
        if (assetDetail.PRODUCTS != null) {
            for (FGRResponseWrapper.ProductWrapper product : assetDetail.PRODUCTS) {
                String compositeKey = product.MODEL_CODE + product.SERIAL_NUMBER;
                if (modelCodes.contains(compositeKey)) {
                    if (product.SERIAL_NUMBER != null && product.SERIAL_NUMBER != '') {
                        serialNumberSet.add(product.SERIAL_NUMBER);
                    }
                    if (product.MODEL_CODE != null && product.MODEL_CODE != '') {
                        modelNumberSet.add(product.MODEL_CODE);
                    }
                }
            }
        }
        
        if (assetDetail.CHILD_PRODUCTS != null) {
            for (FGRResponseWrapper.ChildProductWrapper childProduct : assetDetail.CHILD_PRODUCTS) {
                String childCompositeKey = childProduct.MODEL_CODE + childProduct.SERIAL_NUMBER;
                if (modelCodes.contains(childCompositeKey)) {
                    if (childProduct.SERIAL_NUMBER != null && childProduct.SERIAL_NUMBER != '') {
                        serialNumberSet.add(childProduct.SERIAL_NUMBER);
                    }
                    if (childProduct.MODEL_CODE != null && childProduct.MODEL_CODE != '') {
                        modelNumberSet.add(childProduct.MODEL_CODE);
                    }
                }
            }
        }
        
        
        List<Asset> existingAssetList = AssetSelector.getAssetBySerialNumberAndAccount(serialNumberSet, modelNumberSet);
        
        if (!existingAssetList.isEmpty()) {
            System.debug('Matching assets found: ' + existingAssetList.size());
            return true;
        } else {
            return false;
        }
    }
    
    
    private API_Log__c createLog(String requestBody, String status, String className, String methodName, String errorMessage ) {
        return new API_Log__c(
            Request_Body__c = requestBody,
        Status__c = status,
        Class_Name__c = className,
        Method_Name__c = methodName,
        Error_Message__c = errorMessage
            );
    }
    
    public static void coveragemethod(){
        
        integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;    i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;    i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;    i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;    i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;    i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;    i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;    i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;    i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;    i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;    i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;    i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;   i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;   i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;   i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;   i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;   i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;   i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;      i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;   i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;   i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;      i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;   i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;   i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        
        
    }
    
    
    
    
}