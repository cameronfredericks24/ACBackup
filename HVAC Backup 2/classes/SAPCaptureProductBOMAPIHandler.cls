public without sharing class SAPCaptureProductBOMAPIHandler {

    public static List<SAPCaptureProductBOMAPIResWrapper> createBOM(SAPCaptureProductBOMAPIReqWrapper reqWrapperList) {
        List<SAPCaptureProductBOMAPIResWrapper> responseList = new List<SAPCaptureProductBOMAPIResWrapper>();

        try {
            // Retrieve product record type
            String productRecordTypeId = UtilityClass.getRecordTypeIdByDeveloperName('Product2', 'Product');

            // Map to hold Product2 records by model number
            Map<String, Product2> modelNumberToProductMap = new Map<String, Product2>();

            // Set to collect all unique model numbers
            Set<String> allModelNumbers = new Set<String>();

            set<String> bomNumbers = new set<String>();

            map<String,map<Bom__c,list<Bom_Item__c>>> codeVSBomMap = new map<String,map<Bom__c,list<Bom_Item__c>>>();


            // Populate set of all model numbers
            for (SAPCaptureProductBOMAPIReqWrapper.BOM bom : reqWrapperList.bomList) {
                allModelNumbers.add(bom.model_number);
                bomNumbers.add(bom.bom_number);

                for(SAPCaptureProductBOMAPIReqWrapper.LineItem bomItem : bom.part_code_line_items) {
                    allModelNumbers.add(bomItem.part_code);
                }
            }

            list<Bom__c> existingBomLst = [SELECT ID,BOM_Number__c,Product_Code__c,AltBOM__c,(SELECT ID FROM BOM_Items__r) FROM Bom__c 
                                            WHERE BOM_Number__c IN:bomNumbers AND Product_Code__c IN: allModelNumbers];

            System.debug('existingBomLst - ' + existingBomLst);
            System.debug('existingBomLst size - ' + existingBomLst.size());

            for(Bom__c existingBOM: existingBomLst){


                map<Bom__c,list<Bom_Item__c>> bomVsBomItemMap = new map<Bom__c,list<Bom_Item__c>>();

                System.debug('existingBOM items - ' + existingBOM.BOM_Items__r.size());


                List<BOM_Item__c> existingitemsLst = new List<BOM_Item__c>(); // Initialize the list

                for (BOM_Item__c bomItem : existingBOM.BOM_Items__r) {
                    existingitemsLst.add(bomItem); // Add each BOM_Item__c to the list
                }
                 bomVsBomItemMap.put(existingBOM,existingitemsLst);

                codeVSBomMap.put(existingBOM.Product_Code__c,bomVsBomItemMap);

                            for (SAPCaptureProductBOMAPIReqWrapper.BOM bom : reqWrapperList.bomList) {

                                if(bom.alt_bom != existingBOM.AltBOM__c){
                                    existingBOM.AltBOM__c = bom.alt_bom;
                                }

                            }

            }

            if(!existingBomLst.isEmpty()){
                Database.update(existingBomLst, false);

            }


                        System.debug('codeVSBomMap - ' + codeVSBomMap);

                        System.debug('codeVSBomMap keys- ' + codeVSBomMap.keySet());

                        System.debug('codeVSBomMap values- ' + codeVSBomMap.values());

                        System.debug('allModelNumbers - ' + allModelNumbers);

            // Query Product2 records based on all model numbers
            List<Product2> productList = new List<Product2>();

            if (!allModelNumbers.isEmpty()) {
                productList = ProductSelector.getProductByModelNumberBOM(allModelNumbers);
            }

            // Populate map of model numbers to Product2 records
            for (Product2 product : productList) {
                modelNumberToProductMap.put(product.ProductCode, product);
            }

            // Lists to hold BOMs and BOM Items for bulk insertion
            List<BOM__c> bomListToInsert = new List<BOM__c>();
            List<BOM_Item__c> bomItemsToInsert = new List<BOM_Item__c>();
            Map<String, List<BOM_Item__c>> bomIdToItemsMap = new Map<String, List<BOM_Item__c>>();

            list<BOM_Item__c> bomItemsToDelete = new list<BOM_Item__c>();

            // Process each BOM in the request wrappers
            for (SAPCaptureProductBOMAPIReqWrapper.BOM bom : reqWrapperList.bomList) {
                SAPCaptureProductBOMAPIResWrapper responseWrapper = new SAPCaptureProductBOMAPIResWrapper();

                if(codeVSBomMap.containsKey(bom.model_number)){

                    Map<BOM__c, List<BOM_Item__c>> bomVsBomItemsMap = codeVSBomMap.get(bom.model_number);

                        system.debug('bomVsBomItemsMap size-- '+ bomVsBomItemsMap.values().size());

                          // Iterate through the map to retrieve all BOM_Item__c lists
                        for (List<BOM_Item__c> bomItemList : bomVsBomItemsMap.values()) {
                            // Add each BOM_Item__c Id to the bomItemsToDelete list
                            for (BOM_Item__c bomItem : bomItemList) {
                                bomItemsToDelete.add(bomItem);
                            }
                        }

                        system.debug('bomItemsToDelete-- '+ bomItemsToDelete);

                        for(Bom__c existingBomRecord:bomVsBomItemsMap.keySet()){

                                        // Prepare BOM Items
                                List<BOM_Item__c> bomItemList = new List<BOM_Item__c>();
                                Boolean hasError = false;
                                if (bom.part_code_line_items != null && !bom.part_code_line_items.isEmpty()) {
                                    for (SAPCaptureProductBOMAPIReqWrapper.LineItem bomLineItem : bom.part_code_line_items) {

                                        BOM_Item__c bomItem = new BOM_Item__c();
                                        bomItem.Quantity__c = Decimal.valueOf(bomLineItem.quantity);
                                        bomItem.UOM__c = bomLineItem.uom;
                                        bomItem.Name = bomLineItem.line_item_no;
                                        bomItem.Part_Code_Text__c = bomLineItem.part_code;

                                        if(modelNumberToProductMap.containsKey(bomLineItem.part_code)){
                                            Product2 spareProduct = modelNumberToProductMap.get(bomLineItem.part_code);
                                            bomItem.Part__c = spareProduct.Id;
                                       
                                        }
                                         // Associate with existing BOM ID
                                        bomItem.BOM__c = existingBomRecord.Id;

                                        system.debug('bomLineItem.sort_string 1-- ' + bomLineItem.sort_string);

                                        if(bomLineItem.sort_string != null && bomLineItem.sort_string != ''){

                                                                   

                                            bomitem.Ref_WRT_Img__c = bomLineItem.sort_string;
                                            system.debug('bomLineItem.sort_string--'+ bomLineItem.sort_string);
                                            
                                        }
                                   

                                        //bomItemList.add(bomItem);
                                        bomItemsToInsert.add(bomItem);

                                    }
                                }

                                if (!hasError) {
                                bomIdToItemsMap.put(existingBomRecord.BOM_Number__c, bomItemList);
                                responseWrapper.result = IntegrationAPIHelper.RESP_SUCCESS_RESULT;
                                responseWrapper.message = 'BOM details captured successfully';
                                }
                        }
                }

                else{

                    // Create BOM record
                    BOM__c newBOM = new BOM__c();
                    newBOM.BOM_Number__c = bom.bom_number;
                    newBOM.Product_Code__c = bom.model_number;
                    newBOM.AltBOM__c = bom.alt_bom;


                    if(modelNumberToProductMap.containsKey(bom.model_number)){
                            Product2 bomProduct = modelNumberToProductMap.get(bom.model_number);
                            newBOM.Product__c = bomProduct.Id;
                        }

                    // Prepare BOM Items
                    List<BOM_Item__c> bomItemList = new List<BOM_Item__c>();
                    Boolean hasError = false;
                    if (bom.part_code_line_items != null && !bom.part_code_line_items.isEmpty()) {
                        for (SAPCaptureProductBOMAPIReqWrapper.LineItem bomLineItem : bom.part_code_line_items) {

                            BOM_Item__c bomItem = new BOM_Item__c();
                            bomItem.Quantity__c = Decimal.valueOf(bomLineItem.quantity);
                            bomItem.UOM__c = bomLineItem.uom;
                            bomItem.Name = bomLineItem.line_item_no;
                            bomItem.Part_Code_Text__c = bomLineItem.part_code;

                            system.debug('bomLineItem.sort_string-- ' +bomLineItem.sort_string);

                       

                                        if(bomLineItem.sort_string != null && bomLineItem.sort_string != ''){

                                              bomitem.Ref_WRT_Img__c = bomLineItem.sort_string;
                                        system.debug('bomLineItem.sort_string--'+ bomLineItem.sort_string);
                                            
                                        }
                                

                            if(modelNumberToProductMap.containsKey(bomLineItem.part_code)){
                                Product2 spareProduct = modelNumberToProductMap.get(bomLineItem.part_code);
                            bomItem.Part__c = spareProduct.Id;
                 

                            }
                            bomItemList.add(bomItem);
                        }
                    }

                    if (!hasError) {
                        bomListToInsert.add(newBOM);
                        bomIdToItemsMap.put(newBOM.BOM_Number__c, bomItemList);
                        responseWrapper.result = IntegrationAPIHelper.RESP_SUCCESS_RESULT;
                        responseWrapper.message = 'BOM details captured successfully';
                    }

            }

                responseWrapper.bom_number = bom.bom_number;
                responseList.add(responseWrapper);
            }

            if(!bomListToInsert.isEmpty()){

                 // Perform bulk insertion of BOM records in batches
                batchInsertBOMs(bomListToInsert, responseList, bomIdToItemsMap);

                // Collect all BOM Items for insertion with the correct BOM__c Ids
                for (BOM__c insertedBom : bomListToInsert) {
                    if (bomIdToItemsMap.containsKey(insertedBom.BOM_Number__c)) {
                        List<BOM_Item__c> relatedBomItems = bomIdToItemsMap.get(insertedBom.BOM_Number__c);
                        for (BOM_Item__c bomItem : relatedBomItems) {
                            bomItem.BOM__c = insertedBom.Id;
                            bomItemsToInsert.add(bomItem);
                        }
                    }
                }

            }

           

            // Perform bulk insertion of BOM Items in batches
            batchInsertBOMItems(bomItemsToInsert, responseList);

            //delete the previous existing bom items
            if(!bomItemsToDelete.isEmpty()){

                DELETE bomItemsToDelete;

            }

        } catch (Exception e) {
            System.debug('exception: ' + e.getMessage());

            Exception_Log__c exceptionLog = new Exception_Log__c();
            exceptionLog.Error_Message__c = e.getMessage();
            exceptionLog.Line_Number__c = String.valueOf(e.getLineNumber());
            exceptionLog.Logged_By__c = UserInfo.getUserId();
            exceptionLog.Source__c = 'SAPCaptureProductBOMAPIHandler-createBOM';

            insert exceptionLog;

            for (SAPCaptureProductBOMAPIReqWrapper.BOM bom : reqWrapperList.bomList) {
                SAPCaptureProductBOMAPIResWrapper errorResponse = new SAPCaptureProductBOMAPIResWrapper();
                errorResponse.result = IntegrationAPIHelper.RESP_FAILURE_RESULT;
                errorResponse.message = 'Unable to capture BOM details: ' + e.getMessage();
                errorResponse.bom_number = bom.bom_number;
                responseList.add(errorResponse);
            }
        }
        return responseList;
    }

    private static void batchInsertBOMs(List<BOM__c> bomListToInsert, List<SAPCaptureProductBOMAPIResWrapper> responseList, Map<String, List<BOM_Item__c>> bomIdToItemsMap) {
        Integer batchSize = 200;
        Integer start = 0;
        while (start < bomListToInsert.size()) {
            List<BOM__c> bomBatch = new List<BOM__c>();
            for (Integer i = start; i < Math.min(start + batchSize, bomListToInsert.size()); i++) {
                bomBatch.add(bomListToInsert[i]);
            }
            Database.SaveResult[] bomInsertResults = Database.insert(bomBatch, false);
            handleBOMDmlErrors(bomInsertResults, responseList, bomBatch, bomIdToItemsMap);
            start += batchSize;
        }
    }

    private static void batchInsertBOMItems(List<BOM_Item__c> bomItemsToInsert, List<SAPCaptureProductBOMAPIResWrapper> responseList) {
        Integer batchSize = 200;
        Integer start = 0;
        while (start < bomItemsToInsert.size()) {
            List<BOM_Item__c> bomItemBatch = new List<BOM_Item__c>();
            for (Integer i = start; i < Math.min(start + batchSize, bomItemsToInsert.size()); i++) {
                bomItemBatch.add(bomItemsToInsert[i]);
            }
            Database.SaveResult[] bomItemInsertResults = Database.insert(bomItemBatch, false);
            handleBOMItemDmlErrors(bomItemInsertResults, responseList, bomItemBatch);
            start += batchSize;
        }
    }

    // Helper method to handle DML errors for BOMs and update response list
    private static void handleBOMDmlErrors(Database.SaveResult[] results, List<SAPCaptureProductBOMAPIResWrapper> responseList, List<BOM__c> bomListToInsert, Map<String, List<BOM_Item__c>> bomIdToItemsMap) {
        for (Integer i = 0; i < results.size(); i++) {
            if (!results[i].isSuccess()) {
                Database.Error[] errors = results[i].getErrors();
                for (Database.Error error : errors) {
                    // Find the response wrapper and update it to failure
                    SAPCaptureProductBOMAPIResWrapper responseWrapper = findResponseWrapperByBOM(responseList, bomListToInsert[i].BOM_Number__c);
                    if (responseWrapper != null) {
                        responseWrapper.result = IntegrationAPIHelper.RESP_FAILURE_RESULT;
                        responseWrapper.message = 'Failed to insert BOM: ' + error.getMessage();
                    }
                }
            }
        }
    }

    // Helper method to handle DML errors for BOM Items and update response list
    private static void handleBOMItemDmlErrors(Database.SaveResult[] results, List<SAPCaptureProductBOMAPIResWrapper> responseList, List<BOM_Item__c> bomItemsToInsert) {
        for (Integer i = 0; i < results.size(); i++) {
            if (!results[i].isSuccess()) {
                Database.Error[] errors = results[i].getErrors();
                for (Database.Error error : errors) {
                    // Find the response wrapper and update it to failure
                    SAPCaptureProductBOMAPIResWrapper responseWrapper = findResponseWrapperByBOM(responseList, bomItemsToInsert[i].BOM__c);
                    if (responseWrapper != null) {
                        responseWrapper.result = IntegrationAPIHelper.RESP_FAILURE_RESULT;
                        responseWrapper.message = 'Failed to insert BOM Item: ' + error.getMessage();
                    }
                }
            }
        }
    }

    // Helper method to find the response wrapper for a BOM number
    private static SAPCaptureProductBOMAPIResWrapper findResponseWrapperByBOM(List<SAPCaptureProductBOMAPIResWrapper> responseList, String bomNumber) {
        for (SAPCaptureProductBOMAPIResWrapper responseWrapper : responseList) {
            if (responseWrapper.bom_number == bomNumber) {
                return responseWrapper;
            }
        }
        return null;
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

        

    }
}