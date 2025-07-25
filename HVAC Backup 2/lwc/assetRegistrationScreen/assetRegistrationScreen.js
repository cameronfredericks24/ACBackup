/* eslint-disable no-await-in-loop */
/* eslint-disable no-undef */
/* eslint-disable vars-on-top */
/* eslint-disable no-eval */
/* eslint-disable no-restricted-globals */
/* eslint-disable radix */
/* eslint-disable @lwc/lwc/no-async-operation */
import { LightningElement, track, wire, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import fetchProductCodes from '@salesforce/apex/AssetRegistrationController.fetchProductCodes';
import getCpAccounts from '@salesforce/apex/AssetRegistrationController.getCpAccounts';
import fetchAssetsFromSAP from "@salesforce/apex/AssetDetailsDisplayScreenController.fetchAssetsFromSAP";
import fetchSplitAssetsFromSAP from "@salesforce/apex/AssetDetailsDisplayScreenController.fetchAssetsFromSAP";
import registerAsset from "@salesforce/apex/AssetRegistrationController.registerSplitAsset";
import registerIDUAsset from "@salesforce/apex/AssetRegistrationController.registerIDU";
import getServiceDepartment from "@salesforce/apex/AssetDetailsDisplayScreenController.getServiceDepartment";

import fetchSolId from "@salesforce/apex/AssetRegistrationController.fetchSolId";
import tagFilesToAsset from "@salesforce/apex/AssetRegistrationController.tagFilesToAsset";


import { RefreshEvent } from 'lightning/refresh';
import { NavigationMixin } from 'lightning/navigation';


import getAddressesByAccountId from '@salesforce/apex/AssetDetailsDisplayScreenController.getAddressesByAccountId';
import fetchAccountAddress from '@salesforce/apex/AssetRegistrationController.getAccountShippingAddress';

import getAccoountDetails from '@salesforce/apex/AssetDetailsDisplayScreenController.getAccoountDetails';


const ITEMS_PER_PAGE = 7; // Number of items to display per page

export default class AssetRegistrationScreen extends NavigationMixin(LightningElement) {
    @api recordId;
    @track showSpinner = false;
    @track firstPage = true;
    @track secondPage = false;

    @track isMobileDevice;

    @track addNewAddress = false;
    @track filteredOptions = [];
    @track filteredOptionsProductCode = [];
    @track filteredOptionsCP = [];
    @track cpSearchTerm;
    @track showAvailableCP = false;


    @track showAvailableAddress = false;
    @track showAvailableCodesUnitary = false;

    @track showAvailableCodes = false;
    @track showAvailableCodesIDU = false;

    @track registerODUButtonVisibility = false;

    @track selectedAddress;
    @track selectedAddressId;

    @track selectedCP;
    @track selectedCPLabel;

    @track address = {
        houseFlat: '',
        street: '',
        city: '',
        locality: '',
        subLocality: '',
        sector: '',
        postalCode: '',
        stateCode: '',
        country: ''
    };

    @track addressToDisplay;

    @track installationDate;
    @track solId;

    @track accountGroup;

    @track isNAMO = false;


    @track isFileUploaded = false;
    @track uploadedFileNames = [];

    @track nextButtonVisibility = false;

    @track productOwner;
    @track picklistValue;

    @track hasPromotionalWarranty;
    @track hasExtendedWarranty;

    @track invoiceNumber;
    @track serialNumber;
    @track productType;
    @track modelNumber;

    @track isBluestar = true;
    @track assetDetailsScreen = false;
    @track assetRegTypeScreen = false;

    @track totalODU;
    @track totalIDU;
    @track serialModelInputVisibility = false;
    @track serialInputs = [];
    @track iduInputs = [];
    @track oduInputs = [];

    @track invoiceNumberScreen = false;
    @track serialNumberScreen = false;

    @track productOptions = [];
    @track showOptions = false;
    @track selectedOption;
    @track serviceDepartmentNumber;

    @track ModelNotFound = false;

    @track assetDetails = [];

    @track iduDetails = [];
    @track oduDetails = [];
    @track iduProducts = [];
    @track oduProducts = [];

    @track oduDetailsAccordion = [];

    @track iduAccordionData = [];

    @track showODU = false;
    @track showIDU = false;
    @track showIDUSection = false;

    @track gridData = [];
    @track invoiceDetails = {
        INVOICE_NUMBER: "",
        INVOICE_DATE: "",
        CUSTOMER_CODE: "",
        SALES_DEPARTMENT: "",
        SERVICE_DEPARTMENT: "",
        BRANCH_CODE: ""
    };

    @track modelCodes = [];

    @track isAddressChanged = false;

    @track logicalUnit;
    @track selectedModelNumbers = [];

    @track selectedItemValue;
    @track selectedInvoice;

    @track regtypeVisibility = false;
    @track registerComponentScreen = false;
    @track registerUnitaryScreen = false;

    //@track isUnitary = false;

    get productOwnerOptions() {
        return [
            { label: "Bluestar Manufacturer", value: "Bluestar Manufacturer" },
            { label: "Non Bluestar", value: "Non Bluestar" }
        ];
    }

    get picklistOptions() {
        return [
            { label: "Model and Serial Number", value: "Model and Serial Number" },
            { label: "Invoice Number", value: "Invoice Number" }
        ];
    }

    get productTypeOptions() {
        return [
            { label: "Split", value: "Split" },
            { label: "Unitary", value: "Unitary" }
        ];
    }

    get acceptedFormats() {
        return ['.pdf', '.png', '.jpeg', '.jpg','JPEG','JPG'];
    }


    connectedCallback() {
        console.log("recordId- ", this.recordId);
        this.isMobileDevice = this.checkMobileDevice();
        this.getAccountShippingAddress(this.recordId);
        // this.loadAddresses();
        this.loadProductCodes();
        this.getSolId();
        this.getAccountGroup();

    }

    checkMobileDevice() {
        const userAgent = navigator.userAgent;
        const mobileDeviceRegex =
            /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i;
        return mobileDeviceRegex.test(userAgent);
    }

    handleExistingAsset() {
        this.addExistingAsset = true;
    }

    handleRegisterNewAsset() {
        this.addExistingAsset = false;
    }

    handleProductOwnerChange(event) {
        this.productOwner = event.detail.value;
        console.log("this.productOwner--", this.productOwner);
        this.assetRegTypeScreen = true;

        console.log("this.assetRegTypeScreen--", this.assetRegTypeScreen);

        if (this.productOwner === "Bluestar Manufacturer") {
            this.isBluestar = true;
        } else {
            this.isBluestar = false;
        }
    }

    getSolId() {

        fetchSolId({ accountId: this.recordId })
            .then(result => {

                this.solId = result;

            })
            .catch(error => {
                console.error('Error loading solId:', error);
                console.error('Error message solId:', error.message);

                // Handle error, display a message or log it
            });

    }

    getAccountGroup() {

        getAccoountDetails({ accountId: this.recordId })
            .then(result => {

                console.log('account details - ', result);

                this.accountGroup = result.Group__c;
                if (this.accountGroup === 'NAMO') {
                    this.isNAMO = true;
                }
                console.log('accountGroup- ', this.accountGroup);
                console.log('isNAMO- ', this.isNAMO);
            })
            .catch(error => {
                console.error('Error loading account:', error);
                console.error('Error message:', error.message);

                // Handle error, display a message or log it
            });

    }

    handleProductTypeChange(event) {

        this.notUnitary = false;
        this.picklistValue = '';
        this.serialNumberScreen = false;
        this.invoiceNumberScreen = false;
        this.invoiceNumber = "";
        this.modelNumber = "";
        this.serialNumber = "";
        this.unitaryModelSerialVisibility = false;
        this.serialModelInputVisibility = false;

        this.productType = event.detail.value;
        console.log(" this.productType- ", this.productType);
        //this.nextButtonVisibility = true;

        if (this.productType === "Unitary") {
            this.notUnitary = false;
        } else {
            this.notUnitary = true;
        }

        console.log(" this.notUnitary- ", this.notUnitary);

        this.regtypeVisibility = true;
    }

    handlePicklistChange(event) {
        this.picklistValue = event.detail.value;
        console.log("this.picklistValue--", this.picklistValue);

        this.assetDetailsScreen = true;

        if (this.picklistValue === "Invoice Number") {
            this.invoiceNumberScreen = true;
            this.serialNumberScreen = false;
            this.modelNumber = "";
            this.serialNumber = "";
            this.notUnitary = false;
            this.unitaryModelSerialVisibility = false;
        } else if (this.picklistValue === "Model and Serial Number") {

            if (this.productType !== "Unitary") {
                this.notUnitary = true;
            }

            if (this.notUnitary === false) {
                console.log("this.unitaryModelSerialVisibility--", this.unitaryModelSerialVisibility);

                this.unitaryModelSerialVisibility = true;

            }
            this.serialNumberScreen = true;
            this.invoiceNumberScreen = false;
            this.invoiceNumber = "";
        }

        console.log("this.unitaryModelSerialVisibility--", this.unitaryModelSerialVisibility);

    }

    handleFirstNext(event) {
        if (this.notUnitary === true) {
            this.serialModelInputVisibility = true;
        }

        this.registerComponentScreen = true;

        this.updateSerialInputs();
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

        this.modelNumber = event.currentTarget.dataset.value;
        console.log("index: " + index);
        console.log("selectedValue: " + selectedValue);

        this.showAvailableCodesUnitary = false;

    }

    loadAddresses() {
        getAddressesByAccountId({ accountId: this.recordId })
            .then(result => {
                this.addNewAddress = false;

                console.log('result - ', result);

                console.log('address options - ', JSON.stringify(result));

                if (result && result.length > 0) {
                    this.addressOptions = result.map(address => {
                        return { value: address.Id, label: `${address.Street}, ${address.City}, ${address.State}, ${address.Country}, ${address.PostalCode}` };
                    });
                } else {
                    this.addNewAddress = true;

                    this.filteredOptions = [];
                }
                console.log('this.addressOptions - ', JSON.stringify(this.addressOptions));


                console.log('filteredOptions - ', this.filteredOptions);
            })
            .catch(error => {
                console.error('Error loading addresses:', error);
                console.error('Error message 283:', error.message);

                // Handle error, display a message or log it
            });
    }

    handleOnClickCustomLookup(event) {

        this.filteredOptions = this.addressOptions;

        try {

            console.log('filteredOptions on click - ', this.filteredOptions.length);


            this.showAvailableAddress = this.filteredOptions.length > 0;

        }
        catch (error) {
            console.log('error - ', error);

        }

    }

    handleOnChangeCustomLookup(event) {
        const searchTerm = event.target.value.toLowerCase();

        this.filteredOptions = this.addressOptions.filter(option => option.label.toLowerCase().includes(searchTerm));
        this.showAvailableAddress = this.filteredOptions.length > 0;

        console.log('searchTerm  - ', searchTerm);

    }

    handleOnFocusCustomLookup() {
        this.showAvailableAddress = true;
    }

    handleOnBlurCustomLookup() {
        // Using setTimeout to wait a bit before hiding options so click on options can be captured
        setTimeout(() => {
            this.showAvailableAddress = false;
        }, 300);
    }

    handleOptionClick(event) {
        this.selectedAddress = event.currentTarget.dataset.value;
        this.selectedAddressId = event.currentTarget.dataset.addressid;

        console.log(' selectedAddress- ' + this.selectedAddress);
        console.log(' selectedAddressId- ' + this.selectedAddressId);


        // Split the selected address by comma to get individual parts
        const parts = this.selectedAddress.split(',');

        // Extract postal code
        const postalCode = parts.pop().trim(); // Last part is postal code

        // Extract country
        const country = parts.pop().trim(); // Last but one part is country

        // Extract state
        const stateCode = parts.pop().trim(); // Last but two part is state code

        // Extract city
        const city = parts.pop().trim(); // Last but three part is city

        // The remaining parts are street, so join them
        const street = parts.join(',').trim();

        // Assign values to the address object
        this.address = {
            street: street,
            city: city,
            postalCode: postalCode,
            stateCode: stateCode,
            country: country
        };

        console.log(' address- ' + JSON.stringify(this.address));

        this.showAvailableAddress = false;
    }

    handleAddNewAddress() {
        this.addNewAddress = true;

    }

    getAccountShippingAddress(accountId) {

        console.log('adddress called - ' + this.address);

        fetchAccountAddress({ accountId: accountId })
            .then(result => {

                console.log('result 376 - ' + JSON.stringify(result));

                // Extract the key from the result map
                // const key = Object.keys(result)[0];
                const account = result;

                console.log('account 376 - ' + account);

                // this.selectedAddressId = key;

                this.address = {
                    street: account.ShippingStreet,
                    city: account.ShippingCity,
                    postalCode: account.ShippingPostalCode,
                    stateCode: account.ShippingState,
                    country: account.ShippingCountry
                };

                // Concatenate address fields with null checks
                this.addressToDisplay = [
                    this.address.street,
                    this.address.city,
                    this.address.stateCode,
                    this.address.postalCode,
                    this.address.country
                ]
                    .filter(part => part) // Filter out any null or undefined parts
                    .join(', '); // Join the parts with a comma and space

                console.log('addressToDisplay 376 - ' + this.addressToDisplay);

                console.log('Address 376 - ' + JSON.stringify(this.address));

            })
            .catch(error => {
                console.error('Error fetching account address:', error);
            });
    }

    // Function to handle address change
    handleAddressChange(event) {
        this.address.street = event.detail.street;
        this.address.city = event.detail.city;
        this.address.country = event.detail.country;
        this.address.postalCode = event.detail.postalCode;
        this.address.stateCode = event.detail.province;

        console.log('address changed - ', this.address);
        this.isAddressChanged = true;
        this.insAssetAddress = true;
    }

    handleAddressValues(event) {

        try {

            this.showToast('Success', 'Address added successfully', 'success');

            console.log('in address');
            this.insAssetAddress = true;
            //this.isAddressChanged = true;
            console.log('in address isAddressChanged - ', this.isAddressChanged);

            this.selectedAddressId = null;

            //this.showToast('Success', 'isAddressChanged' + this.isAddressChanged, 'success');


            console.log('in address isAddressChanged - ', this.isAddressChanged);


            this.address.houseFlat = event.detail.flat;
            //this.address.Sector__c= ;
            //this.address.Area__c = event.detail.area;
            this.address.stateCode = event.detail.state;
            this.address.locality = event.detail.locality;
            this.address.subLocality = event.detail.sublocality;
            this.address.street = event.detail.street;
            if (event.detail.sector != null && event.detail.sector != undefined) {
                this.address.sector = event.detail.sector;
            } else {
                this.address.sector = '';
            }

            this.address.city = event.detail.city;
            this.address.country = event.detail.country;
            this.address.postalCode = event.detail.pincode;

            console.log('in address address --- ' + JSON.stringify(this.address));

        } catch (error) {

            console.log('error address - ' + error.message);

        }



    }

    loadCPAccounts() {
        getCpAccounts({ searchTerm: this.cpSearchTerm })
            .then(result => {
                console.log('available cp -- ' + JSON.stringify(result));
                this.filteredOptionsCP = result.map(cp => {
                    // Handle cases where CP_User__r might not be available
                    const employeeNumber = cp.CP_User__r ? cp.CP_User__r.Employee_Number__c : '';
                    const label = employeeNumber ? `${cp.Name} - ${employeeNumber}` : cp.Name;
                    return { label: label, value: cp.Id };
                });

                //this.showAvailableCodes = this.filteredOptionsProductCode.length > 0;
                console.log('filteredOptionsCP -- ' + JSON.stringify(this.filteredOptionsCP));

                this.showAvailableCP = this.filteredOptionsCP.length > 0;

            })
            .catch(error => {
                console.error('Error fetching product codes', error);
            });
    }

    handleOnClickCustomLookupCP(event) {

        try {

            console.log('filteredOptionsProductCode on click - ');
            this.loadCPAccounts(this.cpSearchTerm);

        }
        catch (error) {
            console.log('error - ', error);

        }
    }

    handleOnChangeCustomLookupCP(event) {

        this.cpSearchTerm = event.target.value.toLowerCase();

        console.log('cpSearchTerm  - ', this.cpSearchTerm);

        this.loadProductCodes(this.cpSearchTerm);

    }

    handleOnFocusCustomLookupCP() {
        this.showAvailableCP = true;
    }

    handleOnBlurCustomLookupCP() {
        // Using setTimeout to wait a bit before hiding options so click on options can be captured
        setTimeout(() => {
            this.showAvailableCP = false;
        }, 300);
    }

    handleOptionClickCP(event) {

        this.selectedCP = event.currentTarget.dataset.value;
        this.selectedCPLabel = event.currentTarget.dataset.cplabel;


        console.log(' selectedCP 569 - ' + this.selectedCP);
        this.showAvailableCP = false;


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

    handleSOLchange(event) {
        this.solId = event.detail.value;
        console.log('solId - ', this.solId);

    }

    handleIDUNumberChange(event) {
        this.totalIDU = event.detail.value;
    }

    handleODUNumberChange(event) {
        this.totalODU = event.detail.value;
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

    async fetchServiceDepartment(serviceDepartmentNumber) {
        try {
            console.log('751');
            const result = await getServiceDepartment({ departmentNumber: serviceDepartmentNumber });
            console.log('Service Department fetched:', result);
            return result;
        } catch (error) {
            console.error('Error fetching service department:', error);
            throw error; // Rethrow the error to be caught in the main function
        }
    }



    async handleFetchODU() {
        this.modelCodes = [];
        this.showSpinner = true;

        // Validate installation date
        if (!this.installationDate) {
            this.showSpinner = false;
            this.showToast("Error", "Please fill the Installation Date", "error");
            return;
        }

        // Validate oduInputs for empty or null values
        if (!this.oduInputs || this.oduInputs.length === 0) {
            this.showSpinner = false;
            this.showToast("Error", "Model or Serial number missing", "error");
            return;
        }

        // Collect all serial and model numbers
        let serialModelData = this.oduInputs.map(input => ({
            serialNumber: input?.serialNumber,
            modelNumber: input?.modelNumber
        })).filter(data => data.serialNumber && data.modelNumber);

        console.log('serialModelData-- ' + JSON.stringify(serialModelData));

        if (serialModelData.length === 0) {
            this.showSpinner = false;
            this.showToast("Error", "No valid Model or Serial number found", "error");
            return;
        }

        try {
            // Fetch data for all serial/model numbers using Promise.all
            const results = await Promise.all(
                serialModelData.map(data =>
                    fetchSplitAssetsFromSAP({
                        modelNumber: data.modelNumber,
                        serialNumber: data.serialNumber,
                        invoiceNumber: this.invoiceNumber
                    })
                )
            );

            // Loop through each result and process
            for (const result of results) {
                if (!result) {
                    this.showToast("Error", "No Asset details found", "error");
                    continue;
                } else if (result === 'failure') {
                    this.showToast("Error", "Asset already registered", "error");
                    continue;
                } else if (result === 'Read timed out') {
                    this.showToast("Error", "SAP server is down, please try after sometime", "error");
                    continue;
                }

                let parsedData;
                try {
                    parsedData = JSON.parse(JSON.parse(result));
                } catch (parseError) {
                    console.error("Error parsing result:", parseError);
                    this.showToast("Error", "Failed to parse asset data", "error");
                    continue;
                }

                if (Array.isArray(parsedData) && parsedData.length > 0) {
                    const oduData = parsedData[0];
                    this.oduDetails.push(oduData);
                    if (!oduData) continue;

                    console.log('oduData -- ' + JSON.stringify(oduData));

                    try {
                        // Wait for the service department to be fetched
                        const serviceDepartmentNumber = await this.fetchServiceDepartment(oduData.DEPARTMENT);
                        this.serviceDepartmentNumber = serviceDepartmentNumber || null;

                        this.invoiceDetails = {
                            INVOICE_NUMBER: oduData.INVOICE_NUMBER || null,
                            INVOICE_DATE: oduData.INVOICE_DATE || null,
                            CUSTOMER_CODE: oduData.CUSTOMER_CODE || null,
                            CP_CODE: oduData.CP_CODE || null,
                            SALES_DEPARTMENT: oduData.DEPARTMENT || null,
                            SERVICE_DEPARTMENT: this.serviceDepartmentNumber,
                            BRANCH_CODE: oduData.BRANCH_CODE || null
                        };
                        console.log('invoiceDetails -' + JSON.stringify(this.invoiceDetails));

                        // Ensure PRODUCT exists and is an array
                        if (Array.isArray(oduData.PRODUCT) && oduData.PRODUCT.length > 0) {
                            oduData.PRODUCT.forEach(product => {
                                if (!product || !product.MODEL_CODE) return;

                                this.oduDetailsAccordion.push(product);

                                this.modelCodes.push(product.MODEL_CODE);
                                this.logicalNumber = product.MODEL_CODE;

                                // Iterate over child products and subcomponents if they exist
                                if (Array.isArray(product.CHILD_PRODUCTS)) {
                                    product.CHILD_PRODUCTS.forEach(childProduct => {
                                        if (childProduct && childProduct.MODEL_CODE) {
                                            this.modelCodes.push(childProduct.MODEL_CODE);
                                        }
                                    });
                                }
                            });
                        } else {
                            this.showToast("Error", "No Product details found", "error");
                        }
                        this.showODU = true;
                    } catch (error) {
                        console.error("Error fetching service department:", error);
                        this.showToast("Error", "Failed to fetch service department", "error");
                    }
                } else {
                    this.showToast("Error", "No Asset details found", "error");
                }
            }

            console.log('oduDetails -- ' + JSON.stringify(this.oduDetails));
        } catch (error) {
            console.error("Error in calling Apex method:", error.message);
            this.showToast("Error", "No Asset details found", "error");
        }

        this.showSpinner = false;
        console.log("showSpinner", this.showSpinner);
        console.log("modelCodes", this.modelCodes);
    }




    handleFetchIDU() {
        this.modelCodes = [];
        this.showSpinner = true;

        try {

            console.log(' iduInputs-- ' + JSON.stringify(this.iduInputs));

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
                    if (result && result !== 'failure') {
                        let parsedData = JSON.parse(JSON.parse(result));

                        // Validate fetched product model number against the logical number
                        const isValidProduct = parsedData[0]?.PRODUCT.some(product =>
                            product.MODEL_CODE === this.logicalNumber
                        );
                        console.log('isValidProduct-- ' + isValidProduct);

                        if (isValidProduct) {
                            this.iduDetails.push(parsedData);

                            if (Array.isArray(parsedData) && parsedData.length > 0) {
                                this.iduAccordionData.push(parsedData[0]);

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
                        } else {
                            this.showToast("Warning", "The selected product is different from the logical number.", "warning");
                        }
                    } else if (result === 'failure') {
                        this.showToast("Warning", "Asset already registered", "warning");
                    }
                    else if (result === 'Read timed out') {

                        this.showToast("Error", "SAP server is down, please try after sometime", "error");

                    }
                });

                if (this.iduDetails.length > 0) {
                    this.showIDU = true;
                } else {
                    if (isValidProduct) {
                        this.showToast("Error", "No Asset details found", "error");
                    }
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

        catch (error) {

            console.log("error fetch idu -- " + error.message);

        }
    }


    handleRegisterIDU() {
        this.showSpinner = true;
        //this.iduDetails = JSON.parse(JSON.parse(this.iduDetails));
        var addressString = JSON.stringify(this.address);

        try {

            this.iduDetails.forEach(idu => {

                console.log("idu 462 - ", idu);

                registerIDUAsset({
                    modelCodes: this.modelCodes,
                    assetDetails: JSON.stringify(idu),
                    address: addressString,
                    accountId: this.recordId,
                    workOrderId: null,
                    installationDate: this.installationDate,
                    productType: this.productType,
                    isAddressChanged: this.isAddressChanged,
                    selectedAddressId: this.selectedAddressId,
                    solId: this.solId,
                    logicalUnit: this.logicalUnit,
                    cpAccountId: this.selectedCP

                })
                    .then((result) => {
                        console.log("result 592 - ", result);
                        this.showSpinner = false;

                        console.log('result.ParentId -- ' + result.ParentId);

                        if (result != null) {
                            this.showToast("Success", "IDU registered successfully", "success");

                            //refresh the page
                            //eval("$A.get('e.force:refreshView').fire();");

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
                            this.uploadedFileNames = [];


                            console.log('result.ParentId -- ' + result.ParentId);

                            this[NavigationMixin.Navigate]({
                                type: 'standard__recordPage',
                                attributes: {
                                    recordId: result.ParentId,
                                    actionName: 'view'
                                }
                            });
                            //this.dispatchEvent(new RefreshEvent());
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

    handleRegisterODU() {
        this.showSpinner = true;

        console.log("register odu called:");
        var addressString = JSON.stringify(this.address);

        console.log("address pincode-- " + this.address.postalCode);
        console.log("address state-- " + this.address.stateCode);

        // Validate installation date
        if (!this.installationDate || this.installationDate === null) {
            this.showSpinner = false;
            this.showToast("Error", "Please fill the Installation Date", "error");
            return;
        }

        // Validate invoice upload
        if (!this.isFileUploaded || this.isFileUploaded.length < 1) {
            this.showSpinner = false;
            this.showToast("Error", "Please upload the invoice to proceed", "error");
            return;

        }

        //installation date should be greater than invoice date
        if (this.installationDate < this.invoiceDate) {
            this.showSpinner = false;
            this.showToast("Error", "Installation Date should be greater than or equal to Invoice Date", "error");
            return;
        }

        // Validate address variables
        if (this.address.postalCode === null || this.address.stateCode === null || this.address.postalCode === '' || this.address.stateCode === '') {
            this.showSpinner = false;
            this.showToast("Error", "Please complete the address in account", "error");
            return;
        }
        // Validate installation date
        if (this.addressString === '' || this.addressString === null || this.address === null) {
            this.showSpinner = false;
            this.showToast("Error", "Please complete the address in account", "error");
            return;
        }

        try {
            registerAsset({
                modelCodes: this.modelCodes,
                assetDetails: JSON.stringify(this.oduDetails),
                address: addressString,
                accountId: this.recordId,
                workOrderId: null,
                installationDate: this.installationDate,
                productType: this.productType,
                isAddressChanged: this.isAddressChanged,
                selectedAddressId: this.selectedAddressId,
                solId: this.solId,
                logicalUnit: this.logicalUnit,
                cpAccountId: this.selectedCP
            })
                .then((result) => {
                    console.log("result 592 - ", result);

                    this.showSpinner = false;

                    if (result != null) {

                        this.logicalUnit = result;

                        console.log("logicalUnit 463 - ", this.logicalUnit);

                        this.tagFilesToLogicalUnit(this.logicalUnit);

                        this.showToast("Success", "ODU registered successfully", "success");
                        this.showIDUSection = true;
                        this.registerODUButtonVisibility = true;

                        console.log("registerODUButtonVisibility 463 - ", this.registerODUButtonVisibility);

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

    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
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

    //method to call Apex to tag files
    tagFilesToLogicalUnit(logicalAsset) {
        tagFilesToAsset({
            documentIds: this.uploadedFileNames.map(file => file.id),
            logicalAsset: logicalAsset
        })
            .then(() => {
                this.showToast("Success", "Files tagged to asset successfully", "success");
            })
            .catch((error) => {
                console.error("Error tagging files to asset:", error);
                this.showToast("Error", "Failed to tag files to asset", "error");
            });
    }

    handleFileClick(event) {
        const fileId = event.currentTarget.dataset.id;
        // Construct the URL for the file
        const fileUrl = `/sfc/servlet.shepherd/document/download/${fileId}`;
        // Open the file in a new tab
        window.open(fileUrl, "_blank");
    }

    handleInvoiceNumberChange(event) {
        this.invoiceNumber = event.detail.value;
        console.log(" this.invoiceNumber- ", this.invoiceNumber);
        this.nextButtonVisibility = true;
    }

    handleSerialNumberChange(event) {
        this.serialNumber = event.detail.value;
        console.log(" this.serialNumber- ", this.serialNumber);
        this.nextButtonVisibility = true;

        //console.log(" this.oduInputs- ", JSON.stringify(this.oduInputs));
    }

    handleODUSerialNumberChange(event) {
        const index = event.target.dataset.index;
        const value = event.target.value;
        this.serialNumber = event.detail.value;

        this.oduInputs[index].serialNumber = value;
        //this.nextButtonVisibility = true;

        console.log("Updated oduInputs: ", JSON.stringify(this.oduInputs));
    }

    handleIDUSerialNumberChange(event) {
        const index = event.target.dataset.index;
        const value = event.target.value;
        this.iduInputs[index].serialNumber = value;
        //this.nextButtonVisibility = true;

        console.log("Updated iduInputs: ", JSON.stringify(this.iduInputs));
    }

    handleModelNotFoundChange(event) {
        this.ModelNotFound = event.detail.checked;
        console.log(" this.ModelNotFound- ", this.ModelNotFound);
        this.nextButtonVisibility = true;
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

            const index = event.currentTarget.dataset.index;
            console.log('index - ', index);

            this.oduInputs[index].showAvailableCodes = this.filteredOptionsProductCode.length > 0;;
            console.log('oduInputs on click - ', JSON.stringify(this.oduInputs));

            console.log('filteredOptionsProductCode on click - ', this.filteredOptionsProductCode.length);
        }
        catch (error) {
            console.log('error - ', error);
            console.log('error - ', error.message);


        }
    }

    handleOnChangeCustomLookupProductCode(event) {

        const searchTermProductCode = event.target.value;
        const index = event.currentTarget.dataset.index;

        this.oduInputs[index].modelNumber = searchTermProductCode;

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

    handleModelNumberChangeCustomLookup(event) {
        console.log("option clicked: ");

        const index = event.currentTarget.dataset.index;
        const selectedValue = event.currentTarget.dataset.value;

        this.oduInputs[index].modelNumber = selectedValue;
        this.oduInputs[index].showAvailableCodes = false;
        console.log('iduInputs on click - ', JSON.stringify(this.oduInputs));

        // const index = event.currentTarget.dataset.index;
        // const selectedValue = event.currentTarget.dataset.value;
        // this.modelNumber = event.currentTarget.dataset.value;
        // console.log("index: " + index);
        // console.log("selectedValue: " + selectedValue);

        // this.oduInputs[index].modelNumber = selectedValue;

        // console.log("oduInputs: ", JSON.stringify(this.oduInputs));

        //this.showAvailableCodes = false;

    }

    handleModelNumberChange(event) {
        this.modelNumber = event.detail.value;
        console.log("modelNumber: ", JSON.stringify(this.modelNumber));


    }

    handleIDUOnChangeCustomLookupProductCode(event) {
        const searchTermProductCode = event.detail.value;
        const index = event.currentTarget.dataset.index;

        this.iduInputs[index].modelNumber = searchTermProductCode;

        this.loadProductCodes(searchTermProductCode);
    }

    handleIDUOnClickCustomLookupProductCode(event) {
        const index = event.currentTarget.dataset.index;
        console.log('index - ', index);

        this.iduInputs[index].showAvailableCodesIDU = this.filteredOptionsProductCode.length > 0;;
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



    handleNext(event) {
        if (this.productOwner === "Bluestar Manufacturer") {
            if (this.picklistValue === "Invoice Number" && !this.invoiceNumber) {
                // If the picklist value is Invoice Number, invoiceNumber should not be null
                this.showToast("Error", "Please enter an Invoice Number.", "error");
                return;
            } else if (
                this.picklistValue === "Model and Serial Number" &&
                !this.modelNumber &&
                !this.serialNumber
            ) {
                // If the picklist value is Model and Serial Number, modelNumber and serialNumber cannot be null
                this.showToast(
                    "Error",
                    "Please enter Model Number and Serial Number.",
                    "error"
                );
                return;
            }
            else if (!this.isFileUploaded || this.isFileUploaded.length < 1) {
                this.showSpinner = false;
                this.showToast("Error", "Please upload the invoice to proceed", "error");
                return;

            }
        }

        // Show spinner while waiting for response
        this.showSpinner = true;

        // Call SAP authorization
        this.callSAPAuthorisation();

        console.log("second page", this.secondPage);
    }

    callSAPAuthorisation() {
        // Replace 'modelNumber', 'serialNumber', 'invoiceNumber' with actual values
        fetchAssetsFromSAP({
            modelNumber: this.modelNumber,
            serialNumber: this.serialNumber,
            invoiceNumber: this.invoiceNumber
        })
            .then((result) => {
                // Handle successful response
                console.log("Response from Apex method:", result);

                if (
                    result === undefined ||
                    result === null ||
                    result === ""
                ) {
                    this.showToast("Error", "No Asset details found", "error");
                    this.showSpinner = false;
                    this.firstPage = true;
                    this.secondPage = false;
                }
                else if (result === 'failure') {

                    this.showToast("Error", "Asset already registered", "error");
                    this.showSpinner = false;
                    this.firstPage = true;
                    this.secondPage = false;
                }
                else if (result === 'Read timed out') {

                    this.showToast("Error", "SAP server is down, please try after sometime", "error");
                    this.showSpinner = false;
                    this.firstPage = true;
                    this.secondPage = false;

                }
                else {
                    this.assetDetails = JSON.parse(result);

                    console.log("assetDetails:", this.assetDetails);
                    //console.log('assetDetails size:', this.assetDetails.length);

                    if (
                        this.assetDetails === null ||
                        this.assetDetails === [] ||
                        this.assetDetails === null
                    ) {
                        this.showToast("Error", "No Asset details found", "error");
                        this.showSpinner = false;
                        this.firstPage = true;
                        this.secondPage = false;
                    }

                    this.showSpinner = false;
                    console.log("showSpinner", this.showSpinner);

                    this.firstPage = false;
                    this.secondPage = true;
                }
                console.log("showSpinner", this.showSpinner);
            })
            .catch((error) => {
                // Handle error
                console.error("Error in calling Apex method:", error);
                console.log("Error message:", error.message);

                this.firstPage = true;
                this.secondPage = false;
                this.showToast("Error", "No Asset details found", "error");
                this.firstPage = false;
                this.showSpinner = false;

            });
    }

    isEmpty(value) {
        return (
            value === undefined ||
            value === null ||
            (typeof value === "object" && Object.keys(value).length === 0) ||
            (typeof value === "string" && value.trim().length === 0)
        );
    }

    handleOnselect(event) {
        this.selectedItemValue = event.detail.name;
        // Retrieve the selected invoice details
        this.selectedInvoice = this.assetDetails.find(
            (invoice) => invoice.INVOICE_NUMBER === this.selectedItemValue
        );
    }

    // Determine if the current invoice is selected
    isSelectedInvoice(invoice) {
        return invoice.INVOICE_NUMBER === this.selectedItemValue;
    }

    handleAddProduct(event) {
        console.log("add product event");

        const { address, firstPageVisibility } = event.detail;
        this.firstPage = firstPageVisibility;
        this.secondPage = false;
        // Do something with addressData and firstPage variables
        console.log("Address Data:", address);
        console.log("First Page Flag:", firstPageVisibility);
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
        this.uploadedFileNames = [];

        //this.dispatchEvent(new RefreshEvent());
        // Show first page
        this.firstPage = true;
        this.secondPage = false;

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Asset',
                actionName: 'home'
            }
        });
    }

    handleBackClick() {
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
}