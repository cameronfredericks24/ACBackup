global class UpdateProductCodeBatch implements Database.Batchable<SObject>, Database.Stateful {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Query to retrieve Product2 records where Code__c is not null
        return Database.getQueryLocator('SELECT Id, Code__c FROM Product2 WHERE Code__c != null');
    }

    global void execute(Database.BatchableContext bc, List<Product2> scope) {
        // Iterate through the list of Product2 records
        for (Product2 product : scope) {
            product.ProductCode = product.Code__c;
        }
        
        // Perform the bulk update
        update scope;
    }
    
    global void finish(Database.BatchableContext bc) {
        // Optionally, send a confirmation email or log completion of the batch job
        System.debug('Batch job completed successfully.');
    }
}