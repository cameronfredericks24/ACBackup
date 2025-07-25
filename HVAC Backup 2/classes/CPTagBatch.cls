public class CPTagBatch implements Database.Batchable<SObject> {
    @testvisible private String dynamicQuery;
    public CPTagBatch(String dynamicQuery) {
        this.dynamicQuery = dynamicQuery;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(dynamicQuery);
    }

    // Execute method that processes each batch of records.
    public void execute(Database.BatchableContext BC, List<SObject> scope) {
        // Iterate through the records in the scope.
        for (SObject record : scope) {
            try {

                String recordId = (String) record.get('Id');
                String caseId = (String) record.get('caseId');

                String result = ScriptToTagCP.tagChannelPartner(caseId, new CreateCaseFormController.createCaseParameters(), recordId);

                System.debug('Tagging result: ' + result);
            } catch (Exception e) {
                System.debug('Error processing record: ' + e.getMessage());
            }
        }
    }

    // Finish method to handle any post-processing after batch execution.
    public void finish(Database.BatchableContext BC) {
        // Example: Send email notification or update records after batch completes.
        System.debug('Batch job completed.');
    }
}