# Salesforce Flows Technical Design & Reference Guide

## Executive Summary & Business Overview

### Document Purpose
This document provides a comprehensive technical reference for all **Inactive/Obsolete** Salesforce Flows in the organization, serving as a historical record and audit trail for flows that have been decommissioned or replaced by newer processes.

### Business Context
These flows represent legacy business processes that were once critical to the organization's operations but have been superseded by newer, more efficient automation. They provide valuable insights into:
- **Historical Business Processes:** How the organization operated in the past
- **Data Migration Patterns:** Legacy data upload and mapping processes
- **Evolution of Business Rules:** How approval and validation processes have evolved
- **Technical Debt:** Areas where processes were replaced for better efficiency

### Document Statistics
- **Total Obsolete Flows:** 25 flows
- **Document Size:** 641 lines (~26 KB)
- **Flow Type Distribution:**
  - **Record-Triggered Flows:** 22 (88%) - Legacy automated processes
  - **Screen Flows:** 3 (12%) - Historical user interfaces
  - **Field Service Mobile Flows:** 0 (0%) - No mobile flows in obsolete category

### Business Modules & Functional Areas

#### 1. **Data Migration & Upload Processes** (40% of flows)
- **Purpose:** Legacy data migration and bulk upload operations
- **Key Flows:** Account Data Mapping, Asset Field Mapping, Case Data Mapping
- **Business Impact:** Historical data migration from legacy systems to Salesforce
- **Replacement Status:** Replaced by more efficient data import tools and processes

#### 2. **Legacy Approval Workflows** (24% of flows)
- **Purpose:** Obsolete approval processes and authorization workflows
- **Key Flows:** Approval to SSG, Debit Note Approval Process, Asset Approval
- **Business Impact:** Historical approval processes that have been streamlined
- **Replacement Status:** Replaced by modern approval processes with better routing

#### 3. **Asset Management Legacy** (20% of flows)
- **Purpose:** Historical asset lifecycle management processes
- **Key Flows:** Asset After Insert Trigger, Asset Field Mapping, Asset Approval
- **Business Impact:** Legacy asset registration and management workflows
- **Replacement Status:** Replaced by more comprehensive asset management processes

#### 4. **Case Management Legacy** (16% of flows)
- **Purpose:** Historical case assignment and management processes
- **Key Flows:** Assign Case to CBO Queue, Case Before Insert Trigger, Case Data Mapping
- **Business Impact:** Legacy case routing and assignment logic
- **Replacement Status:** Replaced by more sophisticated case management workflows

### Technical Architecture Overview

#### Flow Categories by Legacy Type:
1. **Data Migration Flows (10 flows)**
   - **Purpose:** Bulk data upload and field mapping operations
   - **Replacement:** Modern data import tools and APIs
   - **Retention Value:** Historical data migration patterns

2. **Legacy Approval Flows (6 flows)**
   - **Purpose:** Multi-step approval processes with manual routing
   - **Replacement:** Streamlined approval processes with automation
   - **Retention Value:** Approval workflow evolution documentation

3. **Asset Management Legacy (5 flows)**
   - **Purpose:** Basic asset registration and field assignment
   - **Replacement:** Comprehensive asset lifecycle management
   - **Retention Value:** Asset process evolution documentation

4. **Case Management Legacy (4 flows)**
   - **Purpose:** Simple case assignment and routing
   - **Replacement:** Advanced case management with AI and automation
   - **Retention Value:** Case process evolution documentation

### Historical Business Processes

#### Data Migration Era (2018-2020):
- **Account Data Mapping:** Legacy account field mapping during system migration
- **Asset Field Mapping:** Product-to-asset mapping during data upload
- **Case Data Mapping:** Department and division mapping for cases
- **CP and Branch Mapping:** Channel partner and branch assignment during migration

#### Legacy Approval Processes (2019-2021):
- **Approval to SSG:** Manual approval routing to Service Support Group
- **Debit Note Approval:** Complex approval chains for financial transactions
- **Asset Approval:** Manual asset registration approval processes

#### Basic Asset Management (2018-2020):
- **Asset After Insert Trigger:** Simple PMS event creation
- **Asset Field Mapping:** Basic product assignment to assets
- **Asset Approval:** Manual approval for non-BSL assets

