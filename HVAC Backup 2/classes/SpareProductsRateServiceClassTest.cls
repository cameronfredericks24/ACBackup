@isTest
public class SpareProductsRateServiceClassTest {
    @testSetup static void setupTestData() {  
        
        TestDataFactory.disableTriggers();     
        String commercialAccountRecordTypeID = AccountConstant.COMMERCIAL_ACCOUNT_RT;
        String channelPartnerAccountRecordTypeID = AccountConstant.CHANNEL_PARTNER_ACCOUNT_RT;
        
        Account testAccount = New Account(
            Name = 'Test Account',
            Contact_Name__c = 'Test',
            RecordTypeId = commercialAccountRecordTypeID
        );
        Insert testAccount;
        
        OperatingHours opHrs = new OperatingHours(
        Name = 'Blue Star Operating Hours',
        TimeZone = 'Asia/Kolkata'
        );

        insert opHrs;
        Account channelPartner = TestDataFactory.createChannelPartner(opHrs);
        
        Department__c dep = New Department__c(
            Department_Number__c = '50'
        );
        insert dep;
        
        Division__c division = New Division__c();
        division.Name = 'CPAG' ;
        insert division;
        
        ID productFamilyRecordTypeId = Schema.SObjectType.Product_Family__c.getRecordTypeInfosByDeveloperName().get('Product_Family').getRecordTypeId();
        ID productSubFamilyRecordTypeId = Schema.SObjectType.Product_Family__c.getRecordTypeInfosByDeveloperName().get('Product_Sub_Family').getRecordTypeId();
        
        Product_Family__c testProductFamily = New Product_Family__c(
            Name = 'testProductFamily',
            RecordTypeId = productFamilyRecordTypeId, 
            Service_Department_No__c = dep.Id,
            Code__c = 'FAM',
            Type__c = 'Product Family',
            Sales_Department_No_SAP__c = '50',
            Service_Department_No_SAP__c = '50',
            Division__c = 'CPAG'
        );
        Insert testProductFamily;
        system.debug('testProductFamily '+ testProductFamily.Division_Lookup__c);
        
        Product_Family__c testProductSubFamily = New Product_Family__c(
            Name = 'testProductSubFamily',
            RecordTypeId = productSubFamilyRecordTypeId,
            Parent_Product_Family__c = testProductFamily.Id,
            Code__c = 'SUBFAM',
            Type__c = 'Product Sub Family',
            Parent_Product_Family_Code__c = 'FAM',
            Sales_Department_No_SAP__c = '50',
            Service_Department_No_SAP__c = '50'
        );
        Insert testProductSubFamily;
        
        Product2 testProduct = New Product2(
            Name = 'testProduct',         
            RecordTypeId = ProductConstants.PRODUCT_RT,
            Product_Family__c = testProductFamily.Id,
            Product_Sub_Family__c = testProductSubFamily.Id,
            Product_Type__c = 'Durable',
            ProductCode ='BSL_Model_1',
            Code__c='BSL_Model_1',
            Material_Group__c = 'WPD-Plastic Parts',
            IsActive = true,
            Type__c = 'Product',
            Product_Family_Code__c = 'FAM',
            Product_Sub_Family_Code__c = 'SUBFAM' ,
            Product_Category__c = AssetConstant.Product_Category_Installation_Required
        );       
        System.runAs(Testdatafactory.createByPassUser()){
            insert testProduct;
                Testdatafactory.createStdPriceBookEntry(testProduct.Id);
            }
        
        Product2 spareProduct = New Product2(
            Name = 'spareProduct',
            RecordTypeId = ProductConstants.SPARE_PRODUCT_RT,
            Parent_Product_Name__c =  'testProduct',
            Parent_Product__c = testProduct.Id,
            Product_Type__c = 'Durable',
            ProductCode ='BSL_Model_2',
            Material_Group__c = 'WPD-Plastic Parts' ,
            Base_Price__c = 900,
            IsActive = true 
        );       
        System.runAs(Testdatafactory.createByPassUser()){
            insert spareProduct;
                Testdatafactory.createStdPriceBookEntry(spareProduct.Id);
            }
        
         BOM__c bom = new BOM__c(
              Product_Code__c = 'BSL_Model_1',
             Product__c = testProduct.Id
         );
         insert bom;
        
        BOM_Item__c bomline = new BOM_Item__c(
              Part__c = spareProduct.Id,
            BOM__c = bom.Id
            
         );
        insert bomline;
        
        Asset testAsset1 = New Asset(
            Name = 'Test Asset',
            AccountId =  testAccount.id,
            Product2Id = testProduct.Id,
            Product_Family__c	= testProductFamily.id,
            Product_Sub_Family__c = testProductSubFamily.id,
            Invoice_Date__c = System.today()-4,
            Service_Department_L__r = dep,
            //Product_Category__c = AssetConstant.Product_Category_Installation_Required,
            CP__c =   channelPartner.id ,
            Standard_Warranty_Start_date__c = (system.Today()).addDays(-2),
            Standard_Warranty_End_date__c = (system.Today()).addDays(2)
        );
        insert testAsset1; 
        
        WorkOrder testWorkOrder1 = new WorkOrder(
            AssetId = testAsset1.Id);
        insert testWorkOrder1;
        
        list<WarrantyTerm> warrantyTermsToBeInserted = New list<WarrantyTerm>();
        
        WarrantyTerm wt1 = New WarrantyTerm();
        wt1.EffectiveStartDate = WarrantyTermConstants.EffectiveStartDate_Installation_Status;
        wt1.WarrantyTermName = 'Test Policy 1';
        wt1.WarrantyType = 'Standard';
        wt1.WarrantyUnitOfTime = 'Months';
        wt1.WarrantyDuration = 2;
        wt1.Start_Date__c = System.today()- 6;
        wt1.End_Date__c =  System.today() + 6;
     //   wt1.Products__c = 'BSL_Model_1';
     //   wt1.Product_Families__c = 'testProductFamily';
     //   wt1.Product_Sub_Families__c = 'testProductSubFamily';
        wt1.IsActive = true;
        insert wt1;
        
        Part_Scope__c ps = New Part_Scope__c(
            Department__c = '50',
            Material_group__c = 'WPD-Plastic Parts',
            Policy__c = wt1.Id,
            Scope__c = 'Customer',
            Sub_Type__c = 'ESA'    
        );
        insert ps;
        
        WarrantyTerm wt2 = New WarrantyTerm();
        wt2.EffectiveStartDate = WarrantyTermConstants.EffectiveStartDate_Installation_Status;
        wt2.WarrantyTermName = 'Test Policy 2';
        wt2.WarrantyUnitOfTime = 'Months';
        wt2.WarrantyType = 'Promotional';
        wt2.WarrantyDuration = 2;
        wt2.Start_Date__c = System.today()- 6;
        wt2.End_Date__c =  System.today() + 6;
     //   wt2.Products__c = 'BSL_Model_1';
     //   wt2.Product_Families__c = 'testProductFamily';
     //   wt2.Product_Sub_Families__c = 'testProductSubFamily';
        wt2.IsActive = true;        
        insert wt2;
        
        WarrantyTerm wt3 = New WarrantyTerm();
        wt3.EffectiveStartDate = WarrantyTermConstants.EffectiveStartDate_Installation_Status;
        wt3.WarrantyTermName = 'Test Policy 3';
        wt3.WarrantyUnitOfTime = 'Months';
        wt3.WarrantyType = 'Extended';
        wt3.WarrantyDuration = 2;
        wt3.Start_Date__c = System.today()- 6;
        wt3.End_Date__c =  System.today() + 6;
   //     wt3.Products__c = 'BSL_Model_1';
   //     wt3.Product_Families__c = 'testProductFamily';
   //     wt3.Product_Sub_Families__c = 'testProductSubFamily';
        wt3.IsActive = true;        
        insert wt3;
        
        AssetWarranty assetWt = new AssetWarranty(WarrantyTermId = wt1.Id, AssetId=testAsset1.Id, StartDate = (system.Today()).addDays(-2), WarrantyType='Standard');
        insert assetwt;
        
        AssetWarranty assetWt2 = new AssetWarranty(WarrantyTermId = wt2.Id, AssetId=testAsset1.Id, StartDate = (system.Today()).addDays(-2), WarrantyType='Promotional');
        insert assetwt2;
        
        AssetWarranty assetWt3 = new AssetWarranty(WarrantyTermId = wt3.Id, AssetId=testAsset1.Id, StartDate = (system.Today()).addDays(-2), WarrantyType='Extended');
        insert assetwt3;
        
        Price_Master__c pm = New Price_Master__c(
            Customer_Price_Percent__c = 90,
            Family__c = 'FAM',
            Sub_Family__c = 'SUBFAM',
            Material_Group__c = 'WPD-Plastic Parts'    
        );
        insert pm;
        
    }
    
    
    @isTest
    static void testWarrantyAssignment1(){
        
        Asset testAsset1 = [SELECT ID, InstallDate FROM Asset   LIMIT 1];        
        testAsset1.InstallDate = System.today()- 2;
        Update testAsset1;
        
        WorkOrder testWorkOrder1 = [SELECT ID FROM WorkOrder WHERE AssetId =: testAsset1.Id LIMIT 1];
        
        Test.startTest();
        list <SpareProductsRateServiceClass.spareWrapper> spareRateList = SpareProductsRateServiceClass.getSpareParts(testWorkOrder1.Id,'BSL_Model_1');
        Test.stopTest();
        
        //Assert.areEqual(1, spareRateList.size());
        
    } 
    
