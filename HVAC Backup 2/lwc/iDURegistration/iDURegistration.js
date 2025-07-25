import { LightningElement, track, api, wire } from 'lwc';
import createOrUpdateProductAndAsset from '@salesforce/apex/NonBSLAssetRegistrationController.createOrUpdateProductAndAsset';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import initiateApprovalProcess from '@salesforce/apex/NonBSLAssetRegistrationController.initiateApprovalProcess';
import { NavigationMixin } from 'lightning/navigation';
import attachFilesToAsset from '@salesforce/apex/NonBSLAssetRegistrationController.attachFilesToAsset';

import fetchSubFamily from '@salesforce/apex/NonBSLAssetRegistrationController.fetchProductFamily';
import checkExistingAsset from '@salesforce/apex/NonBSLAssetRegistrationController.checkExistingNonBslAsset';
import fetchProductCodes from '@salesforce/apex/IDURegisterationController.fetchProductCodes';
import fetchproductCapacity from '@salesforce/apex/NonBSLAssetRegistrationController.fetchproductCapacity';
import fetchParent from '@salesforce/apex/IDURegisterationController.fetchParent';
import createChildAssetRecord from '@salesforce/apex/IDURegisterationController.createChildAssetRecord';
import createWOLI from '@salesforce/apex/IDURegisterationController.createWOLI';
import { RefreshEvent } from 'lightning/refresh';
import { getBarcodeScanner } from 'lightning/mobileCapabilities';
import { CloseActionScreenEvent } from 'lightning/actions';
import {
    createRecord,
    unstable_createContentDocumentAndVersion
  } from "lightning/uiRecordApi";

import getCapacityUOMPicklistValues from '@salesforce/apex/NonBSLAssetRegistrationController.getCapacityUOMPicklistValues';

import LightningAlert from 'lightning/alert';

export default class IDURegistration extends NavigationMixin(LightningElement) {
    @api recordId ; //'0WO9I000003coA9WAI';
    @track make;
    @track model;
    @track serial;
    @track installationDate;
    @track invoiceDate;
    @track prodName;
    @api accountId;
    @track assetId;
    @track wtyStartDate;
    @track wtyEndDate;
    @track inputVariables = [];
    @track cpId;
    @track branchId;
    @track vendorName;
    @track showSpinner = false;
    assetType = ''; 
    @track assetTypeOptions = [
        { label: 'IDU', value: 'IDU' },
        { label: 'ODU', value: 'ODU' }
    ];

    @track modelMakeOption  = [
        { label: 'BlueStar Manufacturer', value: 'BlueStar Manufacturer' },
        { label: 'Vendor Purchased / Non BlueStar', value: 'Non BlueStar' }
    ];
    @track modelMake = '';

    @track filteredOptionsFamily = [];
    @track showSubFamily = false;
    @track subFamilyId;
    @track subFamilyName;

    @track equipmentLocation;


    disableButton = false;
    showAddress = false;
    showDetails = false;
    @track isChecked = false;
    uploadedFileLst = [];
    @track isDummyChecked = false;

    @track uploadedFileNames = [];
    @track isFileUploaded = false;

    @track showAvailableCodes = false;

    @track filteredOptionsProductCode = [];

    @track isMobileDevice = false;

    @track capacityUOM;
    @track capacity;

    @track capacityUOMOptions = [];

    @track parentSerialNumber;
    @track showAvailableSerialNumber = false;
    @track filteredOptionsSerialNumber=[];
    @track assetCreated = false;
    @track assetRecord={};
    @track parentNotpresent = false;
    @track fromFSL = false;
    myScanner;
    @track fileUploadedFromFSL=false;
    @track contentDocumentIds = [];
    @track productsubFamily;
    @track numberLabel;
    @track assetCreatedList = [];
    @track totalIDU;
    @track totalAssetCreated=1;
    @track showInput = true;
    @track createLineItem=false;
    @track workOrder={};
    @track modelNumber;
    @track productSubFamilyName;
    @track productMake;
    @track department;
    @track showInputBox;
    @track errorMessage;
    @track showSTLICheckBox=true;
    // Dropdown options for Make
    get makeOptions() {
        return [
            { label: 'Bluestar', value: 'Bluestar' },
            { label: 'LG', value: 'LG' },
            { label: 'LLoyd', value: 'LLoyd' },
            { label: 'Haier', value: 'Haier' },
            { label: 'VOLTAS', value: 'VOLTAS' },
            { label: 'GODREJ', value: 'GODREJ' },
            { label: 'DAIKIN', value: 'DAIKIN' },
            { label: 'CARRIER', value: 'CARRIER' },
            { label: 'Others', value: 'Others' }
        ];
    }

