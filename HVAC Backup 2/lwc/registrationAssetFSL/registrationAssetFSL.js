/* eslint-disable no-dupe-class-members */
/* eslint-disable radix */
/* eslint-disable @lwc/lwc/no-api-reassignments */
/* eslint-disable @lwc/lwc/no-async-operation */
import { LightningElement, track, api, wire } from 'lwc';
import { getBarcodeScanner } from 'lightning/mobileCapabilities';
import LightningAlert from 'lightning/alert';


import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchProductCodes from '@salesforce/apex/AssetRegistrationController.fetchProductCodes';
import fetchAccount from '@salesforce/apex/AssetRegistrationController.fetchAccount';
import getCustomerType from '@salesforce/apex/AssetRegistrationController.fetchAccountType';
import saveProductdetails from '@salesforce/apex/AssetRegistrationController.saveAssetDetails';

import fetchAssetsFromSAP from "@salesforce/apex/AssetDetailsDisplayScreenController.fetchAssetsFromSAP";
import fetchSplitAssetsFromSAP from "@salesforce/apex/AssetDetailsDisplayScreenController.fetchAssetsFromSAP";
import getServiceDepartment from "@salesforce/apex/AssetDetailsDisplayScreenController.getServiceDepartment";

import registerODU from "@salesforce/apex/AssetRegistrationControllerFSL.registerSplitAsset";
import registerIDUAsset from "@salesforce/apex/AssetRegistrationControllerFSL.registerIDU";
import saveSplitDetails from "@salesforce/apex/AssetRegistrationControllerFSL.saveSplitDetails";

import saveUnitaryDetails from "@salesforce/apex/AssetRegistrationControllerFSL.saveUnitaryDetails";
import fetchExistingAsset from "@salesforce/apex/AssetRegistrationControllerFSL.fetchExistingAsset";

import LightningConfirm from 'lightning/confirm';

import createWoliCommercial from "@salesforce/apex/AssetRegistrationControllerFSL.createWoliCommercial";

import registerUnitaryAsset from "@salesforce/apex/AssetRegistrationControllerFSL.registerUnitaryAsset";

//residential
import saveUnitaryDetailsCommercial from "@salesforce/apex/AssetRegistrationControllerFSL.saveUnitaryDetailsCommercial";

const ITEMS_PER_PAGE = 7; // Number of items to display per page

export default class RegistrationAssetFSL extends LightningElement {

    @api recordId;
    @api isInstallation;

    @track accountId;
    @track showSpinner = false;
    @track firstPage = true;
    @track secondPage = false;

    @track isMobileDevice;

    @track nonBSL = false;


    @track serialNumber;

    @track nextButtonVisibility = true;

    @track registrationDetailsVisibility = false;


    @track notUnitary = false;
    @track isUnitary = false;
    @track splitRegistrationDetails = false;

    @track filteredOptionsProductCode = [];
    @track showAvailableCodesUnitary = false;


    @track fetchODUVisibility = false;
    @track fetchIDUVisibility = false;


    @track totalODU;
    @track totalIDU;
    @track serialModelInputVisibility = false;
    @track serialInputs = [];
    @track iduInputs = [];
    @track oduInputs = [];

    @track modelCodes = [];
    @track serviceDepartmentNumber;

    @track assetDetails = [];

    @track iduDetails = [];
    @track oduDetails = [];
    @track iduProducts = [];
    @track oduProducts = [];

    @track unitaryDetails = [];
    @track unitaryProducts = [];


    @track equipmentLocation;



    @track iduAccordionData = [];

    @track logicalUnit;


    @track showODU = false;
    @track showIDU = false;
    @track showIDUSection = false;
    @track showODUSection = false;

    @track scannedBarcode;

    @track showAvailableCodesIDU = false;


    @track gridData = [];
    @track invoiceDetails = {
        INVOICE_NUMBER: "",
        INVOICE_DATE: "",
        CUSTOMER_CODE: "",
        SALES_DEPARTMENT: "",
        SERVICE_DEPARTMENT: "",
        BRANCH_CODE: ""
    };

    @track productOwner;
    @track picklistValue;

    @track hasPromotionalWarranty;
    @track hasExtendedWarranty;

    @track invoiceNumber;
    @api serialNumber; //api because its embedded in the scan asset cmp
    @track productType;
    @track modelNumber;

    @track oduModelNumber;
        @track iduModelNumber;


    @track isBluestar = true;
    @track assetDetailsScreen = false;
    @track assetRegTypeScreen = false;

    @track invoiceNumberScreen = false;
    @track serialNumberScreen = false;

    @track productOptions = [];
    @track filteredOptions = [];
    @track filteredOptionsProductCode = [];
    @track showOptions = false;
    @track showAvailableCodes = false;

    @track selectedOption;

    @track ModelNotFound = false;

    @track assetDetails = [];

    @track selectedItemValue;
    @track selectedInvoice;

    @track customerType;
    @track isResidentialCustomer = false;
    @track residentialRegDetailsVisibility = false;

    @track registeredUnitaryAsset;

    myScanner;

    get productOwnerOptions() {
        return [
            { label: 'Bluestar Manufacturer', value: 'Bluestar Manufacturer' },
            { label: 'Non Bluestar', value: 'Non Bluestar' }
        ];
    }

    get picklistOptions() {
        return [
            { label: 'Model and Serial Number', value: 'Model and Serial Number' },
            { label: 'Invoice Number', value: 'Invoice Number' }
        ];
    }

    get productTypeOptions() {
        return [
            { label: 'Split', value: 'Split' },
            { label: 'Unitary', value: 'Unitary' }
        ];
    }

    connectedCallback() {
        console.log('recordId- ', this.recordId);
        this.isMobileDevice = this.checkMobileDevice();
        this.ModelNotFound = true;

        this.myScanner = getBarcodeScanner();
        //isAvailable() this method Returns true when used on a supported device, and false otherwise.
        if (this.myScanner == null || !this.myScanner.isAvailable()) {
            this.scanButtonDisabled = true;
        }

        //this.loadProductCodes();
        this.getAccount();
        this.fetchCustomerType();

        this.myScanner = getBarcodeScanner();
        console.log('assetDetails', this.assetDetails);

    }



