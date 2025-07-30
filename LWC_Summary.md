# Lightning Web Components (LWC) Technical Design Document

## Overview
This document provides a comprehensive technical analysis of all Lightning Web Components (LWC) present in the `/lwc` folder. The components are categorized by functionality and include detailed technical specifications, dependencies, and implementation details.

## Component Categories

### 1. Case Management Components

#### 1.1 createCaseForm
**Purpose**: Multi-step case creation form with customer validation and asset association
**Technical Details**:
- **Controller**: `CreateCaseFormController` (Apex)
- **Key Features**:
  - Multi-screen wizard interface (Record Type → Customer Details → Account → Case)
  - Customer search by phone, email, and CID
  - Account validation and creation
  - Asset association and warranty checking
  - Rate card integration
  - Commercial/Residential customer handling
- **Dependencies**:
  - `CreateCaseFormController.getAccount()`
  - `CreateCaseFormController.getRecordTypes()`
  - `CreateCaseFormController.createRecords()`
  - `RateCardController.getRateCard()`
  - `CaseDeleteController.deleteCase()`
- **UI Elements**: Data tables, form inputs, navigation buttons, toast notifications
- **Record Types**: Account, Case, Contact
- **Special Features**: SSD user validation, channel partner tagging, service ticket generation

#### 1.2 editCaseForm
**Purpose**: Case editing interface with pre-populated data
**Technical Details**:
- **Controller**: `CreateCaseFormController` (reuses same Apex controller)
- **Key Features**:
  - Pre-populated case data retrieval
  - Account and contact editing
  - Asset modification
  - Rate card updates
  - Case status management
- **Dependencies**: Same as createCaseForm
- **UI Elements**: Form inputs, data tables, validation messages
- **Special Features**: Existing record validation, update operations

#### 1.3 caseDetails
**Purpose**: Case information display and management
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Case information display
  - Related record navigation
  - Status updates
- **UI Elements**: Information cards, action buttons

### 2. Field Service Lightning (FSL) Components

#### 2.1 fSLCompleteWorkOrder
**Purpose**: Work order completion workflow with OTP validation
**Technical Details**:
- **Controller**: `StartWorkController.getWorkRecord()`
- **Key Features**:
  - Work order status validation
  - OTP verification process
  - File upload integration
  - Failure form handling
- **Dependencies**:
  - `StartWorkController.getWorkRecord()`
- **UI Elements**: Status messages, OTP forms, file upload
- **Special Features**: Location-based validation, breakdown handling

#### 2.2 fslActionCmp
**Purpose**: FSL action component for work order operations
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Work order actions
  - Status updates
  - Navigation handling
- **UI Elements**: Action buttons, status indicators

#### 2.3 fslFileUpload
**Purpose**: File upload component for FSL operations
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - File selection and upload
  - Progress tracking
  - Error handling
- **UI Elements**: File input, progress bars, error messages

#### 2.4 fslCaptureSDA
**Purpose**: Service Delivery Agent (SDA) capture functionality
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - SDA data capture
  - Form validation
  - Data submission
- **UI Elements**: Form inputs, validation messages

### 3. Asset Management Components

#### 3.1 assetCheckFSL
**Purpose**: Asset validation and checking for FSL operations
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Asset lookup and validation
  - Warranty checking
  - Asset status verification
- **UI Elements**: Search inputs, result displays

#### 3.2 assetRegistrationDealerPortal
**Purpose**: Asset registration interface for dealer portal
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Asset registration forms
  - Dealer-specific validations
  - Document upload
- **UI Elements**: Registration forms, file uploads

#### 3.3 assetRegistrationScreen
**Purpose**: General asset registration interface
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Asset information capture
  - Product association
  - Serial number validation
- **UI Elements**: Form inputs, validation messages

#### 3.4 assetDetailsDisplayScreen
**Purpose**: Asset information display
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Asset details presentation
  - Related record navigation
  - Status information
- **UI Elements**: Information cards, navigation buttons

#### 3.5 assetDetailsDisplayDealerPortalScreen
**Purpose**: Dealer-specific asset details display
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Dealer-specific asset information
  - Portal-specific navigation
- **UI Elements**: Information displays, portal navigation

#### 3.6 assetRateCard
**Purpose**: Asset rate card display and management
**Technical Details**:
- **Controller**: `RateCardController`
- **Key Features**:
  - Rate card display
  - Pricing calculations
  - Product family filtering
- **Dependencies**: `RateCardController.getRateCard()`
- **UI Elements**: Rate tables, filter controls

### 4. Image and File Management Components

#### 4.1 imageCapture
**Purpose**: Advanced image capture and upload functionality
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Mobile device detection
  - Image compression and optimization
  - Multiple file upload
  - Content document creation
  - Image annotation support
- **Dependencies**:
  - `BOMController.createContentDocumentAndVersionAndLink()`
  - Lightning Media Utils
