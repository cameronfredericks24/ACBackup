import { LightningElement, wire, track, api } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getRecord } from 'lightning/uiRecordApi';
import RETURN_ORDER_OBJECT from '@salesforce/schema/ReturnOrder';
import EQUIPMENT_TYPE_FIELD from '@salesforce/schema/ReturnOrder.Equipment_Type_General__c';
import MAIN_DEFECT_FIELD from '@salesforce/schema/ReturnOrder.Main_Defect_General__c';
import SUBDEFECT_1_FIELD from '@salesforce/schema/ReturnOrder.Sub_Defect_1_General__c';
import SUBDEFECT_2_FIELD from '@salesforce/schema/ReturnOrder.Sub_Defect_2_General__c';

export default class FgrDefectComp extends LightningElement {

    @wire(getObjectInfo, { objectApiName: RETURN_ORDER_OBJECT })
    returnOrderInfo;

    @api selectedEquipmentType;
    @api selectedMainDefect;
    @api selectedSubDefect1;
    @api selectedSubDefect2;
    @track mainDefectData;
    @track subDefect1Data;
    @track subDefect2Data;
    @track mainDefectDisabled = true;
    @track subDefect1Disabled = true;
    @track subDefect2Disabled = true;

    @api outputEquipTy;
    @api outputMainDft;
    @api outputsubDft1;
    @api outputsubDft2;

    @api recordId;

    @track value2;

    @track isEquipmentTypeLoaded = false;
    @track isMainDefectLoaded = false;
    @track isSubDefect1Loaded = false;
    @track isSubDefect2Loaded = false;
    @track isRecordLoaded = false;

