/* eslint-disable no-else-return */
/* eslint-disable @lwc/lwc/no-async-operation */
/* eslint-disable no-restricted-globals */
/* eslint-disable no-alert */
import { LightningElement, track, api } from 'lwc';
import { getLocationService } from 'lightning/mobileCapabilities';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningAlert from 'lightning/alert';
import getWorkOrderById from '@salesforce/apex/WorkOrderProgressComponentController.getWorkOrderById';
import updateWorkOrderStatus from '@salesforce/apex/WorkOrderProgressComponentController.updateWorkOrderStatus';
import captureLocationOnWO from '@salesforce/apex/WorkOrderProgressComponentController.captureLocationOnWO';
import completePMSWO from '@salesforce/apex/WorkOrderProgressComponentController.completePMSWO';
import updateWOPMS from '@salesforce/apex/WorkOrderProgressComponentController.updateWOPMS';
import getAssetDepartment from '@salesforce/apex/WorkOrderProgressComponentController.getAssetDepartment';
import getWOLICount from '@salesforce/apex/WorkOrderProgressComponentController.getWOLICount';
import checkWorkStepCompletion from '@salesforce/apex/WorkOrderProgressComponentController.checkWorkStepCompletion';


// Define a map for step names and their indices starting from 1
const STEP_INDEX_MAP = {
    'Start Ticket': 1,
    'Scan Asset': 2,
    'Reject Ticket': 3,
    'Capture Feedback': 4,
    'Complete Ticket': 5
};

export default class WorkOrderProgressComponentFSL extends LightningElement {
    @api recordId;

    @track isPMSTicket = false;

    @track showLocationModal = false;
    @track showProgressList = true;
    @track showWorkCompleted = false;
    @track showWorkCompletedbundle = false;
    @track scanAssetLabel;

    @track workOrder;

    @track currentLocation;
    @track latitude;
    @track longitude;

    @track NotInstallation = false;
    @track Installation = false;
    @track isPMS = false;
    @track isBulkPMS = false;
    @track isCommissioning = false;


    @track showSpinner = false;
    @track mainScreenVisibility = true;
    @track startWorkVisibility = false;
    @track cancelTicketVisibility = false;
    @track scanAssetVisibility = false;
    @track registerProductVisibility = false;
    @track rejectWorkVisibility = false;
    @track captureFeedbackVisibility = false;
    @track completeWorkOrderVisibility = false;
    @track createServiceReportVisibilty = false;
    @track captureSDAVisibility = false;
    @track captureImageUploadVisibility = false;
    @track uploadFilesVisiblity = false;


    @track isStepCancelTicketDisabled = false;
    @track isServiceReportGenarationDisabled = false;
    //@track isStepUploadImageDisabled = false;
    // @track isStepCaptureSDADisabled = false;

    @track statWorkDisable = false;

    @track activeStep = 1;
    @track nextStepName;

    // Internal component state
    myLocationService;
    @track currentLocation;
    locationButtonDisabled = false;
    @track showSpinner = true;

    //to track the current step
    @track currentStep;

    @track fileUploaded = false;
    @track assetScannedRegistered = false;


    async connectedCallback() {

        this.showSpinner = true;
        console.log('record Id - ', this.recordId);

        // Fetch the Work Order record
        await this.fetchWorkOrder();

        this.isMobileDevice = this.checkMobileDevice();

        if (this.isMobileDevice === true && this.showWorkCompleted === false) {
            this.myLocationService = getLocationService();
            this.showLocationModal = false;
            this.showProgressList = true;
            this.locationButtonDisabled = false;

            // Check the location status every 1 second
            this.locationCheckInterval = setInterval(this.checkLocationStatus.bind(this), 1000);

            // Optionally, check immediately on component load
            this.checkLocationStatus();

            console.log('locationButtonDisabled - ', this.locationButtonDisabled);

            // LightningAlert.open({
            //     message: 'locationButtonDisabled - ' + this.locationButtonDisabled,
            //     theme: 'success', // a red theme intended for error states
            //     label: 'Error!', // this is the header text
            // });
        }

    }

    checkMobileDevice() {
        const userAgent = navigator.userAgent;
        const mobileDeviceRegex = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i;
        return mobileDeviceRegex.test(userAgent);
    }

