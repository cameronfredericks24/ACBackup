public with sharing class ProductItemSelector {
    /*
    @Author :Divya Nainava
    @Description : Get product items from channel partner Inventory.
    */
    public static List<ProductItem> getProductItems(string userId){
        
        //Currently taking the filter Location.OwnerId but later we need to change it for location.Channel_Partner_assigned__c
        return [SELECT Id, Product2Id, Product2.Name, Product2.ProductCode,LocationId,Location.Name, QuantityOnHand,Location.Channel_Partner_Assigned__c, 
                Location.Channel_Partner_Assigned__r.SDE__c FROM ProductItem WHERE Location.ownerId =:userId AND Product2.IsActive = true ];
    }


       /*
    @Author : Rishabh Sahu
    @Description : Get id, quantityonhand from productitems
    */

    public static List<ProductItem> getProductItemId(set<Id> productItemIds){
        
        return [SELECT Id, QuantityOnHand 
                FROM ProductItem 
                WHERE Id IN : productItemIds];
    }
}