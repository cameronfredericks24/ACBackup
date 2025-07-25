@isTest
public class AccountConstantTest {
    @isTest
    static void testRecordTypeIds() {
        Test.startTest();

        // Fetch the expected record type IDs
        Id expectedCommercialRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Commercial_Customer').getRecordTypeId();
        Id expectedResidentialRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Residential_Customer').getRecordTypeId();
        Id expectedChannelPartnerRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Channel_Partner').getRecordTypeId();

        // Null checks to ensure record types exist in the org
        System.assertNotEquals(null, expectedCommercialRT, 'The Commercial_Customer record type should exist in the org.');
        System.assertNotEquals(null, expectedResidentialRT, 'The Residential_Customer record type should exist in the org.');
        System.assertNotEquals(null, expectedChannelPartnerRT, 'The Channel_Partner record type should exist in the org.');

        // Validate that the record type IDs in AccountConstant match the expected values
        System.assertEquals(expectedCommercialRT, AccountConstant.COMMERCIAL_ACCOUNT_RT, 'The COMMERCIAL_ACCOUNT_RT should match the expected Record Type ID for Commercial_Customer.');
        System.assertEquals(expectedResidentialRT, AccountConstant.RESIDENTIAL_ACCOUNT_RT, 'The RESIDENTIAL_ACCOUNT_RT should match the expected Record Type ID for Residential_Customer.');
        System.assertEquals(expectedChannelPartnerRT, AccountConstant.CHANNEL_PARTNER_ACCOUNT_RT, 'The CHANNEL_PARTNER_ACCOUNT_RT should match the expected Record Type ID for Channel_Partner.');

        Test.stopTest();
    }

    @isTest
    static void testOrgConstantValues() {
        Test.startTest();

        // Fetch the expected custom metadata values
        String expectedTypeUPSD = UtilityClass.getOrgConstantValue('Type_UPSD');
        String expectedTypeCPSD = UtilityClass.getOrgConstantValue('Type_CPSD');
        String expectedStandardCPSD = UtilityClass.getOrgConstantValue('StandardCPSD');
        String expectedSSDCPType = UtilityClass.getOrgConstantValue('Type_SSD');
        String expectedGroupNamo = UtilityClass.getOrgConstantValue('GROUP_NAMO');

        // Null checks to ensure the custom metadata values exist
        System.assertNotEquals(null, expectedTypeUPSD, 'The Type_UPSD Org_Constant__mdt record should exist.');
        System.assertNotEquals(null, expectedTypeCPSD, 'The Type_CPSD Org_Constant__mdt record should exist.');
        System.assertNotEquals(null, expectedStandardCPSD, 'The StandardCPSD Org_Constant__mdt record should exist.');
        System.assertNotEquals(null, expectedSSDCPType, 'The Type_SSD Org_Constant__mdt record should exist.');
        System.assertNotEquals(null, expectedGroupNamo, 'The GROUP_NAMO Org_Constant__mdt record should exist.');

        // Validate that the constants in AccountConstant match the expected values
        System.assertEquals(expectedTypeUPSD, AccountConstant.TYPE_UPSD, 'The TYPE_UPSD should match the expected value from Org_Constant__mdt.');
        System.assertEquals(expectedTypeCPSD, AccountConstant.Type_CPSD, 'The Type_CPSD should match the expected value from Org_Constant__mdt.');
        System.assertEquals(expectedStandardCPSD, AccountConstant.StandardCPSD, 'The StandardCPSD should match the expected value from Org_Constant__mdt.');
        System.assertEquals(expectedSSDCPType, AccountConstant.SSDCPType, 'The SSDCPType should match the expected value from Org_Constant__mdt.');
        System.assertEquals(expectedGroupNamo, AccountConstant.GROUP_NAMO, 'The GROUP_NAMO should match the expected value from Org_Constant__mdt.');

        Test.stopTest();
    }
}