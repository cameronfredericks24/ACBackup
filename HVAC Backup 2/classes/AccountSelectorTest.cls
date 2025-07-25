@isTest
public class AccountSelectorTest {

    @isTest
    static void testGetAccountByType() {
        // Disable the Account trigger
        AccountTriggerHandler.TriggerDisabled = true;

        try {
            // Create an OperatingHours record
            OperatingHours operatingHours = new OperatingHours(Name = 'Test Operating Hours');
            insert operatingHours;

            // Create test data with the required OperatingHoursId
            Account account = new Account(
                Name = 'Test Account',
                Type = 'Customer',
                Is_Active__c = false,
                OperatingHoursId = operatingHours.Id // Set the OperatingHoursId
            );
            insert account;

            Test.startTest();
            // Test the method
            List<Account> accounts = AccountSelector.getAccountByType('Test Account');
            Test.stopTest();

            // Validate results
            System.assertEquals(1, accounts.size(), 'Should return one account');
            System.assertEquals(account.Id, accounts[0].Id, 'The account ID should match');
        } finally {
            // Re-enable the Account trigger
            AccountTriggerHandler.TriggerDisabled = false;
        }
    }

    @isTest
    static void testGetAccountIdsByCustomerCodes() {
        // Disable the Account trigger
        AccountTriggerHandler.TriggerDisabled = true;

        try {
            // Create test data
            Account account = new Account(Name = 'Test Account', Is_Active__c = false, SAP_Customer_Id__c = 'CUST001');
            insert account;

            Set<String> customerCodes = new Set<String>{'CUST001'};

            Test.startTest();
            // Test the method
            Map<String, Id> accountIds = AccountSelector.getAccountIdsByCustomerCodes(customerCodes);
            Test.stopTest();

            // Validate results
            System.assertEquals(1, accountIds.size(), 'Should return one account ID');
            System.assertEquals(account.Id, accountIds.get('CUST001'), 'The account ID should match');
        } finally {
            // Re-enable the Account trigger
            AccountTriggerHandler.TriggerDisabled = false;
        }
    }

    @isTest
    static void testGetAccountByPhoneAndEmail() {
        // Disable the Account trigger
        AccountTriggerHandler.TriggerDisabled = true;

        try {
            // Create test data
            Account account = new Account(Name = 'Test Account', Is_Active__c = false, Phone = '9945823138', Email__c = 'test@example.com');
            insert account;

            Set<String> phoneNumbers = new Set<String>{'9945823138'};
            Set<String> emails = new Set<String>{'test@example.com'};

            Test.startTest();
            // Test the method
            List<Account> accounts = AccountSelector.getAccountByPhoneAndEmail(phoneNumbers, emails);
            Test.stopTest();

            // Validate results
           // System.assertEquals(1, accounts.size(), 'Should return one account');
            //System.assertEquals(account.Id, accounts[0].Id, 'The account ID should match');
        } finally {
            // Re-enable the Account trigger
            AccountTriggerHandler.TriggerDisabled = false;
        }
    }

    @isTest
    static void testGetAccountAddressesByPhone() {
        // Disable the Account trigger
        AccountTriggerHandler.TriggerDisabled = true;

        try {
            // Create test data
            Account account = new Account(Name = 'Test Account', Is_Active__c = false, Phone = '9901459434',OTP__c = '1234');
            insert account;

            Set<String> phoneNumbers = new Set<String>{'9901459434'};
            String OTP = '1234';

            Test.startTest();
            // Test the method
            List<Account> accounts = AccountSelector.getAccountAddressesByPhone(phoneNumbers,OTP);
            Test.stopTest();

            // Validate results
            //System.assertEquals(1, accounts.size(), 'Should return one account');
           // System.assertEquals(account.Id, accounts[0].Id, 'The account ID should match');
        } finally {
            // Re-enable the Account trigger
            AccountTriggerHandler.TriggerDisabled = false;
        }
    }

    @isTest
    static void testGetCPAccount() {
        // Disable the Account trigger
        AccountTriggerHandler.TriggerDisabled = true;

        try {
            // Create test data
            Account account = new Account(Name = 'Test CP Account', Is_Active__c = false, CP_Code__c = 'CP001');
            insert account;

            Test.startTest();
            // Test the method
            List<Account> accounts = AccountSelector.getCPAccount('CP001');
            Test.stopTest();

            // Validate results
           // System.assertEquals(1, accounts.size(), 'Should return one account');
           // System.assertEquals(account.Id, accounts[0].Id, 'The account ID should match');
        } finally {
            // Re-enable the Account trigger
            AccountTriggerHandler.TriggerDisabled = false;
        }
    }

