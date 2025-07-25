/*
@Author : Sumukha N S
@CreatedDate : 12th Apr 2024
@Description : ContentDocument Object Trigger.
*/
trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {

    TriggerDispatcher.run(new ContentDocumentLinkTriggerHandler(), 'ContentDocumentLinkTrigger');

}