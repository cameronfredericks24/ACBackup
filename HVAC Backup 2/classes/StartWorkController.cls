// StartWorkController.cls
public with sharing class StartWorkController {
    @AuraEnabled
    public static WorkOrder getWorkRecord(Id recordId) {
        return [SELECT Id, Status FROM WorkOrder WHERE Id = :recordId];
    }
    @AuraEnabled(cacheable=true)
    public static Boolean isWorkOrderRejected(Id recordId) {
        // Query the work order record to check its status
        WorkOrder workOrder = [SELECT Status FROM WorkOrder WHERE Id = :recordId LIMIT 1];
        
        // Check if the status is 'Rejected'
        if (workOrder != null && workOrder.Status == 'Rejected') {
            return true;
        }
        return false;
    }
    @AuraEnabled(cacheable=true)
    public static Boolean isWorkOrderCompleted(Id recordId) {
        // Query the work order record to check its status
        WorkOrder workOrder = [SELECT Status FROM WorkOrder WHERE Id = :recordId LIMIT 1];
        
        // Check if the status is 'Completed'
        if (workOrder != null && workOrder.Status == 'Completed') {
            return true;
        }
        return false;
    }
    
    @AuraEnabled
    public static void rejectServiceAppointment(Id workOrderId ,String rejectReason, String rejectComment) {
        // Query related Service Appointments
        List<ServiceAppointment> serviceAppointments = [
            SELECT Id, Status 
            FROM ServiceAppointment 
            WHERE Work_Order__c = :workOrderId order by CreatedDate desc Limit 1
        ];
        
        if (!serviceAppointments.isEmpty()) {
            for (ServiceAppointment appointment : serviceAppointments) {
                appointment.Status = 'Rejected';
                appointment.Reject_Reason__c = rejectReason;
                appointment.Reject_Comments__c = rejectComment;
            }
            update serviceAppointments;
        }
    }
    
    
}