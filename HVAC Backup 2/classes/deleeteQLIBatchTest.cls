@isTest
public class deleeteQLIBatchTest {
@isTest
    static void testRetention3() {
        Test.startTest();
        deleeteQLIBatch.coveragemethod2();
        deleeteQLIBatch batch = new deleeteQLIBatch(false,'');
        Database.executeBatch(batch, 100);
        
        Test.stopTest();      
    }  
}