/*
@Author : Abhijeet Ojha
@CreatedDate : 15th March 2024
@Description : Capture Warehouse Details from SAP.
*/
global class SAPCaptureWareHouseMasterRequestWrapper {
    public List<WareHouseDetails> warehousedetails;
    public class WareHouseDetails{
        public String warehouseCode;
        public String type;
        public String subTypeCode;
        public String isActive;
        public String warehouseName;
        public String warehouseType;
        public String addressLine1;
        public String addressLine2;
        public String addressLine3;
        public String addressLine4;
        public String city;
        public String state;
        public String country;
        public String pincode;
        public String email;
        public String phone;
        public String gst;
        public String pan;


    }
}