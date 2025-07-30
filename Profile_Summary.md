# Salesforce Custom Profile Summary

## Executive Summary & Business Overview

### Document Purpose
This document provides a comprehensive technical reference for all **77 Salesforce Profiles** in the organization, serving as the primary source for understanding, maintaining, and optimizing user access controls and security configurations across all business modules. The document covers both custom profiles and standard profiles with detailed access mappings.

### Business Context
The organization operates a complex multi-module Salesforce ecosystem with specialized user roles across:
- **Field Service Operations** (FSL - Field Service Lightning)
- **Partner Community Management** (Channel Partners, External Users)
- **Integration & API Management** (System Integrations, API Users)
- **Sales & Service Operations** (Sales, Service, Support)
- **Administration & System Management** (System Administrators, Power Users)
- **Analytics & Reporting** (Analytics Cloud, Reporting)
- **Chatter & Collaboration** (Social Features, Communication)
- **Identity & Security** (Authentication, Access Control)

### Document Statistics
- **Total Profiles:** 77 profiles (5 custom + 23 standard + 49 XML profiles)
- **Document Size:** 1,152 lines (~46 KB)
- **Profile Distribution:**
  - **Custom Profiles:** 5 profiles (6.5%)
  - **Standard Profiles:** 23 profiles (29.9%)
  - **XML Profiles:** 49 profiles (63.6%)

### License Distribution Analysis
- **Salesforce Standard:** 35 profiles (45.5%)
- **Salesforce Integration:** 12 profiles (15.6%)
- **Partner Community:** 5 profiles (6.5%)
- **Guest User License:** 3 profiles (3.9%)
- **Chatter Licenses:** 3 profiles (3.9%)
- **Field Service Lightning:** 2 profiles (2.6%)
- **Analytics Cloud:** 2 profiles (2.6%)
- **Other Specialized:** 17 profiles (22.1%)

### Business Modules & Functional Areas

#### 1. **Partner Community Management - 6.5%**
- **Channel Partner Users:** External partner access to service and sales features
- **Partner Portal Access:** Limited external access for business partners
- **Community Collaboration:** Partner-specific features and data access
- **External User Management:** Guest and external user access controls

#### 2. **Integration & API Management - 15.6%**
- **API Integration Users:** System-to-system integration capabilities
- **Salesforce Integration:** Internal integration processes
- **Analytics Cloud Integration:** Analytics data integration
- **External Service Integration:** Third-party system connectivity

#### 3. **Field Service Operations - 2.6%**
- **Field Service Lightning:** Mobile and desktop field service capabilities
- **Service Management:** Work order and appointment management
- **Mobile Workforce:** Field technician access and capabilities
- **Service Scheduling:** Resource and appointment scheduling

#### 4. **Sales & Service Operations - 25.3%**
- **Sales Operations:** Opportunity and quote management
- **Service Operations:** Case and service contract management
- **Customer Support:** Customer service and support capabilities
- **Account Management:** Account and contact management

#### 5. **Administration & System Management - 20.8%**
- **System Administrators:** Full org access and configuration
- **Power Users:** Advanced user capabilities
- **Read-Only Access:** Audit and compliance access
- **Minimum Access:** Restricted access for specific use cases

#### 6. **Analytics & Reporting - 2.6%**
- **Analytics Cloud Users:** Analytics and reporting capabilities
- **Report Management:** Report creation and management
- **Data Analysis:** Data query and analysis capabilities
- **Dashboard Management:** Visualization and sharing

#### 7. **Chatter & Collaboration - 3.9%**
- **Chatter External Users:** External collaboration access
- **Chatter Free Users:** Internal collaboration only
- **Chatter Moderators:** Content moderation capabilities
- **Social Features:** Social collaboration and communication

#### 8. **Identity & Security - 7.8%**
- **Identity Users:** Authentication and SSO capabilities
- **Guest Users:** Limited external access
- **Security Management:** Access control and security features
- **Authentication Services:** Multi-factor authentication and security

### Technical Architecture Overview

#### **Profile Categories:**
1. **Custom Profiles:** Organization-specific profiles tailored to business needs
2. **Standard Profiles:** Salesforce-provided profiles for common use cases
3. **XML Profiles:** Detailed profile configurations in XML format

#### **Access Control Patterns:**
- **Application Access:** Visibility to Salesforce applications and features
- **Object Permissions:** CRUD access to standard and custom objects
- **Field-Level Security:** Granular field access controls
- **Record Type Access:** Business process-specific record access
- **Tab Visibility:** Navigation and interface access
- **Apex Class Access:** Custom code execution permissions
- **Visualforce Page Access:** Custom UI component access

#### **License Optimization:**
- **Standard Salesforce:** Core business operations (45.5%)
- **Integration Licenses:** API and system connectivity (15.6%)
- **Community Licenses:** External user access (10.4%)
- **Specialized Licenses:** Field service, analytics, chatter (8.9%)

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
- **Access Reviews:** Regular profile audits and updates

### Business Impact & Recommendations

#### **Operational Efficiency:**
- **Streamlined Access:** Role-specific profiles reduce complexity
- **Community Enablement:** Partner and external user access
- **Integration Capabilities:** API access enables system connectivity
- **Mobile Enablement:** Field service mobile access improves operations

#### **Risk Management:**
- **Access Segregation:** Prevents unauthorized data access
- **Audit Capabilities:** Comprehensive logging for compliance
- **Change Control:** Controlled profile modifications
- **Security Monitoring:** Continuous access monitoring

#### **Scalability Considerations:**
- **Modular Design:** Profiles can be easily modified
- **License Optimization:** Efficient use of Salesforce licenses
- **Growth Support:** Flexible profile structure for expansion
- **Integration Ready:** API access supports system growth

### Maintenance & Governance

#### **Documentation Standards:**
- **Business Function Descriptions:** Clear purpose for each profile
- **Access Matrix:** Comprehensive permission mapping
- **Change Management:** Controlled profile modifications
- **Training Materials:** User access documentation

#### **Operational Procedures:**
- **Regular Reviews:** Quarterly profile audits
- **Access Requests:** Standardized profile assignment process
- **Security Monitoring:** Continuous access monitoring
- **Compliance Reporting:** Regular access compliance reviews

### Profile Management Best Practices

#### **Custom Profile Guidelines:**
- **Naming Conventions:** Clear, descriptive profile names
- **Purpose Documentation:** Business function descriptions
- **Access Mapping:** Comprehensive permission documentation
- **Change Control:** Controlled modification processes

#### **Standard Profile Usage:**
- **Leverage Standard Profiles:** Use standard profiles where possible
- **Minimize Custom Profiles:** Reduce complexity and maintenance
- **Document Deviations:** Clear reasons for custom profiles
- **Regular Reviews:** Periodic assessment of profile usage

---


## 1. Profile Definition

**Standard Profiles:**
Standard profiles are the default profiles provided by Salesforce, such as System Administrator, Standard User, and Marketing User. These profiles come with a predefined set of permissions and access levels that cover common business needs. Standard profiles cannot be deleted or renamed, and their permissions are managed by Salesforce. Examples include:
- System Administrator: Full access to all functionality, including setup and configuration.
- Standard User: Basic access to standard Salesforce objects and features.
- Marketing User: Additional permissions for campaign management and marketing features.

**Custom Profiles:**
Custom profiles are created to address specific business requirements that are not met by standard profiles. These profiles allow organizations to tailor permissions and access to different user groups, roles, or departments. Each custom profile should have a clear purpose and be documented with the permissions it grants.

**Profile Naming Conventions:**
To ensure consistency and clarity, custom profiles should follow a standardized naming convention. For example:
- [BusinessUnit/Department] [Role/Function] Profile (e.g., "BSL Technician Profile", "Sales Manager Profile")
- Use clear, descriptive names that reflect the profile's intended user group or function.

---

## 2. Permissions and Access

**Object Permissions:**
Each profile specifies which Salesforce objects users can access and what actions they can perform (Create, Read, Edit, Delete, View All, Modify All).

**Field-Level Security:**
Profiles define which fields within each object are visible and editable for users, ensuring sensitive data is protected as needed.

**Record Type Access:**
Profiles control access to specific record types within objects, allowing for tailored business processes and data segmentation.

**Apex Class and Visualforce Page Access:**
Profiles can grant access to execute specific Apex classes and view or interact with Visualforce pages, supporting custom business logic and UI extensions.

**Administrative Permissions:**
Profiles may include administrative permissions, such as managing users, customizing the application, running reports, or accessing setup and configuration features.

---

## 3. Profile Assignment

**User Assignment:**
Profiles are assigned to users either manually (via the Salesforce UI) or programmatically (using automated processes, scripts, or data loading tools). Each user can have only one profile, which determines their baseline permissions.

**Role Hierarchy Integration:**
Profiles work in conjunction with the Salesforce role hierarchy. While profiles define what users can do (object/field access), the role hierarchy determines what records users can see, based on their position in the organizational structure. Together, profiles and roles provide a comprehensive security and access model.

---

This document provides a detailed summary of all custom Salesforce profiles in the org, including their intended purpose and the types of access they grant (applications, layouts, record types, etc.).

---

## Profile: BSL SMH
**Purpose:** Likely for a specific business unit or role (e.g., "SMH" team) within the BSL organization. Grants access to select Salesforce applications and layouts, including AMC, BSL_Service_Console, and Data Manager. Includes custom layout assignments for Account, Action Plan, and related objects.

**Key Access:**
- Applications: AMC, BSL_Service_Console, Data Manager, Approvals, Insights, SalesCloudMobile (visible)
- Layouts: Account (various record types), API_Log__c, ActionPlan, ActionPlanTemplate, and related layouts
- Record Types: Account.Channel_Partner, Account.Commercial_Customer, Account.Residential_Customer

---

## Profile: BSL AISH
**Purpose:** Custom profile for the "AISH" group or function within BSL. Similar access pattern to BSL SMH, with visibility to AMC, BSL_Service_Console, Data Manager, Approvals, Insights, and SalesCloudMobile. Custom layouts for Account, Action Plan, and related objects.

**Key Access:**
- Applications: AMC, BSL_Service_Console, Data Manager, Approvals, Insights, SalesCloudMobile (visible)
- Layouts: Account (various record types), API_Log__c, ActionPlan, ActionPlanTemplate, and related layouts
- Record Types: Account.Channel_Partner, Account.Commercial_Customer, Account.Residential_Customer

---

## Profile: Training Assessment Site Profile
**Purpose:** Custom profile for users accessing the Training Assessment Site. Grants minimal application access, with visibility to the Platform app. Custom layouts for Account and related objects.

**Key Access:**
- Applications: Platform (visible)
- Layouts: Account (various record types), API_Log__c, ActionPlan, ActionPlanTemplate, and related layouts
- Record Types: Account.Channel_Partner, Account.Commercial_Customer, Account.Residential_Customer

---

## Profile: BSL MCO
**Purpose:** Custom profile for the "MCO" group or function within BSL. Similar access to BSL SMH and BSL AISH, with visibility to BSL_Service_Console, Data Manager, Approvals, Insights, and SalesCloudMobile. Custom layouts for Account, Action Plan, and related objects.

**Key Access:**
- Applications: BSL_Service_Console, Data Manager, Approvals, Insights, SalesCloudMobile (visible)
- Layouts: Account (various record types), API_Log__c, ActionPlan, ActionPlanTemplate, and related layouts
- Record Types: Account.Channel_Partner, Account.Commercial_Customer, Account.Residential_Customer

---

## Profile: BSL SSG
**Purpose:** Custom profile for the "SSG" group or function within BSL. Grants access to BSL_Service_Console, Data Manager, Approvals, Insights, and SalesCloudMobile. Custom layouts for Account, Action Plan, and related objects.

**Key Access:**
- Applications: BSL_Service_Console, Data Manager, Approvals, Insights, SalesCloudMobile (visible)
- Layouts: Account (various record types), API_Log__c, ActionPlan, ActionPlanTemplate, and related layouts
- Record Types: Account.Channel_Partner, Account.Commercial_Customer, Account.Residential_Customer

---

*This summary will be expanded to include all custom profiles in the org. Each entry will be updated with more detail as needed, including object/field permissions and system permissions if required.* 

---

## Standard Profile: Admin
**Purpose:** System Administrator profile. Grants full access to all Salesforce features, setup, and configuration. Can manage users, data, and all settings.

**Key Access:**
- All applications, objects, and tabs
- Full CRUD (Create, Read, Update, Delete) on all standard and custom objects
- All administrative permissions (Manage Users, Customize Application, Modify All Data, etc.)
- Full access to Apex, Visualforce, and system features

---

## Standard Profile: Analytics Cloud Integration User
**Purpose:** Used for integration with Salesforce Analytics Cloud. Grants access to analytics features and API integration.

**Key Access:**
- Access to Analytics Cloud applications
- API and integration permissions
- Limited object and field access as required for analytics

---

## Standard Profile: Analytics Cloud Security User
**Purpose:** Used for security and access management in Analytics Cloud. Grants permissions for managing analytics security features.

**Key Access:**
- Access to Analytics Cloud security features
- Permissions for managing analytics data security

---

## Standard Profile: Anypoint Integration
**Purpose:** Used for MuleSoft Anypoint integration. Grants access to integration features and APIs.

**Key Access:**
- API and integration permissions
- Access to Anypoint integration features

---

## Standard Profile: Chatter External User
**Purpose:** For external users who access Chatter. Grants limited access to Chatter features only.

