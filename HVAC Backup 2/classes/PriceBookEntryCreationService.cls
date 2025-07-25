/*
@Author : Ajay M
@CreatedDate : 3th Nov 2024
@Description : Service Class to Create PriceBookEntry
@ModifiedBy: Kunal Nadkarni
@ModifiedDate : 4th Nov 2024
 */
public class PriceBookEntryCreationService {
    
    @invocablemethod(label='Create Price Book Entry' description='Creates Price Book Entries')
    public static void createPriceBookEntry(List<Id> requests)
    {
        List<Product2> prodList = [Select Id, Product_Sub_Family__c, Capacity_UOM__c, Capacity__c from Product2 where Id =:requests];
		PriceBookEntryCreationService pbeCreateService = new PriceBookEntryCreationService();
        pbeCreateService.processProducts(prodList);
    }
    
    private Map<String, Decimal> capacityMapping = new Map<String, Decimal>{
                            '0.75 TR' => 0.75, '1.0 TR' => 1.0, '1.5 TR' => 1.5, '1 TR' => 1.0,
                            '2.0 TR' => 2.0, '2.5 TR' => 2.5, '2 TR' => 2.0, '3.0 TR' => 3.0,
                            '3.5 TR' => 3.5, '3 TR' => 3.0, '4.0 HP' => 4.0, '4.0 TR' => 4.0,
                            '4.5 TR' => 4.5, '4 HP' => 4.0, '4 TR' => 4.0
                        };
    private Map<String, String> uomMapping = new Map<String, String>{
                            'TR' => 'TR', 'Tonnage of Refrigeration' => 'TR', 
                            'Horse Power' => 'HP', 
                            'HP' => 'HP'
                        };
    
    private static ID getStdPricebookId() {
        if (Test.isRunningTest())   return Test.getStandardPricebookId();
        return [Select Id from PriceBook2 Where IsActive = TRUE and IsStandard = TRUE limit 1].Id;    
    }                         
    public void processProducts(List<Product2> newProducts) {
        
        Set<Id> productSubFamilyIds = new Set<Id>();
        Map<String, Product2> famProdMap = new Map<String, Product2>();
        Map<String, PricebookEntry> newEntries = new Map<String,PricebookEntry>();
        Map<String, Pricebook2> priceBookMap = new Map<String, Pricebook2>();
        Id standardPriceBookId = getStdPricebookId();
        


        System.debug('Starting processProducts method');
        
        for (Product2 product : newProducts) {
            if (product.Product_Sub_Family__c != null && product.Capacity_UOM__c != null && product.Capacity__c != null) {
                //productSubFamilyIds.add(product.Product_Sub_Family__c);
                famProdMap.put(product.Product_Sub_Family__c, product);
                System.debug('Valid product found: ' + product.Id + ', Sub Family: ' + product.Product_Sub_Family__c);
            }
        }
        
        if (famProdMap.isEmpty()) {
            System.debug('No valid products found, exiting process');
            return;
        }
        
        List<Price_Matrix__c> matchingPriceMatrixRecords = [
            SELECT Id, Product_Sub_Family__c, Pricing_Method__c, Price_TR__c, Price_hp__c, Price_cfm__c, 
                   Price_kw__c, Price_M3h__c, Price_gpm__c, Capacity_Price__c, contract_Type__c, Model_Capacity__c
            FROM Price_Matrix__c
            WHERE Product_Sub_Family__c IN :famProdMap.keySet()
        ];

        if (matchingPriceMatrixRecords.isEmpty()) {
            System.debug('No matching Price Matrix records found');
            return;
        }
        
        List<Pricebook2> pricebooks = [
            SELECT Id, Contract_Type__c
            FROM Pricebook2 WHERE IsActive = true and Contract_Type__c != null
        ];

        for(PriceBook2 pb : pricebooks){
            priceBookMap.put(pb.Contract_Type__c, pb);
        }
        
        for(Product2 product : newProducts) {
            
            for(Price_Matrix__c matrixRecord : matchingPriceMatrixRecords) {
                if (matrixRecord.Product_Sub_Family__c == product.Product_Sub_Family__c) {
                    
                    System.debug('Processing Price Matrix for product: ' + product.Id);
                    Decimal unitPrice = 0;
                    String pricingType;
                    Decimal productCapacity = (product.Capacity__c!=null? product.Capacity__c:0);

                    if (matrixRecord.Pricing_Method__c == 'UoM') {
                        unitPrice = calculateCapacityPriceByUOM(product.Capacity_UOM__c, matrixRecord, productCapacity);
                        pricingType = 'UOM Price';
                        
                    }else if (matrixRecord.Pricing_Method__c == 'Capacity' && 
                              uomMapping.containsKey(product.Capacity_UOM__c) && 
                              matrixRecord.Model_Capacity__c.contains(uomMapping.get(product.Capacity_UOM__c)) && 
                              capacityMapping.containsKey(matrixRecord.Model_Capacity__c) &&
                              productCapacity == capacityMapping.get(matrixRecord.Model_Capacity__c)) {
                        unitPrice = calculateCapacityFlatRate(product.Capacity_UOM__c, matrixRecord, productCapacity);
                        pricingType = 'Flat Rate';
                        System.debug('Calculated unitPrice for Capacity: ' + unitPrice);
                    }
                    
                    if (unitPrice != 0) {
                        if(priceBookMap.containsKey(matrixRecord.contract_Type__c)){
                            Id priceBook2Id = priceBookMap.get(matrixRecord.contract_Type__c).Id;
                            //create Contract Type Price Book Entry
                            newEntries.put(priceBook2Id+':'+product.Id,(createPriceBookEntryList(priceBook2Id, product.Id, unitPrice, pricingType, matrixRecord.Id)));
                        }
                        
                    }
                }
            }
            
           	//create Standard Price Book Entry
            newEntries.put(standardPriceBookId+':'+product.Id,createPriceBookEntryList(standardPriceBookId, product.Id, 1, null, null));
            
            
        }
        
        if (!newEntries.isEmpty()) {
            createNewPriceBookEntries(newEntries);
        } else {
            System.debug('No PricebookEntry records to insert');
        }
    }
    
