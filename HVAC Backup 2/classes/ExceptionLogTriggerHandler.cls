public class ExceptionLogTriggerHandler {

    public static void sendEmailNotification(Map<Id,Exception_Log__c> errorMap){
        LogExceptionService.sendErrorLogEmailNotification(errorMap.values());
    }
    
}