    fetchWorkOrder() {

        this.showSpinner = true;

        return getWorkOrderById({ recordId: this.recordId })
            .then(result => {
                this.workOrder = result;

                this.fileUploaded = this.workOrder.Is_File_Uploaded__c;
                this.assetScannedRegistered = this.workOrder.Is_Asset_Scanned_Added__c;

                console.log(' this.workOrder - ' + JSON.stringify(this.workOrder));
                if (this.workOrder.RecordType.Name === 'Installation') {
                    this.Installation = true;
                    this.NotInstallation = false;
                    this.isPMS = false
                    console.log('this.workOrder.WorkType.name - ' + this.Installation);

                }
                else if (this.workOrder.RecordType.Name === 'PMS') {
                    this.isPMS = true;
                    this.Installation = false;
                    this.NotInstallation = false;
                }
                else if (this.workOrder.RecordType.Name === 'Bulk PMS Checklist') {
                    this.isBulkPMS = true;

                    this.isPMS = false;
                    this.Installation = false;
                    this.NotInstallation = false;
                }
                else if (this.workOrder.RecordType.Name.includes('Commissioning')) {

                    this.isCommissioning = true;

                    this.isPMS = false;
                    this.Installation = false;
                    this.NotInstallation = false;

                }

                else {
                    this.NotInstallation = true;

                    this.isPMS = false;
                    this.Installation = false;
                    this.isBulkPMS = false;


                }

                this.updateUIBasedOnStatus();

                this.showSpinner = false;
                return this.workOrder;

            })
            .catch(error => {
                console.error('Error fetching work order:', error);
                this.showSpinner = false;

            });

    }


    updateUIBasedOnStatus() {


        // LightningAlert.open({
        //     message: 'status - ' + this.workOrder.Status ,
        //     theme: 'success', // a red theme intended for error states
        //     label: 'Status', // this is the header text
        // });

        if (this.workOrder.Status === 'New' || this.workOrder.Status === 'Accepted' || this.workOrder.Status === 'Allocated') {

            if (this.isBulkPMS === true) {
                if (this.workOrder.Is_Customer_Feedback_Captured__c === true) {
                    this.currentStep = 'complete-ticket';

                }
                else {
                    this.currentStep = 'capture-feedback';

                }

                // LightningAlert.open({
                //     message: 'currect step - ' + this.currentStep + '--' + this.isStepCaptureFeedbackDisabled,
                //     theme: 'success', // a red theme intended for error states
                //     label: 'step', // this is the header text
                // });
            }
            else if (this.isCommissioning === true) {
                if (this.workOrder.Is_Customer_Feedback_Captured__c === true) {
                    this.currentStep = 'complete-ticket';

                }
                else {
                    this.currentStep = 'start-ticket';

                }
            }
            else {
                this.currentStep = 'start-ticket';

            }
        } else if (this.workOrder.Status === 'In Progress' || this.workOrder.Status === 'On Hold' || this.workOrder.Status === 'Pending') {
            if (this.workOrder.Is_SDA_Captured__c === true && this.workOrder.Is_Customer_Feedback_Captured__c !== true) {

                // LightningAlert.open({
                //     message: 'sda captured - ' + this.workOrder.Is_SDA_Captured__c,
                //     theme: 'success', // a red theme intended for error states
                //     label: 'Status', // this is the header text
                // });

                this.currentStep = 'capture-feedback';

            }
            else if (this.workOrder.Is_Customer_Feedback_Captured__c === true) {

                // LightningAlert.open({
                //     message: 'feedback captured - ' + this.workOrder.Is_Customer_Feedback_Captured__c,
                //     theme: 'success', // a red theme intended for error states
                //     label: 'Status', // this is the header text
                // });

                this.currentStep = 'complete-ticket';
            }
            else if (this.isBulkPMS === true) {
                this.currentStep = 'capture-feedback';

            }
            else if (this.isCommissioning === true) {
                this.currentStep = 'scan-asset';

            }
            else {
                this.currentStep = 'scan-asset';

                // LightningAlert.open({
                //     message: 'current step else - ' + this.currentStep,
                //     theme: 'success', // a red theme intended for error states
                //     label: 'Status', // this is the header text
                // });


            }
            // this.currentStep = 'capture-feedback';


        } else if (this.workOrder.Status === 'Completed' && this.workOrder.Completed_as_Individual__c == false &&
            this.workOrder.RecordType.DeveloperName == 'PMS') {
            this.showWorkCompletedbundle = true;
            this.showProgressList = false;
            //this.currentStep = 'completed';
        } else if (this.workOrder.Status === 'Completed') {
            this.showWorkCompleted = true;
            this.showProgressList = false;
            //this.currentStep = 'completed';
        }



        // LightningAlert.open({
        //     message: 'current step - ' + this.currentStep,
        //     theme: 'success', // a red theme intended for error states
        //     label: 'Status', // this is the header text
        // });

        this.showSpinner = false;
    }


