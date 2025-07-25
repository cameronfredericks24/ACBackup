@isTest
public class OpportunityContractCategorySchedulerTest {

    @isTest
    static void testSchedulerExecution() {
        // Set up test data if needed
        // You can insert any necessary Opportunity or Contract records that the OpportunityContractCategoryBatch batch class might process.
        
        // Schedule the OpportunityContractCategoryScheduler job
        String scheduleName = 'TestOpportunityContractCategoryJob';
        String cronExpression = '0 0 0 * * ?'; // Schedules to run daily at midnight

        Test.startTest();
        
        // Schedule the job
        Id jobId = System.schedule(scheduleName, cronExpression, new OpportunityContractCategoryScheduler());

        // Retrieve the scheduled job to verify it was scheduled
        CronTrigger ct = [SELECT Id, CronExpression, State FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(cronExpression, ct.CronExpression, 'Cron expression should match');
        System.assertEquals('WAITING', ct.State, 'The job should be in the WAITING state initially');

        // Simulate the execution of the scheduled job
        Test.stopTest();
        
        // Verify that the OpportunityContractCategoryBatch batch job was executed
        // Since Test.stopTest() flushes async operations, we can check if the batch job ran
        List<AsyncApexJob> asyncJobs = [SELECT Id, JobType, Status FROM AsyncApexJob WHERE JobType = 'BatchApex'];
        System.debug('Async Batch Jobs: ' + asyncJobs);

        // Check that at least one batch job has been queued, processing, or completed
        Boolean batchExecuted = false;
        for (AsyncApexJob job : asyncJobs) {
            if (job.Status != 'Aborted') {  // We assume any non-aborted status indicates the batch executed
                batchExecuted = true;
                break;
            }
        }

        System.assert(batchExecuted, 'Batch job should have been executed in some form');
    }
}