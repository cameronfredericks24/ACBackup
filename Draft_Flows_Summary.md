# Salesforce Draft Flows Technical Design & Reference Guide

This document provides a comprehensive summary and technical breakdown of all **Draft** Salesforce Flows in the org, including their type, status, and a detailed description of their logic and automation.

---

## 1. Asset Product Validation

- **Flow File:** `Asset_Product_Validation.flow`
- **Label:** Asset Product Validation
- **Type:** Record-Triggered Flow (`<processType>AutoLaunchedFlow</processType>`)
- **Status:** Draft
- **Summary:**
  This flow validates that Asset records (excluding Sub Components) have a Product2Id assigned.
- **Technical Breakdown:**
  - **Decisions:**
    - Checks if the Asset record type is not 'Sub Component'
    - Checks if Product2Id is null
  - **Start:**
    - Triggered on Asset create
  - **End:**
    - Validates product assignment on assets

---

## 2. Assign Case to L2 WD Team on Case Update

- **Flow File:** `Assign_Case_to_L2_WD_Team_on_Case_Update.flow`
- **Label:** Assign Case to L2 WD Team on Case Update
- **Type:** Record-Triggered Flow (`<processType>AutoLaunchedFlow</processType>`)
- **Status:** Draft
- **Summary:**
  This flow assigns Salesforce Support cases to appropriate L1 or L2 queues based on sub-status changes.
- **Technical Breakdown:**
  - **Decisions:**
    - Checks if Case record type contains 'Salesforce System Support'
    - Checks Sub_Status__c for 'Transferred to L2' or 'Assigned to L1'
  - **Record Lookups:**
    - Looks up L2 Queue (L2_Salesforce_Support_WD_Dev)
    - Looks up L1 Admin Queue (L1_Salesforce_Support_BSL_Admin)
  - **Record Updates:**
    - Assigns Case to L2 WD Queue or L1 Admin Queue based on sub-status
  - **Start:**
    - Triggered on Case create or update
  - **End:**
    - Case is assigned to appropriate queue based on sub-status

---

## 3. Case Assign Case Owner to NAMO Case

- **Flow File:** `Case_Assign_case_owner_to_NAMO_case.flow`
- **Label:** Case - Assign case owner to NAMO case
- **Type:** Record-Triggered Flow (`<processType>AutoLaunchedFlow</processType>`)
- **Status:** Draft
- **Summary:**
  This flow automatically assigns NAMO cases to the NAMO Queue based on the account's group classification.
- **Technical Breakdown:**
  - **Decisions:**
    - Checks if account group is 'NAMO'
  - **Record Lookups:**
    - Gets NAMO Queue for assignment
  - **Record Updates:**
    - Updates case owner to NAMO Queue
  - **Start:**
    - Triggered on Case create (RecordAfterSave)
    - Filters for cases with accounts
  - **End:**
    - NAMO cases are assigned to NAMO Queue

---

## Summary of Draft Flows

**Total Draft Salesforce Flows: 3**

### Business Process Distribution:
- **Asset Management:** 1 flow
- **Case Management:** 2 flows

### Technical Complexity Levels:
- **Simple (Basic assignments/updates):** 2 flows
- **Medium (Multiple decisions/loops):** 1 flow
- **Complex (Advanced logic/integrations):** 0 flows

### Flow Types Distribution:
- **Record-Triggered Flows:** 100%

### Development Status:
- **Asset Product Validation:** Ready for testing and deployment
- **Assign Case to L2 WD Team:** Ready for testing and deployment
- **Case Assign Case Owner to NAMO Case:** Ready for testing and deployment

### Recommendations:
1. **Testing:** All draft flows should undergo thorough testing before activation
2. **Documentation:** Ensure business requirements are clearly documented
3. **User Training:** Provide training for any new processes or changes
4. **Monitoring:** Set up monitoring and alerting for new flows
5. **Rollback Plan:** Have rollback procedures ready in case of issues

### Next Steps:
1. **Review Business Requirements:** Ensure flows meet current business needs
2. **Technical Review:** Validate technical implementation and performance
3. **User Acceptance Testing:** Get user feedback on new processes
4. **Deployment Planning:** Plan deployment during low-traffic periods
5. **Post-Deployment Monitoring:** Monitor performance and user adoption

This documentation provides insights into flows under development and helps ensure proper testing and deployment procedures. 