    connectedCallback() {


        this.isMobileDevice = this.checkMobileDevice();
        this.loadParentSerialNumber();
        this.myScanner = getBarcodeScanner();
        console.log('recordsId',this.recordId);
        this.fromFSL =  this.checkMobileDevice();
    }



    checkMobileDevice() {
        const userAgent = navigator.userAgent;
        const mobileDeviceRegex = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i;
        return mobileDeviceRegex.test(userAgent);
    }

    loadCapacityUOMPicklistValues() {
        getCapacityUOMPicklistValues()
            .then((result) => {
                if (result) {
                    this.capacityUOMOptions = result.map((value) => {
                        return { label: value, value: value };
                    });
                }


            })
            .catch((error) => {
                console.error('Error fetching picklist values:', error);
            });
    }

    handleCapacityUOMChange(event) {
        this.capacityUOM = event.target.value;

        console.log('capacityUOM -- ' + this.capacityUOM);
    }

    handleCapacityChange(event) {
        this.capacity = event.target.value;

        console.log('capacity -- ' + this.capacity);

    }

    loadProductSubFamily(serachSubFamily) {
        fetchSubFamily({ searchTerm: serachSubFamily })
            .then(result => {
                if (result) {
                    this.filteredOptionsFamily = result.map(family => ({
                        label: family.Name,
                        value: family.Id
                    }));
                } else {
                    this.filteredOptionsFamily = [];
                }
                console.log('filteredOptionsFamily -- ' + JSON.stringify(this.filteredOptionsFamily));



            })
            .catch(error => {
                console.error('Error fetching product codes', error);
            });
    }

    handleOnClickCustomLookupProductSubFamily(event) {
        try {
            if (this.filteredOptionsFamily && this.filteredOptionsFamily.length > 0) {
                this.showSubFamily = true;
            } else {
                this.showSubFamily = false;
            }
            console.log('filteredOptionsFamily on click - ', this.filteredOptionsFamily.length);
        } catch (error) {
            console.log('error - ', error);
        }
    }


    handleOnChangeCustomLookupSubFamily(event) {

        const serachSubFamily = event.detail.value.toLowerCase();

        console.log('serachSubFamily  - ', serachSubFamily);

        this.loadProductSubFamily(serachSubFamily);

    }

    handleOnFocusCustomLookupProductSubFamily() {
        this.showSubFamily = true;
    }

    handleOnBlurCustomLookupProductSubFamily() {
        // Using setTimeout to wait a bit before hiding options so click on options can be captured
        setTimeout(() => {
            this.showSubFamily = false;
        }, 300);
    }

    handleOptionClickProductSubFamily(event) {

        this.subFamilyId = event.currentTarget.dataset.value;
        this.subFamilyName = event.currentTarget.dataset.name;

        console.log(' subFamilyId 964 - ' + this.subFamilyId);
        console.log(' subFamilyName 964 - ' + this.subFamilyName);

        this.showSubFamily = false;
    }


    handleMakeChange(event) {
        this.othersSelected = false;
        this.make = event.detail.value;
        if (this.make === "Others") {
            this.othersSelected = true;
        }
    }

    handleVendorNameChange(event) {
        this.vendorName = event.detail.value;

    }