    handleODUBarcodeClick(event) {
        const index = event.target.index;
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
                    //     message: 'oduInputs - ' + JSON.stringify(this.oduInputs),
                    //     theme: 'success', // a red theme intended for error states
                    //     label: 'oduInputs', // this is the header text
                    // });

                    // Check if the event is for ODU or IDU input
                    if (this.oduInputs && this.oduInputs[index]) {
                        this.oduInputs[index].serialNumber = this.scannedBarcode;
                        this.fetchODUVisibility = true;
                    }
                    this.serialNumber = this.scannedBarcode;

                    this.showSerial = true;

                })
                .catch((error) => {
                    this.showSuccess = false;
                    console.error('Error scanning barcode: ', error);
                })
                .finally(() => {
                    this.myScanner.endCapture();


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

    handleIDUBarcodeClick(event) {
        const index = event.target.index;
        this.scanAsset = true;
        this.scannedBarcode = '';

        // LightningAlert.open({
        //     message: 'index - ' + index,
        //     theme: 'success', // a red theme intended for error states
        //     label: 'index', // this is the header text
        // });

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

                    // LightningAlert.open({
                    //     message: 'iduInputs - ' + JSON.stringify(this.iduInputs),
                    //     theme: 'success', // a red theme intended for error states
                    //     label: 'iduInputs', // this is the header text
                    // });

                    // Check if the event is for ODU or IDU input
                    if (this.iduInputs && this.iduInputs[index]) {
                        this.iduInputs[index].serialNumber = this.scannedBarcode;
                        this.fetchIDUVisibility = true;
                    }

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


                    // LightningAlert.open({
                    //     message: 'iduInputs - ' + JSON.stringify(this.iduInputs),
                    //     theme: 'success', // a red theme intended for error states
                    //     label: 'iduInputs', // this is the header text
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



    handleBarcodeClickUnitary(event) {

        const index = event.target.dataset.index;
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
                    this.serialNumber = this.scannedBarcode;

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

    checkMobileDevice() {
        const userAgent = navigator.userAgent;
        const mobileDeviceRegex = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i;
        return mobileDeviceRegex.test(userAgent);
    }


    fetchCustomerType() {
        getCustomerType({
            recordId: this.recordId
        })
            .then(result => {
                this.customerType = result;

                console.log('customerType -- ' + this.customerType);

                if (this.customerType === 'Residential Customer') {
                    this.isResidentialCustomer = true;
                }

            });
    }

    getAccount() {
        fetchAccount({ recordId: this.recordId })
            .then(result => {

                this.accountId = result;

            })
            .catch(error => {
                console.error('Error fetching account', error);
            });
    }


    handleOnClickCustomLookupProductCode(event) {

        try {

            this.loadProductCodes(this.modelNumber);
            this.showAvailableCodes = this.filteredOptionsProductCode.length > 0;


            console.log('filteredOptionsProductCode on click - ', this.filteredOptionsProductCode.length);
        }
        catch (error) {
            console.log('error - ', error);

        }
    }

    handleOnChangeCustomLookupProductCode(event) {

        const searchTermProductCode = event.target.value.toLowerCase();

        this.modelNumber = event.target.value;

        // const index = event.currentTarget.dataset.index;

        // this.oduInputs[index].modelNumber = event.target.value;


        console.log('searchTermProductCode  - ', searchTermProductCode);

        console.log('oduInputs  - ', JSON.stringify(this.oduInputs));


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

        this.modelNumber = event.currentTarget.dataset.value;

        console.log(' modelNumber 964 - ' + this.modelNumber);

    }


    handleProductOwnerChange(event) {
        this.nonBSL = false;

        this.productOwner = event.detail.value;
        console.log('this.productOwner--', this.productOwner);
        this.assetRegTypeScreen = true;

        console.log('this.assetRegTypeScreen--', this.assetRegTypeScreen);

        if (this.productOwner === 'Bluestar Manufacturer') {
            this.isBluestar = true;
        } else {

            this.nonBSL = true;

            this.isBluestar = false;
        }


    }

    handleProductTypeChange(event) {

        this.picklistValue = '';
        this.serialNumberScreen = false;
        this.invoiceNumberScreen = false;
        this.invoiceNumber = "";
        this.modelNumber = "";
        this.serialNumber = "";
        this.unitaryModelSerialVisibility = false;
        this.isUnitary = false;
        this.showODUSection = false;
        this.showODU = false;
        this.showIDUSection = false;
        this.showIDU = false;



        this.productType = event.detail.value;
        console.log(" this.productType- ", this.productType);
        //this.nextButtonVisibility = true;

        if (this.productType === 'Unitary') {
            this.notUnitary = false;
            this.isUnitary = true;
        }
        else {
            this.notUnitary = true;

        }

        this.registrationDetailsVisibility = true;

        console.log(" this.notUnitary- ", this.notUnitary);

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


    handleOnClickCustomLookupProductCodeUnitary(event) {

        try {

            console.log('filteredOptionsProductCode on click - ', this.filteredOptionsProductCode.length);
            this.showAvailableCodesUnitary = this.filteredOptionsProductCode.length > 0;
            console.log('showAvailableCodesUnitary on click - ', this.showAvailableCodesUnitary);

        }
        catch (error) {
            console.log('error - ', error);
        }
    }

    handleOnChangeCustomLookupProductCodeUnitary(event) {

        const searchTermProductCodeUnitary = event.target.value.toLowerCase();

        this.modelNumber = event.target.value;

        console.log('searchTermProductCodeUnitary  - ', searchTermProductCodeUnitary);

        this.loadProductCodes(searchTermProductCodeUnitary);

    }

    handleOnFocusCustomLookupProductCodeUnitary() {
        this.showAvailableCodesUnitary = true;
    }

    handleOnBlurCustomLookupProductCodeUnitary() {
        // Using setTimeout to wait a bit before hiding options so click on options can be captured
        setTimeout(() => {
            this.showAvailableCodesUnitary = false;
        }, 300);
    }

    handleOptionClickProductCodeUnitary(event) {

        this.modelNumber = event.currentTarget.dataset.value;

        console.log(' modelNumber 964 - ' + this.modelNumber);

    }

    handleModelNumberChangeCustomLookupUnitary(event) {
        console.log("option clicked: ");

        this.unitaryModelNumber = event.currentTarget.dataset.value;
        this.modelNumber = event.currentTarget.dataset.value;


        this.showAvailableCodesUnitary = false;

    }

    handleSerialNumberChange(event) {
        this.serialNumber = event.detail.value;
        console.log(" this.serialNumber- ", this.serialNumber);

        //console.log(" this.oduInputs- ", JSON.stringify(this.oduInputs));
    }

    handleIDUNumberChange(event) {
        this.totalIDU = event.detail.value;
    }

    handleODUNumberChange(event) {
        this.totalODU = event.detail.value;
    }


    handleResidentialNext() {

        this.residentialRegDetailsVisibility = true;

        this.updateSerialInputs();
    }

    handleFirstNext(event) {

        this.splitRegistrationDetails = true;

        this.showODUSection = true;
        this.updateSerialInputs();
    }

    updateSerialInputs() {
        const totalIDUs = parseInt(this.totalIDU || 0);
        const totalODUs = parseInt(this.totalODU || 0);

        this.iduInputs = Array.from({ length: totalIDUs }, (_, index) => ({
            id: `IDU_${index}_${Date.now()}`, // Generate a unique key
            serialNumber: "",
            modelNumber: "",
            serialLabel: `IDU Serial Number ${index + 1}`,
            modelLabel: `IDU Model Number ${index + 1}`
        }));

        this.oduInputs = Array.from({ length: totalODUs }, (_, index) => ({
            id: `ODU_${index}_${Date.now()}`, // Generate a unique key
            serialNumber: "",
            modelNumber: "",
            serialLabel: `ODU Serial Number ${index + 1}`,
            modelLabel: `ODU Model Number ${index + 1}`
        }));
    }



    handleModelNumberChangeCustomLookup(event) {
        console.log("option clicked: ");

        const index = event.currentTarget.dataset.index;
        const selectedValue = event.currentTarget.dataset.value;
        this.oduModelNumber = event.currentTarget.dataset.value;
        this.modelNumber = event.currentTarget.dataset.value;
        console.log("index: " + index);
        console.log("selectedValue: " + selectedValue);

        this.oduInputs[index].modelNumber = selectedValue;

        console.log("oduInputs: ", JSON.stringify(this.oduInputs));

        this.showAvailableCodes = false;

    }

    handleODUSerialNumberChange(event) {
        const index = event.target.dataset.index;
        const value = event.target.value;
        this.serialNumber = event.detail.value;

        this.oduInputs[index].serialNumber = value;
        //this.nextButtonVisibility = true;

        console.log("Updated oduInputs: ", JSON.stringify(this.oduInputs));

        this.fetchODUVisibility = true;
    }

    handleEquipmentLocationChange(event) {
        this.equipmentLocation = event.detail.value;

        console.log('equipmentLocation - ', this.equipmentLocation);

    }


    handleInstallationDateChange(event) {
        this.installationDate = event.detail.value;
        console.log('installationDate - ', this.installationDate);

        let selectedDate = new Date(this.installationDate);
        let today = new Date();
        //today.setHours(0, 0, 0, 0); // Set time to the beginning of the day

        console.log('today - ', today);

        if (selectedDate > today) {
            // Display error message
            this.errorMessage = 'Future dates are not allowed for installation date.';
            console.error(this.errorMessage);
            this.showToast('', 'Cannot select future date', 'error');

            // Reset the input field
            this.installationDate = null;
        } else {
            // Clear error message if date is valid
            this.errorMessage = '';
        }

    }

    handleFetchODU() {
        this.showSpinner = true;

        LightningAlert.open({
            message: 'modelNumber - ' + this.oduModelNumber,
            theme: 'success', // a red theme intended for error states
            label: 'modelNumber', // this is the header text
        });


        LightningAlert.open({
            message: 'serialNumber - ' + this.serialNumber,
            theme: 'success', // a red theme intended for error states
            label: 'serialNumber', // this is the header text
        });

        // Validate modelNumber - serialNumber
        if (!this.oduModelNumber || !this.serialNumber) {
            this.showSpinner = false;
            this.showToast("Error", "Model or Serial number missing,Please select model from the dropdown", "error");
            return;
        }

        try {

            fetchSplitAssetsFromSAP({
                modelNumber: this.oduModelNumber,
                serialNumber: this.serialNumber,
                invoiceNumber: this.invoiceNumber
            })
                .then((result) => {
                    console.log("Response from Apex method:", result);

                    if (!result) {
                        this.showToast("Error", "No Asset details found", "error");
                        this.showSpinner = false;
                    } else if (result === 'failure') {
                        this.showToast("Error", "Asset already registered", "error");
                        this.showSpinner = false;
                    }
                    else if (result === 'Read timed out') {
                        this.showToast("Error", "SAP server is down, please try after sometime", "error");
                        this.showSpinner = false;

                    }

                    else {
                        this.oduDetails = JSON.parse(JSON.parse(result));
                        console.log("oduDetails:", JSON.stringify(this.oduDetails));

                        if (Array.isArray(this.oduDetails) && this.oduDetails.length > 0) {
                            const parsedData = this.oduDetails[0];
                            console.log("Parsed Data:", parsedData);
                            console.log("Parsed Data DEPARTMENT:", parsedData.DEPARTMENT);

                            // Check if MESSAGE contains "No invoice found"
                            if (parsedData.MESSAGE && parsedData.MESSAGE === "No invoice found") {
                                this.showToast("Error", "No Asset details found in SAP", "error");
                                this.showSpinner = false;
                                return; // Stop further processing
                            }


                            this.serviceDepartmentNumber = this.fetchServiceDepartment(parsedData.DEPARTMENT);
                            console.log("serviceDepartmentNumber:", this.serviceDepartmentNumber);

                            this.showODU = true;

                            this.invoiceDetails = {
                                INVOICE_NUMBER: parsedData.INVOICE_NUMBER,
                                INVOICE_DATE: parsedData.INVOICE_DATE,
                                CUSTOMER_CODE: parsedData.CUSTOMER_CODE,
                                CP_CODE: parsedData.CP_CODE,
                                SALES_DEPARTMENT: parsedData.DEPARTMENT,
                                SERVICE_DEPARTMENT: this.serviceDepartmentNumber,
                                BRANCH_CODE: parsedData.BRANCH_CODE
                            };

                            this.invoiceDate = parsedData.INVOICE_DATE;

                            if (Array.isArray(parsedData.PRODUCT)) {
                                this.oduProducts = parsedData.PRODUCT;

                            }

                        }
                        else {
                            this.showToast("Error", "No Asset details found", "error");
                        }

                        this.showSpinner = false;
                        console.log("showSpinner", this.showSpinner);
                    }
                })
                .catch((error) => {
                    console.log("Error in calling Apex method:", error.message);
                    this.showToast("Error", "No Asset details found", "error");
                    this.showSpinner = false;
                });

        } catch (error) {

            console.log("Error in calling Apex :", error.message);


        }

    }


    fetchServiceDepartment(serviceDepartmentNumber) {

        getServiceDepartment({ serviceDepartmentNumber: serviceDepartmentNumber })
            .then(result => {
                console.log('service department--', result);
                return result;

            })
            .catch(error => {
                console.error('Error fetching department:', error);
                return null;
            });
    }


    handleRegisterODU() {
        this.showSpinner = true;

        console.log("register odu called:");

        if (this.installationDate === null || this.installationDate === '' || this.installationDate === undefined) {

            this.showToast("Error", "Installation Date is required", "error");
            this.showSpinner = false;
            return;

        }
        if(this.invoiceDate > this.installationDate){

            this.showToast("Error", "Invoice Date cannot be greater than the Installation Date", "error");
            this.showSpinner = false;
            return;

        }

        console.log("this.oduInpu--" + this.oduInputs);


        // Validate Model Number in oduInputs
        const missingModelNumbers = this.oduInputs.some(odu => !odu.modelNumber || odu.modelNumber.trim() === '');
        if (missingModelNumbers) {
            this.showToast("Error", "Model Number is required for all ODU inputs", "error");
            this.showSpinner = false;
            return;
        }

        try {
            registerODU({
                modelCodes: this.modelCodes,
                assetDetails: JSON.stringify(this.oduDetails),
                address: null,
                accountId: this.accountId,
                workOrderId: this.recordId,
                installationDate: this.installationDate,
                productType: this.productType,
                solId: this.solId,
                logicalUnit: null,
                equipmentLocation: this.equipmentLocation
            })
                .then((result) => {
                    console.log("result 592 - ", result);

                    this.showSpinner = false;

                    if (result != null) {

                        this.logicalUnit = result;

                        console.log("logicalUnit 463 - ", this.logicalUnit);

                        this.showToast("Success", "ODU registered successfully", "success");
                        this.showIDUSection = true;
                        this.registerODUButtonVisibility = true;

                        console.log("registerODUButtonVisibility 463 - ", this.registerODUButtonVisibility);


                        //this.createWOLIforCommercialScenario(this.logicalUnit);

                    }

                    else {

                        this.showToast("Error", "ODU registration failed", "error");
                    }

                })
                .catch((error) => {
                    // Handle error
                    console.error("Error in calling Apex method:", error);
                    this.addProduct = false;
                    this.showSpinner = false;
                    this.showToast("Error", "Product registration failed", "error");

                    return error;
                });
        } catch (error) {
            console.log("error 477 - ", error.message);
            console.log("result 592 - ", error.lineNumber);
        }
    }

    createWOLIforCommercialScenario(asset) {
        console.log("Create WOLI called--- ");

        createWoliCommercial({
            oduDetails: this.oduInputs,
            iduDetails: this.iduInputs,
            installationDate: this.installationDate,
            workOrderId: this.recordId,
            accountId: this.accountId,
            registeredAsset: asset
        })
            .then((result) => {
                console.log("WOLI created--- " + result);

                console.log("WOLI created--- ");

                this.oduInputs = null;
            })
            .catch((error) => {
                console.log("WOLI creation failed--- ");
                console.log("WOLI creation failed--- " + error);
            });
    }


    handleIDUOnChangeCustomLookupProductCode(event) {
        const searchTermProductCode = event.detail.value;

        // const index = event.currentTarget.dataset.index;

        // this.iduInputs[index].modelNumber = searchTermProductCode;

        this.loadProductCodes(searchTermProductCode);
    }

    handleIDUOnClickCustomLookupProductCode(event) {
        const index = event.currentTarget.dataset.index;
        console.log('index - ', index);

        this.iduInputs[index].showAvailableCodesIDU = this.filteredOptionsProductCode.length > 0;
        console.log('iduInputs on click - ', JSON.stringify(this.iduInputs));

        this.loadProductCodes();

        console.log('filteredOptionsProductCode on click - ', this.filteredOptionsProductCode.length);
    }

    handleIDUOnBlurCustomLookupProductCode(event) {
        const index = event.currentTarget.dataset.index;
        // Using setTimeout to wait a bit before hiding options so click on options can be capture
        setTimeout(() => {
            this.iduInputs[index].showAvailableCodesIDU = false;
        }, 300);

    }

    handleIDUOnFocusCustomLookupProductCode(event) {
        const index = event.currentTarget.dataset.index;
        this.iduInputs[index].showAvailableCodesIDU = true;
    }


    handleIDUModelNumberChangeCustomLookup(event) {
        const index = event.currentTarget.dataset.index;
        const selectedValue = event.currentTarget.dataset.value;
        const selectedProductCode = event.currentTarget.dataset.productcode;

        this.iduInputs[index].modelNumber = selectedValue;
        this.iduInputs[index].showAvailableCodesIDU = false;

        console.log('iduInputs on click - ', JSON.stringify(this.iduInputs));

    }

    handleIDUModelNumberChange(event) {
        const index = event.target.dataset.index;
        const value = event.target.value;
        this.iduInputs[index].modelNumber = value;

        console.log("Updated iduInputs: ", JSON.stringify(this.iduInputs));
    }


    handleIDUSerialNumberChange(event) {
        const index = event.target.dataset.index;
        const value = event.target.value;
        this.iduInputs[index].serialNumber = value;
        //this.nextButtonVisibility = true;

        console.log("Updated iduInputs: ", JSON.stringify(this.iduInputs));

        this.fetchIDUVisibility = true;
    }

    handleFetchIDU() {
        this.modelCodes = [];
        this.showSpinner = true;

        // // Validate installation date
        // if (this.isInstallation === true && (!this.installationDate || this.installationDate === null)) {
        //     this.showSpinner = false;
        //     this.showToast("Error", "Please fill the Installation Date", "error");
        //     return;
        // }


        // Validate Model Number in oduInputs
        const missingModelNumbersIDU = this.iduInputs.some(idu => !idu.modelNumber || idu.modelNumber.trim() === '');
        if (missingModelNumbersIDU) {
            this.showToast("Error", "Please select valid model number from the dropdown for IDU", "error");
            this.showSpinner = false;
            return;
        }

        console.log('iduInputs-- ' + JSON.stringify(this.iduInputs));

        // Collect all serial and model numbers
        let serialModelData = this.iduInputs.map(input => {
            return {
                serialNumber: input.serialNumber,
                modelNumber: input.modelNumber
            };
        });

        console.log(' serialModelData-- ' + JSON.stringify(serialModelData));


        // Call Apex method for each set of serial and model numbers
        Promise.all(
            serialModelData.map(data =>
                fetchSplitAssetsFromSAP({
                    modelNumber: data.modelNumber,
                    serialNumber: data.serialNumber,
                    invoiceNumber: this.invoiceNumber
                })
            )
        ).then((results) => {
            this.iduDetails = [];
            console.log('idu result --' + results);
            results.forEach(result => {

                if (!result) {
                    this.showToast("Error", "No Asset details found", "error");
                    this.showSpinner = false;
                } else if (result === 'failure') {
                    this.showToast("Error", "Asset already registered", "error");
                    this.showSpinner = false;
                }
                else if (result === 'Read timed out') {
                    this.showToast("Error", "SAP server is down, please try after sometime", "error");
                    this.showSpinner = false;
                }
                else {
                    let parsedData = JSON.parse(JSON.parse(result));
                    this.iduDetails.push(parsedData);

                    if (Array.isArray(parsedData) && parsedData.length > 0) {
                        this.iduAccordionData.push(parsedData[0]);

                        // Check if MESSAGE contains "No invoice found"
                        if (parsedData.MESSAGE && parsedData.MESSAGE === "No invoice found") {
                            this.showToast("Error", "No Asset details found in SAP", "error");
                            this.showSpinner = false;
                            return; // Stop further processing
                        }

                        this.invoiceDetails = {
                            INVOICE_NUMBER: parsedData.INVOICE_NUMBER,
                            INVOICE_DATE: parsedData.INVOICE_DATE,
                            CUSTOMER_CODE: parsedData.CUSTOMER_CODE,
                            CP_CODE: parsedData.CP_CODE,
                            SALES_DEPARTMENT: parsedData.DEPARTMENT,
                            SERVICE_DEPARTMENT: this.serviceDepartmentNumber,
                            BRANCH_CODE: parsedData.BRANCH_CODE
                        };

                        console.log('this.invoiceDetails -- ' + JSON.stringify(this.invoiceDetails));

                        parsedData[0].PRODUCT.forEach(product => {
                            this.modelCodes.push(product.MODEL_CODE);
                            if (Array.isArray(product.CHILD_PRODUCTS)) {
                                product.CHILD_PRODUCTS.forEach(childProduct => {
                                    this.modelCodes.push(childProduct.MODEL_CODE);
                                });
                            }
                            if (Array.isArray(product.SUBCOMPONENT)) {
                                product.SUBCOMPONENT.forEach(subcomponent => {
                                    this.modelCodes.push(subcomponent.MODEL_CODE);
                                });
                            }
                        });
                    }
                }
            });

            if (this.iduDetails.length > 0) {
                this.showIDU = true;
            } else {
                this.showToast("Error", "No Asset details found", "error");
            }

            this.showSpinner = false;
            console.log("showSpinner", this.showSpinner);
            console.log("modelCodes", this.modelCodes);
        }).catch((error) => {
            console.error("Error in calling Apex method:", error);
            this.showToast("Error", "No Asset details found", "error");
            this.showSpinner = false;
        });
    }


    handleRegisterIDU() {
        this.showSpinner = true;

        try {

            // Validate installation date
            // if (this.isInstallation === true && (!this.installationDate || this.installationDate === null)) {
            //     this.showSpinner = false;
            //     this.showToast("Error", "Please fill the Installation Date", "error");
            //     return;
            // }

            this.iduDetails.forEach(idu => {

                console.log("idu 462 - ", idu);

                registerIDUAsset({
                    modelCodes: this.modelCodes,
                    assetDetails: JSON.stringify(idu),
                    address: null,
                    accountId: this.accountId,
                    workOrderId: this.recordId,
                    installationDate: this.installationDate,
                    productType: this.productType,
                    isAddressChanged: null,
                    selectedAddressId: this.selectedAddressId,
                    solId: this.solId,
                    logicalUnit: this.logicalUnit,
                    cpAccountId: null

                })
                    .then((result) => {
                        console.log("result 592 - ", result);
                        this.showSpinner = false;

                        if (result != null) {
                            this.showToast("Success", "IDU registered successfully", "success");


                            //create WOLI
                            this.createWOLIforCommercialScenario(result);

                            // Emit custom event on back click
                            const nextClick = new CustomEvent('registersuccess', {});
                            this.dispatchEvent(nextClick);

                            //reset the form----------------------------------------------------
                            this.showSpinner = false;
                            this.productOwner = '';
                            this.regtypeVisibility = false;
                            this.assetRegTypeScreen = false;
                            this.productType = '';
                            this.picklistValue = '';
                            this.notUnitary = '';
                            this.totalODU = '';
                            this.totalIDU = '';
                            this.modelNumber = '';
                            this.serialNumber = '';
                            this.invoiceNumber = '';
                            this.selectedAddress = '';
                            this.installationDate = '';
                            this.solId = '';

                            this.notUnitary = false;
                            this.invoiceNumberScreen = false;
                            this.nextButtonVisibility = false;
                            this.unitaryModelSerialVisibility = false;
                            this.isNAMO = false;
                            this.showODU = false;
                            this.showIDU = false;
                            this.assetDetailsScreen = false;
                            this.isFileUploaded = false;
                            this.secondPage = false;

                            this.serialModelInputVisibility = false;
                            this.assetDetailsScreen = false;
                            this.oduInputs = [];
                            this.iduInputs = [];

                            this.oduProducts = [];
                            this.iduProducts = [];
                            this.iduAccordionData = [];


                        }
                        else {
                            this.showSpinner = false;
                            this.showToast("Error", "Product registration failed", "error");

                        }
                    })
                    .catch((error) => {
                        // Handle error
                        console.error("Error in calling Apex method:", error);
                        this.addProduct = false;
                        this.showSpinner = false;
                        this.showToast("Error", "Product registration failed", "error");

                    });

            });

        } catch (error) {

            console.log("error -- " + error.message);

        }
    }

    async handleRegisterResidentialSplit() {

        const result = await LightningConfirm.open({
            message: 'Are you sure you want to submit!?',
            variant: 'headerless',
            label: 'Are you sure you want to submit!?',
            // setting theme would have no effect
        });

        this.showSpinner = true;


        if (result === true) {

            this.asyncSplitRegistration();

        }
        else {

            this.showSpinner = false;

        }


    }

    asyncSplitRegistration() {

        this.showSpinner = true;

        // Validate installation date
        if (!this.installationDate || this.installationDate === null) {
            this.showSpinner = false;
            this.showToast("Error", "Please fill the Installation Date", "error");
            return;
        }

        // Validate Model Number in oduInputs
        const missingModelNumbers = this.oduInputs.some(odu => !odu.modelNumber || odu.modelNumber.trim() === '');
        if (missingModelNumbers) {
            this.showToast("Error", "Please select valid model number from the dropdown for ODU", "error");
            this.showSpinner = false;
            return;
        }

        // Validate Model Number in oduInputs
        const missingModelNumbersIDU = this.iduInputs.some(idu => !idu.modelNumber || idu.modelNumber.trim() === '');
        if (missingModelNumbersIDU) {
            this.showToast("Error", "Please select valid model number from the dropdown for IDU", "error");
            this.showSpinner = false;
            return;
        }

        saveSplitDetails({
            oduDetails: this.oduInputs,
            iduDetails: this.iduInputs,
            installationDate: this.installationDate,
            workOrderId: this.recordId,
            accountId: this.accountId

        })
            .then(result => {

                if (result != null) {

                    console.log('result:', result);

                    this.showSpinner = false;
                    this.showToast("Success", "Model and Serial captured successfully", "success");

                    // Emit custom event with the serial number
                    const splitDetailsSaved = new CustomEvent('splitdetailsaved', {});
                    this.dispatchEvent(splitDetailsSaved);

                    // Reset HTML variables
                    this.oduInputs = [];
                    this.iduInputs = [];
                    this.installationDate = null;
                    this.totalODU = 0;
                    this.totalIDU = 0;

                    this.residentialRegDetailsVisibility = false;
                    this.registrationDetailsVisibility = false;
                    this.assetRegTypeScreen = false;

                    // Emit custom event on back click
                    const nextClick = new CustomEvent('registersuccess', {});
                    this.dispatchEvent(nextClick);

                }
                else {
                    this.showSpinner = false;
                    this.showToast("Error", "Asset registration failed, contact Admin", "error");

                }

            })
            .catch(error => {
                console.error('Error fetching account', error);
            });

    }


    handleRegisterResidentialUnitary() {

        this.asyncUnitaryRegistration();

    }


    async asyncUnitaryRegistration() {


        const result = await LightningConfirm.open({
            message: 'Are you sure you want to submit!?',
            variant: 'headerless',
            label: 'Are you sure you want to submit!?',
            // setting theme would have no effect
        });


        this.showSpinner = true;

        if (result === true) {

            console.log('asyncUnitaryRegistration -- ');

            // Validate installation date
            if (!this.installationDate || this.installationDate === null) {
                this.showSpinner = false;
                this.showToast("Error", "Please fill the Installation Date", "error");
                return;
            }
            // Validate model number
            if (!this.unitaryModelNumber || this.unitaryModelNumber === null) {
                this.showSpinner = false;
                this.showToast("Error", "Please select the model from the dropdown", "error");
                return;
            }
            // Validate installation date
            if (!this.serialNumber || this.serialNumber === null) {
                this.showSpinner = false;
                this.showToast("Error", "Please select the serial number", "error");
                return;
            }

            console.log('asyncUnitaryRegistration -- ');

            fetchExistingAsset({
                serialNumber: this.serialNumber,
                accountId: this.accountId
            })
                .then(data => {

                    console.log('data -- ' + data);

                    if (data === 'Different Account') {
                        //asset exists
                        this.showSpinner = false;
                        this.showToast("", "Asset already registered with different account", "warning");

                        // Emit custom event with the serial number
                        const assetExist = new CustomEvent('assetexist', {
                            detail: { serialNumber: this.serialNumber }
                        });
                        this.dispatchEvent(assetExist);
                    }
                    else if (data === 'Same Account') {
                        this.showSpinner = false;
                        this.showToast("", "Asset already registered", "warning");

                        // Emit custom event with the serial number
                        const assetExistSameAccount = new CustomEvent('assetexistsameaccount', {
                            detail: { serialNumber: this.serialNumber }
                        });
                        this.dispatchEvent(assetExistSameAccount);

                    }

                    else {

                        saveUnitaryDetails({
                            serialNumber: this.serialNumber,
                            modelNumber: this.unitaryModelNumber,
                            installationDate: this.installationDate,
                            workOrderId: this.recordId,
                            accountId: this.accountId

                        })
                            .then(saveResult => {

                                if (saveResult != null) {

                                    console.log('saveResult:', saveResult);

                                    this.showSpinner = false;
                                    this.showToast("Success", "Model and Serial captured successfully", "success");

                                    // Emit custom event with the serial number
                                    const unitaryDetailsSaved = new CustomEvent('unitarydetailsaved', {});
                                    this.dispatchEvent(unitaryDetailsSaved);

                                    // Reset HTML variables
                                    this.oduInputs = [];
                                    this.iduInputs = [];
                                    this.installationDate = null;
                                    this.totalODU = 0;
                                    this.totalIDU = 0;

                                    this.residentialRegDetailsVisibility = false;
                                    this.registrationDetailsVisibility = false;
                                    this.assetRegTypeScreen = false;

                                    // Emit custom event on back click
                                    const nextClick = new CustomEvent('registersuccess', {});
                                    this.dispatchEvent(nextClick);

                                }
                                else {
                                    this.showSpinner = false;
                                    this.showToast("Error", "Asset registration failed, contact Admin", "error");

                                }

                            })
                            .catch(error => {
                                console.error('Error fetching account', error);
                            });

                    }

                })
                .catch(error => {
                    console.error('Error fetching account', error);
                });

        }
        else {

            this.showSpinner = false;

        }

    }


    saveModelSerialNumbers() {

        if (this.productOwner === 'Bluestar Manufacturer') {
            if (!this.serialNumber) {
                // If the picklist value is Model and Serial Number, modelNumber and serialNumber cannot be null
                this.showToast('Error', 'Please enter Serial Number.', 'error');
                return;
            }
        }

        // Validate model number
        if (!this.unitaryModelNumber || this.unitaryModelNumber === null) {
            this.showSpinner = false;
            this.showToast("Error", "Please select the model from the dropdown", "error");
            return;
        }

        saveProductdetails({
            modelNumber: this.unitaryModelNumber,
            serialNumber: this.serialNumber,
            invoiceNumber: this.invoiceNumber,
            recordId: this.recordId
        })
            .then(result => {
                console.log('successfully saved asset details', result);

                this.showSpinner = false;
                console.log('showSpinner', this.showSpinner);
                this.showToast('Success', 'Model and Serial captured successfully', 'Success');


                // Emit custom event on back click
                const nextClick = new CustomEvent('registersuccess', {});
                this.dispatchEvent(nextClick);


            })
            .catch(error => {
                console.error('Error while saving asset details', error);
            });

    }

    fetchUnitaryDetails() {

        this.showSpinner = true;

            // Validate model number
            if (!this.unitaryModelNumber || this.unitaryModelNumber === null) {
                this.showSpinner = false;
                this.showToast("Error", "Please select the model from the dropdown", "error");
                return;
            }

            // Replace 'modelNumber', 'serialNumber', 'invoiceNumber' with actual values
            fetchAssetsFromSAP({
                modelNumber: this.unitaryModelNumber,
                serialNumber: this.serialNumber,
                invoiceNumber: this.invoiceNumber
            })
                .then(result => {
                    // Handle successful response
                    console.log('Response from Apex method:', result);

                    if (result === undefined || result === null) {
                        this.showToast('Error', 'No Asset details found', 'error');
                        this.showSpinner = false;

                    }
                    else if (result === 'Read timed out') {

                        this.showToast("Error", "SAP server is down, please try after sometime", "error");
                        this.showSpinner = false;


                    }
                    else {

                        // LightningAlert.open({
                        //     message: 'result - ' + JSON.stringify(result),
                        //     theme: 'success', // a red theme intended for error states
                        //     label: 'result', // this is the header text
                        // });


                        this.unitaryDetails = JSON.parse(JSON.parse(result));
                        console.log("unitaryDetails:", JSON.stringify(this.unitaryDetails));

                        if (Array.isArray(this.unitaryDetails) && this.unitaryDetails.length > 0) {
                            const parsedData = this.unitaryDetails[0];
                            console.log("Parsed Data:", parsedData);
                            console.log("Parsed Data DEPARTMENT:", parsedData.DEPARTMENT);

                            // Check if MESSAGE contains "No invoice found"
                            if (parsedData.MESSAGE && parsedData.MESSAGE === "No invoice found") {
                                this.showToast("Error", "No Asset details found in SAP", "error");
                                this.showSpinner = false;
                                return; // Stop further processing
                            }
                            else {

                                this.showUnitaryDetails = true;


                                this.serviceDepartmentNumber = this.fetchServiceDepartment(parsedData.DEPARTMENT);
                                console.log("serviceDepartmentNumber:", this.serviceDepartmentNumber);


                                this.invoiceDetails = {
                                    INVOICE_NUMBER: parsedData.INVOICE_NUMBER,
                                    INVOICE_DATE: parsedData.INVOICE_DATE,
                                    CUSTOMER_CODE: parsedData.CUSTOMER_CODE,
                                    CP_CODE: parsedData.CP_CODE,
                                    SALES_DEPARTMENT: parsedData.DEPARTMENT,
                                    SERVICE_DEPARTMENT: this.serviceDepartmentNumber,
                                    BRANCH_CODE: parsedData.BRANCH_CODE
                                };

                                this.invoiceDate = parsedData.INVOICE_DATE;


                                if (Array.isArray(parsedData.PRODUCT)) {
                                    this.unitaryProducts = parsedData.PRODUCT;

                                }

                                this.showSpinner = false;

                            }

                        }
                        else {
                            this.showToast("Error", "No Asset details found", "error");
                            this.showSpinner = false;

                        }
                    }
                })
                .catch(error => {
                    // Handle error
                    console.error('Error in calling Apex method:', error);

                    this.showToast('Error', 'No Asset details found', 'error');
                    this.showSpinner = false;


                });
        

    }

    handleRegisterUnitary() {

        // Validate installation date
        if (!this.installationDate || this.installationDate === null) {
            this.showSpinner = false;
            this.showToast("Error", "Please fill the Installation Date", "error");
            return;
        }

        if(this.invoiceDate > this.installationDate){

            this.showToast("Error", "Invoice Date cannot be greater than the Installation Date", "error");
            this.showSpinner = false;
            return;

        }


        this.showSpinner = true;
        console.log('handleRegisterUnitary called -- ');

        registerUnitaryAsset({

            modelCodes: this.modelCodes,
            assetDetails: JSON.stringify(this.unitaryDetails),
            address: null,
            accountId: this.accountId,
            workOrderId: this.recordId,
            installationDate: this.installationDate,
            productType: this.productType,
            isAddressChanged: null,
            selectedAddressId: this.selectedAddressId,
            solId: this.solId,
            logicalUnit: this.logicalUnit,
            cpAccountId: null,
            equipmentLocation: this.equipmentLocation

        })
            .then(result => {

                console.log('result -- ' + result);

                this.showToast("Success", "Asset registered successfully", "success");

                this.registeredUnitaryAsset = result;

                console.log('registeredUnitaryAsset -- ' + JSON.stringify(this.registeredUnitaryAsset));

                //create WOLI
                this.createUnitaryWoliCommercial();

                this.showSpinner = false;

                // Emit custom event on back click
                const nextClick = new CustomEvent('registersuccess', {});
                this.dispatchEvent(nextClick);

            })
            .catch(error => {
                // Handle error
                console.error('Error in calling Apex method:', error);

                this.showToast('Error', 'No Asset details found', 'error');
                this.showSpinner = false;


            });

    }


    createUnitaryWoliCommercial() {

        // Validate installation date
        if (!this.installationDate || this.installationDate === null) {
            this.showSpinner = false;
            this.showToast("Error", "Please fill the Installation Date", "error");
            return;
        }

        saveUnitaryDetailsCommercial({
            serialNumber: this.serialNumber,
            modelNumber: this.unitaryModelNumber,
            installationDate: this.installationDate,
            workOrderId: this.recordId,
            accountId: this.accountId,
            assetRegistered: this.registeredUnitaryAsset

        })
            .then(result => {

                if (result != null) {

                    console.log('result:', result);

                }
                else {
                    this.showSpinner = false;
                    this.showToast("Error", "Asset registration failed, contact Admin", "error");

                }

            })
            .catch(error => {
                console.error('Error fetching account', error);
                this.showSpinner = false;

            });


    }

    handleOnselect(event) {
        this.selectedItemValue = event.detail.name;
        // Retrieve the selected invoice details
        this.selectedInvoice = this.assetDetails.find(invoice => invoice.INVOICE_NUMBER === this.selectedItemValue);
    }

    // Determine if the current invoice is selected
    isSelectedInvoice(invoice) {
        return invoice.INVOICE_NUMBER === this.selectedItemValue;
    }

    handleAddProduct(event) {

        console.log('add product event');


        const { address, firstPageVisibility } = event.detail;
        this.firstPage = firstPageVisibility;
        this.secondPage = false;
        // Do something with addressData and firstPage variables
        console.log('Address Data:', address);
        console.log('First Page Flag:', firstPageVisibility);
    }

    handleBack() {
        this.firstPage = true;
        this.secondPage = false;


    }
    handleBackClick() {

        // Emit custom event on back click
        const backClick = new CustomEvent('backclick', {});
        this.dispatchEvent(backClick);

    }

    handleSuccess() {
        // Reset form fields
        this.productOwner = null;
        this.picklistValue = null;
        this.invoiceNumber = null;
        this.serialNumber = null;
        this.modelNumber = null;
        this.productType = null;
        this.hasExtendedWarranty = false;
        this.hasPromotionalWarranty = false;
        this.serialNumberScreen = false;
        this.invoiceNumberScreen = false;
        this.assetRegTypeScreen = false;
        // Show first page
        this.firstPage = true;
        this.secondPage = false;

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
    //Method To Handle Button Click To Scan
    handleBarcodeClick(event) {
        // Reset scannedBarcode to empty string before starting new scan
        this.scannedBarcode = '';
        if (this.myScanner.isAvailable() || this.myScanner != null) {

            const scanningOptions = {
                barcodeTypes: [this.myScanner.barcodeTypes.QR,
                this.myScanner.barcodeTypes.UPC_E,
                this.myScanner.barcodeTypes.EAN_13,
                this.myScanner.barcodeTypes.CODE_39,
                this.myScanner.barcodeTypes.CODE_128,
                this.myScanner.barcodeTypes.CODE_93,
                this.myScanner.barcodeTypes.EAN_8,
                this.myScanner.barcodeTypes.UPC_A,
                this.myScanner.barcodeTypes.UPC_E,
                ],
                instructionText: 'Scan a QR , UPC , EAN 13, Code 39, CODE 128, CODE 93, EAN 8, UPC A, UPC_E',
                successText: 'Scanning complete.'
            };
            this.myScanner.beginCapture(scanningOptions)
                .then((result) => {
                    this.scannedBarcode = result.value;
                    this.serialNumber = this.scannedBarcode;
                    this.serialNumberScreen = true;
                    this.isBluestar = true;

                })
                .catch((error) => {
                    this.showSuccess = false;
                    //this.showError('error',error);
                })
                .finally(() => {
                    // Clean up by ending capture,
                    // whether we completed successfully or had an error
                    this.myScanner.endCapture();
                });
        } else {

            // Inform the user that they must use a mobile phone with a camera.
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'This Device does not support a scanner.',
                error: 'error'
            });
            this.dispatchEvent(event);
        }
    }

    handleRegistratonSuccessNonBSL(event) {

        console.log('non bsl register success');


        // Emit custom event on back click
        const nextClick = new CustomEvent('registersuccess', {});
        this.dispatchEvent(nextClick);
    }

}