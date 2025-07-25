@isTest
private class SurveyConstantsTest {
    @isTest
    static void testSurveyConstants() {
        Test.startTest();

        // Query the metadata directly from the org
        Map<String, String> constantsMap = new Map<String, String>();
        for (Org_Constant__mdt constant : [SELECT DeveloperName, Constant_Value__c FROM Org_Constant__mdt]) {
            constantsMap.put(constant.DeveloperName, constant.Constant_Value__c);
        }

        // Verify constants retrieved from SurveyConstants
        System.assertEquals(constantsMap.get('CSAT_Survey_Form'), SurveyConstants.CSAT_Survey_Form,
            'The value for CSAT_Survey_Form does not match the expected value.');

        System.assertEquals(constantsMap.get('Case_Type_BreakDown'), SurveyConstants.cTypeBreakDown,
            'The value for Case_Type_BreakDown does not match the expected value.');

        System.assertEquals(constantsMap.get('Case_Type_Regular_Service'), SurveyConstants.cTypeRegularService,
            'The value for Case_Type_Regular_Service does not match the expected value.');

        System.assertEquals(constantsMap.get('Case_Type_Installation'), SurveyConstants.cTypeInstallation,
            'The value for Case_Type_Installation does not match the expected value.');

        System.assertEquals(constantsMap.get('Case_Type_PMS'), SurveyConstants.cTypePMS,
            'The value for Case_Type_PMS does not match the expected value.');

        System.assertEquals(constantsMap.get('Case_Type_Survey_Name'), SurveyConstants.cTypeSurveyName,
            'The value for Case_Type_Survey_Name does not match the expected value.');

        System.assertEquals(constantsMap.get('Breakdown_and_Regular'), SurveyConstants.breakDownAndRegular,
            'The value for Breakdown_and_Regular does not match the expected value.');

        Test.stopTest();
    }
}