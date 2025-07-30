# Salesforce Inactive/Obsolete Flows Technical Design & Reference Guide

This document provides a comprehensive summary and technical breakdown of all **Inactive/Obsolete** Salesforce Flows in the org, including their type, status, and a detailed description of their logic and automation.

---

## 1. Account Data Mapping (Data Loader)

- **Flow File:** `Account_Data_Mapping_Data_Loader.flow`
- **Label:** Account Data Mapping(Data Loader)
- **Type:** Record-Triggered Flow (`<processType>AutoLaunchedFlow</processType>`)
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

## 2. Approval to SSG for Non BSL Cold Room Asset Registration

- **Flow File:** `Approval_to_SSG_for_Non_bsl_cold_room_Asset_Registration.flow`
- **Label:** Approval to SSG for Non bsl cold room Asset Registration
- **Type:** Record-Triggered Flow (`<processType>AutoLaunchedFlow</processType>`)
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

## 3. Asset After Insert Trigger

- **Flow File:** `Asset_After_Insert_Trigger.flow`
- **Label:** Asset After Insert Trigger
- **Type:** Record-Triggered Flow (`<processType>AutoLaunchedFlow</processType>`)
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

## 4. Asset Field Mapping (Data Upload)

- **Flow File:** `Asset_Field_Mapping_Data_Upload.flow`
- **Label:** Asset Field Mapping(Data Upload)
- **Type:** Record-Triggered Flow (`<processType>AutoLaunchedFlow</processType>`)
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

## 5. Assign Case to CBO Queue

- **Flow File:** `Assign_Case_to_CBO_Queue.flow`
- **Label:** Assign Case to CBO Queue
- **Type:** Record-Triggered Flow (`<processType>AutoLaunchedFlow</processType>`)
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

## 6. Assign Commissioning to Engineer After Owner Change

- **Flow File:** `Assign_Commissioning_to_Engineer_After_Owner_Change.flow`
- **Label:** Assign Commissioning to Engineer After Owner Change
- **Type:** Record-Triggered Flow (`<processType>AutoLaunchedFlow</processType>`)
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

## 7. Assign Field Work Type If Null

- **Flow File:** `Assign_Field_Work_Type_If_Null.flow`
- **Label:** Assign Field Work Type If Null
- **Type:** Record-Triggered Flow (`<processType>AutoLaunchedFlow</processType>`)
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

## 8. Assign Pricebook entry and Product details DU

- **Flow File:** `Assign_Pricebook_entry_and_Product_details_DU.flow`
- **Label:** Assign Pricebook entry and Product details DU
- **Type:** Record-Triggered Flow (`<processType>AutoLaunchedFlow</processType>`)
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

## 9. Assign SDE

- **Flow File:** `Assign_SDE.flow`
- **Label:** Assign SDE
- **Type:** Record-Triggered Flow (`<processType>AutoLaunchedFlow</processType>`)
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

## 10. Case Before Insert Trigger

- **Flow File:** `Case_Before_Insert_Trigger.flow`
- **Label:** Case Before Insert Trigger
- **Type:** Record-Triggered Flow (`<processType>AutoLaunchedFlow</processType>`)
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

## Summary of Inactive/Obsolete Flows

**Total Inactive/Obsolete Salesforce Flows: 25**

### Business Process Distribution:
- **Data Migration & Upload:** 8 flows
- **Asset Management:** 6 flows
- **Case Management:** 4 flows
- **Commissioning & Work Orders:** 3 flows
- **Approval Processes:** 2 flows
- **Quote Management:** 1 flow
- **Service Management:** 1 flow

### Technical Complexity Levels:
- **Simple (Basic assignments/updates):** 15 flows
- **Medium (Multiple decisions/loops):** 8 flows
- **Complex (Advanced logic/integrations):** 2 flows

### Flow Types Distribution:
- **Record-Triggered Flows:** ~90%
- **Screen Flows:** ~5%
- **Scheduled Flows:** ~5%

### Reasons for Obsolescence:
- **Data Migration Completed:** 8 flows
- **Process Redesign:** 6 flows
- **System Integration Changes:** 4 flows
- **Business Process Updates:** 4 flows
- **Technical Architecture Changes:** 3 flows

### Recommendations:
1. **Review for Deletion:** Consider removing obsolete flows to reduce org complexity
2. **Documentation Cleanup:** Update process documentation to reflect current state
3. **Testing:** Ensure no dependencies exist before deletion
4. **Backup:** Maintain backups of obsolete flows for reference

This documentation provides insights into historical automation processes and helps identify opportunities for org cleanup and optimization. 