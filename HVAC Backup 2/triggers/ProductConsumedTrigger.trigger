trigger ProductConsumedTrigger on ProductConsumed (before insert,after insert, before update, after update, before delete, after delete, after unDelete) {
     TriggerDispatcher.run(new ProductConsumedTriggerHandler(), 'ProductConsumedTrigger');
}