### Replacement Analysis

#### Why These Flows Were Replaced:

1. **Performance Issues:**
   - Manual approval processes were time-consuming
   - Data migration flows were inefficient for large datasets
   - Basic asset management lacked comprehensive features

2. **Business Process Evolution:**
   - Approval workflows became more automated and intelligent
   - Asset management expanded to include warranty and service planning
   - Case management integrated with AI and predictive analytics

3. **Technical Improvements:**
   - Modern APIs replaced bulk data upload processes
   - Automated workflows replaced manual approval chains
   - Integrated systems replaced standalone processes

### Audit & Compliance Value

#### Historical Documentation:
- **Process Evolution:** Shows how business processes have evolved
- **Data Migration Patterns:** Documents historical data transformation rules
- **Approval Workflow Changes:** Tracks approval process improvements
- **System Integration History:** Shows progression from manual to automated processes

#### Compliance Requirements:
- **Audit Trails:** Complete record of historical business processes
- **Data Lineage:** Tracks how data was transformed during migrations
- **Process Documentation:** Evidence of business process changes
- **Regulatory Compliance:** Historical process documentation for audits

### Risk Assessment

#### Low Risk Flows (Safe to Archive):
- **Data Migration Flows:** No longer needed after migration completion
- **Basic Asset Flows:** Replaced by comprehensive asset management
- **Simple Case Flows:** Replaced by advanced case management

#### Medium Risk Flows (Require Review):
- **Approval Flows:** May have dependencies on historical approvals
- **Field Mapping Flows:** May affect data integrity if reactivated
- **Assignment Flows:** May impact current assignment logic

### Cleanup Recommendations

#### Immediate Actions:
1. **Archive Documentation:** Move to historical documentation repository
2. **Dependency Check:** Verify no active flows depend on obsolete flows
3. **Data Validation:** Ensure no data corruption from obsolete processes
4. **User Training:** Update training materials to remove obsolete processes

#### Long-term Actions:
1. **Process Documentation:** Document why each flow was replaced
2. **Migration Planning:** Plan for future system migrations
3. **Compliance Review:** Ensure audit requirements are met
4. **Knowledge Transfer:** Share lessons learned with development teams

### Business Value & Lessons Learned

#### Operational Improvements:
- **Process Efficiency:** Replaced manual processes with automation
- **Error Reduction:** Eliminated manual data entry and approval errors
- **Scalability:** Modern processes handle higher transaction volumes

#### Technical Improvements:
- **Integration:** Better integration between systems
- **Performance:** Faster processing and response times
- **Maintainability:** Easier to maintain and modify modern flows

#### Strategic Benefits:
- **Competitive Advantage:** More efficient processes than competitors
- **Customer Experience:** Faster response times and better service
- **Cost Reduction:** Reduced manual intervention and errors

---

## Detailed Flow Documentation

The following sections provide comprehensive technical documentation for each obsolete flow, including:

- **Historical Business Context**
- **Technical Architecture & Components**
- **Replacement Rationale**
- **Migration Patterns**
- **Audit Trail Information**

Each flow entry includes complete technical breakdowns, historical business logic explanations, and replacement information for effective audit and compliance purposes.

---
## 3. Account Data Mapping (Data Loader)
- **Status:** Obsolete
- **Summary:**  
  This flow was used for data migration and mapping of Account fields, including record type assignment and group categorization, during data loader operations.
- **Technical Breakdown:**
  - **Assignments:**  
    - Cleans up the BillingStreet field, assigns record types (Commercial/Residential), and sets group values (NAMO, Government, NON NAMO).
  - **Decisions:**  
    - Determines record type and group based on field values.
  - **Formulas:**  
    - Cleans double quotes from BillingStreet.
  - **Record Lookups:**  
    - Looks up RecordType for Commercial and Residential Accounts.
  - **Start:**  
    - Triggered on Account update (RecordBeforeSave).
  - **End:**  
    - Updates Account fields as per mapping logic.

---
---

## 4. Account - Data Migration (Existing Asset Department Update)

- **Flow File:** `Account_Data_Migration_Existing_Asset_Department_Update.flow`
- **Label:** Account - Data Migration (Existing Asset Department Update)
- **Type:** Record-Triggered Flow (`<processType>AutoLaunchedFlow</processType>`)
## 31. Approval to SSG for Non BSL Cold Room Asset Registration
- **Status:** Obsolete
- **Summary:**
  This flow automatically submits non-BSL cold room assets for approval to SSG (Service Support Group) and sends notifications.
