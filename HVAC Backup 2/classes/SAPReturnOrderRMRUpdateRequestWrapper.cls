/*
@Author : Abhijeet Ojha
@CreatedDate : 14th March 2024
@Description : Sync the Return Order status from SAP
*/
global class SAPReturnOrderRMRUpdateRequestWrapper {
    public String sapRMRNumber;
    public String status;
    public String obdNumber;
    public String locationFrom;
    public String locationTo;
    public Date expectedDeliveryDate;
    public Date actualDeliveryDate;

}