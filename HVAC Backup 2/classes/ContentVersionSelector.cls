public with sharing class ContentVersionSelector {

    /*
@Author : Mamta S
@CreatedDate : 18 April 2024
@Description : Fetch Content Version record based on Id
*/
    public static List<ContentVersion> getContentVersionsByIds(List<Id> contentVersionIds) {
        return [SELECT Id, ContentDocumentId, Title FROM ContentVersion WHERE Id IN :contentVersionIds];
    }
}