    async checkLocationStatus() {


        this.myLocationService = await getLocationService();


        if (this.myLocationService != null || this.myLocationService.isAvailable()) {

            this.myLocationService.getCurrentPosition({ enableHighAccuracy: true })
                .then((result) => {
                    // Location is available

                    //store the location
                    this.currentLocation = result;

                    this.latitude = result.coords.latitude;
                    this.longitude = result.coords.longitude;

                    //           LightningAlert.open({
                    //     message: 'my location - ' + this.currentLocation + 'lat - ' + this.latitude + 'long - '+ this.longitude,
                    //     theme: 'success', // a red theme intended for error states
                    //     label: 'Success!', // this is the header text
                    // });


                    this.showLocationModal = false;
                    this.showProgressList = true;

                    this.locationButtonDisabled = false;
                    console.log("Location service is now enabled!");

                    // Stop checking once the location is available
                    clearInterval(this.locationCheckInterval);
                })
                .catch((error) => {
                    // Location is not available or other errors
                    this.showLocationModal = true;
                    this.showProgressList = false;

                    this.locationButtonDisabled = true;
                });

        }
        else {

            this.showLocationModal = true;
            this.showProgressList = false;

            this.locationButtonDisabled = true;

            // LightningAlert.open({
            //     message: 'Location Service not available in this device',
            //     theme: 'error', // a red theme intended for error states
            //     label: 'Error!', // this is the header text
            // });


        }

    }

    closeModal() {
        this.showLocationModal = false;
    }


    classSet(baseClass) {
        const classes = new Set();
        if (baseClass) {
            classes.add(baseClass);
        }

        return {
            add(classMap) {
                for (const [cls, condition] of Object.entries(classMap)) {
                    if (condition) {
                        classes.add(cls);
                    }
                }
                return this;
            },
            toString() {
                return Array.from(classes).join(' ');
            },
        };
    }


    get startTicketClasses() {
        return this.classSet('slds-progress__item')
            .add({
                'slds-is-completed': this.currentStep !== 'start-ticket' && this.currentStep !== 'completed',
                'slds-is-active': this.currentStep === 'start-ticket',
            })
            .toString();
    }

    get rejectTicketClasses() {
        return this.classSet('slds-progress__item')
            .add({
                'slds-is-completed': this.currentStep === 'reject-ticket',
            })
            .toString();
    }

    get scanAssetClasses() {
        return this.classSet('slds-progress__item')
            .add({
                'slds-is-completed': (this.currentStep === 'scan-asset' || this.currentStep === 'capture-feedback') && this.currentStep !== 'start-ticket' && this.currentStep !== 'completed',
                'slds-is-active': this.currentStep === 'scan-asset' || this.currentStep === 'capture-feedback' || this.currentStep === 'capture-sda' || this.currentStep === 'cancel-ticket',
            })
            .toString();
    }
    get productRegistrationClasses() {
        return this.classSet('slds-progress__item')
            .add({
                'slds-is-completed': (this.currentStep === 'scan-asset' || this.currentStep === 'capture-feedback') && this.currentStep !== 'start-ticket' && this.currentStep !== 'completed',
                'slds-is-active': this.currentStep === 'scan-asset' || this.currentStep === 'capture-feedback' || this.currentStep === 'capture-sda' || this.currentStep === 'cancel-ticket',
            })
            .toString();
    }

