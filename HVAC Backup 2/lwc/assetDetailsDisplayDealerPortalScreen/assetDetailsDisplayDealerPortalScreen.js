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

import checkProductRegistration from '@salesforce/apex/AssetRegistrationController.checkProductRegistration';

import fetchSolId from "@salesforce/apex/AssetRegistrationController.fetchSolId";

import LightningConfirm from 'lightning/confirm';

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

export default class AssetDetailsDisplayDealerPortalScreen extends LightningElement {

    rowIndex = 0;
    productIndex = 0;
    childProductIndex = 0;

    @api assetId;
    @api uploadedFiles;

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
        @track modelNumbers = [];




    selectedItemValue;

    //asset details from parent
    @api assetDetails;
    @api accountId;
    @api productType;


    @track accountGroup;

    @track isNAMO = false;

    @track invoiceNumber;
    @track invoiceDate;
    @track customerCode;
    @track department;
    @track branchCode;
    @track isAddressChanged = false;

    @track selectedRowLst;

    @track selectedModelNumbers = [];
    @track selectedSerialNumbers = [];


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

    @track currentExpanded = [];
    insAssetAddress = false;

    async connectedCallback() {
        console.log('accountId- ', this.accountId);
        console.log('product type- ', this.productType);

        // this.assetDetailLst = JSON.parse(this.assetDetails);
        if (this.assetId) {
            this.nonBsl = true;

        }
        console.log('this.nonbsl', this.nonBsl);
        this.getAccountGroup();
        this.getSolId();

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

    }

    extractChildSerialNumbers(data) {
        data.forEach(invoice => {
            invoice.PRODUCT.forEach(product => {
                this.serialNumbers.push(product.SERIAL_NUMBER);
                this.modelNumbers.push(product.MODEL_CODE);
                if (Array.isArray(product.CHILD_PRODUCTS)) {
                    product.CHILD_PRODUCTS.forEach(childProduct => {
                        this.serialNumbers.push(childProduct.SERIAL_NUMBER);
                        this.modelNumbers.push(childProduct.MODEL_CODE);

                    });
                }
            });
        });
    }