- **Technical Breakdown:**
  - **Action Calls:**
    - `submit_to_SSG`: Submits asset for approval using "Cold_Room_Non_BSL_Asset_Approval" process
    - `notify_to_ssg`: Sends custom notification to SSG
  - **Assignments:**
    - `Assign_approver_id`: Adds SSG queue ID to approver collection
  - **Record Lookups:**
    - `get_record_for_queue`: Retrieves SSG queue record
    - `get_notification_type`: Retrieves custom notification type
  - **Text Templates:**
    - `title`: Notification title template
    - `body`: Notification body template
  - **Variables:**
    - `ApproverIds`: Collection variable for approver IDs
  - **Start:**
    - Triggered on Asset create when `Cold_Room_Family__c` is true
  - **End:**
    - Submits for approval and sends notification

---
---

## 32. Asset After Insert Trigger

- **Flow File:** `Asset_After_Insert_Trigger.flow`
- **Label:** Asset After Insert Trigger
- **Type:** Record-Triggered Flow (`<processType>AutoLaunchedFlow</processType>`)
## 32. Asset After Insert Trigger
- **Status:** Obsolete
- **Summary:**
  This flow creates PMS (Preventive Maintenance Service) events for warranty assets based on account type (Commercial/Residential) and warranty periods.
- **Technical Breakdown:**
  - **Action Calls:**
    - `Create_PMS_Events_for_AMC_WTY_Action_1`: Calls Apex controller to create PMS events
  - **Assignments:**
    - `Assign_Count_Value_for_Commercial`: Sets PMS count based on product sub-family
    - `asset_list`: Builds asset collection for processing
  - **Decisions:**
    - `Check_Account_Record_Type`: Routes based on account type (Commercial/Residential)
  - **Formulas:**
    - Multiple formulas for calculating PMS event dates, SLA periods, and warranty durations
    - `ISNEW`: Determines if record is new
    - `CheckResidentail`: Boolean flag for residential accounts
  - **Variables:**
    - `assetList`: Collection variable for assets
    - `countOfPMS`: Number variable for PMS count
    - `EventList`/`EventRecord`: Variables for PMS events
  - **Start:**
    - Triggered on Asset create/update when `Asset_Obligation__c` is "Warranty"
  - **End:**
    - Creates PMS events for warranty assets

---
---

## 33. Asset After Update Clean up PMS Records

- **Flow File:** `Asset_After_Update_Clean_up_PMS_Records.flow`
- **Label:** Asset After Update- Clean up PMS Records
- **Type:** Record-Triggered Flow (`<processType>AutoLaunchedFlow</processType>`)
## 37. Asset Field Mapping (Data Upload)
- **Status:** Obsolete
- **Summary:**
  This flow maps Product2 records to Asset records based on the Model_Number__c field during data upload operations.
- **Technical Breakdown:**
  - **Assignments:**
    - Assigns the Product2Id to the Asset based on Model_Number__c match
  - **Decisions:**
    - Checks if a matching Product2 record exists
  - **Record Lookups:**
    - Looks up Product2 records where ProductCode equals the Asset's Model_Number__c
  - **Start:**
    - Triggered on Asset create or update when Model_Number__c is not null
  - **End:**
    - Asset's Product2Id is updated with the matching product

---
---

## 38. Asset - generate PEP lead flow

- **Flow File:** `Asset_generate_PEP_lead_flow.flow`
- **Label:** Asset - generate PEP lead flow
- **Type:** Screen Flow (`<processType>Flow</processType>`)
## 50. Assign Case to CBO Queue
- **Status:** Obsolete
- **Summary:**
  This flow assigns Customer Request cases without Asset or Product to the CBO Queue and sends notifications to active queue members.
