public class ServiceReportBatch implements Database.Batchable<Id>, Database.AllowsCallouts {

    Set<Id> saLst;

    public ServiceReportBatch(Set<Id> serviceAppointmentIds) {
        this.saLst = serviceAppointmentIds;
    }

    // The 'start' method that returns an Iterable of Ids
    public Iterable<Id> start(Database.BatchableContext bc) {
        return saLst; // Return the set of Service Appointment IDs as an iterable
    }

    // The 'execute' method where the logic will be performed on each batch of Ids
    public void execute(Database.BatchableContext bc, List<Id> scope) {
        for (Id serviceAppointmentId : scope) {
            System.debug('Executing for ServiceAppointment: ' + serviceAppointmentId);
            ServiceReportHelper.createServiceReport(serviceAppointmentId);
        }
    }

    // Optional 'finish' method for post-processing
    public void finish(Database.BatchableContext bc) {
        System.debug('Batch processing finished.');
    }
}