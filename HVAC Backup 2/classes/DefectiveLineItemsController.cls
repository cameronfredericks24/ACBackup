public without sharing class DefectiveLineItemsController {
        
    @AuraEnabled(cacheable=true)
    public static List<Defective_Product_Item__c> getDefectiveItemList(){
        List<Defective_Product_Item__c> defectList = new  List<Defective_Product_Item__c>();
        String currentUserId = UserInfo.getUserId();
        if(currentUserId != null){
            Account userContact = [SELECT Id, Name FROM Account WHERE CP_User__c = :currentUserId LIMIT 1];
            system.debug('userContact '+ userContact);
            if(userContact != null){
                 defectList =  [SELECT Id, Name,Product_Name_Text__c,Part_Claim_Number_Text__c,Reverse_GRN__c,CreatedDate,Defective_Category__c,Product_Model__c,Created_From_GRN__c,Approval_Status__c FROM Defective_Product_Item__c
                                               WHERE Channel_Partner__c =: userContact.Id and Defective_Category__c !=null and Created_From_GRN__c = true and (Defective_Category__c ='Sales Order' OR (Defective_Category__c='RMR' and Approval_Status__c='Approved'and Approval_Status__c !=null )) order by CreatedDate desc ];
                 
            } else{
               
               defectList =  [SELECT Id, Name, Product_Name_Text__c,Part_Claim_Number_Text__c,Reverse_GRN__c,CreatedDate,Defective_Category__c,Product_Model__c,Created_From_GRN__c FROM Defective_Product_Item__c
                                               WHERE Channel_Partner__c ='0019I00000H9EIOQA3' and Defective_Category__c !=null and Created_From_GRN__c = true and (Defective_Category__c ='Sales Order' OR (Defective_Category__c='RMR' and Approval_Status__c='Approved'and Approval_Status__c !=null )) order by CreatedDate desc ];
              }

        } else {
             defectList =  [SELECT Id, Name, Product_Name_Text__c, Part_Claim_Number_Text__c,Reverse_GRN__c,CreatedDate,Defective_Category__c,Product_Model__c,Created_From_GRN__c FROM Defective_Product_Item__c
                                               WHERE Channel_Partner__c ='001Bi00000ClVRHIA3' and Defective_Category__c !=null and Created_From_GRN__c = true order by CreatedDate desc ];
            
        }
        
      return defectList;
    } 
    
    @AuraEnabled
    public static  List<detailWrapper> checkImages(List<Id> selectedRowIds) {
        List<detailWrapper> resultMap = new  List<detailWrapper>();
        system.debug('records'+ selectedRowIds);
        List<Defective_Product_Item__c> records = [
            SELECT Id, Name, (SELECT Id, ContentDocument.Title FROM ContentDocumentLinks)
            FROM Defective_Product_Item__c 
            WHERE Id IN :selectedRowIds
        ];
       
        for (Defective_Product_Item__c record : records) {
            
            detailWrapper det = new detailWrapper();
            det.name = record.Name;
            if(record.ContentDocumentLinks.isEmpty()){
                det.hasImage = false;
            }else{
                 det.hasImage = true;
            }
          resultMap.add(det);
            
        }

        return resultMap;
    }
    
    
    public class detailWrapper{
         @AuraEnabled
        public String name;
         @AuraEnabled
        public boolean hasImage;
    }

}