    loadProductCodes(searchTermProductCode) {
        fetchProductCodes({ searchTerm: searchTermProductCode, productSubFamily: this.productsubFamily })
            .then(result => {
                console.log('product codes -- ' + JSON.stringify(result));
                const productSet = new Set(result); // Using Set to store unique product codes
                this.filteredOptionsProductCode = Array.from(productSet).map(productCode => {
                    return { label: productCode, value: productCode };
                });

                //this.showAvailableCodes = this.filteredOptionsProductCode.length > 0;
                console.log('filteredOptionsProductCode -- ' + JSON.stringify(this.filteredOptionsProductCode));

            })
            .catch(error => {
                console.error('Error fetching product codes', error);
            });
    }

    loadParentSerialNumber(searchTermSerialNumber) {
        fetchParent({ recordId : this.recordId })
            .then(result => {
                if(result.Id!=null){
                    if(result.AssetId!=null){
                        this.workOrder = result;
                        this.modelNumber = result.Asset.Model_Number__c;
                        this.productSubFamilyName = result.Asset.Product_Sub_Family__r.Name;
                        this.department = result.Asset.Service_Department_L__r.Name;
                        this.productMake = result.Asset.Asset_type__c;

                        this.parentSerialNumber = result.Asset.SerialNumber;
                        this.productsubFamily = result.Asset.Product_Sub_Family__c;
                        this.parentNotpresent=false;
                        if(result.RecordType.Name=='PMS'){
                            this.showSTLICheckBox = false;
                        }
                    }else{
                        this.errorMessage = 'Please tag an asset first on service ticket before proceeding.';
                        this.parentNotpresent=true;
                    }
                }else{
                    this.errorMessage = 'A new asset cannot be created for this work type or at this current status.';
                    this.parentNotpresent=true;
                }
                
                console.log('parent serial number -- ' + JSON.stringify(result));

                //this.showAvailableCodes = this.filteredOptionsProductCode.length > 0;
                //console.log('filteredOptionsSerialNumber -- ' + JSON.stringify(this.filteredOptionsSerialNumber));

            })
            .catch(error => {
                console.error('Error fetching product codes', error);
            });
    }

    handleOnClickCustomLookupProductCode(event) {

        try {

            this.loadProductCodes();

            console.log('filteredOptionsProductCode on click - ', this.filteredOptionsProductCode.length);
            this.showAvailableCodes = this.filteredOptionsProductCode.length > 0;

            console.log('showAvailableCodes on click - ', this.showAvailableCodes);

        }
        catch (error) {
            console.log('error - ', error);

        }
    }

    handleOnChangeCustomLookupProductCode(event) {

        const searchTermProductCode = event.target.value.toLowerCase();

        //this.model = event.target.value;

        console.log('searchTermProductCode  - ', searchTermProductCode);

        this.loadProductCodes(searchTermProductCode);

    }

    handleOnFocusCustomLookupProductCode() {
        this.showAvailableCodes = true;
    }

    handleOnBlurCustomLookupProductCode() {
        // Using setTimeout to wait a bit before hiding options so click on options can be captured
        setTimeout(() => {
            this.showAvailableCodes = false;
        }, 300);
    }

    handleOptionClickProductCode(event) {

        this.model = event.currentTarget.dataset.value;

        console.log(' model 964 - ' + this.model);

    }

     handleModelNumberChangeCustomLookup(event) {
        console.log("option clicked: ");

        this.model = event.currentTarget.dataset.value;

        this.getProductCapacity();

        console.log("this.model: " + this.model);

        this.showAvailableCodes = false;


    }



    getProductCapacity(){


        console.log("method called fetchProductCapacity: " );


         fetchproductCapacity({ productCode: this.model })
            .then(result => {

               console.log('product  1st -- ' + JSON.stringify(result));

                if(result != null){

                    console.log('product  -- ' + JSON.stringify(result));

                    this.capacity = result.Capacity__c;
                    this.capacityUOM = result.Capacity_UOM__c;

                }
             
            })
            .catch(error => {
                console.error('Error fetching product codes', error);
            });



    }





    handleModelChange(event) {
        this.model = event.target.value;
    }

    handleSerialChange(event) {
        this.serial = event.target.value;
    }

    handleProdNameChange(event) { 
        this.prodName = event.target.value;
    }