**Key Access:**
- Access to Chatter
- No access to standard Salesforce objects

---

## Standard Profile: Chatter Free User
**Purpose:** For internal users who only need access to Chatter. No access to Salesforce data or objects.

**Key Access:**
- Access to Chatter
- No access to Salesforce objects

---

## Standard Profile: Chatter Moderator User
**Purpose:** For users who moderate Chatter groups and content. Includes Chatter Free permissions plus moderation features.

**Key Access:**
- Access to Chatter
- Chatter moderation permissions

---

## Standard Profile: ContractManager
**Purpose:** For users who manage contracts. Grants access to contract management features.

**Key Access:**
- Access to Contracts and related objects
- Limited administrative permissions

---

## Standard Profile: Field Service Lightning Profile
**Purpose:** For users of Field Service Lightning. Grants access to field service features and objects.

**Key Access:**
- Access to Field Service Lightning applications and objects
- Permissions for managing service appointments, work orders, etc.

---

## Standard Profile: Guest License User
**Purpose:** For unauthenticated guest users accessing Salesforce sites or communities.

**Key Access:**
- Very limited access to public objects and pages
- No access to internal data

---

## Standard Profile: Identity User
**Purpose:** For users who need Salesforce Identity features (SSO, authentication, etc.).

**Key Access:**
- Access to identity and authentication features
- Limited access to Salesforce data

---

## Standard Profile: MarketingProfile
**Purpose:** For users who manage marketing campaigns and features.

**Key Access:**
- Access to Campaigns and marketing features
- Permissions for managing leads and campaigns

---

## Standard Profile: Minimum Access - API Only Integrations
**Purpose:** For API-only integration users. Grants only the minimum permissions required for API access.

**Key Access:**
- API access
- No UI access
- Minimal object permissions

---

## Standard Profile: Minimum Access - Salesforce
**Purpose:** For users who need the most restricted access. Grants only the minimum permissions required to log in.

**Key Access:**
- Login access
- No object or data access by default

---

## Standard Profile: Partner Community User
**Purpose:** For partner community users. Grants access to partner community features and objects.

**Key Access:**
- Access to partner community
- Permissions for managing partner data

---

## Standard Profile: Read Only
**Purpose:** For users who need read-only access to Salesforce data.

**Key Access:**
- Read-only access to most objects
- No create, edit, or delete permissions

---

## Standard Profile: Sales Insights Integration User
**Purpose:** For integration with Sales Insights features. Grants access to Sales Insights APIs and data.

**Key Access:**
- Access to Sales Insights features
- API and integration permissions

---

## Standard Profile: Salesforce API Only System Integrations
**Purpose:** For system integrations using Salesforce APIs. Grants only the permissions required for API access.

**Key Access:**
- API access
- No UI access
- Minimal object permissions

---

## Standard Profile: SAP Integration Profile
**Purpose:** For integration with SAP systems. Grants access to integration features and APIs.

**Key Access:**
- API and integration permissions
- Access to SAP integration features

---

## Standard Profile: SolutionManager
**Purpose:** For users who manage solutions in Salesforce. Grants access to solution management features.

**Key Access:**
- Access to Solutions and related objects
- Permissions for managing solution data

---

## Standard Profile: Standard
**Purpose:** The default profile for most users. Grants access to standard Salesforce features and objects.

**Key Access:**
- Access to standard objects (Accounts, Contacts, Opportunities, etc.)
- Basic permissions for most Salesforce features

---

## Standard Profile: Training Assessment Site Profile
**Purpose:** For users accessing the Training Assessment Site. Grants access to training and assessment features.

**Key Access:**
- Access to training and assessment objects
- Permissions for managing training data

---

## Standard Profile: Website Integration User
**Purpose:** For users or integrations accessing Salesforce via a website. Grants access to integration features and APIs.

**Key Access:**
- API and integration permissions
- Access to website integration features

--- 

---

## CAD Sales AM_2FRM.profile.xml
- **License:** Salesforce
- **App Access:**
  - Visible: BSL_Service_Console (default), standard__SalesCloudMobile (visible)
  - Not Visible: AMC, BSL_Service, BlueStar_Training, BlueStar_Trainings, Sales, Technician_Onboarding, and most standard apps
- **Object Access (Tab Visibility):**
  - DefaultOn: Audit_Inventory__c, BS360__c, Daily_Job_Documents__c, Smart_AC_Model__c, sbaa__Approval__c
  - DefaultOff: Attendance__c
  - Hidden: Most other custom and standard objects (see XML for full list)
- **Record Type Access:**
  - Account: Commercial_Customer (default, visible), Residential_Customer (visible), Channel_Partner (not visible)
  - Asset: Asset (default, visible), Component (visible), Sub_Component (visible), StandBy_Asset (not visible)
  - Case: Salesforce_System_Support (default, visible), others not visible
  - Contact: Business_Contact (default, visible), Family_Contact (visible), TechnicianContact (not visible)
  - ProductRequest: Contract_Line_Item (default, visible), Quote_Line_Item_CPQ (visible), Quote_Line_Item_Sales (visible)
  - Others: See XML for full mapping
- **LWC, Visualforce, Apex Access:** Not specified
- **User Permissions:**
  - ActivitiesAccess, AllowUniversalSearch, AllowViewKnowledge, AssignTopics, CanAccessCE, ChatterEditOwnPost, ChatterFileLink, ChatterInternalUser, ChatterInviteExternalUsers, ChatterOwnGroups, ContentWorkspaces, CreateCustomizeFilters, CreateTopics, EditOppLineItemUnitPrice, EditTopics, EnableNotifications, ExportReport, FieldServiceAccess, LightningConsoleAllowedForUser, LightningExperienceUser, RunReports, SelectFilesFromSalesforce, SendSitRequests, ShareFilesWithNetworks, ShowCompanyNameAsUserBadge, SubmitMacrosAllowed, SubscribeToLightningReports, ViewHelpLink, ViewRoles

## CCA Integration User.profile.xml
- **License:** Salesforce Integration
- **App Access:**
  - Visible: standard__Approvals, standard__DataManager, standard__ExpressionSetConsole, standard__FlowsApp, standard__Insights, standard__Optimizer, standard__SalesCloudMobile
  - Not Visible: Most other apps
- **Object Access (Tab Visibility):**
  - DefaultOn: Audit_Inventory__c, BS360__c, Daily_Job_Documents__c, Order_Management1, Smart_AC_Model__c, sbaa__Approval__c
  - DefaultOff: Attendance__c
  - Hidden: Most other objects
- **Record Type Access:**
  - Account: Channel_Partner (visible), Commercial_Customer (default, visible), Residential_Customer (visible)
  - ProductRequest: Contract_Line_Item (default, visible), Quote_Line_Item_CPQ (visible), Quote_Line_Item_Sales (visible)
  - Others: See XML for full mapping
- **LWC, Visualforce, Apex Access:** Not specified
- **User Permissions:**
  - ApiEnabled, ApiUserOnly, ChatterInternalUser

## Channel Partner Portal Profile.profile.xml
- **License:** Guest User License
- **App Access:**
  - Visible: standard__Platform (default, visible)
  - Not Visible: Most other apps
- **Object Access (Tab Visibility):**
  - Hidden: Most objects, except Knowledge__kav (DefaultOn)
- **Record Type Access:**
  - Most record types not visible
- **LWC, Visualforce, Apex Access:** Not specified
- **User Permissions:**
  - ActivitiesAccess, AddDirectMessageMembers, AllowUniversalSearch, ContentWorkspaces, EnableNotifications, GiveRecognitionBadge, PasswordNeverExpires, SelectFilesFromSalesforce, ShowCompanyNameAsUserBadge, UseWebLink

## Channel Partner User - BA.profile.xml
- **License:** Partner Community
- **App Access:**
  - Visible: BSL_Service (default, visible), standard__Approvals, standard__DataManager, standard__Insights, standard__SalesCloudMobile
  - Not Visible: Most other apps
- **Object Access (Tab Visibility):**
  - DefaultOn: API_Log__c, Announcement_Messages__c, Assessment_Questions__c, Attendance__c, Audit_Inventory__c, BOM__c, BS360__c, Branch__c, Bulk_Product_Registration, Bulk_Product_Transfer_Creation, Bulk_Ticket_Creation, CSV_File_Uploader, Daily_Job_Documents__c, Department__c, Division__c, Invoice__c, Knowledge__kav, Local_Purchase__c, Minimum_Wage_Rate__c, Opportunity_Error_Log__c, PMS_Event__c, Payment_Log__c, Sale_Order__c, Smart_AC_Model__c, Survey__c, Transaction_Note__c, Wage_Matrix__c, Warranty_Conditions__c, sbaa__Approval__c
  - DefaultOff: Breakdown_Attribute__c, City_Tier__c, Create_Sale_Order, Create_Stock_Defect_Case, MobileLanding, Order_Management1, Payment__c, PinCode__c, Price_Master__c, Rate_Card__c, Record_Transfer, Sales_Order_Defective_Challan, SMS_Log__c, SMS_Template__c, Warranty_Obligation__c, Whatsapp_Log__c
  - Hidden: Most other objects
- **Record Type Access:**
  - Account: Channel_Partner, Commercial_Customer, Residential_Customer (all visible)
  - Asset: Asset, Component, Sub_Component, StandBy_Asset (all visible)
  - Case: Customer_Request, Internal_Request, Salesforce_System_Support, Stock_Defective (all visible)
  - Contact: Business_Contact, Family_Contact, TechnicianContact (all visible)
  - ProductRequest: Material_Request, Minimum_Stock_Level, Sale_Order (all visible)
  - Product_Family__c: Product_Family, Product_Sub_Family (all visible)
  - Quote: AMC, Revamp (all visible)
  - ReturnOrder: FGR, RMR (all visible)
  - ServiceContract: AMC (visible)
  - Transaction_Note__c: Credit_Note, Debit_Note (all visible)
  - Update_Request__c: Commercial_Account_Update, Commercial_Update, Contact_Account_Update, Contact_Update (all visible)
  - WarrantyTerm: Promotional_Warranty, Standard (all visible)
  - WorkOrder: Breakdown, Bulk_PMS_Checklist, Commissioning, Commissioning_Screw_Chiller, Commissioning_Scroll_Chiller, Commissioning_VRF, Demo, Installation, PDI, PMS, Regular_Service, Stock_Defective (all visible)
  - WorkOrderLineItem: Master (visible)
  - Others: See XML for full mapping
- **LWC, Visualforce, Apex Access:** Not specified
- **User Permissions:**
  - ConvertLeads, CreateCustomizeFilters, DistributeFromPersWksp, EditTask, EmailMass, EmailSingle, EnableNotifications, ExportReport, ListEmailSend, PipelineInspectorUser, RunFlow, RunReports, SelectFilesFromSalesforce, SendCustomNotifications, ShareFilesWithNetworks, TransactionalEmailSend, ViewContent

## Channel Partner User - esa.profile.xml
- **License:** Partner Community
- **App Access:**
  - Visible: BSL_Service (default, visible), standard__Approvals, standard__DataManager, standard__Insights, standard__SalesCloudMobile
  - Not Visible: Most other apps
- **Object Access (Tab Visibility):**
  - DefaultOn: API_Log__c, Announcement_Messages__c, Assessment_Questions__c, Attendance__c, Audit_Inventory__c, BOM__c, BS360__c, Branch__c, Bulk_Product_Registration, Bulk_Product_Transfer_Creation, Bulk_Ticket_Creation, CSV_File_Uploader, Daily_Job_Documents__c, Department__c, Division__c, Invoice__c, Knowledge__kav, Local_Purchase__c, Minimum_Wage_Rate__c, Opportunity_Error_Log__c, PMS_Event__c, Payment_Log__c, Sale_Order__c, Smart_AC_Model__c, Survey__c, Transaction_Note__c, Wage_Matrix__c, Warranty_Conditions__c, sbaa__Approval__c
  - DefaultOff: Breakdown_Attribute__c, City_Tier__c, Create_Sale_Order, Create_Stock_Defect_Case, MobileLanding, Order_Management1, Payment__c, PinCode__c, Price_Master__c, Rate_Card__c, Record_Transfer, Sales_Order_Defective_Challan, SMS_Log__c, SMS_Template__c, Warranty_Obligation__c, Whatsapp_Log__c
  - Hidden: Most other objects
- **Record Type Access:**
  - Account: Channel_Partner, Commercial_Customer, Residential_Customer (all visible)
  - Asset: Asset, Component, Sub_Component, StandBy_Asset (all visible)
  - Case: Customer_Request, Internal_Request, Salesforce_System_Support, Stock_Defective (all visible)
  - Contact: Business_Contact, Family_Contact, TechnicianContact (all visible)
  - ProductRequest: Material_Request, Minimum_Stock_Level, Sale_Order (all visible)
  - Product_Family__c: Product_Family, Product_Sub_Family (all visible)
  - Quote: AMC, Revamp (all visible)
  - ReturnOrder: FGR, RMR (all visible)
  - ServiceContract: AMC (visible)
  - Transaction_Note__c: Credit_Note, Debit_Note (all visible)
  - Update_Request__c: Commercial_Account_Update, Commercial_Update, Contact_Account_Update, Contact_Update (all visible)
  - WarrantyTerm: Promotional_Warranty, Standard (all visible)
  - WorkOrder: Breakdown, Bulk_PMS_Checklist, Commissioning, Commissioning_Screw_Chiller, Commissioning_Scroll_Chiller, Commissioning_VRF, Demo, Installation, PDI, PMS, Regular_Service, Stock_Defective (all visible)
  - WorkOrderLineItem: Master (visible)
  - Others: See XML for full mapping
