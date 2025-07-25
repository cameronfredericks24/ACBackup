global class ScheduleCaptureFGRAPI implements Schedulable {

    global void execute(SchedulableContext SC) {
        // Use the current date for fromDate and toDate
        // String todayDate = Date.today().format(); // Formatting date as a String

 Date yesterday = Date.today().addDays(-1);

        // Convert to DateTime and format as DD.MM.YYYY
        String yesterdayDate = DateTime.newInstance(yesterday, Time.newInstance(0, 0, 0, 0))
                                      .format('dd.MM.yyyy');
                        System.debug('yesterdayDate: ' + yesterdayDate);



        // Call the authrequest method with the current date as both fromDate and toDate
        // String response = SendFGRDetailsSAPAPI.authrequest(todayDate, todayDate);
        // System.debug('API Response: ' + response);

            // Call the queueable job to handle the callout
        System.enqueueJob(new FGRAPIQueueable(yesterdayDate, yesterdayDate));
    }
 
}