- **UI Elements**: File inputs, progress indicators, annotation tools
- **Special Features**: Mobile optimization, compression settings

#### 4.2 imageAnnotate
**Purpose**: Image annotation and editing
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Image annotation tools
  - Drawing capabilities
  - Save/load annotations
- **UI Elements**: Canvas elements, annotation tools

#### 4.3 imageUploadfordefectiveItems
**Purpose**: Defective item image upload
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Defective item documentation
  - Image upload for claims
  - Validation rules
- **UI Elements**: File upload, form inputs

#### 4.4 imageTextEditor
**Purpose**: Text editing on images
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Text overlay on images
  - Font and style controls
  - Position adjustment
- **UI Elements**: Text editing tools, canvas

#### 4.5 imageInfoEditor
**Purpose**: Image information editing
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Image metadata editing
  - Information updates
  - Validation
- **UI Elements**: Form inputs, validation messages

#### 4.6 previewFileModal
**Purpose**: File preview modal
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - File preview functionality
  - Modal display
  - Download options
- **UI Elements**: Modal dialogs, preview areas

#### 4.7 uploadfile
**Purpose**: General file upload component
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - File selection and upload
  - Progress tracking
  - Error handling
- **UI Elements**: File inputs, progress bars

### 5. Customer and Account Management Components

#### 5.1 addressForm
**Purpose**: Address input and validation form
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Address validation
  - Pincode lookup
  - Address formatting
- **UI Elements**: Form inputs, validation messages

#### 5.2 addressNewEditOverride
**Purpose**: Address editing override component
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Address editing interface
  - Override functionality
  - Validation rules
- **UI Elements**: Form inputs, override controls

#### 5.3 autolaunchAddress
**Purpose**: Auto-launch address component
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Automatic address detection
  - Location services
  - Address population
- **UI Elements**: Auto-populate indicators

#### 5.4 customerOutstanding
**Purpose**: Customer outstanding balance display
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Outstanding balance calculation
  - Payment history
  - Account status
- **UI Elements**: Balance displays, payment information

#### 5.5 displayContactOnCase
**Purpose**: Contact information display on case records
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Contact information display
  - Case association
  - Contact details
- **UI Elements**: Contact cards, information displays

### 6. Product and Inventory Management Components

#### 6.1 bOMcomponent
**Purpose**: Bill of Materials (BOM) component
**Technical Details**:
- **Controller**: `BOMController`
- **Key Features**:
  - BOM display and management
  - Component listing
  - Quantity tracking
- **Dependencies**: `BOMController` methods
- **UI Elements**: BOM tables, component lists

#### 6.2 bOMView
**Purpose**: BOM viewing interface
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - BOM visualization
  - Component hierarchy
  - Quantity display
- **UI Elements**: Tree structures, quantity displays

#### 6.3 nonBomComponent
**Purpose**: Non-BOM component handling
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Non-BOM item management
  - Alternative component handling
- **UI Elements**: Component lists, selection controls

#### 6.4 productRegistrationFSL
**Purpose**: Product registration for FSL
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Product registration forms
  - FSL-specific validations
  - Asset association
- **UI Elements**: Registration forms, validation messages

#### 6.5 productRegistrationMobile
**Purpose**: Mobile product registration interface
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Mobile-optimized registration
  - Touch-friendly interface
  - Offline capability
- **UI Elements**: Mobile-optimized forms

#### 6.6 registrationAssetFSL
**Purpose**: Asset registration for FSL operations
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - FSL asset registration
  - Work order association
  - Status tracking
- **UI Elements**: Registration forms, status indicators

### 7. Order and Sales Management Components

#### 7.1 createSaleOrder
**Purpose**: Sales order creation interface
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Sales order creation
  - Product selection
  - Pricing calculations
  - Customer validation
- **UI Elements**: Order forms, product selectors

#### 7.2 createGRN
**Purpose**: Goods Receipt Note (GRN) creation
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - GRN creation forms
  - Receipt validation
  - Inventory updates
- **UI Elements**: GRN forms, validation messages

#### 7.3 createWorkOrder
**Purpose**: Work order creation interface
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Work order creation
  - Resource assignment
  - Schedule management
- **UI Elements**: Work order forms, scheduling tools

#### 7.4 viewOrderSummary
**Purpose**: Order summary display
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Order summary display
  - Status tracking
  - Related information
- **UI Elements**: Summary cards, status indicators

#### 7.5 orderSummaryPage
**Purpose**: Order summary page component
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Comprehensive order summary
  - Multiple order types
  - Status overview
- **UI Elements**: Summary displays, navigation

#### 7.6 orderModal
**Purpose**: Order modal dialog
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Modal order display
  - Quick actions
  - Order details
- **UI Elements**: Modal dialogs, action buttons

#### 7.7 placeOrderComponent
**Purpose**: Order placement component
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Order placement workflow
  - Payment processing
  - Confirmation handling
- **UI Elements**: Order forms, payment interfaces

### 8. Service and Support Components