- **LWC, Visualforce, Apex Access:** Not specified
- **User Permissions:**
  - ConvertLeads, CreateCustomizeFilters, DistributeFromPersWksp, EditTask, EmailMass, EmailSingle, EnableNotifications, ExportReport, ListEmailSend, PipelineInspectorUser, RunFlow, RunReports, SelectFilesFromSalesforce, SendCustomNotifications, ShareFilesWithNetworks, TransactionalEmailSend, ViewContent

## Channel Partner User - freelancer.profile.xml
- **License:** Partner Community
- **App Access:**
  - Visible: BSL_Service (default, visible), standard__Approvals, standard__DataManager, standard__Insights, standard__SalesCloudMobile
  - Not Visible: Most other apps
- **Object Access (Tab Visibility):**
  - DefaultOn: API_Log__c, Announcement_Messages__c, Assessment_Questions__c, Attendance__c, Audit_Inventory__c, BOM__c, BS360__c, Branch__c, Bulk_Product_Registration, Bulk_Product_Transfer_Creation, Bulk_Ticket_Creation, CSV_File_Uploader, Daily_Job_Documents__c, Department__c, Division__c, Invoice__c, Knowledge__kav, Local_Purchase__c, Minimum_Wage_Rate__c, Opportunity_Error_Log__c, PMS_Event__c, Payment_Log__c, Sale_Order__c, Smart_AC_Model__c, Survey__c, Transaction_Note__c, Wage_Matrix__c, Warranty_Conditions__c, sbaa__Approval__c
  - DefaultOff: Breakdown_Attribute__c, City_Tier__c, Create_Sale_Order, Create_Stock_Defect_Case, MobileLanding, Order_Management1, Payment__c, PinCode__c, Price_Master__c, Rate_Card__c, Record_Transfer, Sales_Order_Defective_Challan, SMS_Log__c, SMS_Template__c, Warranty_Obligation__c, Whatsapp_Log__c
  - Hidden: Most other objects
- **Record Type Access:**
  - Account: Channel_Partner, Commercial_Customer, Residential_Customer (all visible)
  - Asset: Asset, Component, Sub_Component, StandBy_Asset (all visible)
  - Case: Customer_Request, Internal_Request, Salesforce_System_Support, Stock_Defective (all visible)
  - Contact: Business_Contact, Family_Contact, TechnicianContact (all visible)
  - ProductRequest: Material_Request, Minimum_Stock_Level, Sale_Order (all visible)
  - Product_Family__c: Product_Family, Product_Sub_Family (all visible)
  - Quote: AMC, Revamp (all visible)
  - ReturnOrder: FGR, RMR (all visible)
  - ServiceContract: AMC (visible)
  - Transaction_Note__c: Credit_Note, Debit_Note (all visible)
  - Update_Request__c: Commercial_Account_Update, Commercial_Update, Contact_Account_Update, Contact_Update (all visible)
  - WarrantyTerm: Promotional_Warranty, Standard (all visible)
  - WorkOrder: Breakdown, Bulk_PMS_Checklist, Commissioning, Commissioning_Screw_Chiller, Commissioning_Scroll_Chiller, Commissioning_VRF, Demo, Installation, PDI, PMS, Regular_Service, Stock_Defective (all visible)
  - WorkOrderLineItem: Master (visible)
  - Others: See XML for full mapping
- **LWC, Visualforce, Apex Access:** Not specified
- **User Permissions:**
  - ConvertLeads, CreateCustomizeFilters, DistributeFromPersWksp, EditTask, EmailMass, EmailSingle, EnableNotifications, ExportReport, ListEmailSend, PipelineInspectorUser, RunFlow, RunReports, SelectFilesFromSalesforce, SendCustomNotifications, ShareFilesWithNetworks, TransactionalEmailSend, ViewContent

## Channel Partner User - ssd.profile.xml
- **License:** Partner Community
- **App Access:**
  - Visible: BSL_Service (default, visible), standard__Approvals, standard__DataManager, standard__Insights, standard__SalesCloudMobile
  - Not Visible: Most other apps
- **Object Access (Tab Visibility):**
  - DefaultOn: API_Log__c, Announcement_Messages__c, Assessment_Questions__c, Attendance__c, Audit_Inventory__c, BOM__c, BS360__c, Branch__c, Bulk_Product_Registration, Bulk_Product_Transfer_Creation, Bulk_Ticket_Creation, CSV_File_Uploader, Daily_Job_Documents__c, Department__c, Division__c, Invoice__c, Knowledge__kav, Local_Purchase__c, Minimum_Wage_Rate__c, Opportunity_Error_Log__c, PMS_Event__c, Payment_Log__c, Sale_Order__c, Smart_AC_Model__c, Survey__c, Transaction_Note__c, Wage_Matrix__c, Warranty_Conditions__c, sbaa__Approval__c
  - DefaultOff: Breakdown_Attribute__c, City_Tier__c, Create_Sale_Order, Create_Stock_Defect_Case, MobileLanding, Order_Management1, Payment__c, PinCode__c, Price_Master__c, Rate_Card__c, Record_Transfer, Sales_Order_Defective_Challan, SMS_Log__c, SMS_Template__c, Warranty_Obligation__c, Whatsapp_Log__c
  - Hidden: Most other objects
- **Record Type Access:**
  - Account: Channel_Partner, Commercial_Customer, Residential_Customer (all visible)
  - Asset: Asset, Component, Sub_Component, StandBy_Asset (all visible)
  - Case: Customer_Request, Internal_Request, Salesforce_System_Support, Stock_Defective (all visible)
  - Contact: Business_Contact, Family_Contact, TechnicianContact (all visible)
  - ProductRequest: Material_Request, Minimum_Stock_Level, Sale_Order (all visible)
  - Product_Family__c: Product_Family, Product_Sub_Family (all visible)
  - Quote: AMC, Revamp (all visible)
  - ReturnOrder: FGR, RMR (all visible)
  - ServiceContract: AMC (visible)
  - Transaction_Note__c: Credit_Note, Debit_Note (all visible)
  - Update_Request__c: Commercial_Account_Update, Commercial_Update, Contact_Account_Update, Contact_Update (all visible)
  - WarrantyTerm: Promotional_Warranty, Standard (all visible)
  - WorkOrder: Breakdown, Bulk_PMS_Checklist, Commissioning, Commissioning_Screw_Chiller, Commissioning_Scroll_Chiller, Commissioning_VRF, Demo, Installation, PDI, PMS, Regular_Service, Stock_Defective (all visible)
  - WorkOrderLineItem: Master (visible)
  - Others: See XML for full mapping
- **LWC, Visualforce, Apex Access:** Not specified
- **User Permissions:**
  - ConvertLeads, CreateCustomizeFilters, DistributeFromPersWksp, EditTask, EmailMass, EmailSingle, EnableNotifications, ExportReport, ListEmailSend, PipelineInspectorUser, RunFlow, RunReports, SelectFilesFromSalesforce, SendCustomNotifications, ShareFilesWithNetworks, TransactionalEmailSend, ViewContent

## Channel Partner User.profile.xml
- **License:** Partner Community
- **App Access:**
  - Visible: BSL_Service (default, visible), standard__Approvals, standard__DataManager, standard__Insights, standard__SalesCloudMobile
  - Not Visible: Most other apps
- **Object Access (Tab Visibility):**
  - DefaultOn: API_Log__c, Announcement_Messages__c, Assessment_Questions__c, Attendance__c, Audit_Inventory__c, BOM__c, BS360__c, Branch__c, Bulk_Product_Registration, Bulk_Product_Transfer_Creation, Bulk_Ticket_Creation, CSV_File_Uploader, Daily_Job_Documents__c, Department__c, Division__c, Invoice__c, Knowledge__kav, Local_Purchase__c, Minimum_Wage_Rate__c, Opportunity_Error_Log__c, PMS_Event__c, Payment_Log__c, Sale_Order__c, Smart_AC_Model__c, Survey__c, Transaction_Note__c, Wage_Matrix__c, Warranty_Conditions__c, sbaa__Approval__c
  - DefaultOff: Breakdown_Attribute__c, City_Tier__c, Create_Sale_Order, Create_Stock_Defect_Case, MobileLanding, Order_Management1, Payment__c, PinCode__c, Price_Master__c, Rate_Card__c, Record_Transfer, Sales_Order_Defective_Challan, SMS_Log__c, SMS_Template__c, Warranty_Obligation__c, Whatsapp_Log__c
  - Hidden: Most other objects
- **Record Type Access:**
  - Account: Channel_Partner, Commercial_Customer, Residential_Customer (all visible)
  - Asset: Asset, Component, Sub_Component, StandBy_Asset (all visible)
  - Case: Customer_Request, Internal_Request, Salesforce_System_Support, Stock_Defective (all visible)
  - Contact: Business_Contact, Family_Contact, TechnicianContact (all visible)
  - ProductRequest: Material_Request, Minimum_Stock_Level, Sale_Order (all visible)
  - Product_Family__c: Product_Family, Product_Sub_Family (all visible)
  - Quote: AMC, Revamp (all visible)
  - ReturnOrder: FGR, RMR (all visible)
  - ServiceContract: AMC (visible)
  - Transaction_Note__c: Credit_Note, Debit_Note (all visible)
  - Update_Request__c: Commercial_Account_Update, Commercial_Update, Contact_Account_Update, Contact_Update (all visible)
  - WarrantyTerm: Promotional_Warranty, Standard (all visible)
  - WorkOrder: Breakdown, Bulk_PMS_Checklist, Commissioning, Commissioning_Screw_Chiller, Commissioning_Scroll_Chiller, Commissioning_VRF, Demo, Installation, PDI, PMS, Regular_Service, Stock_Defective (all visible)
  - WorkOrderLineItem: Master (visible)
  - Others: See XML for full mapping
- **LWC, Visualforce, Apex Access:** Not specified
- **User Permissions:**
  - ConvertLeads, CreateCustomizeFilters, DistributeFromPersWksp, EditTask, EmailMass, EmailSingle, EnableNotifications, ExportReport, ListEmailSend, PipelineInspectorUser, RunFlow, RunReports, SelectFilesFromSalesforce, SendCustomNotifications, ShareFilesWithNetworks, TransactionalEmailSend, ViewContent

## Chatter External User.profile.xml
- **License:** Chatter External User License
- **App Access:**
  - Visible: standard__Chatter (default, visible)
  - Not Visible: Most other apps
- **Object Access (Tab Visibility):**
  - Hidden: Most objects, except Knowledge__kav (DefaultOn)
- **Record Type Access:**
  - Most record types not visible
- **LWC, Visualforce, Apex Access:** Not specified
- **User Permissions:**
  - ActivitiesAccess, AddDirectMessageMembers, AllowUniversalSearch, ContentWorkspaces, EnableNotifications, GiveRecognitionBadge, PasswordNeverExpires, SelectFilesFromSalesforce, ShowCompanyNameAsUserBadge, UseWebLink

## Chatter Free User.profile.xml
- **License:** Chatter Free User License
- **App Access:**
  - Visible: standard__Chatter (default, visible)
  - Not Visible: Most other apps
- **Object Access (Tab Visibility):**
  - Hidden: Most objects, except Knowledge__kav (DefaultOn)
- **Record Type Access:**
  - Most record types not visible
- **LWC, Visualforce, Apex Access:** Not specified
- **User Permissions:**
  - ActivitiesAccess, AddDirectMessageMembers, AllowUniversalSearch, ContentWorkspaces, EnableNotifications, GiveRecognitionBadge, PasswordNeverExpires, SelectFilesFromSalesforce, ShowCompanyNameAsUserBadge, UseWebLink

## Chatter Moderator User.profile.xml
- **License:** Chatter Moderator License
- **App Access:**
  - Visible: standard__Chatter (default, visible)
  - Not Visible: Most other apps
- **Object Access (Tab Visibility):**
  - Hidden: Most objects, except Knowledge__kav (DefaultOn)
- **Record Type Access:**
  - Most record types not visible
- **LWC, Visualforce, Apex Access:** Not specified
- **User Permissions:**
  - ActivitiesAccess, AddDirectMessageMembers, AllowUniversalSearch, ContentWorkspaces, EnableNotifications, GiveRecognitionBadge, PasswordNeverExpires, SelectFilesFromSalesforce, ShowCompanyNameAsUserBadge, UseWebLink

## ContractManager.profile.xml
- **License:** ContractManager License
- **App Access:**
  - Visible: standard__Approvals, standard__DataManager, standard__Insights, standard__SalesCloudMobile
  - Not Visible: Most other apps
- **Object Access (Tab Visibility):**
  - DefaultOn: Audit_Inventory__c, BS360__c, Daily_Job_Documents__c, Order_Management1, Smart_AC_Model__c, sbaa__Approval__c
  - DefaultOff: Attendance__c
  - Hidden: Most other objects
- **Record Type Access:**
  - Account: Channel_Partner (visible), Commercial_Customer (default, visible), Residential_Customer (visible)
  - ProductRequest: Contract_Line_Item (default, visible), Quote_Line_Item_CPQ (visible), Quote_Line_Item_Sales (visible)
  - Others: See XML for full mapping