    handleInstallationDateChange(event) {
    

        let selectedDate = new Date(event.target.value);
        let today = new Date();
        //today.setHours(0, 0, 0, 0); // Set time to the beginning of the day

        console.log('today - ', today);
                console.log('selectedDate - ', selectedDate);


        if (selectedDate > today) {


            // Display error message
            this.errorMessage = 'Future dates are not allowed for installation date.';
            console.error(this.errorMessage);
            this.showToast('', 'Cannot select future date', 'error');

               this.installationDate = null;

        } 

        if (selectedDate <= today) {
                    this.installationDate = event.target.value;
        console.log('installationDate - ', this.installationDate);
            // Clear error message if date is valid
            this.errorMessage = '';
        }

    }

    handleInvoiceDateChange(event) {
        this.invoiceDate = event.target.value;
    
        console.log('invoiceDate - ', this.invoiceDate);

        let selectedDate = new Date(this.invoiceDate);
        let today = new Date();
        //today.setHours(0, 0, 0, 0); // Set time to the beginning of the day

        console.log('today - ', today);

        if (selectedDate > today) {
            // Display error message
            this.errorMessage = 'Future dates are not allowed for installation date.';
            console.error(this.errorMessage);
            this.showToast('', 'Cannot select future date', 'error');

            // Reset the input field
            this.invoiceDate = null;
        } else {
            // Clear error message if date is valid
            this.errorMessage = '';
        }
    }

    handleEquipmentLocationChange(event) {
        this.equipmentLocation = event.detail.value;

        console.log('equipmentLocation - ', this.equipmentLocation);

    }

    handleWtyStartDateChange(event) {
        this.wtyStartDate = event.target.value;
    }

    handleWtyEndDateChange(event) {
        this.wtyEndDate = event.target.value;
    }

    handleCheckboxChange(event) {
        this.isChecked = event.target.checked;
        if (this.isChecked) {
            this.showWty = true;
        } else {
            this.showWty = false;
        }
    }
    handleDummyCheckboxChange(event) {
        this.isDummyChecked = event.target.checked;
    }

    // handleUploadFinished(event) {
    //     const uploadedFiles = event.detail.files;
    //     uploadedFiles.forEach(file => this.uploadedFileLst.push(file.documentId));
    // }

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        

        // Get the list of uploaded files
        
        uploadedFiles.forEach(file => this.uploadedFileLst.push(file.documentId));

        //let uploadedFileNames = '';
        for (let i = 0; i < uploadedFiles.length; i++) {
            //this.uploadedFileNames.push(uploadedFiles[i].name);
            this.uploadedFileNames.push({
                name: uploadedFiles[i].name,
                id: uploadedFiles[i].documentId
            });
            this.isFileUploaded = true;
        }
        // Extract file names into a string
        const fileNames = this.uploadedFileNames.map(file => file.name).join(', ');

