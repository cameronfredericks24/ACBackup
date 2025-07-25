@IsTest
private class ContentDistributionControllerTest {

    @TestSetup
    static void setupTestData() {
        // Disable specific triggers for setup
        List<String> triggerObjectNames = new List<String>{
            'AllTriggers', 'AccountTrigger', 'AssetTrigger', 'CaseTrigger', 'ContentVersionTrigger', 'ContentDocumentLinkTrigger'
        };

        List<Trigger_Setting__c> triggerSettings = new List<Trigger_Setting__c>();
        for (String objectString : triggerObjectNames) {
            triggerSettings.add(new Trigger_Setting__c(Name = objectString, IsActive__c = false));
        }
        insert triggerSettings;
        System.debug('Trigger settings created and inserted: ' + triggerSettings);

        // Create a ContentVersion record to generate the ContentDocument
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Image',
            VersionData = Blob.valueOf('Test Content'),
            PathOnClient = 'testImage.png'
        );
        insert contentVersion;
        System.debug('Test ContentVersion inserted: ' + contentVersion);

        // Re-enable triggers after setup
        for (Trigger_Setting__c triggerSetting : triggerSettings) {
            triggerSetting.IsActive__c = true;
        }
        update triggerSettings;
        System.debug('Trigger settings re-enabled after setup.');
    }

    @IsTest
    static void testGetPublicImageUrl() {
        // Disable specific triggers for this test
        List<String> triggerObjectNames = new List<String>{
            'AllTriggers', 'ContentVersionTrigger', 'ContentDocumentLinkTrigger'
        };

        List<Trigger_Setting__c> triggerSettings = new List<Trigger_Setting__c>();
        for (String objectString : triggerObjectNames) {
            triggerSettings.add(new Trigger_Setting__c(Name = objectString, IsActive__c = false));
        }
        insert triggerSettings;
        System.debug('Trigger settings temporarily disabled for testGetPublicImageUrl.');

        // Query for ContentDocumentId directly within this method
        ContentVersion contentVersionInserted = [
            SELECT ContentDocumentId FROM ContentVersion LIMIT 1
        ];
        Id contentDocumentId = contentVersionInserted.ContentDocumentId;
        System.debug('Re-queried ContentDocumentId in testGetPublicImageUrl: ' + contentDocumentId);

        // Assert ContentDocumentId is accessible
        System.assertNotEquals(null, contentDocumentId, 'ContentDocumentId should not be null in testGetPublicImageUrl.');

        // Test the `getPublicImageUrl` method
        Test.startTest();
        String publicImageUrl = ContentDistributionController.getPublicImageUrl(contentDocumentId);
        Test.stopTest();
        System.debug('Public Image URL returned from getPublicImageUrl: ' + publicImageUrl);

        // Assert that the URL is not null (without checking ConnectApi-dependent details)
        System.assertNotEquals(null, publicImageUrl, 'Public Image URL should not be null');

        // Re-enable triggers after this test
        for (Trigger_Setting__c triggerSetting : triggerSettings) {
            triggerSetting.IsActive__c = true;
        }
        update triggerSettings;
        System.debug('Trigger settings re-enabled after testGetPublicImageUrl.');
    }

    @IsTest
    static void testDeleteFile() {
        // Disable specific triggers for this test
        List<String> triggerObjectNames = new List<String>{ 'AllTriggers', 'ContentDocumentTrigger', 'ContentDocumentLinkTrigger' };
        List<Trigger_Setting__c> triggerSettings = new List<Trigger_Setting__c>();
        for (String objectString : triggerObjectNames) {
            triggerSettings.add(new Trigger_Setting__c(Name = objectString, IsActive__c = false));
        }
        insert triggerSettings;
        System.debug('Trigger settings temporarily disabled for testDeleteFile.');

        // Query for ContentDocumentId directly within this method
        ContentVersion contentVersionInserted = [
            SELECT ContentDocumentId FROM ContentVersion LIMIT 1
        ];
        Id contentDocumentId = contentVersionInserted.ContentDocumentId;
        System.debug('Re-queried ContentDocumentId in testDeleteFile: ' + contentDocumentId);

        // Assert ContentDocumentId is accessible
        System.assertNotEquals(null, contentDocumentId, 'ContentDocumentId should not be null in testDeleteFile.');

        // Test the `deleteFile` method
        Test.startTest();
        ContentDistributionController.deleteFile(contentDocumentId);
        Test.stopTest();
        System.debug('ContentDocument with ID ' + contentDocumentId + ' deleted in deleteFile method.');

        // Verify that the ContentDocument was deleted
        Integer countDeleted = [SELECT COUNT() FROM ContentDocument WHERE Id = :contentDocumentId];
        System.assertEquals(0, countDeleted, 'ContentDocument should be deleted in testDeleteFile.');

        // Re-enable triggers after this test
        for (Trigger_Setting__c triggerSetting : triggerSettings) {
            triggerSetting.IsActive__c = true;
        }
        update triggerSettings;
        System.debug('Trigger settings re-enabled after testDeleteFile.');
    }
}