- **LWC, Visualforce, Apex Access:** Not specified
- **User Permissions:**
  - ApiEnabled, ApiUserOnly, ChatterInternalUser

## CPQ Integration User.profile.xml
- **License:** Salesforce Integration
- **App Access:**
  - Visible: standard__Approvals, standard__DataManager, standard__ExpressionSetConsole, standard__FlowsApp, standard__Insights, standard__Optimizer, standard__SalesCloudMobile
  - Not Visible: Most other apps
- **Object Access (Tab Visibility):**
  - DefaultOn: Audit_Inventory__c, BS360__c, Daily_Job_Documents__c, Order_Management1, Smart_AC_Model__c, sbaa__Approval__c
  - DefaultOff: Attendance__c
  - Hidden: Most other objects
- **Record Type Access:**
  - Account: Channel_Partner (visible), Commercial_Customer (default, visible), Residential_Customer (visible)
  - ProductRequest: Contract_Line_Item (default, visible), Quote_Line_Item_CPQ (visible), Quote_Line_Item_Sales (visible)
  - Others: See XML for full mapping
- **LWC, Visualforce, Apex Access:** Not specified
- **User Permissions:**
  - ApiEnabled, ApiUserOnly, ChatterInternalUser

## Data Migration Profile.profile.xml
- **License:** Salesforce Integration
- **App Access:**
  - Visible: standard__Approvals, standard__DataManager, standard__ExpressionSetConsole, standard__FlowsApp, standard__Insights, standard__Optimizer, standard__SalesCloudMobile
  - Not Visible: Most other apps
- **Object Access (Tab Visibility):**
  - DefaultOn: Audit_Inventory__c, BS360__c, Daily_Job_Documents__c, Order_Management1, Smart_AC_Model__c, sbaa__Approval__c
  - DefaultOff: Attendance__c
  - Hidden: Most other objects
- **Record Type Access:**
  - Account: Channel_Partner (visible), Commercial_Customer (default, visible), Residential_Customer (visible)
  - ProductRequest: Contract_Line_Item (default, visible), Quote_Line_Item_CPQ (visible), Quote_Line_Item_Sales (visible)
  - Others: See XML for full mapping
- **LWC, Visualforce, Apex Access:** Not specified
- **User Permissions:**
  - ApiEnabled, ApiUserOnly, ChatterInternalUser

## Field Service Lightning Profile.profile.xml
- **License:** Field Service Lightning Profile License
- **App Access:**
  - Visible: standard__Approvals, standard__DataManager, standard__ExpressionSetConsole, standard__FlowsApp, standard__Insights, standard__Optimizer, standard__SalesCloudMobile
  - Not Visible: Most other apps
- **Object Access (Tab Visibility):**
  - DefaultOn: Audit_Inventory__c, BS360__c, Daily_Job_Documents__c, Order_Management1, Smart_AC_Model__c, sbaa__Approval__c
  - DefaultOff: Attendance__c
  - Hidden: Most other objects
- **Record Type Access:**
  - Account: Channel_Partner (visible), Commercial_Customer (default, visible), Residential_Customer (visible)
  - ProductRequest: Contract_Line_Item (default, visible), Quote_Line_Item_CPQ (visible), Quote_Line_Item_Sales (visible)
  - Others: See XML for full mapping
- **LWC, Visualforce, Apex Access:** Not specified
- **User Permissions:**
  - ApiEnabled, ApiUserOnly, ChatterInternalUser

## Generic Integration Profile.profile.xml
- **License:** Salesforce Integration
- **App Access:**
  - Visible: standard__Approvals, standard__DataManager, standard__ExpressionSetConsole, standard__FlowsApp, standard__Insights, standard__Optimizer, standard__SalesCloudMobile
  - Not Visible: Most other apps
- **Object Access (Tab Visibility):**
  - DefaultOn: Audit_Inventory__c, BS360__c, Daily_Job_Documents__c, Order_Management1, Smart_AC_Model__c, sbaa__Approval__c
  - DefaultOff: Attendance__c
  - Hidden: Most other objects
- **Record Type Access:**
  - Account: Channel_Partner (visible), Commercial_Customer (default, visible), Residential_Customer (visible)
  - ProductRequest: Contract_Line_Item (default, visible), Quote_Line_Item_CPQ (visible), Quote_Line_Item_Sales (visible)
  - Others: See XML for full mapping
- **LWC, Visualforce, Apex Access:** Not specified
- **User Permissions:**
  - ApiEnabled, ApiUserOnly, ChatterInternalUser

## Genesys Integration Profile.profile.xml
- **License:** Salesforce Integration
- **App Access:**
  - Visible: standard__Approvals, standard__DataManager, standard__ExpressionSetConsole, standard__FlowsApp, standard__Insights, standard__Optimizer, standard__SalesCloudMobile
  - Not Visible: Most other apps
- **Object Access (Tab Visibility):**
  - DefaultOn: Audit_Inventory__c, BS360__c, Daily_Job_Documents__c, Order_Management1, Smart_AC_Model__c, sbaa__Approval__c
  - DefaultOff: Attendance__c
  - Hidden: Most other objects
- **Record Type Access:**
  - Account: Channel_Partner (visible), Commercial_Customer (default, visible), Residential_Customer (visible)
  - ProductRequest: Contract_Line_Item (default, visible), Quote_Line_Item_CPQ (visible), Quote_Line_Item_Sales (visible)
  - Others: See XML for full mapping
- **LWC, Visualforce, Apex Access:** Not specified
- **User Permissions:**
  - ApiEnabled, ApiUserOnly, ChatterInternalUser

## Guest License User.profile.xml
- **License:** Guest License
- **App Access:**
  - Visible: standard__Platform (default, visible)
  - Not Visible: Most other apps
- **Object Access (Tab Visibility):**
  - Hidden: Most objects, except Knowledge__kav (DefaultOn)
- **Record Type Access:**
  - Most record types not visible
- **LWC, Visualforce, Apex Access:** Not specified
- **User Permissions:**
  - ActivitiesAccess, AddDirectMessageMembers, AllowUniversalSearch, ContentWorkspaces, EnableNotifications, GiveRecognitionBadge, PasswordNeverExpires, SelectFilesFromSalesforce, ShowCompanyNameAsUserBadge, UseWebLink

## Identity User.profile.xml
- **License:** Salesforce Identity
- **App Access:**
  - Visible: standard__Approvals, standard__DataManager, standard__ExpressionSetConsole, standard__FlowsApp, standard__Insights, standard__Optimizer, standard__SalesCloudMobile
  - Not Visible: Most other apps
- **Object Access (Tab Visibility):**
  - DefaultOn: Audit_Inventory__c, BS360__c, Daily_Job_Documents__c, Order_Management1, Smart_AC_Model__c, sbaa__Approval__c
  - DefaultOff: Attendance__c
  - Hidden: Most other objects
- **Record Type Access:**
  - Account: Channel_Partner (visible), Commercial_Customer (default, visible), Residential_Customer (visible)
  - ProductRequest: Contract_Line_Item (default, visible), Quote_Line_Item_CPQ (visible), Quote_Line_Item_Sales (visible)
  - Others: See XML for full mapping
- **LWC, Visualforce, Apex Access:** Not specified
- **User Permissions:**
  - ApiEnabled, ApiUserOnly, ChatterInternalUser

## MarketingProfile.profile.xml
- **License:** Salesforce
- **App Access:**
  - Visible: standard__Approvals, standard__DataManager, standard__ExpressionSetConsole, standard__FlowsApp, standard__Insights, standard__Optimizer, standard__SalesCloudMobile
  - Not Visible: Most other apps
- **Object Access (Tab Visibility):**
  - DefaultOn: Audit_Inventory__c, BS360__c, Daily_Job_Documents__c, Order_Management1, Smart_AC_Model__c, sbaa__Approval__c
  - DefaultOff: Attendance__c
  - Hidden: Most other objects
- **Record Type Access:**
  - Account: Channel_Partner (visible), Commercial_Customer (default, visible), Residential_Customer (visible)
  - ProductRequest: Contract_Line_Item (default, visible), Quote_Line_Item_CPQ (visible), Quote_Line_Item_Sales (visible)
  - Others: See XML for full mapping
- **LWC, Visualforce, Apex Access:** Not specified
- **User Permissions:**
  - ApiEnabled, ApiUserOnly, ChatterInternalUser

## Minimum Access - API Only Integrations.profile.xml
- **License:** Salesforce Integration
- **App Access:**
  - Visible: standard__Approvals, standard__DataManager, standard__ExpressionSetConsole, standard__FlowsApp, standard__Insights, standard__Optimizer, standard__SalesCloudMobile
  - Not Visible: Most other apps
- **Object Access (Tab Visibility):**
  - DefaultOn: Audit_Inventory__c, BS360__c, Daily_Job_Documents__c, Order_Management1, Smart_AC_Model__c, sbaa__Approval__c
  - DefaultOff: Attendance__c
  - Hidden: Most other objects
- **Record Type Access:**
  - Account: Channel_Partner (visible), Commercial_Customer (default, visible), Residential_Customer (visible)
  - ProductRequest: Contract_Line_Item (default, visible), Quote_Line_Item_CPQ (visible), Quote_Line_Item_Sales (visible)
  - Others: See XML for full mapping
- **LWC, Visualforce, Apex Access:** Not specified
- **User Permissions:**
  - ApiEnabled, ApiUserOnly, ChatterInternalUser

## Minimum Access - Salesforce.profile.xml
- **License:** Salesforce
- **App Access:**
  - Visible: standard__Approvals, standard__DataManager, standard__ExpressionSetConsole, standard__FlowsApp, standard__Insights, standard__Optimizer, standard__SalesCloudMobile
  - Not Visible: Most other apps
- **Object Access (Tab Visibility):**
  - DefaultOn: Audit_Inventory__c, BS360__c, Daily_Job_Documents__c, Order_Management1, Smart_AC_Model__c, sbaa__Approval__c
  - DefaultOff: Attendance__c
  - Hidden: Most other objects
- **Record Type Access:**
  - Account: Channel_Partner (visible), Commercial_Customer (default, visible), Residential_Customer (visible)
  - ProductRequest: Contract_Line_Item (default, visible), Quote_Line_Item_CPQ (visible), Quote_Line_Item_Sales (visible)
  - Others: See XML for full mapping
- **LWC, Visualforce, Apex Access:** Not specified
- **User Permissions:**
  - ApiEnabled, ApiUserOnly, ChatterInternalUser

## Partner Community User.profile.xml
- **License:** Partner Community
- **App Access:**
  - Visible: BSL_Service (default, visible), standard__Approvals, standard__DataManager, standard__Insights, standard__SalesCloudMobile
  - Not Visible: Most other apps
- **Object Access (Tab Visibility):**
  - DefaultOn: API_Log__c, Announcement_Messages__c, Assessment_Questions__c, Attendance__c, Audit_Inventory__c, BOM__c, BS360__c, Branch__c, Bulk_Product_Registration, Bulk_Product_Transfer_Creation, Bulk_Ticket_Creation, CSV_File_Uploader, Daily_Job_Documents__c, Department__c, Division__c, Invoice__c, Knowledge__kav, Local_Purchase__c, Minimum_Wage_Rate__c, Opportunity_Error_Log__c, PMS_Event__c, Payment_Log__c, Sale_Order__c, Smart_AC_Model__c, Survey__c, Transaction_Note__c, Wage_Matrix__c, Warranty_Conditions__c, sbaa__Approval__c
  - DefaultOff: Breakdown_Attribute__c, City_Tier__c, Create_Sale_Order, Create_Stock_Defect_Case, MobileLanding, Order_Management1, Payment__c, PinCode__c, Price_Master__c, Rate_Card__c, Record_Transfer, Sales_Order_Defective_Challan, SMS_Log__c, SMS_Template__c, Warranty_Obligation__c, Whatsapp_Log__c
  - Hidden: Most other objects
- **Record Type Access:**
  - Account: Channel_Partner, Commercial_Customer, Residential_Customer (all visible)
  - Asset: Asset, Component, Sub_Component, StandBy_Asset (all visible)
  - Case: Customer_Request, Internal_Request, Salesforce_System_Support, Stock_Defective (all visible)
  - Contact: Business_Contact, Family_Contact, TechnicianContact (all visible)
  - ProductRequest: Material_Request, Minimum_Stock_Level, Sale_Order (all visible)
  - Product_Family__c: Product_Family, Product_Sub_Family (all visible)
  - Quote: AMC, Revamp (all visible)
  - ReturnOrder: FGR, RMR (all visible)
  - ServiceContract: AMC (visible)
  - Transaction_Note__c: Credit_Note, Debit_Note (all visible)
  - Update_Request__c: Commercial_Account_Update, Commercial_Update, Contact_Account_Update, Contact_Update (all visible)
  - WarrantyTerm: Promotional_Warranty, Standard (all visible)
  - WorkOrder: Breakdown, Bulk_PMS_Checklist, Commissioning, Commissioning_Screw_Chiller, Commissioning_Scroll_Chiller, Commissioning_VRF, Demo, Installation, PDI, PMS, Regular_Service, Stock_Defective (all visible)
  - WorkOrderLineItem: Master (visible)
  - Others: See XML for full mapping
