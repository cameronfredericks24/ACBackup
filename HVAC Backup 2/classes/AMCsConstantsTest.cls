@isTest
public class AMCsConstantsTest {
    @isTest
    static void testGeneralConstants() {
        // Validate general constants
        System.assertEquals(10000, AMCsConstants.MAX_DML_ROWS, 'MAX_DML_ROWS should be 10000');
        System.assertEquals('Conversion', AMCsConstants.CONTRACT_CATEGORY_CONVERSION, 'CONTRACT_CATEGORY_CONVERSION should be Conversion');
        System.assertEquals('AMC', AMCsConstants.TYPE_AMC, 'TYPE_AMC should be AMC');
        System.assertEquals('RPC', AMCsConstants.RPC, 'RPC should be RPC');
        System.assertEquals('AMC Opportunity - ', AMCsConstants.OPP_PREFIX_NAME, 'OPP_PREFIX_NAME should be AMC Opportunity - ');
        System.assertEquals('AMC Quote ', AMCsConstants.AMC_QUOTE_NAME, 'AMC_QUOTE_NAME should be AMC Quote ');
        System.assertEquals('Monthly', AMCsConstants.BILLING_FREQUENCY_MONTHLY, 'BILLING_FREQUENCY_MONTHLY should be Monthly');
        System.assertEquals('Advance', AMCsConstants.BILLING_DUE_ADVANCE, 'BILLING_DUE_ADVANCE should be Advance');
        System.assertEquals('Draft', AMCsConstants.STATUS_DRAFT, 'STATUS_DRAFT should be Draft');
        System.assertEquals('Auto Generated', AMCsConstants.LEAD_SOURCE_AUTO_GENERATED, 'LEAD_SOURCE_AUTO_GENERATED should be Auto Generated');
        System.assertEquals('NAMO', AMCsConstants.NAMO, 'NAMO should be NAMO');
        System.assertEquals('NON NAMO', AMCsConstants.NON_NAMO, 'NON_NAMO should be NON NAMO');
        System.assertEquals('Prospecting', AMCsConstants.PROSPECTING, 'PROSPECTING should be Prospecting');
        System.assertEquals('Not Contacted', AMCsConstants.NOT_CONTACTED, 'NOT_CONTACTED should be Not Contacted');
        System.assertEquals('Yearly Advance', AMCsConstants.YEARLY_ADVANCE, 'YEARLY_ADVANCE should be Yearly Advance');
        System.assertEquals('Yearly Advance', AMCsConstants.SAMPLE, 'SAMPLE should be Yearly Advance');
    }

    @isTest
    static void testRecordTypeConstants() {
        // Validate record type constants
        Id opportunityAMCRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('AMC').getRecordTypeId();
        Id cpqQuoteAMCRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('AMC').getRecordTypeId();
        Id salesQuoteAMCRecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('AMC').getRecordTypeId();

        System.assertEquals(opportunityAMCRecordTypeId, AMCsConstants.Opportunity_AMC_RT, 'Opportunity_AMC_RT should match the actual Opportunity AMC Record Type ID');
        System.assertEquals(cpqQuoteAMCRecordTypeId, AMCsConstants.CPQQuote_AMC_RT, 'CPQQuote_AMC_RT should match the actual CPQ Quote AMC Record Type ID');
        System.assertEquals(salesQuoteAMCRecordTypeId, AMCsConstants.SalesQUote_AMC_RT, 'SalesQUote_AMC_RT should match the actual Sales Quote AMC Record Type ID');
    }

    @isTest
    static void testObjectFieldConstants() {
        // Validate object field constants
        System.assertEquals('Closed Won', AMCsConstants.OPPORTUNITY_STAGE_CLOSED_WON, 'OPPORTUNITY_STAGE_CLOSED_WON should be Closed Won');
    }

    @isTest
    static void testErrorMessages() {
        // Validate error message constants
        System.assertEquals('Invalid input', AMCsConstants.ERROR_INVALID_INPUT, 'ERROR_INVALID_INPUT should be Invalid input');
    }

    @isTest
    static void testSOQLConstants() {
        // Validate SOQL constants
        String expectedQuery = 'SELECT Id, Name FROM Opportunity WHERE StageName = \'Closed Won\'';
        System.assertEquals(expectedQuery, AMCsConstants.QUERY_GET_OPPORTUNITIES, 'QUERY_GET_OPPORTUNITIES should match the expected SOQL query');
    }

    @isTest
    static void testObjectNameConstants() {
        // Validate object name constants
        System.assertEquals('Opportunity', AMCsConstants.OPPORTUNITY_OBJECT, 'OPPORTUNITY_OBJECT should be Opportunity');
    }
}