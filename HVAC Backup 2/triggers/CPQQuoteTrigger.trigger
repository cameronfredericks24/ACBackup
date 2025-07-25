trigger CPQQuoteTrigger on SBQQ__Quote__c (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
  TriggerDispatcher.run(new CPQQuoteTriggerHandler(), 'CPQQuoteTrigger');
}