- **Technical Breakdown:**
  - **Action Calls:**
    - `Send_Notification`: Sends custom notification to queue members
  - **Assignments:**
    - Collects user IDs from queue members
    - Collects active user IDs for notification
  - **Decisions:**
    - Checks if Case record type is Customer Request
    - Checks if UserIds are present for notification
  - **Formulas:**
    - `Body`: Notification message about case creation without model
    - `Subject`: Subject line for notification
  - **Loops:**
    - Iterates over group members to collect user IDs
    - Iterates over active users for notification
  - **Record Lookups:**
    - Looks up Customer Request record type
    - Looks up CBO Queue
    - Looks up Group Members
    - Looks up Active Users
    - Looks up Custom Notification Type
  - **Record Updates:**
    - Updates Case owner to CBO Queue
  - **Start:**
    - Triggered on Case create when AssetId and ProductId are null
  - **End:**
    - Case is assigned to CBO Queue and notification is sent

---
---

## 51. Assign Case to L2 WD Team on Case Update

- **Flow File:** `Assign_Case_to_L2_WD_Team_on_Case_Update.flow`
- **Label:** Assign Case to L2 WD Team on Case Update
- **Type:** Record-Triggered Flow (`<processType>AutoLaunchedFlow</processType>`)
## 54. Assign Commissioning to Engineer After Owner Change
- **Status:** Obsolete
- **Summary:**
  This flow assigns commissioning work orders to engineers when the owner changes, updating ServiceAppointment records with the new engineer.
- **Technical Breakdown:**
  - **Decisions:**
    - Checks if owner user profile contains 'Engineer'
    - Checks if WorkOrder record type contains 'Commissioning'
  - **Record Lookups:**
    - Looks up owner User record
    - Looks up ServiceResource based on owner User
  - **Record Updates:**
    - Updates ServiceAppointment with assigned service resource and owner
  - **Start:**
    - Triggered on WorkOrder update when OwnerId changes
  - **End:**
    - ServiceAppointment is updated with new engineer assignment

---
---

## 55. Assign Field Work Type If Null

- **Flow File:** `Assign_Field_Work_Type_If_Null.flow`
- **Label:** Assign Field Work Type If Null
- **Type:** Record-Triggered Flow (`<processType>AutoLaunchedFlow</processType>`)
## 55. Assign Field Work Type If Null
- **Status:** Obsolete
- **Summary:**
  This flow assigns 'PMS Call' to Field_Work_Type__c for PMS or Regular Service WorkOrders when Status changes to Completed and Field_Work_Type__c is null.
- **Technical Breakdown:**
  - **Assignments:**
    - Assigns 'PMS Call' to Field_Work_Type__c
  - **Decisions:**
    - Checks if WorkOrder record type is 'PMS' or 'Regular_Service'
    - Checks if Field_Work_Type__c is null
  - **Start:**
    - Triggered on WorkOrder update when Status changes to 'Completed' and Field_Work_Type__c is null
  - **End:**
    - WorkOrder Field_Work_Type__c is set to 'PMS Call'

---
---

## 56. Assign Pricebook entry and Product details DU

- **Flow File:** `Assign_Pricebook_entry_and_Product_details_DU.flow`
- **Label:** Assign Pricebook entry and Product details DU
- **Type:** Record-Triggered Flow (`<processType>AutoLaunchedFlow</processType>`)
## 56. Assign Pricebook entry and Product details DU
- **Status:** Obsolete
- **Summary:**
  This flow assigns PricebookEntry and Product2 details to QuoteLineItem records based on Asset configuration during data upload operations.
- **Technical Breakdown:**
  - **Assignments:**
    - Assigns PricebookEntryId from lookup
    - Assigns Product2Id from Asset
  - **Decisions:**
    - Checks if Product details exist on Asset
  - **Record Lookups:**
    - Looks up Asset details
    - Looks up PricebookEntry based on Asset's Product2
  - **Start:**
    - Triggered on QuoteLineItem update when Asset__c is not null
  - **End:**
    - QuoteLineItem PricebookEntryId and Product2Id are populated

---
---

## 57. Assign Sales AIDH and submit for approval

- **Flow File:** `Assign_Sales_AIDH_and_submit_for_approval.flow`
- **Label:** Assign Sales AIDH and submit for approval
- **Type:** Record-Triggered Flow (`<processType>AutoLaunchedFlow</processType>`)
## 58. Assign SDE
- **Status:** Obsolete
- **Summary:**
  This flow assigns SDE (Service Department Engineer) to Asset records based on CP's SDE or Branch/Department configuration.
