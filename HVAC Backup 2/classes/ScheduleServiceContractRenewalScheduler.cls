public class ScheduleServiceContractRenewalScheduler {
    public static void scheduleBatch() {
        String cronExpression = '0 10 10 * * ?'; // Runs every day at 9 AM
        SchedulerServiceContractRenewal scheduler = new SchedulerServiceContractRenewal();
        System.schedule('AMC Renewal', cronExpression, scheduler);
    }
}
//Run every day at 9:45 AM:
//String cronExp = '0 45 9 * * ?';
/*String cronExp = '0 0 9 * * ?'; // Every day  insertion will doen at 9 AM 
SchedulerClass scheduler = new SchedulerClass();
String jobId = System.schedule('Daily Batch Job CPQ', cronExp, scheduler);
System.debug('Scheduled job with ID: ' + jobId);*/