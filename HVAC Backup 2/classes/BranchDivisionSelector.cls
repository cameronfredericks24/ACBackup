public with sharing class BranchDivisionSelector {
    /*
    @Author : Divya Nainava
    @CreatedDate : 12 Mar 2024
    @Description : To get the branch SDE based on pincode and division
    */
    
    public static List<Branch_Division__c> getBranch(String branchId, String division){  
        List<Branch_Division__c> returnList = new List<Branch_Division__c>();
        List<Branch_Division__c> branchSDE = [Select Id,Branch__c, Service_SDE__c,Service_RM__c,Service_AM__c,Service_SDH__c from Branch_Division__c where Department__r.Department_Number__c = :division and Branch__c = : branchId];
        for (Branch_Division__c bdRecord : branchSDE){
            if(bdRecord.Service_SDE__c!=null){
                returnList.add(bdRecord);
                break;
            }
        }

        if(returnList.size()>0){
            for (Branch_Division__c bdRecord : branchSDE){
                if(bdRecord.Service_SDH__c!=null){
                    returnList.add(bdRecord);
                    break;
                }
            }
        }

        if(returnList.size()>0){
            for (Branch_Division__c bdRecord : branchSDE){
                if(bdRecord.Service_RM__c!=null){
                    returnList.add(bdRecord);
                    break;
                }
            }
        }

        if(returnList.size()>0){
            for (Branch_Division__c bdRecord : branchSDE){
                if(bdRecord.Service_AM__c!=null){
                    returnList.add(bdRecord);
                    break;
                }
            }
        }
        
        return branchSDE;
    }

    public static List<PinCode__c> getPincode(String pincode, String sector){
        List<PinCode__c> pincodeBranch = new List<PinCode__c>();
        if(sector!=null){
            pincodeBranch = [Select Id, Branch__c from PinCode__c where Postal_Code__c = :pincode and Sector__c=:sector];
        }
        else{
            pincodeBranch = [Select Id, Branch__c from PinCode__c where Postal_Code__c = :pincode];
        }
        return pincodeBranch;
    }

}