    get uploadImageClasses() {
        return this.classSet('slds-progress__item')
            .add({
                'slds-is-completed': (this.currentStep === 'scan-asset' || this.currentStep === 'capture-feedback' || this.currentStep === 'complete-ticket') && this.currentStep !== 'start-ticket',
                'slds-is-active': this.currentStep === 'scan-asset' || this.currentStep === 'capture-sda' || this.currentStep === 'cancel-ticket' || this.currentStep === 'capture-feedback' || this.currentStep === 'completed',
            })
            .toString();
    }
    get captureSDAClasses() {
        return this.classSet('slds-progress__item')
            .add({
                'slds-is-completed': this.currentStep === 'scan-asset' && this.currentStep !== 'start-ticket' && this.currentStep !== 'completed',
                'slds-is-active': this.currentStep === 'scan-asset' || this.currentStep === 'capture-sda' || this.currentStep === 'cancel-ticket',
            })
            .toString();
    }

    get cancelTicketClasses() {
        return this.classSet('slds-progress__item')
            .add({
                'slds-is-completed': this.currentStep !== 'cancel-ticket' && this.currentStep !== 'scan-asset' && this.currentStep !== 'start-ticket' && this.currentStep !== 'completed',
                'slds-is-active': this.currentStep === 'cancel-ticket',
            })
            .toString();
    }

    get captureFeedbackClasses() {
        return this.classSet('slds-progress__item')
            .add({
                'slds-is-completed': this.currentStep === 'capture-feedback',
                'slds-is-active': this.currentStep === 'capture-feedback',
            })
            .toString();
    }

    get completeTicketClasses() {
        return this.classSet('slds-progress__item')
            .add({
                'slds-is-completed': this.currentStep === 'complete-ticket' || this.currentStep === 'completed',
                'slds-is-active': this.currentStep === 'complete-ticket',
            })
            .toString();
    }

    get PMSindividualTicketCompletionClasses() {
        return this.classSet('slds-progress__item')
            .add({
                'slds-is-completed': this.currentStep === 'scan-asset' || this.currentStep === 'completed',
                'slds-is-active': this.currentStep === 'scan-asset',
            })
            .toString();
    }

    get PMSbulkTicketCompletionClasses() {
        return this.classSet('slds-progress__item')
            .add({
                'slds-is-completed': this.currentStep === 'scan-asset' || this.currentStep === 'completed',
                'slds-is-active': this.currentStep === 'scan-asset',
            })
            .toString();
    }


    get isStepStartTicketDisabled() {
        return this.currentStep !== 'start-ticket';
    }

    get isStepScanAssetDisabled() {
        return this.currentStep === 'start-ticket' || this.currentStep === 'completed' || this.currentStep === 'complete-ticket';
    }
    get isRegisterProductDisabled() {
        return this.currentStep === 'start-ticket' || this.currentStep === 'completed' || this.currentStep === 'complete-ticket';
    }
    get isStepUploadImageDisabled() {
        return this.currentStep === 'start-ticket' || this.currentStep === 'completed' || this.currentStep === 'complete-ticket';
    }

    get isStepCaptureSDADisabled() {
        return this.currentStep !== 'scan-asset';
    }

    get isIndividualTicketDisabled() {
        return this.currentStep !== 'scan-asset';
    }

    get isBulkTicketDisabled() {
        return this.currentStep !== 'scan-asset';
    }


    // get isStepCancelTicketDisabled() {
    //     return this.currentStep !== 'cancel-ticket';
    // }

    // get isStepCaptureFeedbackDisabled() {
    //     return this.currentStep !== 'capture-feedback';
    // }

    // get isStepCompleteTicketDisabled() {
    //     return this.currentStep !== 'complete-ticket';
    // }

    get isStepCaptureFeedbackDisabled() {
        return this.currentStep !== 'capture-feedback';
    }

    // get isStepCompleteTicketDisabled() {
    //     return (this.currentStep !== 'complete-ticket' && this.currentStep !== 'scan-asset') ;
    // }
    get isStepCompleteTicketDisabled() {
        return (this.currentStep !== 'complete-ticket');
    }


