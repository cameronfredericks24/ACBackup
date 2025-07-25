global class Changed_Bussiness_Entities_Schedule implements Schedulable {
    
    // Execute at regular intervals
    global void execute(SchedulableContext ctx){
        Date customStartDate = null; // Default value is null
        Date customEndDate = null;  
        String foldername='landing';// Default value is null
        Changed_Bussiness_Entities_Batch batch = new Changed_Bussiness_Entities_Batch(false,'', customStartDate, customEndDate, folderName);
        Database.executebatch(batch, 2000);
    }
}