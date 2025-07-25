@isTest
public class ContentVersionTriggerHandlerTest {

    @isTest
    static void testAfterInsert() {
         TestDataFactory.disableTriggers();
        Account account = TestDataFactory.createResidentialAccount('Chintan S', '6677889977');

        // Create a ContentVersion and ContentDocumentLink using the provided methods
        ContentVersion testVersion = TestDataFactory.createContentVersion('Test Document');
        ContentDocument testDocument = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :testVersion.Id LIMIT 1];
        TestDataFactory.createContentDocumentLink(testDocument.Id, account.Id);

        // Retrieve ContentVersion records for the test
        List<ContentVersion> contentVersions = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :testVersion.Id];

        // Simulate afterInsert logic
        Test.startTest();
        ContentVersionTriggerHandler handler = new ContentVersionTriggerHandler();
        handler.beforeInsert((List<sObject>)contentVersions);
        handler.afterInsert((List<sObject>)contentVersions, null);
        handler.beforeUpdate((List<sObject>)contentVersions, null, null, null);
        handler.afterUpdate((List<sObject>)contentVersions, null, null, null);
        Test.stopTest();

        // Assertions to validate logic
        Map<Id, ContentDocumentLink> documentLinkMap = ContentVersionTriggerHandler.getContentDocumentLinkMap(contentVersions);
        System.assert(!documentLinkMap.isEmpty(), 'ContentDocumentLink map should not be empty');
        System.assert(documentLinkMap.containsKey(testDocument.Id), 'ContentDocumentLink map should contain the test document');

        // Ensure the content is flagged for upload
        System.assertEquals(1, documentLinkMap.size(), 'Only one document should be linked');
         TestDataFactory.enableTriggers();
    }
}