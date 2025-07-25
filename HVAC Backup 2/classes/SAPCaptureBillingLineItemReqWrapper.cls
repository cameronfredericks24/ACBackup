global class SAPCaptureBillingLineItemReqWrapper {
    public String contract_number;
    public String status;
    public List<BillingLine> billing_lines;

    public class BillingLine {
        public String start_date;
        public String end_date;
        public String billing_due_date;
        public String amount;
        public String billing_line_number;
        public String billing_term;
    }
}