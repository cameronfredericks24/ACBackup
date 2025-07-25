public class ServiceContractRenewalQueueable implements Queueable, Database.AllowsCallouts {
    private List<OpportunityLineItem> records;
    
    public ServiceContractRenewalQueueable(List<OpportunityLineItem> records) {
        this.records = records;
    }

    public void execute(QueueableContext context) {
        System.debug('DML records: ' + records);
        if (!records.isEmpty()) {
            try {
                insert records;
            } catch (DmlException e) {
                System.debug('DML Error: ' + e.getMessage());
            }
        }
    }
}