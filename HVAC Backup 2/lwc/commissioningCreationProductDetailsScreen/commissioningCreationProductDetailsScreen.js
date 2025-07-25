/* eslint-disable no-dupe-class-members */
/* eslint-disable @lwc/lwc/no-api-reassignments */
/* eslint-disable @lwc/lwc/no-async-operation */
import { LightningElement, api, track, wire } from 'lwc';
import { RefreshEvent } from 'lightning/refresh';

import fetchAccountAddress from '@salesforce/apex/AssetRegistrationController.getAccountShippingAddress';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchAssetsFromSAP from '@salesforce/apex/AssetDetailsDisplayScreenController.fetchAssetsFromSAP';
import getAddressesByAccountId from '@salesforce/apex/AssetDetailsDisplayScreenController.getAddressesByAccountId';

import getAccoountDetails from '@salesforce/apex/AssetDetailsDisplayScreenController.getAccoountDetails';

import addAddressToAsset from '@salesforce/apex/AssetDetailsDisplayScreenController.addAddressToAsset'
import registerAsset from '@salesforce/apex/AssetRegistrationController.registerAsset';
import getCpAccounts from '@salesforce/apex/AssetRegistrationController.getCpAccounts';

import checkProductRegistration from '@salesforce/apex/CommissioningCreationController.checkProductRegistration';
import fetchAsset from '@salesforce/apex/CommissioningCreationController.fetchAsset';
import createWorkOrderAndLineItems from '@salesforce/apex/CommissioningCreationController.createWorkOrderAndLineItems';
import fetchServiceDepartment from '@salesforce/apex/CommissioningCreationController.fetchServiceDepartment';
import fetchServiceTicket from '@salesforce/apex/CommissioningCreationController.fetchServiceTicket';


import fetchSolId from "@salesforce/apex/AssetRegistrationController.fetchSolId";


const EXAMPLES_COLUMNS_DEFINITION_BASIC = [
    { label: '', fieldName: 'INVOICE_NUMBER', type: 'text' },
    { label: 'Model Code', fieldName: 'MODEL_CODE', type: 'text' },
    { label: 'Serial Number', fieldName: 'SERIAL_NUMBER', type: 'text' },
    { label: 'Registration Status', fieldName: 'registrationStatus', type: 'text' },
    { label: 'CP Code', fieldName: 'CP_CODE', type: 'text' },
    { label: 'Branch Code', fieldName: 'BRANCH_CODE', type: 'text' },
    { label: 'Department ', fieldName: 'DEPARTMENT', type: 'text' },
    { label: 'Invoice Date', fieldName: 'INVOICE_DATE', type: 'text' }

    // Add other columns as needed
];

export default class CommissioningCreationProductDetailsScreen extends LightningElement {

    @track primaryWorkOrderRecordId; // Dynamically populated Work Order ID
    @track isFileUploaded = false;
    @track uploadedFileNames = [];
    acceptedFormats = [];
    @track serviceTerritories = [];
    @track isFirstScreen = true; // To toggle between screens
    @track assetOptions = []; // Asset dropdown options
    @track familyOptions = []; // Family dropdown options
    @track productTypeOptions = []; // type dropdown options


    rowIndex = 0;
    productIndex = 0;
    childProductIndex = 0;

    @api assetId;
    @track filteredOptions = [];

    @track productSearchTerm = '';
    @track filteredData = [];

    @track filteredOptionsCP = [];
    @track cpSearchTerm;
    @track showAvailableCP = false;

    @track addressToDisplay;


    gridColumns = EXAMPLES_COLUMNS_DEFINITION_BASIC;

    @track showSpinner = false;

    @track newModelNumber;
    @track newSerialNumber;

    @track childProductRegistrationStatus = {};

    @track serialNumbers = [];
    
    selectedItemValue;

    //asset details from parent
    @api assetDetails;
    @api accountId;
    @api productType;
    @api branchId;
    @api cpId;
    @api itemDetails;
    @api subfamilyId;
    
    @track accountGroup;

    @track isNAMO = false;

    @track invoiceNumber;
    @track invoiceDate;
    @track customerCode;
    @track department;
    @track branchCode;
    @track cpCode;
    @track isAddressChanged = false;

    @track selectedRowLst;

    @track selectedModelNumbers = [];

    @track gridData = [];

    @track assetDetailLst = [];

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

    @track installationDate;
    @track solId;

    @track selectedAddress;
    @track selectedAddressId;


    @track isButtonDisabled = false;
    @track addProduct = false;

    @track showAvailableAddress = false;
    @track addNewAddress = false;

    @track nonBsl = false;
    tempList = [];
    @track selectedRows = [];
    @track originalSelectedRows = [];

    @track productSelectedLst = [];

    @track currentExpanded = [];
    insAssetAddress = false;

    assetOptions = [
        { label: '-- None --', value: '' },
        { label: 'Asset 1', value: 'Asset 1' },
        { label: 'Asset 2', value: 'Asset 2' },
        { label: 'Asset 3', value: 'Asset 3' },
        { label: 'Asset 4', value: 'Asset 4' },
        { label: 'Asset 5', value: 'Asset 5' },
        { label: 'Asset 6', value: 'Asset 6' },
        { label: 'Asset 7', value: 'Asset 7' },
        { label: 'Asset 8', value: 'Asset 8' },
        { label: 'Asset 9', value: 'Asset 9' },
        { label: 'Asset 10', value: 'Asset 10' }
    ];

    familyOptions = [
        { label: '-- None --', value: '' },
        { label: 'Family 1', value: 'Family 1' },
        { label: 'Family 2', value: 'Family 2' },
        { label: 'Family 3', value: 'Family 3' },
        { label: 'Family 4', value: 'Family 4' },
        { label: 'Family 5', value: 'Family 5' },
        { label: 'Family 6', value: 'Family 6' },
        { label: 'Family 7', value: 'Family 7' },
        { label: 'Family 8', value: 'Family 8' },
        { label: 'Family 9', value: 'Family 9' },
        { label: 'Family 10', value: 'Family 10' }
    ];

    productTypeOptions = [
        { label: 'IDU', value: 'IDU' },
        { label: 'ODU', value: 'ODU' },
        { label: 'Unitary', value: 'Unitary' }
    ]

    // @track assetName;
    @track filteredOptionsAsset = [];
    @track filteredOptionsST = [];
    // @track showAvailableAsset = false;


    async connectedCallback() {
        console.log('subFamilyId - ' + this.subfamilyId);
        console.log('accountId- ', this.accountId);
        console.log('product type- ', this.productType);
        console.log('itemDetails -  ', this.itemDetails);

        // this.assetDetailLst = JSON.parse(this.assetDetails);
        this.getAccountGroup();
        this.getSolId();

        if (this.itemDetails != null && this.itemDetails.length > 0) {
            this.productSelectedLst = this.itemDetails;
            this.isFirstScreen = false;
        }
        // this.loadAddresses();
        if (!this.nonBsl) {
            this.assetDetailLst = JSON.parse(this.assetDetails);

            this.extractChildSerialNumbers(this.assetDetailLst);

            this.childProductRegistrationStatus = await this.fetchProductRegistrationDetails();

            this.assignDetails();
            this.gridData = this.prepareTreeData(this.assetDetailLst);

            this.filteredData = this.gridData;

            console.log('this.gridData- ' + JSON.stringify(this.gridData));

            //this.transformAssetDetails();
            console.log('this.assetDetails- ' + JSON.stringify(this.assetDetails));

        }

        console.log('assetDetailLst--', this.assetDetailLst);

        // Replace 'accountId' with the actual Account Id you want to fetch the billing address for
        this.getAccountShippingAddress(this.accountId);

        //this.gridData = this.transformData(this.assetDetailLst);
        this.loadST();
    }

