public with sharing class ServiceAppointmentController {
    public class ServiceAppointmentWrapper {
        @AuraEnabled public String serviceAppointmentId;
        @AuraEnabled public Decimal latitude;
        @AuraEnabled public Decimal longitude;
        @AuraEnabled public String status;
    }

    @AuraEnabled
    public static Boolean updateServiceAppointmentLocation(ServiceAppointmentWrapper wrapper) {
        Boolean isSuccess = false;
        // Retrieve the ServiceAppointment record
        List<ServiceAppointment> serviceAppointments = [SELECT Id, Start_Latitude__c, Start_Logitude__c, End_Latitude__c, End_Logitude__c FROM ServiceAppointment WHERE Id = :wrapper.serviceAppointmentId];

        if (!serviceAppointments.isEmpty()) {
            ServiceAppointment serviceAppt = serviceAppointments[0];

            // Update the location fields based on status
            if (wrapper.status.equals('In Progress')) {
                serviceAppt.Start_Latitude__c = wrapper.latitude;
                serviceAppt.Start_Logitude__c = wrapper.longitude;
            } else if (wrapper.status.equals('Completed')) {
                serviceAppt.End_Latitude__c = wrapper.latitude;
                serviceAppt.End_Logitude__c = wrapper.longitude;
            }

            // Update the record
            try {
                update serviceAppt;
                isSuccess = true;
            } catch (Exception ex) {
                isSuccess = false;
                // Handle exception
            }
        } else {
            // Handle the case where no records were found
            System.debug('No ServiceAppointment record found with Id: ' + wrapper.serviceAppointmentId);
        }
        return isSuccess;
    }
}