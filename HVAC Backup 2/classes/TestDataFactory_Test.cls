@isTest
public class TestDataFactory_Test {
    
    @isTest
    public static void testallmethod(){
     Test.startTest();
        TestDataFactory.disableTriggers();
        
        
            Account acc =TestDataFactory.createAccount('chekdts', '9088786867', 'chete@gmail.com', 'sape094');
           Contact con =TestDataFactory.createContact('frst', 'lst', acc);
            //TestDataFactory
            Product_family__c pf = TestDataFactory.createProductFamily('prodFamily');
            Product_family__c psf = TestDataFactory.createProductSubFamily('prodsub',pf);
            Product2 pr = TestDataFactory.createProduct('prodname','prodcode', pf,psf);
             TestDataFactory.createInvoicePaymentRequest();
             TestDataFactory.createByPassUser();
           Branch__c br=   TestDataFactory.createBranch('mum');
        TestDataFactory.createBOM(pr);
        //TestDataFactory.createChannelPartner2('cpTWo');
        //TestDataFactory.createAsset('asst', 'Registered', pr, br,null, 'inv788', acc);
       //TestDataFactory.createContentVersion('tit');
       
            TestDataFactory.createDivision('cpd');
        
        
        //TestDataFactory.createChannelPartnerUser('frstcp', 'lstcp', con);
        
        
        TestDataFactory.GenericTicketCreationJSONRequest();
        TestDataFactory.GenericTicketCreationJSONRequestExistingAccount();
        TestDataFactory.GenesysIVRTicketCreationJSONRequest();
        TestdataFactory.GenesysIVRFeedbackCaptureJSONRequest('98999');
        TestdataFactory.createInvoicePaymentRequest();
        TestdataFactory.createSAPCreditDebitRequest();
        TestdataFactory.createSAPChannelPartnerDetails();
        TestdataFactory.SAPCaptureAlternatePartAPIJSONRequest();
        Schema.location loc = TestdataFactory.createLocation('loc','CP');
        
        
        TestDataFactory.disableTriggers();
        
        
        
        OperatingHours oh = new OperatingHours();
        oh.Name = 'Blue Star Operating Hours';
        insert oh;
        
        Account acc2 = TestDataFactory.createChannelPartner(oh);
        Contact cpCon = TestDataFactory.createContactCP('cp', 'testcp', 'cptestemail@gamil.com', acc2.id);
        User cpUser;
        System.runAs(Testdatafactory.createByPassUser()){
         cpUser = TestDatafactory.createChannelPartnerUser('cp', 'Acc', cpCon);
        }
        ProductRequest preq =  new ProductRequest();
        preq.RecordTypeId = ProductRequestConstants.Material_Request_RT;
        preq.Product__c=pr.id;
        preq.Status='Submitted';
        preq.Quantity__c =1;
        preq.Destination_Location__c ='Channel Partner';
        preq.CP__c= acc2.id;
        insert preq;
        TestDataFactory.createOperatingHour();
        TestdataFactory.createOperatingHour2('optwo');
        try{
             TestdataFactory.createServiceTrt2(acc2);
             TestdataFactory.createServiceTrt(acc2,oh);
            TestdataFactory.createContentVersion('tit');
        }catch(exception e){
            
        }
       
        
        TestDataFactory.createByPassUser();
        TestDataFactory.createWorkType('pms');
        GRN__c grn =TestDataFactory.createGRN(preq,'Generated','RMR');
        ProductRequestLineItem prli =TestDataFactory.createProductRequestLineItem(preq,acc,pr,loc);
        ProductTransfer pt =TestDataFactory.createProductTransfer(pr, loc, grn, prli);
        TestdataFactory.createdefectiveProductItem(acc2,'Sales Order',pt,grn);
        //TestdataFactory.createResidentialAccount('resi','8967878787');
        //TestdataFactory.createProductItem(pr.id,loc.id,2);
       
            
        
        
        
        TestDataFactory.enableAllTriggers();
     Test.stopTest();
        
    }

         @isTest
    static void testConverage() {

         Test.startTest();
        TestDataFactory.coveragemethod();
        Test.stopTest();

    }
    

}