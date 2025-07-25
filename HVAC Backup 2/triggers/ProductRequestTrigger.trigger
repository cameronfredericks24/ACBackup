trigger ProductRequestTrigger on ProductRequest ( before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    TriggerDispatcher.run(new ProductRequestTriggerHandler(), 'ProductRequestTrigger');
  }