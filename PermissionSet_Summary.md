# Salesforce Permission Set Summary

## Executive Summary & Business Overview

### Document Purpose
This document provides a comprehensive technical reference for all **84 Permission Sets** in the Salesforce organization, serving as the primary source for understanding, maintaining, and optimizing user access controls and security configurations across all business modules.

### Business Context
The organization operates a complex multi-module Salesforce ecosystem with specialized user roles across:
- **Field Service Operations** (FSL - Field Service Lightning)
- **Sales & CPQ Management** (Configure, Price, Quote)
- **Service & Support Operations**
- **Integration & API Management**
- **Administration & System Management**
- **Reporting & Analytics**
- **Knowledge Management**
- **Community & Portal Access**

### Document Statistics
- **Total Permission Sets:** 84 permission sets
- **Document Size:** 2,601 lines (~104 KB)
- **License Distribution:**
  - **Salesforce Standard:** 45 permission sets (53.6%)
  - **Field Service Lightning:** 15 permission sets (17.9%)
  - **CPQ (Configure, Price, Quote):** 8 permission sets (9.5%)
  - **Integration Licenses:** 6 permission sets (7.1%)
  - **Cloud Integration:** 2 permission sets (2.4%)
  - **Other Specialized:** 8 permission sets (9.5%)

### Business Modules & Functional Areas

#### 1. **Field Service Lightning (FSL) - 17.9%**
- **Mobile Technicians:** Field Service Mobile access for field operations
- **Dispatchers:** Service appointment scheduling and resource management
- **Agents:** Call center support for field service operations
- **Administrators:** Full FSL configuration and management
- **Self-Service:** Community-based appointment booking

#### 2. **Sales & CPQ Management - 9.5%**
- **CPQ Quote Management:** Advanced quoting and pricing processes
- **CPQ Advanced Approvals:** Multi-level approval workflows
- **Sales Operations:** Opportunity and quote management
- **Product Management:** Product lifecycle and pricing

#### 3. **Service & Support Operations - 15.5%**
- **Case Management:** Customer service and support
- **Service Contracts:** Contract lifecycle management
- **Knowledge Management:** Article creation and management
- **Commissioning:** Specialized service processes

#### 4. **Integration & API Management - 9.5%**
- **API Integration:** External system connectivity
- **Bulk Operations:** Data migration and processing
- **DevOps:** Deployment and metadata management
- **External Services:** Third-party integrations

#### 5. **Administration & System Management - 20.2%**
- **System Administrators:** Full org access and configuration
- **Metadata Management:** Customization and development
- **User Management:** Role and permission administration
- **Security & Compliance:** Audit and access control

#### 6. **Reporting & Analytics - 11.9%**
- **Report Management:** Creation, editing, and scheduling
- **Dashboard Management:** Visualization and sharing
- **Data Analysis:** Query and export capabilities
- **Adoption Tracking:** Usage analytics and insights

#### 7. **Community & Portal Access - 7.1%**
- **Partner Community:** External partner access
- **Customer Portal:** Self-service capabilities
- **Guest Access:** Limited external access
- **Channel Partner:** Specialized partner operations

#### 8. **Specialized Business Functions - 7.1%**
- **NAMO Operations:** National Account Management
- **CBO Processes:** Channel Business Operations
- **SME Functions:** Subject Matter Expert access
- **Audit & Compliance:** Read-only access for auditing

### Technical Architecture Overview

#### **License Distribution Analysis:**
- **Standard Salesforce:** Core business operations and administration
- **Field Service Mobile:** Mobile workforce enablement
- **Field Service Standard:** Desktop field service operations
- **Field Service Dispatcher:** Scheduling and dispatch operations
- **CPQ Licenses:** Advanced quoting and pricing capabilities
- **Integration Licenses:** API and external system connectivity

#### **Permission Categories:**
1. **Object Permissions:** CRUD access to standard and custom objects
2. **Field Permissions:** Granular field-level access control
3. **System Permissions:** Platform-level capabilities and features
4. **Apex Class Access:** Custom code execution permissions
5. **Visualforce Page Access:** Custom UI component access
6. **Tab Visibility:** Application navigation and access
7. **Record Type Access:** Business process-specific record access
8. **Custom Permissions:** Organization-specific access controls

### Security & Compliance Features

#### **Access Control Patterns:**
- **Role-Based Access Control (RBAC):** User role-specific permissions
- **Least Privilege Principle:** Minimal required access for each role
- **Separation of Duties:** Distinct permissions for different functions
- **Audit Trail:** Comprehensive access logging and monitoring

#### **Compliance Considerations:**
- **Data Privacy:** Field-level access controls for sensitive data
- **Regulatory Compliance:** Industry-specific access requirements
- **Security Standards:** Multi-factor authentication and session management
- **Access Reviews:** Regular permission set audits and updates

### Business Impact & Recommendations

#### **Operational Efficiency:**
- **Streamlined Access:** Role-specific permission sets reduce complexity
- **Mobile Enablement:** Field service mobile access improves field operations
- **Self-Service:** Community access reduces support burden
- **Integration Capabilities:** API access enables system connectivity

#### **Risk Management:**
- **Access Segregation:** Prevents unauthorized data access
- **Audit Capabilities:** Comprehensive logging for compliance
- **Change Control:** Controlled permission modifications
- **Security Monitoring:** Continuous access monitoring

#### **Scalability Considerations:**
- **Modular Design:** Permission sets can be easily modified
- **License Optimization:** Efficient use of Salesforce licenses
- **Growth Support:** Flexible permission structure for expansion
- **Integration Ready:** API access supports system growth

### Maintenance & Governance

#### **Documentation Standards:**
- **Business Function Descriptions:** Clear purpose for each permission set
- **Access Matrix:** Comprehensive permission mapping
- **Change Management:** Controlled permission modifications
- **Training Materials:** User access documentation

#### **Operational Procedures:**
- **Regular Reviews:** Quarterly permission set audits
- **Access Requests:** Standardized permission assignment process
- **Security Monitoring:** Continuous access monitoring
- **Compliance Reporting:** Regular access compliance reviews

---


---

## Permission Set: **BSL CCO Permission Set**

**Label:** BSL CCO Permission Set  
**License:** Salesforce

### Object Permissions
| Object           | Create | Read | Edit | Delete | View All | Modify All |
|------------------|--------|------|------|--------|----------|------------|
| Account          |   No   | Yes  | No   |  No    |  Yes     |    No      |
| Asset            |   No   | Yes  | No   |  No    |  Yes     |    No      |
| Case             |  Yes   | Yes  | Yes  |  No    |  Yes     |    No      |
| Contact          |   No   | Yes  | No   |  No    |   No     |    No      |
| Lead             |   No   | Yes  | No   |  No    |  Yes     |    No      |
| Location         |   No   | Yes  | No   |  No    |  Yes     |    No      |
| Opportunity      |   No   | Yes  | No   |  No    |  Yes     |    No      |
| Pricebook2       |   No   | Yes  | No   |  No    |   No     |    No      |
| Product2         |   No   | Yes  | No   |  No    |   No     |    No      |
| ProductItem      |   No   | Yes  | No   |  No    |  Yes     |    No      |
| ProductRequest   |   No   | Yes  | No   |  No    |  Yes     |    No      |
| ProductTransfer  |   No   | Yes  | No   |  No    |  Yes     |    No      |
| Product_Family__c|   No   | Yes  | No   |  No    |  Yes     |    No      |
| Project__c       |   No   | Yes  | No   |  No    |  Yes     |    No      |
| Quote            |   No   | Yes  | No   |  No    |  Yes     |    No      |
| ReturnOrder      |   No   | Yes  | No   |  No    |  Yes     |    No      |
| ServiceAppointment| Yes   | Yes  | No   |  No    |  Yes     |    No      |
| ServiceContract  |   No   | Yes  | No   |  No    |  Yes     |    No      |
| WorkOrder        |   No   | Yes  | No   |  No    |  Yes     |    No      |

### Tab Visibility
- Product_Family__c: Visible
- Account: Visible
- Asset: Visible
- Case: Visible
- Lead: Visible
- Location: Visible
- Opportunity: Visible
- Pricebook2: Visible
- Product2: Visible
- ProductItem: Visible
- ProductRequest: Visible
- ProductTransfer: Visible
- Quote: Visible
- ReturnOrder: Visible
- ServiceAppointment: Visible
- ServiceContract: Visible
- WorkOrder: Visible

### Record Type Visibilities
- Account.Commercial_Customer: Visible
- Lead.Revamp: Visible

### System/User Permissions
_None_

### Field Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Grants broad read access to core and custom objects, with limited create/edit on Cases and Service Appointments for CCO users.

---

## Permission Set: **Manage Reports and Dashboard**

**Label:** Manage Reports and Dashboard

### Object Permissions
_None_

### System/User Permissions
- CreateCustomizeReports: Enabled
- CreateReportFolders: Enabled
- CreateReportInLightning: Enabled
- EditMyReports: Enabled
- ExportReport: Enabled
- ManageCustomReportTypes: Enabled
- ManagePvtRptsAndDashbds: Enabled
- ManageReportsInPubFolders: Enabled
- NewReportBuilder: Enabled
- RunReports: Enabled
- ScheduleReports: Enabled
- SubscribeToLightningReports: Enabled
- ViewPublicReports: Enabled
- ViewRoles: Enabled
- ViewSetup: Enabled

### Field Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Grants advanced reporting and dashboard management capabilities to power users.

---

## Permission Set: **sf api integration_inactive**

**Label:** sf api integration_inactive  
**Description:** not used anymore  
**License:** SalesforceAPIIntegrationPsl

### Object Permissions
| Object             | Create | Read | Edit | Delete | View All | Modify All |
|--------------------|--------|------|------|--------|----------|------------|
| API_Log__c         |  Yes   | Yes  | Yes  |  No    |  Yes     |    No      |
| Alternate_Part__c  |  Yes   | Yes  | Yes  |  No    |  Yes     |    No      |

### Field Permissions
| Field                              | Readable | Editable |
|------------------------------------|----------|----------|
| API_Log__c.API_Name__c             |   Yes    |   Yes    |
| API_Log__c.Account__c              |   Yes    |   Yes    |
| API_Log__c.Class_Name__c           |   Yes    |   Yes    |
| API_Log__c.End_Point__c            |   Yes    |   Yes    |
| API_Log__c.Error_Line_Number__c    |   Yes    |   Yes    |
| API_Log__c.Error_message__c        |   Yes    |   Yes    |
| API_Log__c.Method_Name__c          |   Yes    |   Yes    |
| API_Log__c.Request_Body__c         |   Yes    |   Yes    |
| API_Log__c.Response_Body__c        |   Yes    |   Yes    |
| API_Log__c.Response_Status_Code__c |   Yes    |   Yes    |
| API_Log__c.Response_Time__c        |   Yes    |   Yes    |
| API_Log__c.Service_Contract__c     |   Yes    |   Yes    |
| API_Log__c.Status__c               |   Yes    |   Yes    |
| API_Log__c.Targer_Record_Id__c     |   Yes    |   Yes    |
| API_Log__c.Template_Name__c        |   Yes    |   Yes    |
| Alternate_Part__c.Alternate_Part__c|   Yes    |   Yes    |
| Alternate_Part__c.Parent_Part__c   |   Yes    |   Yes    |
| Alternate_Part__c.Part_Code__c     |   Yes    |   No     |
| Alternate_Part__c.Part_Name__c     |   Yes    |   No     |

