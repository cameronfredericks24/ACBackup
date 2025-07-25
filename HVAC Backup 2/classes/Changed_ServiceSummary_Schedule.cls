global class Changed_ServiceSummary_Schedule implements Schedulable {
    
    // Execute at regular intervals
    global void execute(SchedulableContext ctx){
        String foldername='landing';
        Changed_ServiceSummary_batch batch = new Changed_ServiceSummary_batch(foldername);
        Database.executebatch(batch, 2000);
    }
}