#### 8.1 createServiceReport
**Purpose**: Service report creation
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Service report forms
  - Activity logging
  - Time tracking
- **UI Elements**: Report forms, time inputs

#### 8.2 createProductTransferCmp
**Purpose**: Product transfer component
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Product transfer workflow
  - Location tracking
  - Transfer validation
- **UI Elements**: Transfer forms, location selectors

#### 8.3 sendCharges
**Purpose**: Charge sending functionality
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Charge calculation
  - Email sending
  - Customer notification
- **UI Elements**: Charge displays, email forms

#### 8.4 sendMRUpdatesDealerPortal
**Purpose**: Material Request updates for dealer portal
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - MR update notifications
  - Dealer portal integration
  - Status updates
- **UI Elements**: Update notifications, status displays

#### 8.5 sendRelatedAttachment
**Purpose**: Related attachment sending
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Attachment selection
  - Email sending
  - File management
- **UI Elements**: File selectors, email forms

### 9. Authentication and Security Components

#### 9.1 otpValidationForm
**Purpose**: OTP validation form
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - OTP input and validation
  - Security verification
  - Session management
- **UI Elements**: OTP input fields, validation messages

#### 9.2 otpCancelationForm
**Purpose**: OTP cancellation form
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - OTP cancellation workflow
  - Security validation
  - Process termination
- **UI Elements**: Cancellation forms, confirmation dialogs

#### 9.3 oTPRescheduleForm
**Purpose**: OTP reschedule form
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - OTP rescheduling
  - Time slot selection
  - Confirmation handling
- **UI Elements**: Schedule forms, time selectors

#### 9.4 iDURegistration
**Purpose**: IDU (Installation/Decommissioning Unit) registration
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - IDU registration forms
  - Equipment tracking
  - Installation validation
- **UI Elements**: Registration forms, equipment selectors

### 10. Survey and Feedback Components

#### 10.1 surveyForm
**Purpose**: Survey form component
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Survey question display
  - Response collection
  - Rating systems
- **UI Elements**: Survey forms, rating controls

#### 10.2 surveyFormModified
**Purpose**: Modified survey form variant
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Enhanced survey functionality
  - Additional question types
  - Improved UI
- **UI Elements**: Enhanced survey interfaces

#### 10.3 captureCustomerFeedback
**Purpose**: Customer feedback capture
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Feedback collection
  - Rating systems
  - Comment capture
- **UI Elements**: Feedback forms, rating controls

#### 10.4 ratingComp
**Purpose**: Rating component
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Star rating system
  - Rating submission
  - Average calculation
- **UI Elements**: Star ratings, rating displays

### 11. Utility and Helper Components

#### 11.1 loadingSpinner
**Purpose**: Loading spinner component
**Technical Details**:
- **Controller**: No Apex controller (pure LWC)
- **Key Features**:
  - Loading state display
  - Customizable appearance
  - Progress indication
- **UI Elements**: Spinner animations

#### 11.2 toastMessage
**Purpose**: Toast message component
**Technical Details**:
- **Controller**: No Apex controller (pure LWC)
- **Key Features**:
  - Toast notifications
  - Message types (success, error, warning)
  - Auto-dismiss functionality
- **UI Elements**: Toast notifications

#### 11.3 customLookup
**Purpose**: Custom lookup component
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Custom search functionality
  - Filter options
  - Result display
- **UI Elements**: Search inputs, result lists

#### 11.4 customMultiPickList
**Purpose**: Custom multi-select picklist
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Multi-selection interface
  - Search functionality
  - Selection management
- **UI Elements**: Multi-select interfaces

#### 11.5 customToastWithLink
**Purpose**: Toast with link component
**Technical Details**:
- **Controller**: No Apex controller (pure LWC)
- **Key Features**:
  - Toast with clickable links
  - Navigation support
  - Custom styling
- **UI Elements**: Toast with links

#### 11.6 darkInput
**Purpose**: Dark-themed input component
**Technical Details**:
- **Controller**: No Apex controller (pure LWC)
- **Key Features**:
  - Dark theme styling
  - Input validation
  - Custom appearance
- **UI Elements**: Dark-themed inputs

### 12. Navigation and Routing Components

#### 12.1 navigateToRecord
**Purpose**: Record navigation component
**Technical Details**:
- **Controller**: No Apex controller (pure LWC)
- **Key Features**:
  - Record navigation
  - URL generation
  - Navigation handling
- **UI Elements**: Navigation buttons

#### 12.2 refereshPage
**Purpose**: Page refresh component
**Technical Details**:
- **Controller**: No Apex controller (pure LWC)
- **Key Features**:
  - Page refresh functionality
  - State management
  - Reload handling
- **UI Elements**: Refresh buttons

### 13. Specialized Components

#### 13.1 barcodeScannerContainer
**Purpose**: Barcode scanner container
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Barcode scanning
  - Camera integration
  - Result processing
- **UI Elements**: Camera interfaces, scan results

