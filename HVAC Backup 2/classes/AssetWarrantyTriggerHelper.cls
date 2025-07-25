/*
@Author : Anshika Jain
@CreatedDate : 9th feb
@Description : AssetWarranty Object Trigger Handler.
*/
public with sharing class AssetWarrantyTriggerHelper {
    public static boolean isExecuting = false;
    public AssetWarrantyTriggerHelper() {
        
    }
    
    public void UpdateAssetStandardWarrantyDates(List<AssetWarranty> assetWarrantyList) {
        map<Id, AssetWarranty> assetIdToWarranty = New  map<Id, AssetWarranty>();
        For(AssetWarranty aw : assetWarrantyList){
            assetIdToWarranty.put(aw.assetId, aw);
        }
        system.debug('assetIdToWarranty : '+assetIdToWarranty);
        list<asset> assetToUpdate = New List <asset>();
        For(asset asset : AssetSelector.getAssetByIdSet(assetIdToWarranty.keyset())){
            if(asset.Extended_Warranty_End_Date__c != null){
                asset.Extended_Warranty_End_Date__c = assetIdToWarranty.get(asset.Id).EndDate;   
            }else{
                asset.Extended_Warranty_Start_Date__c = assetIdToWarranty.get(asset.Id).StartDate;
                asset.Extended_Warranty_End_Date__c = assetIdToWarranty.get(asset.Id).EndDate;  
            }
            assetToUpdate.add(asset);
        }
        If(!assetToUpdate.isEmpty()){
            update assetToUpdate;
        }
    }
    /*
@Author : Himanshi Verma
@CreatedDate : 3Rd May
@Description : AssetWarranty Object Trigger Handler.
*/
    public void UpdateAssetPMSAvailable(List<AssetWarranty> assetWarrantyList) {
        if (isExecuting) {
            return; // Exit if already executing to prevent infinite loop
        }
        try {
            isExecuting = true;
            //System.debug('assetIdToWarranty'+assetWarrantyList);
            map<Id, AssetWarranty> assetIdToWarranty = New  map<Id, AssetWarranty>();
            For(AssetWarranty aw : assetWarrantyList){
                assetIdToWarranty.put(aw.AssetId, aw);
            }
            list<Asset> productFamiliesIds = AssetSelector.returnProductFamilyids(assetIdToWarranty.keyset());
            Map<String, String> productFamilyMap = new Map<String, String>();
            for (Asset obj : productFamiliesIds) {
                productFamilyMap.put(obj.Id, obj.Product_Family__c);
            }
            list<Product_Family__c> productFamiliesWithAssets = ProductFamilySelector.getProductFamilyByAssetId(productFamilyMap.values());
            Map<String, String> productFamilyAssetMap = new Map<String, String>();
            for (Product_Family__c family : productFamiliesWithAssets) {
                productFamilyAssetMap.put(family.Id,family.Sales_Department_No__r.PMS_Events__c);
            }
            list<Asset> assetToUpdate = New List<Asset>();
            For(Asset obj : productFamiliesIds){
                // Asset asst = new Asset();
                // asst.Id = obj.Id;
                if(productFamilyAssetMap.containsKey(obj.Product_Family__c) && productFamilyAssetMap.get(obj.Product_Family__c) != null){
                    obj.PMS_Available__c = Decimal.valueOf(productFamilyAssetMap.get(obj.Product_Family__c));
                    assetToUpdate.add(obj);
                }
            }
            If(!assetToUpdate.isEmpty()){
                update assetToUpdate;
            }
        } catch (Exception e) {
            // Log the exception message along with line number
            System.debug('Exception caught at line: ' + e.getLineNumber() + ', Message: ' + e.getMessage());
            
        } finally {
            isExecuting = false;
        }
    }
}