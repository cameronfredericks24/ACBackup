/* eslint-disable @lwc/lwc/no-async-operation */
import { LightningElement, track, api, wire } from 'lwc';
import createOrUpdateProductAndAsset from '@salesforce/apex/NonBSLAssetRegistrationController.createOrUpdateProductAndAsset';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import initiateApprovalProcess from '@salesforce/apex/NonBSLAssetRegistrationController.initiateApprovalProcess';
import { NavigationMixin } from 'lightning/navigation';
import attachFilesToAsset from '@salesforce/apex/NonBSLAssetRegistrationController.attachFilesToAsset';

import fetchSubFamily from '@salesforce/apex/NonBSLAssetRegistrationController.fetchProductFamily';
import checkExistingAsset from '@salesforce/apex/NonBSLAssetRegistrationController.checkExistingNonBslAsset';
import fetchProductCodes from '@salesforce/apex/AssetRegistrationController.fetchProductCodes';
import fetchproductCapacity from '@salesforce/apex/NonBSLAssetRegistrationController.fetchproductCapacity';

import getCapacityUOMPicklistValues from '@salesforce/apex/NonBSLAssetRegistrationController.getCapacityUOMPicklistValues';

import LightningAlert from 'lightning/alert';

export default class ProductAssetForm extends NavigationMixin(LightningElement) {
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

    @track filteredOptionsFamily = [];
    @track showSubFamily = false;
    @track subFamilyId;
    @track subFamilyName;

    disableButton = false;
    showAddress = false;
    showDetails = true;
    @track isChecked = false;
    uploadedFileLst = [];

    @track uploadedFileNames = [];
    @track isFileUploaded = false;

    @track showAvailableCodes = false;

    @track filteredOptionsProductCode = [];

    @track isMobileDevice = false;

    @track capacityUOM;
    @track capacity;

    @track capacityUOMOptions = [];

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

        this.loadProductSubFamily();
        this.loadCapacityUOMPicklistValues();


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
        fetchProductCodes({ searchTerm: searchTermProductCode })
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

    // handleUploadFinished(event) {
    //     const uploadedFiles = event.detail.files;
    //     uploadedFiles.forEach(file => this.uploadedFileLst.push(file.documentId));
    // }

    handleUploadFinished(event) {

        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
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

        if (this.othersSelected === true && (this.vendorName === '' || this.vendorName === null)) {

            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Please enter the vendor name',
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
        if (this.capacity === '' || this.capacity === null || this.capacity === undefined) {

            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Please enter valid capacity',
                variant: 'error'
            }));

            this.showSpinner = false;
            this.disableButton = false;


            return;

        }

        if (!this.make || !this.model || !this.serial || !this.installationDate || !this.invoiceDate || !this.prodName || !this.installationDate || !this.invoiceDate || !this.capacity || !this.capacityUOM) {


            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Please fill all the fields',
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

                }
                else {

                    this.showSpinner = true;


                    createOrUpdateProductAndAsset({
                        accountId: this.accountId,
                        prodName: this.prodName,
                        make: this.make,
                        model: this.model,
                        serial: this.serial,
                        installationDate: this.installationDate,
                        invoiceDate: this.invoiceDate,
                        checked: this.isChecked,
                        wtyStartDate: this.wtyStartDate,
                        wtyEndDate: this.wtyEndDate,
                        cpId: this.cpId,
                        branchId: this.branchId,
                        vendorName: this.vendorName,
                        subFamilyId: this.subFamilyId,
                        capacity: this.capacity,
                        capacityUOM: this.capacityUOM
                       
                    })
                        .then(result => {
                            this.showSpinner = false;

                            if (result.existingAsst) {

                                this.dispatchEvent(new ShowToastEvent({
                                    title: 'Success',
                                    message: 'Asset is already Created/Registered',
                                    variant: 'success'
                                }));
                            } else {
                                this.assetId = result.ast.Id;

                                if (this.isMobileDevice !== true) {

                                    if (this.uploadedFileNames.length > 0) {
                                        attachFilesToAsset({ assetId: this.assetId, fileIds: this.uploadedFileLst })
                                            .then(() => {
                                                this.dispatchEvent(new ShowToastEvent({
                                                    title: 'Success',
                                                    message: 'Asset created successfully',
                                                    variant: 'success'
                                                }));

                                                this.showDetails = false;
                                                this.showAddress = true;
                                                this.showSpinner = false;

                                            })
                                            .catch(error => {
                                                this.dispatchEvent(new ShowToastEvent({
                                                    title: 'Error',
                                                    message: 'Asset created but failed to attach files',
                                                    variant: 'error'
                                                }));
                                            });
                                    } else {
                                        console.log('please upload file');
                                        this.dispatchEvent(new ShowToastEvent({
                                            title: 'Error',
                                            message: 'Please Upload File!',
                                            variant: 'error'
                                        }));
                                        this.showSpinner = false;

                                    }

                                }

                                this.inputVariables = [
                                    {
                                        name: 'recordId',
                                        type: 'String',
                                        value: this.accountId
                                    },
                                    {
                                        name: 'assetId',
                                        type: 'String',
                                        value: result.ast.Id
                                    }
                                ];
                            }

                            // Emit custom event with the serial number
                            const assetRegisterSuccess = new CustomEvent('assetregistersuccess', {
                                detail: { serialNumber: this.serialNumber }
                            });
                            this.dispatchEvent(assetRegisterSuccess);
                        })
                        .catch(error => {
                            this.showSpinner = false;

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
}