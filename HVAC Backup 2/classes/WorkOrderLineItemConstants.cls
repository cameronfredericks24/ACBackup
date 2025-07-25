public with sharing class WorkOrderLineItemConstants {
     public WorkOrderLineItemConstants() {
		
    }

	public static final String WORK_ORDER_LINE_ITEM_STATUS_NEW = 'New';
    public static final String WORK_ORDER_LINE_ITEM_STATUS_IN_PROGRESS = 'In Progress';
    public static final String WORK_ORDER_LINE_ITEM_STATUS_ONHOLD = 'On Hold';
    public static final String WORK_ORDER_LINE_ITEM_STATUS_CANNOT_COMPLETE = 'Cannot Complete';
    public static final String WORK_ORDER_LINE_ITEM_STATUS_IN_COMPLETED = 'Completed';  
    public static final String WORK_ORDER_LINE_ITEM_STATUS_CANCELED = 'Canceled';  
    //ADDED REPLACMENT STATUS FOR WOLIs - 01-02-24 Utkarsha Patil
    public static final String WORK_ORDER_LINE_ITEM_STATUS_REPLACEMENT_REQUESTED = 'Replacement Requested';

    //Work Order Line Item Type Constants
    public static final String WORK_ORDER_LINE_ITEM_INSTALLATION_FREE = 'Free Installation';
    public static final String WORK_ORDER_LINE_ITEM_INSTALLATION_CHARGEABLE = 'Chargeable Installation';
    public static final String WORK_ORDER_LINE_ITEM_INCITY = 'InCity';
    public static final String WORK_ORDER_LINE_ITEM_OUTCITY = 'OutCity';
    public static final String WORK_ORDER_LINE_ITEM_FAN = 'Fan';
    public static final String WORK_ORDER_LINE_ITEM_MG = 'Mixer';
    
    public static Boolean checkIfMaterialCostReuquired(String productType){
        Set<String> productTypeSet = new Set<String>();
        productTypeSet.add(WORK_ORDER_LINE_ITEM_MG);
        if(productTypeSet.contains(productType)){
            return true;
        }else{
            return false;
        }
        
    }

    public static final ID WOLI_INSTALLATION;//Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDeveloperName().get('Installation').getRecordTypeId();
    public static final ID WOLI_REPAIR ;// Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDeveloperName().get('Repair').getRecordTypeId();
    public static final ID WOLI_INSPECTION ;//Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDeveloperName().get('Inspection').getRecordTypeId();
    
    public static Map<String,String> getWorkOrderLineItemRecordTypeMap(){
        /*Map<String, String> WOLI_RT_Map = new Map<String, String>();
        WOLI_RT_Map.put('Installation',WOLI_INSTALLATION);
        WOLI_RT_Map.put('Repair',WOLI_REPAIR);
        WOLI_RT_Map.put('Inspection',WOLI_INSPECTION);*/
        return new Map<String, String>{'Installation' => WOLI_INSTALLATION, 'Repair' => WOLI_REPAIR, 'Inspection' => WOLI_INSPECTION};
    }
    
    /*public static final ID ASMASEProfileId = WorkOrderLineItemSelector.getASMASEProfileId();
    public static final ID ASPProfileId = WorkOrderLineItemSelector.getASPProfileId();
    public static final ID TechnicianProfileId = WorkOrderLineItemSelector.getTechnicianProfileId();
    public static final ID EngineerProfileId = WorkOrderLineItemSelector.getEngineerProfileId();*/

    public static final String CANNOT_UPDATE_COMPLETED_CANCELLED = 'You cannot update a Completed/Cancelled Work Order Line Item';
    public static final String INVALID_OPERATION_OLD_STATUS = 'Invalid operation. Old status must be \'New\' only.';
    public static final String INVALID_STATUS_CANNOT_COMPLETE = 'Invalid status. Only \'Cannot Complete\' is allowed.';
    public static final String INVALID_STATUS_COMPLETED_CANNOT_COMPLETE = 'Invalid status. Only \'Completed\' and \'Cannot Complete\' are allowed.';
    
    
}