### System/User Permissions
_None_

### Apex Class Access
_None_

**Business Function:** (Inactive) Previously granted API integration object and field access for integration users.

--- 

---

## Permission Set: **BSL RCH**

**Label:** BSL RCH  
**Description:** This Permission set is to give Opportunity access which is blocked on profile level due to CPQ access

### Object Permissions
| Object      | Create | Read | Edit | Delete | View All | Modify All |
|-------------|--------|------|------|--------|----------|------------|
| Account     |   No   | Yes  | No   |  No    |  Yes     |    No      |
| Asset       |   No   | Yes  | No   |  No    |  Yes     |    No      |
| Contact     |   No   | Yes  | No   |  No    |   No     |    No      |
| Opportunity |   No   | Yes  | No   |  No    |  Yes     |    No      |

### Record Type Visibilities
- Asset.Asset: Visible
- Asset.Component: Visible
- Asset.StandBy_Asset: Visible
- Asset.Sub_Component: Visible
- Case.Customer_Request: Visible
- Case.Salesforce_System_Support: Visible
- Opportunity.AMC: Visible

### Tab Visibility
- Asset: Visible
- Case: Visible
- Opportunity: Visible
- WorkOrder: Visible
- Report: Visible

### System/User Permissions
_None_

### Field Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Grants read access to Account, Asset, Contact, and Opportunity, specifically to enable Opportunity access for users restricted by CPQ profile settings. 

---

## Permission Set: **LWC Access**

**Label:** LWC Access

### Object Permissions
_None_

### System/User Permissions
- CustomAppsOnFSMobile: Enabled
- FieldServiceAccess: Enabled
- FieldServiceMobileApp: Enabled
- FieldServiceScheduling: Enabled

### Field Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Grants access to custom Lightning Web Components and Field Service Mobile features for users requiring LWC and Field Service functionality. 

---

## Permission Set: **Disable MFA**

**Label:** Disable MFA

### Object Permissions
_None_

### System/User Permissions
- BypassMFAForUiLogins: Enabled

### Field Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Allows users to bypass Multi-Factor Authentication (MFA) for UI logins, typically used for integration or exception scenarios where MFA is not feasible. 

---

## Permission Set: **Account Category Access Permission Set**

**Label:** Account Category Access Permission Set  
**License:** Salesforce

### Custom Permissions
- Account_Category_Access: Enabled

### Object Permissions
_None_

### System/User Permissions
_None_

### Field Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Grants access to custom permission 'Account_Category_Access', likely used for controlling access to account category features or processes.

---

## Permission Set: **Admin Permissions**

**Label:** Admin Permissions

### Apex Class Access
- 100s of Apex classes enabled (see XML for full list; includes Account, Asset, Case, Product, Quote, Service, WorkOrder, and many more custom and standard classes)

### Custom Permissions
- BSL_Create_NAMO_Child_Customer: Enabled

### Object Permissions
- Extensive object permissions (see XML for full list; includes Account, Asset, Case, Contact, Opportunity, Product, Quote, ServiceAppointment, WorkOrder, and many custom objects)
- Most objects have full CRUD and View All/Modify All enabled for admin-level access

### Field Permissions
- Extensive field-level access (see XML for full list; includes all fields on Account, Asset, Address, Announcement_Messages__c, Alternate_Part__c, and many more)
- Most fields are readable and editable, with some exceptions (e.g., certain fields are read-only)

### System/User Permissions
- All major system permissions enabled (see XML for full list; includes ModifyAllData, ViewAllData, APIEnabled, ManageUsers, CustomizeApplication, etc.)

### Tab Visibility
- All major tabs visible (see XML for full list)

### Record Type Visibilities
- All major record types visible (see XML for full list)

**Business Function:** Grants full administrative access to all Salesforce data, objects, fields, and system features. Intended for system administrators and super users who require unrestricted access for configuration, integration, and support.

---

## Permission Set: **Advance Approval Access**

**Label:** Advance Approval Access  
**License:** SalesforceCPQ.CPQAAPerm

### Object Permissions
| Object                 | Create | Read | Edit | Delete | View All | Modify All |
|------------------------|--------|------|------|--------|----------|------------|
| sbaa__ApprovalRule__c  |  Yes   | Yes  | Yes  |  No    |  Yes     |    No      |
| sbaa__Approval__c      |  Yes   | Yes  | Yes  |  No    |  Yes     |    No      |

### Field Permissions
- Full access to all fields on sbaa__ApprovalRule__c and sbaa__Approval__c (see XML for full list)

### System/User Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Grants access to manage and process advanced approval rules and approval records for Salesforce CPQ Advanced Approvals.

---

## Permission Set: **Advance Approval CPQ Access**

**Label:** Advance Approval  CPQ Access  
**License:** SalesforceCPQ.CPQStandardPerm

### Object Permissions
| Object            | Create | Read | Edit | Delete | View All | Modify All |
|-------------------|--------|------|------|--------|----------|------------|
| SBQQ__Quote__c    |  Yes   | Yes  | Yes  |  Yes   |  Yes     |   Yes      |

### Record Type Visibilities
- SBQQ__Quote__c.AMC: Visible

### Field Permissions
- Read-only access to all fields on SBQQ__Quote__c (see XML for full list)

### System/User Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Grants full access to CPQ Quote object and fields, including create, read, edit, delete, and all record types, for users working with Salesforce CPQ Advanced Approvals.

---

## Permission Set: **Advanced Approvals User Clone**

**Label:** Advanced Approvals User Clone  
**Description:** Standard user permissions across all Salesforce CPQ Advanced Approvals objects.

### Application Visibilities
- sbaa__AdvancedApprovals: Visible

### Apex Class Access
- 30+ Apex classes enabled (see XML for full list; includes sbaa__ApprovalAPI, sbaa__ApprovalService, sbaa__MetaDataUtils, sbaa__Operators, sbaa__QueryBuilder, etc.)

### Page Access
- 20+ Visualforce pages enabled (see XML for full list; includes sbaa__ApprovalChainHelp, sbaa__ApprovalHelp, sbaa__DealDesk, sbaa__ListRequests, etc.)

### Object Permissions
| Object                      | Create | Read | Edit | Delete | View All | Modify All |
|-----------------------------|--------|------|------|--------|----------|------------|
| sbaa__ApprovalChain__c      |   No   | Yes  | No   |  No    |   No     |    No      |
| sbaa__ApprovalCondition__c  |   No   | Yes  | No   |  No    |   No     |    No      |
| sbaa__ApprovalRule__c       |   No   | Yes  | No   |  No    |   No     |    No      |
| sbaa__ApprovalSnapshot__c   |  Yes   | Yes  | No   |  No    |   No     |    No      |
| sbaa__ApprovalVariable__c   |   No   | Yes  | No   |  No    |   No     |    No      |
| sbaa__Approval__c           |  Yes   | Yes  | Yes  |  No    |   No     |    No      |
| sbaa__Approver__c           |   No   | Yes  | No   |  No    |   No     |    No      |
| sbaa__EmailTemplate__c      |   No   | Yes  | No   |  No    |   No     |    No      |
| sbaa__TrackedField__c       |   No   | Yes  | No   |  No    |   No     |    No      |
| sbaa__TrackedValue__c       |  Yes   | Yes  | No   |  No    |   No     |    No      |

### Field Permissions
- Read-only or editable access to all fields on Advanced Approvals objects (see XML for full list)

### System/User Permissions
_None_

**Business Function:** Grants access to all Advanced Approvals objects, classes, and pages for users who need to manage, process, and report on approval chains, rules, and related data in Salesforce CPQ.

---

## Permission Set: **API Integration Permission**

**Label:** API Integration Permission

### Object Permissions
| Object      | Create | Read | Edit | Delete | View All | Modify All |
|-------------|--------|------|------|--------|----------|------------|
| Product2    |  Yes   | Yes  | Yes  |  No    |   No     |    No      |

### Record Type Visibilities
- Account.Channel_Partner: Visible
- Account.Commercial_Customer: Visible
- Account.Residential_Customer: Visible
- PersonAccount.Master: Visible
- Product2.Child_Product: Visible
- Product2.Product: Visible
- Product2.Product_Development: Visible
- Product2.Spare: Visible

### Field Permissions
- Full access to all fields on Account and Product2 (see XML for full list)

### System/User Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Grants API integration users access to all necessary fields and records on Account and Product2 for data integration, synchronization, and automation.

---

## Permission Set: **Approve Permission**

**Label:** Approve Permission

### Object Permissions
_None_

### System/User Permissions
_None_

### Field Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Likely a placeholder or minimal permission set for users who only need approval access or to be assigned approval tasks. 

---

## Permission Set: **BSL CP Permission Set**

**Label:** BSL CP Permission Set  
**Description:** Case Object Create Permission giving through Permission Set for CP User  
**License:** Salesforce

### Object Permissions
| Object | Create | Read | Edit | Delete | View All | Modify All |
|--------|--------|------|------|--------|----------|------------|
| Case   |  Yes   | Yes  | Yes  |  No    |  Yes     |    No      |

### Record Type Visibilities
- Case.Customer_Request: Visible
- Case.Internal_Request: Visible

### Tab Visibility
- Create_a_Case_Custom: Visible
- Case: Visible

### System/User Permissions
_None_

### Field Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Grants CP users the ability to create and edit Cases, with visibility to specific record types and tabs for case management.

---

## Permission Set: **BSL Create NAMO Child Account**

**Label:** BSL Create NAMO Child Account

### Custom Permissions
- BSL_Create_NAMO_Child_Customer: Enabled

### Object Permissions
_None_

### System/User Permissions
_None_

### Field Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Grants access to custom permission for creating NAMO child customer accounts, likely used in specialized account creation flows.

---

## Permission Set: **BSL SME Permission Set**

**Label:** BSL SME Permission Set  
**License:** Salesforce

### Application Visibilities
- AMC, BSL_Service, BSL_Service_Console, BlueStar_Training, BlueStar_Trainings, FSL__FieldService, FSL__FieldService_Admin, ILT_Training__Training_Event_Sign_Up, SBQQ__QuoteQuickly, Sales, Technician_Onboarding, sbaa__AdvancedApprovals, standard__AllTabSet, standard__AppLauncher, standard__Chatter, standard__Commerce, standard__Community, standard__DataAssessment, standard__ExpressionSetConsole, standard__FlowsApp, standard__LightningBolt, standard__LightningInstrumentation, standard__LightningSales, standard__LightningSalesConsole, standard__LightningService, standard__Marketing, standard__OnlineSales, standard__Optimizer, standard__Platform, standard__PublicSectorInspectionManagement, standard__Sales, standard__SalesCloudMobile, standard__SalesforceCMS, standard__Service, standard__ServiceConsole, standard__TrustCard, tspa__Visual_Remote_Assistant

