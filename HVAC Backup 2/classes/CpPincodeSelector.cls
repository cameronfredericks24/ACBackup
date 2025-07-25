public with sharing class CpPincodeSelector {
    public static List<CP_Pincode_Coverage__c> getCpFromPincodes( set<Id> pincodeList) {
        return [Select Id, CP__c, CP__r.Id, CP__r.Name, PinCode__c from CP_Pincode_Coverage__c where PinCode__c In : pincodeList and CP__r.Is_Active__c= true];
    }
}