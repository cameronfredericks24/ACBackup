public without sharing class RequestedMaterialsController {
    @AuraEnabled(cacheable=false)
    public static List<ProductRequest> getProductRequests(Id workOrderId) {
        // Check if workOrderId is not null
        System.debug('Entering getProductRequests method.');
        if (workOrderId == null) {
            System.debug('WorkOrderId is null.');
            throw new AuraHandledException('WorkOrderId cannot be null.');
        }

        try {
            // Query ProductRequest records related to the given WorkOrderId
            System.debug('Querying ProductRequest records for WorkOrderId: ' + workOrderId);
            List<ProductRequest> productRequests = [
                SELECT Id, Status, Quantity__c, Product__r.Name, Material_Code__c,ProductRequestNumber, Defective_Part_Serial_Number__c,is_Product_Consumed__c
                FROM ProductRequest
                WHERE WorkOrderId = :workOrderId AND is_Product_Consumed__c = false
            ];
            System.debug('ProductRequest query result: ' + productRequests);
            return productRequests;
        } catch (Exception e) {
            // Handle exceptions and provide a user-friendly error message
            System.debug('Exception occurred: ' + e.getMessage());
            throw new AuraHandledException('An error occurred while retrieving product requests: ' + e.getMessage());
        }
    }
     @AuraEnabled(cacheable=true)
    public static List<ProductRequest> getSubmittedProductRequests(Id workOrderId) {
         return [SELECT Id, Status, Quantity__c, Product__r.Name FROM ProductRequest WHERE WorkOrderId = :workOrderId AND Status = 'Submitted'];
    }

    @AuraEnabled
    public static void createProductConsumedRecords(Id workOrderId,Id productRequestId, string productid, string defectiveSerialNumber, string newbarcode) {
        // Check if workOrderId is not null
        System.debug('Entering createProductConsumedRecords method.');
        if (workOrderId == null) {
            System.debug('WorkOrderId is null.');
            throw new AuraHandledException('WorkOrderId cannot be null.');
        }

        try {
            // Query ProductRequest records related to the given WorkOrderId
            System.debug('Querying ProductRequest records for WorkOrderId: ' + workOrderId);
            List<ProductRequest> productRequests = [
                SELECT Id, Status, Quantity__c, Product__c, Material_Code__c, WorkOrderId, WorkOrderLineItemId, Product_Item__c, CP__c
                FROM ProductRequest
                WHERE WorkOrderId = :workOrderId AND ID = :productRequestId
            ];
            System.debug('ProductRequest query result: ' + productRequests);

            // Create ProductConsumed records
            List<ProductConsumed> productConsumedRecords = new List<ProductConsumed>();
             List<Part_Replace__c> partReplaceRecords = new List<Part_Replace__c>();
            for (ProductRequest pr : productRequests) {
                System.debug('Processing ProductRequest: ' + pr);
                ProductConsumed pc = new ProductConsumed();
                pc.WorkOrderId = pr.WorkOrderId;
                pc.WorkOrderLineItemId = pr.WorkOrderLineItemId;
                pc.QuantityConsumed = pr.Quantity__c;
                pc.ProductItemId = pr.Product_Item__c;
                pc.Account__c = pr.CP__c;
                //pc.Product2Id = pr.Product__c;
                // Add any other necessary fields here

                System.debug('Adding ProductConsumed record: ' + pc);
                productConsumedRecords.add(pc);
                
              // Create Part_Replace__c record
            Part_Replace__c newPartReplace = new Part_Replace__c();
            newPartReplace.Service_Ticket__c = pr.WorkOrderId;
            newPartReplace.Service_Ticket_Line_Item__c = pr.WorkOrderLineItemId;
            newPartReplace.Spare__c = pr.Product__c; 
            newPartReplace.Old_Serial_Number__c = defectiveSerialNumber; 
            newPartReplace.New_Serial_Number__c = newbarcode; 
        

            System.debug('Adding Part_Replace__c record: ' + newPartReplace);
            partReplaceRecords.add(newPartReplace);
            }

            // Insert ProductConsumed records
            if (!productConsumedRecords.isEmpty()) {
                System.debug('Inserting ProductConsumed records: ' + productConsumedRecords);
                insert productConsumedRecords;
            }
        } catch (Exception e) {
            // Handle exceptions and provide a user-friendly error message
            System.debug('Exception occurred: ' + e.getMessage());
            throw new AuraHandledException('An error occurred while creating product consumed records: ' + e.getMessage());
        }
    }
}