### Apex Class Access
- 100s of Apex classes enabled (see XML for full list; includes Account, Asset, Case, Opportunity, Product, Quote, Service, WorkOrder, and many more custom and standard classes)

### Object Permissions
- Extensive object permissions (see XML for full list; includes Account, Asset, Address, Announcement_Messages__c, Alternate_Part__c, Contact, Division__c, Location, Opportunity, ServiceContract, and many custom objects)
- Opportunity: Create, Read, Edit, Delete, View All, Modify All
- Account, Asset, Address, Alternate_Part__c, Announcement_Messages__c: Create, Read, Edit, View All
- Contact, Division__c, Location: Read only
- ServiceContract: Read, Edit

### Field Permissions
- Extensive field-level access (see XML for full list; includes all fields on Account, Opportunity, and many more)

### Page Access
- ProformaInvoiceVFPage, ProformaInvoiceVFPage_SQ: Enabled

### Record Type Visibilities
- Account.Channel_Partner: Visible
- Account.Commercial_Customer: Visible
- Account.Residential_Customer: Visible
- Division__c.CPSD: Visible
- Division__c.UPSD: Visible

### Tab Visibility
- API_Log__c: Visible
- Account: Visible
- Opportunity: Visible

### System/User Permissions
_None_

**Business Function:** Grants SME users broad access to sales, service, and training applications, with full access to Opportunity and related objects, and visibility to all key business data.

---

## Permission Set: **Bulk API Hard Delete Permission**

**Label:** Bulk API Hard Delete Permission

### System/User Permissions
- BulkApiHardDelete: Enabled

### Object Permissions
_None_

### Field Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Allows users to perform hard deletes via the Bulk API, typically for data cleanup or integration scenarios.

---

## Permission Set: **Bulk Product Registration**

**Label:** Bulk Product Registration

### Apex Class Access
- GenericFileUploaderController: Enabled
- productRegistrationController: Enabled

### Custom Metadata Type Access
- CSV_Uploading_Mapping__mdt: Enabled
- Parent_CSV_Mapping__mdt: Enabled

### Object Permissions
| Object                | Create | Read | Edit | Delete | View All | Modify All |
|-----------------------|--------|------|------|--------|----------|------------|
| Bulk_Product_Request__c |  Yes   | Yes  | Yes  |  Yes   |  Yes     |   Yes      |
| Bulk_Upload_Job__c      |  Yes   | Yes  | Yes  |  No    |   No     |    No      |

### Field Permissions
- Full access to all fields on Bulk_Product_Request__c and Bulk_Upload_Job__c (see XML for full list)

### Tab Visibility
- Bulk_Product_Registration: Visible
- Bulk_Product_Request__c: Visible
- Bulk_Upload_Job__c: Visible

### System/User Permissions
_None_

**Business Function:** Enables users to register products in bulk, upload CSVs, and manage bulk upload jobs for product registration processes.

---

## Permission Set: **Bulk Ticket Creation**

**Label:** Bulk Ticket Creation

### Apex Class Access
- BulkTicketCreationController: Enabled
- GenericFileUploaderController: Enabled

### Custom Metadata Type Access
- CSV_Uploading_Mapping__mdt: Enabled
- Parent_CSV_Mapping__mdt: Enabled

### Object Permissions
| Object                | Create | Read | Edit | Delete | View All | Modify All |
|-----------------------|--------|------|------|--------|----------|------------|
| Account               |  Yes   | Yes  | No   |  No    |   No     |    No      |
| Bulk_Upload_Job__c    |  Yes   | Yes  | Yes  |  No    |   No     |    No      |
| Case                  |  Yes   | Yes  | No   |  No    |   No     |    No      |
| Contact               |   No   | Yes  | No   |  No    |   No     |    No      |
| WorkOrder             |  Yes   | Yes  | No   |  No    |   No     |    No      |

### Field Permissions
- Full access to all fields on Account, Bulk_Upload_Job__c, Case, Contact, WorkOrder (see XML for full list)

### Record Type Visibilities
- Case.Internal_Request: Visible
- WorkOrder.Breakdown: Visible
- WorkOrder.Commissioning: Visible
- WorkOrder.Demo: Visible
- WorkOrder.Installation: Visible
- WorkOrder.PDI: Visible
- WorkOrder.PMS: Visible
- WorkOrder.Regular_Service: Visible

### Tab Visibility
- Bulk_Ticket_Creation: Visible
- Bulk_Upload_Job__c: Visible

### System/User Permissions
_None_

**Business Function:** Enables users to create tickets (cases, work orders) in bulk, upload CSVs, and manage bulk upload jobs for ticket creation processes.

---

## Permission Set: **By Pass Validation**

**Label:** By Pass Validation  
**License:** Salesforce

### Custom Permissions
- By_Pass_Validation: Enabled

### Object Permissions
_None_

### System/User Permissions
_None_

### Field Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Grants access to a custom permission for bypassing validation rules, likely used for data migration, integration, or exception handling scenarios. 

---

## Permission Set: **cases_Permisssion_Set**

**Label:** cases_Permisssion_Set  
**License:** Salesforce

### System/User Permissions
- GiveRecognitionBadge: Enabled

### Object Permissions
_None_

### Field Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Grants users the ability to give recognition badges, likely for Chatter or community engagement features.

---

## Permission Set: **CBO CPQ Quote Permission**

**Label:** CBO CPQ Quote Permission  
**License:** SalesforceCPQ.CPQStandardPerm

### Object Permissions
| Object                 | Create | Read | Edit | Delete | View All | Modify All |
|------------------------|--------|------|------|--------|----------|------------|
| SBQQ__QuoteTemplate__c |  Yes   | Yes  | Yes  |  No    |  Yes     |    No      |
| SBQQ__Quote__c         |   No   | Yes  | Yes  |  No    |  Yes     |    No      |

### Record Type Visibilities
- SBQQ__Quote__c.AMC: Visible

### Field Permissions
- Full access to all fields on SBQQ__QuoteTemplate__c and SBQQ__Quote__c (see XML for full list)

### System/User Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Grants users the ability to manage CPQ quote templates and edit quotes, with visibility to AMC record types for CPQ processes.

---

## Permission Set: **CBO Permission**

**Label:** CBO Permission  
**License:** Salesforce

### Object Permissions
| Object      | Create | Read | Edit | Delete | View All | Modify All |
|-------------|--------|------|------|--------|----------|------------|
| Account     |   No   | Yes  | No   |  No    |  Yes     |    No      |
| Contact     |   No   | Yes  | No   |  No    |   No     |    No      |
| Opportunity |   No   | Yes  | No   |  No    |   No     |    No      |
| Quote       |  Yes   | Yes  | Yes  |  No    |   No     |    No      |

### Record Type Visibilities
- Opportunity.AMC: Visible

### Tab Visibility
- Opportunity: Visible
- Quote: Visible

### Field Permissions
- Full access to key Opportunity fields (see XML for full list)

### System/User Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Grants users read access to Account, Contact, Opportunity, and full access to Quote, supporting CBO business processes.

---

## Permission Set: **Created date for data loader**

**Label:** Created date for data loader  
**License:** Salesforce

### Object Permissions
- Extensive object permissions (see XML for full list; includes Account, Asset, Case, Contact, Opportunity, Product2, and many custom objects)
- Most objects have full CRUD and View All/Modify All enabled for data loading and migration

### Field Permissions
- Extensive field-level access (see XML for full list; includes all fields on AssetWarranty, Account, and many more)

### System/User Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Grants full access to all objects and fields for data loading, migration, and integration scenarios, typically used with data loader tools.

---

## Permission Set: **CP Portal Permission**

**Label:** CP Portal Permission  
**License:** Salesforce

### Object Permissions
_None_

### System/User Permissions
_None_

### Field Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Likely a placeholder or minimal permission set for users accessing the CP Portal.

---

## Permission Set: **CPQ Advance Approval Read Permission**

**Label:** CPQ Advance Approval Read Permission

### Object Permissions
| Object                 | Create | Read | Edit | Delete | View All | Modify All |
|------------------------|--------|------|------|--------|----------|------------|
| sbaa__ApprovalChain__c |   No   | Yes  | No   |  No    |   No     |    No      |
| sbaa__Approval__c      |   No   | Yes  | No   |  No    |   No     |    No      |

### Tab Visibility
- sbaa__ApprovalChain__c: Visible

### Field Permissions
- Read-only or editable access to key fields on sbaa__Approval__c (see XML for full list)

### System/User Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Grants read-only access to advanced approval chains and approval records for CPQ processes.

---

## Permission Set: **CPQ Quote Line Only**

**Label:** CPQ Quote Line Only  
**Description:** This Permission set will give access to CPQ Quote Lines.

### Object Permissions
| Object                 | Create | Read | Edit | Delete | View All | Modify All |
|------------------------|--------|------|------|--------|----------|------------|
| SBQQ__QuoteLineGroup__c|   No   | Yes  | No   |  No    |   No     |    No      |
| SBQQ__QuoteLine__c     |  Yes   | Yes  | Yes  |  Yes   |   No     |    No      |
| SBQQ__Quote__c         |   No   | Yes  | No   |  No    |   No     |    No      |

### Field Permissions
- Full access to all fields on SBQQ__QuoteLine__c (see XML for full list)

### System/User Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Grants users access to manage CPQ quote lines, supporting detailed quote configuration and pricing.

---

## Permission Set: **CPQ Quote Permission Set**

**Label:** CPQ Quote Permission Set  
**License:** SalesforceCPQ.CPQStandardPerm

### Object Permissions
| Object                 | Create | Read | Edit | Delete | View All | Modify All |
|------------------------|--------|------|------|--------|----------|------------|
| SBQQ__PriceRule__c     |   No   | Yes  | No   |  No    |   No     |    No      |
| SBQQ__PricingGuidance__c|  No   | Yes  | No   |  No    |   No     |    No      |
| SBQQ__ProductRule__c   |   No   | Yes  | No   |  No    |   No     |    No      |
| SBQQ__QuoteTemplate__c |  Yes   | Yes  | Yes  |  No    |  Yes     |    No      |
| SBQQ__Quote__c         |  Yes   | Yes  | Yes  |  No    |  Yes     |    No      |
| SBQQ__Subscription__c  |  Yes   | Yes  | Yes  |  No    |  Yes     |    No      |

### Record Type Visibilities
- SBQQ__Quote__c.AMC: Visible

### Field Permissions
- Full access to all fields on SBQQ__QuoteTemplate__c, SBQQ__Quote__c, SBQQ__Subscription__c (see XML for full list)

### System/User Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Grants users full access to CPQ quote, quote template, and subscription objects for advanced quoting and pricing processes.

---

## Permission Set: **Commissioning Service Ticket Create Permission**

**Label:** Commissioning Service Ticket Create Permission

