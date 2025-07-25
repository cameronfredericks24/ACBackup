@isTest
public class ProductServedSelectorTest {

    @testSetup
    static void setupTestData() {
        // Insert Trigger Settings to disable specific triggers for setup
        List<Trigger_Setting__c> settingList = new List<Trigger_Setting__c>();
        settingList.add(new Trigger_Setting__c(Name = 'AccountTrigger', IsActive__c = false));
        settingList.add(new Trigger_Setting__c(Name = 'ProductItemTrigger', IsActive__c = false));
        settingList.add(new Trigger_Setting__c(Name = 'AllTriggers', IsActive__c = false));
        insert settingList;

        System.debug('Inserted Trigger Settings to disable Account and ProductItem triggers.');

        try {
            // Create a Division__c record to use as a lookup reference
            Division__c testDivision = new Division__c(Name = 'Test Division');
            insert testDivision;
            Id testDivisionLookupId = testDivision.Id;
            System.debug('Inserted Division with Id: ' + testDivisionLookupId);

            // Insert Channel Partner record for testing
            Account testChannelPartner = new Account(
                Name = 'Test Channel Partner',
                Is_Active__c=false,
                CP_Service_Type__c = 'Service Type A'
            );
            insert testChannelPartner;
            System.debug('Inserted Channel Partner with Id: ' + testChannelPartner.Id);

            // Insert Product Family record with a reference to Division__c
            Product_Family__c testProductFamily = new Product_Family__c(
                Name = 'Test Product Family',
                Division_Lookup__c = testDivisionLookupId
            );
            insert testProductFamily;
            System.debug('Inserted Product Family with Id: ' + testProductFamily.Id);

            // Insert Product Served record linked to Channel Partner and Product Family
            Product_Served__c testProductServed = new Product_Served__c(
                Channel_Partner__c = testChannelPartner.Id,
                Product_Family__c = testProductFamily.Id
            );
            insert testProductServed;
            System.debug('Inserted Product Served with Id: ' + testProductServed.Id);
        } finally {
            // Reset trigger settings after setup if needed
            for (Trigger_Setting__c setting : settingList) {
                setting.IsActive__c = true;
            }
            update settingList;
        }
    }

    @isTest
    static void testGetProductServedByCPWithValidCPIds() {
        AccountTriggerHandler.TriggerDisabled = true;
        try {
            // Re-query to retrieve the Channel Partner ID
            Id testChannelPartnerId = [SELECT Id FROM Account WHERE Name = 'Test Channel Partner' LIMIT 1].Id;
            Set<Id> cpIds = new Set<Id>{ testChannelPartnerId };

            System.debug('Cp ids we are sending --------------------' + cpIds);

            Test.startTest();
            List<Product_Served__c> results = ProductServedSelector.getProductServedByCP(cpIds);
            Test.stopTest();

            System.debug('Retrieved Product Served records: ' + results);

            // Verify that we get exactly one record back
            System.assertEquals(1, results.size(), 'Expected exactly one Product_Served__c record.');
            
            // Verify the retrieved record's fields
            Product_Served__c resultRecord = results[0];
            System.assertEquals(testChannelPartnerId, resultRecord.Channel_Partner__c, 'Channel Partner ID should match the expected ID');
            System.assertEquals('Service Type A', resultRecord.Channel_Partner__r.CP_Service_Type__c, 'CP Service Type should match the expected value');
        } finally {
            AccountTriggerHandler.TriggerDisabled = false;
        }
    }

    @isTest
    static void testGetProductServedByCPWithEmptyCPIds() {
        AccountTriggerHandler.TriggerDisabled = true;
        try {
            Set<Id> cpIds = new Set<Id>();

            Test.startTest();
            List<Product_Served__c> results = ProductServedSelector.getProductServedByCP(cpIds);
            Test.stopTest();

            System.debug('Retrieved Product Served records with empty CP Ids: ' + results);

            System.assertEquals(0, results.size(), 'Expected no Product_Served__c records for empty CP Ids.');
        } finally {
            AccountTriggerHandler.TriggerDisabled = false;
        }
    }

    @isTest
    static void testGetProductServedByCPWithNonExistentCPIds() {
        AccountTriggerHandler.TriggerDisabled = true;
        try {
            Set<Id> cpIds = new Set<Id>{ '001000000000000AAA' };

            Test.startTest();
            List<Product_Served__c> results = ProductServedSelector.getProductServedByCP(cpIds);
            Test.stopTest();

            System.debug('Retrieved Product Served records with non-existent CP Ids: ' + results);

            System.assertEquals(0, results.size(), 'Expected no Product_Served__c records for non-existent CP Ids.');
        } finally {
            AccountTriggerHandler.TriggerDisabled = false;
        }
    }
}