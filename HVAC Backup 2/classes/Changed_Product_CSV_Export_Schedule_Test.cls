@isTest
public class Changed_Product_CSV_Export_Schedule_Test {
    
    @isTest
    public static void execute(){
            // Create a cron expression for the test (run the job in 1 minute)
            String cronExpression = '0 0 0 15 8 ? 2025'; // Example cron expression
            
            // Schedule the batch job
            Test.startTest();
            Changed_Product_CSV_Export_Schedule scheduler = new Changed_Product_CSV_Export_Schedule();
            System.schedule('My Scheduled Batch Job', cronExpression, scheduler);
            Test.stopTest();
            


    }
    
}