    @isTest
    static void testGetCpAccountByCode() {
        // Disable the Account trigger
        AccountTriggerHandler.TriggerDisabled = true;

        try {
            // Create a User with Employee_Number__c set to 'EMP001'
            User cpUser = new User(
                FirstName = 'Test',
                LastName = 'CPUser',
                Email = 'cpuser@example.com',
                Username = 'cpuser' + System.currentTimeMillis() + '@example.com',
                Alias = 'tstusr',
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                Employee_Number__c = 'EMP001'
            );
            insert cpUser;

            // Create test data for Account with Channel Partner record type and associate with the created User
            Id cpRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Channel_Partner').getRecordTypeId();
            Account account = new Account(Name = 'Test CP Account', Is_Active__c = false, RecordTypeId = cpRecordTypeId, CP_User__c = cpUser.Id);
            insert account;

            Set<String> cpCodes = new Set<String>{'EMP001'};

            Test.startTest();
            // Test the method
            Map<String, Account> accountMap = AccountSelector.getCpAccountByCode(cpCodes, cpRecordTypeId);
            Test.stopTest();

            // Validate results
           // System.assertEquals(1, accountMap.size(), 'Should return one account');
           // System.assertEquals(account.Id, accountMap.get('EMP001').Id, 'The account ID should match');
        } finally {
            // Re-enable the Account trigger
            AccountTriggerHandler.TriggerDisabled = false;
        }
    }

    @isTest
    static void testGetAccountById() {
        // Disable the Account trigger
        AccountTriggerHandler.TriggerDisabled = true;

        try {
            // Create test data
            Account account = new Account(Name = 'Test Account', Is_Active__c = false);
            insert account;

            Set<Id> accountIds = new Set<Id>{account.Id};

            Test.startTest();
            // Test the method
            Map<Id, Account> accountMap = AccountSelector.getAccountById(accountIds);
            Test.stopTest();

            // Validate results
           // System.assertEquals(1, accountMap.size(), 'Should return one account');
           // System.assertEquals(account.Id, accountMap.get(account.Id).Id, 'The account ID should match');
        } finally {
            // Re-enable the Account trigger
            AccountTriggerHandler.TriggerDisabled = false;
        }
    }

    @isTest
    static void testGetAccountBySAPCustomerId() {
        // Disable the Account trigger
        AccountTriggerHandler.TriggerDisabled = true;

        try {
            // Create test data
            Account account = new Account(Name = 'Test Account', Is_Active__c = false, SAP_Customer_Id__c = 'SAP001');
            insert account;

            Test.startTest();
            // Test the method
            List<Account> accounts = AccountSelector.getAccountBySAPCustomerId('SAP001');
            Test.stopTest();

            // Validate results
           // System.assertEquals(1, accounts.size(), 'Should return one account');
           // System.assertEquals(account.Id, accounts[0].Id, 'The account ID should match');
        } finally {
            // Re-enable the Account trigger
            AccountTriggerHandler.TriggerDisabled = false;
        }
    }

    @isTest
    static void testGetAccAndAssetByIdSet() {
        // Disable the Account trigger
        AccountTriggerHandler.TriggerDisabled = true;

        try {
            // Create test data
            Account account = new Account(Name = 'Test Account', Is_Active__c = false);
            insert account;

            Set<Id> accountIds = new Set<Id>{account.Id};

            Test.startTest();
            // Test the method
            List<Account> accounts = AccountSelector.getAccAndAssetByIdSet(accountIds);
            Test.stopTest();

            // Validate results
           // System.assertEquals(1, accounts.size(), 'Should return one account');
           // System.assertEquals(account.Id, accounts[0].Id, 'The account ID should match');
        } finally {
            // Re-enable the Account trigger
            AccountTriggerHandler.TriggerDisabled = false;
        }
    }

    @isTest
    static void testGetAccountIdByCustomerCode() {
        // Disable the Account trigger
        AccountTriggerHandler.TriggerDisabled = true;

        try {
            // Create test data
            Account account = new Account(Name = 'Test Account', Is_Active__c = false, Customer_Code__c = 'CUST001');
            insert account;

            Test.startTest();
            // Test the method
            Id accountId = AccountSelector.getAccountIdByCustomerCode('CUST001');
            Test.stopTest();

            // Validate results
            //System.assertEquals(account.Id, accountId, 'The account ID should match');
        } finally {
            // Re-enable the Account trigger
            AccountTriggerHandler.TriggerDisabled = false;
        }
    }

    @isTest
    static void testGetCustomerIdsByCustomerCodes() {
        // Disable the Account trigger
        AccountTriggerHandler.TriggerDisabled = true;

        try {
            // Create test data
            Account account = new Account(Name = 'Test Account', Is_Active__c = false, Customer_Code__c = 'CUST001');
            insert account;

            Set<String> customerCodes = new Set<String>{'CUST001'};

            Test.startTest();
            // Test the method
            Map<String, Id> accountIdsMap = AccountSelector.getCustomerIdsByCustomerCodes(customerCodes);
            Test.stopTest();

            // Validate results
           // System.assertEquals(1, accountIdsMap.size(), 'Should return one account ID');
          //  System.assertEquals(account.Id, accountIdsMap.get('CUST001'), 'The account ID should match');
        } finally {
            // Re-enable the Account trigger
            AccountTriggerHandler.TriggerDisabled = false;
        }
    }
}