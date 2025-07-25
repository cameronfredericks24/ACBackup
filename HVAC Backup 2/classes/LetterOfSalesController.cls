public class LetterOfSalesController {
    public String serviceTicketNum { get; set; }
    public String customerName { get; set; }
    public String customerAddress { get; set; }
    public String customerShipAddress { get; set; }
    public String customerPhone { get; set; }
    public String placeOfSupply { get; set; }
    public String customerGSTIN { get; set; }
    public String customerPanNumber { get; set; }
    public String orderBillDate { get; set; }
    public String orderType { get; set; }
    public String status { get; set; }

    public List<ProductRequestWrapper> productRequestWrapperList { get; set; }
    public Decimal breakdownOrInstallationCharge { get; set; }
    public Decimal gasCharge { get; set; }
    public Decimal otherCharge { get; set; }
    public Decimal otherMaterial { get; set; }
    public Decimal spareCharge { get; set; }
    public Decimal totalAmount { get; set; }
    public Decimal totalCGST { get; set; }
    public Decimal totalSGST { get; set; }
    public Decimal totalIGST { get; set; }
    public Decimal totalSTCess { get; set; }
    public Decimal subTotal { get; set; }
    public Decimal taxAmount { get; set; }
    public String totalAmountWords { get; set; }
    public String workTypeName { get; set; }
    public boolean igstSelected { get; set; }
    public boolean spareLineAvailable { get; set; }
    public boolean isCommercial { get; set; }


    public LetterOfSalesController(ApexPages.StandardController controller) {
        Id workOrderId = ApexPages.currentPage().getParameters().get('id');
        if (workOrderId != null) {
            fetchCustomerInfo(workOrderId);
            fetchProductDetails(workOrderId);
            calculateCharges(workOrderId);
        }
    }

    public void fetchCustomerInfo(Id workOrderId) {
        WorkOrder custDetails = [
            SELECT Id, Ticket_Number_Read_Only__c, Visiting_Charges__c,Spare_Charge__c,WorkOrderNumber, Account.Name, 
                   Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.RecordType.developerName,
                   Account.BillingPostalCode,Account.ShippingCity,Account.ShippingPostalCode, Account.ShippingState, Account.ShippingStreet, Account.Phone, Account.GST_Number__c, 
                   Account.PAN_Number__c, WorkType.Name, Breakdown_Charges__c, Installation_Charges__c,IGST__c
            FROM WorkOrder 
            WHERE Id = :workOrderId 
            LIMIT 1
        ];

        serviceTicketNum = custDetails.Ticket_Number_Read_Only__c != null ? custDetails.Ticket_Number_Read_Only__c : '';
        customerName = custDetails.Account != null && custDetails.Account.Name != null ? custDetails.Account.Name : '';
        customerPhone = custDetails.Account != null && custDetails.Account.Phone != null ? custDetails.Account.Phone : '';
        placeOfSupply = custDetails.Account != null && custDetails.Account.BillingState != null ? custDetails.Account.BillingState : '';
        isCommercial = custDetails.Account.RecordType.developerName=='Commercial_Customer' ? true : false ;

        customerAddress = '';
        if (custDetails.Account != null) {
            if(custDetails.Account.BillingPostalCode != null){
                if (custDetails.Account.BillingStreet != null && !custDetails.Account.BillingStreet.trim().equals('')) {
                    customerAddress += custDetails.Account.BillingStreet + ', ';
                }
                if (custDetails.Account.BillingCity != null && !custDetails.Account.BillingCity.trim().equals('')) {
                    customerAddress += custDetails.Account.BillingCity + ', ';
                }
                if (custDetails.Account.BillingState != null && !custDetails.Account.BillingState.trim().equals('')) {
                    customerAddress += custDetails.Account.BillingState + ', ';
                }
                if (custDetails.Account.BillingPostalCode != null && !custDetails.Account.BillingPostalCode.trim().equals('')) {
                    customerAddress += custDetails.Account.BillingPostalCode;
                }
            }if(custDetails.Account.ShippingPostalCode != null){
                if (custDetails.Account.ShippingStreet != null && !custDetails.Account.ShippingStreet.trim().equals('')) {
                    customerShipAddress += custDetails.Account.ShippingStreet + ', ';
                }
                if (custDetails.Account.ShippingCity != null && !custDetails.Account.ShippingCity.trim().equals('')) {
                    customerShipAddress += custDetails.Account.ShippingCity + ', ';
                }
                if (custDetails.Account.ShippingState != null && !custDetails.Account.ShippingState.trim().equals('')) {
                    customerShipAddress += custDetails.Account.ShippingState + ', ';
                }
                if (custDetails.Account.ShippingPostalCode != null && !custDetails.Account.ShippingPostalCode.trim().equals('')) {
                    customerShipAddress += custDetails.Account.ShippingPostalCode;
                }
            }
           
        }
        
        customerGSTIN = custDetails.Account != null && custDetails.Account.GST_Number__c != null ? custDetails.Account.GST_Number__c : '';
        customerPanNumber = custDetails.Account != null && custDetails.Account.PAN_Number__c != null ? custDetails.Account.PAN_Number__c : '';

        igstSelected = custDetails.IGST__c;
        
        Date readableDate = System.today();
        Datetime dt = DateTime.newInstance(readableDate.year(), readableDate.month(), readableDate.day());
        orderBillDate = dt != null ? dt.format('MMMM d, yyyy') : '';
        orderType = 'Letter of Sales';
        status = 'Billed';

        // Set the WorkType Name for conditional rendering
        workTypeName = custDetails.WorkType != null && custDetails.WorkType.Name != null ? custDetails.WorkType.Name : '';

        // Set the Breakdown or Installation charge based on WorkType
        if (custDetails.WorkType != null && custDetails.WorkType.Name == 'Breakdown') {
            breakdownOrInstallationCharge = custDetails.Breakdown_Charges__c != null ? custDetails.Breakdown_Charges__c : 0;
        } else if (custDetails.WorkType != null && custDetails.WorkType.Name == 'Installation') {
            breakdownOrInstallationCharge = custDetails.Installation_Charges__c != null ? custDetails.Installation_Charges__c : 0;
        } else {
            breakdownOrInstallationCharge = 0;
        }
    }

    public void fetchProductDetails(Id workOrderId) {
        productRequestWrapperList = new List<ProductRequestWrapper>();

        // Query ProductRequest records and related Product records
        List<ProductRequest> productRequestList = [
            SELECT Id, Quantity__c, Spare_Price__c, Product__r.HSN_No__c, 
                   Product__r.Code__c, Product__r.Product_Category__c,Product__r.Material_Group__c
            FROM ProductRequest
            WHERE WorkOrderId = :workOrderId
        ];

        // Collect unique HSN Codes
        Set<String> hsnCodes = new Set<String>();
        for (ProductRequest pr : productRequestList) {
            if (pr.Product__r != null && pr.Product__r.HSN_No__c != null) {
                hsnCodes.add(pr.Product__r.HSN_No__c);
            }
        }

        // Query HSNCode_Tax__c Object based on HSN Codes
        Map<String, HSNCode_Tax__c> hsnTaxMap = new Map<String, HSNCode_Tax__c>();
        if (!hsnCodes.isEmpty()) {
            List<HSNCode_Tax__c> hsnCodeTaxList = [
                SELECT HSN_Code__c, CGST__c, SGST__c, IGST__c
                FROM HSNCode_Tax__c
                WHERE HSN_Code__c IN :hsnCodes
            ];

            // Map HSN Code to corresponding Tax details
            for (HSNCode_Tax__c tax : hsnCodeTaxList) {
                if (tax.HSN_Code__c != null) {
                    hsnTaxMap.put(tax.HSN_Code__c, tax);
                }
            }
        }

        // Create wrappers and populate them with ProductRequest and tax details
        for (ProductRequest pr : productRequestList) {
            HSNCode_Tax__c taxDetails = hsnTaxMap.get(pr.Product__r != null ? pr.Product__r.HSN_No__c : null);
            ProductRequestWrapper wrapper = new ProductRequestWrapper(pr, taxDetails);
            productRequestWrapperList.add(wrapper);
        }
        if(productRequestWrapperList.size()>0){
            spareLineAvailable = true;
        }
    }

    public void calculateCharges(Id workOrderId) {
        // Query the WorkOrder record based on the provided workOrderId
        WorkOrder workOrder = [
            SELECT WorkType.Name, Breakdown_Charges__c, Installation_Charges__c, 
                   labour_Charges__c, Total_Other_Amount__c,Visiting_Charges__c,Spare_Charge__c, (Select Id, Total_Amount__c from Local_Purchases__r)
            FROM WorkOrder
            WHERE Id = :workOrderId
            LIMIT 1
        ];

        // Determine Breakdown or Installation Charge based on WorkType
        if (workOrder.WorkType != null && workOrder.WorkType.Name != 'Installation' && !workOrder.WorkType.Name.contains('PMS') &&  workOrder.WorkType.Name != 'Regular Service' && workOrder.WorkType.Name !='Commissioning') {
            breakdownOrInstallationCharge = workOrder.Visiting_Charges__c != null ? workOrder.Visiting_Charges__c : 0;
        } else if (workOrder.WorkType != null && workOrder.WorkType.Name == 'Installation') {
            breakdownOrInstallationCharge = workOrder.Installation_Charges__c != null ? workOrder.Installation_Charges__c : 0;
        } else {
            breakdownOrInstallationCharge = 0;
        }

        // Get other charges
        gasCharge = workOrder.labour_Charges__c != null ? workOrder.labour_Charges__c : 0;
        otherCharge = workOrder.Total_Other_Amount__c != null ? workOrder.Total_Other_Amount__c : 0;

        // Calculate Spare Charge from ProductRequestWrapper
        spareCharge = 0;
        totalCGST = 0;
        totalSGST = 0;
        totalIGST = 0;

        for (ProductRequestWrapper wrapper : productRequestWrapperList) {
            Decimal quantity = wrapper.productRequest.Quantity__c != null ? wrapper.productRequest.Quantity__c : 0;
            Decimal sparePrice = wrapper.productRequest.Spare_Price__c != null ? wrapper.productRequest.Spare_Price__c : 0;
            Decimal chargeForCurrentWrapper = quantity * sparePrice;
            spareCharge += chargeForCurrentWrapper;

            // Calculate total taxes
            totalCGST += (wrapper.CGST != null ? wrapper.CGST : 0) * chargeForCurrentWrapper / 100;
            totalSGST += (wrapper.SGST != null ? wrapper.SGST : 0) * chargeForCurrentWrapper / 100;
            totalIGST += (wrapper.IGST != null ? wrapper.IGST : 0) * chargeForCurrentWrapper / 100;
        }

        // Calculate Total Amount
        
        otherMaterial = 0;

        if(workOrder!=null){
            for(Local_purchase__c lp : workOrder.Local_Purchases__r){
                otherMaterial+=lp.Total_Amount__c;
            }
        }
        spareCharge +=totalIGST;
        spareCharge = spareCharge.setScale(2);

        totalAmount = (breakdownOrInstallationCharge + gasCharge + otherCharge + spareCharge + otherMaterial).setScale(2);

        // Calculate SubTotal and Tax Amount
        taxAmount = (totalIGST).setScale(2);
        subTotal = totalAmount.setScale(2);
        totalAmountWords = convertNumberToWords(subTotal);
    }

    private static final List<String> units = new List<String>{
        '', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten', 
        'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'
    };

    private static final List<String> tens = new List<String>{
        '', // 0
        '', // 1
        'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'
    };

    private static final List<String> thousands = new List<String>{
        '', 'Thousand', 'Lakh', 'Crore'
    };

    public static String convertNumberToWords(Decimal no) {
        if (no == null) {
            return 'Zero';
        }
        
        String[] numberParts = String.valueOf(no.setScale(2)).split('\\.');
        Integer integerPart = Integer.valueOf(numberParts[0]);
        Integer decimalPart = numberParts.size() > 1 ? Integer.valueOf(numberParts[1]) : 0;

        return convert(integerPart) + (decimalPart > 0 ? ' and paise ' + convert(decimalPart) : '');
    }

    private static String convert(Integer no) {
        if (no < 20) {
            return units[no];
        }

        if (no < 100) {
            return tens[no / 10] + (Math.mod(no, 10) != 0 ? ' ' + units[Math.mod(no, 10)] : '');
        }

        if (no < 1000) {
            return units[no / 100] + ' Hundred' + (Math.mod(no, 100) != 0 ? ' and ' + convert(Math.mod(no, 100)) : '');
        }

        for (Integer i = 0; i < thousands.size(); i++) {
            Integer unit = Math.pow(1000, i + 1).intValue();
            if (no < unit) {
                return convert(no / (unit / 1000)) + ' ' + thousands[i] + (Math.mod(no, (unit / 1000)) != 0 ? ' ' + convert(Math.mod(no, (unit / 1000))) : '');
            }
        }

        return '';
    }

    // Wrapper class to hold ProductRequest and tax details
    public class ProductRequestWrapper {
        public ProductRequest productRequest { get; set; }
        public Decimal CGST { get; set; }
        public Decimal SGST { get; set; }
        public Decimal IGST { get; set; }
        public Decimal CGSTTax { get; set; }
        public Decimal SGSTTax { get; set; }
        public Decimal IGSTTax { get; set; }
        public Decimal totalAmountwithTax { get; set; }


        // Constructor
        public ProductRequestWrapper(ProductRequest pr, HSNCode_Tax__c taxDetails) {
            this.productRequest = pr != null ? pr : new ProductRequest();
            if (taxDetails != null) {
                this.CGST = taxDetails.CGST__c != null ? taxDetails.CGST__c : 0;
                this.SGST = taxDetails.SGST__c != null ? taxDetails.SGST__c : 0;
                this.IGST = taxDetails.IGST__c != null ? taxDetails.IGST__c : 0;
                this.CGSTTax = (this.CGST * (this.productRequest.Quantity__c * this.productRequest.Spare_Price__c) / 100).setScale(2);
                this.SGSTTax = (this.SGST * (this.productRequest.Quantity__c * this.productRequest.Spare_Price__c) / 100).setScale(2);
                this.IGSTTax = (this.IGST * (this.productRequest.Quantity__c * this.productRequest.Spare_Price__c) / 100).setScale(2);
                this.totalAmountwithTax = (this.IGSTTax + (this.productRequest.Quantity__c * this.productRequest.Spare_Price__c)).setScale(2);
            } else {
                this.CGST = 0;
                this.SGST = 0;
                this.IGST = 0;
                this.CGSTTax = 0;
                this.totalAmountwithTax=0;
                this.SGSTTax=0;
                this.IGSTTax = 0;
            }
        }
    }
}