    extractChildSerialNumbers(data) {
        data.forEach(invoice => {
            invoice.PRODUCT.forEach(product => {
                this.serialNumbers.push(product.SERIAL_NUMBER);
                if (Array.isArray(product.CHILD_PRODUCTS)) {
                    product.CHILD_PRODUCTS.forEach(childProduct => {
                        this.serialNumbers.push(childProduct.SERIAL_NUMBER);
                    });
                }
            });
        });
    }

    async fetchProductRegistrationDetails() {
        try {
            const result = await checkProductRegistration({ serialNumbers: this.serialNumbers, productType: this.productType });
            console.log('Registration Details - ', result);
            return result;
        } catch (error) {
            console.error('Registration Details:', error);
            console.error('Registration Details message:', error.message);
            // Handle error, display a message or log it
            return {}; // Return an empty object or appropriate default value in case of error
        }
    }



    // Add the computed property here
    get hasProducts() {
        return this.gridData.some(item => item.type === 'product');
    }

    prepareTreeData(data) {
        if (!Array.isArray(data)) {
            console.error('Data is not an array:', data);
            return [];
        }
        return data.map(item => ({
            rowIndex: ++this.rowIndex,
            id: 'INV - ' + item.INVOICE_NUMBER,
            INVOICE_NUMBER: 'INV - ' + item.INVOICE_NUMBER,
            CP_CODE: item.CP_CODE,
            BRANCH_CODE: item.BRANCH_CODE,
            DEPARTMENT: item.DEPARTMENT,
            INVOICE_DATE: item.INVOICE_DATE,

            _children: [
                ...(Array.isArray(item.PRODUCT) ? this.prepareProductNodes(item.PRODUCT) : [])],
            isSelectable: false,
            type: 'invoice'

        }));
    }

    prepareProductNodes(products) {
        try {
            return products.map(product => {

                const productRegistrationStatus = this.childProductRegistrationStatus[product.SERIAL_NUMBER];

                console.log('product registration Status -- ', productRegistrationStatus);

                return {
                    id: product.MODEL_CODE + product.SERIAL_NUMBER,
                    INVOICE_NUMBER: 'Product - ' + ++this.productIndex,
                    MODEL_CODE: product.MODEL_CODE,
                    SERIAL_NUMBER: product.SERIAL_NUMBER,
                    compositeKey: product.MODEL_CODE + product.SERIAL_NUMBER,
                    _children: [
                        ...(Array.isArray(product.CHILD_PRODUCTS) ? this.prepareChildProductNodes(product.CHILD_PRODUCTS) : []),
                        // ...(Array.isArray(product.SUBCOMPONENT) ?
                        //     this.prepareSubcomponentNodes(product.SUBCOMPONENT, 'Product - ' + this.productIndex) : [])
                    ],
                    productIndex: this.productIndex,
                    type: 'product',
                    isLookupAssetSelected: false,
                    isAssetAndFamilySelected: false,
                    asset: '',
                    assetName: '',
                    showAvailableAsset: false,
                    family: '',
                    registrationStatus: productRegistrationStatus, // Add registration status
                    isSelectable: !Array.isArray(product.CHILD_PRODUCTS) || product.CHILD_PRODUCTS.length === 0, // Set to false if CHILD_PRODUCTS exists
                    parentModelNumber: '',
                    serviceTicketId: null,
                    serviceTicketNumber: '',
                    showAvailableServiceTicket: false
                };

            });

        } catch (error) {
            console.error('Error in prepareProductNodes:', error);
            console.error('Error in prepareProductNodes:', error.message);

            return [];
        }
    }

    prepareChildProductNodes(childProducts) {
        try {
            return childProducts.map(childProduct => {
                const registrationStatus = this.childProductRegistrationStatus[childProduct.SERIAL_NUMBER];

                console.log('registrationStatus -- ', registrationStatus);


                return {
                    id: childProduct.MODEL_CODE + childProduct.SERIAL_NUMBER,
                    INVOICE_NUMBER: 'Child Product - ' + ++this.childProductIndex,
                    MODEL_CODE: childProduct.MODEL_CODE,
                    SERIAL_NUMBER: childProduct.SERIAL_NUMBER,
                    compositeKey: childProduct.MODEL_CODE + childProduct.SERIAL_NUMBER,
                    // _children: this.prepareSubcomponentNodes(childProduct.SUBCOMPONENT, 'Child Product - ' + this.childProductIndex),
                    isSelectable: true, // Allow selection for child products
                    childProductIndex: this.childProductIndex,
                    type: 'childproduct',
                    registrationStatus: registrationStatus // Add registration status
                };
            });
        } catch (error) {
            console.error('Error in prepareChildProductNodes:', error);
            console.error('Error in prepareChildProductNodes:', error.message);

            return [];
        }
    }

    prepareSubcomponentNodes(subcomponents, parentInvoiceNumber) {
        return subcomponents.map((subcomponent, subComponentIndex) => ({
            id: subcomponent.MODEL_CODE,
            INVOICE_NUMBER: parentInvoiceNumber + ' / Sub Component - ' + (subComponentIndex + 1),
            MODEL_CODE: subcomponent.MODEL_CODE,
            SERIAL_NUMBER: subcomponent.SERIAL_NUMBER,
            _children: [],
            isSelectable: false,
            type: 'subcomponent'
        }));
    }

    handleSearchChange(event) {
        this.productSearchTerm = event.target.value;
        this.applyFilter();
    }

    applyFilter() {
        try {
            if (!this.productSearchTerm) {
                // If there's no search term, show all data
                this.filteredData = this.prepareTreeData(this.assetDetailLst);
            } else {
                const searchLower = this.productSearchTerm.toLowerCase();
                console.log('Search Term:', searchLower);

                // Prepare and filter data
                const preparedData = this.prepareTreeData(this.assetDetailLst);
                console.log('Prepared Data:', JSON.stringify(preparedData));

                // Filter data based on the search term
                this.filteredData = this.filterTreeData(preparedData, searchLower);
                console.log('Filtered Data:', JSON.stringify(this.filteredData));
            }

            // Ensure the Lightning Tree Grid updates with the new filtered data
            this.filteredData = [...this.filteredData];



        } catch (error) {

            console.log('error - ' + error.message);
        }

    }

    filterTreeData(data, searchTerm) {
        return data.reduce((filtered, item) => {
            const matches = this.containsSearchTerm(item, searchTerm);

            if (matches) {
                // Include the item if it matches or has matching children
                filtered.push({
                    ...item,
                    _children: item._children ? this.filterTreeData(item._children, searchTerm) : []
                });
            } else if (item._children) {
                // Recursively filter children
                const filteredChildren = this.filterTreeData(item._children, searchTerm);
                if (filteredChildren.length > 0) {
                    // Include the item if any of its children match the search term
                    filtered.push({
                        ...item,
                        _children: filteredChildren
                    });
                }
            }

            return filtered;
        }, []);
    }


