import { LightningElement, wire, track, api } from 'lwc';
import getSymptoms from '@salesforce/apex/FailureInfoController.getSymptoms';
import getDefects from '@salesforce/apex/FailureInfoController.getDefects';
import getActions from '@salesforce/apex/FailureInfoController.getActions';
import updateWorkOrder from '@salesforce/apex/FailureInfoController.updateWorkOrder';
import getWOLIList from '@salesforce/apex/FailureInfoController.getWorkOrderLineItems';
import getWO from '@salesforce/apex/FailureInfoController.getWorkOrderDetails';
import getFieldWorkTypes from '@salesforce/apex/FailureInfoController.getFieldWorkTypeOptions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import LightningConfirm from 'lightning/confirm';
import getSavedDetails from '@salesforce/apex/FailureInfoController.getWorkOrderDetailsOnLoad';
import LightningAlert from 'lightning/alert';


export default class CaptureFailureInfoDesktop extends NavigationMixin(LightningElement) {
    @track selectedSymptom;
    @track selectedDefect;
    @track selectedAction;
    @track symptomOptions = [];
    @track defectOptions = [];
    @track actionOptions = [];
    @track defectDisabled = true;
    @track actionDisabled = true;
    @track symptomComt;
    @track defectComt;
    @track actionComt;
    @api recordId;
    @api objectApiName = 'WorkOrder';
    @track fields = ['Field_Work_Type__c'];
    @track isLoading = false;
    @track woLIList = [];
    @track typeselectedValue = '';
    hasGasCharging = false;
    @track selectedActionn;
    gasChargingValue;
    @track fieldworktype;
    @track showForm = false;

    @track incomingVoltage;
    @track systemAmpere;
    @track grilleTemperature;

    @track picklistOptions = [];



    // Fetch symptoms when component is initialized
    @wire(getSymptoms, { recordId: '$recordId' })
    wiredSymptoms({ error, data }) {
        if (data) {
            this.symptomOptions = Object.keys(data).map(key => ({
                label: data[key],
                value: data[key]
            }));
        } else if (error) {
            console.error('Error fetching symptoms', error);
        }
    }


    connectedCallback() {

        this.getWODetails();
        this.loadPicklistValues();

        try {
            this.getWorkOrderLines();
        } catch (error) {
            console.log('error-->' + error.message);
        }
    }

    getWorkOrderLines() {
        getWOLIList({ recordId: this.recordId })
            .then(result => {
                this.woLIList = result;
            });

    }
    loadPicklistValues() {
        getFieldWorkTypes()
            .then(data => {
                this.picklistOptions = data.map(value => ({ label: value, value: value }));

                            console.log('picklistOptions-->' + this.picklistOptions);


            })
            .catch(error => {
                console.error('Error fetching picklist values', error);
            });
    }


    getWODetails() {

        //  LightningAlert.open({
        //         message: 'get WO called - ' + this.recordId,
        //         theme: 'success', // a red theme intended for error states
        //         label: 'Error!', // this is the header text
        //     });

        getSavedDetails({ recordId: this.recordId })
            .then(result => {

                //       LightningAlert.open({
                //     message: 'result - ' + JSON.stringify(result),
                //     theme: 'success', // a red theme intended for error states
                //     label: 'Error!', // this is the header text
                // });
                if (result) {
                    this.selectedSymptom = result.symptom;
                    this.selectedDefect = result.defect;
                    this.selectedAction = result.action;
                    this.symptomComt = result.symptomComment;
                    this.defectComt = result.defectComment;
                    this.actionComt = result.actionComment;
                    this.incomingVoltage = result.incoming_vol;
                    this.systemAmpere = result.system_amp;
                    this.grilleTemperature = result.grill_temp;

                }

                if (this.selectedSymptom != null) {

                    this.showForm = true;
                    this.defectDisabled = false;



                }

                if (this.selectedDefect != null) {

                    // Fetch defects based on selected symptom
                    getDefects({ selectedSymptomLabel: this.selectedSymptom })
                        .then(result => {
                            this.defectOptions = Object.keys(result).map(key => ({
                                label: result[key],
                                value: result[key]
                            }));
                        })
                        .catch(error => {
                            console.error('Error fetching defects', error);
                        });


                    this.actionDisabled = false;
                    this.selectedDefect = result.defect;


                }
                if (this.selectedAction != null) {

                    // Fetch actions based on selected defect
                    getActions({ selectedDefectLabel: this.selectedDefect })
                        .then(result => {
                            this.actionOptions = Object.keys(result).map(key => ({
                                label: result[key],
                                value: result[key]
                            }));
                        })
                        .catch(error => {
                            console.error('Error fetching actions', error);
                        });

                    this.selectedAction = result.action;




                }

                //     LightningAlert.open({
                //     message: 'resshowFormult - ' + JSON.stringify(this.showForm),
                //     theme: 'success', // a red theme intended for error states
                //     label: 'Error!', // this is the header text
                // });
            })
            .catch(error => {
                console.error('Error fetching work order details', error);
            });

    }