- **LWC, Visualforce, Apex Access:** Not specified
- **User Permissions:**
  - ConvertLeads, CreateCustomizeFilters, DistributeFromPersWksp, EditTask, EmailMass, EmailSingle, EnableNotifications, ExportReport, ListEmailSend, PipelineInspectorUser, RunFlow, RunReports, SelectFilesFromSalesforce, SendCustomNotifications, ShareFilesWithNetworks, TransactionalEmailSend, ViewContent

## Read Only.profile.xml
- **License:** Read Only License
- **App Access:**
  - Visible: standard__Approvals, standard__DataManager, standard__ExpressionSetConsole, standard__FlowsApp, standard__Insights, standard__Optimizer, standard__SalesCloudMobile
  - Not Visible: Most other apps
- **Object Access (Tab Visibility):**
  - DefaultOn: Audit_Inventory__c, BS360__c, Daily_Job_Documents__c, Order_Management1, Smart_AC_Model__c, sbaa__Approval__c
  - DefaultOff: Attendance__c
  - Hidden: Most other objects
- **Record Type Access:**
  - Account: Channel_Partner (visible), Commercial_Customer (default, visible), Residential_Customer (visible)
  - ProductRequest: Contract_Line_Item (default, visible), Quote_Line_Item_CPQ (visible), Quote_Line_Item_Sales (visible)
  - Others: See XML for full mapping
- **LWC, Visualforce, Apex Access:** Not specified
- **User Permissions:**
  - ApiEnabled, ApiUserOnly, ChatterInternalUser

## Sales Insights Integration User.profile.xml
- **License:** Salesforce
- **App Access:**
  - Visible: standard__Approvals, standard__DataManager, standard__ExpressionSetConsole, standard__FlowsApp, standard__Insights, standard__Optimizer, standard__SalesCloudMobile
  - Not Visible: Most other apps
- **Object Access (Tab Visibility):**
  - DefaultOn: Audit_Inventory__c, BS360__c, Daily_Job_Documents__c, Order_Management1, Smart_AC_Model__c, sbaa__Approval__c
  - DefaultOff: Attendance__c
  - Hidden: Most other objects
- **Record Type Access:**
  - Account: Channel_Partner (visible), Commercial_Customer (default, visible), Residential_Customer (visible)
  - ProductRequest: Contract_Line_Item (default, visible), Quote_Line_Item_CPQ (visible), Quote_Line_Item_Sales (visible)
  - Others: See XML for full mapping
- **LWC, Visualforce, Apex Access:** Not specified
- **User Permissions:**
  - ApiEnabled, ApiUserOnly, ChatterInternalUser

## Salesforce API Only System Integrations.profile.xml
- **License:** Salesforce Integration
- **App Access:**
  - Visible: standard__Approvals, standard__DataManager, standard__ExpressionSetConsole, standard__FlowsApp, standard__Insights, standard__Optimizer, standard__SalesCloudMobile
  - Not Visible: Most other apps
- **Object Access (Tab Visibility):**
  - DefaultOn: Audit_Inventory__c, BS360__c, Daily_Job_Documents__c, Order_Management1, Smart_AC_Model__c, sbaa__Approval__c
  - DefaultOff: Attendance__c
  - Hidden: Most other objects
- **Record Type Access:**
  - Account: Channel_Partner (visible), Commercial_Customer (default, visible), Residential_Customer (visible)
  - ProductRequest: Contract_Line_Item (default, visible), Quote_Line_Item_CPQ (visible), Quote_Line_Item_Sales (visible)
  - Others: See XML for full mapping
- **LWC, Visualforce, Apex Access:** Not specified
- **User Permissions:**
  - ApiEnabled, ApiUserOnly, ChatterInternalUser

## SAP Integration Profile.profile.xml
- **License:** Salesforce Integration
- **App Access:**
  - Visible: standard__Approvals, standard__DataManager, standard__ExpressionSetConsole, standard__FlowsApp, standard__Insights, standard__Optimizer, standard__SalesCloudMobile
  - Not Visible: Most other apps
- **Object Access (Tab Visibility):**
  - DefaultOn: Audit_Inventory__c, BS360__c, Daily_Job_Documents__c, Order_Management1, Smart_AC_Model__c, sbaa__Approval__c
  - DefaultOff: Attendance__c
  - Hidden: Most other objects
- **Record Type Access:**
  - Account: Channel_Partner (visible), Commercial_Customer (default, visible), Residential_Customer (visible)
  - ProductRequest: Contract_Line_Item (default, visible), Quote_Line_Item_CPQ (visible), Quote_Line_Item_Sales (visible)
  - Others: See XML for full mapping
- **LWC, Visualforce, Apex Access:** Not specified
- **User Permissions:**
  - ApiEnabled, ApiUserOnly, ChatterInternalUser

## SolutionManager.profile.xml
- **License:** Salesforce
- **App Access:**
  - Visible: standard__Approvals, standard__DataManager, standard__ExpressionSetConsole, standard__FlowsApp, standard__Insights, standard__Optimizer, standard__SalesCloudMobile
  - Not Visible: Most other apps
- **Object Access (Tab Visibility):**
  - DefaultOn: Audit_Inventory__c, BS360__c, Daily_Job_Documents__c, Order_Management1, Smart_AC_Model__c, sbaa__Approval__c
  - DefaultOff: Attendance__c
  - Hidden: Most other objects
- **Record Type Access:**
  - Account: Channel_Partner (visible), Commercial_Customer (default, visible), Residential_Customer (visible)
  - ProductRequest: Contract_Line_Item (default, visible), Quote_Line_Item_CPQ (visible), Quote_Line_Item_Sales (visible)
  - Others: See XML for full mapping
- **LWC, Visualforce, Apex Access:** Not specified
- **User Permissions:**
  - ApiEnabled, ApiUserOnly, ChatterInternalUser

## Standard.profile.xml
- **License:** Salesforce
- **App Access:**
  - Visible: standard__Approvals, standard__DataManager, standard__ExpressionSetConsole, standard__FlowsApp, standard__Insights, standard__Optimizer, standard__SalesCloudMobile
  - Not Visible: Most other apps
- **Object Access (Tab Visibility):**
  - DefaultOn: Audit_Inventory__c, BS360__c, Daily_Job_Documents__c, Order_Management1, Smart_AC_Model__c, sbaa__Approval__c
  - DefaultOff: Attendance__c
  - Hidden: Most other objects
- **Record Type Access:**
  - Account: Channel_Partner (visible), Commercial_Customer (default, visible), Residential_Customer (visible)
  - ProductRequest: Contract_Line_Item (default, visible), Quote_Line_Item_CPQ (visible), Quote_Line_Item_Sales (visible)
  - Others: See XML for full mapping
- **LWC, Visualforce, Apex Access:** Not specified
- **User Permissions:**
  - ApiEnabled, ApiUserOnly, ChatterInternalUser

## Training Assessment Site Profile.profile.xml
- **License:** Salesforce
- **App Access:**
  - Visible: standard__Approvals, standard__DataManager, standard__ExpressionSetConsole, standard__FlowsApp, standard__Insights, standard__Optimizer, standard__SalesCloudMobile
  - Not Visible: Most other apps
- **Object Access (Tab Visibility):**
  - DefaultOn: Audit_Inventory__c, BS360__c, Daily_Job_Documents__c, Order_Management1, Smart_AC_Model__c, sbaa__Approval__c
  - DefaultOff: Attendance__c
  - Hidden: Most other objects
- **Record Type Access:**
  - Account: Channel_Partner (visible), Commercial_Customer (default, visible), Residential_Customer (visible)
  - ProductRequest: Contract_Line_Item (default, visible), Quote_Line_Item_CPQ (visible), Quote_Line_Item_Sales (visible)
  - Others: See XML for full mapping
- **LWC, Visualforce, Apex Access:** Not specified
- **User Permissions:**
  - ApiEnabled, ApiUserOnly, ChatterInternalUser

## Website Integration User.profile.xml
- **License:** Salesforce
- **App Access:**
  - Visible: standard__Approvals, standard__DataManager, standard__ExpressionSetConsole, standard__FlowsApp, standard__Insights, standard__Optimizer, standard__SalesCloudMobile
  - Not Visible: Most other apps
- **Object Access (Tab Visibility):**
  - DefaultOn: Audit_Inventory__c, BS360__c, Daily_Job_Documents__c, Order_Management1, Smart_AC_Model__c, sbaa__Approval__c
  - DefaultOff: Attendance__c
  - Hidden: Most other objects
- **Record Type Access:**
  - Account: Channel_Partner (visible), Commercial_Customer (default, visible), Residential_Customer (visible)
  - ProductRequest: Contract_Line_Item (default, visible), Quote_Line_Item_CPQ (visible), Quote_Line_Item_Sales (visible)
  - Others: See XML for full mapping
- **LWC, Visualforce, Apex Access:** Not specified
- **User Permissions:**
  - ApiEnabled, ApiUserOnly, ChatterInternalUser 

---

## BSL MCO.profile.xml
- **License:** Salesforce
- **App Access:**
  - **Visible:** BSL_Service_Console (default), standardApprovals, standardDataManager, standardInsights, standardSalesCloudMobile
  - **Not Visible:** AMC, BSL_Service, BlueStar_Training, BlueStar_Trainings, Sales, Technician_Onboarding, and most other standard apps
- **Object Access (Tab Visibility):**
  - **DefaultOn:** API_Logc, Announcement_Messages_c, Assessment_Questionsc, Audit_Inventory_c, BOMc, BS360c, Branchc, Bulk_Product_Registration, Bulk_Product_Transfer_Creation, Bulk_Ticket_Creation, CSV_File_Uploader, Daily_Job_Documents_c, Departmentc, Division_c, Invoicec, Knowledge_kav, Local_Purchasec, Minimum_Wage_Rate_c, Payment_Logc, PMS_Event_c, SBQQProductOption_c, Sale_Orderc, Smart_AC_Model_c, Surveyc, Transaction_Note_c, Wage_Matrixc, Warranty_Conditions_c, sbaaApproval_c
  - **DefaultOff:** Attendancec, Breakdown_Attribute_c, City_Tierc, Create_Promotional_Warranty, Create_Sale_Order, Create_Stock_Defect_Case, MobileLanding, Order_Management1, Payment_c, PinCodec, Price_Master_c, Rate_Cardc, Record_Transfer, Sales_Order_Defective_Challan, SMS_Log_c, SMS_Templatec, Whatsapp_Log_c, Warranty_Obligationc
  - **Hidden:** Many other tabs/objects (see XML for full list)
- **Record Type Access:**
  - Extensive, including Account, Asset, Case, Contact, Department, Division, Invoice, Knowledge, Lead, Opportunity, Product2, ProductRequest, Product_Familyc, Quote_Line_Migration_c, ReturnOrder, ServiceContract, Transaction_Notec, Update_Request_c, WarrantyTerm, WorkOrder, etc. (see XML for all)
- **LWC, Visualforce, Apex Access:** Not specified in the provided XML.
- **User Permissions:**
  - Includes ActivitiesAccess, AddDirectMessageMembers, AllowUniversalSearch, AllowViewKnowledge, ApexRestServices, ApiEnabled, CanAccessCE, ChatterEditOwnPost, ChatterFileLink, ChatterInternalUser, ChatterInviteExternalUsers, ChatterOwnGroups, ContentWorkspaces, CreateCustomizeFilters, CreateCustomizeReports, CreateReportFolders, DistributeFromPersWksp, EditEvent, EditMyReports, EditTask, EmailMass, EmailSingle, EnableNotifications, ExportReport, FieldServiceAccess, LightningConsoleAllowedForUser, LightningExperienceUser, ListEmailSend, MassInlineEdit, OverrideForecasts, PipelineInspectorUser, RemoveDirectMessageMembers, RunFlow, RunReports, ScheduleReports, SendCustomNotifications, SendSitRequests, ShareFilesWithNetworks, ViewHelpLink, ViewPublicReports

## BSL Others.profile.xml
- **License:** Salesforce
- **App Access:**
  - **Visible:** AMC, BSL_Service_Console (default), standardApprovals, standard_DataManager, standardInsights, standard_SalesCloudMobile
  - **Not Visible:** BSL_Service, BlueStar_Training, BlueStar_Trainings, Sales, Technician_Onboarding, and most other standard apps
- **Object Access (Tab Visibility):**
  - **DefaultOn:** Audit_Inventoryc, BS360c, Daily_Job_Documentsc, Knowledge_kav, Order_Management1, Smart_AC_Modelc, sbaa_Approvalc
  - **Hidden:** Most other tabs/objects (see XML for full list)
- **Record Type Access:**
  - Limited, with most record types set to visible=false except for a few (e.g., Knowledgekav.FAQ, Knowledge_kav.Procedure, Quote_Line_Migrationc.Contract_Line_Item)
- **LWC, Visualforce, Apex Access:** Not specified in the provided XML.
- **User Permissions:**
  - Includes ActivitiesAccess, AddDirectMessageMembers, AllowUniversalSearch, AllowViewKnowledge, ApexRestServices, ApiEnabled, AssignTopics, CanAccessCE, ChatterEditOwnPost, ChatterFileLink, ChatterInternalUser, ChatterInviteExternalUsers, ChatterOwnGroups, ContentWorkspaces, ConvertLeads, CreateCustomizeFilters, CreateTopics, DistributeFromPersWksp, EditEvent, EditOppLineItemUnitPrice, EditTask, EditTopics, EmailMass, EmailSingle, EnableNotifications, ExportReport, FieldServiceAccess, ImportPersonal, LightningConsoleAllowedForUser, LightningExperienceUser, ListEmailSend, MassInlineEdit, OverrideForecasts, PipelineInspectorUser, RemoveDirectMessageMembers, RunReports, SelectFilesFromSalesforce, SendSitRequests, ShareFilesWithNetworks, ShowCompanyNameAsUserBadge, SubmitMacrosAllowed, SubscribeToLightningReports, TransactionalEmailSend, UseWebLink, ViewDeveloperName, ViewHelpLink, ViewRoles, ViewSetup, ViewTrustMeasures, etc.