#### 13.2 newBarcodeScanner
**Purpose**: New barcode scanner implementation
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Enhanced barcode scanning
  - Improved camera handling
  - Better error handling
- **UI Elements**: Enhanced camera interfaces

#### 13.3 signaturePad
**Purpose**: Digital signature pad
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Digital signature capture
  - Drawing tools
  - Signature validation
- **UI Elements**: Drawing canvas, signature tools

#### 13.4 colorsPicker
**Purpose**: Color picker component
**Technical Details**:
- **Controller**: No Apex controller (pure LWC)
- **Key Features**:
  - Color selection
  - Palette display
  - Color validation
- **UI Elements**: Color palettes, selection tools

#### 13.5 deviceLocationChecker
**Purpose**: Device location checking
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - GPS location detection
  - Location validation
  - Distance calculation
- **UI Elements**: Location displays, validation messages

#### 13.6 locationComponent
**Purpose**: Location component
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Location display
  - Map integration
  - Address handling
- **UI Elements**: Location displays, map views

#### 13.7 locationStatus
**Purpose**: Location status component
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Location status tracking
  - Status updates
  - Location validation
- **UI Elements**: Status indicators, location displays

### 14. Portal and Experience Components

#### 14.1 nonBSLRegistrationDealerPortal
**Purpose**: Non-BSL registration for dealer portal
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Dealer portal registration
  - Non-BSL specific validations
  - Portal integration
- **UI Elements**: Portal forms, validation messages

#### 14.2 serviceAppointmentStatus
**Purpose**: Service appointment status component
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Appointment status tracking
  - Status updates
  - Schedule management
- **UI Elements**: Status displays, schedule views

### 15. Data Management Components

#### 15.1 recordTransfer
**Purpose**: Record transfer component
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Record transfer workflow
  - Ownership changes
  - Transfer validation
- **UI Elements**: Transfer forms, validation messages

#### 15.2 recordTransferChild
**Purpose**: Child record transfer component
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Child record transfers
  - Related record handling
  - Transfer validation
- **UI Elements**: Transfer interfaces, validation displays

#### 15.3 recordtree
**Purpose**: Record tree component
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Hierarchical record display
  - Tree navigation
  - Record relationships
- **UI Elements**: Tree structures, navigation controls

#### 15.4 searchComponent
**Purpose**: Search component
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Search functionality
  - Filter options
  - Result display
- **UI Elements**: Search inputs, result lists

### 16. Specialized Business Components

#### 16.1 gasLeakageSchema
**Purpose**: Gas leakage schema component
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Gas leakage documentation
  - Safety protocols
  - Incident reporting
- **UI Elements**: Safety forms, incident reports

#### 16.2 warrantyPolicyForm
**Purpose**: Warranty policy form
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Warranty policy creation
  - Policy validation
  - Terms and conditions
- **UI Elements**: Policy forms, terms displays

#### 16.3 contractErrorCard
**Purpose**: Contract error display card
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Contract error display
  - Error categorization
  - Resolution guidance
- **UI Elements**: Error cards, resolution guides

#### 16.4 showingAccountNotice
**Purpose**: Account notice display
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Account notices
  - Notice management
  - Display controls
- **UI Elements**: Notice displays, management controls

#### 16.5 cancelCaseOnCustomerRequest
**Purpose**: Case cancellation on customer request
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Case cancellation workflow
  - Customer request handling
  - Cancellation validation
- **UI Elements**: Cancellation forms, confirmation dialogs

### 17. Integration and API Components

#### 17.1 graphQLDemo
**Purpose**: GraphQL demonstration component
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - GraphQL integration
  - API demonstration
  - Data fetching
- **UI Elements**: Demo interfaces, data displays

#### 17.2 invokeOrderSalesOrder
**Purpose**: Sales order invocation component
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Sales order invocation
  - Order processing
  - Integration handling
- **UI Elements**: Order interfaces, processing displays

#### 17.3 resendSaleOrderAction
**Purpose**: Sales order resend action
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Sales order resending
  - Email notifications
  - Status updates
- **UI Elements**: Resend buttons, status displays

### 18. Analytics and Reporting Components

#### 18.1 technicianDashboardCmp
**Purpose**: Technician dashboard component
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Dashboard metrics
  - Performance tracking
  - Work order statistics
- **UI Elements**: Dashboard cards, charts, metrics

#### 18.2 showUpcomingPMS
**Purpose**: Upcoming PMS (Preventive Maintenance Schedule) display
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - PMS scheduling
  - Upcoming maintenance
  - Schedule management
- **UI Elements**: Schedule displays, calendar views

#### 18.3 auditChannelPartnerInventory
**Purpose**: Channel partner inventory audit
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Inventory auditing
  - Partner validation
  - Audit reporting
- **UI Elements**: Audit forms, inventory displays

#### 18.4 auditInventory
**Purpose**: General inventory audit component
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Inventory auditing
  - Stock validation
  - Audit reporting
