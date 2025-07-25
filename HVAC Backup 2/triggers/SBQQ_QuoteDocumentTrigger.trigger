trigger SBQQ_QuoteDocumentTrigger on SBQQ__QuoteDocument__c (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {

    TriggerDispatcher.run(new SBQQ_QuoteDocumentTriggerHandler(), 'SBQQ_QuoteDocumentTrigger');

}