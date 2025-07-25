public class ServiceReportTriggerHelper {
    
    
    public static void callTrigger(List<ServiceReport> newReports){
        if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            ServiceReportTriggerHandler.beforeInsert(newReports);
        }
    }
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            ServiceReportTriggerHandler.afterInsert(newReports);
        }
    }
    } 
    
    
    
    public static void handleBeforeInsert(List<ServiceReport> newReports) {
        Set<Id> setOfOwners = new Set<Id>();
        Map<Id,Id> setOfWO = new Map<Id,Id>();
        
        Set<Id> ifReportExists = new Set<Id>();
        Map<Id, String> workOrderStatusMap = new Map<Id, String>();
        
        // Collect ParentIds
        for(ServiceReport sr : newReports) {
            sr.IsSigned = true;
            setOfOwners.add(sr.ParentId);
        }

        system.debug('setOfOwners: ' + setOfOwners);

        
        // Query existing ServiceReports
        for(ServiceAppointment sa : [SELECT Id, Work_order__c FROM ServiceAppointment WHERE Id IN :setOfOwners]) {
            setOfWO.put(sa.Id,sa.Work_order__c);
        }
        // Query existing ServiceReports
        for(ServiceReport sr : [SELECT Id, ParentId FROM ServiceReport WHERE ParentId IN :setOfOwners]) {
            ifReportExists.add(sr.ParentId);
        }
        
        // Query WorkOrder statuses
        for(WorkOrder wo : [SELECT Id, Status FROM WorkOrder WHERE Id IN :setOfWO.values()]) {
            workOrderStatusMap.put(wo.Id, wo.Status);
        }
        
        system.debug('ifReportExists: ' + ifReportExists);
        system.debug('workOrderStatusMap: ' + workOrderStatusMap);
        system.debug('setOfWO: ' + setOfWO);
        
        // Validate the ServiceReports
        for(ServiceReport sr : newReports) {
            System.debug('parentid: '+sr.ParentId);
            if(ifReportExists.contains(sr.ParentId)) {
                sr.addError('Service Report has already been generated for this Service Appointment.');
            }
            if(workOrderStatusMap.get(setOfWO.get(sr.ParentId)) != 'Completed') {
                sr.addError('Please complete the appointment before generating FSR.');
            }
        }
    }
}