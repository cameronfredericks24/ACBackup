global class SAPCaptureInvoiceDetailsAPIReqWrapper {
 
    public List<InvoiceDetails> invoice_details;

    public class InvoiceDetails{
        public String customerCode;
        public String amcContractNumber;
        public String invoiceNumber;
        public String invoiceDate;
        public String invoicePeriodFrom;
        public String invoicePeriodTo;
        public String invoiceAmount;
    }
  

}