    handleStartTicket() {
        this.showSpinner = true;
        this.showToast(null, 'Ticket has started', 'info');

        updateWorkOrderStatus({ recordId: this.recordId, status: 'In Progress', latitude: this.latitude, longitude: this.longitude })
            .then(() => {

                this.fetchWorkOrder(); // Refresh the work order to get the updated status
                // Update to the next step
                if (this.isBulkPMS === true) {

                    this.currentStep = 'capture-feedback';
                }
                else {
                    this.currentStep = 'scan-asset';
                }

                this.showSpinner = false;
            })
            .catch(error => {
                // LightningAlert.open({
                //     message: 'error - ' + JSON.stringify(error),
                //     theme: 'error', // a red theme intended for error states
                //     label: 'Error!', // this is the header text
                // });
                console.error('Error updating work order status:', error);
            });

        // setTimeout(() => {
        //     this.showSpinner = false;
        // }, 1000);
    }

    captureTechnicianLocation(currentAction) {

        captureLocationOnWO({ recordId: this.recordId, latitude: this.latitude, longitude: this.longitude, currentAction: currentAction })
            .then(() => {

                //this.fetchWorkOrder(); // Refresh the work order to get the updated status
                // this.currentStep = 'scan-asset';  // Update to the next step

                this.showSpinner = false;
            })
            .catch(error => {
                // LightningAlert.open({
                //     message: 'error - ' + JSON.stringify(error),
                //     theme: 'error', // a red theme intended for error states
                //     label: 'Error!', // this is the header text
                // });
                console.error('Error updating work order status:', error);
            });
    }

    fetchAssetDepartment() {
        this.showSpinner = true;

        // Return a promise to handle the asynchronous nature of this function
        return new Promise((resolve, reject) => {
            getAssetDepartment({ recordId: this.recordId })
                .then((result) => {
                    console.log('result :', JSON.stringify(result));

                    console.log('Service Department:', result?.Asset?.Service_Department_L__r);


                    if (result != null) {
                        if (result.Is_Asset_Scanned_Added__c === true) {
                            console.log('if 1 :', result.Is_Asset_Scanned_Added__c);

                            if (result?.Asset?.Service_Department_L__r?.Department_Number__c && result.Asset.Service_Department_L__r.Department_Number__c !== '51') {
                                console.log('if 2 :', result.Asset.Service_Department_L__r.Department_Number__c);

                                this.allowScanAsset = false;
                                this.showSpinner = false;
                                resolve(this.allowScanAsset);  // Resolve the promise with the value of allowScanAsset
                            } else {
                                console.log('else 1 :', result.Asset.Service_Department_L__r.Department_Number__c);

                                getWOLICount({ recordId: this.recordId })
                                    .then((woliCount) => {
                                        if (woliCount >= 2) {
                                            console.log('if 3:', woliCount);

                                            this.allowScanAsset = false;
                                        } else {
                                            console.log('else 2:', woliCount);

                                            this.allowScanAsset = true;
                                        }
                                        this.showSpinner = false;
                                        resolve(this.allowScanAsset);  // Resolve the promise with the updated allowScanAsset value
                                    })
                                    .catch(error => {
                                        this.showSpinner = false;
                                        console.error('Error updating work order status:', error);
                                        reject(error);  // Reject the promise with the error
                                    });
                            }
                        } else {
                            this.allowScanAsset = true;  // Or false, depending on your logic if Is_Asset_Scanned_Added__c is not true
                            this.showSpinner = false;
                            resolve(this.allowScanAsset);
                        }
                    } else {
                        this.allowScanAsset = true;  // Default value if result is null
                        this.showSpinner = false;
                        resolve(this.allowScanAsset);
                    }
                })
                .catch(error => {
                    this.showSpinner = false;
                    console.error('Error fetching asset department:', error);
                    reject(error);  // Reject the promise with the error
                });
        });
    }



    async handleScanAsset() {

        this.captureTechnicianLocation('Scan Asset');

        //add validation based on department

        this.allowScanAsset = await this.fetchAssetDepartment();

        console.log('this.allowScanAsset :', this.allowScanAsset);


        // if (this.allowScanAsset === false) {

        //     this.showToast("Error", 'Asset already present', 'warning');
        // }
        // else {


        //     this.currentStep = 'scan-asset';

        //     this.mainScreenVisibility = false;
        //     this.scanAssetVisibility = true;
        // }

        this.currentStep = 'scan-asset';

        this.mainScreenVisibility = false;
        this.scanAssetVisibility = true;
    }

