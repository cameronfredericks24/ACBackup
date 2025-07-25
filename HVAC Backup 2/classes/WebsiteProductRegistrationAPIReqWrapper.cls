global class WebsiteProductRegistrationAPIReqWrapper {

    public String customer_name;
    public Address billing_address;
    public Address installation_address;
    public String product_type;
    public String model_number;
    public String product_serial_number;
    public String dealer_name;
    public String installation_date;
    public String installed_at;
    public String contact_name;
    public String contact_mobile_number;
    public String contact_email;

    public class Address {
        public String building_apartment_name;
        public String block_flat_no;
        public String street;
        public String locality;
        public String pincode;
        public String state;
        public String city;
        public String telephone_number;
        public String mobile_number;
        public String email;
    }
}