        this.dispatchEvent(
            new ShowToastEvent({
                title: "Success",
                message: uploadedFiles.length + " Files uploaded Successfully: " + fileNames,
                variant: "success"
            })
        );
        console.log("uploadedFileNames -- " + this.uploadedFileNames);
        console.log("isFileUploaded -- " + this.isFileUploaded);
    }

    handleAccountChange(event) {
        // Handle account change
        this.cpId = event.target.value;
        console.log('cpId -- ' + this.cpId);

    }

    handleBranchChange(event) {
        // Handle branch change
        this.branchId = event.target.value;
        console.log('branchId -- ' + this.branchId);
    }

    handleSubmit() {

        console.log('model -- ' + this.model);

        this.showSpinner = true;

        this.disableButton = true;

        if(this.modelMake!=this.workOrder.Asset.Asset_type__c && this.workOrder.Asset.Asset_type__c!=null){

            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Please select the product make same as parent asset.',
                variant: 'error'
            }));

            this.showSpinner = false;
            this.disableButton = false;


            return;
        }
        if (this.model === '' || this.model === null || this.model === undefined) {

            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Please select a valid model number',
                variant: 'error'
            }));

            this.showSpinner = false;
            this.disableButton = false;


            return;

        }
      

        if (!this.model || !this.serial || !this.modelMake) {


            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Please fill all the fields',
                variant: 'error'
            }));

            this.showSpinner = false;
            this.disableButton = false;


            return;

        }

        const pattern = /^[A-Za-z0-9-]+$/;
        if (!pattern.test(this.serial)) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Please enter valid serial number. ',
                variant: 'error'
            }));

            this.showSpinner = false;
            this.disableButton = false;
            return;
        } 

        if (this.uploadedFileNames.length == 0 && this.fromFSL==false) {

            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Please upload the image',
                variant: 'error'
            }));

            this.showSpinner = false;
            this.disableButton = false;


            return;
        }

        if (this.fileUploadedFromFSL==false && this.fromFSL==true) {

            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Please upload the image',
                variant: 'error'
            }));

            this.showSpinner = false;
            this.disableButton = false;


            return;
        }



        checkExistingAsset({ serialNumber: this.serial })
            .then(result => {

                console.log('result -- ' + result);
                if (result === true) {

                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error',
                        message: 'Asset with serial Number already registered',
                        variant: 'error'
                    }));
                    this.disableButton=false;
                    this.showSpinner = false;

                }
                else {

                    this.showSpinner = true;


                    createChildAssetRecord({
                        model: this.model,
                        serialNumber: this.serial,
                        parentSerialNumber: this.parentSerialNumber,
                        recordId : this.recordId,
                        type :  this.assetType,
                        contentDocumentIds : this.contentDocumentIds,
                        make : this.modelMake
                       
                    })
                        .then(result => {
                            this.showSpinner = false;

                            if (result.Id==null) {

                                this.dispatchEvent(new ShowToastEvent({
                                    title: 'Error',
                                    message: 'Error occured while creating the asset. Please contact your admin.',
                                    variant: 'error'
                                }));
                            } else {
                                this.assetId = result.Id;
                                this.assetRecord = result;
                                this.assetCreated = true;
                                var assetRecordTemp={};

                                assetRecordTemp.serialNumber = result.SerialNumber;
                                assetRecordTemp.Model_Number__c = result.Model_Number__c;
                                assetRecordTemp.make = this.modelMake;
                               // assetRecordTemp.noOfFiles = 2;
                                assetRecordTemp.type = result.Type__c;
                                assetRecordTemp.STLICreated = (this.createLineItem) ? 'Yes' : 'No';
                                assetRecordTemp.index = this.totalAssetCreated;
                                if(this.createLineItem){
                                    this.createSTLI();
                                    this.createLineItem = false;
                                }

                               // this.assetCreatedList.push(assetRecord);
                                

                                this.dispatchEvent(new ShowToastEvent({
                                    title: 'Success',
                                    message: 'Asset created successfully',
                                    variant: 'success'
                                }));

                                if (this.fromFSL==false) {
                                    assetRecordTemp.noOfFiles = this.uploadedFileNames.length;
                                    if (this.uploadedFileNames.length > 0) {
                                        attachFilesToAsset({ assetId: this.assetId, fileIds: this.uploadedFileLst })
                                            .then(() => {
                                                this.uploadedFileNames=[];
                                                this.uploadedFileLst = [];
                                                /*this.dispatchEvent(new ShowToastEvent({
                                                    title: 'Success',
                                                    message: 'Asset created successfully',
                                                    variant: 'success'
                                                }));*/

                                                //this.showDetails = false;
                                                //this.showAddress = true;
                                                this.showSpinner = false;

                                            })
                                            .catch(error => {
                                               /* this.dispatchEvent(new ShowToastEvent({
                                                    title: 'Error',
                                                    message: 'Asset created but failed to attach files',
                                                    variant: 'error'
                                                }));*/
                                            });
                                    } else {
                                        console.log('please upload file');
                                        /*this.dispatchEvent(new ShowToastEvent({
                                            title: 'Error',
                                            message: 'Please Upload File!',
                                            variant: 'error'
                                        }));*/
                                        this.showSpinner = false;

                                    }
                                    //this.showDetails = false;
                                    //this.showAddress = true;
                                    this.showSpinner = false;
                                    

                                }else{
                                   // this.showDetails = false;
                                   assetRecordTemp.noOfFiles = this.contentDocumentIds.length;
                                   this.contentDocumentIds = [];
                                    this.showAddress = true;
                                    this.showSpinner = false;
                                    
                                }

                            }
                            this.assetCreatedList.push(assetRecordTemp);
                            this.totalAssetCreated +=1;

                            console.log('this.totalAssetCreated',this.totalAssetCreated);
                            console.log('this.totalIDU',this.totalIDU);
                            if(this.totalAssetCreated<=this.totalIDU){
                                    this.showDetails=true;
                            }else{
                                this.showDetails=false;
                            }
                            this.resetComponent();

                            // Emit custom event with the serial number
                            const assetRegisterSuccess = new CustomEvent('assetregistersuccess', {
                                detail: { serialNumber: this.serialNumber }
                            });
                            this.dispatchEvent(assetRegisterSuccess);
                        })
                        .catch(error => {
                            this.showSpinner = false;
                            this.showSpinner = false;
                            this.disableButton = false;

                            this.dispatchEvent(new ShowToastEvent({
                                title: 'Error',
                                message: error.body.message,
                                variant: 'error'
                            }));
                        })
                        .finally(() => {
                            this.disableButton = false;
                        });

                }
            })
            .catch(error => {
                console.error('Error fetching product codes', error);
            });


    }

     // Method to show toast messages
    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }

    handleOnClickCustomLookupParentSerial(event) {

        try {

            this.loadParentSerialNumber();

            console.log('filteredOptionsProductCode on click - ', this.filteredOptionsSerialNumber.length);
            this.showAvailableSerialNumber = this.filteredOptionsSerialNumber.length > 0;

            console.log('showAvailableCodes on click - ', this.showAvailableSerialNumber);

        }
        catch (error) {
            console.log('error - ', error);

        }
    }

    handleOnChangeCustomLookupParentSerial(event) {

        const searchTermParentSerial = event.target.value.toLowerCase();

        //this.model = event.target.value;

        console.log('searchTermParentSerial  - ', searchTermParentSerial);

        this.loadParentSerialNumber(searchTermParentSerial);

    }

    handleOnFocusCustomLookupParentSerial() {
        this.showAvailableSerialNumber = true;
    }

    handleOnBlurCustomLookupParentSerial() {
        // Using setTimeout to wait a bit before hiding options so click on options can be captured
        setTimeout(() => {
            this.showAvailableSerialNumber = false;
        }, 300);
    }

    handleOptionClickParentSerial(event) {

        this.parentSerialNumber = event.currentTarget.dataset.value;

        console.log(' model 964 - ' + this.parentSerialNumber);

    }

     handleParentSerialChangeCustomLookup(event) {
        console.log("option clicked: ");

        this.parentSerialNumber = event.currentTarget.dataset.value;

        console.log("this.model: " + this.parentSerialNumber);

        this.showAvailableSerialNumber = false;

    }

    
    createSTLI() {
        console.log('woli');
        this.showSpinner = true;
        createWOLI({ iduAsset: this.assetRecord, recordId : this.recordId, type:this.assetType})
            .then(result => {
                this.showSpinner = false;
                if (result.Id==null) {
                    console.log('woli 1');
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error',
                        message: 'Error occured while creating service ticket line item. Please contact your admin.',
                        variant: 'Error'
                    }));
                }else{
                    console.log('woli 2');
                    /*this.dispatchEvent(new ShowToastEvent({
                        title: 'Success',
                        message: 'Service Ticket Line Item created successfully ',
                        variant: 'success'
                    }));*/
                }
                //this.showDetails=true;
               // this.assetCreated = false;
                this.resetComponent();

            })
            .catch(error => {
                this.showSpinner = false;
                console.error('Error creating line item', error);
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: 'Error occured while creating service ticket line item. Please contact your admin.',
                    variant: 'Error'
                }));
            });
    }
    handleYes(){
        this.createSTLI();
    }
    handleNo(){
        this.showDetails=true;
        this.assetCreated = false;
        this.resetComponent();
    }
    handleAssetTypeChange(event) {
        this.assetType = event.detail.value;
        this.showInputBox = true;
        this.numberLabel = 'Number of '+this.assetType;
        console.log('Selected Asset Type:', this.assetType);
    }
    resetComponent(){
        this.model = '';
        this.serialNumber='';
        this.uploadedFileNames = [];
        this.modelMake='';
       // this.assetType='';
        this.isFileUploaded = false;
        this.serial='';
        this.contentDocumentIds = [];
        this.fileUploadedFromFSL = false;
    }
    handleBarcodeClickUnitary(event) {

        //const index = event.target.dataset.index;
        this.scanAsset = true;
        this.scannedBarcode = '';

        if (this.myScanner.isAvailable() || this.myScanner != null) {
            const scanningOptions = {
                barcodeTypes: [
                    this.myScanner.barcodeTypes.QR,
                    this.myScanner.barcodeTypes.UPC_E,
                    this.myScanner.barcodeTypes.EAN_13,
                    this.myScanner.barcodeTypes.CODE_39,
                    this.myScanner.barcodeTypes.CODE_128,
                    this.myScanner.barcodeTypes.CODE_93,
                    this.myScanner.barcodeTypes.EAN_8,
                    this.myScanner.barcodeTypes.UPC_A,
                    this.myScanner.barcodeTypes.UPC_E,
                ],
                instructionText: 'Scan a QR, UPC, EAN 13, Code 39, CODE 128, CODE 93, EAN 8, UPC A, UPC_E',
                successText: 'Scanning complete.'
            };

            this.myScanner.beginCapture(scanningOptions)
                .then((result) => {
                    this.scannedBarcode = result.value;

                    // LightningAlert.open({
                    //     message: 'scannedBarcode - ' + this.scannedBarcode,
                    //     theme: 'success', // a red theme intended for error states
                    //     label: 'scannedBarcode', // this is the header text
                    // });


                    // Check if the event is for ODU or IDU input
                    this.serial = this.scannedBarcode;

                    this.showSerial = true;

                })
                .catch((error) => {
                    this.showSuccess = false;
                    console.error('Error scanning barcode: ', error);
                })
                .finally(() => {
                    this.myScanner.endCapture();
                    // LightningAlert.open({
                    //     message: 'scannedBarcode - ' + this.scannedBarcode,
                    //     theme: 'success', // a red theme intended for error states
                    //     label: 'scannedBarcode', // this is the header text
                    // });


                });
        } else {
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'This Device does not support a scanner.',
                variant: 'error'
            });
            this.dispatchEvent(event);
            this.showSuccess = false;
        }
    }
    handleFileUpload(event){
        this.fileUploadedFromFSL = true;
    }
    getFiles(event){
        if(event.detail!=null && event.detail!='' && event.detail!=undefined){
            this.contentDocumentIds.push(event.detail);
        }
        
    }
    handleModelMakeChange(event){
        this.modelMake = event.detail.value;
        console.log('Selected modelMake', this.modelMake);
    }
    handleIDUNumberChange(event){
        this.totalIDU = event.detail.value;
        
        //this.showDetails=true;
    }

    handleNext(event){
        
        if(this.totalIDU==null || this.totalIDU=='' || this.assetType=='' || this.assetType==null){
            return;
        }else{
            this.showDetails=true;
        this.showInput = false;
        }
    }
    handleCheckboxChange(event){
        this.createLineItem = event.target.checked;
    }
    handleClose(event){ 

       this.disableButton=true;
                this.showSpinner=false;
                console.log('Navigate ');
                var result = this.recordId;
                console.log('window.location',window.location.pathname);
                if( (window.location.pathname).includes('channelpartnerportal')){
                    console.log('window.location',window.location);
                    window.location =  `${window.location.origin}/channelpartnerportal/s/detail/${result}`;
                }else{
                    window.location = `${window.location.origin}/${result}`;
                }
               
              
            
    }

}