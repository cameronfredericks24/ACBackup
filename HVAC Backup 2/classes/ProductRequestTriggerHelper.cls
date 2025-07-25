public without sharing class ProductRequestTriggerHelper {
    public ProductRequestTriggerHelper() {
        System.debug('Inside ProductRequestTriggerHelper Constructor--');
    }

    
    public void createRMR(List<ProductRequest> newProductRequests) {
        List<ReturnOrder> insertreturnOrders = new List<ReturnOrder>();
        
        Set<Id> productRequestIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        for (ProductRequest pr : newProductRequests) {
            productRequestIds.add(pr.Id);
            productIds.add(pr.Product__c);
        }
        
        Map<Id, WorkOrder> workOrdersMap = new Map<Id, WorkOrder>([SELECT Id, AccountId, CaseId 
                                                               FROM WorkOrder 
                                                               WHERE Id IN (SELECT WorkOrderId FROM ProductRequest WHERE Id IN :productRequestIds)]);
        
        Map<Id, Product2> productsMap = new Map<Id, Product2>([SELECT Id, Is_Consumable__c, Is_Returnable__c 
                                                               FROM Product2 
                                                               WHERE Id IN :productIds]);
        
        for (ProductRequest pr : newProductRequests) {
       //String scope = getBSLScopeProducts(pr.WorkOrderId, pr.Product__c);
            Product2 product = productsMap.get(pr.Product__c);
            
           // if (scope == 'Bluestar' ||  product.Is_Returnable__c) {
            if ( product.Is_Returnable__c) {
                ReturnOrder ro = new ReturnOrder();
                ro.RecordTypeId = ReturnOrderConstant.RMR_recordTypeId;
                ro.AccountId = workOrdersMap.get(pr.WorkOrderId).AccountId;
                system.debug('AccountId' + workOrdersMap.get(pr.WorkOrderId).AccountId);
                system.debug('CaseId' + workOrdersMap.get(pr.WorkOrderId).CaseId);
                ro.Work_Order__c = pr.WorkOrderId;
                ro.ProductRequestId = pr.Id;
                ro.CaseId = workOrdersMap.get(pr.WorkOrderId).CaseId;
                ro.RMR_Record_Type__c = true;
                ro.Status = 'InProcess';
                
                insertreturnOrders.add(ro);
            } else {
             //   System.debug('scope' + scope);
                System.debug('Is_Consumable__c' + product.Is_Consumable__c);
                System.debug('Is_Returnable__c' + product.Is_Returnable__c);
            }
        }
        
        if (!insertreturnOrders.isEmpty()) {
            insert insertreturnOrders;
        }
    }

    
    public static String getBSLScopeProducts( Id WorkorderId, Id ProductId) {
        system.debug('WorkorderID'+ WorkorderId);
        system.debug('productID'+ ProductId);
        string spareRecordTypeId = ProductConstants.SPARE_PRODUCT_RT;
        WorkOrder wo = [SELECT Id,AssetId, Asset.Asset_Obligation__c, 
                    asset.Promotional_Warranty_Start_Date__c ,asset.Promotional_Warranty_End_Date__c ,
                    Asset.CP__r.CP_Type__c,
                    Asset.Product_Family__r.Service_Department_No__r.Department_Number__c
                    FROM WorkOrder
                    WHERE Id=:WorkorderId];
        
        
        list<Product2> spareProducts =  [SELECT Id, Name, Material_Group__c, Parent_Product__r.Product_Family__r.Code__c,
                                     Base_Price__c, Parent_Product__r.Product_Sub_Family__r.Code__c
                                     FROM Product2 
                                     WHERE RecordTypeId =:spareRecordTypeId
                                     AND Id=:ProductId];
        
        
        string policyType = '';
        String scope;
        if(wo.Asset.Asset_Obligation__c == AssetConstant.Asset_Warranty_Obligation || (wo.Asset.Asset_Obligation__c  == 'NIC' && wo.asset.Promotional_Warranty_Start_Date__c <= system.today() && wo.asset.Promotional_Warranty_End_Date__c >= system.today())){
            if(wo.Asset.Asset_Obligation__c  == AssetConstant.Asset_NIC_Obligation && wo.asset.Promotional_Warranty_Start_Date__c <= system.today() && wo.asset.Promotional_Warranty_End_Date__c >= system.today()){
                policyType = 'Promotional';
            }else if (wo.Asset.Asset_Obligation__c == AssetConstant.Asset_Warranty_Obligation){
                policyType = 'Standard';
            }
            WarrantyTerm warrantyTerm = [SELECT Id,WarrantyTermName,WarrantyType,
                                     (SELECT Id,Material_group__c, Obligation__c,
                                      Sub_Type__c,Department__c, Scope__c 
                                      FROM Part_Scopes__r) 
                                     FROM WarrantyTerm 
                                     WHERE Id IN (SELECT WarrantyTermId FROM AssetWarranty WHERE AssetId =:wo.AssetId AND WarrantyType =: policyType) LIMIT 1];
            
            system.debug('warrantyTerm'+warrantyTerm);
            
            map<string, string> materialGroupToScope = New map<string, string>();
            
            system.debug('CpType'+  wo.Asset.CP__r.CP_Type__c);
            system.debug('Department'+ wo.Asset.Product_Family__r.Service_Department_No__r.Department_Number__c);
            
            for(Part_Scope__c ps : warrantyTerm.Part_Scopes__r){
                if(/*wo.Asset.Asset_Obligation__c == ps.Obligation__c &&*/ wo.Asset.CP__r.CP_Type__c == ps.Sub_Type__c && wo.Asset.Product_Family__r.Service_Department_No__r.Department_Number__c == ps.Department__c){
                    materialGroupToScope.put(ps.Material_group__c, ps.Scope__c);
                    system.debug('ps.scope'+ps.Scope__c);
                }
            }
            
            for(Product2 product : spareProducts){
                scope = materialGroupToScope.get(product.Material_Group__c);
            }
            return scope;
        }else{
            for(Product2 product : spareProducts){
                scope = 'Customer';
                
            }
            return scope;
        }
    }

    
        public void sendMRDetailsToSAP(list<Productrequest> prList){
            
            for(Productrequest pr:prList){

                    if(pr.is_MR_SO__c == true && pr.RecordTypeId == ProductRequestConstants.Sale_Order_RT){
                        SendSaleOrderDetailsAPI.sendSaleOrder(pr.Id);
                    }
                    else if(pr.RecordTypeId == ProductRequestConstants.Material_Request_RT){
                    //check if the SAP Id is ther in Account or not
                    list<Account> customerAccount = [SELECT Id,SAP_Customer_Id__c FROM Account WHERE Id=:pr.AccountId LIMIT 1];

                    if(!customerAccount.isEmpty()){

                           system.debug('customerAccount - '+ customerAccount);
                        if(customerAccount[0].SAP_Customer_Id__c == null){
                        
                            //send Customer and contact details to SAP and then send MR details
                            list<String> accountIds = new list<String>{customerAccount[0].Id};
                            
                            SendCustomerDetails.sendToSAP(accountIds,pr.Id, null);
                        }
                        else{
                            system.debug('SendMRDetailsSAPAPI.sendToSAP - '+ pr.Id);
                            SendMRDetailsSAPAPI.sendToSAP(pr.Id);
                            //Customer and contact details exist in SAP, so send MR directly
                        }
                    }
                } 
            }
      }

        public void callSaleorderAPI(List<Productrequest> prList) {
            // Get RecordType info for filtering
            Set<Id> prIds = new Set<Id>();
            for (Productrequest pr : prList) {
                prIds.add(pr.Id);
            }

            // Query necessary fields from Productrequest
            List<Productrequest> validPRs = [
                SELECT Id, is_MR_SO__c, RecordType.Name
                FROM Productrequest
                WHERE Id IN :prIds
            ];

            for (Productrequest pr : validPRs) {
                if (pr.is_MR_SO__c == true && pr.RecordType.Name == 'Sale Order') {
                    SendSaleOrderDetailsAPI.sendSaleOrder(pr.Id);
                }
            }
        }

    
    //Added By Soniya Kocher
    Public  void updateNPCPR(list<Productrequest> prList, String Status){
        if(prList!=null){
            Map<Id, Decimal> productQuantityMap = new Map<Id, Decimal>();
            for(ProductRequest  pr:prList ){
                if(pr.Product__c!=null && (pr.Quantity__c != null && pr.Quantity__c>1)){
                    if (productQuantityMap.containsKey(pr.Product__c)) {
                        productQuantityMap.put(pr.Product__c, productQuantityMap.get(pr.Product__c) + pr.Quantity__c);
                    } else {
                        productQuantityMap.put(pr.Product__c, pr.Quantity__c);
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
                        piNew.NPC_Pending_PR__c = pi.NPC_Pending_PR__c !=null ? pi.NPC_Pending_PR__c - productQuantityMap.get(pi.Product2Id):0;  
                    }
                    
                    if(piNew.NPC_Pending_PR__c>0){
                        updatedPIList.add(piNew);
                    }
                    //updatedPIList.add(piNew);
                    
                }
            }
            if(!updatedPIList.isEmpty()){
                database.update(updatedPIList);
            }
            
            
        }else{
            
        }
        
    }
       // Method to create a Spare Product with Family and Sub-Family
    public static Product2 createSpareProduct(String name, Boolean isReturnable, String productCode, Product_Family__c productFamily, Product_Family__c productSubFamily, String materialGroup) {
        Product2 product = new Product2(
            Name = name,
            ProductCode = productCode,
            Status__c = 'Active',
            Product_Family__c = productFamily.Id,
            Product_Sub_Family__c = productSubFamily.Id,
            RecordTypeId = ProductConstants.SPARE_PRODUCT_RT,
            Is_Returnable__c = isReturnable,
            Material_Group__c = materialGroup
        );
        System.runAs(TestDataFactory.createByPassUser()){
        insert product;
            TestDataFactory.createStdPriceBookEntry(product.Id);
        }
        return product;
    }

}