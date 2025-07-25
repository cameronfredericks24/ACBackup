public class SerialNumberValidationSAPResponseWrapper {
    public String INVOICE_NUMBER;
    public String INVOICE_DATE;
    public String CUSTOMER_CODE;
    public String DEPARTMENT;
    public String BRANCH_CODE;
    public String CP_CODE;


    public list<Product> PRODUCT;



    // public list<AssetDetailsWrapper> PRODUCT;
    
    public class Product {
        public String IS_INSTALLABLE;
        public String MODEL_CODE;
        public String SERIAL_NUMBER;
        public String MANUFACTURING_DATE;
        public list<ChildProduct> CHILD_PRODUCTS;

        public List<Subcomponent> SUBCOMPONENT;
    }
    
   
    public class Subcomponent {
        public String MODEL_CODE;
        public String SERIAL_NUMBER;
        public String MANUFACTURING_DATE;
    }

    public class ChildProduct {
        public String IS_INSTALLABLE;
        public String MODEL_CODE;
        public String SERIAL_NUMBER;
        public String MANUFACTURING_DATE;
        public List<Subcomponent> SUBCOMPONENT;
    }
}