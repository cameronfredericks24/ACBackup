/*
@Author : Kunal Nadkarni
@CreatedDate : 5th Nov 2024
@Description : Product Object Trigger Helper.
 */
public without sharing class ProductTriggerHelper {
	public ProductTriggerHelper() {
        System.debug('Inside ProductTriggerHelper Constructor');
    }
    
    public void createPriceBookEnties(List<Product2> productList){
        PriceBookEntryCreationService pbeCreateService = new PriceBookEntryCreationService();
        pbeCreateService.processProducts(productList);
    }
    
}