/*
@Author : Kunal Nadkarni
@CreatedDate : 17th Jan 2024
@Description : Custom Message Exception Class.
*/
public class CustomMessageException extends Exception {
    public static void showMessage(){
        Integer i = 0;
        i++;
        System.debug('test: '+i);
    }
    
}