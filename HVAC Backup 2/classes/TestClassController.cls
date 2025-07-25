public class TestClassController {
    public Id parentWorkOrderId { get; set; }
    public List<GroupedWrapperClass> groupedWrapperList { get; set; }
    public Integer columnSize = 4;

    public TestClassController() {
        parentWorkOrderId = '0WOBi000001xT2POAU'; // Replace with your actual parent Work Order Id
        groupedWrapperList = new List<GroupedWrapperClass>();
        fetchData();
    }

    public void fetchData() {
        List<WorkOrder> childWorkOrders = [
            SELECT Id, Asset.SerialNumber, Product_Sub_Family__c
            FROM WorkOrder 
            WHERE ParentWorkOrderId = :parentWorkOrderId
        ];

        List<WrapperClass> tempWrapperList = new List<WrapperClass>();
        Integer count = 0;

        // Separate collections for storing the sub-family names
        List<String> firstFourProductSubFamilies = new List<String>();
        List<String> remainingProductSubFamilies = new List<String>();

        for (WorkOrder childWO : childWorkOrders) {
            WrapperClass wc = new WrapperClass();
            wc.modelNo = childWO.Asset.SerialNumber;
            wc.productSubFamily = childWO.Product_Sub_Family__c;
            wc.workplans = new List<WorkplanWrapper>();

            List<Workplan> workplans = [SELECT Id, Name FROM Workplan WHERE WorkOrderId = :childWO.Id];
            for (Workplan wp : workplans) {
                WorkplanWrapper wpw = new WorkplanWrapper();
                wpw.workplanName = wp.Name;
                wpw.worksteps = [SELECT Name, Status, executionOrder FROM Workstep WHERE WorkplanId = :wp.Id ORDER BY executionOrder];
                wc.workplans.add(wpw);
            }

            // Fetch the image URL from File_URL__c object
            List<File_URL__c> fileUrls = [
                SELECT URL__c 
                FROM File_URL__c 
                WHERE Work_order__c = :childWO.Id
            ];

            wc.imageUrl = fileUrls.isEmpty() ? '' : fileUrls[0].URL__c;

            if (count < columnSize) {
                if (!firstFourProductSubFamilies.contains(childWO.Product_Sub_Family__c)) {
                    firstFourProductSubFamilies.add(childWO.Product_Sub_Family__c);
                }
            } else {
                if (!remainingProductSubFamilies.contains(childWO.Product_Sub_Family__c)) {
                    remainingProductSubFamilies.add(childWO.Product_Sub_Family__c);
                }
            }

            tempWrapperList.add(wc);
            count++;
            if (count == columnSize) {
                GroupedWrapperClass groupWrapper = new GroupedWrapperClass();
                groupWrapper.firstFourProductSubFamilies = concatenateList(firstFourProductSubFamilies);
                groupWrapper.remainingProductSubFamilies = concatenateList(remainingProductSubFamilies);
                groupWrapper.workOrders = tempWrapperList;
                groupedWrapperList.add(groupWrapper);
                
                tempWrapperList = new List<WrapperClass>();
                count = 0;
                firstFourProductSubFamilies.clear();
                remainingProductSubFamilies.clear();
            }
        }

        if (!tempWrapperList.isEmpty()) {
            while (tempWrapperList.size() < columnSize) {
                tempWrapperList.add(new WrapperClass(true)); // Adding dummy objects for padding
            }
            GroupedWrapperClass groupWrapper = new GroupedWrapperClass();
            groupWrapper.firstFourProductSubFamilies = concatenateList(firstFourProductSubFamilies);
            groupWrapper.remainingProductSubFamilies = concatenateList(remainingProductSubFamilies);
            groupWrapper.workOrders = tempWrapperList;
            groupedWrapperList.add(groupWrapper);
        }
    }

    // Custom method to concatenate list elements into a string
    private String concatenateList(List<String> listv) {
        String result = '';
        for (String item : listv) {
            if (result != '') {
                result += ', ';
            }
            result += item;
        }
        return result;
    }

    public class WrapperClass {
        public String modelNo { get; set; }
        public String productSubFamily { get; set; }
        public List<WorkplanWrapper> workplans { get; set; }
        public Boolean isEmpty { get; set; }
        public String imageUrl { get; set; }

        public WrapperClass() {
            this.isEmpty = false;
            this.workplans = new List<WorkplanWrapper>();
            this.imageUrl = '';
        }

        public WrapperClass(Boolean isEmpty) {
            this.isEmpty = isEmpty;
            this.modelNo = '';
            this.workplans = new List<WorkplanWrapper>();
            this.imageUrl = '';
        }
    }

    public class WorkplanWrapper {
        public String workplanName { get; set; }
        public List<Workstep> worksteps { get; set; }

        public WorkplanWrapper() {
            this.worksteps = new List<Workstep>();
        }
    }

    public class GroupedWrapperClass {
        public String firstFourProductSubFamilies { get; set; }
        public String remainingProductSubFamilies { get; set; }
        public List<WrapperClass> workOrders { get; set; }
    }
}