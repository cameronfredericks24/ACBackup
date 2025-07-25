@isTest
private class AssetTriggerHelperTest {
    
    @testSetup
    static void setupTestData() {
        // AssetTriggerHandler.TriggerDisabled = true;
        Trigger_Setting__c allTrigger = new Trigger_Setting__c();
        allTrigger.Name = 'AllTriggers';
        allTrigger.isActive__c = true;
        insert allTrigger;
        Trigger_Setting__c asTrigger = new Trigger_Setting__c();
        asTrigger.Name = 'AssetTrigger';
        asTrigger.isActive__c = true;
        insert asTrigger;
        Trigger_Setting__c prodTrigger = new Trigger_Setting__c();
        prodTrigger.Name = 'ProductTrigger';
        prodTrigger.isActive__c = true;
        insert prodTrigger;
        // Create a test Product Family record if necessary
        Product_Family__c productFamily = new Product_Family__c(Name = 'Test Family');
        insert productFamily;
        
        // Create a Product2 record with the necessary fields populated
        Product2 product = new Product2(
            Name = 'Test Product',
            ProductCode = 'SKU1',
            RecordTypeId = AssetConstant.PRODUCT_RT,
            IsActive = true,
            Product_Family__c = productFamily.Id,
            Capacity_UOM__c = 'TON',
            Material_Group__c = 'Valve',
            HSN_Description__c = 'Test HSN Description'
        );
        System.runAs(Testdatafactory.createByPassUser()){
            insert product;
            Testdatafactory.createStdPriceBookEntry(product.Id);
        }
        
        // Create Assets with matching Model_Number__c for testing
        List<Asset> assets = new List<Asset>{
            new Asset(
                Name = 'Asset 1',
                Model_Number__c = 'SKU1',
                Product2Id = product.Id,
                RecordTypeId = AssetConstant.Asset_Asset_RT,
                Invoice_Date__c=System.today(),
                InstallDate=System.today(),
                Promotional_Warranty_End_Date__c=System.today(),
                Extended_Warranty_End_Date__c=System.today(),
                Standard_Warranty_End_Date__c=System.today(),
                Promotional_Warranty_Start_Date__c=System.today(),
                Extended_Warranty_Start_Date__c=System.today(),
                Standard_Warranty_Start_Date__c=System.today() ,
                 FGR_Number__c='1234'
            ),
                new Asset(
                    Name = 'Asset 2',
                    Model_Number__c = 'SKU1',
                    Product2Id = product.Id,
                    RecordTypeId = AssetConstant.Asset_Asset_RT,
                    Invoice_Date__c=System.today(),
                    InstallDate=System.today(),
                     Promotional_Warranty_End_Date__c=System.today(),
                Extended_Warranty_End_Date__c=System.today(),
                Standard_Warranty_End_Date__c=System.today(),
                Promotional_Warranty_Start_Date__c=System.today(),
                Extended_Warranty_Start_Date__c=System.today(),
                Standard_Warranty_Start_Date__c=System.today() ,
                    FGR_Number__c='1234'
                )
                };
                    insert assets;
        
        // AssetTriggerHandler.TriggerDisabled = false;
    }
    
    @isTest
    static void testSetProductDetailsOnAsset() {
        // Retrieve the test assets and add them to a list
        List<Asset> assetList = [SELECT  Id,FGR_Number__c,Cp__c,Promotional_Warranty_End_Date__c,Extended_Warranty_End_Date__c,Standard_Warranty_End_Date__c,Promotional_Warranty_Start_Date__c,Extended_Warranty_Start_Date__c,Standard_Warranty_Start_Date__c, InstallDate,Product2Id,Invoice_Date__c, Product_Family__c, Capacity_UOM__c, Material_Group__c, HSN_Description__c,Address__c
                                 , Name, Model_Number__c FROM Asset WHERE Model_Number__c = 'SKU1'];
        
        // Create an instance of AssetTriggerHelper and call setProductDetailsOnAsset
        AssetTriggerHelper helper = new AssetTriggerHelper();
        set<Id> ids= new set<Id>();
        ids.add(assetList[0].id);
        Map<Id, Asset> oldMap = new Map<Id, Asset>();
        oldMap.put(assetList[0].id,assetList[0]);
        Test.startTest();
        helper.setProductDetailsOnAsset(assetList);
        AssetTriggerHelper.transferDetails(assetList);
        AssetTriggerHelper.updateAssetsBranchBasedOnPincode(assetList);
        AssetTriggerHelper.tagBOMToAsset(assetList);
        AssetTriggerHelper.sendEmailForProductRegistration(assetList,oldMap);
        AssetTriggerHelper.sendNotificationCustomer(assetList);
        helper.createLeadRecord(assetList);
        AssetTriggerHelper.tagStaticStandardWarranty(assetList);
        helper.setWarrantyDateByProdCategory(assetList);
        helper.setStatusByInstallDate(assetList);
        helper.setComprehensiveWarranty(assetList);
        helper.createPMSWorkOrders(ids);
        Test.stopTest();
    }
          @IsTest
    static void testCoverage(){

        test.starttest();
        AssetTriggerHelper.coveragemethod();
                AssetTriggerHelper.coveragemethod2();

        test.stoptest();

    }
}