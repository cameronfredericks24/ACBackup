global class ScheduleUpdatePrimaryContactBatch implements Schedulable {
	
   global void execute(SchedulableContext sc) {
        String query = 'SELECT Id, Name, RecordType.DeveloperName,(SELECT Id,RecordTypeId, LastModifiedDate, Email, Phone FROM Contacts ORDER BY LastModifiedDate DESC Limit 1) FROM Account WHERE ID IN (Select AccountId from Contact) and Account.recordType.DeveloperName !=\'Channel_Partner\' and CreatedBy.Name=\'Data Migration User\' and Phone = null ORDER BY CreatedDate Desc limit 100000';
		UpdatePrimaryContactBatch batch = new UpdatePrimaryContactBatch(query);
		Database.executeBatch(batch, 2000);
    }

    
}