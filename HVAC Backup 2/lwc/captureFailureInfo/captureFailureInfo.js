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
import gasCapping from '@salesforce/label/c.Gas_Capping_value';




export default class CaptureFailureInfo extends NavigationMixin(LightningElement) {
    @track gasAmount;
    @track otherAmount;
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
    @track hasGasLeakage = '';
    @track gasChargingValue;
    @track fieldworktype;
    @track showForm = false;
    @track gasLeaking = 'No';
    @track isGasLeakingYes = false;
    @track hasGasChargingvalue = false;
    @track hasGasCharging = false;
    @track incomingVoltage;
    @track gaschargingrequired;
    @track gasleakagerequired;
    @track isGasLeakageTrue = false;
    @track isGaschargeTrue = false;
    @track systemAmpere;
    @track grilleTemperature;
    @track actualcapacity;
    @track suctionpressure;
    @track dischargePressure;
    @track waterpressure;
    @track rawwaterTDS;
    @track tDSafterpurification;
    @track suctionpressure;
    @track ambienttemp;
    @track roomtemp;
    @track ampsinrunningcondition;
    @track tr;
    @track refrigerant;
    @track rangeBetweenSuctionPressure;
    @track rangeBetweenDischargePressure;
    @track firstProductParameters = false;
    @track wpdParameters = false;
    @track secondProductParameters = false;
    @track unitFunctionalParameter = false;
    @track refrigerantOptions = [
        { label: 'R-22', value: 'R-22' },
        { label: 'R-410A', value: 'R-410A' },
        { label: 'R-32', value: 'R-32' },
        { label: 'R-134A', value: 'R-134A' },
        // Add more refrigerants as needed
    ];

    @track picklistOptions = [];



    // Gas charging options
    get gasChargingOptions() {
        return [
            { label: 'Yes', value: 'yes' },
            { label: 'No', value: 'no' }
        ];
    }

    get gasLeakageOptions() {
        return [
            { label: 'Yes', value: 'yes' },
            { label: 'No', value: 'no' }
        ];
    }

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