    async fetchProductRegistrationDetails() {
        try {
            const result = await checkProductRegistration({ serialNumbers: this.serialNumbers, modelNumbers: this.modelNumbers });
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
            isSelectable: true,
            type: 'invoice'

        }));
    }

    prepareProductNodes(products) {
        try {
            return products.map(product => {
                const modelSrKey = product.SERIAL_NUMBER + product.MODEL_CODE;

                const productRegistrationStatus = this.childProductRegistrationStatus[modelSrKey];

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
                    isSelectable: productRegistrationStatus !== 'Registered', // Allow selection only if not registered
                    productIndex: this.productIndex,
                    type: 'product',
                    registrationStatus: productRegistrationStatus // Add registration status

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
                                const modelSrKey = childProduct.SERIAL_NUMBER + childProduct.MODEL_CODE;

                const registrationStatus = this.childProductRegistrationStatus[modelSrKey];
                //const isRegistered = (registrationStatus === 'Registered') || 'Not Registered';

                console.log('registrationStatus -- ', registrationStatus);


                return {
                    id: childProduct.MODEL_CODE + childProduct.SERIAL_NUMBER,
                    INVOICE_NUMBER: 'Child Product - ' + ++this.childProductIndex,
                    MODEL_CODE: childProduct.MODEL_CODE,
                    SERIAL_NUMBER: childProduct.SERIAL_NUMBER,
                    compositeKey: childProduct.MODEL_CODE + childProduct.SERIAL_NUMBER,
                    // _children: this.prepareSubcomponentNodes(childProduct.SUBCOMPONENT, 'Child Product - ' + this.childProductIndex),
                    isSelectable: (registrationStatus === 'Not Registered') || false, // Allow selection for child products
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
            const { INVOICE_NUMBER, INVOICE_DATE, CUSTOMER_CODE, DEPARTMENT, BRANCH_CODE } = this.assetDetailLst[0];

            // Assign these values to variables
            this.invoiceNumber = INVOICE_NUMBER;
            this.invoiceDate = INVOICE_DATE;
            this.customerCode = CUSTOMER_CODE;
            this.department = DEPARTMENT;
            this.branchCode = BRANCH_CODE;

            console.log('Invoice Number:', this.invoiceNumber);
            console.log('Invoice Date:', this.invoiceDate);
            console.log('Customer Code:', this.customerCode);
            console.log('Department:', this.department);
            console.log('Branch Code:', this.branchCode);
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

        this.loadCPAccounts(this.cpSearchTerm);

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
            this.showToast('', 'error', 'Cannot select future date');

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
                    this.selectedSerialNumbers.push(childProduct.SERIAL_NUMBER);

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
                    this.selectedSerialNumbers.push(product.SERIAL_NUMBER);


                    if (product.CHILD_PRODUCTS && product.CHILD_PRODUCTS.length > 0) {
                        product.CHILD_PRODUCTS.forEach(childProduct => {
                            console.log('row.PRODUCT:', childProduct);
                            let modelSerialCompositeKey1 = childProduct.MODEL_CODE + childProduct.SERIAL_NUMBER;

                            childrenModelCodes.push(modelSerialCompositeKey1);
                            console.log('code added 502 - ', JSON.stringify(childrenModelCodes));


                            this.selectedModelNumbers.push(modelSerialCompositeKey1);
                            this.selectedSerialNumbers.push(childProduct.SERIAL_NUMBER);



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

        //var selectedRowId;
        var childrenModelCodes = [];

        const newlyAddedIds = selectedRowIds.filter(id => !this.selectedModelNumbers.includes(id));

        let selectedRowId = null;
        if (newlyAddedIds.length > 0) {
            selectedRowId = newlyAddedIds[0];
        }

        if (selectedRowId.toString().includes('INV')) {
            selectedRowId = selectedRowId.substring(6);
        }

        console.log('selected Id--', selectedRowId);

        console.log('this.selectedRows 234 -- ', this.selectedRows);

        this.assetDetailLst.forEach(asset => {
            console.log('item - ', asset);

            if (asset.INVOICE_NUMBER === selectedRowId) {

                console.log('invoice selected');

                childrenModelCodes = this.fetchChildCodes(asset);

            }
            if (asset.PRODUCT) {

                asset.PRODUCT.forEach(prod => {


                    let currentRowId = prod.MODEL_CODE + prod.SERIAL_NUMBER;

                    if (currentRowId === selectedRowId) {
                        console.log('prod - ', JSON.stringify(prod));


                        console.log('product selected- ', prod.MODEL_CODE);


                        let modelSerialCompositeKey1 = prod.MODEL_CODE + prod.SERIAL_NUMBER;


                        console.log('modelSerialCompositeKey1', JSON.stringify(modelSerialCompositeKey1));


                        //childrenModelCodes.push(prod.MODEL_CODE);
                        childrenModelCodes.push(modelSerialCompositeKey1);

                        console.log('code added 591 - ', JSON.stringify(childrenModelCodes));


                        this.selectedModelNumbers.push(modelSerialCompositeKey1);
                        this.selectedSerialNumbers.push(prod.SERIAL_NUMBER);



                        if (prod.CHILD_PRODUCTS) {
                            console.log('child product - ', JSON.stringify(prod.CHILD_PRODUCTS));

                            prod.CHILD_PRODUCTS.forEach(childProd => {
                                console.log('childProd.MODEL_CODE - ', childProd.MODEL_CODE);
                                console.log('selectedRowId - ', selectedRowId);

                                let modelSerialCompositeKey2 = childProd.MODEL_CODE + childProd.SERIAL_NUMBER;

                                // childrenModelCodes.push(childProd.MODEL_CODE);
                                childrenModelCodes.push(modelSerialCompositeKey2);
                                console.log('code added 614 - ', JSON.stringify(childrenModelCodes));


                                this.selectedModelNumbers.push(modelSerialCompositeKey2);
                                this.selectedSerialNumbers.push(childProd.SERIAL_NUMBER);



                            });
                        }
                    }
                    else {
                        if (prod.CHILD_PRODUCTS) {
                            console.log('only child product seleected- ', JSON.stringify(prod.CHILD_PRODUCTS));

                            prod.CHILD_PRODUCTS.forEach(childProd => {
                                console.log('childProd.MODEL_CODE - ', childProd.MODEL_CODE);
                                console.log('selectedRowId - ', selectedRowId);

                                let modelSerialCompositeKey2 = childProd.MODEL_CODE + childProd.SERIAL_NUMBER;

                                if (modelSerialCompositeKey2 === selectedRowId) {

                                    // childrenModelCodes.push(childProd.MODEL_CODE);
                                    childrenModelCodes.push(modelSerialCompositeKey2);
                                    console.log('code added 614 - ', JSON.stringify(childrenModelCodes));

                                    this.selectedModelNumbers.push(modelSerialCompositeKey2);
                                    this.selectedSerialNumbers.push(childProd.SERIAL_NUMBER);



                                }




                                // if (childProd.SUBCOMPONENT) {
                                //     childProd.SUBCOMPONENT.forEach(subComp => {
                                //         childrenModelCodes.push(subComp.MODEL_CODE);
                                //     });

                                // }
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

                    console.log('prod - ', JSON.stringify(prod));

                    console.log('product selected- ', prod.MODEL_CODE);

                    let modelSerialCompositeKey1 = prod.MODEL_CODE + prod.SERIAL_NUMBER;


                    console.log('modelSerialCompositeKey1', JSON.stringify(modelSerialCompositeKey1));


                    //childrenModelCodes.push(prod.MODEL_CODE);
                    //childrenModelCodes.push(modelSerialCompositeKey1);

                    //console.log('code added 591 - ', JSON.stringify(childrenModelCodes));



                    this.selectedModelNumbers.push(modelSerialCompositeKey1);
                    this.selectedSerialNumbers.push(prod.SERIAL_NUMBER);


                    // if (prod.SUBCOMPONENT) {
                    //     prod.SUBCOMPONENT.forEach(subComp => {
                    //         childrenModelCodes.push(subComp.MODEL_CODE);
                    //     });
                    // }

                    if (prod.CHILD_PRODUCTS) {
                        console.log('child product - ', JSON.stringify(prod.CHILD_PRODUCTS));

                        prod.CHILD_PRODUCTS.forEach(childProd => {
                            console.log('childProd.MODEL_CODE - ', childProd.MODEL_CODE);

                            let modelSerialCompositeKey2 = childProd.MODEL_CODE + childProd.SERIAL_NUMBER;

                            // childrenModelCodes.push(childProd.MODEL_CODE);
                            // childrenModelCodes.push(modelSerialCompositeKey2);
                            // console.log('code added 614 - ', JSON.stringify(childrenModelCodes));


                            this.selectedModelNumbers.push(modelSerialCompositeKey2);
                            this.selectedSerialNumbers.push(childProd.SERIAL_NUMBER);


                        });
                    }

                });
            }
        });
    }


    // Adjust the rowSelectionHandler function
    rowSelectionHandler(event) {

        var deselectedIds = [];
        const eventType = event.detail.config.action;

        console.log('eventType- ', eventType);

        try {

            if (eventType === 'rowDeselect') {
                const deSelectedRows = this.template.querySelector('lightning-tree-grid').getSelectedRows();
                console.log('DeSelected Rows 369:', deSelectedRows);

                deSelectedRows.forEach(deSelectedRow => {

                    deselectedIds.push(deSelectedRow.id);

                });
                console.log('deselectedIds:', JSON.stringify(deselectedIds));

                this.selectedRows.forEach(temp => {

                    if (!deselectedIds.includes(temp)) {

                        console.log('deselected Id -- ', temp);

                        const deselectedId = temp;

                        // Remove the array containing deselectedId from originalSelectedRows
                        this.originalSelectedRows = this.originalSelectedRows.filter(row => !row.includes(deselectedId));

                        console.log('Updated originalSelectedRows:', this.originalSelectedRows.flat());

                        // Remove the serial number corresponding to the deselected ID
                        this.selectedSerialNumbers = this.selectedSerialNumbers.filter(serial => {
                            // Logic to match the serial with the deselected ID
                            return !this.isSerialLinkedToRow(temp, serial); // Add this helper function
                        });

                        console.log('selectedSerialNumbers:', this.selectedSerialNumbers.flat());

                    }

                });

                this.tempList = this.originalSelectedRows;

                this.selectedRows = this.originalSelectedRows.flat();

                this.selectedModelNumbers = this.selectedRows;

            }

            else if (eventType === 'selectAllRows') {
                const allRows = this.template.querySelector('lightning-tree-grid').getSelectedRows();
                console.log('allRows:', allRows);
                this.selectAllRows();

            }
            else if (eventType === 'deSelectAllRows') {
                this.tempList = [];
                this.selectedRows = [];
                this.selectedModelNumbers = [];
                this.selectedSerialNumbers = [];

                this.originalSelectedRows = [];

            }
            else if (eventType === 'rowSelect') {

                const selectedRows = this.template.querySelector('lightning-tree-grid').getSelectedRows();
                console.log('Selected Rows 406:', selectedRows);

                const selectedRowId = selectedRows.map(row => row.id);
                console.log('Selected Row Id 411:', selectedRowId);

                console.log('Selected Row Id 713:', JSON.stringify(selectedRowId));
                console.log('previous selected rows:', JSON.stringify(this.selectedModelNumbers));


                const newlyAddedIds = selectedRowId.filter(id => !this.selectedModelNumbers.includes(id));

                let currentSelectedId = null;
                if (newlyAddedIds.length > 0) {
                    currentSelectedId = newlyAddedIds[0];
                }

                console.log('currentSelectedId:', currentSelectedId);
                console.log('currentSelectedId:', JSON.stringify(currentSelectedId));

                // const isRowSelectable = selectedRows.map(row => row.isSelectable);
                const isRowSelectable = selectedRows.some(row => row.isSelectable);
                console.log('is selectable - ', isRowSelectable);



                if (isRowSelectable === true) {
                    console.log('is selectable - ', isRowSelectable);

                    console.log('Selected Rows:', selectedRows);

                    const childrenModelCodes = this.fetchChildrenModelCodes(selectedRowId);

                    this.tempList.push(childrenModelCodes);

                    console.log('this.tempList:', this.tempList);

                    this.originalSelectedRows = this.tempList;
                    console.log('originalSelectedRows:', this.originalSelectedRows);
                    console.log('originalSelectedRows:', JSON.stringify(this.originalSelectedRows));

                    this.selectedRows = this.originalSelectedRows.flat();
                    console.log('final selectedRows:', this.selectedRows);
                }

                else {

                    // Remove the non-selectable row's ID from the selectedRows array
                    this.selectedRows = selectedRowId.filter(id => id !== currentSelectedId);

                    console.log('Updated selectedRows:', this.selectedRows);

                    this.showToast(null, 'warning', 'Selected serial number is already registered');
                }
            }

            this.selectedModelNumbers = this.selectedModelNumbers.flat();

            // Remove duplicates using Set
            this.selectedModelNumbers = [...new Set(this.selectedModelNumbers)];


            console.log('this.selectedModelNumbers final - ', JSON.stringify(this.selectedModelNumbers));

        } catch (error) {
            console.error('Error in rowSelectionHandler:', error.message);
            console.error('Error in rowSelectionHandler:', error.lineNumber);

        }
    }

    isSerialLinkedToRow(rowId, serialNumber) {
        let isLinked = false;

        // Loop through your `assetDetailLst` to find a matching rowId and check its serials
        this.assetDetailLst.forEach(asset => {
            if (asset.PRODUCT) {
                asset.PRODUCT.forEach(prod => {
                    if ((prod.MODEL_CODE + prod.SERIAL_NUMBER === rowId) && prod.SERIAL_NUMBER === serialNumber) {
                        isLinked = true;
                    }
                    if (prod.CHILD_PRODUCTS) {
                        prod.CHILD_PRODUCTS.forEach(childProd => {
                            if ((childProd.MODEL_CODE + childProd.SERIAL_NUMBER === rowId) && childProd.SERIAL_NUMBER === serialNumber) {
                                isLinked = true;
                            }
                        });
                    }
                });
            }
        });

        return isLinked;
    }

    async handleRegister(event) {

        // Check if there are selected serial numbers
        if (!this.selectedModelNumbers || this.selectedModelNumbers.length === 0) {
            this.showToast('Warning', 'warning', 'No serial numbers selected for registration.');
            return;
        }

        const promptResult = await LightningConfirm.open({
            message: `You have selected the following serial numbers for registration:\n\n${this.selectedSerialNumbers.join(', ')}\n\n,Do you want to proceed?`,
            variant: 'headerless',
            label: 'Are you sure you want to submit!?',
            // setting theme would have no effect
        });

        // Display confirmation dialog
        // const confirmation = confirm(
        //     `You have selected the following serial numbers for registration:\n\n${this.selectedModelNumbers.join(', ')}\n\nDo you want to proceed?`
        // );

        // If user cancels, do nothing
        if (!promptResult) {
            return;
        }

        const result = await this.assetRegisterHandler();

        console.log('result 550 - ', result.response);

        if (result.response === 'Success') {
            this.showSpinner = false;

            this.showToast('Success', 'success', 'Product registered successfully - ' + result.message);

            this.selectedModelNumbers = [];

            // Fire custom event to notify parent component
            const successEvent = new CustomEvent('success');
            this.dispatchEvent(successEvent);

        }
        else {
            this.showToast('Error', 'error', result.message);
            this.showSpinner = false;
        }


    }

    assetRegisterHandler() {

        var assetDetails = JSON.stringify(this.assetDetailLst);
        var addressString = JSON.stringify(this.address);

        if (this.selectedModelNumbers.length === 0) {
            // If the list is empty, show an error message or handle it as needed
            console.error('No products selected!');
            this.showToast('Error', 'error', 'No products selected');
            return 'failure';
        }

        // Validate installation date
        if (!this.installationDate || this.installationDate === null) {
            this.showSpinner = false;
            this.showToast("Error", "error", "Please fill the Installation Date");
            return 'failure';
        }
        //installation date should be greater than invoice date
        if (this.installationDate < this.invoiceDate) {
            this.showSpinner = false;
            this.showToast("Error", "error", "Installation Date should be greater than or equal to Invoice Date");
            return 'failure';
        }
        // Validate address variables
        if (this.address.postalCode === null || this.address.stateCode === null || this.address.postalCode === '' || this.address.stateCode === '') {
            this.showSpinner = false;
            this.showToast("Error", "error", "Please select an address");
            return 'failure';
        }


        // If the list has values, proceed with the submission logic
        console.log('Submitting with selected serial numbers:', this.selectedModelNumbers);

        this.showSpinner = true;

        console.log('uploadedFiles:', this.uploadedFiles);


        let documentIds = this.uploadedFiles.map(file => file.id);
        console.log('documentIds:', documentIds);

        return registerAsset({
            modelCodes: this.selectedModelNumbers,
            assetDetails: assetDetails,
            address: addressString,
            accountId: this.accountId,
            workOrderId: null,
            installationDate: this.installationDate,
            productType: this.productType,
            isAddressChanged: this.isAddressChanged,
            selectedAddressId: this.selectedAddressId,
            solId: this.solId,
            logicalId: null,
            cpAccountId: this.selectedCP,
            uploadedFiles: documentIds

        })
            .then(result => {
                console.log('result 592 - ', result);
                return result;
            })
            .catch(error => {
                // Handle error
                console.error('Error in calling Apex method:', error);
                this.addProduct = false;
                this.showSpinner = false;
                this.showToast('Error', 'error', 'Product registration failed');

                return error;

            });
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


}