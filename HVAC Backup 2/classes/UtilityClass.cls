/*
@Author : Kunal Nadkarni
@CreatedDate : 16th Jan 2024
@Description : Generic utility class.
@Last Modified By :Deepanshu on 20 Feb 2024 for adding getRecordTypeIdByDeveloperName Method
*/
public without sharing class UtilityClass {
    /*
    @Author : Kunal Nadkarni
    @CreatedDate : 16th Jan 2024
    @Description : Return the constant value from custom metadata.
    @Parameter : String constantVariable
    */
    public static String getOrgConstantValue(String constantVariable){
        return Org_Constant__mdt.getInstance(constantVariable).Constant_Value__c;
    }

    
	 /*
    @Author :Deepanshu Tyagi
    @CreatedDate : 20th Feb 2024
    @Description : Return the RecordId.
    @Parameter : String Object Name and String RecordTypeName
    */
    public static Map<String,Id> recordTypeIdMap = new Map<String,Id>();
    
    public static Id getRecordTypeIdByDeveloperName(String objApiName,String recordTypeName) {
        if(recordTypeIdMap.containsKey(objAPIName+'-'+recordTypeName)){
            return recordTypeIdMap.get(objAPIName+'-'+recordTypeName);
        } else {
            Id recordTypeId = Schema.getGlobalDescribe().get(objAPIName).getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
            recordTypeIdMap.put(objAPIName+'-'+recordTypeName, recordTypeId);
            return recordTypeId;
        }
    }
    	 /*
    @Author :Deepanshu Tyagi
    @CreatedDate : 22th Feb 2024
    @Description : Return the Id of EntitlementId.
    @Parameter : String  Name;
    */
  public static List<entitlement>  getEntitlementId(String name){
List<entitlement> enList =[ select id,AccountId from entitlement where Name=:name limit 1];
return enList;

}
    
public static Decimal getDateDifferenceWithBusinessHours(String businessHoursId, Datetime startDate, Datetime endDate){
    long diffInMillis =BusinessHours.diff(businessHoursId,startDate,endDate);
    system.debug('diffInMillis'+diffInMillis);
    //Convert milliseconds to hours
    Decimal diffInHours = ((decimal)diffInMillis / 3600000).setScale(2);
       System.debug(diffInHours);
    return diffInHours;
}
    /*
    @Author :Sanket Anand
    @CreatedDate : 20th March 2024
    @Description : Return the fields in a given FieldSet.
    @Parameter : String  FieldSetName, String ObjectName;
    */
public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName)
{
    Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
    Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
    Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();

    Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);

    return fieldSetObj.getFields(); 
}  

public static list<Schema.Location> getLocationByCode(String warehouseCode){

    return[select id,Warehouse_Code__c,
          (select id,Product2Id,Product2.productCode,LocationId,Location.Warehouse_Code__c from ProductItems) 
          from Location where Warehouse_Code__c=:warehouseCode LIMIT 1];
}

public static List<Schema.Location> getLocationsByCodes(Set<String> warehouseCodes) {
    return [SELECT Id, Name,Warehouse_Code__c, (SELECT Id,Product2Id, Product2.ProductCode, QuantityOnHand FROM ProductItems) 
            FROM Location WHERE Warehouse_Code__c IN :warehouseCodes];
}


	 /*
    @Author :Sumukha N S
    @CreatedDate : 24th Apr 2024
    @Description : Returns the Record.
    @Parameter :
    */
public static sObject getRecordById(String sObjectType, List<String> fields, Id recordId) {
    // Check for null or empty parameters to avoid errors
    if (String.isBlank(sObjectType) || fields == null || fields.isEmpty() || recordId == null) {
        throw new IllegalArgumentException('Invalid arguments provided.');
    }

    // Construct the SOQL query string
    String queryString = 'SELECT ' + String.join(fields, ', ') + ' FROM ' + sObjectType + ' WHERE Id = :recordId LIMIT 1';

    // Execute the dynamic query
    List<sObject> results = Database.query(queryString);

    // Return the first record if available
    if (!results.isEmpty()) {
        return results[0];
    }

    return null;
}

}