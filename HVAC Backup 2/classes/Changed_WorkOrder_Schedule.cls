global class Changed_WorkOrder_Schedule implements Schedulable {
    
    // Execute at regular intervals
    global void execute(SchedulableContext ctx){
        // Instantiate the Changed_Service_Ticket_Batch with customStartDate and customEndDate (both default to null)
        Date customStartDate = null; // Default value is null
        Date customEndDate = null;   // Default value is null
        String foldername='landing';
        Changed_WorkOrder_Batch batch = new Changed_WorkOrder_Batch(false,'', customStartDate, customEndDate,foldername);
        Database.executebatch(batch, 2000);
    }
}