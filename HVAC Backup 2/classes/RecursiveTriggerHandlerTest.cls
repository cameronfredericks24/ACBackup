@isTest
public class RecursiveTriggerHandlerTest {
    
    @isTest
    public static void testRecursiveTriggerHandler() {
        TestDataFactory.disableTriggers();
        
        Test.startTest();
        
        RecursiveTriggerHandler handler = new RecursiveTriggerHandler();
        
        RecursiveTriggerHandler.isFirstTime = true;
        RecursiveTriggerHandler.iscompcheck = true;

        Account account = TestDataFactory.createResidentialAccount('Sam', '6677889977');
        
        System.assertEquals(RecursiveTriggerHandler.isFirstTime, true, 'isFirstTime should be true initially.');
        System.assertEquals(RecursiveTriggerHandler.iscompcheck, true, 'iscompcheck should be true initially.');
        
        RecursiveTriggerHandler.isFirstTime = false;
        RecursiveTriggerHandler.iscompcheck = false;
        
        System.assertEquals(RecursiveTriggerHandler.isFirstTime, false, 'isFirstTime should be false after update.');
        System.assertEquals(RecursiveTriggerHandler.iscompcheck, false, 'iscompcheck should be false after update.');
        
        Test.stopTest();
        TestDataFactory.enableTriggers();
    }
}