global class SAPCaptureSaleorderResponseWrapper {
    public String result { get; set; }
    public String message { get; set; }

    // Constructor to initialize fields
    global SAPCaptureSaleorderResponseWrapper(String result, String message) {
        this.result = result;
        this.message = message;
    }
    
    global SAPCaptureSaleorderResponseWrapper(){}
}