public without sharing class WarrantyTermSelector {
    /*
@Author : Anshika Jain
@CreatedDate : 12th MAR 2024
@Description : get active warranty
*/
    public static List<WarrantyTerm> getActiveWarranty(){
        return [SELECT Id,WarrantyTermName, End_Date__c, Start_Date__c, Policy_Sub_Type__c, WarrantyType, EffectiveStartDate, WarrantyDuration, Approval_Status__c,WarrantyUnitOfTime,
                  (SELECT Id, Branch__c, Branch_Operator__c, Brand__c, Customer_SubType__c, Customer_SubType_Operator__c, Installation_date_operator__c, 
                   Installation_From__c, Installation_To__c, Modals__c, Model_Operator__c, Name, Namo__c, Product_Family__c, Product_family_Operator__c,
                   Product_Sub_Family_Operator__c, Product_Sub_Family__c,Registration_Source__c,UOM_Operator__c,Capacity_UOM__c
                   FROM Warranty_Conditions__r)
                FROM WarrantyTerm 
                WHERE Approval_Status__c = 'Approved' 
                AND Start_Date__c <= TODAY 
                AND End_Date__c >= TODAY
                AND IsActive = true
               ];
    }
}