      @isTest
    static void testWarrantyAssignment2(){
        
        Asset testAsset1 = [SELECT ID, InstallDate FROM Asset   LIMIT 1]; 
        testAsset1.Standard_Warranty_Start_Date__c = null;
        testAsset1.Standard_Warranty_End_Date__c =null;
        update testAsset1;
              
        WorkOrder testWorkOrder1 = [SELECT ID FROM WorkOrder WHERE AssetId =: testAsset1.Id LIMIT 1];
        
        Test.startTest();
        list <SpareProductsRateServiceClass.spareWrapper> spareRateList = SpareProductsRateServiceClass.getSpareParts(testWorkOrder1.Id,'BSL_Model_1');
        Test.stopTest();
        
        //Assert.areEqual(1, spareRateList.size());
        
    } 
    
    @isTest
    static void testSparePricesInvocable(){
        
        Asset testAsset1 = [SELECT ID, InstallDate FROM Asset   LIMIT 1]; 
        testAsset1.Standard_Warranty_Start_Date__c = null;
        testAsset1.Standard_Warranty_End_Date__c =null;
        update testAsset1;
              
        WorkOrder testWorkOrder1 = [SELECT ID FROM WorkOrder WHERE AssetId =: testAsset1.Id LIMIT 1];
        
        SparePriceInvocable.Request request1 = new SparePriceInvocable.Request();
        request1.partId = [Select Id, Name from Product2 where recordTypeId = : ProductConstants.SPARE_PRODUCT_RT Limit 1].Name;
        request1.model = 'BSL_Model_1';
        request1.recordId = TestWorkOrder1.Id;
        
        List<SparePriceInvocable.Request> requests = new List<SparePriceInvocable.Request>{request1};

        Test.startTest();
        List<SparePriceInvocable.Response> responses = SparePriceInvocable.getPrice(requests);
        Test.stopTest();
        
        
    } 
}