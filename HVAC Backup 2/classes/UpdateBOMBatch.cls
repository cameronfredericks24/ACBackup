public class UpdateBOMBatch implements Database.Batchable<SObject> {

    // Query locator to get all BOM records with a non-null Product_Code__c
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Product_Code__c FROM BOM__c WHERE Product_Code__c != null');
    }

    // Execute method to process each batch of BOM records
    public void execute(Database.BatchableContext bc, List<BOM__c> bomLst) {
        // Create a map to hold Product2 records by ProductCode
        Map<String, Product2> prodCodeMap = new Map<String, Product2>();

        set<String> prodCodes = new set<String> ();

        for (BOM__c bom : bomLst) {
            prodCodes.add(bom.Product_Code__c);
        
        }

        // Query all Product2 records with a non-null ProductCode
        List<Product2> prodLst = [SELECT Id, ProductCode FROM Product2 WHERE ProductCode != null And ProductCode IN:prodCodes ];

        // Populate the map with Product2 records
        for (Product2 prod : prodLst) {
            prodCodeMap.put(prod.ProductCode, prod);
        }

        // Update the BOM records with the corresponding Product2 Id
        for (BOM__c bom : bomLst) {
            if (prodCodeMap.containsKey(bom.Product_Code__c)) {
                bom.Product__c = prodCodeMap.get(bom.Product_Code__c).Id;
            }
        }

        // Update the BOM records in the database
        if (!bomLst.isEmpty()) {
            update bomLst;
        }
    }

    // Finish method (optional) to perform any post-processing
    public void finish(Database.BatchableContext bc) {
        // Optional: Add any code you want to execute after the batch finishes
    }
}