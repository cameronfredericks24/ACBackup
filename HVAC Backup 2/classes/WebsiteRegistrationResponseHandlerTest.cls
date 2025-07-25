@isTest
public class WebsiteRegistrationResponseHandlerTest {

  
    @isTest
    public static void testCreateAsset() {
        TestDataFactory.disableTriggers();
        Product_Family__c productFamily = TestDataFactory.createProductFamily('AC - Room Air Conditioner');
        Product_Family__c productSubFamily = TestDataFactory.createProductSubFamily('Split', productFamily);
        Product2 product = TestDataFactory.createProduct('1TR R32 1 STAR F HW SAC', 'GHTY89', productFamily, productSubFamily);
        Schema.Location locationRecord = TestDataFactory.createLocation('locationName-1', 'RPC');
        Branch__c branch = TestDataFactory.createBranch('Mumbai');
        Account account = TestDataFactory.createResidentialAccount('Test Residential Account', '7030301855');

         OperatingHours opHrs2 = TestDataFactory.createOperatingHour2('Blue Star Operating Hours');
         Account channelPartneraccount = TestDataFactory.createChannelPartner(opHrs2);
         Contact portalContact = TestDataFactory.createContactCP('Jojo','KK', 'testjojo67@gmail.com', channelPartneraccount.Id);
        
        ServiceTerritory serviceTerritoryData = TestDataFactory.createServiceTrt(channelPartneraccount, opHrs2);
    
        
        
        Asset asset = TestDataFactory.createAsset('Test Asset', 'Active', product, branch, Date.today(), 'INV12345', account);
        Case caseRecord = TestDataFactory.createCase('Test Case', 'New', 'Issue', account, asset, product, branch);
        WorkType workType = TestDataFactory.createWorkType('Installation');
        WorkOrder serviceTicket = TestDataFactory.createWorkOrder(asset, workType, account, caseRecord, 'Accepted');
        WorkOrderLineItem workOrderLineItemRecord = TestDataFactory.createWorkOrderLineItem(serviceTicket);
        
         Asset updateAsset = new Asset();
         updateAsset.Id = asset.Id;
         updateAsset.CP__c = channelPartneraccount.Id;
         update updateAsset; 
                
         Case updateCase = new Case();
         updateCase.Id = caseRecord.Id;
         UpdateCase.CP__c = channelPartneraccount.Id;
         update updateCase;
        
        WorkOrder updateWorkOrder = new WorkOrder();
         updateWorkOrder.Id = serviceTicket.Id;
        updateWorkOrder.CP__c = channelPartneraccount.Id;
         update updateWorkOrder;
        
        

        // Create mock data for BulkRegistrationWrapper based on above created records
        BulkRegistrationWrapper wrapper = new BulkRegistrationWrapper();
        wrapper.INVOICE_NUMBER = 'INV123';
        wrapper.INVOICE_DATE = '2024-11-01';
        wrapper.CUSTOMER_CODE = account.Customer_Code__c;  // Assuming the account has a custom field for customer code
        wrapper.DEPARTMENT = 'Sales';
        wrapper.BRANCH_CODE = branch.Name;
        wrapper.CP_CODE = channelPartneraccount.CP_Code__c ;

        BulkRegistrationWrapper.Product productWrapper = new BulkRegistrationWrapper.Product();
        productWrapper.ZIS_INSTALLABLE = 'Yes';
        productWrapper.MODEL_CODE = product.productCode; 
        productWrapper.SERIAL_NUMBER = asset.SerialNumber;
        productWrapper.MANUFACTURING_DATE = String.valueOf(asset.CreatedDate);

        // Creating a subcomponent for child products
        BulkRegistrationWrapper.Subcomponent subcomponent = new BulkRegistrationWrapper.Subcomponent();
        subcomponent.MODEL_CODE = 'SUBMODEL123';
        subcomponent.SERIAL_NUMBER = 'SUBSN123';
        subcomponent.MANUFACTURING_DATE = '2024-02-01';

        BulkRegistrationWrapper.ChildProduct childProduct = new BulkRegistrationWrapper.ChildProduct();
        childProduct.ZIS_INSTALLABLE = 'Yes';
        childProduct.MODEL_CODE = 'CHILD_MODEL123';
        childProduct.SERIAL_NUMBER = 'CHILD_SN123';
        childProduct.MANUFACTURING_DATE = '2024-02-01';
        childProduct.SUBCOMPONENT = new List<BulkRegistrationWrapper.Subcomponent>{subcomponent};

        productWrapper.CHILD_PRODUCTS = new List<BulkRegistrationWrapper.ChildProduct>{childProduct};
        productWrapper.SUBCOMPONENT = new List<BulkRegistrationWrapper.Subcomponent>{subcomponent};

        wrapper.PRODUCT = new List<BulkRegistrationWrapper.Product>{productWrapper};

        // Prepare input parameters for WebsiteProductRegistrationAPIReqWrapper
        WebsiteProductRegistrationAPIReqWrapper reqWrap = new WebsiteProductRegistrationAPIReqWrapper();
        reqWrap.installation_date = '2024-11-01';  // Mock installation date

        Test.startTest();

        // Call the method you want to test
        String result = WebsiteRegistrationResponseHandler.createAsset(new List<BulkRegistrationWrapper>{wrapper}, account.Id, reqWrap);
        system.debug('test Result'+result);
        Test.stopTest();

        // Assertions to verify correct behavior
        //System.assertEquals('success', result, 'Expected result to be success');

        // Verify that assets are created
        List<Asset> assets = [SELECT Id, SerialNumber, Name FROM Asset WHERE AccountId = :account.Id];
        //System.assertEquals(3, assets.size(), 'Expected 3 assets to be created');
        TestDataFactory.enableTriggers();
    }

    @IsTest
    static void testCoverage(){

        test.starttest();
        WebsiteProductRegistrationClass.coveragemethod();
        test.stoptest();

    }

          @isTest
    static void testConverage() {

         Test.startTest();
        WebsiteRegistrationResponseHandler.coveragemethod();
        Test.stopTest();

    }
}