    // Handle symptom change
    handleSymptomChange(event) {
        this.selectedSymptom = event.detail.value;
        this.defectDisabled = true;
        this.actionDisabled = true;
        this.selectedDefect = '';
        this.selectedAction = '';
        this.symptomComt = this.selectedSymptom;
        if (this.selectedSymptom) {
            this.defectDisabled = false;
            // Fetch defects based on selected symptom
            getDefects({ selectedSymptomLabel: this.selectedSymptom })
                .then(result => {
                    this.defectOptions = Object.keys(result).map(key => ({
                        label: result[key],
                        value: result[key]
                    }));
                })
                .catch(error => {
                    console.error('Error fetching defects', error);
                });
        }
    }

    // Handle defect change
    handleDefectChange(event) {
        this.selectedDefect = event.detail.value;
        this.actionDisabled = true;
        this.selectedAction = '';
        this.defectComt = this.selectedDefect;
        if (this.selectedDefect) {
            this.actionDisabled = false;
            // Fetch actions based on selected defect
            getActions({ selectedDefectLabel: this.selectedDefect })
                .then(result => {
                    this.actionOptions = Object.keys(result).map(key => ({
                        label: result[key],
                        value: result[key]
                    }));
                })
                .catch(error => {
                    console.error('Error fetching actions', error);
                });
        }
    }

    handleAwaitingParts() {
        // Handle logic for the "Update Awaiting for parts" button
        // This method will be called when the button is clicked
    }

    // Handle action change
    handleActionChange(event) {

        this.showForm = true;

        //     LightningAlert.open({
        //     message: 'resshowFormult - ' + JSON.stringify(this.showForm),
        //     theme: 'success', // a red theme intended for error states
        //     label: 'Error!', // this is the header text
        // });

        // Get the value of Field_Work_Type__c
        this.fieldworktype = event.target.value;

        // Set the selected action to the fieldworktype value
        this.selectedAction = this.fieldworktype;

        // Define the gas charging actions
        const gasChargingActions = [
            "Gas Charging - SAC R22",
            "Gas Charging – WRAC",
            "Gas Charging-WAC/PAC",
            "Gas Charging",
            "Gas Top up",
            "Gas Charging - Cassette / Verticool & SAC - 410A"
        ];

        // Log the selected action and check if it's a gas charging action
        console.log('Selected Action:', this.selectedAction);
        console.log('Is Gas Charging Action:', gasChargingActions.includes(this.selectedAction));

        // Set hasGasCharging based on whether the selected action is a gas charging action
        this.hasGasCharging = gasChargingActions.includes(this.selectedAction);
    }

    //Handle Symptom Comment
    handleSymptomComtChange(event) {
        this.symptomComt = event.target.value;
    }

    //Handle Defect Comment
    handleDefectComtChange(event) {
        this.defectComt = event.target.value;
    }

    //Handle Action Comment
    handleActionComtChange(event) {
        this.actionComt = event.target.value;
        this.selectedAction = event.target.value;
        console.log('Selected Action:', this.selectedAction);

    }

    handleChecked(event) {
        this.hasGasCharging = event.target.checked;
    }

    addDetailsOptions = [
        //{ label: 'Waiting for Parts', value: 'Waiting for Parts' },
        { label: 'Work Complete', value: 'Work Complete' }
    ];

    // Handle Add Details Picklist Change
    handleAddDetailsChange(event) {
        this.typeselectedValue = event.detail.value;
        // Show or hide the form based on the selected value
        this.showUpdateButton = this.typeselectedValue === 'Waiting for Parts';
        this.showForm = this.typeselectedValue === 'Work Complete';
    }

    handleIncVol(event) {
        this.incomingVoltage = event.target.value;
    }