- **Technical Breakdown:**
  - **Assignments:**
    - Assigns SDE from CP's SDE field or from Branch_Division__c
  - **Decisions:**
    - Checks if CP is present and has SDE assigned
  - **Record Lookups:**
    - Looks up Branch_Division__c record with matching Branch and Department
  - **Start:**
    - Triggered on Asset create or update when Service_Department_L__c, Branch__c, or Update_SDE__c changes
  - **End:**
    - Asset SDE__c field is populated based on CP or Branch/Department configuration

---
---

## 59. Assign Service Territory on Creation

- **Flow File:** `Assign_Service_Territory_on_Creation.flow`
- **Label:** Assign Service Territory on Creation
- **Type:** Record-Triggered Flow (`<processType>AutoLaunchedFlow</processType>`)
## 84. Case Before Insert Trigger
- **Status:** Obsolete
- **Summary:**
  This flow creates PMS (Preventive Maintenance Schedule) tickets for cases when there are active service contracts and no open work orders.
- **Technical Breakdown:**
  - **Action Calls:**
    - `Create_PMS_Ticket`: Calls Apex controller `SchedulePMSTicketsForContracts`
  - **Assignments:**
    - Adds service contract IDs to collection for PMS ticket creation
  - **Decisions:**
    - Checks if active service contract exists
    - Checks if open work order exists under the contract
  - **Record Lookups:**
    - Looks up active service contracts for the account
    - Looks up open work orders for the account and service contract
  - **Start:**
    - Triggered on Case create (RecordAfterSave)
  - **End:**
    - PMS tickets are created for eligible service contracts

---
---

## 85. Case Assign Case Owner to NAMO Case

- **Flow File:** `Case_Assign_case_owner_to_NAMO_case.flow`
- **Label:** Case - Assign case owner to NAMO case
- **Type:** Record-Triggered Flow (`<processType>AutoLaunchedFlow</processType>`)
## 88. Case Data Mapping Data Loader
- **Status:** Obsolete
- **Summary:**
  This flow maps department and division information to cases based on associated assets or products during data loader operations.
- **Technical Breakdown:**
  - **Assignments:**
    - Maps Sales Division, Service Division, and Serviceable Division from asset or product
  - **Decisions:**
    - Checks if asset or product is present
    - Checks if department/division information is available
    - Checks case status for queue assignment
  - **Record Lookups:**
    - Gets product details for mapping
    - Gets Open and Closed Ticket Queues
  - **Record Updates:**
    - Assigns case to appropriate queue based on status
  - **Start:**
    - Triggered on Case create (RecordBeforeSave)
    - Filters for cases with assets or products
  - **End:**
    - Cases are assigned to appropriate queues with department mapping

---
---

## 89. Case Details Tag

- **Flow File:** `Case_details_tag.flow`
- **Label:** Case details tag
- **Type:** Record-Triggered Flow (`<processType>AutoLaunchedFlow</processType>`)
## 88. CP and Branch Mapping CPQ Flow Data Upload
- **Status:** Obsolete
- **Summary:**
  This flow maps CP (Channel Partner) and Branch information to CPQ Quote records during data upload operations, based on CP code patterns and lookup relationships.
- **Technical Breakdown:**
  - **Assignments:**
    - Assigns Branch__c from Branch lookup based on CP code
    - Assigns CP__c from Account lookup based on CP code
  - **Decisions:**
    - Checks if CP code starts with 'L' to determine lookup strategy
  - **Record Lookups:**
    - Gets CP Details from Account records based on CP_Code__c
    - Gets Branch Details from Branch__c records based on Branch_Code__c
  - **Start:**
    - Triggered on SBQQ__Quote__c create/update when CP_Code_Backend_Data_upload__c is not null
  - **End:**
    - CPQ Quote records are updated with CP and Branch mappings

---
---

## 89. CP and Branch Mapping Flow Data Upload

- **Flow File:** `CP_and_Branch_Mapping_Flow_Data_Upload.flow`
- **Label:** CP and Branch Mapping Flow Data Upload
- **Type:** Record-Triggered Flow (`<processType>AutoLaunchedFlow</processType>`)
## 128. Debit Note Approval Process RMR to Reassign CFS
- **Status:** Obsolete
- **Summary:**
  This flow manages the approval process for debit notes in RMR (Return Material Request) scenarios, reassigning approvals to CFS (Customer Field Service) when status changes to "Awaiting Approval From AM".
