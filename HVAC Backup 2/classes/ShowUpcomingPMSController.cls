/*
@Author : Himanshi Verma
@CreatedDate : 5th April 2024
@Description : It is a controller class for ShowUpcomingPMS LWC.
*/
public with sharing class ShowUpcomingPMSController { 
    @AuraEnabled(cacheable=true)
    public static List<WorkOrder> getOpenWorkOrdersThisMonth(String recordId, Integer pageNumber, Integer pageSize) {
       List<WorkOrder> workOrders = new List<WorkOrder>();        
        try {
            if(String.isBlank(recordId) || pageNumber == null || pageSize == null || pageNumber <= 0 || pageSize <= 0) {
                return workOrders; // Return empty list if input parameters are invalid
            }
            
              List<Asset> assets = [SELECT Id FROM Asset WHERE AccountId = :recordId];
               if(assets.isEmpty()) {
                return workOrders; // No assets found, return empty list
            }
        Set<Id> assetIds = new Set<Id>();
        for(Asset asset : assets) {
            assetIds.add(asset.Id);
        }        
        Integer startIndex = (pageNumber - 1) * pageSize;
        Date startDate = Date.today().toStartOfMonth();
        Date endDate = Date.today().toStartOfMonth().addDays(Date.daysInMonth(Date.today().year(), Date.today().month()));
         workOrders = [SELECT Asset.Name,WorkType.Name, AssetId,PMS_Reschedule_Date__c,PMS_Maintenance_Date__c
                FROM WorkOrder
                WHERE AssetId IN :assetIds AND Status != 'Completed' AND WorkType.Name != null  AND WorkType.Name Like '%PMS%' AND CreatedDate >= :startDate AND CreatedDate <= :endDate 
                ORDER BY CreatedDate DESC
                LIMIT :pageSize OFFSET :startIndex];

         } catch(Exception e) {
             System.debug('Exception occurred: ' + e.getMessage());
        }
        return workOrders;      
 }
}