    containsSearchTerm(item, searchTerm) {
        // Convert item fields to lowercase for case-insensitive search
        const modelCode = item.MODEL_CODE ? item.MODEL_CODE.toLowerCase() : '';
        const serialNumber = item.SERIAL_NUMBER ? item.SERIAL_NUMBER.toLowerCase() : '';

        // Check if the item itself matches the search term
        const matchesModelOrSerial = modelCode.includes(searchTerm) || serialNumber.includes(searchTerm);

        if (matchesModelOrSerial) {
            return true;
        }

        // Recursively check children
        if (item._children) {
            return item._children.some(child => this.containsSearchTerm(child, searchTerm));
        }

        return false;
    }

    transformData(assetDetails) {
        return assetDetails.map(invoice => ({
            ...invoice,
            _children: invoice.PRODUCT.map((product, productIndex) => ({
                ...product,
                _children: product.CHILD_PRODUCTS.map((childProduct, childIndex) => ({
                    ...childProduct,
                    _children: childProduct.SUBCOMPONENT.map((sub, subIndex) => ({
                        ...sub,
                        name: 'Sub Component-' + (subIndex + 1),
                    })),
                    name: 'Child Product-' + (childIndex + 1),
                })),
                name: 'Product-' + (productIndex + 1),
            })),
            name: 'INV-' + ' ' + invoice.INVOICE_NUMBER,
        }));
    }


    assignDetails() {
        if (this.assetDetailLst && this.assetDetailLst.length > 0) {
            // Extracting details from the first item in the array
            const { INVOICE_NUMBER, INVOICE_DATE, CUSTOMER_CODE, DEPARTMENT, BRANCH_CODE, CP_CODE } = this.assetDetailLst[0];

            // Assign these values to variables
            this.invoiceNumber = INVOICE_NUMBER;
            this.invoiceDate = INVOICE_DATE;
            this.customerCode = CUSTOMER_CODE;
            this.department = DEPARTMENT;
            this.branchCode = BRANCH_CODE;
            this.cpCode = CP_CODE;

            console.log('Invoice Number:', this.invoiceNumber);
            console.log('Invoice Date:', this.invoiceDate);
            console.log('Customer Code:', this.customerCode);
            console.log('Department:', this.department);
            console.log('Branch Code:', this.branchCode);
            console.log('cp Code:', this.cpCode);
        }
    }


    getSolId() {

        fetchSolId({ accountId: this.accountId })
            .then(result => {

                this.solId = result;
                console.log('loading solId:', this.solId);


            })
            .catch(error => {
                console.error('Error loading solId:', error);
                console.error('Error message solId:', error.message);

                // Handle error, display a message or log it
            });

    }