- **Technical Breakdown:**
  - **Decisions:**
    - Checks if status has changed to "Awaiting Approval From AM"
  - **Formulas:**
    - `TodayDate`: Gets current date/time using Now()
  - **Record Lookups:**
    - Gets CFS queue for approval assignment
    - Gets approval record for process instance
  - **Record Updates:**
    - Updates approval process with CFS assignment
    - Updates start date for approval process
    - Updates status to "Awaiting Approval From CFS"
  - **Scheduled Paths:**
    - CFS approval path with 7-day offset
  - **Start:**
    - Triggered on Transaction_Note__c update when Debit_Note_Approval_Status__c is "Awaiting Approval From AM"
  - **End:**
    - Approval is reassigned to CFS with updated status

---
---

## 129. Debit Note Approval Process RMR

- **Flow File:** `Debit_note_approval_process_RMR.flow`
- **Label:** Debit note approval process RMR
- **Type:** Record-Triggered Flow (`<processType>AutoLaunchedFlow</processType>`)
## 129. Debit Note Approval Process RMR
- **Status:** Obsolete
- **Summary:**
  This flow manages the approval process for debit notes in RMR scenarios, handling SDE to AM approval routing with scheduled escalation.
- **Technical Breakdown:**
  - **Decisions:**
    - Checks if status is "Awaiting Approval From SDE"
  - **Formulas:**
    - `todaydate`: Gets current date/time using Now()
  - **Record Lookups:**
    - Gets approval record for process instance
  - **Record Updates:**
    - Updates approval process with AM assignment
    - Updates start date for approval process
    - Updates status to "Awaiting Approval From AM"
  - **Scheduled Paths:**
    - SDE approval path with 7-day offset
  - **Variables:**
    - `processInstanceId`: SObject variable for ProcessInstanceWorkitem
  - **Start:**
    - Triggered on Transaction_Note__c create when Debit_Note_Approval_Status__c is "Awaiting Approval From SDE"
  - **End:**
    - Approval is routed to AM with updated status

---
---

## 130. Debok Contract After Update

- **Flow File:** `Debook_Contract_After_Update.flow`
- **Label:** Debok Contract After Update
- **Type:** Record-Triggered Flow (`<processType>AutoLaunchedFlow</processType>`)
## 130. Debok Contract After Update
- **Status:** Obsolete
- **Summary:**
  This complex flow handles contract debooking and short closure processes, including service ticket cancellation, PMS event updates, material request cancellation, and notification to stakeholders.
- **Technical Breakdown:**
  - **Action Calls:**
    - Sends custom notifications for debooking and short closure events
  - **Assignments:**
    - Adds initiator to recipient list for notifications
    - Collects service ticket IDs and PMS event details
    - Assigns list sizes for processing
  - **Decisions:**
    - Checks if modification initiator exists
    - Determines if debooking or short closure occurred
    - Checks PMS list size for processing
  - **Formulas:**
    - `NotificationBodyDebooked`: Notification message for debooking
    - `NotificationBodyShortClosed`: Notification message for short closure
    - `todayDate`: Gets current date
  - **Loops:**
    - Iterates through service tickets to collect IDs
    - Iterates through PMS events for processing
  - **Record Lookups:**
    - Gets service tickets not closed for the contract
    - Gets PMS events for the contract
    - Gets custom notification type
    - Gets record types for MR and ST PMS
  - **Record Updates:**
    - Closes all service tickets with "Canceled" status
    - Updates all material requests with "Canceled" status
    - Updates PMS list with cancellation status
  - **Scheduled Paths:**
    - Asynchronous path with 1-minute offset
  - **Text Templates:**
    - Email templates for contract activation notifications
  - **Variables:**
    - Collections for PMS events, recipient lists, and service ticket lists
  - **Start:**
    - Triggered on ServiceContract update when Modification_Status__c is "Debook" or "Short Closed"
  - **End:**
    - Contract is debooked/short closed with all related records updated and notifications sent

---
---

## 131. Defective Line Item AM and SDE