### Tab Visibility
- Create_Commissioning: Visible

### Object Permissions
_None_

### System/User Permissions
_None_

### Field Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Grants users access to the commissioning service ticket creation tab, likely for specialized service processes. 

---

## Permission Set: **Deploy Change Set Permission**

**Label:** Deploy Change Set Permission

### System/User Permissions
- InboundMigrationToolsUser: Enabled
- ModifyMetadata: Enabled
- ViewRoles: Enabled
- ViewSetup: Enabled

### Object Permissions
_None_

### Field Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Grants users the ability to deploy change sets, modify metadata, and view setup and roles, typically for deployment or release managers.

---

## Permission Set: **Field Service App Builder Permission**

**Label:** Field Service App Builder Permission
**Description:** Permission to configure the FSL App Builder - only for Admin

### System/User Permissions
- AccessContentBuilder: Enabled
- CustomAppsOnFSMobile: Enabled
- CustomizeApplication: Enabled
- ManageCustomPermissions: Enabled
- ViewRoles: Enabled
- ViewSetup: Enabled

### Object Permissions
_None_

### Field Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Grants admin users the ability to configure Field Service Lightning (FSL) App Builder and related customizations.

---

## Permission Set: **Field Service - LWC Offline**

**Label:** Field Service - LWC Offline
**Description:** Assign to Field Service Mobile users to give them permission to run LWC actions.

### System/User Permissions
- LightningOnFSMobile: Enabled

### Object Permissions
_None_

### Field Permissions
_None_

### Apex Class Access
- CalculateAverageRating: Enabled

**Business Function:** Allows Field Service Mobile users to run Lightning Web Component (LWC) actions, specifically for offline scenarios.

---

## Permission Set: **Field Service Mobile For Technician**

**Label:** Field Service Mobile For Technician
**Description:** Allows field technicians (Under Channel Partner) access to the Field Service mobile app for managing work orders, appointments, and inventory on the go.
**License:** FieldServiceMobilePsl

### Object Permissions
| Object              | Create | Read | Edit | Delete | View All | Modify All |
|---------------------|--------|------|------|--------|----------|------------|
| Contact             |   No   | Yes  | No   |  No    |   No     |    No      |
| ServiceAppointment  |   No   | Yes  | Yes  |  No    |   No     |    No      |
| ServiceResource     |   No   | Yes  | Yes  |  No    |   No     |    No      |
| WorkOrder           |   No   | Yes  | Yes  |  No    |   No     |    No      |

### Field Permissions
- Contact.MobilePhone: Read Only
- Contact.Title: Read Only
- ServiceAppointment.Address: Read/Edit
- ServiceAppointment.ContactId: Read/Edit
- ServiceAppointment.SchedEndTime: Read/Edit
- ServiceAppointment.SchedStartTime: Read/Edit
- ServiceAppointment.WorkTypeId: Read/Edit
- ServiceResource.IsActive: Read/Edit

### Record Type Visibilities
- Contact.Business_Contact: Visible
- Contact.Family_Contact: Visible
- WorkOrder.Breakdown: Visible
- WorkOrder.Commissioning: Visible
- WorkOrder.Demo: Visible
- WorkOrder.Installation: Visible
- WorkOrder.PDI: Visible
- WorkOrder.PMS: Visible
- WorkOrder.Regular_Service: Visible

### Tab Settings
- WorkOrder: Visible

### System/User Permissions
- ApiEnabled: Enabled
- FieldServiceAccess: Enabled
- FieldServiceMobileApp: Enabled
- LightningOnFSMobile: Enabled

### Flow Access
- VRA_AssistConnect_Flow: Enabled

**Business Function:** Enables field technicians to manage work orders, appointments, and inventory using the Field Service mobile app, with appropriate field and object-level access.

---

## Permission Set: **FieldServiceMobileStandardPermSet2**

**Label:** FieldServiceMobileStandardPermSet2
**Description:** Give your mobile workforce access to the Field Service mobile app. Set them up with the right user license and permissions.
**License:** FieldServiceMobilePsl

### Object Permissions
| Object              | Create | Read | Edit | Delete | View All | Modify All |
|---------------------|--------|------|------|--------|----------|------------|
| Contact             |   No   | Yes  | No   |  No    |   No     |    No      |
| ServiceAppointment  |   No   | Yes  | Yes  |  No    |   No     |    No      |
| ServiceResource     |   No   | Yes  | Yes  |  No    |   No     |    No      |
| WorkOrder           |  Yes   | Yes  | Yes  |  No    |   No     |    No      |

### Field Permissions
- Contact.Phone: Read Only
- Contact.Title: Read Only
- ServiceAppointment.Address: Read/Edit
- ServiceAppointment.ContactId: Read/Edit
- ServiceAppointment.SchedEndTime: Read/Edit
- ServiceAppointment.SchedStartTime: Read/Edit
- ServiceAppointment.StatusCategory: Read Only
- ServiceAppointment.WorkTypeId: Read/Edit
- ServiceResource.IsActive: Read/Edit

### System/User Permissions
- ApiEnabled: Enabled
- FieldServiceAccess: Enabled
- FieldServiceMobileApp: Enabled

**Business Function:** Provides Field Service mobile app access and permissions for mobile workforce, including key object and field-level access.

---

## Permission Set: **Field Service Admin License**

**Label:** Field Service Admin License
**License:** FieldServiceStandardPsl

### Object Permissions
_None_

### Field Permissions
_None_

### System/User Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Assigns the Field Service Standard PSL license to admin users for Field Service Lightning.

---

## Permission Set: **Field Service Admin Permissions**

**Label:** Field Service Admin Permissions

### Application Visibilities
- FSL__FieldService: Visible
- FSL__FieldService_Admin: Visible

### Apex Class Access
- FSL__AppointmentBookingLightningController: Enabled
- FSL__AutomationNameRest: Enabled
- FSL__EnhancedMatchRuleController: Enabled
- FSL__IntegrityCheckerUtils: Enabled
- FSL__IntegrityResults: Enabled
- FSL__OptInsightHealthCheckController: Enabled
- FSL__OptimizationCenter: Enabled
- FSL__OptimizationHub: Enabled
- FSL__OptimizationInsightsKPIController: Enabled
- FSL__OptimizationInsightsMetricsController: Enabled
- FSL__OptimizationInsightsSummaryController: Enabled
- FSL__SchedulingAssistant: Enabled
- FSL__capacityLimit: Enabled
- FSL__countRule: Enabled
- FSL__dispatchConsole: Enabled
- FSL__dispatchConsoleSettings: Enabled
- FSL__dispatchConsoleTerritoriesTree: Enabled
- FSL__retrieveDataActivityLog: Enabled

### Custom Permissions
- FSL__Abort_Optimization_Request: Enabled
- FSL__Bulk_Bundle: Enabled
- FSL__Bulk_Dispatch: Enabled
- FSL__Bulk_Optimize: Enabled
- FSL__Bulk_Schedule: Enabled
- FSL__Bulk_Unbundle: Enabled
- FSL__Bulk_Unschedule: Enabled
- FSL__Bundle_Unbundle: Enabled
- FSL__Create_Absences_from_Gantt: Enabled
- FSL__Create_custom_Gantt_filters: Enabled
- FSL__Enable_Bulk_Check_Rules: Enabled
- FSL__Enable_Check_Rules: Enabled
- FSL__Enable_Check_Rules_For_All_Services: Enabled
- FSL__Enable_Drag_And_Drop: Enabled
- FSL__Enable_Gantt_Locker: Enabled
- FSL__Enable_Gantt_Policy_Picker: Enabled
- FSL__Fill_in: Enabled
- FSL__Fix_Overlaps: Enabled
- FSL__Gantt_Palettes_Edit: Enabled
- FSL__Gantt_Palettes_View: Enabled
- FSL__Group_Nearby: Enabled
- FSL__Longterm_View: Enabled
- FSL__Monthly_Utilization: Enabled
- FSL__Policy_Picker_In_Appointment_Booking: Enabled
- FSL__Policy_Picker_In_Get_Candidates: Enabled
- FSL__Polygons_create_update: Enabled
- FSL__Polygons_view: Enabled
- FSL__Publish_custom_Gantt_filters: Enabled
- FSL__Reshuffle: Enabled
- FSL__Resource_Schedule_Optimization: Enabled
- FSL__Schedule: Enabled
- FSL__Service_List_Canceled: Enabled
- FSL__Service_List_Contractors: Enabled
- FSL__Service_List_Crews: Enabled
- FSL__Service_List_Exclude_Bundle_Members: Enabled
- FSL__Service_List_Flagged: Enabled
- FSL__Service_List_Gantt: Enabled
- FSL__Service_List_In_Jeopardy: Enabled
- FSL__Service_List_Rule_Violating: Enabled
- FSL__Service_List_Scheuled: Enabled
- FSL__Service_List_Selected: Enabled
- FSL__Service_List_Todo: Enabled
- FSL__Service_List_Unscheduled: Enabled
- FSL__Show_Change_Status: Enabled
- FSL__Show_Get_Candidates: Enabled
- FSL__Show_In_Jeopardy: Enabled
- FSL__Show_Pin_Service: Enabled
- FSL__Show_Unschedule: Enabled
- FSL__Utilization_on_Service_Territory: Enabled
- FSL__View_resource_on_secondary_STM: Enabled

### Field Permissions
_See file for exhaustive list; includes full access to all FSL custom objects and fields._

### Object Permissions
_See file for exhaustive list; includes full access to all FSL custom objects and standard objects related to Field Service._

### Page Accesses
- FSL__AppointmentBookingCommunitiesVf: Enabled
- FSL__AppointmentBookingVf: Enabled
- FSL__EmergencyWizard: Enabled
- FSL__GetCandidates: Enabled

### System/User Permissions
- FieldServiceAccess: Enabled

**Business Function:** Grants Field Service Lightning administrators comprehensive access to all FSL features, objects, fields, custom permissions, and Apex classes for full configuration and management.

---

## Permission Set: **Field Service Agent License**

**Label:** Field Service Agent License
**Description:** Assign to Call center agents to use field service
**License:** FieldServiceStandardPsl

### Object Permissions
_None_

### Field Permissions
_None_

### System/User Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Assigns the Field Service Standard PSL license to call center agents for Field Service Lightning.

---

## Permission Set: **Field Service Agent Permissions**

**Label:** Field Service Agent Permissions

### Apex Class Access
- FSL__AppointmentBookingLightningController: Enabled
- FSL__AutomationNameRest: Enabled

