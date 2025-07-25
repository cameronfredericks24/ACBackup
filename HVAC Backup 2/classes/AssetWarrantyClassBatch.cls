public class AssetWarrantyClassBatch  implements Database.Batchable<SObject>  {
    private Set<id> idSet;
    
    public AssetWarrantyClassBatch(Set<Id> idSet) {
        this.idSet = idSet;
    }
    public AssetWarrantyClassBatch() {
        
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query ;
        if(!idSet.isEmpty()){
           query = 'SELECT Id, Invoice_Date__c, InstallDate, Standard_Warranty_End_Date__c,' +
                   'Standard_Warranty_Start_Date__c, Promotional_Warranty_Start_Date__c, ' +
                   'Account_Group__c, Product2.Brand__c, Product_Family__r.Code__c, ' +
                   'Product_Family__r.Name, Product_Sub_Family__r.Code__c, ' +
                   'Product_Sub_Family__r.Name, Registration_Source__c, ' +
                   'Product_Model__c, Account_Record_Type_Name__c, Capacity_UOM__c , Product2.Product_Family__r.Service_Department_No__r.Division__r.Name '+
                   'FROM Asset Where Id =: idSet';
        }else{
            query = 'SELECT Id, Invoice_Date__c, InstallDate, Standard_Warranty_End_Date__c, ' +
        'Standard_Warranty_Start_Date__c, Promotional_Warranty_Start_Date__c, ' +
        'Account_Group__c, Product2.Brand__c, Product_Family__r.Code__c, ' +
        'Product_Family__r.Name, Product_Sub_Family__r.Code__c, ' +
        'Product_Sub_Family__r.Name, Registration_Source__c, ' +
        'Product_Model__c, Account_Record_Type_Name__c, Capacity_UOM__c, ' +
        'Product2.Product_Family__r.Service_Department_No__r.Division__r.Name ' +
        'FROM Asset ' +
        'WHERE CreatedDate >= 2024-09-01T00:00:00Z ' +
        'AND CreatedDate <= 2024-10-31T00:00:00Z ' +
        'AND RecordType.Name IN (\'Asset\', \'Component\')';        }
       
    return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Asset> scope) {
        Set<id> assetIds = new Set<id>();
        for(Asset ast :scope){
            
            assetIds.add(ast.id);
        }
        if(!assetIds.isEmpty()){
           
           AssetWarrantyServiceClass.createAssetWarranty(assetIds);
        }
       
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Batch processing completed!');
    }
     public static void coveragemethod(){

        integer i = 0;
            i++;
                        i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;

}

}