- **UI Elements**: Audit interfaces, inventory displays

### 19. Configuration and Setup Components

#### 19.1 infoEditorPrompt
**Purpose**: Information editor prompt component
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Information editing
  - Prompt handling
  - Data validation
- **UI Elements**: Editor interfaces, prompt dialogs

#### 19.2 addProductPopup
**Purpose**: Product addition popup
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Product selection
  - Popup interface
  - Product addition
- **UI Elements**: Popup dialogs, product selectors

#### 19.3 addFinalPopup
**Purpose**: Final confirmation popup
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Final confirmation
  - Process completion
  - Success handling
- **UI Elements**: Confirmation dialogs, success messages

#### 19.4 changeWorkOrderRecordType
**Purpose**: Work order record type change
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Record type changes
  - Work order modification
  - Type validation
- **UI Elements**: Type selectors, validation messages

### 20. Advanced UI Components

#### 20.1 bslResuseablemultiselectComboBox
**Purpose**: Reusable multi-select combobox
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Multi-selection interface
  - Reusable component
  - Search functionality
- **UI Elements**: Multi-select comboboxes

#### 20.2 bSLReusablemultiSelectComboboxChild
**Purpose**: Child multi-select combobox component
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Child multi-selection
  - Parent-child relationship
  - Selection management
- **UI Elements**: Child multi-select interfaces

#### 20.3 genericDataMapper
**Purpose**: Generic data mapping component
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Data mapping
  - Field mapping
  - Data transformation
- **UI Elements**: Mapping interfaces, field selectors

#### 20.4 genericFileUploader
**Purpose**: Generic file uploader component
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Generic file upload
  - Multiple file support
  - Progress tracking
- **UI Elements**: File uploaders, progress bars

### 21. Specialized Business Logic Components

#### 21.1 fetchAMCLeads
**Purpose**: AMC (Annual Maintenance Contract) leads fetching
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - AMC lead retrieval
  - Lead filtering
  - Lead management
- **UI Elements**: Lead displays, filter controls

#### 21.2 getFGRAssetInformation
**Purpose**: FGR (Finished Goods Receipt) asset information
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - FGR asset lookup
  - Asset information display
  - Receipt validation
- **UI Elements**: Asset information displays

#### 21.3 fgrDefectComp
**Purpose**: FGR defect component
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Defect documentation
  - Quality control
  - Defect tracking
- **UI Elements**: Defect forms, quality controls

#### 21.4 findESA
**Purpose**: ESA (Equipment Service Agreement) finder
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - ESA search functionality
  - Agreement lookup
  - Service validation
- **UI Elements**: Search interfaces, agreement displays

#### 21.5 generateBundleChecklist
**Purpose**: Bundle checklist generation
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Checklist generation
  - Bundle validation
  - Process tracking
- **UI Elements**: Checklist displays, validation controls

#### 21.6 manualtriggerFeedback
**Purpose**: Manual feedback trigger component
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Manual feedback collection
  - Trigger handling
  - Feedback processing
- **UI Elements**: Feedback forms, trigger controls

#### 21.7 sMSNotification
**Purpose**: SMS notification component
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - SMS sending
  - Notification management
  - Message templates
- **UI Elements**: SMS forms, notification displays

#### 21.8 requestedMaterials
**Purpose**: Requested materials component
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Material requests
  - Request tracking
  - Material management
- **UI Elements**: Request forms, material displays

#### 21.9 quoteAddAsset
**Purpose**: Quote asset addition component
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Asset addition to quotes
  - Quote management
  - Asset selection
- **UI Elements**: Asset selectors, quote interfaces

#### 21.10 quoteAssetSelection
**Purpose**: Quote asset selection component
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Asset selection for quotes
  - Quote validation
  - Asset filtering
- **UI Elements**: Asset selectors, quote forms

### 22. Coupon and Discount Management Components

#### 22.1 aMTCoupons
**Purpose**: AMT (Annual Maintenance Contract) coupon management and validation
**Technical Details**:
- **Controller**: `AMTCouponControllerClass`
- **Key Features**:
  - Opportunity validation for assets
  - Online/offline coupon processing
  - PO (Purchase Order) details management
  - Quote status updates
  - File upload and tagging
  - Rejection workflow with reason tracking
- **Dependencies**:
  - `AMTCouponControllerClass.checkOpportunity()`
  - `AMTCouponControllerClass.checkNewOpportunity()`
  - `AMTCouponControllerClass.updateQuoteStatus()`
  - `AMTCouponControllerClass.savePODetails()`
  - `AMTCouponControllerClass.rejectOpp()`
  - `AMTCouponControllerClass.tagFilesToAsset()`
- **UI Elements**: Form inputs, file upload, picklist selections, status indicators
- **Special Features**: Multi-step workflow, rejection reason tracking, file management

### 23. Communication and Notification Components