    getAccountGroup() {

        getAccoountDetails({ accountId: this.accountId })
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

    loadAddresses() {
        getAddressesByAccountId({ accountId: this.accountId })
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
                // Extract the key from the result map
                //    const key = Object.keys(result)[0];
                const account = result;

                console.log('account 376 - ' + account);

                //    this.selectedAddressId = key;

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

        this.showToast(null, 'success', 'Address saved successfully');

        console.log('in address');
        this.insAssetAddress = true;

        console.log(event.detail.flat);
        console.log('in address2');
        this.address.House_Flat__c = event.detail.flat;
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



    }


    // loadCPAccounts() {
    //     getCpAccounts({ searchTerm: this.cpSearchTerm })
    //         .then(result => {
    //             console.log('available cp -- ' + JSON.stringify(result));
    //             this.filteredOptionsCP = result.map(cp => {
    //                 // Handle cases where CP_User__r might not be available
    //                 const employeeNumber = cp.CP_User__r ? cp.CP_User__r.Employee_Number__c : '';
    //                 const label = employeeNumber ? `${cp.Name} - ${employeeNumber}` : cp.Name;
    //                 return { label: label, value: cp.Id };
    //             });

    //             //this.showAvailableCodes = this.filteredOptionsProductCode.length > 0;
    //             console.log('filteredOptionsCP -- ' + JSON.stringify(this.filteredOptionsCP));

    //             this.showAvailableCP = this.filteredOptionsCP.length > 0;

    //         })
    //         .catch(error => {
    //             console.error('Error fetching product codes', error);
    //         });
    // }

    // handleOnClickCustomLookupCP(event) {

    //     try {

    //         console.log('filteredOptionsProductCode on click - ');
    //         this.loadCPAccounts(this.cpSearchTerm);

    //     }
    //     catch (error) {
    //         console.log('error - ', error);

    //     }
    // }

    // handleOnChangeCustomLookupCP(event) {

    //     this.cpSearchTerm = event.target.value.toLowerCase();

    //     console.log('cpSearchTerm  - ', this.cpSearchTerm);

    //     this.loadCPAccounts(this.cpSearchTerm);

    // }

    // handleOnFocusCustomLookupCP() {
    //     this.showAvailableCP = true;
    // }

    // handleOnBlurCustomLookupCP() {
    //     // Using setTimeout to wait a bit before hiding options so click on options can be captured
    //     setTimeout(() => {
    //         this.showAvailableCP = false;
    //     }, 300);
    // }

    // handleOptionClickCP(event) {

    //     this.selectedCP = event.currentTarget.dataset.value;
    //     this.selectedCPLabel = event.currentTarget.dataset.cplabel;


    //     console.log(' selectedCP 569 - ' + this.selectedCP);
    //     this.showAvailableCP = false;


    // }


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
            this.showToast('', 'Cannot select future date', 'warning');

            // Reset the input field
            this.installationDate = null;
        } else {
            // Clear error message if date is valid
            this.errorMessage = '';
        }

    }

    handleSOLChange(event) {
        try {
            this.solId = event.detail.value;
            console.log('solId - ', this.solId);

        } catch (error) {
            console.log('error - ', error.message);

        }

    }

    handleBackClick() {
        // Emit custom event on back click
        this.department = '';
        const backClick = new CustomEvent('backclick', {});
        this.dispatchEvent(backClick);

    }


    transformAssetDetails() {
        // Create a new array to store transformed asset details
        let transformedAssetDetails = [];

        // Iterate over each asset detail in the list
        this.assetDetails.forEach((asset, index) => {
            // Create a new object for each asset detail
            let transformedAsset = { ...asset };

            // Add name property based on the type of asset detail
            if (transformedAsset.hasOwnProperty('INVOICE_NUMBER')) {
                // For invoice
                transformedAsset.name = 'INV-' + transformedAsset.INVOICE_NUMBER;
            } else if (transformedAsset.hasOwnProperty('PRODUCT')) {
                // For product
                transformedAsset.name = 'Product-' + (index + 1);
                // Iterate over each product in the asset and assign names to subcomponents
                transformedAsset.PRODUCT.forEach((product, productIndex) => {
                    product.name = 'Product-' + (productIndex + 1); // Assign product name
                    if (Array.isArray(product.SUBCOMPONENT)) {
                        // Iterate over each subcomponent in the product
                        product.SUBCOMPONENT.forEach((subComponent, subIndex) => {
                            // Assign name to subcomponent
                            subComponent.name = 'Sub-component-' + (subIndex + 1);
                        });
                    }
                });
            }

            // Push the transformed asset detail to the new array
            transformedAssetDetails.push(transformedAsset);
        });

        // Assign the new array to assetDetails
        this.assetDetails = transformedAssetDetails;

        console.log('transformed Asset Details - ', this.assetDetails);
    }

   fetchChildCodes(selectedRowData) {
        const childrenModelCodes = [];

        //const selectedRowData = this.assetDetails.find(item => item.id === this.selectedRows[0]);

        console.log('this.selectedRows[0]-', this.selectedRows[0]);
        if (selectedRowData) {
            console.log('selectedRowData- ', JSON.stringify(selectedRowData));

            childrenModelCodes.push('INV - ' + selectedRowData.INVOICE_NUMBER);

            if (selectedRowData.CHILD_PRODUCTS && selectedRowData.CHILD_PRODUCTS.length > 0) {
                selectedRowData.CHILD_PRODUCTS.forEach(childProduct => {
                    console.log('row.PRODUCT:', childProduct);
                    let modelSerialCompositeKey1 = childProduct.MODEL_CODE + childProduct.SERIAL_NUMBER;

                    childrenModelCodes.push(modelSerialCompositeKey1);

                    this.selectedModelNumbers.push(modelSerialCompositeKey1);


                    if (childProduct.SUBCOMPONENT && childProduct.SUBCOMPONENT.length > 0) {
                        childProduct.SUBCOMPONENT.forEach(subComponent => {
                            console.log('row.SUBCOMPONENT:', subComponent);
                            childrenModelCodes.push(subComponent.MODEL_CODE);
                        });
                    }
                });
            }

            if (selectedRowData.PRODUCT && selectedRowData.PRODUCT.length > 0) {
                selectedRowData.PRODUCT.forEach(product => {
                    console.log('row.product:', product);
                    let modelSerialCompositeKey2 = product.MODEL_CODE + product.SERIAL_NUMBER;

                    // childrenModelCodes.push(product.MODEL_CODE);
                    childrenModelCodes.push(modelSerialCompositeKey2);
                    console.log('code added 491 - ', JSON.stringify(childrenModelCodes));


                    this.selectedModelNumbers.push(modelSerialCompositeKey2);

                    if (product.CHILD_PRODUCTS && product.CHILD_PRODUCTS.length > 0) {
                        product.CHILD_PRODUCTS.forEach(childProduct => {
                            console.log('row.PRODUCT:', childProduct);
                            let modelSerialCompositeKey1 = childProduct.MODEL_CODE + childProduct.SERIAL_NUMBER;

                            childrenModelCodes.push(modelSerialCompositeKey1);
                            console.log('code added 502 - ', JSON.stringify(childrenModelCodes));


                            this.selectedModelNumbers.push(modelSerialCompositeKey1);


                            if (childProduct.SUBCOMPONENT && childProduct.SUBCOMPONENT.length > 0) {
                                childProduct.SUBCOMPONENT.forEach(subComponent => {
                                    console.log('row.SUBCOMPONENT:', subComponent);
                                    childrenModelCodes.push(subComponent.MODEL_CODE);
                                });
                            }
                        });
                    }


                    if (product.SUBCOMPONENT && product.SUBCOMPONENT.length > 0) {
                        product.SUBCOMPONENT.forEach(subComponent => {
                            console.log('row.SUBCOMPONENT:', subComponent);
                            childrenModelCodes.push(subComponent.MODEL_CODE);
                        });
                    }
                });
            }

            if (selectedRowData.SUBCOMPONENT && selectedRowData.SUBCOMPONENT.length > 0) {
                selectedRowData.SUBCOMPONENT.forEach(subComponent => {
                    console.log('row.SUBCOMPONENT:', subComponent);
                    childrenModelCodes.push(subComponent.MODEL_CODE);
                });
            }
        }
        console.log('childrenModelCodes - ' + JSON.stringify(childrenModelCodes));

        return childrenModelCodes;

    }




  fetchChildrenModelCodes(selectedRowIds) {
    var childrenModelCodes = [];

    // Determine newly added row IDs
    const newlyAddedIds = selectedRowIds.filter(id => !this.selectedModelNumbers.includes(id));
    console.log('Newly added IDs: ', newlyAddedIds);

    let selectedRowId = null;
    if (newlyAddedIds.length > 0) {
        selectedRowId = newlyAddedIds[0];
    }

    if (selectedRowId != null) {
        if (selectedRowId.toString().includes('INV')) {
            selectedRowId = selectedRowId.substring(6);
        }
    } else {
        console.warn('No new row selected — skipping fetchChildrenModelCodes logic.');
        return []; // Exit early if no new selection
    }

    console.log('Selected ID --', selectedRowId);
    console.log('this.selectedRows 234 -- ', this.selectedRows);

    this.assetDetailLst.forEach(asset => {
        console.log('item - ', asset);

        if (asset.INVOICE_NUMBER === selectedRowId) {
            console.log('Invoice selected');
            childrenModelCodes = this.fetchChildCodes(asset);
        }

        if (asset.PRODUCT) {
            asset.PRODUCT.forEach(prod => {
                let currentRowId = prod.MODEL_CODE + prod.SERIAL_NUMBER;

                if (currentRowId === selectedRowId) {
                    console.log('prod - ', JSON.stringify(prod));
                    console.log('product selected - ', prod.MODEL_CODE);

                    let modelSerialCompositeKey1 = prod.MODEL_CODE + prod.SERIAL_NUMBER;
                    childrenModelCodes.push(modelSerialCompositeKey1);
                    console.log('code added 591 - ', JSON.stringify(childrenModelCodes));
                    this.selectedModelNumbers.push(modelSerialCompositeKey1);

                    if (prod.CHILD_PRODUCTS) {
                        console.log('child product - ', JSON.stringify(prod.CHILD_PRODUCTS));
                        prod.CHILD_PRODUCTS.forEach(childProd => {
                            let modelSerialCompositeKey2 = childProd.MODEL_CODE + childProd.SERIAL_NUMBER;
                            childrenModelCodes.push(modelSerialCompositeKey2);
                            console.log('code added 614 - ', JSON.stringify(childrenModelCodes));
                            this.selectedModelNumbers.push(modelSerialCompositeKey2);
                        });
                    }
                } else {
                    if (prod.CHILD_PRODUCTS) {
                        console.log('only child product selected - ', JSON.stringify(prod.CHILD_PRODUCTS));
                        prod.CHILD_PRODUCTS.forEach(childProd => {
                            let modelSerialCompositeKey2 = childProd.MODEL_CODE + childProd.SERIAL_NUMBER;

                            if (modelSerialCompositeKey2 === selectedRowId) {
                                childrenModelCodes.push(modelSerialCompositeKey2);
                                console.log('code added 614 - ', JSON.stringify(childrenModelCodes));
                                this.selectedModelNumbers.push(modelSerialCompositeKey2);
                            }
                        });
                    }
                }
            });
        }
    });

    console.log('Children Model Codes:', childrenModelCodes);
    console.log('Children Model Codes string:', JSON.stringify(childrenModelCodes));
    return childrenModelCodes;
}