    @TestVisible private PricebookEntry createPriceBookEntryList(Id priceBookId, Id productId, Decimal unitPrice, String pricingType, Id matrixRecordId){
        PricebookEntry newPbe = new PricebookEntry
                                (
                                    Pricebook2Id = priceBookId,
                                    Product2Id = productId,
                                    UnitPrice = unitPrice,
                                    IsActive = true,
                                    Pricing_Type__c = pricingType,
                                    Price_Matrix__c = matrixRecordId
                                );
        return newPbe;
    }

    @TestVisible private Decimal calculateCapacityPriceByUOM(String productUom, Price_Matrix__c priceMatrix, Decimal productCapacity){
        Decimal capacityPrice = 0;
        if((productUom == 'Tonnage of Refrigeration' || productUom == 'TR') && priceMatrix.Price_TR__c != null){
            capacityPrice = priceMatrix.Price_TR__c * productCapacity;
        }

        if((productUom == 'Horse Power' || productUom == 'HP') && priceMatrix.Price_HP__c != null){
            capacityPrice = priceMatrix.Price_HP__c * productCapacity;
        }

        if((productUom == 'Cubic Feet per Minute' || productUom == 'CFM') && priceMatrix.Price_cfm__c != null){
            capacityPrice = priceMatrix.Price_cfm__c * productCapacity;
        }

        if((productUom == 'Kilowatt' || productUom == 'KW') && priceMatrix.Price_kw__c != null){
            capacityPrice = priceMatrix.Price_kw__c * productCapacity;
        }

        if((productUom == 'Meters Cubed Per Hour' || productUom == 'M3h') && priceMatrix.Price_M3h__c != null){
            capacityPrice = priceMatrix.Price_M3h__c * productCapacity;
        }

        if((productUom == 'Gallons per Mile' || productUom == 'GPM') && priceMatrix.Price_gpm__c != null){
            capacityPrice = priceMatrix.Price_gpm__c * productCapacity;
        }
        return capacityPrice;
    }

    @TestVisible private Decimal calculateCapacityFlatRate(String productUom, Price_Matrix__c priceMatrix, Decimal productCapacity){
        Decimal capacityPrice = 0;
        if(priceMatrix.Model_Capacity__c != null){
            Decimal modelCapacity = capacityMapping.containsKey(priceMatrix.Model_Capacity__c)?capacityMapping.get(priceMatrix.Model_Capacity__c):0;
            // Calculate unitPrice using Capacity_Price__c if modelCapacity is valid
            if (modelCapacity != null && priceMatrix.Capacity_Price__c != null && uomMapping.containsKey(productUom) && priceMatrix.Model_Capacity__c.contains(uomMapping.get(productUom))) {
                capacityPrice = priceMatrix.Capacity_Price__c;
            }
        }
        return capacityPrice;
    }
    
    @TestVisible private void createNewPriceBookEntries(Map<String, PriceBookEntry> newPbeList){
        Set<Id> productIds = new Set<Id>();
        List<PriceBookEntry> deactivatePbeList = new List<PriceBookEntry>();
        Map<String, PriceBookEntry> extPriceEntryMap = new Map<String, PriceBookEntry>();
        if(!newPbeList.isEmpty()){
            for(PriceBookEntry pbe : newPbeList.values()){
                productIds.add(pbe.Product2Id);
            }
            System.debug('productIds: '+productIds);
            //check for existing price entry the pricebooks
            for(PriceBookEntry extPbe : [Select Id, Product2Id, Pricebook2Id from PriceBookEntry Where Product2Id =: productIds]){
                extPriceEntryMap.put(extPbe.Pricebook2Id+':'+extPbe.Product2Id,extPbe);
            }
            System.debug('extPriceEntryMap: '+extPriceEntryMap);
            for(PriceBookEntry pbe : newPbeList.values()){
                if(extPriceEntryMap.containsKey(pbe.PriceBook2Id+':'+pbe.Product2Id)){
                   pbe.Id = extPriceEntryMap.get(pbe.PriceBook2Id+':'+pbe.Product2Id).Id;
                }
                System.debug('pbe: '+pbe+' : '+pbe.Product2Id+pbe.Pricebook2Id);
            }
            System.debug('newPbeList: '+newPbeList);
            //upsert the new Price Entries
            upsert newPbeList.values();
        	System.debug('Inserted ' + newPbeList.size() + ' PricebookEntry records');
        }
        
    }
}