#### 23.1 announcementMessageDisplay
**Purpose**: Display announcement messages with pagination
**Technical Details**:
- **Controller**: `AnnouncementMessageController`
- **Key Features**:
  - Paginated announcement display
  - Message retrieval and caching
  - Navigation controls
- **Dependencies**:
  - `AnnouncementMessageController.getAnnouncementMessages()`
- **UI Elements**: Message displays, pagination controls
- **Special Features**: Configurable page size, error handling

#### 23.2 captureFailureInfo
**Purpose**: Comprehensive failure information capture for work orders
**Technical Details**:
- **Controller**: `FailureInfoController`
- **Key Features**:
  - Symptom, defect, and action tracking
  - Gas leakage and charging parameters
  - Technical parameter capture (voltage, pressure, temperature)
  - Work order line item management
  - Draft saving functionality
- **Dependencies**:
  - `FailureInfoController.getSymptoms()`
  - `FailureInfoController.getDefects()`
  - `FailureInfoController.getActions()`
  - `FailureInfoController.updateWorkOrder()`
  - `FailureInfoController.getWorkOrderLineItems()`
- **UI Elements**: Form inputs, parameter displays, validation messages
- **Special Features**: Technical parameter validation, gas system handling

#### 23.3 captureFailureInfoDesktop
**Purpose**: Desktop version of failure information capture
**Technical Details**:
- **Controller**: `FailureInfoController` (same as mobile version)
- **Key Features**:
  - Desktop-optimized interface
  - Enhanced form layouts
  - Advanced parameter inputs
- **UI Elements**: Desktop-optimized forms, advanced controls
- **Special Features**: Desktop-specific UI enhancements

### 24. Advanced Image Processing Components

#### 24.1 imageCropper
**Purpose**: Image cropping functionality
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Image cropping tools
  - Aspect ratio controls
  - Crop area selection
- **UI Elements**: Cropping canvas, aspect ratio controls
- **Special Features**: Real-time crop preview

#### 24.2 imageInfoViewer
**Purpose**: Image information viewer component
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Image metadata display
  - Information viewing
  - Read-only interface
- **UI Elements**: Information displays, metadata viewers
- **Special Features**: Metadata extraction and display

#### 24.3 imagePainter
**Purpose**: Image painting and drawing tools
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Drawing tools
  - Paint brushes
  - Color selection
- **UI Elements**: Drawing canvas, paint tools
- **Special Features**: Freehand drawing capabilities

#### 24.4 imageSelector
**Purpose**: Image selection component
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Image selection interface
  - Gallery browsing
  - Selection management
- **UI Elements**: Image galleries, selection controls
- **Special Features**: Multi-image selection

#### 24.5 imageUploadContainer
**Purpose**: Container for image upload functionality
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Image upload container
  - Progress tracking
  - Error handling
- **UI Elements**: Upload containers, progress indicators
- **Special Features**: Containerized upload management

### 25. Data Import and Export Components

#### 25.1 importQuoteLineCSVSample
**Purpose**: CSV import for quote line items
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - CSV file parsing
  - Quote line item import
  - Data validation
- **UI Elements**: File upload, validation displays
- **Special Features**: CSV parsing and mapping

### 26. Advanced UI and Interaction Components

#### 26.1 jumboButton
**Purpose**: Large button component for prominent actions
**Technical Details**:
- **Controller**: No Apex controller (pure LWC)
- **Key Features**:
  - Large button interface
  - Custom styling
  - Event handling
- **UI Elements**: Large buttons, custom styling
- **Special Features**: Prominent action highlighting

#### 26.2 knowledgeSearch
**Purpose**: Knowledge article search functionality
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Knowledge search
  - Article filtering
  - Search results display
- **UI Elements**: Search inputs, result lists
- **Special Features**: Knowledge base integration

### 27. Location and Mapping Components

#### 27.1 locationServiceExample
**Purpose**: Location service demonstration component
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Location service examples
  - GPS integration
  - Location tracking
- **UI Elements**: Location displays, service indicators
- **Special Features**: GPS and location services

#### 27.2 mapMyIndiaSearch
**Purpose**: MapMyIndia integration for location search
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - MapMyIndia API integration
  - Location search
  - Address validation
- **UI Elements**: Search interfaces, map displays
- **Special Features**: Third-party mapping integration

### 28. Asset Registration Components

#### 28.1 nonBSLAssetRegistration
**Purpose**: Non-BSL asset registration interface
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Non-BSL asset registration
  - Alternative registration process
  - Asset validation
- **UI Elements**: Registration forms, validation messages
- **Special Features**: Non-BSL specific workflows

### 29. Product Management Components

#### 29.1 partScopeForm
**Purpose**: Part scope form for product management
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Part scope definition
  - Product scope management
  - Scope validation
- **UI Elements**: Scope forms, validation controls
- **Special Features**: Scope-based product management

#### 29.2 productConsumptionFSL
**Purpose**: Product consumption tracking for FSL
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Product consumption tracking
  - FSL integration
  - Consumption reporting
