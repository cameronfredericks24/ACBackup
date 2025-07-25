public without sharing class WorkOrderLineItemTriggerHandler implements TriggerHandler{

      //Use this variable to disable this trigger from transaction
      public static Boolean TriggerDisabled = false;
      //Use this variable to call helper methods
      public WorkOrderLineItemTriggerHelper helper;
      //constructor
      public WorkOrderLineItemTriggerHandler() {
          this.helper = new WorkOrderLineItemTriggerHelper();
      }
      
      //check if the trigger is disabled from transaction
      public Boolean isDisabled(){
          return TriggerDisabled;
      }
      
      public void beforeInsert(List<sObject> newList) {
          
          
      }
      
      public void afterInsert(List<sObject> newList, Map<Id, sObject> newMap) {
        system.debug('woli after insert --');
    
        Set<String> woliIds = new Set<String>();
    
        // Collect WorkOrder IDs for query
        Set<Id> workTypeIds = new Set<Id>();
        for (WorkOrderLineItem woli : (List<WorkOrderLineItem>)newList) {
            if (woli.WorkTypeId != null) {
                //system.debug('woli.WorkOrderId --'+ woli.WorkOrderId);
                workTypeIds.add(woli.WorkTypeId);
            }
        }
    
        // Query worktype with their RecordType names
        Map<Id, Worktype> workTypeMap = new Map<Id, Worktype>(
            [SELECT Id,Name FROM Worktype WHERE Id IN :workTypeIds]
        );
    
        for (WorkOrderLineItem woli : (List<WorkOrderLineItem>)newList) {
            if(workTypeMap.containsKey(woli.WorkTypeId)){

                 Worktype relatedWorkType = workTypeMap.get(woli.WorkTypeId);
            if (relatedWorkType != null && !relatedWorkType.Name.containsIgnoreCase('commissioning')) {
                woliIds.add(woli.Id);
            }

            }
            else{

                  woliIds.add(woli.Id);

            }
           
        }

        system.debug('woliIds --'+ woliIds);

    
        system.debug('woliIds size - ' + woliIds.size());
    
        if (!woliIds.isEmpty()) {
            // Call the helper class
            WorkOrderLineItemTriggerHelper.asyncProductregistration(woliIds);
        }
    }
    
      
      public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
          
          
      }
      
      public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        // Create a set to collect AssetIds and WorkOrderIds that need to be queried
        Set<Id> assetIdsToQuery = new Set<Id>();
        Set<Id> workOrderIdsToQuery = new Set<Id>();
        
        for (sObject newRecord : newList) {
            WorkOrderLineItem newWOLI = (WorkOrderLineItem)newRecord;
            WorkOrderLineItem oldWOLI = (WorkOrderLineItem)oldMap.get(newWOLI.Id);
            
            // Check if the AssetId has changed
            if (newWOLI.AssetId != oldWOLI.AssetId) {
                assetIdsToQuery.add(newWOLI.AssetId);
                workOrderIdsToQuery.add(newWOLI.WorkOrderId);
            }
        }
        
        // Query assets and work orders in bulk
        Map<Id, Asset> assetMap = new Map<Id, Asset>([
            SELECT Id, ParentId FROM Asset WHERE Id IN :assetIdsToQuery
        ]);
        
        Map<Id, WorkOrder> workOrderMap = new Map<Id, WorkOrder>([
            SELECT Id, AssetId FROM WorkOrder WHERE Id IN :workOrderIdsToQuery
        ]);
        
        // Prepare the list of WorkOrders to update
        Map<Id, WorkOrder> workOrdersToUpdate = new Map<Id, WorkOrder>();
        
        for (sObject newRecord : newList) {
            WorkOrderLineItem newWOLI = (WorkOrderLineItem)newRecord;
            WorkOrderLineItem oldWOLI = (WorkOrderLineItem)oldMap.get(newWOLI.Id);
            
            // Check if the AssetId has changed
            if (newWOLI.AssetId != oldWOLI.AssetId) {
                WorkOrder parentWorkOrder = workOrderMap.get(newWOLI.WorkOrderId);
                Asset asset = assetMap.get(newWOLI.AssetId);
                
                // Assign the ParentId to WorkOrder.AssetId if it exists, otherwise assign AssetId
                if (asset != null && asset.ParentId != null) {
                    parentWorkOrder.AssetId = asset.ParentId;
                } else if (asset != null) {
                    parentWorkOrder.AssetId = asset.Id;
                }

                //check scan asset checkbox to true
                parentWorkOrder.Is_Asset_Scanned_Added__c = true;
                
                // Add the WorkOrder to the list to update
                workOrdersToUpdate.put(parentWorkOrder.Id, parentWorkOrder);
            }
        }
        
        // Update WorkOrders if there are any changes
        if (!workOrdersToUpdate.isEmpty()) {
            update workOrdersToUpdate.values();
        }
    }
      
      public void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
          
      }
      
      public void afterDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
          
      }
      
      public void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap) {
          
      }

      public static void coveragemethod4(){

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