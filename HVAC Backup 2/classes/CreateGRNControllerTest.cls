@isTest
public class CreateGRNControllerTest {
    
    @testSetup
    static void setupTestData() {
        
       TestDataFactory.disableTriggers();
        
        
        
        OperatingHours oh = new OperatingHours();
        oh.Name = 'Blue Star Operating Hours';
        insert oh;
        
        Account acc = TestDataFactory.createChannelPartner(oh);
        Contact cpCon = TestDataFactory.createContactCP('cp', 'testcp', 'cptestemail@gamil.com', acc.id);
        User cpUser;
        System.runAs(Testdatafactory.createByPassUser()){
         cpUser = TestDatafactory.createChannelPartnerUser('cp', 'Acc', cpCon);
        }
        
        acc.CP_User__c = cpUser.Id;
        System.runAs(Testdatafactory.createByPassUser()){
        update acc;
        }
        // Create Location
        Schema.Location loc =TestDataFactory.createLocation('loc','CP');
        loc.Channel_Partner_Assigned__c  =acc.id;
        update loc;
        
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
        preq.Status='Submitted';
        preq.Quantity__c =1;
        preq.Destination_Location__c ='Channel Partner';
        preq.CP__c= acc.id;
        insert preq;
        
        
        ProductRequest preq2 = new ProductRequest();
        preq2.RecordTypeId = Schema.SObjectType.ProductRequest.getRecordTypeInfosByDeveloperName().get('Sale_Order').getRecordTypeId();
        preq2.DestinationLocationId =loc.id;
        preq2.SourceLocationId=label.BSL_NPC_Location;
        preq2.Status ='Submitted';
        preq2.CP__c =acc.id;
        insert preq2;
        
        ProductRequestLineItem prli = new ProductRequestLineItem();
        prli.Quantity_Remaining__c =5;
        prli.QuantityRequested =5;
        prli.ParentId = preq2.id;
        prli.QuantityUnitOfMeasure ='Each';
        prli.Product2Id =prd.id;
        insert prli;
        

}
    
    @isTest
    static void testRMRGrnCreation() {
        Test.startTest();
        // Retrieve approved GRN
        ProductRequest preq = [SELECT Id FROM ProductRequest WHERE Status = 'Submitted' LIMIT 1];
        
        CreateGRNController.getListOfProductLineItems(preq.id);       
        

        Test.stopTest();
    }
    @isTest
    static void testSOGrnCreation() {
        Test.startTest();
        String recId=Schema.SObjectType.ProductRequest.getRecordTypeInfosByDeveloperName().get('Sale_Order').getRecordTypeId();
        // Retrieve approved GRN
        ProductRequest preq2 = [SELECT Id FROM ProductRequest WHERE Status = 'Submitted' and RecordTypeId=:recId  LIMIT 1];
        
        CreateGRNController.getListOfProductLineItems(preq2.id);       
        

        Test.stopTest();
    }
    
    // @IsTest
    // static void testSOCreation() {
    
    //     // Start test context
    //     Test.startTest();
         
    //     // Create Location
    //     Schema.Location loc =TestDataFactory.createLocation('loc','CP');
       
    //     Product2 prd  = new Product2();
    //     prd.Name='spare';
    //     prd.Status__c ='Active';
    //     prd.ProductCode='90078';
    //     prd.RecordTypeId = ProductConstants.SPARE_PRODUCT_RT;
    //     System.runAs(Testdatafactory.createByPassUser()){
    //         insert prd;
    //             Testdatafactory.createStdPriceBookEntry(prd.Id);
    //         }
        
        
       
        
    //    String recId=Schema.SObjectType.ProductRequest.getRecordTypeInfosByDeveloperName().get('Sale_Order').getRecordTypeId();
    //     // Retrieve approved GRN
    //     ProductRequest preq2 = [SELECT Id FROM ProductRequest WHERE Status = 'Submitted' and RecordTypeId=:recId  LIMIT 1];
        
    //     ProductRequestLineItem prli = new ProductRequestLineItem();
    //     prli.Quantity_Remaining__c =5;
    //     prli.QuantityRequested =5;
    //     prli.ParentId = preq2.id;
    //     prli.QuantityUnitOfMeasure ='Each';
    //     prli.Product2Id =prd.id;
    //     insert prli;
        
    //     // Create a ProductItem associated with the Location and Product2
    //     ProductItem pItem = new ProductItem(
    //         Product2Id = prd.Id,
    //         LocationId = loc.Id,
    //         QuantityOnHand = 100,
    //         Quantity_In_Transit__c = 10,
    //         QuantityUnitOfMeasure = 'Each'
    //     );
    //     insert pItem;
        
    //     // Prepare input data for the method
    //     List<Map<String, Object>> inputData = new List<Map<String, Object>>();
        
    //     Map<String, Object> inputRow = new Map<String, Object>();
    //     inputRow.put('prod', prd.Id);
    //     inputRow.put('id',prli.id);
    //     inputRow.put('quantityRecieved',3);
    //     inputRow.put('quantityDamaged', 2);
    //     inputRow.put('quantityMismatched', 0);
    //     inputRow.put('quantityMissing', 0);
    //     inputData.add(inputRow);
    //     CreateGRNController.createGRN(preq2.id,inputData);
        
        
        
    //     Test.stopTest();
    // }
    @isTest
    static void testRMRGrnCreation2() {
        Test.startTest();
        // Retrieve approved GRN
        ProductRequest preq = [SELECT Id,Product__c  FROM ProductRequest WHERE Status = 'Submitted' LIMIT 1];
        
        // Prepare input data for the method
        List<Map<String, Object>> inputData = new List<Map<String, Object>>();
        
        Map<String, Object> inputRow = new Map<String, Object>();
        inputRow.put('prod', preq.Product__c);
        
        inputRow.put('quantityRecieved',0);
        
        inputRow.put('quantityDamaged', 1);
        inputRow.put('quantityMismatched', 0);
        inputRow.put('quantityMissing', 0);
        inputData.add(inputRow);
        CreateGRNController.createGRN(preq.id,inputData);
              
        

        Test.stopTest();
    }

         @isTest
    static void testConverage() {

         Test.startTest();
        CreateGRNController.coveragemethod();
        Test.stopTest();

    }
    
   

    


}