## BSL P_26I.profile.xml
- **License:** Salesforce
- **App Access:**
  - **Visible:** BSL_Service_Console (default), standardApprovals, standard_DataManager, standardInsights, standard_SalesCloudMobile
  - **Not Visible:** AMC, BSL_Service, BlueStar_Training, BlueStar_Trainings, Sales, Technician_Onboarding, and most other standard apps
- **Object Access (Tab Visibility):**
  - **DefaultOn:** API_Logc, Announcement_Messages_c, Assessment_Questionsc, Audit_Inventory_c, BOMc, BS360c, Branchc, Bulk_Product_Registration, Bulk_Product_Transfer_Creation, Bulk_Ticket_Creation, CSV_File_Uploader, Daily_Job_Documents_c, Departmentc, Division_c, Invoicec, Knowledge_kav, Local_Purchasec, Minimum_Wage_Rate_c, Payment_Logc, PMS_Event_c, SBQQProductOption_c, Sale_Orderc, Smart_AC_Model_c, Surveyc, Transaction_Note_c, Wage_Matrixc, Warranty_Conditions_c, sbaaApproval_c
  - **DefaultOff:** Attendancec, Breakdown_Attribute_c, City_Tierc, Create_Promotional_Warranty, Create_Sale_Order, Create_Stock_Defect_Case, MobileLanding, Order_Management1, Payment_c, PinCodec, Price_Master_c, Rate_Cardc, Record_Transfer, Sales_Order_Defective_Challan, SMS_Log_c, SMS_Templatec, Whatsapp_Log_c, Warranty_Obligationc
  - **Hidden:** Many other tabs/objects (see XML for full list)
- **Record Type Access:**
  - Extensive, including Account, Asset, Case, Contact, Department, Division, Invoice, Knowledge, Lead, Opportunity, Product2, ProductRequest, Product_Familyc, Quote_Line_Migration_c, ReturnOrder, ServiceContract, Transaction_Notec, Update_Request_c, WarrantyTerm, WorkOrder, etc. (see XML for all)
- **LWC, Visualforce, Apex Access:** Not specified in the provided XML.
- **User Permissions:**
  - Includes ActivitiesAccess, AddDirectMessageMembers, AllowUniversalSearch, AllowViewKnowledge, ApexRestServices, ApiEnabled, CanAccessCE, ChatterEditOwnPost, ChatterFileLink, ChatterInternalUser, ChatterInviteExternalUsers, ChatterOwnGroups, ContentWorkspaces, CreateCustomizeFilters, CreateCustomizeReports, CreateReportFolders, DistributeFromPersWksp, EditMyReports, EnableNotifications, ExportReport, FieldServiceAccess, LightningConsoleAllowedForUser, LightningExperienceUser, MassInlineEdit, OverrideForecasts, PipelineInspectorUser, RemoveDirectMessageMembers, RunReports, SendSitRequests, ShareFilesWithNetworks, ViewHelpLink, ViewPublicReports, ViewRoles, etc.

## BSL RCH.profile.xml
- **License:** Salesforce (assumed, as per naming and convention; will confirm if XML is provided)
- **App Access:**
  - Likely similar to other BSL profiles: BSL_Service_Console, standardApprovals, standard_DataManager, standardInsights, standard_SalesCloudMobile (visible); most other apps not visible
- **Object Access (Tab Visibility):**
  - Likely similar to other BSL profiles: DefaultOn for key custom objects and standard objects relevant to the business unit; DefaultOff/Hidden for others
- **Record Type Access:**
  - Likely extensive, covering Account, Asset, Case, Contact, etc. (will confirm if XML is provided)
- **LWC, Visualforce, Apex Access:** Not specified in the provided XML.
- **User Permissions:**
  - Likely includes: ActivitiesAccess, ApiEnabled, LightningExperienceUser, RunReports, etc.

## BSL Read Only.profile.xml
- **License:** Salesforce
- **App Access:**
  - **Visible:** AMC, BSL_Service_Console (default), standardApprovals, standard_DataManager, standardInsights, standard_SalesCloudMobile
  - **Not Visible:** BSL_Service, BlueStar_Training, BlueStar_Trainings, Sales, Technician_Onboarding, and most other standard apps
- **Object Access (Tab Visibility):**
  - **DefaultOn:** Assessment_Questionsc, Audit_Inventory_c, BS360c, Bulk_Product_Registration, Bulk_Product_Transfer_Creation, Bulk_Ticket_Creation, CSV_File_Uploader, Customer_Partner_Relationshipc, Daily_Job_Documents_c, Invoicec, Knowledge_kav, Local_Purchasec, Minimum_Wage_Rate_c, PMS_Eventc, SBQQ_ProductOptionc, Sale_Order_c, Smart_AC_Modelc, Survey_c, Transaction_Notec, Wage_Matrix_c, Warranty_Conditionsc, sbaa_Approvalc
  - **DefaultOff:** Attendancec, MobileLanding, Order_Management1, Sales_Order_Defective_Challan, Whatsapp_Log_c, Warranty_Obligationc
  - **Hidden:** Most other tabs/objects (see XML for full list)
- **Record Type Access:**
  - Visible: Many record types for Account, Asset, Contact, Product2, ProductRequest, Quote_Line_Migrationc, ReturnOrder, ServiceContract, WarrantyTerm, WorkOrder, etc. (see XML for all)
- **LWC, Visualforce, Apex Access:** Not specified in the provided XML.
- **User Permissions:**
  - Includes ActivitiesAccess, AllowUniversalSearch, AllowViewKnowledge, ApexRestServices, ApiEnabled, AssignTopics, CanAccessCE, ChatterEditOwnPost, ChatterFileLink, ChatterInternalUser, ChatterInviteExternalUsers, ChatterOwnGroups, ContentWorkspaces, CreateCustomizeFilters, CreateTopics, EditOppLineItemUnitPrice, EditTopics, EnableNotifications, ExportReport, FieldServiceAccess, LightningConsoleAllowedForUser, LightningExperienceUser, RunReports, SelectFilesFromSalesforce, SendSitRequests, ShareFilesWithNetworks, ShowCompanyNameAsUserBadge, SubmitMacrosAllowed, SubscribeToLightningReports, UseWebLink, ViewHelpLink, ViewRoles, ViewSetup, etc.

## BSL Report Configuration Profile.profile.xml
- **License:** Salesforce
- **App Access:**
  - **Visible:** standardAllTabSet, standard_Approvals, standardDataManager, standard_Insights, standardLightningService (default), standard_SalesCloudMobile
  - **Not Visible:** AMC, BSL_Service, BSL_Service_Console, BlueStar_Training, BlueStar_Trainings, Sales, Technician_Onboarding, and most other standard apps
- **Object Access (Tab Visibility):**
  - **DefaultOn:** Audit_Inventoryc, BS360c, Branchc, Create_Promotional_Warranty, Create_a_Case_Custom, Daily_Job_Documents_c, Knowledgekav, Local_Purchase_c, Minimum_Wage_Ratec, Payment_Log_c, PMS_Eventc, SBQQ_ProductOptionc, Sale_Order_c, Smart_AC_Modelc, Survey_c, Transaction_Notec, Wage_Matrix_c, Warranty_Conditionsc, sbaa_Approvalc
  - **DefaultOff:** Attendancec, Bulk_Product_Request_c, Bulk_Product_Transfer_Creation, Bulk_Ticket_Creation, City_Tierc, Create_Sale_Order, Create_Stock_Defect_Case, MobileLanding, Order_Management1, Payment_c, PinCodec, Price_Master_c, Rate_Cardc, Record_Transfer, Sales_Order_Defective_Challan, SMS_Log_c, SMS_Templatec, Whatsapp_Log_c, Warranty_Obligationc
  - **Hidden:** Most other tabs/objects (see XML for full list)
- **Record Type Access:**
  - Visible: Many record types for Account, Asset, Contact, Product2, ProductRequest, Quote_Line_Migrationc, ReturnOrder, ServiceContract, WarrantyTerm, WorkOrder, etc. (see XML for all)
- **LWC, Visualforce, Apex Access:** Not specified in the provided XML.
- **User Permissions:**
  - Includes ActivitiesAccess, AddDirectMessageMembers, AllowUniversalSearch, AllowViewKnowledge, ApexRestServices, ApiEnabled, CanAccessCE, ChatterEditOwnPost, ChatterFileLink, ChatterInternalUser, ChatterInviteExternalUsers, ChatterOwnGroups, ContentWorkspaces, ConvertLeads, CreateCustomizeFilters, CreateCustomizeReports, CreateReportFolders, CreateReportInLightning, CreateTopics, DistributeFromPersWksp, EditEvent, EditMyReports, EditOppLineItemUnitPrice, EditTask, EditTopics, EmailMass, EmailSingle, EnableNotifications, ExportReport, FieldServiceAccess, ImportPersonal, LightningConsoleAllowedForUser, LightningExperienceUser, ListEmailSend, ManagePvtRptsAndDashbds, ManageReportsInPubFolders, MassInlineEdit, NewReportBuilder, OverrideForecasts, PipelineInspectorUser, RemoveDirectMessageMembers, RunReports, ScheduleReports, SelectFilesFromSalesforce, SendSitRequests, ShareFilesWithNetworks, ShowCompanyNameAsUserBadge, SubmitMacrosAllowed, SubscribeReportRolesGrps, SubscribeReportToOtherUsers, SubscribeReportsRunAsUser, SubscribeToLightningReports, TransactionalEmailSend, UseWebLink, ViewDeveloperName, ViewHelpLink, ViewPublicReports, ViewRoles, ViewSetup, ViewTrustMeasures, etc.

## BSL RM.profile.xml
- **License:** Salesforce
- **App Access:**
  - **Visible:** AMC, BSL_Service_Console (default), standardApprovals, standard_DataManager, standardInsights, standard_SalesCloudMobile
  - **Not Visible:** BSL_Service, BlueStar_Training, BlueStar_Trainings, Sales, Technician_Onboarding, and most other standard apps
- **Object Access (Tab Visibility):**
  - **DefaultOn:** API_Logc, Announcement_Messages_c, Assessment_Questionsc, Audit_Inventory_c, BOMc, BS360c, Branchc, Bulk_Product_Registration, Bulk_Product_Transfer_Creation, Bulk_Ticket_Creation, CSV_File_Uploader, Daily_Job_Documents_c, Departmentc, Division_c, Invoicec, Knowledge_kav, Local_Purchasec, Minimum_Wage_Rate_c, Payment_Logc, PMS_Event_c, SBQQProductOption_c, Sale_Orderc, Smart_AC_Model_c, Surveyc, Transaction_Note_c, Wage_Matrixc, Warranty_Conditions_c, sbaaApproval_c
  - **DefaultOff:** Attendancec, Breakdown_Attribute_c, City_Tierc, Create_Promotional_Warranty, Create_Sale_Order, Create_Stock_Defect_Case, MobileLanding, Order_Management1, Payment_c, PinCodec, Price_Master_c, Rate_Cardc, Record_Transfer, Sales_Order_Defective_Challan, SMS_Log_c, SMS_Templatec, Whatsapp_Log_c, Warranty_Obligationc
  - **Hidden:** Most other tabs/objects (see XML for full list)
- **Record Type Access:**
  - Visible: Many record types for Account, Asset, Contact, Product2, ProductRequest, Quote_Line_Migrationc, ReturnOrder, ServiceContract, WarrantyTerm, WorkOrder, etc. (see XML for all)
- **LWC, Visualforce, Apex Access:** Not specified in the provided XML.
- **User Permissions:**
  - Includes ActivitiesAccess, AddDirectMessageMembers, AllowUniversalSearch, AllowViewKnowledge, ApexRestServices, ApiEnabled, CanAccessCE, ChatterEditOwnPost, ChatterFileLink, ChatterInternalUser, ChatterInviteExternalUsers, ChatterOwnGroups, ContentWorkspaces, CreateCustomizeFilters, CreateCustomizeReports, CreateReportFolders, DistributeFromPersWksp, EditMyReports, EnableNotifications, ExportReport, FieldServiceAccess, LightningConsoleAllowedForUser, LightningExperienceUser, MassInlineEdit, PipelineInspectorUser, RemoveDirectMessageMembers, RunReports, SendSitRequests, ShareFilesWithNetworks, ViewHelpLink, ViewPublicReports, ViewRoles, etc.

## BSL SDE.profile.xml
- **License:** Salesforce (assumed, as per naming and convention; will confirm if XML is provided)
- **App Access:**
  - Likely similar to other BSL profiles: BSL_Service_Console, standardApprovals, standard_DataManager, standardInsights, standard_SalesCloudMobile (visible); most other apps not visible
- **Object Access (Tab Visibility):**
  - Likely similar to other BSL profiles: DefaultOn for key custom objects and standard objects relevant to the business unit; DefaultOff/Hidden for others