### Object Permissions
| Object              | Create | Read | Edit | Delete | View All | Modify All |
|---------------------|--------|------|------|--------|----------|------------|
| Account             |   No   | Yes  | No   |  No    |   No     |    No      |
| Asset               |   No   | Yes  | No   |  No    |   No     |    No      |
| Contact             |   No   | Yes  | No   |  No    |   No     |    No      |
| Entitlement         |   No   | Yes  | No   |  No    |   No     |    No      |
| FSL__Criteria__c    |   No   | Yes  | No   |  No    |   No     |    No      |
| FSL__FMA_Count_Action__e | Yes | Yes | No |  No    |   No     |    No      |
| FSL__FSL_Operation__c | Yes | Yes | Yes | Yes |   No     |    No      |
| FSL__Overlap_Event__e | Yes | Yes | No |  No    |   No     |    No      |
| FSL__Polygon__c     |   No   | Yes  | No   |  No    |   No     |    No      |
| FSL__SLR_Cache__c   | Yes    | Yes  | No   |  No    |   No     |    No      |
| FSL__SchedulingRecipe__c | No | Yes | No |  No    |   No     |    No      |
| FSL__Scheduling_Policy_Goal__c | No | Yes | No |  No    |   No     |    No      |
| FSL__Scheduling_Policy_Work_Rule__c | No | Yes | No |  No    |   No     |    No      |
| FSL__Scheduling_Policy__c | No | Yes | No |  No    |   No     |    No      |
| FSL__Service_Goal__c | No | Yes | No |  No    |   No     |    No      |
| FSL__Time_Dependency__c | No | Yes | No |  No    |   No     |    No      |
| FSL__Work_Rule_Entry__c | No | Yes | No |  No    |   No     |    No      |
| FSL__Work_Rule__c   |   No   | Yes  | No   |  No    |   No     |    No      |
| OperatingHours      |   No   | Yes  | No   |  No    |  Yes     |    No      |
| PushTopic           |   No   | Yes  | No   |  No    |   No     |    No      |
| RecordsetFilterCriteria | No | Yes | No |  No    |   No     |    No      |
| ServiceAppointment  |  Yes   | Yes  | Yes  |  No    |   No     |    No      |
| ServiceCrew         |   No   | Yes  | No   |  No    |   No     |    No      |
| ServiceResource     |  Yes   | Yes  | Yes  |  No    |   No     |    No      |
| ServiceTerritory    |   No   | Yes  | No   |  No    |   No     |    No      |
| Shift               |   No   | Yes  | No   |  No    |   No     |    No      |
| TravelMode          |   No   | Yes  | No   |  No    |   No     |    No      |
| WorkOrder           |  Yes   | Yes  | Yes  |  No    |   No     |    No      |
| WorkType            |   No   | Yes  | No   |  No    |   No     |    No      |

### Field Permissions
_See file for exhaustive list; includes access to all relevant FSL and standard object fields._

### System/User Permissions
- FieldServiceAccess: Enabled

**Business Function:** Grants Field Service Lightning agents access to all necessary FSL objects, fields, and Apex classes to perform their duties in the call center or field support roles. 

---

## Permission Set: **Field Service Bundle for Dispatcher License**

**Label:** Field Service Bundle for Dispatcher License
**Description:** Allows to use service appointment bundling feature
**License:** FieldServiceDispatcherPsl

### Object Permissions
_None_

### Field Permissions
_None_

### System/User Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Assigns the Field Service Dispatcher PSL license to users for service appointment bundling features.

---

## Permission Set: **Field Service Bundle for Dispatcher Permissions**

**Label:** Field Service Bundle for Dispatcher Permissions

### Custom Permissions
- FSL__Bulk_Bundle: Enabled
- FSL__Bulk_Unbundle: Enabled

### Object Permissions
| Object           | Create | Read | Edit | Delete | View All | Modify All |
|------------------|--------|------|------|--------|----------|------------|
| Account          |   No   | Yes  | No   |  No    |   No     |    No      |
| ApptBundlePolicy |  Yes   | Yes  | Yes  | Yes    |  Yes     |    No      |
| Contact          |   No   | Yes  | No   |  No    |   No     |    No      |

### Field Permissions
- ApptBundlePolicy.IsManualBundling: Read Only
- ServiceAppointment.BundlePolicyId: Read/Edit
- ServiceAppointment.IsBundle: Read/Edit
- ServiceAppointment.IsBundleMember: Read/Edit
- ServiceAppointment.IsManuallyBundled: Read/Edit
- ServiceAppointment.RelatedBundleId: Read/Edit
- ServiceTerritory.FSL__O2_Enabled__c: Read Only

### Page Accesses
- FSL__vf0008_BundlerDetailsLightBox: Enabled

### System/User Permissions
- FieldServiceAccess: Enabled

**Business Function:** Grants dispatchers permissions to manage service appointment bundling, including custom permissions, object, and field-level access.

---

## Permission Set: **Field Service Community Dispatcher License**

**Label:** Field Service Community Dispatcher License
**License:** FieldServiceDispatcherPsl

### System/User Permissions
- FieldServiceDispatcher: Enabled

### Object Permissions
_None_

### Field Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Assigns the Field Service Dispatcher PSL license to community dispatcher users.

---

## Permission Set: **Field Service Community Dispatcher Permissions**

**Label:** Field Service Community Dispatcher Permissions

### Apex Class Access
- FSL__AppointmentBookingLightningController: Enabled
- FSL__AutomationNameRest: Enabled
- FSL__OptInsightHealthCheckController: Enabled
- FSL__OptimizationHub: Enabled
- FSL__OptimizationInsightsKPIController: Enabled
- FSL__OptimizationInsightsMetricsController: Enabled
- FSL__OptimizationInsightsSummaryController: Enabled
- FSL__SchedulingAssistant: Enabled
- FSL__capacityLimit: Enabled

### Custom Permissions
- FSL__Bulk_Dispatch: Enabled
- FSL__Bulk_Optimize: Enabled
- FSL__Bulk_Schedule: Enabled
- FSL__Bulk_Unschedule: Enabled
- FSL__Create_Absences_from_Gantt: Enabled
- FSL__Create_custom_Gantt_filters: Enabled
- FSL__Enable_Bulk_Check_Rules: Enabled
- FSL__Enable_Check_Rules: Enabled
- FSL__Enable_Check_Rules_For_All_Services: Enabled
- FSL__Enable_Drag_And_Drop: Enabled
- FSL__Enable_Gantt_Locker: Enabled
- FSL__Enable_Gantt_Policy_Picker: Enabled
- FSL__Fill_in: Enabled
- FSL__Fix_Overlaps: Enabled
- FSL__Gantt_Palettes_View: Enabled
- FSL__Longterm_View: Enabled
- FSL__Monthly_Utilization: Enabled
- FSL__Polygons_view: Enabled
- FSL__Reshuffle: Enabled
- FSL__Resource_Schedule_Optimization: Enabled
- FSL__Schedule: Enabled
- FSL__Service_List_Canceled: Enabled
- FSL__Service_List_Contractors: Enabled
- FSL__Service_List_Crews: Enabled
- FSL__Service_List_Exclude_Bundle_Members: Enabled
- FSL__Service_List_Flagged: Enabled
- FSL__Service_List_Gantt: Enabled
- FSL__Service_List_In_Jeopardy: Enabled
- FSL__Service_List_Rule_Violating: Enabled
- FSL__Service_List_Scheuled: Enabled
- FSL__Service_List_Selected: Enabled
- FSL__Service_List_Todo: Enabled
- FSL__Service_List_Unscheduled: Enabled
- FSL__Show_Change_Status: Enabled
- FSL__Show_Get_Candidates: Enabled
- FSL__Show_In_Jeopardy: Enabled
- FSL__Show_Pin_Service: Enabled
- FSL__Show_Unschedule: Enabled
- FSL__Utilization_on_Service_Territory: Enabled
- FSL__View_resource_on_secondary_STM: Enabled

### Object Permissions
_See file for exhaustive list; includes full access to all FSL custom objects and standard objects related to Field Service._

### Field Permissions
_See file for exhaustive list; includes access to all relevant FSL and standard object fields._

### Page Accesses
- FSL__AppointmentBookingCommunitiesVf: Enabled
- FSL__AppointmentBookingVf: Enabled
- FSL__EmergencyWizard: Enabled
- FSL__FSLGanttMapSF: Enabled
- FSL__FSLGanttMapSFDev: Enabled
- FSL__FilterEditor: Enabled
- FSL__GanttPalette: Enabled
- FSL__GetCandidates: Enabled
- FSL__ResourceUnited: Enabled
- FSL__vf0008_BundlerDetailsLightBox: Enabled
- FSL__vf0018_ResourceLB_RelatedLists: Enabled
- FSL__vf001_ServiceExpert: Enabled
- FSL__vf002_ServiceExpertLightboxForm: Enabled
- FSL__vf002_ServiceExpertLightboxForm_Edit: Enabled
- FSL__vf004_ResourceChatter: Enabled
- FSL__vf005_AbsenceChatter: Enabled
- FSL__vf011_ResourceLightboxForm: Enabled
- FSL__vf012_AbsenceLightboxForm: Enabled
- FSL__vf012_AbsenceLightboxForm_Edit: Enabled
- FSL__vf015_ChangeServiceStatus: Enabled
- FSL__vf016_CompletionForm: Enabled
- FSL__vf017_AccountLightbox: Enabled
- FSL__vf017_IncompleteReason: Enabled
- FSL__vf023_CalendarEditor: Enabled
- FSL__vf034_Skill_Selector_V2_Resource_Page: Enabled
- FSL__vf078_CapacityCalendar: Enabled
- FSL__vf079_ResourceCalendar: Enabled
- FSL__vf0993_ServiceChatter: Enabled
- FSL__vf0994_WorkWorderLineItemRelatedLists: Enabled
- FSL__vf0995_WorkWorderRelatedLists: Enabled
- FSL__vf0996_WorkOrderChatter: Enabled
- FSL__vf0997_WorkOrderLineItemChatter: Enabled
- FSL__vf0998_WorkOrderLineItemLightbox: Enabled
- FSL__vf0998_WorkOrderLineItemLightbox_Edit: Enabled
- FSL__vf0999_WorkOrderLightbox: Enabled
- FSL__vf0999_WorkOrderLightbox_Edit: Enabled
- FSL__vf739_ComplexWork: Enabled

### Record Type Visibilities
- ResourceAbsence.FSL__Break: Visible
- ResourceAbsence.FSL__Non_Availability: Visible

### Tab Settings
- FSL__FieldService: Visible

### System/User Permissions
- FieldServiceAccess: Enabled

**Business Function:** Grants community dispatchers comprehensive access to all FSL features, objects, fields, custom permissions, and Apex classes for full configuration and management in a community context.

---

## Permission Set: **Field Service Self Service Permissions**

**Label:** Field Service Self Service Permissions

### Apex Class Access
- FSL__AppointmentBookingLightningController: Enabled
- FSL__AutomationNameRest: Enabled

### Object Permissions
_See file for exhaustive list; includes full access to all FSL custom objects and standard objects related to Field Service._

### Field Permissions
_See file for exhaustive list; includes access to all relevant FSL and standard object fields._

### Page Accesses
- FSL__AppointmentBookingCommunitiesVf: Enabled
- FSL__AppointmentBookingVf: Enabled
- FSL__EmergencyWizard: Enabled
- FSL__GetCandidates: Enabled

### System/User Permissions
- FieldServiceAccess: Enabled

