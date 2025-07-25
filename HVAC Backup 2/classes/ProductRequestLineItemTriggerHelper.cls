public without Sharing class ProductRequestLineItemTriggerHelper {
    public ProductRequestLineItemTriggerHelper() {
        System.debug('Inside ProductRequestTriggerHelper Constructor');
    }
    
    
     Public  void updateNPCPR(list<ProductRequestLineItem> prList, String Status){
        if(prList!=null){
            Map<Id, Decimal> productQuantityMap = new Map<Id, Decimal>();
            for(ProductRequestLineItem  pr:prList ){
                if(pr.Product2Id!=null && (pr.QuantityRequested != null && pr.QuantityRequested>1)){
                    if (productQuantityMap.containsKey(pr.Product2Id)) {
                        productQuantityMap.put(pr.Product2Id, productQuantityMap.get(pr.Product2Id) + pr.QuantityRequested);
                    } else {
                        productQuantityMap.put(pr.Product2Id, pr.QuantityRequested);
                    }
                    system.debug('prList '+  productQuantityMap);
                }
                
            }
            system.debug('productQuantityMapsize '+ productQuantityMap.size());
            system.debug('productQuantityMap '+ productQuantityMap);
            List<ProductItem> prodItemNPC = [select Id,QuantityOnHand,Product2Id,NPC_Pending_PR__c from ProductItem where Product2Id In:productQuantityMap.keySet() and LocationId=:label.BSL_NPC_Location ];
            system.debug('prodItemNPC '+ prodItemNPC);
            List<ProductItem> updatedPIList = new List<ProductItem>();
            if(!prodItemNPC.isEmpty()){
                for(ProductItem pi:prodItemNPC){
                    system.debug('pi.id '+ pi.id);
                    ProductItem piNew = new ProductItem();
                    piNew.id= pi.id;
                    if(Status == null){
                        piNew.NPC_Pending_PR__c = pi.NPC_Pending_PR__c !=null? pi.NPC_Pending_PR__c + productQuantityMap.get(pi.Product2Id):0+ productQuantityMap.get(pi.Product2Id);
                    }else{
                        piNew.NPC_Pending_PR__c = pi.NPC_Pending_PR__c !=null? pi.NPC_Pending_PR__c - productQuantityMap.get(pi.Product2Id):0; 
                    }
                    
                    if(piNew.NPC_Pending_PR__c>0){
                        updatedPIList.add(piNew);
                    }
                    
                    
                }
            }
            if(!updatedPIList.isEmpty()){
                database.update(updatedPIList);
            }
            
            
        }else{
            
        }
        
    }

}