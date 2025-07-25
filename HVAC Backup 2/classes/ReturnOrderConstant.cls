/*
@Author : Himanshi Verma
@CreatedDate : 11th March 2024
@Description : Return Order Object Constant Class.
*/
public with sharing class ReturnOrderConstant {
    Public static final ID recordTypeIdWorkOrder = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get('Installation').getRecordTypeId();
    Public static final ID recordTypeId = Schema.SObjectType.ReturnOrder.getRecordTypeInfosByName().get('FGR').getRecordTypeId();
    Public static final String InstallationWorkTypeName = UtilityClass.getOrgConstantValue('InstallationWorkTypeName');
    Public static final String fgrStatus = UtilityClass.getOrgConstantValue('FGRStatus');
    Public static final String locationTypeDealer = UtilityClass.getOrgConstantValue('Location_Type_Dealer');
    Public static final ID RMR_recordTypeId = Schema.SObjectType.ReturnOrder.getRecordTypeInfosByName().get('RMR').getRecordTypeId();
    Public static final ID FGR_recordTypeId = Schema.SObjectType.ReturnOrder.getRecordTypeInfosByName().get('FGR').getRecordTypeId();
}