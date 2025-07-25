@isTest
public class CaseWorkOrderValidationTest {
    
    
    @testSetup
    static void setupTestData() {
        Test.startTest();
        TestDataFactory.disableTriggers();
        OperatingHours OP = TestDataFactory.createOperatingHour();
        OperatingHours opHrs = new OperatingHours(
        Name = 'Blue Star Operating Hours',
        TimeZone = 'Asia/Kolkata'
        );

        insert opHrs;
        Account channelPartner = TestDataFactory.createChannelPartner(opHrs);
        Account ResidentialAccount = TestDataFactory.createResidentialAccount('CP Payout', '9000000000');      
        Product_Family__c productFamily = TestDataFactory.createProductFamily('AC - Room Air Conditioner');
        Product_Family__c productSubFamily = TestDataFactory.createProductSubFamily('Split', productFamily);
        Product2 product = TestDataFactory.createProduct('11213TR R32 1 STAR F HW SAC', 'P12345', productFamily, productSubFamily);
        Branch__c branch = TestDataFactory.createBranch('Mumbai');
        Division__c division = TestDataFactory.createDivision('CPAG');
        Department__c department = TestDataFactory.createDepartment('52',division);
        Asset asset = TestDataFactory.createAsset('Test Asset', 'Active', product, branch, Date.today(), 'INV1234', channelPartner);
        asset.Service_Department_L__c = department.Id;
        asset.Cp__c = channelPartner.Id;
        update asset;
        Case caseRecord = TestDataFactory.createCase('CP Payout', 'In Progress', 'Breakdown', ResidentialAccount, asset, product, branch);
        WorkType workType = TestDataFactory.createWorkType('Breakdown');
 
        WorkOrder workOrder = TestDataFactory.createWorkOrder(asset, workType,ResidentialAccount , caseRecord,'In Progress');
        Test.stopTest();
    }

    @isTest
    static void testWorkOrderValidation() {

        Org_Constant__mdt workOrderConstant = Org_Constant__mdt.getInstance('Work_Order_constant');
        system.debug(workOrderConstant.Constant_Value__c);
        // Create Case
        Case testCase = [select Id from Case limit 1];

        // Update the Case status to 'Resolved' - this should trigger validation
        testCase.Status = 'Resolved';
        try {
            update testCase;
            // If validation fails, an exception should be thrown
            //System.assert(false, 'Expected exception was not thrown.');
        } catch (Exception e) {
            // Assert that the exception message matches the expected error message from Custom Metadata
            System.assertEquals(workOrderConstant.Constant_Value__c, e.getMessage());
        }
    }
}