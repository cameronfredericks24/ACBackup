trigger BulkProductRequestTrigger on Bulk_Product_Request__c (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {

    TriggerDispatcher.run(new BulkProductRequestTriggerHandler(), 'BulkProductRequestTrigger');

}