selectAllRows() {
  

    this.assetDetailLst.forEach(asset => {
        if (asset.PRODUCT) {
            asset.PRODUCT.forEach(prod => {
                if (prod.registrationStatus && prod.registrationStatus !== 'Not Registered') {
                    return;
                }

                const modelSerialCompositeKey1 = prod.MODEL_CODE + prod.SERIAL_NUMBER;

                // Fetch child model codes BEFORE pushing to selectedModelNumbers
                const childrenModelCodes = this.fetchChildrenModelCodes([modelSerialCompositeKey1]);
                this.tempList.push(childrenModelCodes);

                // Now push to selectedModelNumbers
                this.selectedModelNumbers.push(modelSerialCompositeKey1);

                this.productSelectedLst.push({
                    ...prod,
                    isLookupAssetSelected: false,
                    isAssetAndFamilySelected: false,
                    asset: '',
                    assetName: '',
                    showAvailableAsset: false,
                    family: '',
                    parentModelNumber: '',
                    serviceTicketId: null,
                    serviceTicketNumber: '',
                    showAvailableServiceTicket: false
                });

                if (prod.CHILD_PRODUCTS) {
                    prod.CHILD_PRODUCTS.forEach(childProd => {
                        if (childProd.registrationStatus && childProd.registrationStatus !== 'Not Registered') {
                            return;
                        }
                        
                        const modelSerialCompositeKey2 = childProd.MODEL_CODE + childProd.SERIAL_NUMBER;

                        // Fetch child codes before pushing to selectedModelNumbers
                        const childCodes = this.fetchChildrenModelCodes([modelSerialCompositeKey2]);
                        this.tempList.push(childCodes);

                        this.selectedModelNumbers.push(modelSerialCompositeKey2);

                        this.productSelectedLst.push({
                            ...childProd,
                            isLookupAssetSelected: false,
                            isAssetAndFamilySelected: false,
                            asset: '',
                            assetName: '',
                            showAvailableAsset: false,
                            family: '',
                            parentModelNumber: '',
                            serviceTicketId: null,
                            serviceTicketNumber: '',
                            showAvailableServiceTicket: false
                        });
                    });
                }
            });
        }
    });

    // Flatten the list of all selected row ids
    this.originalSelectedRows = this.tempList;
    this.selectedRows = this.tempList.flat();
}

    // Adjust the rowSelectionHandler function

rowSelectionHandler(event) {

        var deselectedIds = [];
        const eventType = event.detail.config.action;

        console.log('eventType- ', eventType);

        try {

            if (eventType === 'rowDeselect') 
            {
                const currentSelectedRows = this.template.querySelector('lightning-tree-grid').getSelectedRows();
                const currentlySelectedIds = currentSelectedRows.map(row => row.id);
                const previouslySelectedIds = this.selectedModelNumbers;

                // Find which IDs were removed (deselected)
                const deselectedIds = previouslySelectedIds.filter(id => !currentlySelectedIds.includes(id));
                console.log('Deselected Ids: ', deselectedIds);

                // Remove deselected IDs from productSelectedLst
                this.productSelectedLst = this.productSelectedLst.filter(prod => !deselectedIds.includes(prod.MODEL_CODE + prod.SERIAL_NUMBER));

                // Remove deselected IDs from selectedModelNumbers
                this.selectedModelNumbers = this.selectedModelNumbers.filter(id => !deselectedIds.includes(id));

                // Remove from originalSelectedRows
                this.originalSelectedRows = this.originalSelectedRows.map(group => {
                return group.filter(id => !deselectedIds.includes(id));
                }).filter(group => group.length > 0); // remove empty groups

                // Flatten again
                this.tempList = this.originalSelectedRows;
                this.selectedRows = this.originalSelectedRows.flat();
            }
            if (eventType === 'selectAllRows') 
            {
                const allRows = this.template.querySelector('lightning-tree-grid').getSelectedRows();
                console.log('allRows:', allRows);
                const nonSelectableRows = allRows.filter(row => row.registrationStatus && row.registrationStatus !== 'Not Registered');
                this.selectAllRows();
         
            } 
            if (eventType === 'deselectAllRows') 
            {
                // Clear internal tracking arrays
                this.tempList = [];
                this.selectedRows = [];
                this.selectedModelNumbers = [];
                this.originalSelectedRows = [];
                this.productSelectedLst = [];

                console.log('Deslected All Rows...');
            } 
            if (eventType === 'rowSelect') 
            {
                const selectedRows = this.template.querySelector('lightning-tree-grid').getSelectedRows();
                console.log('Selected Rows 1211:', selectedRows);

                // Check if any row has a non-blank registrationStatus, making it unselectable
                const nonSelectableRows = selectedRows.filter(row => row.registrationStatus && row.registrationStatus !== 'Not Registered');

                if (nonSelectableRows.length > 0) {
                    // If there are non-selectable rows, show a warning and deselect them
                    console.log('Non-selectable rows detected:', nonSelectableRows);
                    this.showToast(null, 'warning', 'Selected serial number is already registered');

                    // Filter out non-selectable rows from the selectedRows
                    this.selectedRows = selectedRows.filter(row => !nonSelectableRows.includes(row.id));
                    console.log('Filtered selected rows:', this.selectedRows);

                    return;  // Prevent further processing of non-selectable rows
                }

                 this.productSelectedLst = selectedRows.map(row => {
                                        return {
                                            ...row,  // Spread existing properties
                                            isLookupAssetSelected: false,
                                            isAssetAndFamilySelected: false,
                                            asset: '',
                                            assetName: '',
                                            showAvailableAsset: false,
                                            family: '',
                                            parentModelNumber:'',
                                            serviceTicketId: null,
                                            serviceTicketNumber:'',
                                            showAvailableServiceTicket: false
                                        };
                                    });
                console.log("productselectedlst :" + JSON.stringify( this.productSelectedLst));
                const selectedRowId = selectedRows.map(row => row.id);
                console.log('Selected Row Id:', selectedRowId);

                const newlyAddedIds = selectedRowId.filter(id => !this.selectedModelNumbers.includes(id));
                let currentSelectedId = null;
                if (newlyAddedIds.length > 0) {
                    currentSelectedId = newlyAddedIds[0];
                }

                const isRowSelectable = selectedRows.some(row => row.isSelectable);
                console.log('is selectable - ', isRowSelectable);

                if (isRowSelectable) {
                    console.log('is selectable - ', isRowSelectable);
                    const childrenModelCodes = this.fetchChildrenModelCodes(selectedRowId);
                    this.tempList.push(childrenModelCodes);
                    console.log('this.tempList:', this.tempList);
                    this.originalSelectedRows = this.tempList;
                    this.selectedRows = this.originalSelectedRows.flat();
                    console.log('final selectedRows:', this.selectedRows);
                } else {
                    this.selectedRows = selectedRowId.filter(id => id !== currentSelectedId);
                    console.log('Updated selectedRows:', this.selectedRows);
                }
            }

            // Remove duplicates from selectedModelNumbers
            this.selectedModelNumbers = [...new Set(this.selectedModelNumbers.flat())];
            console.log('this.selectedModelNumbers final:', JSON.stringify(this.selectedModelNumbers));

        } catch (error) {
            console.error('Error in rowSelectionHandler:', error.message);
            console.error('Error in rowSelectionHandler:', error.lineNumber);
        }
    }

   modelNumberChangeHandler(event) {
        this.newModelNumber = event.detail.value;
        console.log('newModelNumber - ', this.newModelNumber);

    }
    serialNumberChangeHandler(event) {
        this.newSerialNumber = event.detail.value;
        console.log('newSerialNumber - ', this.newSerialNumber);

    }

    showToast(title, variant, message) {
        const event = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message,
        });
        this.dispatchEvent(event);
    }