    @wire(getRecord, { recordId: '$recordId', fields: [EQUIPMENT_TYPE_FIELD, MAIN_DEFECT_FIELD, SUBDEFECT_1_FIELD, SUBDEFECT_2_FIELD] })
    wiredRecord({ error, data }) {
        if (data) {
            this.outputEquipTy = data.fields.Equipment_Type_General__c.value;
            this.outputMainDft = data.fields.Main_Defect_General__c.value;
            this.outputsubDft1 = data.fields.Sub_Defect_1_General__c.value;
            this.outputsubDft2 = data.fields.Sub_Defect_2_General__c.value;

            console.log('Output Equipment Type:', this.outputEquipTy);
            console.log('Output Main Defect:', this.outputMainDft);
            console.log('Output Sub Defect 1:', this.outputsubDft1);
            console.log('Output Sub Defect 2:', this.outputsubDft2);

            this.isRecordLoaded = true;
            this.initializePicklists();
        } else if (error) {
            console.error('Error loading record:', error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$returnOrderInfo.data.defaultRecordTypeId', fieldApiName: EQUIPMENT_TYPE_FIELD })
    wireEquipmentType({ data, error }) {
        if (data) {
            this.selectedEquipmentType = data.values;
            console.log('Equipment Type Picklist Values:', JSON.stringify(this.selectedEquipmentType));
            this.isEquipmentTypeLoaded = true;
            this.initializePicklists();
        } else if (error) {
            console.error('Error loading equipment type picklist values', error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$returnOrderInfo.data.defaultRecordTypeId', fieldApiName: MAIN_DEFECT_FIELD })
    wiredMainDefect({ data, error }) {
        if (data) {
            this.mainDefectData = data;
            console.log('Main Defect Picklist Values:', JSON.stringify(this.mainDefectData));
            this.isMainDefectLoaded = true;
            this.initializePicklists();
        } else if (error) {
            console.error('Error loading main defect picklist values', error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$returnOrderInfo.data.defaultRecordTypeId', fieldApiName: SUBDEFECT_1_FIELD, controllingFieldApiName: MAIN_DEFECT_FIELD })
    wiredSubDefect1({ data, error }) {
        if (data) {
            this.subDefect1Data = data;
            console.log('Sub Defect 1 Picklist Values:', JSON.stringify(this.subDefect1Data));
            this.isSubDefect1Loaded = true;
            this.initializePicklists();
        } else if (error) {
            console.error('Error loading sub defect 1 picklist values', error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$returnOrderInfo.data.defaultRecordTypeId', fieldApiName: SUBDEFECT_2_FIELD, controllingFieldApiName: SUBDEFECT_1_FIELD })
    wiredSubDefect2({ data, error }) {
        if (data) {
            this.subDefect2Data = data;
            console.log('Sub Defect 2 Picklist Values:', JSON.stringify(this.subDefect2Data));
            this.isSubDefect2Loaded = true;
            this.initializePicklists();
        } else if (error) {
            console.error('Error loading sub defect 2 picklist values', error);
        }
    }

    initializePicklists() {
        if (this.isEquipmentTypeLoaded && this.isMainDefectLoaded && this.isSubDefect1Loaded && this.isSubDefect2Loaded && this.isRecordLoaded) {
            console.log('Initializing Picklists...');
            // Check if picklist values and record values are available
            if (this.outputEquipTy && this.mainDefectData) {
                this.mainDefectDisabled = false;
                this.selectedMainDefect = this.filterPicklistValues(this.mainDefectData, this.outputEquipTy);
                console.log('Filtered Main Defect:', this.selectedMainDefect);
                if (this.outputMainDft && this.subDefect1Data) {
                    this.subDefect1Disabled = false;
                    this.selectedSubDefect1 = this.filterPicklistValues(this.subDefect1Data, this.outputMainDft);
                    console.log('Filtered Sub Defect 1:', this.selectedSubDefect1);
                    if (this.outputsubDft1 && this.subDefect2Data) {
                        this.subDefect2Disabled = false;
                        this.selectedSubDefect2 = this.filterPicklistValues(this.subDefect2Data, this.outputsubDft1);
                        console.log('Filtered Sub Defect 2:', this.selectedSubDefect2);
                    }
                }
            } else {
                console.log('Value not found or picklist data not loaded yet.');
            }
        }
    }

    handleEquipTypeChange(event) {
        const key = event.target.value;
        this.outputEquipTy = key;
        console.log('Selected Equipment Type:', key);
        this.resetDependentPicklists('mainDefect');
        this.selectedMainDefect = this.filterPicklistValues(this.mainDefectData, key);
        this.mainDefectDisabled = false;
    }

    handleMainDefectChange(event) {
        const key = event.target.value;
        this.outputMainDft = key;
        console.log('Selected Main Defect:', key);
        this.resetDependentPicklists('subDefect1');
        this.selectedSubDefect1 = this.filterPicklistValues(this.subDefect1Data, key);
        this.subDefect1Disabled = false;
    }

    handleSubDefect1Change(event) {
        const key = event.target.value;
        this.outputsubDft1 = key;
        console.log('Selected Sub Defect 1:', key);
        this.resetDependentPicklists('subDefect2');
        this.selectedSubDefect2 = this.filterPicklistValues(this.subDefect2Data, key);
        this.subDefect2Disabled = false;
    }

    handleSubDefect2Change(event) {
        const key = event.detail.value;
        this.outputsubDft2 = key;
        console.log('Selected Sub Defect 2:', key);
    }

    resetDependentPicklists(level) {
        if (level === 'mainDefect') {
            this.selectedMainDefect = null;
            this.selectedSubDefect1 = null;
            this.selectedSubDefect2 = null;
            this.mainDefectDisabled = true;
            this.subDefect1Disabled = true;
            this.subDefect2Disabled = true;
        } else if (level === 'subDefect1') {
            this.selectedSubDefect1 = null;
            this.selectedSubDefect2 = null;
            this.subDefect2Disabled = true;
        } else if (level === 'subDefect2') {
            this.selectedSubDefect2 = null;
        }
    }

    filterPicklistValues(picklistData, key) {
        if (!picklistData || !picklistData.values || picklistData.values.length === 0) {
            return [];
        }
        const controllerValues = picklistData.controllerValues;
        const controllerValue = controllerValues[key];
        return picklistData.values.filter(option => option.validFor.includes(controllerValue));
    }
}