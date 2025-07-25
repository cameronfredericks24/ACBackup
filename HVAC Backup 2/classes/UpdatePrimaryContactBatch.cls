public class UpdatePrimaryContactBatch implements Database.Batchable<SObject>, Database.Stateful {
    
    //String query = 'SELECT Id, Name, RecordType.DeveloperName,(SELECT Id,RecordTypeId, LastModifiedDate, Email, Phone FROM Contacts ORDER BY LastModifiedDate DESC Limit 1) FROM Account WHERE ID IN (Select AccountId from Contact) and Account.recordType.DeveloperName !=\'Channel_Partner\' and CreatedBy.Name=\'Data Migration User\' and Phone = null ORDER BY CreatedDate Desc limit 10000';
	//UpdatePrimaryContactBatch batch = new UpdatePrimaryContactBatch(query);
	//Database.executeBatch(batch, 200);
	
    private String query; 
    
    public UpdatePrimaryContactBatch(){}
    
    public UpdatePrimaryContactBatch(String query){
        this.query = query;
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        if(query != null){
            return Database.getQueryLocator(query);
        } 
        
        // Query accounts with their related contacts
        return Database.getQueryLocator([
            SELECT Id, Name, RecordType.DeveloperName,
                   (SELECT Id,RecordTypeId, LastModifiedDate, Email, Phone 
                    FROM Contacts 
                    ORDER BY LastModifiedDate DESC Limit 1) 
            FROM Account
            WHERE Account.recordType.DeveloperName !='Channel_Partner' and CreatedBy.Name='Data Migration User' and Phone = null ORDER BY CreatedDate Desc limit 10000
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Account> scope) {
        List<Account> accountsToUpdate = new List<Account>();
        Map<Id, Contact> latestContacts = new Map<Id, Contact>();
        List<Contact> contactsToUpdate = new List<Contact>();
        // Loop through accounts in the batch scope
        AccountTriggerHandler.TriggerDisabled = true;
        String contactBusinessRecordTypeId =Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Business_Contact').getRecordTypeId();
        String contactFamilyrecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Family_Contact').getRecordTypeId();
                
                
        for (Account acc : scope) {
            system.debug('acc.Contacts.size()'+acc.Contacts.size());
            system.debug('acc'+acc);
            if (acc.Contacts != null && !acc.Contacts.isEmpty()) {
                // Get the latest contact (Contacts are ordered by LastModifiedDate DESC)
                Contact latestContact = new Contact();
                latestContact.Id =  acc.Contacts[0].Id;
                latestContact.Is_Primary__c = true;

                if(acc.recordType.DeveloperName=='Commercial_Customer'){                   
                    latestContact.role__c='Business';
                    if( acc.Contacts[0].recordTypeId!=contactBusinessRecordTypeId){
                        latestContact.recordTypeId=contactBusinessRecordTypeId;
                    }
                    
                }else{
                    if( acc.Contacts[0].recordTypeId!=contactFamilyrecordTypeId){
                        latestContact.recordTypeId=contactFamilyrecordTypeId;
                    }
                }

                contactsToUpdate.add(latestContact);
                system.debug('contactsToUpdate.size()'+contactsToUpdate.size());

                acc.Email__c =  acc.Contacts[0].Email;
                acc.Phone =  acc.Contacts[0].Phone;

                // Add to the update list
                accountsToUpdate.add(acc);
               
            }
        }

        // Perform a bulk update
        if (!accountsToUpdate.isEmpty()) {
            database.update(accountsToUpdate,false);
        }
        if (!contactsToUpdate.isEmpty()) {
            database.update(contactsToUpdate,false);
        }
    }

    public void finish(Database.BatchableContext bc) {
        // Optionally log or send an email when the batch process completes
        System.debug('Batch process completed for updating primary contacts.');
    }
}