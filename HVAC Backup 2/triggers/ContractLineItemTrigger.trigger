trigger ContractLineItemTrigger on ContractLineItem (after insert,after update) {
  triggerDispatcher.run(new ContractLineItemTriggerHandler(), 'ContractLineItemTrigger');
}