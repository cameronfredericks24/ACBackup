@isTest
public class BatchForDeleteSMSLogsTest {

      @isTest static void testBatchDelete() {
      
            SMS_Log__c log = new SMS_Log__c();
            log.Template_Name__c = 'Test';
            insert log;
        
        Test.startTest();
        BatchForDeleteSMSLogs batch = new BatchForDeleteSMSLogs();
        Database.executeBatch(batch, 10);
        Test.stopTest();
        
       
    }
}