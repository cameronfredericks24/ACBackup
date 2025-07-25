@isTest
public class GRNPdfControllerTest {
    
    @testSetup
    static void setupTestData() {
        TestDataFactory.disableTriggers();
        
        Product2 prd  = new Product2();
        prd.Name='spare';
        prd.Status__c ='Active';
        prd.ProductCode='90078';
        prd.RecordTypeId = ProductConstants.SPARE_PRODUCT_RT;
        System.runAs(Testdatafactory.createByPassUser()){
            insert prd;
                Testdatafactory.createStdPriceBookEntry(prd.Id);
            }
        ProductRequest preq =  new ProductRequest();
        preq.RecordTypeId = ProductRequestConstants.Material_Request_RT;
        preq.Product__c=prd.id;
        insert preq;
       

        // Create GRNs
        GRN__c grnApproved = new GRN__c(
            Reverse_GRN__c = true,
            GRN_Type__c = 'Sales Order',
            Status__c = 'Approved',
            GRN_Date_Time__c = Datetime.now()
        );
        insert grnApproved;

        GRN__c grnNotApproved = new GRN__c(
            Reverse_GRN__c = false,
            GRN_Type__c = 'RMR',
            Status__c = 'Generated',
            GRN_Date_Time__c = Datetime.now()
        );
        insert grnNotApproved;

        // Create Defective Product Item
        Defective_Product_Item__c defectiveItem = new Defective_Product_Item__c(
            Part_Request__c = preq.Id,
            Defective_Category__c = 'Sales Order',
            Reverse_GRN__c = grnApproved.Id,
            Quantity_On_Hand__c = 2
        );
        insert defectiveItem;

        // Create Supporting Data
        OperatingHours operatingHours = new OperatingHours(Name = 'Blue Star Operating Hours');
        insert operatingHours;

        Account account = TestDataFactory.createChannelPartner(operatingHours);
        Contact contact = TestDataFactory.createContactCP('CP1', 'TestCP', 'testcp@example.com', account.Id);
        User channelPartnerUser = TestDataFactory.createChannelPartnerUser('cpUser', 'CP001', contact);
        account.CP_User__c = channelPartnerUser.Id;
        update account;

        Schema.Location location = TestDataFactory.createLocation('Loc1', 'CP');
        location.Channel_Partner_Assigned__c = account.Id;
        update location;

        ProductRequestLineItem prli = TestDataFactory.createProductRequestLineItem(preq, account, prd, location);
        ProductTransfer productTransfer = TestDataFactory.createProductTransfer(prd, location, grnApproved, prli);
    }
    
    @isTest
    static void testGRNPdfControllerApproved() {
        // Retrieve approved GRN
        GRN__c grn = [SELECT Id FROM GRN__c WHERE Status__c = 'Approved' LIMIT 1];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(grn);
        GRNPdfController controller = new GRNPdfController(sc);
        
        System.assert(controller.isApproved, 'GRN should be approved');
        System.assertEquals(grn.Id, controller.grn.Id, 'Controller should initialize with the correct GRN record');
    }
    
    @isTest
    static void testGRNPdfControllerNotApproved() {
        // Retrieve not approved GRN
        GRN__c grn = [SELECT Id FROM GRN__c WHERE Status__c != 'Approved' LIMIT 1];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(grn);
        GRNPdfController controller = new GRNPdfController(sc);
        
        System.assert(!controller.isApproved, 'GRN should not be approved');
        System.assertEquals('GRN is not approved.', controller.errorMessage, 'Error message should indicate unapproved GRN');
    }
    
    @isTest
    static void testGRNPdfControllerWithDefectiveProducts() {
        // Retrieve approved GRN with defective products
        GRN__c grn = [SELECT Id FROM GRN__c WHERE Reverse_GRN__c = true LIMIT 1];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(grn);
        GRNPdfController controller = new GRNPdfController(sc);
        
        System.assert(controller.showDefectiveProducts, 'Show defective products should be true');
        System.assert(controller.defectiveProducts.size() > 0, 'Defective products list should not be empty');
    }
    
    @isTest
    static void testGenerateAndAttachPDF() {
        // Retrieve approved GRN
        GRN__c grn = [SELECT Id FROM GRN__c WHERE Status__c = 'Approved' LIMIT 1];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(grn);
        GRNPdfController controller = new GRNPdfController(sc);
        
        PageReference pageRef = controller.generateAndAttachPDF();
        
        System.assertNotEquals(null, pageRef, 'PageReference should not be null');
        System.assert(pageRef.getUrl().contains(grn.Id), 'PageReference should redirect to the GRN record');
        
        Attachment attachedPDF = [SELECT Id FROM Attachment WHERE ParentId = :grn.Id LIMIT 1];
        System.assertNotEquals(null, attachedPDF, 'PDF should be attached to the GRN record');
    }
}