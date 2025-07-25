public without sharing class ProductTransferHelper {
    public ProductTransferHelper() {

    }
    public  void createDefectiveProductLineItems(List<ProductTransfer> transferList){
        List<Defective_Product_Item__c> defectItemList = new List<Defective_Product_Item__c>();
        Set<id> idSet = new Set<id>();
        List<ProductRequest> prList = new List<ProductRequest>();
        if(transferList != null){
            for(ProductTransfer pt : transferList){
                 idSet.add(pt.ProductRequestId);
                 idSet.add(pt.Part_Request_MR__c );
                
            }
        }
        if(!idSet.isEmpty()){
           prList =[select id , CP__c, Part_Request_No__c,SDE__c from ProductRequest where id IN :idSet ];
        }
        Map<Id,ProductRequest> prIdMap = new Map<id,ProductRequest>();
        if(!prList.isEmpty()){
            for(ProductRequest pr :prList){
                prIdMap.put(pr.id,pr );
            }
            
        }

        try {
            if(transferList!=null){
                for(ProductTransfer pt : transferList){
                    Defective_Product_Item__c  defectItem = new Defective_Product_Item__c();
                    defectItem.Product_Name__c = pt.Product2Id;
                    defectItem.Location__c = pt.DestinationLocationId;
                    defectItem.Quantity_On_Hand__c =pt.Quantity_Damaged__c;
                    defectItem.Product_Transfer__c = pt.id;
                    defectItem.Part_Request__c = pt.Part_Request_MR__c;
                    defectItem.Created_From_GRN__c =true;
                    defectItem.Product_Type__c = 'Damaged';
                    defectItem.Part_Request_Line_Item__c= pt.ProductRequestLineItemId;
                    if(prIdMap.containsKey(pt.Part_Request_MR__c)){
                        defectItem.Channel_Partner__c = prIdMap.get(pt.Part_Request_MR__c).CP__c;
                        defectItem.SDE__c = prIdMap.get(pt.Part_Request_MR__c).SDE__c;

                        if(prIdMap.get(pt.Part_Request_MR__c).Part_Request_No__c.contains('MR')){
                            system.debug('prIdMap.get(pt.Part_Request_MR__c).Part_Request_No__c'+ prIdMap.get(pt.Part_Request_MR__c).Part_Request_No__c);
                            defectItem.Defective_Category__c = 'RMR';
                        }else{
                            defectItem.Defective_Category__c = 'Sales Order';
                            
                        }
                    }

                    defectItemList.add(defectItem);

                }
            }
            if(!defectItemList.isEmpty()){
             insert defectItemList;
            }
        } catch (Exception e) {
            
        } 
    }
}