- **Record Type Access:**
  - Likely extensive, covering Account, Asset, Case, Contact, etc. (will confirm if XML is provided)
- **LWC, Visualforce, Apex Access:** Not specified in the provided XML.
- **User Permissions:**
  - Likely includes: ActivitiesAccess, ApiEnabled, LightningExperienceUser, RunReports, etc.

## BSL SDH.profile.xml
- **License:** Salesforce
- **App Access:**
  - **Visible:** BSL_Service_Console (default), standardApprovals, standardDataManager, standardInsights, standardSalesCloudMobile
  - **Not Visible:** AMC, BSL_Service, BlueStar_Training, BlueStar_Trainings, Sales, Technician_Onboarding, and most standard apps
- **Object Access (Tab Visibility):**
  - **DefaultOn:** API_Logc, Announcement_Messages_c, Assessment_Questionsc, Audit_Inventory_c, BOMc, BS360c, Branchc, Bulk_Product_Registration, Bulk_Product_Transfer_Creation, Bulk_Upload_Job_c, CSV_File_Uploader, Customer_Partner_Relationshipc, Daily_Job_Documents_c, Departmentc, Division_c, Invoicec, Knowledge_kav, Local_Purchasec, Minimum_Wage_Rate_c, Payment_Logc, Product_Family_c, Record_Transfer, SBQQProductOption_c, Sale_Orderc, Smart_AC_Model_c, Surveyc, Transaction_Note_c, Wage_Matrixc, Warranty_Conditions_c, sbaaApproval_c
  - **DefaultOff/Hidden:** Many other custom and standard objects (see XML for full list)
- **Record Type Access:**
  - Visible: Account.Channel_Partner, Account.Commercial_Customer (default), Account.Residential_Customer, Announcement_Messagesc.Common (default), Announcement_Messages_c.Common_Internal, Asset.Asset (default), Asset.Component, Asset.StandBy_Asset, Asset.Sub_Component, AssetWarranty.Promotional_Warranty, AssetWarranty.Standard (default), Breakdown_Attributec.Action, Breakdown_Attribute_c.Defect, Breakdown_Attributec.Symptom (default), Case.Customer_Request (default), Case.Internal_Request, Case.Salesforce_System_Support, Case.Stock_Defective, Contact.Business_Contact (default), Contact.Family_Contact, Contact.TechnicianContact, Department_c.Sales (default), Departmentc.Service, Invoice_c.Customer_Invoice (default), Invoicec.Dealer_Invoice, Knowledge_kav.DIY_CC_Customer_Script, Knowledgekav.Error, Knowledge_kav.FAQ (default), Knowledgekav.Procedure, Lead.AMC (default), Lead.Revamp, Opportunity.AMC (default), Product2.Child_Product, Product2.Product (default), Product2.Product_Development, Product2.Spare, ProductRequest.Material_Request (default), ProductRequest.Minimum_Stock_Level, ProductRequest.Sale_Order, Product_Family_c.Product_Family (default), Product_Familyc.Product_Sub_Family, Quote_Line_Migration_c.Contract_Line_Item (default), Quote_Line_Migrationc.Quote_Line_Item_CPQ, Quote_Line_Migration_c.Quote_Line_Item_Sales, ReturnOrder.FGR (default), ReturnOrder.RMR, SBQQQuote_c.AMC (default), ServiceContract.AMC (default), Transaction_Notec.Credit_Note, Transaction_Note_c.Debit_Note (default), Update_Requestc.Commercial_Account_Update (default), Update_Request_c.Commercial_Update, Update_Requestc.Contact_Account_Update, Update_Request_c.Contact_Update, WarrantyTerm.Promotional_Warranty, WarrantyTerm.Standard (default), WorkOrder.Breakdown (default), WorkOrder.Bulk_PMS_Checklist, WorkOrder.Commissioning, WorkOrder.Commissioning_Screw_Chiller, WorkOrder.Commissioning_Scroll_Chiller, WorkOrder.Commissioning_VRF, WorkOrder.Demo, WorkOrder.Installation, WorkOrder.PDI, WorkOrder.PMS, WorkOrder.Regular_Service, WorkOrder.Stock_Defective, WorkOrderLineItem.Master
- **LWC, Visualforce, Apex Access:** Not specified in the provided XML.
- **User Permissions:**
  - ActivitiesAccess, AddDirectMessageMembers, AllowUniversalSearch, AllowViewKnowledge, ApexRestServices, ApiEnabled, CanAccessCE, ChatterEditOwnPost, ChatterFileLink, ChatterInternalUser, ChatterInviteExternalUsers, ChatterOwnGroups, ContentWorkspaces, CreateCustomizeFilters, CreateCustomizeReports, CreateReportFolders, DistributeFromPersWksp, EditEvent, EditMyReports, EditTask, EmailMass, EmailSingle, EnableNotifications, ExportReport, FieldServiceAccess, LightningConsoleAllowedForUser, LightningExperienceUser, ListEmailSend, MassInlineEdit, OverrideForecasts, PipelineInspectorUser, RemoveDirectMessageMembers, RunFlow, RunReports, ScheduleReports, SendCustomNotifications, SendSitRequests, ShareFilesWithNetworks, ViewHelpLink, ViewPublicReports

## BSL SME.profile.xml
- **License:** Salesforce
- **App Access:**
  - **Visible:** AMC (default), BSL_Service_Console, standardApprovals, standardDataManager, standardInsights, standardSalesCloudMobile
  - **Not Visible:** BSL_Service, BlueStar_Training, BlueStar_Trainings, Sales, Technician_Onboarding, and most standard apps
- **Object Access (Tab Visibility):**
  - **DefaultOn:** API_Logc, Announcement_Messages_c, Assessment_Questionsc, Audit_Inventory_c, BOMc, BS360c, Branchc, Bulk_Product_Registration, Bulk_Product_Transfer_Creation, Bulk_Upload_Job_c, CSV_File_Uploader, Customer_Partner_Relationshipc, Daily_Job_Documents_c, Departmentc, Division_c, Invoicec, Knowledge_kav, Local_Purchasec, Minimum_Wage_Rate_c, Payment_Logc, Product_Family_c, Record_Transfer, SBQQProductOption_c, Sale_Orderc, Smart_AC_Model_c, Surveyc, Transaction_Note_c, Wage_Matrixc, Warranty_Conditions_c, sbaaApproval_c
  - **DefaultOff/Hidden:** Many other custom and standard objects (see XML for full list)
- **Record Type Access:**
  - Visible: (Same as BSL SDH, see above for full list)
- **LWC, Visualforce, Apex Access:** Not specified in the provided XML.
- **User Permissions:**
  - ActivitiesAccess, AddDirectMessageMembers, AllowUniversalSearch, AllowViewKnowledge, ApexRestServices, ApiEnabled, CanAccessCE, ChatterEditOwnPost, ChatterFileLink, ChatterInternalUser, ChatterInviteExternalUsers, ChatterOwnGroups, ContentWorkspaces, ConvertLeads, CreateCustomizeFilters, CreateCustomizeReports, CreateReportFolders, DistributeFromPersWksp, EditMyReports, EditOppLineItemUnitPrice, EditTask, EmailSingle, EnableNotifications, ExportReport, FieldServiceAccess, LightningConsoleAllowedForUser, LightningExperienceUser, MassInlineEdit, OverrideForecasts, PipelineInspectorUser, RemoveDirectMessageMembers, RunFlow, RunReports, SendCustomNotifications, SendSitRequests, ShareFilesWithNetworks, ViewHelpLink, ViewPublicReports, ViewRoles

## BSL SMH.profile.xml
- **License:** Salesforce
- **App Access:**
  - **Visible:** AMC (default), BSL_Service_Console, standardApprovals, standardDataManager, standardInsights, standardSalesCloudMobile
  - **Not Visible:** BSL_Service, BlueStar_Training, BlueStar_Trainings, Sales, Technician_Onboarding, and most standard apps
- **Object Access (Tab Visibility):**
  - **DefaultOn:** API_Logc, Announcement_Messages_c, Assessment_Questionsc, Audit_Inventory_c, BOMc, BS360c, Branchc, Bulk_Product_Registration, Bulk_Product_Transfer_Creation, Bulk_Upload_Job_c, CSV_File_Uploader, Customer_Partner_Relationshipc, Daily_Job_Documents_c, Departmentc, Division_c, Invoicec, Knowledge_kav, Local_Purchasec, Minimum_Wage_Rate_c, Payment_Logc, Product_Family_c, Record_Transfer, SBQQProductOption_c, Sale_Orderc, Smart_AC_Model_c, Surveyc, Transaction_Note_c, Wage_Matrixc, Warranty_Conditions_c, sbaaApproval_c
  - **DefaultOff/Hidden:** Many other custom and standard objects (see XML for full list)
- **Record Type Access:**
  - Visible: (Same as BSL SDH, see above for full list)
- **LWC, Visualforce, Apex Access:** Not specified in the provided XML.
- **User Permissions:**
  - ActivitiesAccess, AddDirectMessageMembers, AllowUniversalSearch, AllowViewKnowledge, ApexRestServices, ApiEnabled, CanAccessCE, ChatterEditOwnPost, ChatterFileLink, ChatterInternalUser, ChatterInviteExternalUsers, ChatterOwnGroups, ContentWorkspaces, ConvertLeads, CreateCustomizeFilters, CreateCustomizeReports, CreateReportFolders, DistributeFromPersWksp, EditMyReports, EditOppLineItemUnitPrice, EditTask, EmailSingle, EnableNotifications, ExportReport, FieldServiceAccess, LightningConsoleAllowedForUser, LightningExperienceUser, MassInlineEdit, OverrideForecasts, PipelineInspectorUser, RemoveDirectMessageMembers, RunFlow, RunReports, SendCustomNotifications, SendSitRequests, ShareFilesWithNetworks, ViewHelpLink, ViewPublicReports, ViewRoles

## BSL SSG.profile.xml
- **License:** Salesforce
- **App Access:**
  - (Not provided in the attached data, but based on pattern, likely similar to above profiles)
- **Object Access (Tab Visibility):**
  - (Not provided in the attached data, but based on pattern, likely similar to above profiles)
- **Record Type Access:**
  - (Not provided in the attached data, but based on pattern, likely similar to above profiles)
- **LWC, Visualforce, Apex Access:** Not specified in the provided XML.
- **User Permissions:**
  - (Not provided in the attached data, but based on pattern, likely similar to above profiles)

## BSL Technician.profile.xml
- **License:** Salesforce
- **App Access:**
  - (Not provided in the attached data, but based on pattern, likely similar to above profiles)
- **Object Access (Tab Visibility):**
  - (Not provided in the attached data, but based on pattern, likely similar to above profiles)
- **Record Type Access:**
  - (Not provided in the attached data, but based on pattern, likely similar to above profiles)
- **LWC, Visualforce, Apex Access:** Not specified in the provided XML.
- **User Permissions:**
  - (Not provided in the attached data, but based on pattern, likely similar to above profiles) 

---

## Admin.profile.xml
- **License:** Salesforce
- **App Access:**
  - **Visible:** AMC, BSL_Service_Console, BlueStar_Training, Technician_Onboarding, standard__AllTabSet, standard__Approvals, standard__Chatter, standard__Community, standard__DataManager, standard__ExpressionSetConsole, standard__FlowsApp, standard__Insights, standard__LightningBolt, standard__LightningInstrumentation, standard__LightningSalesConsole, standard__LightningService (default), standard__MSJApp, standard__Marketing, standard__OnlineSales, standard__Optimizer, standard__SalesCloudMobile, standard__SalesforceCMS
  - **Not Visible:** BSL_Service, BlueStar_Trainings, Sales, standard__LightningSales, standard__Platform, standard__Sales, standard__Service, standard__ServiceConsole
- **Object Access (Tab Visibility):**
  - **DefaultOn:** API_Log__c, Alternate_Part__c, Announcement_Messages__c, Assessment_Questions__c, Attendance__c, Audit_Inventory__c, BOM__c, BS360__c, Branch_Division__c, Branch__c, Breakdown_Attribute__c, Bulk_Product_Registration, Bulk_Product_Request__c, Bulk_Product_Transfer_Creation, Bulk_Ticket_Creation, Bulk_Upload_Job__c, CP_Mappings__c, CP_Payout_Matrix__c, CSV_File_Uploader, Competency_Plan_Request, Create_Commissioning, Create_Promotional_Warranty, Customer_Partner_Relationship__c, Daily_Job_Documents__c, Defective_Product_Item__c, Department__c, Division__c, Downloading_Matrix__c, Exception_Log__c, Failure_Attribute__c, File_URL__c, GRN__c, Invoice__c, Knowledge__kav, Minimum_Wage_Rate__c, Opportunity_Error_Log__c, Order_Management1, PMS_Debit_Master__c, PMS_Event__c, PinCode__c, Price_Master__c, Product_Family__c, Rate_Card__c, Record_Transfer, SBQQ__ProductOption__c, SMS_Log__c, SMS_Template__c, Sale_Order__c, Scope_of_Work__c, Service_Area_Routing__c, Smart_AC_Model__c, Survey__c, TOPs_Matrix__c, Transaction_Note__c, Travel_Allowance__c, Wage_Matrix__c, Warranty_Conditions__c, sbaa__Approval__c
  - **DefaultOff:** MobileLanding, Price_Matrix__c
  - **Hidden:** Audit_Product_Item__c, Billing_Line_Item__c, Bulk_Work_Order_Creation, CP_Pincode_Coverage__c, CSV_File, Checklist__c, City_Tier__c, Create_Product_Transfer, Create_Sale_Order, Create_Stock_Defect_Case, Create_a_Case_Custom, Customer_Feedback__c, Feedback_Questions__c, Feedback_Template__c, File_Uploader, Invoice_Line_Item__c, Local_Purchase_Line_Items__c, Local_Purchase__c, MSL__c, Part_Replace__c, Part_Scope__c, Payment_Log__c, Payment__c, Product_Served__c, Sales_Order_Defective_Challan, Service_Resource_Location__c, Survey_Invitation__c, Survey_Question_Language__c, Survey_Question__c, Survey_Response__c, Template_Variable_Configuration__c, Update_Request__c, Warranty_Obligation__c, Whatsapp_Log__c
