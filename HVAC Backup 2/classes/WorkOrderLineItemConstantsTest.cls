@isTest
public class WorkOrderLineItemConstantsTest {
   /* @isTest
    static void testConstants() {
        // Validate Status Constants
        System.assertEquals('New', WorkOrderLineItemConstants.WORK_ORDER_LINE_ITEM_STATUS_NEW);
        System.assertEquals('Replacement Requested', WorkOrderLineItemConstants.WORK_ORDER_LINE_ITEM_STATUS_REPLACEMENT_REQUESTED);
    } */
    
       @isTest
    static void testCheckIfMaterialCostReuquired() {
        // Case 1: Product type requiring material cost (Mixer)
        String productType = WorkOrderLineItemConstants.WORK_ORDER_LINE_ITEM_MG;
        system.debug('productType--'+productType);
        Boolean isMaterialCostRequired = WorkOrderLineItemConstants.checkIfMaterialCostReuquired(productType);
        System.assert(isMaterialCostRequired, 'Material cost should be required for Mixer');
    
        // Case 2: Product type not requiring material cost (Water Purifier)
        productType = 'Water Purifier';
        isMaterialCostRequired = WorkOrderLineItemConstants.checkIfMaterialCostReuquired(productType);
        System.assert(!isMaterialCostRequired, 'Material cost should not be required for Water Purifier');
    }
    
     @isTest
    static void testGetWorkOrderLineItemRecordTypeMap() {
        Map<String, String> recordTypeMap = WorkOrderLineItemConstants.getWorkOrderLineItemRecordTypeMap();
        System.assert(recordTypeMap != null, 'Record type map should not be null');
        System.assertEquals(3, recordTypeMap.size(), 'Record type map should contain 3 entries');
        //System.assert(recordTypeMap.get('Installation') == 'MockInstallationId');
    }

    


   /* @isTest
    static void testCheckIfMaterialCostRequired() {
        Boolean isMaterialCostRequired = WorkOrderLineItemConstants.checkIfMaterialCostReuquired(WorkOrderLineItemConstants.WORK_ORDER_LINE_ITEM_MG);
        System.assert(isMaterialCostRequired, 'Material cost should be required for Mixer');
    }

    @isTest
    static void testGetWorkOrderLineItemRecordTypeMap() {
        Map<String, String> recordTypeMap = WorkOrderLineItemConstants.getWorkOrderLineItemRecordTypeMap();
        System.assert(recordTypeMap != null, 'Record type map should not be null');
        System.assertEquals(3, recordTypeMap.size(), 'Record type map should contain 3 entries');
        System.assert(recordTypeMap.get('Installation') == 'MockInstallationId');
    }

    @isTest
    static void testErrorMessages() {
        System.assertEquals('You cannot update a Completed/Cancelled Work Order Line Item', WorkOrderLineItemConstants.CANNOT_UPDATE_COMPLETED_CANCELLED);
    } */
}