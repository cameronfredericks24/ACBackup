@isTest(SeeAllData=true)
public class CaseConstantsTest {

    @isTest
    static void testCaseConstants() {
        // Assuming that the Org_Constant__mdt records already exist in the org with these DeveloperNames
        // Test the CaseResolvedStatus constant
        String caseResolvedStatus = CaseConstants.CaseResolvedStatus;
        System.assertEquals('Resolved', caseResolvedStatus, 'CaseResolvedStatus should be "Resolved".');

        // Test the CaseClosedStatus constant
        String caseClosedStatus = CaseConstants.CaseClosedStatus;
        System.assertEquals('Closed', caseClosedStatus, 'CaseClosedStatus should be "Closed".');

        // Test the CaseReopenedStatus constant
        String caseReopenedStatus = CaseConstants.CaseReopenedStatus;
        System.assertEquals('Reopened', caseReopenedStatus, 'CaseReopenedStatus should be "Reopened".');

        // Test the CaseOpenStatus constant
        String caseOpenStatus = CaseConstants.CaseOpenStatus;
        System.assertEquals('Open', caseOpenStatus, 'CaseOpenStatus should be "Open".');

        // Test the CASE_ORIGIN_EMAIL constant
        String caseOriginEmail = CaseConstants.CASE_ORIGIN_EMAIL;
        System.assertEquals('Email', caseOriginEmail, 'CASE_ORIGIN_EMAIL should be "Email".');

        // Test the NO_USER_FOUND_FOR_CP_ERROR constant
        String noUserFoundForCpError = CaseConstants.NO_USER_FOUND_FOR_CP_ERROR;
        System.assertEquals('No user found for this channel partner *. Please make sure this channel partner is a partner account.', 
                            noUserFoundForCpError, 
                            'NO_USER_FOUND_FOR_CP_ERROR should match the actual value in the Org_Constant__mdt.');

        // Test the Case_IssueType_Model_Not_Found constant
        //String caseIssueTypeModelNotFound = CaseConstants.Case_IssueType_Model_Not_Found;
        //System.assertEquals('Model not found', caseIssueTypeModelNotFound, 'Case_IssueType_Model_Not_Found should be "Model not found".');

        // Test the Case_Origin constant
        //String caseOrigin = CaseConstants.Case_Origin;
        //System.assertEquals('Registration', caseOrigin, 'Case_Origin should be "Registration".');
    }
}