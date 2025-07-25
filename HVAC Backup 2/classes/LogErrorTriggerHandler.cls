public class LogErrorTriggerHandler {
    public static void onAfterInsert(List<Error_Log__e> newList){
        for(Error_Log__e errorNotification : newList){
            LogExceptionService.insertPlatformEventErrorLog(errorNotification);
        }
    }
}