**Business Function:** Grants self-service users access to book appointments, view and manage their own service requests, and interact with Field Service Lightning features in a self-service portal.

---

## Permission Set: **Field Service Dispatcher License**

**Label:** Field Service Dispatcher License
**License:** FieldServiceDispatcherPsl

### System/User Permissions
- FieldServiceDispatcher: Enabled

### Object Permissions
_None_

### Field Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Assigns the Field Service Dispatcher PSL license to dispatcher users.

---

## Permission Set: **Field Service Dispatcher Permissions**

**Label:** Field Service Dispatcher Permissions

### Application Visibilities
- FSL__FieldService: Visible

### Apex Class Access
- FSL__AppointmentBookingLightningController: Enabled
- FSL__AutomationNameRest: Enabled
- FSL__OptInsightHealthCheckController: Enabled
- FSL__OptimizationHub: Enabled
- FSL__OptimizationInsightsKPIController: Enabled
- FSL__OptimizationInsightsMetricsController: Enabled
- FSL__OptimizationInsightsSummaryController: Enabled
- FSL__SchedulingAssistant: Enabled
- FSL__capacityLimit: Enabled
- FSL__dispatchConsole: Enabled
- FSL__dispatchConsoleAvailabilityService: Enabled
- FSL__dispatchConsoleSettings: Enabled
- FSL__dispatchConsoleTerritoriesTree: Enabled

### Custom Permissions
- FSL__Bulk_Dispatch: Enabled
- FSL__Bulk_Optimize: Enabled
- FSL__Bulk_Schedule: Enabled
- FSL__Bulk_Unschedule: Enabled
- FSL__Create_Absences_from_Gantt: Enabled
- FSL__Create_custom_Gantt_filters: Enabled
- FSL__Enable_Bulk_Check_Rules: Enabled
- FSL__Enable_Check_Rules: Enabled
- FSL__Enable_Check_Rules_For_All_Services: Enabled
- FSL__Enable_Drag_And_Drop: Enabled
- FSL__Enable_Gantt_Locker: Enabled
- FSL__Enable_Gantt_Policy_Picker: Enabled
- FSL__Fill_in: Enabled
- FSL__Fix_Overlaps: Enabled
- FSL__Gantt_Palettes_View: Enabled
- FSL__Longterm_View: Enabled
- FSL__Monthly_Utilization: Enabled
- FSL__Polygons_view: Enabled
- FSL__Reshuffle: Enabled
- FSL__Resource_Schedule_Optimization: Enabled
- FSL__Schedule: Enabled
- FSL__Service_List_Canceled: Enabled
- FSL__Service_List_Contractors: Enabled
- FSL__Service_List_Crews: Enabled
- FSL__Service_List_Exclude_Bundle_Members: Enabled
- FSL__Service_List_Flagged: Enabled
- FSL__Service_List_Gantt: Enabled
- FSL__Service_List_In_Jeopardy: Enabled
- FSL__Service_List_Rule_Violating: Enabled
- FSL__Service_List_Scheuled: Enabled
- FSL__Service_List_Selected: Enabled
- FSL__Service_List_Todo: Enabled
- FSL__Service_List_Unscheduled: Enabled
- FSL__Show_Change_Status: Enabled
- FSL__Show_Get_Candidates: Enabled
- FSL__Show_In_Jeopardy: Enabled
- FSL__Show_Pin_Service: Enabled
- FSL__Show_Unschedule: Enabled
- FSL__Utilization_on_Service_Territory: Enabled
- FSL__View_resource_on_secondary_STM: Enabled

### Object Permissions
_See file for exhaustive list; includes full access to all FSL custom objects and standard objects related to Field Service._

### Field Permissions
_See file for exhaustive list; includes access to all relevant FSL and standard object fields._

### Page Accesses
- FSL__AppointmentBookingCommunitiesVf: Enabled
- FSL__AppointmentBookingVf: Enabled
- FSL__EmergencyWizard: Enabled
- FSL__GetCandidates: Enabled

### System/User Permissions
- FieldServiceAccess: Enabled

**Business Function:** Grants dispatchers comprehensive access to all FSL features, objects, fields, custom permissions, and Apex classes for full configuration and management.

---

## Permission Set: **Field Service Guest User Permissions**

**Label:** Field Service Guest User Permissions

### Apex Class Access
- FSL__AppointmentBookingLightningController: Enabled
- FSL__AutomationNameRest: Enabled

### Object Permissions
_See file for exhaustive list; includes full access to all FSL custom objects and standard objects related to Field Service._

### Field Permissions
_See file for exhaustive list; includes access to all relevant FSL and standard object fields._

### Page Accesses
- FSL__AppointmentBookingCommunitiesVf: Enabled
- FSL__AppointmentBookingVf: Enabled
- FSL__EmergencyWizard: Enabled
- FSL__GetCandidates: Enabled

### System/User Permissions
- FieldServiceAccess: Enabled

**Business Function:** Grants guest users access to book appointments, view and manage their own service requests, and interact with Field Service Lightning features as a guest.

---

## Permission Set: **Field Service Mobile License**

**Label:** Field Service Mobile License
**License:** FieldServiceMobilePsl

### System/User Permissions
- FieldServiceMobileApp: Enabled

### Object Permissions
_None_

### Field Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Assigns the Field Service Mobile PSL license to mobile users for Field Service Lightning.

---

## Permission Set: **Field Service Resource License**

**Label:** Field Service Resource License
**License:** FieldServiceSchedulingPsl

### Object Permissions
| Object           | Create | Read | Edit | Delete | View All | Modify All |
|------------------|--------|------|------|--------|----------|------------|
| ServiceResource  |   No   | Yes  | No   |  No    |   No     |    No      |

### Field Permissions
- ServiceResource.Aadhar_Number__c: Read Only
- ServiceResource.AccountId: Read Only
- ServiceResource.CP__c: Read Only
- ServiceResource.Communication_Preference__c: Read Only
- ServiceResource.Description: Read Only
- ServiceResource.Device_Make__c: Read Only
- ServiceResource.Device_Model__c: Read Only
- ServiceResource.Device_Type__c: Read Only
- ServiceResource.Driving_License_Expiry__c: Read Only
- ServiceResource.Driving_License_No__c: Read Only
- ServiceResource.Email__c: Read Only
- ServiceResource.FSL__Efficiency__c: Read Only
- ServiceResource.FSL__GanttLabel__c: Read Only
- ServiceResource.FSL__Online_Offset__c: Read Only
- ServiceResource.FSL__Picture_Link__c: Read Only
- ServiceResource.FSL__Priority__c: Read Only
- ServiceResource.FSL__Travel_Speed__c: Read Only
- ServiceResource.Insurance_Expiry__c: Read Only
- ServiceResource.Insurance_No__c: Read Only
- ServiceResource.IsActive: Read Only
- ServiceResource.IsCapacityBased: Read Only
- ServiceResource.IsOptimizationCapable: Read Only
- ServiceResource.LastKnownLocation: Read Only
- ServiceResource.LastKnownLocationDate: Read Only
- ServiceResource.Last_Training__c: Read Only
- ServiceResource.LocationId: Read Only
- ServiceResource.MTD__c: Read Only
- ServiceResource.Next_Training__c: Read Only
- ServiceResource.No_of_days_since_no_ticket__c: Read Only
- ServiceResource.Overall_Ratings__c: Read Only
- ServiceResource.ServiceCrewId: Read Only
- ServiceResource.Vehical_Number__c: Read Only
- ServiceResource.YTD__c: Read Only

### Tab Settings
- ServiceResource: Visible

### System/User Permissions
- FieldServiceScheduling: Enabled

**Business Function:** Assigns the Field Service Scheduling PSL license to resources and provides read-only access to all ServiceResource fields for scheduling and resource management. 

---

## Permission Set: **FSL Resource Permissions**

**Label:** Field Service Resource Permissions

### Object Permissions
| Object                   | Create | Read | Edit | Delete | View All | Modify All |
|--------------------------|--------|------|------|--------|----------|------------|
| Account                  |   No   | Yes  | No   |  No    |   No     |    No      |
| Asset                    |   No   | Yes  | No   |  No    |   No     |    No      |
| Contact                  |   No   | Yes  | No   |  No    |   No     |    No      |
| FSL__Criteria__c         |   No   | Yes  | No   |  No    |   No     |    No      |
| FSL__FMA_Count_Action__e |  Yes   | Yes  | No   |  No    |   No     |    No      |
| FSL__Polygon__c          |   No   | Yes  | No   |  No    |   No     |    No      |
| FSL__SchedulingRecipe__c |   No   | Yes  | No   |  No    |   No     |    No      |
| FSL__Work_Rule_Entry__c  |   No   | Yes  | No   |  No    |   No     |    No      |
| FSL__Work_Rule__c        |   No   | Yes  | No   |  No    |   No     |    No      |
| OperatingHours           |   No   | Yes  | No   |  No    |  Yes     |    No      |
| RecordsetFilterCriteria  |   No   | Yes  | No   |  No    |   No     |    No      |
| ServiceAppointment       |   No   | Yes  | Yes  |  No    |   No     |    No      |
| ServiceResource          |   No   | Yes  | Yes  |  No    |   No     |    No      |
| ServiceTerritory         |   No   | Yes  | No   |  No    |   No     |    No      |
| Shift                    |   No   | Yes  | No   |  No    |   No     |    No      |
| WorkOrder                |   No   | Yes  | No   |  No    |   No     |    No      |

### Field Permissions
- Extensive field-level read/edit access across FSL custom objects, ServiceAppointment, ServiceResource, ResourceAbsence, WorkOrder, and related objects. (See XML for full list.)

### Visualforce Page Access
- FSL__vf015_ChangeServiceStatus: Enabled
- FSL__vf016_CompletionForm: Enabled
- FSL__vf017_IncompleteReason: Enabled

### System/User Permissions
- FieldServiceAccess: Enabled

### Apex Class Access
_None_

**Business Function:** Grants Field Service Lightning resource users access to key FSL objects, fields, and Visualforce pages required for scheduling, resource management, and service appointment operations.

---

## Permission Set: **Integration permissions**

**Label:** Integration permissions
**License:** Salesforce Integration
**Description:** includes all the permissions for integration user

### Object Permissions
- Full CRUD and View All on all integration-related custom objects (see XML for exhaustive list)

### Field Permissions
- Extensive field-level read/edit access across all integration-related custom objects. (See XML for full list.)

### Record Type Visibilities
- Breakdown_Attribute__c.Action: Visible
- Breakdown_Attribute__c.Defect: Visible
- Breakdown_Attribute__c.Symptom: Visible
- Department__c.Sales: Visible
- Department__c.Service: Visible
- Division__c.CPSD: Visible
- Division__c.UPSD: Visible
- Invoice__c.Customer_Invoice: Visible
- Invoice__c.Dealer_Invoice: Visible
- Product_Family__c.Product_Family: Visible
- Product_Family__c.Product_Sub_Family: Visible
- SMS_Template__c.SMS: Visible
- SMS_Template__c.Whatsapp: Visible

