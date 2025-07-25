/**
* @File Name : UserTerritoryQueueable.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : February 11, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | February 11, 2025 |   | Initial Version
**/

public class UserTerritoryQueueable implements Queueable {
    
    private Set<Id> userIds;

    public UserTerritoryQueueable(Set<Id> userIds) {
        this.userIds = userIds;
    }

    public void execute(QueueableContext context) {
        List<FSL__User_Territory__c> userTerritories = new List<FSL__User_Territory__c>();

        try {
            List<User> users;

            if (userIds != null && !userIds.isEmpty()) {
                users = [SELECT Id, Contact.AccountId, Profile.Name, ContactId 
                         FROM User 
                         WHERE Id IN :userIds 
                         AND Id NOT IN (SELECT FSL__User__c FROM FSL__User_Territory__c)
                         AND Profile.Name LIKE '%Channel%'];
            } else {
                users = [SELECT Id, Contact.AccountId, Profile.Name, ContactId 
                         FROM User 
                         WHERE Id NOT IN (SELECT FSL__User__c FROM FSL__User_Territory__c)
                         AND Profile.Name LIKE '%Channel%' 
                         AND CreatedDate = TODAY];
            }


            if (!users.isEmpty()) {
                Set<Id> accountIds = new Set<Id>();
                for (User usr : users) {
                    if (usr.Contact != null && usr.Contact.AccountId != null) {
                        accountIds.add(usr.Contact.AccountId);
                    }
                }

                if (!accountIds.isEmpty()) {
                    Map<Id, ServiceTerritory> accountTerritoryMap = new Map<Id, ServiceTerritory>();
                    for (ServiceTerritory st : [SELECT Id, Channel_Partner_Account__c FROM ServiceTerritory WHERE Channel_Partner_Account__c IN :accountIds]) {
                        accountTerritoryMap.put(st.Channel_Partner_Account__c, st);
                    }

                    for (User usr : users) {
                        if (usr.ContactId != null && accountTerritoryMap.containsKey(usr.Contact.AccountId)) {
                            userTerritories.add(new FSL__User_Territory__c(
                                FSL__User__c = usr.Id,
                                FSL__ServiceTerritory__c = accountTerritoryMap.get(usr.Contact.AccountId).Id
                            ));
                        }
                    }

                    if (!userTerritories.isEmpty()) {
                        insert userTerritories;
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());

            Exception_Log__c exceptionLog = new Exception_Log__c();
            exceptionLog.Error_Message__c = e.getMessage();
            exceptionLog.Line_Number__c = String.valueOf(e.getLineNumber());
            exceptionLog.Logged_By__c = UserInfo.getUserId();
            exceptionLog.Source__c = 'execute-UserTerritoryQueueable';
            //insert exceptionLog;
        }
    }
}