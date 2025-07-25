@isTest
public class UniqueServiceAreaRoutingTest {
    
    @TestSetup
    static void setupTestData() {
        // List of trigger setting names to disable
        List<String> triggerObjectNames = new List<String>{
            'AllTriggers', 'AccountTrigger', 'AssetTrigger', 'CaseTrigger'
        };

        // Create and insert Trigger_Setting__c records with IsActive__c set to false to disable triggers
        List<Trigger_Setting__c> triggerSettings = new List<Trigger_Setting__c>();
        for (String objectString : triggerObjectNames) {
            Trigger_Setting__c triggerSetting = new Trigger_Setting__c(Name = objectString, IsActive__c = false);
            triggerSettings.add(triggerSetting);
        }
        insert triggerSettings;

        // Create a test Channel Partner with a specific CP_Code__c value
        Account testChannelPartner = new Account(
            Name = 'Test Channel Partner',
            Is_Active__c = false,
            CP_Code__c = 'CP123'
        );
        insert testChannelPartner;
        
        // Create a Branch record to associate with the Pincode
        Branch__c testBranch = new Branch__c(
            Name = 'Test Branch',
            Branch_Code__c = 'B001'
        );
        insert testBranch;
        
        // Create a Department record to associate with the Service Area Routing
        Department__c testDepartment = new Department__c(
            Name = 'Test Department',
            Department_Number__c = 'D001'
        );
        insert testDepartment;
        
        // Create a Pincode record that links to the Branch
        Pincode__c testPincode = new Pincode__c(
            Branch__c = testBranch.Id
        );
        insert testPincode;
        
        // Create a Service Area Routing record linked to the Channel Partner, Department, and Pincode
        Service_Area_Routing__c testServiceAreaRouting = new Service_Area_Routing__c(
            Channel_Partner__c = testChannelPartner.Id,
            Department__c = testDepartment.Id,
            Pincode__c = testPincode.Id
        );
        insert testServiceAreaRouting;
        
        // Create a Branch_Division__c record with unique Branch and Department fields
        Branch_Division__c testBranchDivision = new Branch_Division__c(
            Branch__c = testBranch.Id,
            Department__c = testDepartment.Id
        );
        insert testBranchDivision;
    }

    static void enableTriggers() {
        // List of trigger setting names to re-enable
        List<String> triggerObjectNames = new List<String>{
            'AllTriggers', 'AccountTrigger', 'AssetTrigger', 'CaseTrigger'
        };

        // Update Trigger_Setting__c records with IsActive__c set to true to re-enable triggers
        List<Trigger_Setting__c> triggerSettings = [SELECT Id, Name FROM Trigger_Setting__c WHERE Name IN :triggerObjectNames];
        for (Trigger_Setting__c triggerSetting : triggerSettings) {
            triggerSetting.IsActive__c = true;
        }
        update triggerSettings;
    }
    
    @isTest
    static void testFetchUniqueServiceAreaRoutingWithValidCPCode() {
        List<String> cpCodes = new List<String>{ 'CP123' };
        
        Test.startTest();
        List<List<Branch_Division__c>> result = UniqueServiceAreaRouting.fetchUniqueServiceAreaRouting(cpCodes);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(1, result.size(), 'Expected one list of Branch_Division__c records');
        
        
        enableTriggers();
    }

    @isTest
    static void testFetchUniqueServiceAreaRoutingWithInvalidCPCode() {
        List<String> cpCodes = new List<String>{ 'INVALID_CP_CODE' };
        
        Test.startTest();
        List<List<Branch_Division__c>> result = UniqueServiceAreaRouting.fetchUniqueServiceAreaRouting(cpCodes);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(1, result.size(), 'Result should contain an empty list for invalid CP code');
        System.assertEquals(0, result[0].size(), 'Expected no Branch_Division__c records for invalid CP code');
        
        enableTriggers();
    }

    @isTest
    static void testFetchUniqueServiceAreaRoutingWithEmptyInput() {
        List<String> cpCodes = new List<String>();
        
        Test.startTest();
        List<List<Branch_Division__c>> result = UniqueServiceAreaRouting.fetchUniqueServiceAreaRouting(cpCodes);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(0, result.size(), 'Expected an empty result for empty input');
        
        enableTriggers();
    }
    
    @isTest
    static void testFetchUniqueServiceAreaRoutingWithNullInput() {
        Test.startTest();
        List<List<Branch_Division__c>> result = UniqueServiceAreaRouting.fetchUniqueServiceAreaRouting(null);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(0, result.size(), 'Expected an empty result for null input');
        
        enableTriggers();
    }
}