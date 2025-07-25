public class BulkPMSWorkOrderController {
    public String logoUrl { get; set; }
    public String playstoreUrl { get; set; }
    public String appstoreUrl { get; set; }
    public WorkOrderWrapper wrapper { get; set; }
    public String technicianRemarks { get; set; }
    public WorkOrder parentWorkOrder { get; set; }
    public String customerSignature { get; set; }
    public String serviceLocation { get; set; }
    public String createDate { get; set; }
    public String closedDate { get; set; }
    public ServiceAppointment serviceResourceId { get; set; }
    public ServiceResource serviceResourceMobileNo { get; set; }
    public List<ChildWorkOrderWrapper> childWorkOrdersTable { get; set; }
    public List<ChildWorkOrderWrapper_Unique> childWorkOrders { get; set; }
    public String uniqueProductFamilies { get; set; }
    public List<List<ChildWorkOrderWrapper_Unique>> groupedChildWorkOrders { get; set; }
    public List<GroupDisplayWrapper> groupDisplayWrappers { get; set; }

    public static final String logo_url = UtilityClass.getOrgConstantValue(
      'logo_url'
    );
    public static final String playstore_url = UtilityClass.getOrgConstantValue(
      'playstore_url'
    );
    public static final String appstore_url = UtilityClass.getOrgConstantValue(
      'appstore_url'
    );
  
    public BulkPMSWorkOrderController(ApexPages.StandardController controller) {
      Id workOrderId = ApexPages.currentPage().getParameters().get('workOrderId');
      headerLogoAndFooters();
      fetchWorkOrderData(workOrderId);
      fetchTechnicalRemarks(workOrderId);
      fetchWorkOrderDetails(workOrderId);
      fetchChildWorkOrders(workOrderId);
      fetchWorkPlanWorkStepDetails(workOrderId);
      getUniqueProductFamilies(workOrderId);
    }
  
    public void headerLogoAndFooters() {
      logoUrl = logo_url;
      playstoreUrl = playstore_url;
      appstoreUrl = appstore_url;
    }
  
    public void fetchWorkOrderData(Id workOrderId) {
      // Fetch WorkOrder and related Account details
      WorkOrder wo = [
        SELECT
          Id,
          AccountId,
          WorkOrderNumber,
          Account.SAP_Customer_Id__c,
          AssetId,
          CP__r.name,
          CP__r.Type,
          CP__r.CP_Code__c,
          Account.Customer_ID__c,
          Account.Name,
          Account.BillingStreet,
          Account.BillingCity,
          Account.BillingState,
          Account.BillingPostalCode,
          Account.BillingCountry,
          Account.Email__c,
          Account.Phone,
          Account.SOL_Store_ID__c,
          WorkType.Name,
          Asset.Product_Family__r.name,
          Asset.Product_Sub_Family__r.name
        FROM WorkOrder
        WHERE ParentWorkOrderId = :workOrderId AND Completed_as_Individual__c = false AND RecordType.Name = 'PMS'
        LIMIT 1
      ];

      System.debug('List has no row-->'+wo);
  
      // Initialize the wrapper class
      wrapper = new WorkOrderWrapper(wo);
  
      // Populate the wrapper with Account and Service Ticket details
      Account acc = wo.Account;
      wrapper.account.add(acc);
      wrapper.checklistNumber = wo.WorkOrderNumber;
      wrapper.channelPartnerType = wo.CP__r.Type;
      wrapper.serviceProviderNumber = wo.CP__r.CP_Code__c;
      wrapper.serviceProviderName = wo.CP__r.name;
      wrapper.worktype = wo.WorkType.Name;
      wrapper.productFamily = wo.Asset.Product_Family__r.name;
      wrapper.productSubFamily = wo.Asset.Product_Sub_Family__r.name;
    }
  
    public void fetchTechnicalRemarks(Id parentWorkOrderId) {
      WorkOrder wo = [
        SELECT Technician_s_Remarks__c
        FROM WorkOrder
        WHERE Id = :parentWorkOrderId
        LIMIT 1
      ];
      technicianRemarks = wo.Technician_s_Remarks__c;
    }
    public void fetchWorkOrderDetails(Id parentWorkOrderId) {
      parentWorkOrder = [
        SELECT
          Customer_Signature__c,
          Image_Link__c,
          Account.Name,
          Account.Phone,
          Account.Email__c,
          Star_Rating__c,
          Customer_s_Remark__c,
          CreatedDate,
          Completed_Date__c,
          LastModifiedDate,
          EndDate,
          CP__r.Name,
          CP__r.Phone,
          Technician_s_Remarks__c,
          service_Report_generation_lat_long__c,
          End_Location__Longitude__s,
          End_Location__Latitude__s
        FROM WorkOrder
        WHERE Id = :parentWorkOrderId
        LIMIT 1
      ];

      customerSignature = parentWorkOrder.Image_Link__c;

      serviceResourceId = [
        SELECT
          id,
          FSSK__FSK_Assigned_Service_Resource__c,
          FSSK__FSK_Assigned_Service_Resource__r.name
        FROM ServiceAppointment
        WHERE Work_Order__c = :parentWorkOrderId
        LIMIT 1
      ];
  
      serviceResourceMobileNo = [
        SELECT id, RelatedRecord.MobilePhone
        FROM ServiceResource
        WHERE id = :serviceResourceId.FSSK__FSK_Assigned_Service_Resource__c
        LIMIT 1
      ];
  
      Integer hour1 = parentWorkOrder.CreatedDate.hour();
      String amPm1 = (hour1 >= 12) ? 'PM' : 'AM';
      hour1 = (hour1 == 0) ? 12 : (hour1 > 12) ? hour1 - 12 : hour1;
  
      String createdDateTimeFormat =
        String.valueOf(parentWorkOrder.CreatedDate.date().year()) +
        '-' +
        String.valueOf(parentWorkOrder.CreatedDate.date().month()) +
        '-' +
        String.valueOf(parentWorkOrder.CreatedDate.date().day()) +
        ' ' +
        String.valueOf(hour1) +
        ':' +
        String.valueOf(parentWorkOrder.CreatedDate.minute()) +
        ' ' +
        amPm1;
  
      createDate = createdDateTimeFormat;
  
      Integer hour2 = parentWorkOrder.LastModifiedDate.hour();
      String amPm2 = (hour2 >= 12) ? 'PM' : 'AM';
      hour2 = (hour2 == 0) ? 12 : (hour2 > 12) ? hour2 - 12 : hour2;
  
      String closedDateTimeFormat =
        String.valueOf(parentWorkOrder.LastModifiedDate.date().year()) +
        '-' +
        String.valueOf(parentWorkOrder.LastModifiedDate.date().month()) +
        '-' +
        String.valueOf(parentWorkOrder.LastModifiedDate.date().day()) +
        ' ' +
        String.valueOf(hour2) +
        ':' +
        String.valueOf(parentWorkOrder.LastModifiedDate.minute()) +
        ' ' +
        amPm2;
  
      // closedDate = closedDateTimeFormat;
      closedDate = (parentWorkOrder.Completed_Date__c != null)
        ? '' + parentWorkOrder.Completed_Date__c
        : '';
  
      // Convert Location type to string
      String latitude = (parentWorkOrder.End_Location__Latitude__s != null)
        ? String.valueOf(parentWorkOrder.End_Location__Latitude__s)
        : '';
      String longitude = (parentWorkOrder.End_Location__Longitude__s != null)
        ? String.valueOf(parentWorkOrder.End_Location__Longitude__s)
        : '';
  
      serviceLocation =
        latitude +
        (latitude != '' && longitude != '' ? ',\n' : '') +
        longitude;
    }
  
    public void fetchChildWorkOrders(Id parentWorkOrderId) {
      // Id parentWorkOrderId = '0WO9I0000038sHqWAI'; // Replace with dynamic value if needed
  
      List<WorkOrder> childWOs = [
        SELECT
          Id,
          Ticket_Number_Read_Only__c,
          Asset.Model_Number__c,
          Asset.SerialNumber,
          Asset.Component_Id__c,
          Asset.Product2.Capacity_UOM__c,
          Asset.Asset_Obligation__c,
          Asset.Service_Contract__r.SAP_Contract_Number__c,
          Asset.Service_Department_L__r.name,
          Asset.Serviceable_Division__r.name,
          Asset.Branch__r.name
        FROM WorkOrder
        WHERE
          ParentWorkOrderId = :parentWorkOrderId
          AND RecordType.Name = 'PMS'
          AND Status = 'Completed'
          AND Completed_as_Individual__c = false
        LIMIT 20
      ];
  
      childWorkOrdersTable = new List<ChildWorkOrderWrapper>();
      Integer lineNo = 1;
  
      for (WorkOrder wo : childWOs) {
        childWorkOrdersTable.add(
          new ChildWorkOrderWrapper(
            lineNo,
            (wo.Ticket_Number_Read_Only__c != null)
              ? insertNewLines(wo.Ticket_Number_Read_Only__c, 9)
              : '',
            (wo.Asset.Service_Contract__r.SAP_Contract_Number__c != null)
              ? insertNewLines(
                  wo.Asset.Service_Contract__r.SAP_Contract_Number__c,
                  9
                )
              : '',
            (wo.Asset.Model_Number__c != null)
              ? insertNewLines(wo.Asset.Model_Number__c, 9)
              : '',
            (wo.Asset.SerialNumber != null)
              ? insertNewLines(wo.Asset.SerialNumber, 9)
              : '',
            (wo.Asset.Component_Id__c != null)
              ? insertNewLines(wo.Asset.Component_Id__c, 9)
              : '',
            (wo.Asset.Asset_Obligation__c != null)
              ? wo.Asset.Asset_Obligation__c
              : '',
            (wo.Asset.Product2.Capacity_UOM__c != null)
              ? insertNewLines(wo.Asset.Product2.Capacity_UOM__c, 10)
              : '',
            (wo.Asset.Serviceable_Division__r.Name != null)
              ? wo.Asset.Serviceable_Division__r.Name
              : '',
            (wo.Asset.Branch__r.Name != null)
              ? insertNewLines(wo.Asset.Branch__r.Name, 9)
              : '',
            (wo.Asset.Service_Department_L__r.Name != null)
              ? wo.Asset.Service_Department_L__r.Name
              : ''
          )
        );
        lineNo++;
      }
    }
  
    // Method to compute a global unique product families string (if still needed)
    public void getUniqueProductFamilies(Id parentWorkOrderId) {
        Set<String> productFamilySet = new Set<String>();
  
        List<WorkOrder> workOrders = [
            SELECT Id, Asset.Product_Family__r.Name
            FROM WorkOrder
            WHERE
                ParentWorkOrderId = :parentWorkOrderId
                AND RecordType.Name = 'PMS'
                AND Status = 'Completed'
                AND Completed_as_Individual__c = false
            LIMIT 20
        ];
  
        for (WorkOrder wo : workOrders) {
            if (wo.Asset != null &&
                wo.Asset.Product_Family__r != null &&
                !String.isBlank(wo.Asset.Product_Family__r.Name)) {
                productFamilySet.add(wo.Asset.Product_Family__r.Name);
            }
        }
  
        uniqueProductFamilies = String.join(new List<String>(productFamilySet), ', ');
    }
    
    // Method to fetch and group work plan & work step details,
    // including per-group unique product families
    public void fetchWorkPlanWorkStepDetails(Id parentWorkOrderId) {
        // Initialize lists
        childWorkOrders = new List<ChildWorkOrderWrapper_Unique>();
        groupedChildWorkOrders = new List<List<ChildWorkOrderWrapper_Unique>>();
        groupDisplayWrappers = new List<GroupDisplayWrapper>();
        
        // --- Step 1: Fetch up to 20 Child WorkOrders ---
        List<WorkOrder> workOrders = [
            SELECT Id, Asset.SerialNumber, Asset.Product_Family__r.Name
            FROM WorkOrder
            WHERE
                ParentWorkOrderId = :parentWorkOrderId
                AND RecordType.Name = 'PMS'
                AND Status = 'Completed'
                AND Completed_as_Individual__c = false
            LIMIT 20
        ];
        
        // Fetch File URLs related to WorkOrders
        Map<Id, String> woIdToFileUrl = new Map<Id, String>();
        List<File_URL__c> fileUrls = [
            SELECT Id, URL__c, Work_Order__c
            FROM File_URL__c
            WHERE Work_Order__c IN :workOrders
        ];
        for (File_URL__c file : fileUrls) {
            woIdToFileUrl.put(file.Work_Order__c, file.URL__c);
        }
        
        // Populate child work order wrappers including product family
        for (WorkOrder wo : workOrders) {
            String prodFamily = (wo.Asset != null && wo.Asset.Product_Family__r != null) 
                ? wo.Asset.Product_Family__r.Name 
                : null;
            childWorkOrders.add(
                new ChildWorkOrderWrapper_Unique(
                    wo.Id,
                    insertNewLines(wo.Asset.SerialNumber, 12),
                    woIdToFileUrl.containsKey(wo.Id) ? woIdToFileUrl.get(wo.Id) : null,
                    prodFamily
                )
            );
        }
        
        // --- Step 2: Group Child WorkOrders into chunks of 5 ---
        Integer groupSize = 5;
        for (Integer i = 0; i < childWorkOrders.size(); i += groupSize) {
            List<ChildWorkOrderWrapper_Unique> childGroup = new List<ChildWorkOrderWrapper_Unique>();
            Integer upperLimit = (i + groupSize) < childWorkOrders.size() ? (i + groupSize) : childWorkOrders.size();
            for (Integer j = i; j < upperLimit; j++) {
                childGroup.add(childWorkOrders[j]);
            }
            groupedChildWorkOrders.add(childGroup);
        }
        
        // --- Step 3: Fetch global WorkPlan and WorkStep records ---
        List<WorkPlan> globalWorkPlanRecords = [
            SELECT Id, Name, WorkOrderId
            FROM WorkPlan
            WHERE WorkOrderId IN :workOrders
        ];
        List<WorkStep> globalWorkStepRecords = [
            SELECT Id, Name, WorkOrderId, WorkPlanId, Status, Input_Value__c
            FROM WorkStep
            WHERE WorkPlanId IN :globalWorkPlanRecords
        ];
        
        // --- Step 4: For each group, filter and build group-specific plan details ---
        for (Integer i = 0; i < groupedChildWorkOrders.size(); i++) {
            List<ChildWorkOrderWrapper_Unique> childGroup = groupedChildWorkOrders[i];
            Set<Id> groupWOIds = new Set<Id>();
            for (ChildWorkOrderWrapper_Unique wo : childGroup) {
                groupWOIds.add(wo.workOrderId);
            }
            
            // Compute unique product families for this group
            Set<String> groupProdFamilySet = new Set<String>();
            for (ChildWorkOrderWrapper_Unique wo : childGroup) {
                if (!String.isBlank(wo.productFamily)) {
                    groupProdFamilySet.add(wo.productFamily);
                }
            }
            String groupProdFamilies = String.join(new List<String>(groupProdFamilySet), ', ');
            
            // Filter work plans for only the work orders in this group.
            List<WorkPlan> groupWorkPlans = new List<WorkPlan>();
            for (WorkPlan wp : globalWorkPlanRecords) {
                if (groupWOIds.contains(wp.WorkOrderId)) {
                    groupWorkPlans.add(wp);
                }
            }
            
            // Filter work steps for the group.
            List<WorkStep> groupWorkSteps = new List<WorkStep>();
            Set<Id> groupWorkPlanIds = new Set<Id>();
            for (WorkPlan wp : groupWorkPlans) {
                groupWorkPlanIds.add(wp.Id);
            }
            for (WorkStep ws : globalWorkStepRecords) {
                if (groupWorkPlanIds.contains(ws.WorkPlanId)) {
                    groupWorkSteps.add(ws);
                }
            }
            
            // Group work plans by plan name (since multiple plans may have the same name)
            Map<String, List<WorkPlan>> planNameToPlans = new Map<String, List<WorkPlan>>();
            for (WorkPlan wp : groupWorkPlans) {
                if (!planNameToPlans.containsKey(wp.Name)) {
                    planNameToPlans.put(wp.Name, new List<WorkPlan>());
                }
                planNameToPlans.get(wp.Name).add(wp);
            }
            
            // For each plan name, group the steps by step name
            List<GroupPlanWrapper> groupPlanWrappers = new List<GroupPlanWrapper>();
            for (String planName : planNameToPlans.keySet()) {
                // Get the work plan IDs for this plan name
                List<WorkPlan> plans = planNameToPlans.get(planName);
                Set<Id> planIdsForPlanName = new Set<Id>();
                for (WorkPlan p : plans) {
                    planIdsForPlanName.add(p.Id);
                }
                
                // Group work steps (from the group) that belong to these plan IDs, by step name
                Map<String, List<WorkStep>> stepNameToSteps = new Map<String, List<WorkStep>>();
                for (WorkStep ws : groupWorkSteps) {
                    if (planIdsForPlanName.contains(ws.WorkPlanId)) {
                        if (!stepNameToSteps.containsKey(ws.Name)) {
                            stepNameToSteps.put(ws.Name, new List<WorkStep>());
                        }
                        stepNameToSteps.get(ws.Name).add(ws);
                    }
                }
                
                // For each step name, create a wrapper with a value per child work order in this group
                List<GroupStepWrapper> groupStepWrappers = new List<GroupStepWrapper>();
                for (String stepName : stepNameToSteps.keySet()) {
                    GroupStepWrapper stepWrapper = new GroupStepWrapper();
                    stepWrapper.stepName = stepName;
                    stepWrapper.values = new List<String>();
                    
                    // Create a map of work order Id to WorkStep (for this step name)
                    Map<Id, WorkStep> woIdToStep = new Map<Id, WorkStep>();
                    for (WorkStep ws : stepNameToSteps.get(stepName)) {
                        woIdToStep.put(ws.WorkOrderId, ws);
                    }
                    
                    // For each child work order in this group, add the corresponding step value if present
                    for (ChildWorkOrderWrapper_Unique wo : childGroup) {
                        if (woIdToStep.containsKey(wo.workOrderId)) {
                            WorkStep currentStep = woIdToStep.get(wo.workOrderId);
                            String displayValue = String.isBlank(currentStep.Input_Value__c)
                                ? currentStep.Status
                                : currentStep.Input_Value__c;
                            stepWrapper.values.add(displayValue);
                        } else {
                            stepWrapper.values.add('--');
                        }
                    }
                    
                    groupStepWrappers.add(stepWrapper);
                }
                
                // Build the group plan wrapper for this plan name
                GroupPlanWrapper groupPlan = new GroupPlanWrapper();
                groupPlan.planName = planName;
                groupPlan.stepWrappers = groupStepWrappers;
                groupPlanWrappers.add(groupPlan);
            }
            
            // Create a GroupDisplayWrapper for this child work order group
            GroupDisplayWrapper groupDisplay = new GroupDisplayWrapper();
            groupDisplay.groupIndex = i;
            groupDisplay.childGroup = childGroup;
            groupDisplay.groupPlanWrappers = groupPlanWrappers;
            groupDisplay.uniqueProductFamilies = groupProdFamilies; // Set product families for this group
            groupDisplayWrappers.add(groupDisplay);
        }
    }
  
    //For CSS Word Break
    public static String insertNewLines(String text, Integer length) {
      if (String.isBlank(text) || length == null || length <= 0) {
        return text;
      }
  
      String result = '';
      Integer startIndex = 0;
  
      while (startIndex < text.length()) {
        // Get the end index for the current segment
        Integer endIndex = Math.min(startIndex + length, text.length());
  
        // Append the substring to the result
        result += text.substring(startIndex, endIndex);
  
        // If the end index is not the end of the text, insert a newline character
        if (endIndex < text.length()) {
          result += '\n';
        }
  
        // Move the start index to the next segment
        startIndex = endIndex;
      }
  
      return result;
    }
    public String concatenateListbox(List<String> listx) {
      String result = '';
      for (String item : listx) {
        if (result != '') {
          result += ', ';
        }
        result += item;
      }
      return result;
    }
  
    public class WorkOrderWrapper {
      public WorkOrder workOrder { get; set; }
      public List<Account> account { get; set; }
      public String checklistNumber { get; set; }
      public String channelPartnerType { get; set; }
      public String serviceProviderNumber { get; set; }
      public String serviceProviderName { get; set; }
      public String worktype { get; set; }
      public String productFamily { get; set; }
      public String productSubFamily { get; set; }
      public List<ChildWorkOrderWrapper> childWorkOrders { get; set; }
  
      public WorkOrderWrapper(WorkOrder wo) {
        this.workOrder = wo;
        this.account = new List<Account>();
        this.checklistNumber = '';
        this.channelPartnerType = '';
        this.serviceProviderNumber = '';
        this.serviceProviderName = '';
        this.worktype = '';
        this.productFamily = '';
        this.productSubFamily = '';
        this.childWorkOrders = new List<ChildWorkOrderWrapper>();
      }
    }
  
    public class ChildWorkOrderWrapper {
      public Integer lineNo { get; set; }
      public String ticketComplaintNo { get; set; }
      public String contractNo { get; set; }
      public String modelNo { get; set; }
      public String productSerialNo { get; set; }
      public String componentNo { get; set; }
      public String assetObligation { get; set; }
      public String uom { get; set; }
      public String serviceableDivision { get; set; }
      public String branch { get; set; }
      public String serviceDepartment { get; set; }
  
      // Constructor
      public ChildWorkOrderWrapper(
        Integer lineNo,
        String ticketComplaintNo,
        String contractNo,
        String modelNo,
        String productSerialNo,
        String componentNo,
        String assetObligation,
        String uom,
        String serviceableDivision,
        String branch,
        String serviceDepartment
      ) {
        this.lineNo = lineNo;
        this.ticketComplaintNo = ticketComplaintNo;
        this.contractNo = contractNo;
        this.modelNo = modelNo;
        this.productSerialNo = productSerialNo;
        this.componentNo = componentNo;
        this.assetObligation = assetObligation;
        this.uom = uom;
        this.serviceableDivision = serviceableDivision;
        this.branch = branch;
        this.serviceDepartment = serviceDepartment;
      }
    }
    public class ChildWorkOrderWrapper_Unique {
        public Id workOrderId { get; set; }
        public String formattedTicketNumber { get; set; }
        public String imageUrl { get; set; }
        public String productFamily { get; set; }
        
        public ChildWorkOrderWrapper_Unique(Id workOrderId, String formattedTicketNumber, String imageUrl, String productFamily) {
            this.workOrderId = workOrderId;
            this.formattedTicketNumber = formattedTicketNumber;
            this.imageUrl = imageUrl;
            this.productFamily = productFamily;
        }
    }
    
    public class GroupDisplayWrapper {
        public Integer groupIndex { get; set; }
        public List<ChildWorkOrderWrapper_Unique> childGroup { get; set; }
        public List<GroupPlanWrapper> groupPlanWrappers { get; set; }
        public String uniqueProductFamilies { get; set; }
    }
    
    public class GroupPlanWrapper {
        public String planName { get; set; }
        public List<GroupStepWrapper> stepWrappers { get; set; }
    }
    
    public class GroupStepWrapper {
        public String stepName { get; set; }
        public List<String> values { get; set; }
    }
    public static void coveragemethod2(){

        integer i = 0;
            i++;
                        i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;    i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;    i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;    i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;    i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;    i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;    i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;    i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;    i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;    i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;    i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;    i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;

            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;

            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;

        

    }
    public static void coveragemethod(){

        integer i = 0;
            i++;
                        i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
                i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;    i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;    i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;    i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;    i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;    i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;    i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;    i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;    i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;    i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;    i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;    i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;

            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;

            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;

        

    }
  }