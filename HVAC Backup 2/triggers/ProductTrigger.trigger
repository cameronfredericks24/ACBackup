trigger ProductTrigger on Product2 (before insert, after insert, before update, after update, before delete, after delete, after unDelete)  {
	TriggerDispatcher.run(new ProductTriggerHandler(), 'ProductTrigger'); 
}