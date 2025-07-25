public with sharing class ServiceAppointmentSelector {
   
    public static Map<String, Integer> getServiceAppointmentCount(Set<Date> preferredSlotsList, Set<Id> cpIds){
        Map<Id, WorkOrder> workOrderMap = new Map<Id, WorkOrder>([select Id, OwnerId from WorkOrder where CP__c In : cpIds]);
        system.debug('workOrderMap'+workOrderMap);
        Map<String, Integer> cpToCPCount = new  Map<String, Integer>();
        if(workOrderMap.size()>0){
            List<ServiceAppointment> ServiceAppointmentCount = [select Id,ParentRecordId,SchedStartTime from ServiceAppointment where DAY_ONLY(SchedStartTime) In : preferredSlotsList and ParentRecordId In : workOrderMap.keySet()];
            system.debug('ServiceAppointmentCount'+ServiceAppointmentCount);
            for(ServiceAppointment appointment : ServiceAppointmentCount){
                if(workOrderMap.get(appointment.ParentRecordId)!=null){
                    String key = workOrderMap.get(appointment.ParentRecordId).ownerId + String.valueOf((appointment.SchedStartTime).date());
                    if(cpToCPCount.get(key)==null){
                        cpToCPCount.put(key,1);
                    }else{
                        cpToCPCount.put(key,cpToCPCount.get(key)+1);
                    }
                }              
            }
        }
        system.debug('cpToCPCount'+cpToCPCount);
        return cpToCPCount;
    }

    public static List<ServiceAppointment> getServiceAppointment(STring recordId){
        return [select Id, ParentRecordId from ServiceAppointment where Id = :recordId];
    }

      /*
    @Author : 
    @CreatedDate : 3rd April 2024
    @Description : Method to retrieve Service Appointments based on parentRecordId
    Last Modified By : Mamta S
    */

        public static List<ServiceAppointment> getServiceAppt(Id parentRecordId) {
            List<ServiceAppointment> serviceAppointments = [SELECT Id, ParentRecordId, Service_Resource__r.Id 
                                                            FROM ServiceAppointment 
                                                            WHERE ParentRecordId = :parentRecordId];
            return serviceAppointments;
        }

}