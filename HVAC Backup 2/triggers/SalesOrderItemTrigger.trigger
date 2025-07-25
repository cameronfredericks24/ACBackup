trigger SalesOrderItemTrigger on Sales_Order_Item__c ( before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
  
    TriggerDispatcher.run(new SalesOrderItemTriggerHandler(), 'SalesOrderItemTrigger');
}