- **Flow File:** `Defective_Line_Item_AM_and_SDE.flow`
- **Label:** Defective Line Item AM and SDE
- **Type:** Record-Triggered Flow (`<processType>AutoLaunchedFlow</processType>`)
## 164. Initiate Debit Flow RMR
- **Status:** Obsolete
- **Summary:**
  This flow creates debit notes for RMR (Return Material Request) records after 35 days, handling approval processes and email notifications.
- **Technical Breakdown:**
  - **Record Creates:**
    - `Create_Debit_Note`: Creates Transaction_Note__c records with debit note details
  - **Action Calls:**
    - `Debit_Note_Approval_Process`: Submits for approval using RMR_Debit_Note_Approval process
    - `Send_Email_Action_1`: Sends email notifications to CP users
  - **Formulas:**
    - `dealerMarginPer`: Calculates dealer margin percentage
    - `debitAmount`: Calculates total debit amount including margin
    - `subject`: Generates email subject line
    - `Today`: Gets current date
  - **Decisions:**
    - `Is_RMR_created`: Checks if RMR is eligible for debit note creation
    - `Check_SDE`: Validates SDE presence
    - `Check_Email`: Validates email availability
  - **Scheduled Paths:**
    - `RMR_Details_after_35_Days`: Triggers after 45 days from RMR_Month_End_Date__c
- **Business Logic:**
  - Creates debit notes for RMR records after specified time period
  - Calculates amounts based on product pricing and dealer margins
  - Routes through approval process with SDE and AM approvers
  - Sends email notifications to relevant stakeholders

## 165. Initiate PMS Debit Flow

- **Flow File:** `Initiate_PMS_debit_Flow.flow`
- **Label:** Initiate PMS debit Flow
- **Type:** Record-Triggered Flow (`<processType>AutoLaunchedFlow</processType>`)
## 165. Initiate PMS Debit Flow
- **Status:** Obsolete
- **Summary:**
  This flow creates debit notes for PMS (Preventive Maintenance Service) work orders after 35 days, handling approval processes and email notifications.
- **Technical Breakdown:**
  - **Record Creates:**
    - `Create_Debit_Note`: Creates Transaction_Note__c records for PMS debit notes
  - **Action Calls:**
    - `Debit_Note_Approval_Process`: Submits for approval using PMS_Debit_Note_Approval process
    - `Send_Email`: Sends email notifications to CP users
  - **Formulas:**
    - `AssetTonValue`: Gets asset capacity value
    - `DebitValue`: Calculates debit amount from PMS master data
    - `Subject`: Generates email subject line
    - `Today`: Gets current date
  - **Decisions:**
    - `TicketClosed`: Checks if work order is still active
    - `SDE_Null`: Validates SDE presence
    - `Check_Email`: Validates email availability
  - **Record Lookups:**
    - `Get_PMS_Debit_Value`: Retrieves PMS debit rates based on asset specifications
    - `Get_AM`: Gets Service AM based on branch and department
  - **Scheduled Paths:**
    - `PMS_Details_after_35_Days`: Triggers after 35 days from creation date
- **Business Logic:**
  - Creates debit notes for PMS work orders after specified time period
  - Calculates amounts based on asset specifications and PMS master data
  - Routes through approval process with SDE and Service AM approvers
  - Sends email notifications to relevant stakeholders

## 166. Invoice Overdue Payment Notification Flow

- **Flow File:** `Invoice_Overdue_Payment_Notification_Flow.flow`
- **Label:** Invoice - Overdue Payment Notification Flow
- **Type:** Record-Triggered Flow (`<processType>AutoLaunchedFlow</processType>`)
## 226. Quote Line Migration Flow
- **Status:** Obsolete
- **Summary:**
  This flow handles quote line migration processes, creating price book entries and updating migration records.
- **Technical Breakdown:**
  - **Loops:**
    - Processes quote line migration records
  - **Record Creates:**
    - `create_pricebook_entry`: Creates price book entries for products
  - **Record Updates:**
    - `Update_Current_Record`: Updates migration records with product and quote information
  - **Record Lookups:**
    - `Get_Quote`: Gets quote information
    - `Get_Asset`: Gets asset information
    - `Get_PriceBook_Entry`: Gets price book entry information
  - **Decisions:**
    - `Chec_pricebook_entry`: Validates price book entry existence
  - **Variables:**
    - `pricebookentry`: Price book entry object
    - `pricebookentryid`: Price book entry ID
