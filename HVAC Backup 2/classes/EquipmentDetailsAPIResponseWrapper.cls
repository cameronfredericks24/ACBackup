global class EquipmentDetailsAPIResponseWrapper {
 
        public String status;
        public String message;
        public List<EquipmentFamily> equipments;
    
    
    public class EquipmentFamily {
        public String productFamily;
        public String productFamilyName;
        public List<EquipmentProduct> products;
    }
    
    public class EquipmentProduct {
        public String subFamily;
        public String subFamilyName;
        public String model;
        public String modelName;
        public String componentNo;
        public String serialNumber;
        public String customerId;
    
    
}
}