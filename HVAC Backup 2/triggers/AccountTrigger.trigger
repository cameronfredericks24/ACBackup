/*
@Author : Kunal Nadkarni
@CreatedDate : 16th Jan 2024
@Description : Account Object Trigger.
*/
trigger AccountTrigger on Account(before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    TriggerDispatcher.run(new AccountTriggerHandler(), 'AccountTrigger');
}