    handleAssetScannedSelected(event) {

        this.assetScannedRegistered = true;

        console.log('assetScannedRegistered -- ' + this.assetScannedRegistered);

        //    LightningAlert.open({
        //             message: 'assetScannedRegistered - ' + JSON.stringify(this.assetScannedRegistered),
        //             theme: 'error', // a red theme intended for error states
        //             label: 'Error!', // this is the header text
        //         });
    }

    async handleRegisterProduct() {


        await this.fetchWorkOrder();


        if (this.workOrder.AssetId === true) {
            this.showToast(null, 'Asset already registered', 'warning');

        }
        else {

            this.captureTechnicianLocation('Product Registration');

            this.currentStep = 'scan-asset';

            this.mainScreenVisibility = false;
            this.registerProductVisibility = true;

        }

    }

    handleScanAssetSuccess() {

        this.assetScannedRegistered = true;

        console.log('handleRegisterSuccess -- ' + this.assetScannedRegistered);


        this.currentStep = 'scan-asset';

        this.mainScreenVisibility = true;
        this.scanAssetVisibility = false;
    }

    handleRegisterSuccess(event) {

        this.assetScannedRegistered = true;

        console.log('handleRegisterSuccess -- ' + this.assetScannedRegistered);

    }

    handleProductRegSuccess(event) {


        if (this.workOrder.Is_SDA_Captured__c === true) {
            this.currentStep = 'capture-feedback';

        }
        else {
            this.currentStep = 'scan-asset';

        }

        this.mainScreenVisibility = true;
        this.scanAssetVisibility = false;

        this.registerProductVisibility = false;

        this.assetScannedRegistered = true;

        console.log('handleRegisterSuccess 781 -- ' + this.assetScannedRegistered);


        //   LightningAlert.open({
        //                 message: 'assetScannedRegistered - ' + JSON.stringify(this.assetScannedRegistered),
        //                 theme: 'error', // a red theme intended for error states
        //                 label: 'Error!', // this is the header text
        //             });

    }

    handleRejectTicket() {

        //     this.showSpinner = true;
        //    // Disable all buttons
        //    const buttons = this.template.querySelectorAll('lightning-button');
        //    buttons.forEach(button => {
        //        button.disabled = true;
        //    });

        //    // Show toast message
        //    this.showToast(null,'Ticket Rejected', 'error');

        //     setTimeout(() => {
        //         this.showSpinner = false;
        //     }, 1000);

        this.mainScreenVisibility = false;
        this.rejectWorkVisibility = true;
    }

    handleCancelTicket() {
        this.mainScreenVisibility = false;
        this.cancelTicketVisibility = true;

    }

    handleSingleTicketCompletionPMS() {

        this.showSpinner = true;


        updateWOPMS({ recordId: this.recordId })
            .then((result) => {

                //this.fetchWorkOrder(); // Refresh the work order to get the updated status
                // this.currentStep = 'scan-asset';  // Update to the next step

                this.showSpinner = false;
            })
            .catch(error => {
                // LightningAlert.open({
                //     message: 'error - ' + JSON.stringify(error),
                //     theme: 'error', // a red theme intended for error states
                //     label: 'Error!', // this is the header text
                // });
                console.error('Error updating work order status:', error);
            });

        this.currentStep = 'capture-feedback';

        this.showToast(null, 'Please complete the ticket after capturing feedback', 'success');

        this.showSpinner = false;

        console.log('currentstep -- ' + this.currentstep);
        console.log('isStepCaptureFeedbackDisabled -- ' + this.isStepCaptureFeedbackDisabled);
        console.log('isIndividualTicketDisabled -- ' + this.isIndividualTicketDisabled);



    }

