public without sharing class ProductRequestLineItemRollUpSummary {

    public static List<ProductRequest> rollUpSummary(Set<Id> productRequestIds) {
        
        List<AggregateResult> productRequests = [Select SUM(Qty_Damaged__c),SUM(Qty_Mismatched__c), SUM(Qty_Missing_Short__c), SUM(Qty_Received__c),SUM(Qty_Received_Good__c),SUM(Qty_Sent__c),ParentId from ProductRequestLineItem Where ParentId IN: productRequestIds group by ParentId ];
        List<ProductRequest> productRequestUpdates = new List<ProductRequest>();
        for (AggregateResult aggRes : productRequests) {
            ProductRequest pr = new ProductRequest();
            pr.Id =  String.valueOf(aggRes.get('ParentId'));
            pr.Total_Qty_Damaged__c = Integer.valueOf(aggRes.get('expr0'));
            pr.Total_Qty_Mismatched__c = Integer.valueOf(aggRes.get('expr1'));
            pr.Total_Qty_Missing_Short__c = Integer.valueOf(aggRes.get('expr2'));
            pr.Total_Qty_Received__c = Integer.valueOf(aggRes.get('expr3'));
            pr.Total_Qty_Received_Good__c = Integer.valueOf(aggRes.get('expr4'));
            pr.Total_Qty_Sent__c = Integer.valueOf(aggRes.get('expr5'));

            productRequestUpdates.add(pr);
        }
        
        if (!productRequestUpdates.isEmpty()) {
            update productRequestUpdates;
        }

        return productRequestUpdates;
    }

    //write a future method to call the rollup summary
    @future
    public static void rollUpSummaryFuture(Set<Id> productRequestIds) {
         rollUpSummary(productRequestIds);
    }

    //Write a normal method to call the rollup summary
    public static List<ProductRequest> rollUpSummaryNormal(Set<Id> productRequestIds) {
        return rollUpSummary(productRequestIds);
    }
}