### Apex Class Access
- 200+ Apex classes enabled for integration and automation (see XML for full list)

### System/User Permissions
_None_

**Business Function:** Provides all necessary object, field, and Apex class access for integration users to perform automated data exchange, logging, and process orchestration between Salesforce and external systems.

---

## Permission Set: **Knowledge LSF Permission Set**

**Label:** Knowledge LSF Permission Set
**Description:** Grants CRUD permission for Knowledge, as well as Knowledge user permissions.

### Object Permissions
| Object         | Create | Read | Edit | Delete | View All | Modify All |
|----------------|--------|------|------|--------|----------|------------|
| Knowledge__kav |  Yes   | Yes  | Yes  |  Yes   |  Yes     |   Yes      |

### System/User Permissions
- EditKnowledge: Enabled
- PublishArticles: Enabled
- ViewArchivedArticles: Enabled
- ViewDraftArticles: Enabled

### Field Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Grants users full access to Salesforce Knowledge, including article creation, editing, publishing, and management.

---

## Permission Set: **Knowledge Manager Permission Set**

**Label:** Knowledge Manager Permission Set

### Object Permissions
| Object         | Create | Read | Edit | Delete | View All | Modify All |
|----------------|--------|------|------|--------|----------|------------|
| Knowledge__kav |  Yes   | Yes  | Yes  |  Yes   |  Yes     |   Yes      |

### System/User Permissions
- EditKnowledge: Enabled
- ManageKnowledge: Enabled
- ManageKnowledgeImportExport: Enabled
- PublishArticles: Enabled
- ShareInternalArticles: Enabled
- ViewArchivedArticles: Enabled
- ViewDraftArticles: Enabled

### Field Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Provides full management capabilities for Salesforce Knowledge, including import/export, sharing, and advanced article management.

---

## Permission Set: **Manage All List View Permission**

**Label:** Manage All List View Permission

### System/User Permissions
- CreateCustomizeFilters: Enabled
- EditPublicFilters: Enabled

### Object Permissions
_None_

### Field Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Allows users to create and edit public list view filters, supporting advanced list management and sharing.

---

## Permission Set: **LWC Access**

**Label:** LWC Access

### System/User Permissions
- CustomAppsOnFSMobile: Enabled
- FieldServiceAccess: Enabled
- FieldServiceMobileApp: Enabled
- FieldServiceScheduling: Enabled

### Object Permissions
_None_

### Field Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Grants access to custom Lightning Web Components and Field Service Mobile features for users requiring LWC and Field Service functionality.

---

## Permission Set: **Manage Reports and Dashboard**

**Label:** Manage Reports and Dashboard

### System/User Permissions
- CreateCustomizeReports: Enabled
- CreateReportFolders: Enabled
- CreateReportInLightning: Enabled
- EditMyReports: Enabled
- ExportReport: Enabled
- ManageCustomReportTypes: Enabled
- ManagePvtRptsAndDashbds: Enabled
- ManageReportsInPubFolders: Enabled
- NewReportBuilder: Enabled
- RunReports: Enabled
- ScheduleReports: Enabled
- SubscribeToLightningReports: Enabled
- ViewPublicReports: Enabled
- ViewRoles: Enabled
- ViewSetup: Enabled

### Object Permissions
_None_

### Field Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Grants comprehensive report and dashboard management capabilities, including creation, editing, scheduling, and sharing of reports and dashboards.

---

## Permission Set: **Manage Reports Permission**

**Label:** Manage Reports Permission

### System/User Permissions
- CreateCustomizeReports: Enabled
- CreateReportFolders: Enabled
- EditMyReports: Enabled
- ExportReport: Enabled
- ManagePvtRptsAndDashbds: Enabled
- ManageReportsInPubFolders: Enabled
- RunReports: Enabled
- ScheduleReports: Enabled
- SubscribeReportRolesGrps: Enabled
- SubscribeReportToOtherUsers: Enabled
- SubscribeToLightningReports: Enabled
- ViewPublicReports: Enabled

### Object Permissions
_None_

### Field Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Enables users to manage, schedule, and subscribe to reports, supporting advanced reporting workflows and collaboration.

---

## Permission Set: **Modify All Data**

**Label:** Modify All Data

### Object Permissions
- Full CRUD, View All, and Modify All on all standard and custom objects (see XML for exhaustive list)

### System/User Permissions
- All major system permissions enabled (see XML for full list; includes ModifyAllData, ViewAllData, APIEnabled, ManageUsers, CustomizeApplication, etc.)

### Field Permissions
- Extensive field-level access (see XML for full list)

### Apex Class Access
_None_

**Business Function:** Grants the powerful "Modify All Data" permission, allowing users to view and edit all data in the org, typically reserved for administrators.

---

## Permission Set: **Modify Metadata**

**Label:** Modify Metadata

### System/User Permissions
- AssignPermissionSets: Enabled
- AuthorApex: Enabled
- DelegatedTwoFactor: Enabled
- FreezeUsers: Enabled
- GovernNetworks: Enabled
- ManageInteraction: Enabled
- ManageInternalUsers: Enabled
- ManageIpAddresses: Enabled
- ManageLoginAccessPolicies: Enabled
- ManageNetworks: Enabled
- ManagePasswordPolicies: Enabled
- ManageProfilesPermissionsets: Enabled
- ManageRoles: Enabled
- ManageSharing: Enabled
- ManageUsers: Enabled
- ModifyMetadata: Enabled
- MonitorLoginHistory: Enabled
- ResetPasswords: Enabled
- RunFlow: Enabled
- ViewAllUsers: Enabled
- ViewRoles: Enabled
- ViewSetup: Enabled

### Object Permissions
_None_

### Field Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Allows users to modify metadata, such as custom objects, fields, and page layouts, supporting configuration and customization tasks.

---

## Permission Set: **Omni Setup Flow**

**Label:** Omni Setup Flow

### System/User Permissions
_None_

### Object Permissions
_None_

### Field Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Used for Omni-Channel setup flows; typically grants access to setup/configuration flows for service channels and routing.

---

## Permission Set: **Partner Community Custom CPQ Access**

**Label:** Partner Community Custom CPQ Access

### Object Permissions
- Extensive read and some create/edit on CPQ and approval objects (see XML for full list)

### Field Permissions
- Extensive field-level read access on PricebookEntry, SBQQ__CustomAction__c, SBQQ__ImportFormat__c, SBQQ__QuoteDocument__c, SBQQ__QuoteTemplate__c, SBQQ__TemplateContent__c, SBQQ__TemplateSection__c, User, sbaa__ApprovalChain__c, sbaa__ApprovalCondition__c, sbaa__ApprovalRule__c, sbaa__ApprovalVariable__c, sbaa__Approval__c, sbaa__Approver__c, etc. (see XML for full list)

### Page Accesses
- Many Visualforce pages enabled (see XML for full list)

### Tab Settings
- SBQQ__CustomAction__c: Visible
- SBQQ__ImportFormat__c: Visible
- sbaa__ApprovalRule__c: Visible
- sbaa__Approver__c: Visible

### Apex Class Access
- Extensive Apex class access (see XML for full list)

**Business Function:** Grants Partner Community users access to CPQ and approval objects, Visualforce pages, and related features for custom quoting and approval processes.

---

## Permission Set: **Permission for Set Audit**

**Label:** Permission for Set Audit
**License:** Salesforce

### System/User Permissions
- CreateAuditFields: Enabled

### Object Permissions
_None_

### Field Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Grants users the ability to create audit fields, typically for auditing and compliance purposes.

---

## Permission Set: **Pricebook Entry Create**

**Label:** Pricebook Entry Create

### Object Permissions
| Object      | Create | Read | Edit | Delete | View All | Modify All |
|-------------|--------|------|------|--------|----------|------------|
| Pricebook2  |  Yes   | Yes  | Yes  |  No    |   No     |    No      |
| Product2    |   No   | Yes  | No   |  No    |   No     |    No      |

### Field Permissions
- Full access to key Pricebook2 and PricebookEntry fields (see XML for full list)

### System/User Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Grants users the ability to create and edit Pricebook2 and PricebookEntry records, supporting product and pricing management.

---

## Permission Set: **Product Delete Only**

**Label:** Product Delete Only
**Description:** This permission will give access to delete the products.

### Object Permissions
| Object      | Create | Read | Edit | Delete | View All | Modify All |
|-------------|--------|------|------|--------|----------|------------|
| Pricebook2  |  Yes   | Yes  | Yes  |  Yes   |   No     |    No      |
| Product2    |  Yes   | Yes  | Yes  |  Yes   |   No     |    No      |

### Field Permissions
- Full access to all key fields on Pricebook2, PricebookEntry, and Product2 (see XML for full list)

### Record Type Visibilities
- Product2.Child_Product: Visible
- Product2.Product: Visible
- Product2.Product_Development: Visible
- Product2.Spare: Visible

### System/User Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Grants users the ability to delete products and related pricebook entries, supporting product lifecycle management.

---

## Permission Set: **Promotional Warranty create Custom Permission**

**Label:** Promotional Warranty create Custom Permission
**Description:** To assign promotional warranty custom permission

### Custom Permissions
- Promotional_Warranty_Create_Permission: Enabled

### System/User Permissions
- ApiEnabled: Enabled

### Object Permissions
_None_

### Field Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Grants access to a custom permission for creating promotional warranties, typically used in warranty management processes.

---

## Permission Set: **Query All Files**

**Label:** Query All Files

### Object Permissions
- Read and View All on all standard and custom objects (see XML for exhaustive list)

### System/User Permissions
- QueryAllFiles: Enabled
- ViewAllData: Enabled
- ViewAllForecasts: Enabled
- ViewEventLogFiles: Enabled
- ViewPublicDashboards: Enabled
- ViewPublicReports: Enabled
- ViewRoles: Enabled
- ViewSetup: Enabled

### Field Permissions
- Extensive field-level read access (see XML for full list)

### Apex Class Access
_None_

**Business Function:** Grants users the ability to query all files and view all data, typically for data analysis, reporting, and compliance.

---

## Permission Set: **RadiusAdjustmentPermissionSet**

**Label:** RadiusAdjustmentPermissionSet
**License:** Salesforce

### Object Permissions
| Object      | Create | Read | Edit | Delete | View All | Modify All |
|-------------|--------|------|------|--------|----------|------------|
| Account     |   No   | Yes  | Yes  |  No    |   No     |    No      |
| Contact     |   No   | Yes  | No   |  No    |   No     |    No      |

### Field Permissions
- Account.Cellphone_Not_Allowed__c: Read/Edit
- Account.Radius_Unit__c: Read/Edit
- Account.Radius__c: Read/Edit

### Record Type Visibilities
- Account.Commercial_Customer: Visible

### Tab Settings
- standard-Account: Visible

### System/User Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Grants users the ability to edit radius-related fields on Account, supporting location-based business logic.

---

## Permission Set: **Read Only Access**

**Label:** Read Only Access
**Description:** Created Audit Team where they need to view all data with read-only

