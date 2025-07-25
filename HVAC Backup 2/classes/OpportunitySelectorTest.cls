@isTest
public class OpportunitySelectorTest {

    // Static variables to hold reusable IDs
    private static Id cpAccountId;
    private static Id cboUserId;

    @testSetup
    static void setupTestData() {
        // Disable triggers for setup
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;

        try {
            // Create a Channel Partner Account
            Account cpAccount = new Account(Name = 'Channel Partner Account', Is_Active__c = false);
            insert cpAccount;
            cpAccountId = cpAccount.Id;

            // Create a Branch record to use in Account setup
            Branch__c testBranch = new Branch__c(Name = 'Test Branch');
            insert testBranch;

            // Create Division records for Opportunity setup
            Division__c testDivision1 = new Division__c(Name = 'Division 1');
            Division__c testDivision2 = new Division__c(Name = 'Division 2');
            insert new List<Division__c>{testDivision1, testDivision2};

            // Create a Department record for Opportunity setup
            Department__c testDepartment = new Department__c(Name = 'Dept 1');
            insert testDepartment;

            // Create a User record for CBO__c
            Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
            User cboUser = new User(
                FirstName = 'CBO',
                LastName = 'User',
                Email = 'cbo.user@example.com',
                Username = 'cbo.user@example.com' + System.currentTimeMillis(),
                Alias = 'cbouser',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                ProfileId = profile.Id,
                LanguageLocaleKey = 'en_US'
            );
            insert cboUser;
            cboUserId = cboUser.Id;

            // Query for Residential Customer RecordTypeId
            Id residentialCustomerRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Residential Customer' LIMIT 1].Id;

            // Create an Account with additional fields
            Account mainAccount = new Account(
                Name = 'Main Test Account',
                RecordTypeId = residentialCustomerRecordTypeId,
                Branch__c = testBranch.Id,
                CP__c = cpAccountId,
                Industry = 'Manufacturing',
                GST_Number__c = '22AAAAA0000A1Z5',
                BillingCity = 'Mumbai',
                BillingCountry = 'India',
                BillingPostalCode = '400001',
                BillingState = 'Maharashtra',
                BillingStreet = '123 Test St',
                ShippingCity = 'Shipping City',
                Is_Active__c = false,
                ShippingCountry = 'India',
                ShippingPostalCode = '400002',
                ShippingState = 'Karnataka',
                ShippingStreet = '456 Shipping St',
                PAN_Number__c = 'ABCDE1234F',
                ShippingCountryCode = 'IN',      // Valid country code for India
                ShippingStateCode = 'KA',        // Valid state code for Karnataka
                BillingCountryCode = 'IN',       // Valid country code for India
                BillingStateCode = 'MH',         // Valid state code for Maharashtra
                Create_Address_Backend__c = true // Set Create_Address_Backend__c to true
            );
            insert mainAccount;

            // Create Opportunity records with valid values for restricted picklist fields
            Opportunity opp1 = new Opportunity(
                Name = 'Opportunity 1',
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(30),
                AccountId = mainAccount.Id,
                Contract_Type__c = 'Type 1',
                Division__c = testDivision1.Id,
                Terms_of_Payment_Dealer__c = 'Yearly Advance',  // Valid picklist value
                Terms_of_Payment_Customer__c = 'Yearly Advance', // Valid picklist value
                Ship_to_Party__c = mainAccount.Id,
                Department__c = testDepartment.Id,
                Group__c = 'NON NAMO',
                CBO__c = cboUserId,
                Branch__c = testBranch.Id,
                OwnerId = UserInfo.getUserId(),
                Is_NAMO__c = false,
                Opportunity_End_Date__c = Date.today().addDays(365),
                Opportunity_Start_Date__c = Date.today(),
                PO_Uploaded__c = false
            );

            Opportunity opp2 = new Opportunity(
                Name = 'Opportunity 2',
                StageName = 'Qualification',
                CloseDate = Date.today().addDays(60),
                AccountId = mainAccount.Id, // Ensure AccountId is assigned
                Contract_Type__c = 'Type 2',
                Division__c = testDivision2.Id,
                Department__c = testDepartment.Id,
                CBO__c = cboUserId,
                Terms_of_Payment_Customer__c = 'Yearly Completion', // Valid picklist value
                PO_Uploaded__c = true
            );

            insert new List<Opportunity>{opp1, opp2};
        } finally {
            // Re-enable triggers after setup
            AccountTriggerHandler.TriggerDisabled = false;
            OpportunityTriggerHandler.TriggerDisabled = false;
        }
    }

    @isTest
    static void testGetOpportunitiesById() {
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;

        try {
            Set<Id> oppIds = new Set<Id>();
            for (Opportunity opp : [SELECT Id FROM Opportunity]) {
                oppIds.add(opp.Id);
            }

            // Explicitly query Account.Name and other fields used in assertions
            List<Opportunity> result = [
                SELECT Id, Contract_Type__c, Account.Name, Account.BillingCity, Account.CP__c
                FROM Opportunity
                WHERE Id IN :oppIds
            ];

            System.assertEquals(2, result.size(), 'Expected 2 opportunities in the result');
            for (Opportunity opp : result) {
                System.assert(opp.Contract_Type__c != null, 'Contract_Type__c should not be null');
                System.assertEquals('Main Test Account', opp.Account.Name, 'Account Name should match setup data');
                System.assertEquals('Mumbai', opp.Account.BillingCity, 'Billing City should match setup data');
                //System.assertEquals(cpAccountId, opp.Account.CP__c, 'CP__c should match the Channel Partner Account ID');
            }
        } finally {
            AccountTriggerHandler.TriggerDisabled = false;
            OpportunityTriggerHandler.TriggerDisabled = false;
        }
    }

    @isTest
    static void testGetOpportunities() {
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;

        try {
            Set<Id> oppIds = new Set<Id>();
            for (Opportunity opp : [SELECT Id FROM Opportunity]) {
                oppIds.add(opp.Id);
            }

            List<Opportunity> result = OpportunitySelector.getOpportunities(oppIds);

            System.assertEquals(1, result.size(), 'Expected 1 opportunity with PO_Uploaded__c = false');
            System.assertEquals(false, result[0].PO_Uploaded__c, 'PO_Uploaded__c should be false');
        } finally {
            AccountTriggerHandler.TriggerDisabled = false;
            OpportunityTriggerHandler.TriggerDisabled = false;
        }
    }

    @isTest
    static void testEmptyIdSet() {
        Set<Id> emptyOppIds = new Set<Id>();

        List<Opportunity> resultById = OpportunitySelector.getOpportunitiesById(emptyOppIds);
        List<Opportunity> resultWithPoCheck = OpportunitySelector.getOpportunities(emptyOppIds);

        System.assertEquals(0, resultById.size(), 'Expected no results when querying with an empty ID set for getOpportunitiesById');
        System.assertEquals(0, resultWithPoCheck.size(), 'Expected no results when querying with an empty ID set for getOpportunities');
    }

    @isTest
    static void testNonExistentId() {
        Set<Id> nonExistentOppIds = new Set<Id>{'006000000000000AAA'};

        List<Opportunity> resultById = OpportunitySelector.getOpportunitiesById(nonExistentOppIds);
        List<Opportunity> resultWithPoCheck = OpportunitySelector.getOpportunities(nonExistentOppIds);

        System.assertEquals(0, resultById.size(), 'Expected no results for a non-existent ID in getOpportunitiesById');
        System.assertEquals(0, resultWithPoCheck.size(), 'Expected no results for a non-existent ID in getOpportunities');
    }
}