validateSelectedRows() {
    const invalidRows = this.productSelectedLst.filter(prod => prod.registrationStatus !== 'Not Registered');

    if (invalidRows.length > 0) {
        const invalidCodes = invalidRows.map(p => p.MODEL_CODE + p.SERIAL_NUMBER);
        
        // Display a warning to the user (toast, alert, or custom message area)
        alert(`The following rows have a status other than "Not Registered":\n\n${invalidCodes.join(', ')}\n\nPlease deselect them to proceed.`);
        
        return false; // Indicate invalid state
    }

    return true; // All good
}
    // Handler for the Next button click to show selected rows on next screen
    handleNextClick() 
    {
         // Step 1: Get selected rows
        const treeGrid = this.template.querySelector('lightning-tree-grid');
        const selectedRows = treeGrid.getSelectedRows();

        // Step 2: Check if any selected row has a status other than 'Not Registered'
        const invalidRows = selectedRows.filter(row => row.registrationStatus && row.registrationStatus !== 'Not Registered');

        if (invalidRows.length > 0) 
        {
            // Step 3: Show error toast and stop
            this.showToast(null, 'error', 'Some selected rows are already registered or in Commission. Please deselect them to proceed.');
            return;
        }
        console.log('this.selectedRows.length -- ' + this.selectedRows.length);

        this.showSpinner = true;
        if (this.selectedRows.length != 0 && this.selectedRows != null && this.selectedRows != []) {

            console.log('productSelectedLst String -- ' + JSON.stringify(this.productSelectedLst));

            console.log('productSelectedLst -- ' + this.productSelectedLst);

            console.log('selectedRows -- ' + JSON.stringify(this.selectedRows));

           
           
                        this.showSpinner = false;
                        this.isFirstScreen = false; // Show next screen
                        //this.loadAssetAndFamilyOptions(); // Load dropdown options
                  

        } else {
            // Handle case where no rows are selected (optional)
            console.log('No rows selected');
            this.showToast('Error', 'error', 'Please select product to proceed');

            this.showSpinner = false;

        }
    }

    // Reusable method to check and update row selection
    updateRowSelectionState(rowIndex) {
        const currentRow = this.productSelectedLst[rowIndex];

        // If both asset, family, and modelCode are cleared, enable re-selection
        if (!currentRow.asset && !currentRow.family && !currentRow.modelCode) {
            console.log('All selections cleared, enabling lookup.');
            this.updateRowSelection(rowIndex, { isAssetAndFamilySelected: false });  // Allow re-selection
        } else {
            console.log('At least one selection present, keeping lookup disabled.');
            // this.updateRowSelection(rowIndex, { isAssetAndFamilySelected: true });  // Lock selection
        }
    }

    // Generalized handler for clearing selections
    clearSelection(rowIndex, field) {
        console.log(`Clearing ${field} selection`);
        const updateObj = {};
        updateObj[field] = null;
        this.updateRowSelection(rowIndex, updateObj);  // Reset the specified field
        this.updateRowSelectionState(rowIndex);        // Check the state after clearing
    }

    // Handle asset change in dropdown
    handleAssetChange(event) {
        const selectedAsset = event.detail.value;
        const rowIndex = event.currentTarget.dataset.index;  // Get the row ID for row-specific logic

        if (!selectedAsset) {
            this.clearSelection(rowIndex, 'asset');
        } else {
            console.log('Asset selected: ', selectedAsset);
            this.updateRowSelection(rowIndex, { asset: selectedAsset, isAssetAndFamilySelected: true });  // Lock the family selection

        }
    }

    // Handle family change in dropdown
    handleFamilyChange(event) {
        const selectedFamily = event.detail.value;
        const rowIndex = event.currentTarget.dataset.index;  // Get the row ID for row-specific logic

        if (!selectedFamily) {
            this.clearSelection(rowIndex, 'type');
        } else {
            console.log('Family selected: ', selectedFamily);
            this.updateRowSelection(rowIndex, { family: selectedFamily, isAssetAndFamilySelected: true });  // Lock the family selection
        }
    }

    handleProductTypeChange(event) {
        const selectedType = event.detail.value;
        const rowIndex = event.currentTarget.dataset.index;  // Get the row ID for row-specific logic

        console.log('productType selected: ', selectedType);
        this.updateRowSelection(rowIndex, { type: selectedType });

        const selectedProductmodelnumber = this.productSelectedLst[rowIndex];  // assuming index matches
        const modelCode = selectedProductmodelnumber?.MODEL_CODE || ''; 

         if (!modelCode) {
            this.clearSelection(rowIndex, 'parentModelNumber');
        } else {
            console.log('Model number selected: ', modelCode);
            this.updateRowSelection(rowIndex, { parentModelNumber: modelCode, isAssetAndFamilySelected: true });  // Lock the family selection
          
        }

    }

    // Handle model number change in dropdown
    handleModelNumberChange(event) {
        const modelCode = event.detail.value;
        const rowIndex = event.currentTarget.dataset.index;  // Get the row ID for row-specific logic

        if (!modelCode) {
            this.clearSelection(rowIndex, 'parentModelNumber');
        } else {
            console.log('Model number selected: ', modelCode);
            this.updateRowSelection(rowIndex, { parentModelNumber: modelCode, isAssetAndFamilySelected: true });  // Lock the family selection

        }
    }


    loadAsset(searchTermAsset, modelCode) {
        fetchAsset({ searchTerm: searchTermAsset, accountId: this.accountId, modelCode: modelCode })
            .then(result => {
                console.log('asset names -- ' + JSON.stringify(result));
                const assetSet = new Set(result); // Using Set to store unique product codes
                this.filteredOptionsAsset = Array.from(assetSet).map(asset => {
                    return { label: asset.Name, value: asset.Id };
                });
                //this.showAvailableCodes = this.filteredOptionsProductCode.length > 0;
                console.log('filteredOptionsAsset -- ' + JSON.stringify(this.filteredOptionsAsset));
            })
            .catch(error => {
                console.error('Error fetching product codes', error);
            });
    }

    loadST(searchTerm) {
        fetchServiceTicket({ searchTerm: searchTerm, accountId: this.accountId, productType: this.productType })
            .then(result => {
                console.log('ST number -- ' + JSON.stringify(result));
                const stSet = new Set(result);
                this.filteredOptionsST = Array.from(stSet).map(st => {
                    return { label: st.Ticket_Number_Read_Only__c, value: st.Id };
                });
                console.log('filteredOptionsST -- ' + JSON.stringify(this.filteredOptionsST));
            })
            .catch(error => {
                console.error('Error fetching Service Ticket', error);
            });
    }


    // Handle click on custom lookup asset
    handleOnClickCustomLookupAsset(event) {
        try {
            const rowIndex = event.currentTarget.dataset.index;
            const modelCode = this.productSelectedLst[rowIndex].MODEL_CODE;
            console.log('Row ID for click - ', rowIndex);
            console.log('modelCode - ', modelCode);

            this.loadAsset('', modelCode); // Load all assets with an empty search term

            // Show the dropdown for the clicked row only
            this.updateRowSelection(rowIndex, { showAvailableAsset: true });
            console.log('Updated productSelectedLst: ' + JSON.stringify(this.productSelectedLst));
            console.log('Dropdown visibility for the row is set to true');

        } catch (error) {
            console.error('Error in handleOnClickCustomLookupAsset:', error.message);
        }
    }

    // Handle change on custom lookup asset
    handleOnChangeCustomLookupAsset(event) {
        try {
            const searchTermAsset = event.target.value.toLowerCase();
            const rowIndex = event.currentTarget.dataset.index;
            const assetName = event.target.value;
            const modelCode = this.productSelectedLst[rowIndex].MODEL_CODE;

            console.log('assetName  - ', assetName);

            this.updateRowSelection(rowIndex, { assetName: assetName });
            this.loadAsset(searchTermAsset, modelCode);

            if (!assetName || assetName.trim() === "") {
                console.log("Asset name is not present, enabling fields...");
                this.updateRowSelection(rowIndex, {
                    isLookupAssetSelected: false,
                    isAssetAndFamilySelected: false,
                    assetName: null
                });
            }
        } catch (error) {
            console.error('Error in handleOnChangeCustomLookupAsset:', error.message);
        }
    }


    // Handle focus on custom lookup asset
    handleOnFocusCustomLookupAsset(event) {
        try {
            const rowIndex = event.currentTarget.dataset.index;
            console.log('onfocus - ' + rowIndex);
            this.updateRowSelection(rowIndex, { showAvailableAsset: true });
            console.log('Updated productSelectedLst: ' + JSON.stringify(this.productSelectedLst));
        } catch (error) {
            console.error('Error in handleOnFocusCustomLookupAsset:', error.message);
        }
    }

    // Handle blur on custom lookup asset
    handleOnBlurCustomLookupAsset(event) {
        try {
            const rowIndex = event.currentTarget.dataset.index;
            console.log('onblur - ' + rowIndex);
            setTimeout(() => {
                this.updateRowSelection(rowIndex, { showAvailableAsset: false });
            }, 300);
            console.log('Updated productSelectedLst: ' + JSON.stringify(this.productSelectedLst));
            console.log('Dropdown visibility set to false for row: ' + rowIndex);
        } catch (error) {
            console.error('Error in handleOnBlurCustomLookupAsset:', error.message);
        }
    }



    handleAssetNameChangeCustomLookup(event) {
        try {
            console.log("option clicked: ");

            const rowIndex = event.currentTarget.dataset.index;
            console.log('rowId  - ', rowIndex);

            const selectedAssetId = event.currentTarget.dataset.id;
            console.log('selectedAssetId - ' + selectedAssetId);

            const assetName = event.currentTarget.dataset.value;
            console.log("option clicked: " + assetName);

            // Update the row with all necessary fields at once
            this.updateRowSelection(rowIndex, {
                asset: selectedAssetId,              // Set the selected asset ID
                family: null,                        // Clear the family selection
                isLookupAssetSelected: true,         // Disable the lookup field
                isAssetAndFamilySelected: false,     // Reset asset and family selection
                assetName: assetName,                // Set the asset name in the row
                showAvailableAsset: false            // Hide the dropdown for this row
            });

            console.log("called ");

        } catch (error) {
            console.error('Error in handleAssetNameChangeCustomLookup:', error.message);
        }
    }

    // Handle click on custom lookup service ticket
    handleOnClickCustomLookupServiceTicket(event) {
        try {
            const rowIndex = event.currentTarget.dataset.index;
            console.log('Row ID for click - ', rowIndex);

            this.loadST(); // Load all service tickets with an empty search term

            // Show the dropdown for the clicked row only
            this.updateRowSelection(rowIndex, { showAvailableServiceTicket: true });
            console.log('Updated productSelectedLst: ' + JSON.stringify(this.productSelectedLst));
            console.log('Dropdown visibility for the row is set to true');

        } catch (error) {
            console.error('Error in handleOnClickCustomLookupServiceTicket:', error.message);
        }
    }

    // Handle change on custom lookup service ticket
    handleOnChangeCustomLookupServiceTicket(event) {
        try {
            const searchTermServiceTicket = event.target.value.toLowerCase();
            const rowIndex = event.currentTarget.dataset.index;
            const serviceTicketNumber = event.target.value;
            console.log('Service Ticket Name - ', serviceTicketNumber);

            this.updateRowSelection(rowIndex, { serviceTicketNumber: serviceTicketNumber });
            this.loadST(searchTermServiceTicket);
            if (!serviceTicketNumber || serviceTicketNumber.trim() === "") {
                console.log("serviceTicketNumber is not present, enabling fields...");
                this.updateRowSelection(rowIndex, {
                    isLookupAssetSelected: false,
                    isAssetAndFamilySelected: false,
                    serviceTicketNumber: null
                });
            }
        } catch (error) {
            console.error('Error in handleOnChangeCustomLookupServiceTicket:', error.message);
        }
    }

    // Handle focus on custom lookup service ticket
    handleOnFocusCustomLookupServiceTicket(event) {
        try {
            const rowIndex = event.currentTarget.dataset.index;
            console.log('onfocus - ' + rowIndex);
            this.updateRowSelection(rowIndex, { showAvailableServiceTicket: true });
            console.log('Updated productSelectedLst: ' + JSON.stringify(this.productSelectedLst));
        } catch (error) {
            console.error('Error in handleOnFocusCustomLookupServiceTicket:', error.message);
        }
    }

    // Handle blur on custom lookup service ticket
    handleOnBlurCustomLookupServiceTicket(event) {
        try {
            const rowIndex = event.currentTarget.dataset.index;
            console.log('onblur - ' + rowIndex);
            setTimeout(() => {
                this.updateRowSelection(rowIndex, { showAvailableServiceTicket: false });
            }, 300);
            console.log('Updated productSelectedLst: ' + JSON.stringify(this.productSelectedLst));
            console.log('Dropdown visibility set to false for row: ' + rowIndex);
        } catch (error) {
            console.error('Error in handleOnBlurCustomLookupServiceTicket:', error.message);
        }
    }

    // Handle service ticket selection from lookup
    handleServiceTicketNameChangeCustomLookup(event) {
        try {
            console.log("option clicked: ");

            const rowIndex = event.currentTarget.dataset.index;
            console.log('Row ID - ', rowIndex);

            const selectedServiceTicketId = event.currentTarget.dataset.id;
            console.log('selectedServiceTicketId - ' + selectedServiceTicketId);

            const serviceTicketNumber = event.currentTarget.dataset.value;
            console.log("option clicked: " + serviceTicketNumber);

            // Update the row with all necessary fields at once
            this.updateRowSelection(rowIndex, {
                serviceTicketId: selectedServiceTicketId,      // Set the selected service ticket ID
                serviceTicketNumber: serviceTicketNumber,        // Set the service ticket name in the row
                showAvailableServiceTicket: false,            // Hide the dropdown for this row
                isAssetAndFamilySelected: true,     // Reset asset and family selection
                isLookupAssetSelected: true,
                asset: null,
                family: null,
                assetName: null
            });

            console.log("called ");

        } catch (error) {
            console.error('Error in handleServiceTicketNameChangeCustomLookup:', error.message);
        }
    }



    updateRowSelection(rowIndex, fieldsToUpdate) {
        try {
            // Add more logs to check flow
            console.log('Inside updateRowSelection');
            console.log('rowIndex: ' + rowIndex + ' Value: ' + JSON.stringify(fieldsToUpdate));

            // Check if productSelectedLst exists and has data
            if (!this.productSelectedLst || this.productSelectedLst.length === 0) {
                console.error('productSelectedLst is empty or undefined');
                return;
            }

            // Clone the productSelectedLst array
            let updatedProductList = [...this.productSelectedLst];

            // Update the specific row by index
            updatedProductList[rowIndex] = {
                ...updatedProductList[rowIndex],
                ...fieldsToUpdate
            };

            this.productSelectedLst = updatedProductList;
            // Log the updated productSelectedLst
            console.log('Updated productSelectedLst: ' + JSON.stringify(this.productSelectedLst));

        } catch (error) {
            console.error('Error in updateRowSelection:', error.message);
        }
    }

    async createWorkOrderHandler(event) {
        console.log('Starting Work Order creation...');

        try {
            

            // Step 1: Validate department using fetchServiceDepartment
            if (this.department != null) {
                const serviceDepartment = await this.fetchServiceDepartment(this.department);
                console.log('Service Department',serviceDepartment);
                if (serviceDepartment !== '50' && serviceDepartment !== '51') {
                    console.error('Invalid Department');
                    this.showToast('Error', 'error', 'Tickets can only be created for departments 50 or 51');
                    this.showSpinner = false;
                    return;
                }
            }

            if (this.productType === 'Chiller' && this.uploadedFileNames.length < 1) {
                console.error('No file uploaded!');
                this.showToast('Error', 'error', 'No File Uploaded!');
                return Promise.reject({ response: 'Error', message: 'No File Uploaded!' });
            }

            if (this.productType === 'VRF' && this.uploadedFileNames.length < 4) {
                console.error('No file uploaded!');
                this.showToast('Error', 'error', 'No File Uploaded!');
                return Promise.reject({ response: 'Error', message: 'No File Uploaded!' });
            }

            if (this.productSelectedLst.length === 0) {
                console.error('No products selected!');
                this.showToast('Error', 'error', 'No products selected');
                return
            } 

             console.error('this.productSelectedLst.length - ' + this.productSelectedLst.length);
            const invalidProducts = this.productSelectedLst.filter(product => {
                console.error(' products - ' + product);
                const hasAssetAndModel = product.asset && product.parentModelNumber;
                const hasServiceTicket = product.serviceTicketId;
                return !(hasAssetAndModel || hasServiceTicket); // Product is invalid if neither condition is met
            }); 

            if (invalidProducts.length > 0 && this.productType === 'VRF') {
                console.error('Validation failed for selected products:', invalidProducts);
                this.showToast('Error', 'error', 'All selected products must have either Asset and Parent Model Number or a Service Ticket.');
                return;
            } 
             //this.serviceTerritories = 'Id';
              /* if (!serviceTerritories || serviceTerritories.length > 0) 
                {
                   // Show an error
                     console.error('Service Territory is not assigned to cp:',serviceTerritories);
                      this.showToast('Error', 'error', 'Service Territory is not assigned to cp');
                       return;
    
                } */


            const result = await this.createWorkOrderAndLineItem();

            // Handle the result assuming it's already JSON or a valid object
            const parsedResult = typeof result === 'string' ? JSON.parse(result) : result;

            console.log('Result from Apex: ', parsedResult);

            if (parsedResult.response === 'Success') {
                this.showSpinner = false;
                this.showToast('Success', 'success', 'Service Ticket created successfully - ' + parsedResult.message);

                this.selectedModelNumbers = [];

                // Fire custom event to notify parent component
                const successEvent = new CustomEvent('success');
                this.dispatchEvent(successEvent);
            } else {
                this.showToast('Error', 'error', parsedResult.message);
                this.showSpinner = false;
            }
       } catch (error) {
           console.error('Error in Work Order creation: ', error);
            this.showToast('Error', 'error', 'Failed to create Service Ticket');
            this.showSpinner = false;
           } 
    }

    // Fetch and validate service department via Apex
    fetchServiceDepartment(department) {
        return fetchServiceDepartment({ department })
            .then(result => result)
            .catch(error => {
                console.error('Error fetching service department:', error);
                this.showToast('Error', 'error', 'Failed to validate department');
                this.showSpinner = false;
                throw error;
            });
    }

    createWorkOrderAndLineItem() {

        console.log('department - ' + this.department);
        console.log('subFamilyId - ' + this.subfamilyId);

        this.showSpinner = true;

        // Call the Apex method and handle the product type logic
        return createWorkOrderAndLineItems({
            productList: JSON.stringify(this.productSelectedLst), // Send the correct product list structure
            accountId: this.accountId,
            address: JSON.stringify(this.address),
            productType: this.productType,
            branchId: this.branchId,
            invoiceNumber: this.invoiceNumber,
            invoiceDate: this.invoiceDate,
            department: this.department,
            cp: this.cpId,
            documentIds: this.uploadedFileNames.map(file => file.id),
            cpCode: this.cpCode,
            subFamilyId: this.subfamilyId

        })
            /* .then(result => {
                console.log('Result from Apex: ', result);
                this.serviceTerritories = result;
                console.log('Check Service Terrotories==>',JSON.stringify(this.serviceTerritories));
                return result;
                  // Ensure that result is a JSON-formatted string or object
            })  */
            .then(result => {
    this.serviceTerritories = JSON.parse(result);

    if (!this.serviceTerritories || this.serviceTerritories.length === 0) {
        this.showToast('Error', 'error', 'Service Territory is not assigned to cp');
        return;
    }

    return this.serviceTerritories; 
})
            .catch(error => {
                console.error('Error in creating Work Order or Service Ticket:', error);
                this.showSpinner = false;
                this.showToast('Error', 'error', 'Failed to create Service Ticket');
                return { response: 'Error', message: 'Failed to create Service Ticket' };
            });
    }


    get isChillerProductType() {
        return this.productType === 'Chiller';
    }

    get isDuctedProductType() {
        return this.productType === 'Ducted Split';
    }

    get isVRFProductType() {
        return this.productType === 'VRF';
    }

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        const fileUploadName = this.template.querySelector('lightning-file-upload').name;
        console.log("fileUploadName -- " + fileUploadName);


        this.isFileUploaded = true;


        // Add each uploaded file to uploadedFileNames array
        uploadedFiles.forEach(file => {
            this.uploadedFileNames.push({
                id: file.documentId,
                name: file.name,
                fileName: fileUploadName
            });
        });


        this.dispatchEvent(
            new ShowToastEvent({
                title: "Success",
                message:
                    uploadedFiles.length +
                    " Files uploaded Successfully: ",
                variant: "success"
            })
        );
        console.log("uploadedFileNames -- " + this.uploadedFileNames[0].name);
        console.log("isFileUploaded -- " + this.isFileUploaded);

    }

    handleFileClick(event) {
        const fileId = event.currentTarget.dataset.id;
        // Construct the URL for the file
        const fileUrl = `/sfc/servlet.shepherd/document/download/${fileId}`;
        // Open the file in a new tab
        window.open(fileUrl, "_blank");
    }
    handleCloseFile(event) {
        const fileIdToRemove = event.currentTarget.dataset.id;
        this.uploadedFileNames = this.uploadedFileNames.filter(file => file.id !== fileIdToRemove);
        this.isFileUploaded = this.uploadedFileNames.length > 0;
    }

}