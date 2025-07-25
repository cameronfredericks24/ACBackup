public class GenericTicketCreationAPIRequestWrapper {
    public String source;
    public String phone_number;
    public String customer_name;
    public String email;
    public String product_name;
    public String model_number;
    public String ticket_type;
    public Address billing_address;
    public Address installation_address;

    public class Address {
        public String builder_apartment_name;
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