    getWorkOrderLines() {
        getWOLIList({ recordId: this.recordId })
            .then(result => {
                this.woLIList = result;
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

                 console.log('result -- '+ JSON.stringify(this.result));


                //       LightningAlert.open({
                //     message: 'result - ' + JSON.stringify(result),
                //     theme: 'success', // a red theme intended for error states
                //     label: 'Error!', // this is the header text
                // });
                if (result) {
                    this.fieldworktype = result.fieldWorkType,
                    this.selectedSymptom = result.symptom;
                    this.selectedDefect = result.defect;
                    this.selectedAction = result.action;
                    this.symptomComt = result.symptomComment;
                    this.defectComt = result.defectComment;
                    this.actionComt = result.actionComment;
                    this.incomingVoltage = result.incoming_vol;
                    this.systemAmpere = result.system_amp;
                    this.grilleTemperature = result.grill_temp;
                    this.actualcapacity = result.actual_capacity;
                    this.suctionpressure = result.suction_pressure;
                    this.dischargePressure = result.discharge_Pressure;
                    this.waterPressure = result.water_pressure;
                    this.rawWaterTDS = result.raw_water_TDS;
                    this.tdsAfterPurification = result.tds_after_purification;
                    this.ambientTemp = result.ambient_temp;
                    this.roomTemp = result.room_temp;
                    this.ampsinrunningcondition = result.amps_in_running_condition;
                    this.tr = result.tr;
                    this.refrigerant = result.refrigerant;
                    this.rangeBetweenDischargePressure = result.range_between_discharge_pressure;
                    this.rangeBetweenSuctionPressure = result.range_between_suction_pressure;
                    this.firstProductParameters = result.firstProductParameters;
                    this.wpdParameters = result.wpdParameters;
                    this.secondProductParameters = result.secondProductParameters;
                    this.unitFunctionalParameter = result.unitFunctionalParameter;

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
                            console.log('defectOptions -- '+ JSON.stringify(this.defectOptions));
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
                                console.log('actionOptions -- '+ JSON.stringify(this.actionOptions));

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


        // Get the value of Field_Work_Type__c
        this.fieldworktype = event.target.value;


        //     LightningAlert.open({
        //     message: 'fieldworktype - ' + JSON.stringify(this.fieldworktype),
        //     theme: 'success', // a red theme intended for error states
        //     label: 'fieldworktype!', // this is the header text
        // });

        // Set the selected action to the fieldworktype value
        this.selectedAction = this.fieldworktype;

        // Define the gas charging actions
        const gasChargingActions = [
            "Breakdown",
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

        this.hasGasChargingvalue = gasChargingActions.includes(this.fieldworktype);
        // Clear hasGasCharging if gas charging is not required
        if (!this.hasGasChargingvalue) {
            this.hasGasCharging = false;
        }
    }

    // Handle the change in gas charging combobox (Yes/No)
    handleGasChargingChange(event) {


        this.gaschargingrequired = event.detail.value;

        if (this.gaschargingrequired === 'yes') {

            this.isGaschargeTrue = true;
        } else {
            this.isGaschargeTrue = false;
        }
    }
    handleGasLeakageChange(event) {
        this.gasleakagerequired = event.detail.value;
        if (this.gasleakagerequired === 'yes') {

            this.isGasLeakageTrue = true;
        } else {
            this.isGasLeakageTrue = false;
        }
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

    handlegaschargingvalue(event) {
        this.gaschargingvalue = event.target.value;
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
    handleactualcapacity(event) {
        this.actualcapacity = event.target.value;
    }
    handleSuctionpressure(event) {
        this.suctionpressure = event.target.value;
    }
    handledischargePressure(event) {
        this.dischargePressure = event.target.value;
    }
    handleWaterpressure(event) {
        this.waterpressure = event.target.value;
    }
    handleRawwaterTDS(event) {
        this.rawwaterTDS = event.target.value;
    }
    handleTDSafterpurification(event) {
        this.tDSafterpurification = event.target.value;
    }
    handlesuctionpressure(event) {
        this.suctionpressure = event.target.value;
    }
    handleambienttemp(event) {
        this.ambienttemp = event.target.value;
    }
    handleroomtemp(event) {
        this.roomtemp = event.target.value;
    }
    handleampsinrunningcondition(event) {
        this.ampsinrunningcondition = event.target.value;
    }
    handleRefrigerant(event) {
        this.refrigerant = event.target.value; // Set the selected refrigerant value
    }
    handletr(event) {
        this.tr = event.target.value;
    }
    handlerangeBetweenSuctionPressure(event) {
        this.rangeBetweenSuctionPressure = event.target.value;
    }
    handlerangeBetweenDischargePressure(event) {
        this.rangeBetweenDischargePressure = event.target.value;
    }
    handleGasAmount(event) {
        this.gasAmount = event.target.value;
    }
    handleOtherAmount(event) {
        this.otherAmount = event.target.value;
    }



    // Handle save button click
    async handleSave() {

        const result = await LightningConfirm.open({
            message: 'Are you sure you want to submit!?',
            variant: 'headerless',
            label: 'Are you sure you want to submit!?',
            // setting theme would have no effect
        });

        // Set isLoading to true to show spinner
        this.isLoading = true;

        if (result === true) {


            console.log('here', gasCapping);
            console.log('here this.gasAmount', this.gasAmount);
            if (this.gasAmount && this.gasAmount > parseInt(gasCapping)) {
                console.log('test');
                this.isLoading = false;
                // If any of the required fields are not filled, show an error toast
                this.showToast('Error', 'Maximum allowed value for gas amount is ' + gasCapping, 'error');
                return;
            }

            let missingFields = [];

            

            // Check each field and add its label to the missingFields array if it's blank
             if (!this.fieldworktype) {
                missingFields.push('work type');
            }
            if (!this.selectedSymptom) {
                missingFields.push('Symptom');
            }
            if (!this.selectedDefect) {
                missingFields.push('Defect');
            }
            if (!this.selectedAction) {
                missingFields.push('Action');
            }
            if (!this.symptomComt) {
                missingFields.push('Symptom Comment');
            }
            if (!this.defectComt) {
                missingFields.push('Defect Comment');
            }
            if (!this.actionComt) {
                missingFields.push('Action Comment');
            }

            // If there are missing fields, construct the error message and show the toast
            if (missingFields.length > 0) {
                this.isLoading = false;
                const errorMessage = `Please fill all the details: ${missingFields.join(', ')}`;
                this.showToast('Error', errorMessage, 'error');
            }

            // if (!this.selectedSymptom || !this.selectedDefect || !this.selectedAction || !this.symptomComt || !this.defectComt || !this.actionComt) {
            //     this.isLoading = false;
            //     // If any of the required fields are not filled, show an error toast
            //     this.showToast('Error', 'Please fill all the details', 'error');
            // } 
            else {
                // If all required fields are filled, proceed with saving the data
                updateWorkOrder({
                    recordId: this.recordId,
                    fieldworktype:this.fieldworktype,
                    symptomLabel: this.selectedSymptom,
                    defectLabel: this.selectedDefect,
                    actionLabel: this.selectedAction,
                    symptomCmt: this.symptomComt,
                    defectCmt: this.defectComt,
                    actionCmt: this.actionComt,
                    gasChargingValue: this.gasChargingValue,
                    incomingVoltage: this.incomingVoltage,
                    systemAmpere: this.systemAmpere,
                    grilleTemperature: this.grilleTemperature,
                    actualcapacity: this.actualcapacity,
                    suctionpressure: this.suctionpressure,
                    dischargePressure: this.dischargePressure,
                    otherAmount: this.otherAmount,
                    gasAmount: this.gasAmount,
                    saveAsDraft: false,
                    // New parameters for wpdParameters
                    waterpressure: this.waterpressure,
                    rawwaterTDS: this.rawwaterTDS,
                    tDSafterpurification: this.tDSafterpurification,

                    // New parameters for secondProductParameters
                    ambienttemp: this.ambienttemp,
                    roomtemp: this.roomtemp,

                    // New parameters for unitFunctionalParameter
                    ampsinrunningcondition: this.ampsinrunningcondition,
                    tr: this.tr,
                    refrigerant: this.refrigerant,
                    rangeBetweenSuctionPressure: this.rangeBetweenSuctionPressure,
                    rangeBetweenDischargePressure: this.rangeBetweenDischargePressure

                })
                    .then((result) => {
                        this.isLoading = false;
                        if(result === 'Success'){

                             // Show success toast
                        this.showToast('Success', 'Failure Details updated successfully', 'success');
                        // Navigate to the record page
                        // this.navigateToRecordPage(this.recordId);
                        const event = new CustomEvent('submitsda');
                        this.dispatchEvent(event);

                        }
                        else if(result === 'Asset Missing'){
                             this.showToast('Warning', 'Please Register/Scan the asset before submitting SDA', 'Warning');

                        }
                        else{
                            this.showToast('Error', 'Failed to save the details, please contact admin', 'error');

                        }
                       
                    })
                    .catch(error => {
                        this.isLoading = false;
                        // Show error toast with error message
                        this.showToast('Error updating record', error.body.message, 'error');
                    });
            }

        }
        else {

            this.isLoading = false;



        }


    }

    // Handle save button click
    handleSaveDraft() {
        // Set isLoading to true to show spinner
        this.isLoading = true;
        console.log('here', gasCapping);
        console.log('here this.gasAmount', this.gasAmount);
        if (this.gasAmount && this.gasAmount > parseInt(gasCapping)) {
            console.log('test');
            this.isLoading = false;
            // If any of the required fields are not filled, show an error toast
            this.showToast('Error', 'Maximum allowed value for gas amount is ' + gasCapping, 'error');
            return;
        }

        // If all required fields are filled, proceed with saving the data
        updateWorkOrder({
            recordId: this.recordId,
            fieldworktype:this.fieldworktype,
            symptomLabel: this.selectedSymptom,
            defectLabel: this.selectedDefect,
            actionLabel: this.selectedAction,
            symptomCmt: this.symptomComt,
            defectCmt: this.defectComt,
            actionCmt: this.actionComt,
            gasCharging: this.hasGasCharging,
            gasChargingValue: this.gasChargingValue,
            incomingVoltage: this.incomingVoltage,
            systemAmpere: this.systemAmpere,
            grilleTemperature: this.grilleTemperature,
            actualcapacity: this.actualcapacity,
            suctionpressure: this.suctionpressure,
            dischargePressure: this.dischargePressure,
            otherAmount: this.otherAmount,
            gasAmount: this.gasAmount,
            saveAsDraft: true,
            // New parameters for wpdParameters
            waterpressure: this.waterpressure,
            rawwaterTDS: this.rawwaterTDS,
            tDSafterpurification: this.tDSafterpurification,

            // New parameters for secondProductParameters
            ambienttemp: this.ambienttemp,
            roomtemp: this.roomtemp,

            // New parameters for unitFunctionalParameter
            ampsinrunningcondition: this.ampsinrunningcondition,
            tr: this.tr,
            refrigerant: this.refrigerant,
            rangeBetweenSuctionPressure: this.rangeBetweenSuctionPressure,
            rangeBetweenDischargePressure: this.rangeBetweenDischargePressure

        })
            .then(() => {
                this.isLoading = false;
                // Show success toast
                this.showToast('Success', 'Details saved as draft', 'success');
                // Navigate to the record page
                // this.navigateToRecordPage(this.recordId);
                const event = new CustomEvent('draftsda');
                this.dispatchEvent(event);
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