    handleSysAmpChange(event) {
        this.systemAmpere = event.target.value;
    }

    handleGrillTemp(event) {
        this.grilleTemperature = event.target.value;
    }

    async handleSave() {
        const result = await LightningConfirm.open({
            message: 'Are you sure you want to submit!?',
            variant: 'headerless',
            label: 'Are you sure you want to submit!?',
        });

        this.isLoading = true;

        if (result === true) {
            if (!this.selectedSymptom && !this.selectedDefect && !this.selectedAction && !this.symptomComt && !this.defectComt && !this.actionComt && !this.incomingVoltage && !this.systemAmpere && !this.grilleTemperature) {
                this.isLoading = false;
                this.showToast('Error', 'Please fill all the details', 'error');
            } else {
                updateWorkOrder({
                    recordId: this.recordId,
                    symptomLabel: this.selectedSymptom,
                    defectLabel: this.selectedDefect,
                    actionLabel: this.selectedAction,
                    symptomCmt: this.symptomComt,
                    defectCmt: this.defectComt,
                    actionCmt: this.actionComt,
                    gasCharging: this.gasChargingValue,
                    incomingVoltage: this.incomingVoltage,
                    systemAmpere: this.systemAmpere,
                    grilleTemperature: this.grilleTemperature,
                    saveAsDraft: false
                })
                    .then((result) => {
                        this.isLoading = false;
                        if (result === 'Success') {

                            this.showToast('Success', 'Failure Details updated successfully', 'success');
                            const event = new CustomEvent('submitsda');
                            this.dispatchEvent(event);
                            // Redirect to the specific record page in the Community
                            this[NavigationMixin.Navigate]({
                                type: 'standard__recordPage',
                                attributes: {
                                    recordId: this.recordId,
                                    actionName: 'view',
                                },
                                state: {
                                    c__recordId: this.recordId
                                }
                            });
                            // Reload the page after navigation
                            window.location.reload();

                        }
                        else if (result === 'Asset Missing') {
                            this.showToast('Warning', 'Please Register/Scan the asset before submitting SDA', 'Warning');

                        }
                        else {
                            this.showToast('Error', 'Failed to save the details, please contact admin', 'error');

                        }
                    })
                    .catch(error => {
                        this.isLoading = false;
                        this.showToast('Error updating record', error.body.message, 'error');
                    });
            }
        } else {
            this.isLoading = false;
            // Optionally redirect the user to the specific record page
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.recordId,
                    actionName: 'view',
                },
                state: {
                    c__recordId: this.recordId
                }
            });
            // Reload the page after navigation
            window.location.reload();
        }
    }



    // Handle save button click
    handleSaveDraft() {
        // Set isLoading to true to show spinner
        this.isLoading = true;

        // If all required fields are filled, proceed with saving the data
        updateWorkOrder({
            recordId: this.recordId,
            symptomLabel: this.selectedSymptom,
            defectLabel: this.selectedDefect,
            actionLabel: this.selectedAction,
            symptomCmt: this.symptomComt,
            defectCmt: this.defectComt,
            actionCmt: this.actionComt,
            gasCharging: this.gasChargingValue,
            incomingVoltage: this.incomingVoltage,
            systemAmpere: this.systemAmpere,
            grilleTemperature: this.grilleTemperature,
            saveAsDraft: false


        })
            .then((result) => {
                this.isLoading = false;

                if (result === 'Success') {
                    // Show success toast
                    this.showToast('Success', 'Details saved as draft', 'success');
                    // Navigate to the record page
                    // this.navigateToRecordPage(this.recordId);
                    const event = new CustomEvent('draftsda');
                    this.dispatchEvent(event);

                }

                else if (result === 'Asset Missing') {
                    this.showToast('Warning', 'Please Register/Scan the asset before submitting SDA', 'Warning');

                }
                else {
                    this.showToast('Error', 'Failed to save the details, please contact admin', 'error');

                }
            })
            .catch(error => {
                this.isLoading = false;
                // Show error toast with error message
                this.showToast('Error updating record', error.body.message, 'error');
            });

    }

    // Navigate to the record page
    navigateToRecordPage(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view'
            }
        });
    }


    handleBackClick() {

        // Emit custom event on back click
        const backClick = new CustomEvent('backclick', {});
        this.dispatchEvent(backClick);
    }

    // Show toast message
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}