    handleBulkTicketCompletionPMS() {
        this.showSpinner = true;

        completePMSWO({ recordId: this.recordId })
            .then((result) => {


                if (result === 'Success') {

                    this.showToast(null, 'Ticket completed, please generate PMS Checklist', 'success');

                    this.fetchWorkOrder(); // Refresh the work order to get the updated status

                    this.showSpinner = false;

                }
                else if (result === 'Failure') {

                    console.error('Error updating work order status:', error);

                    this.showToast(null, 'Unable to complete the ticket,Please fill all the checklist before completing', 'error');

                    this.showSpinner = false;

                }


            })
            .catch(error => {
                // LightningAlert.open({
                //     message: 'error - ' + JSON.stringify(error),
                //     theme: 'error', // a red theme intended for error states
                //     label: 'Error!', // this is the header text
                // });
                console.error('Error updating work order status:', error);

                this.showToast(null, 'Unable to complete the ticket,Please fill all the checklist before completing', 'error');


                this.showSpinner = false;

            });

    }

    async handleCaptureSDA() {

        this.captureTechnicianLocation('Capture SDA');

        console.log('handleRegisterSuccess 985 -- ' + this.assetScannedRegistered);

        await this.fetchWorkOrder();

            // LightningAlert.open({
            //         message: 'success - ' + JSON.stringify(this.workOrder.AssetId),
            //         theme: 'success', // a red theme intended for error states
            //         label: 'Success!', // this is the header text
            //     });

        if (this.workOrder.AssetId === null || this.workOrder.AssetId === undefined){
            this.showToast(null, 'Please register/scan Asset to proceed', 'warning');
        }
        else if (this.workOrder.Is_SDA_Captured__c === true) {
            this.showToast(null, 'SDA already submitted', 'warning');
        }
        else {
            this.currentStep = 'capture-sda';
            this.mainScreenVisibility = false;
            this.captureSDAVisibility = true;
        }

    }

    handleUploadFiles() {

        this.captureTechnicianLocation('File Upload');


        // if (this.workOrder.Is_File_Uploaded__c === true) {
        //     this.showToast(null, 'Images/Videos already uploaded', 'warning');
        // }
        // else {

        //     this.currentStep = 'upload-files';

        //     this.mainScreenVisibility = false;
        //     this.captureImageUploadVisibility = true;
        // }

        this.currentStep = 'upload-files';

        this.mainScreenVisibility = false;
        this.captureImageUploadVisibility = true;
    }

    handleFileUploadSuccess() {
        this.fileUploaded = true;
    }

    async workStepCompletionCheck() {
        try {
            const result = await checkWorkStepCompletion({ recordId: this.recordId });

            // LightningAlert.open({
            //     message: 'result - ' + JSON.stringify(result),
            //     theme: 'success',
            //     label: 'Success!',
            // });

            console.log('result-- ' + result);

            return result === 'Pending' ? 'Pending' : 'Completed';
        } catch (error) {
            console.error('Error updating work order status:', error);
            return 'Pending'; // Default to pending in case of error
        }
    }


    async handleCaptureFeedback() {


        this.workStepStatus = await this.workStepCompletionCheck();


        if (this.workStepStatus === 'Pending') {


            this.showToast(null, 'Please complete all the checklist before proceeding', 'warning');

        }
        else {

            this.captureTechnicianLocation('Customer Feedback');

            if (this.assetScannedRegistered === false && this.isBulkPMS === false && this.isPMS === false && this.isCommissioning === false) {
                this.showToast(null, 'Please register/scan Asset before feedback!!', 'warning');
            }

            else if (this.workOrder.Is_Customer_Feedback_Captured__c === true && this.workOrder.Is_SDA_Captured__c != true) {
                this.showToast(null, 'Feedback captured already', 'warning');
            }
            else if (this.fileUploaded === false && this.isBulkPMS === false && this.isPMS === false) {
                this.showToast(null, 'Please upload images before proceeding!!', 'warning');

            }
            else {
                this.currentStep = 'capture-feedback';

                this.mainScreenVisibility = false;
                this.captureFeedbackVisibility = true;

            }

        }

    }




