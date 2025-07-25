public class SAPInventoryUpdateBatch implements Database.Batchable<SAPInventoryUpdateAPIReqWrapper.InventoryDetail> {

    private List<SAPInventoryUpdateAPIReqWrapper.InventoryDetail> inventoryDetails;
    private List<SAPInventoryUpdateAPIResWrapper> responseWrappers;

    public SAPInventoryUpdateBatch(List<SAPInventoryUpdateAPIReqWrapper.InventoryDetail> inventoryDetails, List<SAPInventoryUpdateAPIResWrapper> responseWrappers) {
        this.inventoryDetails = inventoryDetails;
        this.responseWrappers = responseWrappers;
    }

    public Iterable<SAPInventoryUpdateAPIReqWrapper.InventoryDetail> start(Database.BatchableContext BC) {
        return inventoryDetails;
    }

    public void execute(Database.BatchableContext BC, List<SAPInventoryUpdateAPIReqWrapper.InventoryDetail> scope) {
        try {
            SAPInventoryUpdateAPIResWrapper batchResponseWrapper = updateInventory(scope);
            responseWrappers.add(batchResponseWrapper);
        } catch (Exception e) {
            System.debug('Exception in execute method: ' + e.getMessage());
            for (SAPInventoryUpdateAPIReqWrapper.InventoryDetail detail : scope) {
                SAPInventoryUpdateAPIResWrapper errorResponse = new SAPInventoryUpdateAPIResWrapper();
                errorResponse.result = 'Failure';
                errorResponse.message = 'Unable to update inventory details: ' + e.getMessage();
                   if(errorResponse != null){
                responseWrappers.add(errorResponse);
                }
            }
        }
    }

    public void finish(Database.BatchableContext BC) {
        // Optionally handle finish logic
    }



    private SAPInventoryUpdateAPIResWrapper updateInventory(List<SAPInventoryUpdateAPIReqWrapper.InventoryDetail> inventoryDetails) {
        SAPInventoryUpdateAPIResWrapper responseWrapper = new SAPInventoryUpdateAPIResWrapper();
        Map<String, ProductItem> productItemsMap = new Map<String, ProductItem>();
        Map<String, Product2> productsToUpdate = new Map<String, Product2>();
        Set<String> productCodes = new Set<String>();
        Set<String> warehouseCodes = new Set<String>();
    
        List<API_Log__c> invLogLst = new List<API_Log__c>();
    
        Map<String, Schema.Location> locationsMap = new Map<String, Schema.Location>();
        Map<String, Product2> productsMap = new Map<String, Product2>();
    
        // Collect all product codes and warehouse codes
        for (SAPInventoryUpdateAPIReqWrapper.InventoryDetail detail : inventoryDetails) {
            productCodes.add(detail.productCode);
            warehouseCodes.add(detail.warehouseCode);
        }
    
        try {
            // Get locations by warehouse codes
            List<Schema.Location> locationLst = UtilityClass.getLocationsByCodes(warehouseCodes);
        
            // Initialize a list to hold new ProductItems
            List<ProductItem> newProductItems = new List<ProductItem>();
             
            // Map product items
            for (Schema.Location inventory : locationLst) {
                locationsMap.put(inventory.Warehouse_Code__c, inventory);
    
                for (ProductItem prodItem : inventory.ProductItems) {
                    if (productCodes.contains(prodItem.Product2.ProductCode)) {
                        productItemsMap.put(prodItem.Product2.ProductCode, prodItem);
                    }
                }
            }
    
            system.debug('locationsMap - '+ locationsMap);
            system.debug('productItemsMap - '+ productItemsMap);
    
            List<Product2> productsToFetch = [SELECT Id, ProductCode FROM Product2 WHERE ProductCode IN :productCodes];
            for (Product2 product : productsToFetch) {
                productsMap.put(product.ProductCode, product);
            }
            system.debug('productsMap - '+ productsMap);
            
            // Update products and prepare response
            for (SAPInventoryUpdateAPIReqWrapper.InventoryDetail detail : inventoryDetails) {
                API_Log__c invLog = new API_Log__c();
                invLog.Request_Body__c = JSON.serialize(detail);

                system.debug('JSON.serialize(detail) - '+ JSON.serialize(detail));

                invLog.Class_Name__c = 'SAPInventoryUpdateBatch';
                invLog.API_Name__c = 'Inventory Update';
    
                if (productItemsMap.containsKey(detail.productCode)) {
                    ProductItem prodItem = productItemsMap.get(detail.productCode);
                    prodItem.QuantityOnHand = detail.totalStock;
    
                    boolean priceUpdate = Boolean.valueOf(detail.isPriceUpdate);
    
                    // Handle price update if required
                    if (priceUpdate) {
                        Product2 inventoryProduct = new Product2();
                        inventoryProduct.Id = prodItem.Product2Id;
                        if(detail.base_Price != null && detail.base_Price != ''){
                            inventoryProduct.Base_Price__c = Decimal.valueOf(detail.base_Price);
                        }
                        productsToUpdate.put(inventoryProduct.Id, inventoryProduct);
                    }
    
                    invLog.Status__c = 'Success';
                } else {
                    Schema.Location location = locationsMap.get(detail.warehouseCode);
    
                    if (location != null) {
                        if(productsMap.containsKey(detail.productCode)){
                            
                        ProductItem newProdItem = new ProductItem();
                        newProdItem.LocationId = location.Id;
                        newProdItem.Product2Id = productsMap.get(detail.productCode).Id;
                        newProdItem.QuantityOnHand = detail.totalStock;
                        newProductItems.add(newProdItem);
    
                        invLog.Status__c = 'Success';
                            
                        }
                        else{
                        invLog.Error_message__c = 'product unavailable' + detail.productCode;
                        invLog.Status__c = 'Failure';
    
                        responseWrapper.result = 'Failure';
                        responseWrapper.message = 'product unavailable' + detail.productCode;
                            
                            
                        }
                       
                    } else {
                        invLog.Error_message__c = 'Unable to find the location';
                        invLog.Status__c = 'Failure';
    
                        responseWrapper.result = 'Failure';
                        responseWrapper.message = 'Unable to find the location';
                    }
                }
                invLogLst.add(invLog);
            }

            system.debug('invLogLst size -- '+ invLogLst.size());
    
            // Insert new ProductItems
            if (!newProductItems.isEmpty()) {
                system.debug('newProductItems - ' + newProductItems);
                system.debug('newProductItems size - ' + newProductItems.size());

                Database.SaveResult[] insertResults = Database.insert(newProductItems, false);
                handleDmlErrors(insertResults, invLogLst, 'ProductItem');
            }
    
            // Perform bulk updates
            if (!productsToUpdate.isEmpty()) {
                system.debug('productsToUpdate - ' + productsToUpdate);
                system.debug('productsToUpdate size - ' + productsToUpdate.size());

                Database.UpsertResult[] upsertResults = Database.upsert(productsToUpdate.values(), Product2.Id, false);
                handleUpsertDmlErrors(upsertResults, invLogLst, 'Product2');
            }
            if (!productItemsMap.isEmpty()) {
                system.debug('productItemsMap - ' + productItemsMap);
                system.debug('productItemsMap size - ' + productItemsMap.size());

                Database.SaveResult[] updateResults = Database.update(productItemsMap.values(), false);
                handleDmlErrors(updateResults, invLogLst, 'ProductItem');
            }
            if (!invLogLst.isEmpty()) {

                system.debug('invLogLst - ' + invLogLst);
                system.debug('invLogLst size - ' + invLogLst.size());
                Database.insert(invLogLst, false);
            }
    
            system.debug('responseWrapper - ' + responseWrapper);
    
            // Success response if no exception occurred
            responseWrapper.result = 'Success';
            responseWrapper.message = 'Inventory details updated successfully';
    
            return responseWrapper;
    
        } catch (Exception e) {
            // Failure response if an exception occurred
            API_Log__c invLog = new API_Log__c();
            invLog.Error_message__c = 'Unable to update inventory details: ' + e.getMessage();
            invLog.Error_Line_Number__c = e.getLineNumber();
            invLog.Class_Name__c = 'SAPInventoryUpdateBatch';
            invLog.API_Name__c = 'Inventory Update';

            String requestJson = JSON.serialize(inventoryDetails);
            Integer maxCharLimit = 131072; // Adjust based on your field's length

            if (requestJson.length() > maxCharLimit) {
                invLog.Request_Body__c = JSON.serialize(inventoryDetails);
            }

    
            insert invLog;
            
            responseWrapper.result = 'Failure';
            responseWrapper.message = 'Unable to update inventory details: ' + e.getMessage();
            System.debug('Exception: ' + e.getMessage());
            System.debug('line num: ' + e.getLineNumber());
        }
    
        return responseWrapper;
    }
    
    // Helper method to handle DML errors for upsert operations and update response list
    private void handleUpsertDmlErrors(Database.UpsertResult[] results, List<API_Log__c> invLogLst, String recordType) {
        for (Integer i = 0; i < results.size(); i++) {
            if (!results[i].isSuccess()) {
                for (Database.Error error : results[i].getErrors()) {
                    API_Log__c errorLog = new API_Log__c();
                    errorLog.Error_message__c = 'Failed to process ' + recordType + ': ' + error.getMessage();
                    errorLog.Status__c = 'Failure';
                    invLogLst.add(errorLog);
                }
            }
        }
    }
    
    // Helper method to handle DML errors for insert and update operations and update response list
    private void handleDmlErrors(Database.SaveResult[] results, List<API_Log__c> invLogLst, String recordType) {
        for (Integer i = 0; i < results.size(); i++) {
            if (!results[i].isSuccess()) {
                for (Database.Error error : results[i].getErrors()) {
                    API_Log__c errorLog = new API_Log__c();
                    errorLog.Error_message__c = 'Failed to process ' + recordType + ': ' + error.getMessage();
                    errorLog.Status__c = 'Failure';
                    invLogLst.add(errorLog);
                }
            }
        }
    }
    
    


    
}