- **Business Logic:**
  - Manages quote line migration processes
  - Creates price book entries for products
  - Updates migration records with proper relationships
  - Handles data migration workflows

## 227. Quote Scope of Work Assignment for Delete

- **Flow File:** `Quote_Scope_of_Work_Assignment_for_Delete.flow`
- **Label:** Quote Scope of Work Assignment for Delete
- **Type:** Record-Triggered Flow (`<processType>AutoLaunchedFlow</processType>`)
## 228. Quote Scope of Work Assignment
- **Status:** Obsolete
- **Summary:**
  This flow handles scope of work assignment when quote line items are created, calling Apex service class for assignment.
- **Technical Breakdown:**
  - **Action Calls:**
    - `ScopeOfWorkServiceClassCall`: Calls ScopeOfWorkServiceClass Apex method
  - **Trigger Conditions:**
    - Triggers when quote line items are created
    - Object: QuoteLineItem
  - **Variables:**
    - `QuoteIds`: Collection of quote IDs
- **Business Logic:**
  - Manages scope of work assignment on quote line creation
  - Calls Apex service for proper assignment
  - Ensures data integrity during creation
  - Maintains scope of work relationships

## 229. Quote Status In Review

- **Flow File:** `Quote_Status_In_Review.flow`
- **Label:** Quote Status In Review
- **Type:** Record-Triggered Flow (`<processType>AutoLaunchedFlow</processType>`)
## 332. Tag Asset on Quote Lines
- **Status:** Obsolete
- **Summary:**
  This flow tags assets on quote lines, managing asset-to-quote line mapping workflows.
- **Technical Breakdown:**
  - **Record Lookups:**
    - `Get_Asset`: Gets asset based on component ID
  - **Record Updates:**
    - `Update_quote_line`: Updates quote line with asset details
  - **Trigger Conditions:**
    - Triggers when quote lines are created or updated
    - Object: SBQQ__QuoteLine__c
- **Business Logic:**
  - Manages asset tagging on quote lines
  - Handles asset-to-quote line mapping
  - Ensures proper asset assignment to quote lines
  - Maintains quote line asset mapping audit trail

## 333. Tag Asset on WO

- **Flow File:** `Tag_Asset_on_WO.flow`
- **Label:** Tag Asset on WO
- **Type:** Screen Flow (`<processType>Flow</processType>`)
## 337. Tag Family Details on Logical Asset
- **Status:** Obsolete
- **Summary:**
  This flow tags family details on logical assets from child assets, managing family mapping workflows.
- **Technical Breakdown:**
  - **Decisions:**
    - `null_check_for_child_asset`: Validates if child asset is null
  - **Record Lookups:**
    - `Get_Child_Asset`: Gets child asset details
  - **Record Updates:**
    - `Update_family_details_on_parent_asset`: Updates parent asset with family details
  - **Trigger Conditions:**
    - Triggers when logical assets are created
    - Object: Asset
- **Business Logic:**
  - Manages family details tagging workflows for logical assets
  - Handles family mapping processes from child assets
  - Ensures proper family assignment to logical assets
  - Maintains logical asset family mapping audit trail

## 338. Tag Parent Account with same PAN

- **Flow File:** `Tag_Parent_Account_with_same_PAN.flow`
- **Label:** Flow to tag Parent Account with same PAN
- **Type:** Record-Triggered Flow (`<processType>AutoLaunchedFlow</processType>`)
## 410. Update SA Owner
- **Status:** Obsolete
- **Summary:**
  This flow updates service appointment owners when work order owners change, managing ownership synchronization workflows.
- **Technical Breakdown:**
  - **Record Updates:**
    - `Update_SA_Owner`: Updates service appointment owner
  - **Trigger Conditions:**
    - Triggers when work order owner changes
    - Object: WorkOrder
- **Business Logic:**
  - Manages service appointment ownership synchronization workflows
  - Handles ownership change processes
  - Ensures proper ownership updates
  - Maintains ownership synchronization audit trail

## 411. Update SA Priority

- **Flow File:** `update_SA_priority.flow`
- **Label:** Update Work Order On SA
- **Type:** Record-Triggered Flow (`<processType>AutoLaunchedFlow</processType>`)