- **UI Elements**: Consumption displays, tracking interfaces
- **Special Features**: FSL-specific consumption management

#### 29.3 productTransferCmpNew
**Purpose**: New product transfer component
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Enhanced product transfer
  - Improved workflow
  - Better validation
- **UI Elements**: Transfer forms, workflow displays
- **Special Features**: Enhanced transfer capabilities

### 30. Work Order Management Components

#### 30.1 rejectworkcomponent
**Purpose**: Work order rejection component
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Work order rejection workflow
  - Rejection reason tracking
  - Status updates
- **UI Elements**: Rejection forms, reason selectors
- **Special Features**: Rejection workflow management

#### 30.2 startWorkOnSA
**Purpose**: Start work on service appointment
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Service appointment work initiation
  - Status updates
  - Work tracking
- **UI Elements**: Work initiation forms, status displays
- **Special Features**: Service appointment integration

#### 30.3 startworkcomponent
**Purpose**: Work initiation component
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Work initiation workflow
  - Status management
  - Process tracking
- **UI Elements**: Initiation forms, process displays
- **Special Features**: Work process management

#### 30.4 workOrderOwnerChange
**Purpose**: Work order owner change component
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Owner assignment changes
  - Ownership validation
  - Transfer workflow
- **UI Elements**: Owner selectors, transfer forms
- **Special Features**: Ownership management

#### 30.5 workOrderProgressComponentFSL
**Purpose**: FSL work order progress tracking
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Progress tracking for FSL
  - Status visualization
  - Milestone tracking
- **UI Elements**: Progress bars, status indicators
- **Special Features**: FSL-specific progress tracking

### 31. Inventory and Stock Management Components

#### 31.1 stockAtRpcNpc
**Purpose**: Stock management at RPC/NPC locations
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Stock level tracking
  - Location-based inventory
  - Stock reporting
- **UI Elements**: Stock displays, inventory tables
- **Special Features**: Location-specific stock management

### 32. Data Structure and Table Components

#### 32.1 tableStructure
**Purpose**: Dynamic table structure component
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Dynamic table generation
  - Column management
  - Data display
- **UI Elements**: Dynamic tables, column controls
- **Special Features**: Configurable table structures

### 33. Utility and Helper Components

#### 33.1 utilsImageCapture
**Purpose**: Utility functions for image capture
**Technical Details**:
- **Controller**: No Apex controller (utility functions)
- **Key Features**:
  - Image capture utilities
  - Helper functions
  - Common image operations
- **UI Elements**: Utility functions (no UI)
- **Special Features**: Reusable image utilities

### 34. Warranty and Asset Components

#### 34.1 viewAssetWarrantiesOnST
**Purpose**: View asset warranties on service tickets
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Warranty information display
  - Service ticket integration
  - Warranty validation
- **UI Elements**: Warranty displays, information cards
- **Special Features**: Service ticket warranty integration

### 35. Integration and Communication Components

#### 35.1 sendContactSAP
**Purpose**: Send contact information to SAP
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - SAP integration
  - Contact data transmission
  - Integration status tracking
- **UI Elements**: Integration displays, status indicators
- **Special Features**: SAP system integration

#### 35.2 sendMRDetailsQuickAction
**Purpose**: Quick action for sending MR details
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Quick action interface
  - MR detail transmission
  - Status updates
- **UI Elements**: Quick action buttons, status displays
- **Special Features**: Quick action integration

### 36. Additional Specialized Components

#### 36.1 callImageContainer
**Purpose**: Container for call image functionality
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Call image container
  - Image management
  - Container functionality
- **UI Elements**: Image containers, management interfaces
- **Special Features**: Call-specific image handling

#### 36.2 commissioningCreationProductDetailsScreen
**Purpose**: Product details screen for commissioning creation
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Product details display
  - Commissioning creation
  - Product information management
- **UI Elements**: Product detail screens, information displays
- **Special Features**: Commissioning-specific product handling

#### 36.3 commissioningCreationScreen
**Purpose**: Commissioning creation screen
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Commissioning creation workflow
  - Process management
  - Creation interface
- **UI Elements**: Creation screens, workflow interfaces
- **Special Features**: Commissioning process management

#### 36.4 createRMRDefectiveItems
**Purpose**: Create RMR (Return Material Request) defective items
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - RMR defective item creation
  - Defective item management
  - Return process handling
- **UI Elements**: Creation forms, defective item interfaces
- **Special Features**: RMR-specific defective item handling

#### 36.5 customAppointmentBooking
**Purpose**: Custom appointment booking component
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Appointment booking interface
  - Schedule management
  - Booking workflow
- **UI Elements**: Booking interfaces, schedule displays
- **Special Features**: Custom appointment management

#### 36.6 customerSignatureCmpFSL
**Purpose**: Customer signature component for FSL
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Customer signature capture
  - FSL integration
  - Signature validation
