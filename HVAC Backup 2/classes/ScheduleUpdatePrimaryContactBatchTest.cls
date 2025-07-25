@isTest
public class ScheduleUpdatePrimaryContactBatchTest {
    @isTest
    public static void runScheduleMethos(){
        ScheduleUpdatePrimaryContactBatch schedulable = new ScheduleUpdatePrimaryContactBatch();
        // Schedule the job
        String jobId = System.schedule('Test Schedule', '0 0 12 * * ?', schedulable);

        // Assert the job is scheduled
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                           FROM CronTrigger WHERE Id = :jobId];
    }  

}