### Object Permissions
| Object      | Create | Read | Edit | Delete | View All | Modify All |
|-------------|--------|------|------|--------|----------|------------|
| Account     |   No   | Yes  | No   |  No    |  Yes     |    No      |
| Case        |   No   | Yes  | No   |  No    |  Yes     |    No      |
| Contact     |   No   | Yes  | No   |  No    |   No     |    No      |
| WorkOrder   |   No   | Yes  | No   |  No    |  Yes     |    No      |

### Record Type Visibilities
- Account.Channel_Partner: Visible
- Account.Commercial_Customer: Visible
- Account.Residential_Customer: Visible
- Case.Customer_Request: Visible
- Case.Internal_Request: Visible
- Case.Salesforce_System_Support: Visible
- Case.Stock_Defective: Visible
- WorkOrder.Breakdown: Visible
- WorkOrder.Bulk_PMS_Checklist: Visible
- WorkOrder.Commissioning: Visible
- WorkOrder.Commissioning_Screw_Chiller: Visible
- WorkOrder.Commissioning_Scroll_Chiller: Visible
- WorkOrder.Commissioning_VRF: Visible
- WorkOrder.Demo: Visible
- WorkOrder.Installation: Visible
- WorkOrder.PDI: Visible
- WorkOrder.PMS: Visible
- WorkOrder.Regular_Service: Visible

### System/User Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Grants users read-only access to all key business data, supporting audit and compliance needs.

---

## Permission Set: **Report Type Access**

**Label:** Report Type Access

### System/User Permissions
- ManageCustomReportTypes: Enabled
- ViewRoles: Enabled
- ViewSetup: Enabled

### Object Permissions
_None_

### Field Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Grants users the ability to manage custom report types, supporting advanced reporting configuration.

---

## Permission Set: **Report View Access**

**Label:** Report View Access

### System/User Permissions
- ExportReport: Enabled
- ManageCustomReportTypes: Enabled
- RunReports: Enabled
- ViewPublicReports: Enabled
- ViewRoles: Enabled
- ViewSetup: Enabled

### Object Permissions
_None_

### Field Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Grants users the ability to view and export reports, supporting reporting and data analysis needs.

---

## Permission Set: **Report View and Edit Own access**

**Label:** Report View and Edit Own access

### System/User Permissions
- CreateCustomizeReports: Enabled
- EditMyReports: Enabled
- ExportReport: Enabled
- RunReports: Enabled
- ScheduleReports: Enabled
- ViewPublicReports: Enabled

### Object Permissions
_None_

### Field Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Grants users the ability to view, edit, and schedule their own reports, supporting personalized reporting workflows.

---

## Permission Set: **Salesforce Adoption Dashboard Admin**

**Label:** Salesforce Adoption Dashboard Admin

### Field Permissions
- Campaign.DB_Campaign_Tactic__c: Read/Edit
- Lead.DB_Created_Date_without_Time__c: Read Only
- Lead.DB_Lead_Age__c: Read Only
- Opportunity.DB_Competitor__c: Read/Edit
- User.DB_Region__c: Read/Edit

### System/User Permissions
_None_

### Object Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Grants access to key fields for managing Salesforce Adoption Dashboard, supporting adoption tracking and analytics.

---

## Permission Set: **SDEPermissionSet**

**Label:** SDEPermissionSet

### Application Visibilities
- BSL_Service_Console, standard__AnypointPlatform, standard__Approvals, standard__Commerce, standard__DataAssessment, standard__DataGovernanceConsole, standard__DataManager, standard__Insights, standard__MSJApp, standard__PublicSectorInspectionManagement, standard__SalesCloudMobile, standard__SalesforceContracts, standard__TrustCard, standard__Work: Visible

### Apex Class Access
- Extensive Apex class access (see XML for full list)

### Field Permissions
- Extensive field-level access (see XML for full list)

### Object Permissions
- Extensive object permissions (see XML for full list)

**Business Function:** Grants SDE users access to a wide range of Salesforce features, applications, and data, supporting advanced business processes and integrations.

---

## Permission Set: **Service Contract Update**

**Label:** Service Contract Update
**Description:** This permission set will give access to edit Service Contracts.

### Object Permissions
| Object           | Create | Read | Edit | Delete | View All | Modify All |
|------------------|--------|------|------|--------|----------|------------|
| ServiceContract  |   No   | Yes  | Yes  |  Yes   |  Yes     |   Yes      |

### Field Permissions
- Full access to all key ServiceContract fields (see XML for full list)

### Record Type Visibilities
- ServiceContract.AMC: Visible

### Tab Settings
- standard-ServiceContract: Visible

### System/User Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Grants users the ability to edit and delete Service Contracts, supporting contract management processes.

---

## Permission Set: **sf api integration_inactive**

**Label:** sf api integration_inactive
**Description:** not used anymore
**License:** SalesforceAPIIntegrationPsl

### Object Permissions
| Object             | Create | Read | Edit | Delete | View All | Modify All |
|--------------------|--------|------|------|--------|----------|------------|
| API_Log__c         |  Yes   | Yes  | Yes  |  No    |  Yes     |    No      |
| Alternate_Part__c  |  Yes   | Yes  | Yes  |  No    |  Yes     |    No      |

### Field Permissions
- Full access to all key fields on API_Log__c and Alternate_Part__c (see XML for full list)

### System/User Permissions
_None_

### Apex Class Access
_None_

**Business Function:** (Inactive) Previously granted API integration object and field access for integration users.

---

## Permission Set: **sf api integration**

**Label:** sf api integration

### Object Permissions
- Extensive object permissions and field-level access for Account, Asset, Case, Contact, Opportunity, Product2, ServiceContract, and many custom objects (see XML for full list)

### Field Permissions
- Extensive field-level access (see XML for full list)

### System/User Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Grants API integration users access to all necessary fields and records for data integration, synchronization, and automation.

---

## Permission Set: **sf_devops_InitializeEnvironments**

**Label:** sf_devops_InitializeEnvironments
**Description:** Allows managers of the DevOps Center to manage connections to development environments. This requires the Modify Metadata Through Metadata API Functions and Customize Application permissions.

### System/User Permissions
- CustomizeApplication: Enabled
- ManageCustomPermissions: Enabled
- ModifyMetadata: Enabled
- ViewRoles: Enabled
- ViewSetup: Enabled

### Object Permissions
_None_

### Field Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Grants DevOps Center managers the ability to manage environment connections and metadata, supporting DevOps workflows.

---

## Permission Set: **sf_devops_NamedCredentials**

**Label:** sf_devops_NamedCredentials
**Description:** Grants access to the Named Credentials needed to authenticate to work environments. Created and maintained automatically by DevOps Center.

### System/User Permissions
- ApiEnabled: Enabled

### Object Permissions
_None_

### Field Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Grants access to Named Credentials for DevOps Center authentication to work environments.

---

## Permission Set: **sfdcInternalInt__sfdc_cpq**

**Label:** sfdcInternalInt__sfdc_cpq
**Description:** Give the CPQ integration user access to external calculation services.

### Object Permissions
- Extensive object and field-level access for CPQ objects (see XML for full list)

### Field Permissions
- Extensive field-level access (see XML for full list)

### System/User Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Grants CPQ integration users access to external calculation services and related CPQ data.

---

## Permission Set: **sfdcInternalInt__sfdc_fieldservice**

**Label:** sfdcInternalInt__sfdc_fieldservice
**Description:** Permissions to access data needed for optimization, automatic scheduling, and service appointment bundling.(Licenseless Migration)
**License:** Cloud Integration User

### Object Permissions
- Extensive object and field-level access for Field Service and related objects (see XML for full list)

### Field Permissions
- Extensive field-level access (see XML for full list)

### System/User Permissions
_None_

### Apex Class Access
- FSL__AutomationNameRest: Enabled
- FSL__BulkServiceBasedRestRequest: Enabled
- FSL__O2FetchFiles: Enabled
- FSL__ResourceBasedRestRequest: Enabled
- FSL__ServiceBasedRestRequest: Enabled
- FSL__TerritoryBasedRestRequest: Enabled

**Business Function:** Grants integration users access to Field Service data for optimization, scheduling, and bundling.

---

## Permission Set: **sfdcInternalInt__sfdc_scrt2**

**Label:** SCRT2 Integration User
**Description:** Give SCRT2 Integration User necessary access
**License:** Cloud Integration User

### Object Permissions
| Object      | Create | Read | Edit | Delete | View All | Modify All |
|-------------|--------|------|------|--------|----------|------------|
| Case        |   No   | Yes  | No   |  No    |  Yes     |    No      |

### System/User Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Grants SCRT2 integration users read access to all Cases for integration purposes.

---

## Permission Set: **SteelBrickCPQStandardObjectsAccess**

**Label:** Salesforce CPQ Integration User (Unmanaged)
**Description:** Give the CPQ integration user access to standard objects used by Salesforce CPQ.

### System/User Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Grants CPQ integration users access to standard objects required by Salesforce CPQ.

---

## Permission Set: **SSD_Create_Case_Permission**

**Label:** SSD_Create_Case_Permission

### Apex Class Access
- AccountConstant: Enabled
- AssetConstant: Enabled
- BranchDivisionSelector: Enabled
- CPMappingConstant: Enabled
- CPMappingSelector: Enabled
- CaseConstants: Enabled
- CaseService: Enabled
- CreateCaseFormController: Enabled
- ServiceTerritorySelector: Enabled
- UserSelector: Enabled
- UtilityClass: Enabled
- WorkOrderConstants: Enabled
- WorkOrderSelector: Enabled

### Field Permissions
- Extensive field-level access for Account, Case, Contact, Product2, and related objects (see XML for full list)

### Object Permissions
- Extensive object permissions (see XML for full list)

**Business Function:** Grants users the ability to create cases and access related data and classes for SSD processes.

---

## Permission Set: **View/Modify Contract WorkOrder**

**Label:** View/Modify Contract WorkOrder

### Object Permissions
| Object                | Create | Read | Edit | Delete | View All | Modify All |
|-----------------------|--------|------|------|--------|----------|------------|
| Contract_WorkOrder__c |   No   | Yes  | No   |  No    |  Yes     |    No      |

### Field Permissions
- Read-only access to all key fields on Contract_WorkOrder__c (see XML for full list)

### System/User Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Grants users read-only access to contract work orders, supporting contract and work order management.

---

## Permission Set: **View Reports and Dashboard**

**Label:** View Reports and Dashboard

### System/User Permissions
- ExportReport: Enabled
- ManagePvtRptsAndDashbds: Enabled
- RunReports: Enabled
- ScheduleReports: Enabled
- SubscribeToLightningReports: Enabled
- ViewPublicReports: Enabled
- ViewRoles: Enabled
- ViewSetup: Enabled

### Object Permissions
_None_

### Field Permissions
_None_

### Apex Class Access
_None_

**Business Function:** Grants users the ability to view, export, and schedule reports and dashboards, supporting reporting and analytics needs.

---

</rewritten_file>