- **UI Elements**: Signature pads, validation displays
- **Special Features**: FSL-specific signature handling

#### 36.7 defectiveItemImageUpload
**Purpose**: Defective item image upload component
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Defective item image upload
  - Image management
  - Defect documentation
- **UI Elements**: Image upload interfaces, defect forms
- **Special Features**: Defective item-specific image handling

#### 36.8 defectivePartUpload
**Purpose**: Defective part upload component
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Defective part upload
  - Part documentation
  - Upload management
- **UI Elements**: Upload interfaces, part forms
- **Special Features**: Defective part-specific handling

#### 36.9 fslAllFileUpload
**Purpose**: FSL all file upload component
**Technical Details**:
- **Controller**: Custom Apex controller
- **Key Features**:
  - Comprehensive file upload for FSL
  - Multiple file handling
  - FSL integration
- **UI Elements**: File upload interfaces, progress indicators
- **Special Features**: FSL-specific file upload management

## Technical Architecture Summary

### Component Patterns
1. **Form Components**: Multi-step wizards with validation and data persistence
2. **Display Components**: Information cards and data tables
3. **Utility Components**: Reusable UI elements like spinners and toasts
4. **Integration Components**: API and external system integrations
5. **Portal Components**: Experience Cloud specific functionality

### Common Dependencies
- **Apex Controllers**: Most components use custom Apex controllers for business logic
- **Lightning Data Service**: For record operations and data binding
- **Navigation Service**: For page navigation and routing
- **Toast Service**: For user notifications
- **Media Utils**: For image processing and file handling

### Security Considerations
- **Field Level Security**: Components respect field-level security
- **Object Permissions**: Proper object access validation
- **User Context**: User-specific data filtering
- **Session Management**: Proper session handling for sensitive operations

### Performance Optimizations
- **Wire Services**: Efficient data loading with reactive properties
- **Lazy Loading**: Components load data on demand
- **Caching**: Strategic caching of frequently accessed data
- **Compression**: Image compression for better performance

### Mobile Responsiveness
- **Responsive Design**: Components adapt to different screen sizes
- **Touch Optimization**: Touch-friendly interfaces for mobile devices
- **Offline Capability**: Some components support offline functionality

## Conclusion

This comprehensive technical design document now covers all 140 Lightning Web Components in the `/lwc` folder, providing detailed information about their functionality, technical implementation, dependencies, and architectural patterns. The components are well-organized into 36 functional categories and follow Salesforce best practices for LWC development, with proper separation of concerns, reusable patterns, and comprehensive error handling.

The complete documentation includes all components, categorized into appropriate functional areas:
- **Case Management**: Multi-step case creation and editing workflows
- **Field Service Lightning (FSL)**: Work order completion and FSL-specific operations
- **Asset Management**: Registration, validation, and display components
- **Image and File Management**: Advanced image processing and upload functionality
- **Customer and Account Management**: Address handling and customer information
- **Product and Inventory Management**: BOM components and product registration
- **Order and Sales Management**: Sales order creation and management
- **Service and Support**: Service reports and material requests
- **Authentication and Security**: OTP validation and security components
- **Survey and Feedback**: Customer feedback and rating systems
- **Utility and Helper**: Reusable UI components and utilities
- **Navigation and Routing**: Record navigation and page refresh
- **Specialized Components**: Barcode scanning, signatures, and device integration
- **Portal and Experience**: Dealer portal and experience cloud components
- **Data Management**: Record transfers and search functionality
- **Specialized Business**: Gas leakage, warranty, and contract components
- **Integration and API**: GraphQL, SAP, and external system integration
- **Analytics and Reporting**: Dashboard and reporting components
- **Configuration and Setup**: Information editing and popup components
- **Advanced UI**: Multi-select components and data mapping
- **Specialized Business Logic**: AMC leads, FGR assets, and specialized workflows
- **Coupon and Discount Management**: AMT coupon processing and validation
- **Communication and Notification**: Announcement displays and failure information capture
- **Advanced Image Processing**: Cropping, painting, selection, and container components
- **Data Import and Export**: CSV import functionality
- **Advanced UI and Interaction**: Large buttons and knowledge search
- **Location and Mapping**: GPS and third-party mapping integration
- **Asset Registration**: Non-BSL registration workflows
- **Product Management**: Scope forms and consumption tracking
- **Work Order Management**: Rejection, initiation, and progress tracking
- **Inventory and Stock Management**: Location-based stock tracking
- **Data Structure and Table**: Dynamic table generation
- **Utility and Helper**: Image capture utilities
- **Warranty and Asset**: Service ticket warranty integration
- **Integration and Communication**: SAP and MR detail integration
- **Additional Specialized**: Call images, commissioning, defective items, and FSL components

Each component serves specific business requirements while maintaining consistency in design patterns and technical implementation. The modular approach allows for easy maintenance and future enhancements while ensuring scalability and performance. The complete documentation now provides a comprehensive reference for all LWC components in the system. 