    async handleCompleteTicket() {
        try {

            this.showSpinner = true;

            this.myLocationService = await getLocationService();

            if (this.myLocationService && this.myLocationService.isAvailable()) {
                // Attempt to get the current position
                const result = await this.myLocationService.getCurrentPosition({ enableHighAccuracy: true });

                if (result && result.coords) {
                    // Store the location
                    this.currentLocation = result;
                    this.latitude = result.coords.latitude;
                    this.longitude = result.coords.longitude;

                    // LightningAlert.open({
                    //     message: 'My location - ' + this.currentLocation + ', lat - ' + this.latitude + ', long - ' + this.longitude,
                    //     theme: 'success',
                    //     label: 'Success!',
                    // });

                    console.log("Location service is now enabled!");

                    // Stop any ongoing location checks if the location is retrieved
                    clearInterval(this.locationCheckInterval);
                } else {
                    this.showSpinner = false;

                    this.showToast(null, 'Cannot complete the ticket without location coordinates', 'warning');
                    return; // Exit if no valid location is available
                }
            } else {
                this.showSpinner = false;

                this.showToast(null, 'Cannot complete the ticket without location service', 'warning');
                return; // Exit if location service is not available
            }

            // Proceed only if latitude and longitude are valid numbers
            if (this.latitude && this.longitude) {

                this.showSpinner = false;

                // Call method to capture technician's location
                this.captureTechnicianLocation('Complete Ticket');

                // Proceed to the next step
                this.currentStep = 'complete-ticket';
                this.mainScreenVisibility = false;
                this.completeWorkOrderVisibility = true;

            } else {
                this.showSpinner = false;

                this.showToast(null, 'Cannot complete the ticket without valid location', 'warning');
            }
        } catch (error) {
            this.showSpinner = false;

            this.showToast(null, 'Error while retrieving location: ' + error.message, 'error');
        }
    }


    handleDraftSDA() {

        this.currentStep = 'scan-asset';

        // SDA capture successful, hide child component
        this.mainScreenVisibility = true;
        this.captureSDAVisibility = false;

    }


    handleSubmitSDA() {
        //event after sda submission

        this.currentStep = 'capture-feedback';

        // SDA capture successful, hide child component
        this.mainScreenVisibility = true;
        this.captureSDAVisibility = false;


    }

    // Event listener for feedbackSubmitted event from child component
    handleFeedbackSubmitted(event) {
        console.log('event passed parent -- ', event.detail);
        const { success } = event.detail;

        if (success) {

            this.currentStep = 'complete-ticket';

            // Feedback submission successful, hide child component
            this.mainScreenVisibility = true;
            this.captureFeedbackVisibility = false;


        } else {
            // Handle potential errors during feedback submission
            this.showToast('Error', 'An error occurred during feedback submission.', 'error');
        }
    }


    handleOtpVerificationSuccess(event) {
        console.log('event passed parent -- ', event.detail);
        const { success } = event.detail;

        if (success) {
            this.currentStep = 'completed';

            updateWorkOrderStatus({ recordId: this.recordId, status: 'Completed', latitude: this.latitude, longitude: this.longitude })
                .then(() => {
                    // Handle successful update
                    this.fetchWorkOrder(); // Refresh the work order to get the updated status
                    // this.showToast(null, 'Ticket completed successfully!!', 'success');

                })
                .catch(error => {
                    console.error('Error updating work order status:', error);
                });

            // Feedback submission successful, hide child component
            this.mainScreenVisibility = true;
            this.completeWorkOrderVisibility = false;

            // Update visibility for other steps based on your logic
            // (e.g., show complete work order screen)
        } else {
            // Handle potential errors during feedback submission
            this.showToast('Error', 'An error occurred during feedback submission.', 'error');
        }


    }

    handleCreateServiceReport() {

        this.mainScreenVisibility = false;
        this.createServiceReportVisibilty = true;

    }

    async backEventHandler() {

        if (this.isCommissioning === true) {

            this.currentStep = 'capture-feedback';

        }

        await this.fetchWorkOrder();

        this.mainScreenVisibility = true;

        this.updateUIBasedOnStatus();

        //this.currentStep = 'scan-asset';

        this.cancelTicketVisibility = false;
        this.startWorkVisibility = false;
        this.scanAssetVisibility = false;
        this.registerProductVisibility = false;
        this.rejectWorkVisibility = false;
        this.captureSDAVisibility = false;
        this.captureImageUploadVisibility = false;
        this.captureFeedbackVisibility = false;
        this.completeWorkOrderVisibility = false;

    }


    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastEvent);
    }

}