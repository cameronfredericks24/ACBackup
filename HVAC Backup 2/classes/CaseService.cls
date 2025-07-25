/*
@Author : Divya nainava
@CreatedDate : 10th Jan 2024
@Description : Generic class for finding the channel partner based on pincode, product and service type.
*/
public with sharing class CaseService {

    public static PurchaseDetailWrapper getChannelPartner(PurchaseDetailWrapper areaRouting){

        system.debug('areaRouting.pinCode'+areaRouting.pinCode);
        //system.debug('areaRouting.productFamily.Id'+areaRouting.productFamily.Id);
        //system.debug('areaRouting.department.Department_Number__c'+areaRouting.department.Department_Number__c);
        system.debug('areaRouting.callType'+areaRouting.callType);

        try{

            String productFamilyId= (areaRouting.productFamily!=null) ? areaRouting.productFamily.Id : null;
            String department = (areaRouting.department!=null) ? areaRouting.department.Department_Number__c : null;

            List<Service_Area_Routing__c> SARList = [Select Channel_Partner__c,Channel_Partner__r.SDE__C,Channel_Partner__r.Id,Channel_Partner__r.Name from Service_Area_Routing__c 
                    where Pincode__r.Postal_Code__c = :areaRouting.pinCode and Product_Family__c = :productFamilyId and Department__r.Department_Number__c =: department and Call_Type__c = :areaRouting.callType and Channel_Partner__r.Is_Active__c=true and Channel_Partner__r.Bad_TAT_Ratings__c = false];

            if(SARList.size()==0){
                SARList = [Select Channel_Partner__c,Channel_Partner__r.Id, Channel_Partner__r.SDE__C,Channel_Partner__r.Name from Service_Area_Routing__c 
                    where Pincode__r.Postal_Code__c = :areaRouting.pinCode and Department__r.Department_Number__c =: department and Call_Type__c = :areaRouting.callType and Channel_Partner__r.Is_Active__c=true and Channel_Partner__r.Bad_TAT_Ratings__c = false and Product_Family__c=null];
            }

            if(SARList.size()==0 && areaRouting.sector!=null && areaRouting.sector!=''){
                SARList = [Select Channel_Partner__c, Channel_Partner__r.Id,Channel_Partner__r.SDE__C, Channel_Partner__r.Name from Service_Area_Routing__c 
                    where Sector__c = :areaRouting.sector and Department__r.Department_Number__c =: department and Channel_Partner__r.Is_Active__c=true and Channel_Partner__r.Bad_TAT_Ratings__c = false and Product_Family__c=null and Call_Type__c = null];
            }

            if(SARList.size()==0 ){
                SARList = [Select Channel_Partner__c,Channel_Partner__r.Id, Channel_Partner__r.SDE__C,Channel_Partner__r.Name from Service_Area_Routing__c 
                    where Pincode__r.Postal_Code__c = :areaRouting.pinCode and Department__r.Department_Number__c =: department and Channel_Partner__r.Is_Active__c=true and Channel_Partner__r.Bad_TAT_Ratings__c = false and Product_Family__c=null and Call_Type__c = null ];
            }

            if(SARList.size() > 0){
                Set<Id> cpIds = new Set<Id>();
                Map<Id, Account> cpIdToAccount = new Map<Id,Account>();
                for(Service_Area_Routing__c SAR : SARList){
                    if(SAR.Channel_Partner__c!=null){
                        cpIds.add(SAR.Channel_Partner__c);
                        cpIdToAccount.put(SAR.Channel_Partner__c,SAR.Channel_Partner__r);
                    }
                }

                if(cpIds.size()>0){
                    //Assuming one Service Territoty will have one channel partner
                    Map<Id,User> channelPartnerToUserMap = new Map<Id,User>();
                    List<ServiceTerritory> serviceTerritory = ServiceTerritorySelector.getServiceTerritorybyCP(cpIds);
                    Map<Id, Id> CpToStMap = new Map<Id, Id>();
                    for(serviceTerritory stRecord : serviceTerritory){
                        CpToStMap.put(stRecord.Channel_Partner_Account__c, stRecord.Id);
                    }

                    //Get the users from partner accounts
                    List<User> channelPartnerUsers = UserSelector.getUserByCP(cpIds);
                    for(User userRecord : channelPartnerUsers){
                        channelPartnerToUserMap.put(userRecord.Contact.AccountId, userRecord);
                    }

                    //set<Id> idList = new set<Id>(cpIds);
                    List<Id> idList = new List<Id>(cpIds);
                    Integer randomIndex = (Integer)Math.floor(Math.random() * idList.size());
                    String randomId = idList[randomIndex];
                    System.debug('Randomly selected ID: ' + randomId);
                    
                    Account channelPartner = cpIdToAccount.get(randomId);
                    areaRouting.channelPartner = channelPartner;

                    //assign service territory
                    if(CpToStMap.get(channelPartner.Id)!=null){
                        areaRouting.serviceTerritory = new ServiceTerritory(Id=CpToStMap.get(channelPartner.Id));
                    }
                    
                    //Assign partner user
                    if(channelPartnerToUserMap.get(channelPartner.Id)!=null){
                        areaRouting.channelPartnerUser =channelPartnerToUserMap.get(channelPartner.Id);
                    }
                }      
            }
            return areaRouting;
        }catch(Exception e){
            throw e;
        }
    }

    public class PurchaseDetailWrapper{
        public String pinCode;
        public String city;
        public decimal latitude;
        public decimal longitude;
        public Boolean searchBySector;
        public Product2 productRecord;
        public Product_Family__c productSubFamily;
        public Product_Family__c productFamily;
        public ServiceTerritory serviceTerritory;
        public String callType;
        public Account channelPartner;
        @AuraEnabled
        public User channelPartnerUser;
        @AuraEnabled
        public User sde;
        @AuraEnabled
        public String errorMessage;
        public Branch_Division__c branchSDE;
        public pincode__c pincodeBranch;
        public Date preferredSlot;
        public Department__c department;
        public string sector;
    }

}