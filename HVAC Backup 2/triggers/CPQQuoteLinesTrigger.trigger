trigger CPQQuoteLinesTrigger on SBQQ__QuoteLine__c (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
  TriggerDispatcher.run(new CPQQuoteLinesTriggerHandler(), 'CPQQuoteLinesTrigger');
}