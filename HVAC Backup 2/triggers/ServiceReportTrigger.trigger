trigger ServiceReportTrigger on ServiceReport (before insert, after insert) {
    ServiceReportTriggerHelper.callTrigger(trigger.new);
}