global class Changed_User_Schedule implements Schedulable {
    
    // Execute at regular intervals
    global void execute(SchedulableContext ctx){
        Date customStartDate = null; // Default value is null
        Date customEndDate = null;   // Default value is null
        String foldername='landing';
        Changed_User_Batch batch = new Changed_User_Batch(false,'', customStartDate, customEndDate, foldername);
        Database.executebatch(batch, 2000);
    }
}