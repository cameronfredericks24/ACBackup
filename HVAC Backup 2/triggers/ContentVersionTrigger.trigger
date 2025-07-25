/*
@Author : Sumukha N S
@CreatedDate : 24th Apr 2024
@Description : ContentDocument Object Trigger.
*/
trigger ContentVersionTrigger on ContentVersion (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {

    //TriggerDispatcher.run(new ContentVersionTriggerHandler(), 'ContentVersionTrigger');



}