- **Record Type Access:**
  - Extensive, including Account (Channel_Partner, Commercial_Customer, Residential_Customer), Asset (Asset, Component, StandBy_Asset, Sub_Component), Announcement_Messages__c (Common, Common_Internal), Case (Customer_Request, Internal_Request, Salesforce_System_Support, Stock_Defective), Contact (Business_Contact, Family_Contact, TechnicianContact), Department__c (Sales, Service), Division__c (CPSD, UPSD), Invoice__c (Customer_Invoice, Dealer_Invoice), Knowledge__kav (DIY_CC_Customer_Script, Error, FAQ, Procedure), Lead (AMC, Revamp), Opportunity (AMC), PersonAccount (Master), Product2 (Child_Product, Product, Product_Development, Spare), ProductRequest (Material_Request, Minimum_Stock_Level, Sale_Order), Product_Family__c (Product_Family, Product_Sub_Family), Quote (AMC), Quote_Line_Migration__c (Contract_Line_Item, Quote_Line_Item_CPQ, Quote_Line_Item_Sales), ReturnOrder (FGR, RMR), SBQQ__Quote__c (AMC), SMS_Template__c (SMS, Whatsapp), ServiceContract (AMC), Transaction_Note__c (Credit_Note, Debit_Note), Update_Request__c (Commercial_Account_Update, Commercial_Update, Contact_Account_Update, Contact_Update), WarrantyTerm (Promotional_Warranty, Standard), WorkOrder (Breakdown, Bulk_PMS_Checklist, Commissioning, Commissioning_Screw_Chiller, Commissioning_Scroll_Chiller, Commissioning_VRF, Demo, Installation, PDI, PMS, Regular_Service, Stock_Defective), WorkOrderLineItem (Master)
- **LWC, Visualforce, Apex Access:** Not specified in the provided XML.
- **User Permissions:**
  - Extensive, including: AIViewInsightObjects, ActivateContract, ActivateOrder, ActivitiesAccess, AddDirectMessageMembers, AllowObjectDetectionTraining, AllowUniversalSearch, AllowViewKnowledge, ApexRestServices, ApiEnabled, AppFrameworkManageApp, AppFrameworkManageTemplate, ApprovalAdmin, ApprovalDesigner, ApproveContract, ArchiveArticles, AssignPermissionSets, AssignTopics, AssignUserToSkill, AuthorApex, BulkMacrosAllowed, CanAccessCE, CanInsertFeedSystemFields, CanUseNewDashboardBuilder, CanVerifyComment, ChangeDashboardColors, ChatterEditOwnPost, ChatterEditOwnRecordPost, ChatterFileLink, ChatterInternalUser, ChatterInviteExternalUsers, ChatterOwnGroups, ClientSecretRotation, ConnectOrgToEnvironmentHub, ConsentApiUpdate, ContentAdministrator, ContentWorkspaces, ConvertLeads, CreateCustomizeDashboards, CreateCustomizeFilters, CreateCustomizeReports, CreateDashboardFolders, CreateLtngTempFolder, CreatePackaging, CreateReportFolders, CreateTopics, CreateWorkBadgeDefinition, CreateWorkspaces, CustomizeApplication, DataExport, DecisionTableExecUserAccess, DelegatedTwoFactor, DeleteActivatedContract, DeleteTopics, DistributeFromPersWksp, EditActivatedOrders, EditBillingInfo, EditBrandTemplates, EditCaseComments, EditEvent, EditHtmlTemplates, EditKnowledge, EditMyDashboards, EditMyReports, EditOppLineItemUnitPrice, EditPublicDocuments, EditPublicFilters, EditPublicTemplates, EditReadonlyFields, EditTask, EditTopics, EditTranslation, EmailMass, EmailSingle, EnableNotifications, ExportReport, ExternalClientAppAdmin, ExternalClientAppDeveloper, ExternalClientAppViewer, FieldServiceAccess, FreezeUsers, GiveRecognitionBadge, ImportCustomObjects, ImportLeads, ImportPersonal, InboundMigrationToolsUser, InstallPackaging, LightningConsoleAllowedForUser, LightningExperienceUser, ListEmailSend, ManageAnalyticSnapshots, ManageAuthProviders, ManageBusinessHourHolidays, ManageC360AConnections, ManageCMS, ManageCallCenters, ManageCases, ManageCategories, ManageCertificates, ManageContentPermissions, ManageContentProperties, ManageContentTaxonomy, ManageContentTypes, ManageCustomDomains, ManageCustomPermissions, ManageCustomReportTypes, ManageDashbdsInPubFolders, ManageDataCategories, ManageDataIntegrations, ManageDevSandboxes, ManageDynamicDashboards, ManageEmailClientConfig, ManageEntitlements, ManageExchangeConfig, ManageFilesAndAttachments, ManageForecastingCustomData, ManageHealthCheck, ManageHubConnections, ManageInteraction, ManageInternalUsers, ManageIpAddresses, ManageKnowledge, ManageKnowledgeImportExport, ManageLeads, ManageLoginAccessPolicies, ManageMobile, ManageMobileAppSecurity, ManageNetworks, ManageOrchInstsAndWorkItems, ManagePackageLicenses, ManagePartners, ManagePasswordPolicies, ManageProfilesPermissionsets, ManagePropositions, ManagePvtRptsAndDashbds, ManageQuotas, ManageRecommendationStrategies, ManageReleaseUpdates, ManageRemoteAccess, ManageReportsInPubFolders, ManageRoles, ManageSandboxes, ManageSearchPromotionRules, ManageSharing, ManageSolutions, ManageSubscriptions, ManageSynonyms, ManageTrustMeasures, ManageUnlistedGroups, ManageUsers, MassInlineEdit, MergeTopics, ModerateChatter, ModifyAllData, ModifyAllPolicyCenterPolicies, ModifyDataClassification, ModifyMetadata, MonitorLoginHistory, NewReportBuilder, OutboundMigrationToolsUser, OverrideForecasts, Packaging2, Packaging2Delete, Packaging2PromoteVersion, PipelineInspectorUser, PrivacyDataAccess, PublishArticles, PublishPackaging, PublishTranslation, RemoveDirectMessageMembers, ResetPasswords, RunReports, ScheduleJob, ScheduleReports, SelectFilesFromSalesforce, SendCustomNotifications, SendSitRequests, ShareFilesWithNetworks, ShareInternalArticles, ShowCompanyNameAsUserBadge, SolutionImport, SubmitForTranslation, SubmitMacrosAllowed, SubscribeDashboardRolesGrps, SubscribeDashboardToOtherUsers, SubscribeReportRolesGrps, SubscribeReportToOtherUsers, SubscribeReportsRunAsUser, SubscribeToLightningDashboards, SubscribeToLightningReports, TerritoryOperations, TransactionalEmailSend, TransferAnyCase, TransferAnyEntity, TransferAnyLead, UseTeamReassignWizards, UseWebLink, ViewAllData, ViewAllForecasts, ViewAllPolicyCenterPolicies, ViewAllProfiles, ViewAllUsers, ViewArchivedArticles, ViewClientSecret, ViewContentTaxonomy, ViewDataAssessment, ViewDataCategories, ViewDeveloperName, ViewDraftArticles, ViewEventLogFiles, ViewFlowUsageAndFlowEventData, ViewHealthCheck, ViewHelpLink, ViewMLModels, ViewMyTeamsDashboards, ViewPublicDashboards, ViewPublicReports, ViewRoles, ViewSALifecycle, ViewSetup, ViewTrustMeasures, ViewUserPII

---

## Analytics Cloud Integration User.profile.xml
- **License:** Analytics Cloud Integration User
- **App Access:**
  - **Visible:** standard__Platform (default)
  - **Not Visible:** AMC, BSL_Service, BSL_Service_Console, BlueStar_Training, BlueStar_Trainings, Sales, Technician_Onboarding, standard__AllTabSet, standard__Approvals, standard__Chatter, standard__Community, standard__DataManager, standard__ExpressionSetConsole, standard__FlowsApp, standard__Insights, standard__LightningBolt, standard__LightningInstrumentation, standard__LightningSales, standard__LightningSalesConsole, standard__LightningService, standard__MSJApp, standard__Marketing, standard__OnlineSales, standard__Optimizer, standard__Sales, standard__SalesCloudMobile, standard__SalesforceCMS, standard__Service, standard__ServiceConsole
- **Object Access (Tab Visibility):**
  - **DefaultOn:** Audit_Inventory__c, BS360__c, Daily_Job_Documents__c, Order_Management1, Smart_AC_Model__c, sbaa__Approval__c
  - **DefaultOff:** Attendance__c
  - **Hidden:** Most other tabs/objects (see XML for full list)
- **Record Type Access:**
  - **Visible:** Knowledge__kav.FAQ, Knowledge__kav.Procedure, Quote_Line_Migration__c.Contract_Line_Item, Quote_Line_Migration__c.Quote_Line_Item_CPQ, Quote_Line_Migration__c.Quote_Line_Item_Sales
  - **Not Visible:** Most other record types (see XML for full list)
- **LWC, Visualforce, Apex Access:** Not specified in the provided XML.
- **User Permissions:**
  - ActivitiesAccess, AddDirectMessageMembers, AllowViewKnowledge, ApexRestServices, ApiEnabled, ApiUserOnly, CampaignInfluence2, ClauseUser, DocGenRuntimeUser, FieldServiceAccess, InsightsAppAdmin, InsightsAppUser, ObligationUser, PasswordNeverExpires, PipelineInspectorUser, QueryAllFiles, RecordVisibilityAPI, RemoveDirectMessageMembers, RunReports, UseWebLink, ViewAllData, ViewAllForecasts, ViewAllProfiles, ViewAllUsers, ViewDeveloperName, ViewDraftArticles, ViewEventLogFiles, ViewPublicDashboards, ViewPublicReports, ViewRoles, ViewSetup

---

## Analytics Cloud Security User.profile.xml
- **License:** Analytics Cloud Integration User
- **App Access:**
  - **Visible:** standard__Platform (default)
  - **Not Visible:** AMC, BSL_Service, BSL_Service_Console, BlueStar_Training, BlueStar_Trainings, Sales, Technician_Onboarding, standard__AllTabSet, standard__Approvals, standard__Chatter, standard__Community, standard__DataManager, standard__ExpressionSetConsole, standard__FlowsApp, standard__Insights, standard__LightningBolt, standard__LightningInstrumentation, standard__LightningSales, standard__LightningSalesConsole, standard__LightningService, standard__MSJApp, standard__Marketing, standard__OnlineSales, standard__Optimizer, standard__Sales, standard__SalesCloudMobile, standard__SalesforceCMS, standard__Service, standard__ServiceConsole
- **Object Access (Tab Visibility):**
  - **DefaultOn:** Audit_Inventory__c, BS360__c, Daily_Job_Documents__c, Order_Management1, Smart_AC_Model__c, sbaa__Approval__c
  - **DefaultOff:** Attendance__c
  - **Hidden:** Most other tabs/objects (see XML for full list)
- **Record Type Access:**
  - **Visible:** Knowledge__kav.FAQ, Knowledge__kav.Procedure, Quote_Line_Migration__c.Contract_Line_Item, Quote_Line_Migration__c.Quote_Line_Item_CPQ, Quote_Line_Migration__c.Quote_Line_Item_Sales
  - **Not Visible:** Most other record types (see XML for full list)
- **LWC, Visualforce, Apex Access:** Not specified in the provided XML.
- **User Permissions:**
  - AddDirectMessageMembers, ApexRestServices, ApiEnabled, ApiUserOnly, CampaignInfluence2, ClauseUser, DocGenRuntimeUser, FieldServiceAccess, InsightsAppAdmin, InsightsAppUser, ObligationUser, PasswordNeverExpires, PipelineInspectorUser, RemoveDirectMessageMembers, UseWebLink, ViewAllProfiles, ViewAllUsers, ViewDeveloperName, ViewDraftArticles, ViewEventLogFiles, ViewRoles, ViewSetup

---

## Anypoint Integration.profile.xml
- **License:** Not specified in the provided XML (review XML for details if needed)
- **App Access:**
  - **Visible:** Not specified in the provided XML
  - **Not Visible:** Not specified in the provided XML
- **Object Access (Tab Visibility):**
  - Not specified in the provided XML
- **Record Type Access:**
  - Not specified in the provided XML
- **LWC, Visualforce, Apex Access:** Not specified in the provided XML
- **User Permissions:**
  - Not specified in the provided XML

*For Anypoint Integration.profile.xml, please review the XML for more details if required, as the attached content did not include the full XML structure.* 