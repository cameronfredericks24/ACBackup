Global class SAPAPIResponse {
   
    @AuraEnabled
    public String ItemCode { get; set; }
    @AuraEnabled
    public String ItemDescription { get; set; }
    @AuraEnabled
    public String MfgDate { get; set; }
    @AuraEnabled
    public String invoiceDate { get; set; }
    @AuraEnabled
    public String invoiceNumber { get; set; }

    public static List<SAPAPIResponse> parse(String json) {
		return (List<SAPAPIResponse>) System.JSON.deserialize(json, List<SAPAPIResponse>.class);
	}
}