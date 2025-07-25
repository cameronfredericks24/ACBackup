global class SchedulerBatchSalesQuotePDF implements Schedulable {
    global void execute(SchedulableContext sc) {
        BatchSalesQuotePDF batchJob = new BatchSalesQuotePDF();
        Database.executeBatch(batchJob);
    }
}
//Run every day at 9:45 AM:
//String cronExp = '0 45 9 * * ?';
/*String cronExp = '0 15 9 * * ?'; // Every day at 9:15 and insertion will doen at 9 AM 
SchedulerClass scheduler = new SchedulerClass();
String jobId = System.schedule('Daily Batch Job CPQ', cronExp, scheduler);
System.debug('Scheduled job with ID: ' + jobId);*/