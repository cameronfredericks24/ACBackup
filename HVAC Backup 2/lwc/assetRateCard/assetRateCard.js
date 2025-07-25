/* eslint-disable @lwc/lwc/no-async-operation */
import { LightningElement, track, api } from 'lwc';
import getProductFamily from '@salesforce/apex/RateCardController.getProductFamily';
import getProductSubFamily from '@salesforce/apex/RateCardController.getProductSubFamily';
import getRateCard from '@salesforce/apex/RateCardController.getRateCard';
import getWorkOrder from '@salesforce/apex/RateCardController.getWorkOrder';
import sendEmail from '@salesforce/apex/RateCardController.sendEmail';
import getSpareParts from '@salesforce/apex/RateCardController.getSpareParts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchProductCodes from '@salesforce/apex/AssetRegistrationController.fetchProductCodes';

const columns = [
    { label: 'Name', fieldName: 'Name', type: 'text' },
    { label: 'Material Group', fieldName: 'Material_Group__c', type: 'text' }
];
const PAGE_SIZE = 10; // Define the number of records per page

export default class AssetRateCard extends LightningElement {

    @track modelNumber;
    @track showAvailableCodesUnitary;
    @track filteredOptionsProductCode = [];
    @track productFamily = {};
    @track modalData = {};
    @track productSubFamily = {};
    @api recordId;
    hasRateMatrix = false;
    rateMatrixes = [];
    @track rateMatrixesWithSelection = [];
    @track selectedRateMatrixes = [];
    showRates = false;
    selectedRecordIds = [];
    selectedProductFamilyId = '';
    selectedProductSubFamilyId = '';
    selectedProductFamilyCode = '';
    selectedProductSubFamilyCode = '';
    selectedProductFamilyName = '';
    selectedProductSubFamilyName = '';
    accountEmail = '';
    ticketNumber = '';
    show = false;
    workOrder;
    assetObligation = '';
    assetUnderWarranty = false;
    @track isEmailSent = false;
    @track error;
    @track searchKey = '';
    @track data = [];
    @track filteredData = [];
    // @track selectedRowsIds = new Set();
    @track selectedRows = []; // Initialize selectedRows array
    @track selectedItems = [];
    assetPresent = false;
    woStarted = false;
    @track selectedItemsMap = new Map(); // Map to persist selections across searches
    @track paginatedData = []; // Data to display on the current page
    @track currentPage = 1; // Current page number
    @track totalPages = 0; // Total number of pages


    // Call fetchProductFamily when the component is connected
    connectedCallback() {
        this.fetchProductFamily();
        this.fetchWorkOrder();
        this.loadProductCodes();

    }
    // Method to call Apex and get product family
    fetchProductFamily() {
        getProductFamily()
            .then(result => {
                this.productFamily = {
                    id: 'ProductFamily',
                    options: result.map(pf => ({
                        label: pf.Name,
                        value: pf.Id,
                        code: pf.Code__c,
                        checked: false
                    }))
                };
            })
            .catch(error => {
                console.error('Error fetching product family: ', error);
            });
    }

    // Method to call Apex and get work order
    fetchWorkOrder() {
        getWorkOrder({ recordId: this.recordId })
            .then(data => {

                console.log('data- '+ JSON.stringify(data));
                this.workOrder = data;
                if (this.workOrder.Status === 'In Progress' || this.workOrder.Status === 'On Hold' ||  this.workOrder.Status === 'Work Started') {
                    this.woStarted = true;
                    if (this.workOrder.AssetId) {
                        this.assetPresent = true;
                        this.selectedProductFamilyCode = this.workOrder.Asset.Product_Family__r.Code__c;
                        this.selectedProductFamilyName = this.workOrder.Asset.Product_Family__r.Name;
                        this.selectedProductSubFamilyCode = this.workOrder.Asset.Product_Sub_Family__r.Code__c;
                        this.selectedProductSubFamilyName = this.workOrder.Asset.Product_Sub_Family__r.Name;
                        this.accountEmail = this.workOrder.Asset.Account.Email__c;
                        this.ticketNumber = this.workOrder.Ticket_Number__c;
                        this.assetObligation = this.workOrder.Asset_Obligation__c;
                        this.assetUnderWarranty = this.assetObligation === 'NIC' ? false : true;
                        this.fetchRateCard();
                    } else {
                        console.warn('No Asset associated with the Work Order');
                    }
                } else {
                    console.warn('Service ticket');
                }
            })
            .catch(error => {
                console.error('Error retrieving Work Order:', error);
            });
    }

    // Method to call Apex and fetch product subfamily
    fetchProductSubFamily() {
        getProductSubFamily({ parentFamilyId: this.selectedProductFamilyId })
            .then(result => {
                this.productSubFamily = {
                    id: 'ProductSubFamily',
                    options: result.map(pf => ({
                        label: pf.Name,
                        value: pf.Id,
                        checked: false,
                        code: pf.Code__c
                    }))
                };
            })
            .catch(error => {
                console.error('Error fetching product subfamily: ', error);
            });
    }

    // Method to call Apex and fetch rate card
    fetchRateCard() {
        getRateCard({ familyCode: this.selectedProductFamilyCode, familySubCode: this.selectedProductSubFamilyCode })
            .then(result => {
                this.rateMatrixesWithSelection = JSON.parse(JSON.stringify(result));
                this.hasRateMatrix = this.rateMatrixesWithSelection.length > 0;
            })
            .catch(error => {
                console.error('Error fetching rate card: ', error);
            });
    }


    // Method to call Apex and send email
    sendRateCard() {
        console.log("mail"+this.accountEmail);
        this.selectedRecordIds = this.rateMatrixesWithSelection
            .filter(record => record.isSelected)
            .map(record => record.Id);
        sendEmail({
            genericRate: JSON.stringify(this.rateMatrixesWithSelection),
            spareRates: JSON.stringify(this.selectedItems),
            emailId: this.accountEmail,
            ticketNumber: this.ticketNumber,
            workOrderId: this.recordId
        })
            .then(result => {
                this.isEmailSent = true;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Email sent successfully',
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                this.error = error;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'An error occurred while sending the email. Please contact your Administrator.',
                        variant: 'error'
                    })
                );
            });
    }

    // Method to call Apex and fetch spare parts
    fetchSpareParts() {
        getSpareParts({ recordId: this.recordId, materialGroup: this.modelNumber })
            .then(result => {
                console.log("model" + this.modelNumber);
                this.filteredData = JSON.parse(JSON.stringify(result));
                console.log("model" + this.filteredData);
                this.updatePaginatedData();
            })
            .catch(error => {
                console.error('Error retrieving data: ', error);
            });
    }

    // Method to handle checkbox change event
    handleGenericCheckboxChange(event) {
        const recordId = event.target.value;
        const isChecked = event.target.checked;
        const seletedRow = this.rateMatrixesWithSelection.find(record => record.Id === recordId);
        seletedRow.isSelected = isChecked;

        this.selectedRateMatrixes = [];
        this.rateMatrixesWithSelection.forEach((rateMatrix) => {
             if(rateMatrix.isSelected){
                this.selectedRateMatrixes.push(rateMatrix);
             }
        });

        if(this.selectedRateMatrixes.length>0){
            this.showRates = true;
        }else{
            this.showRates=false;
        }
    }

    handleSearchKeyChange(event) {
        this.searchKey = event.target.value;
        this.fetchSpareParts();
    }

    handleSpareCheckboxChange(event){
        const recordId = event.target.value;
        const isChecked = event.target.checked;
        const selectedRow = this.paginatedData.find(record => record.Id === recordId);


         if (selectedRow) {
            selectedRow.selected = isChecked;

            if (isChecked) {
                this.selectedItemsMap.set(recordId, selectedRow); // Add to map
            } else {
                this.selectedItemsMap.delete(recordId); // Remove from map
            }

            this.updateSelectedItems(); // Update the selected items array
        }
        // seletedRow.selected = isChecked;
        console.error('this.filteredData: ', this.paginatedData);
        
    }

    handleSelectedItemsCheckboxChange(event){
        const recordId = event.target.value;
        const isChecked = event.target.checked;
        const selectedRow = this.selectedItems.find(record => record.Id === recordId);


         if (selectedRow) {
            selectedRow.selected = isChecked;

            if (!isChecked) {
             
                this.selectedItemsMap.delete(recordId); // Remove from map
            }

            this.updateSelectedItems(); // Update the selected items array
        }
        // seletedRow.selected = isChecked;
        console.error('this.filteredData: ', this.paginatedData);
    }


    // Update the selectedItems array based on the map
    updateSelectedItems() {
        this.selectedItems = Array.from(this.selectedItemsMap.values());
    }


    updatePaginatedData() {
        this.totalPages = Math.ceil(this.filteredData.length / PAGE_SIZE);
        const start = (this.currentPage - 1) * PAGE_SIZE;
        const end = start + PAGE_SIZE;
        this.paginatedData = this.filteredData.slice(start, end);
    }

    get isFirstPage() {
        return this.currentPage === 1;
    }

    get isLastPage() {
        return this.currentPage === this.totalPages;
    }

    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage -= 1;
            this.updatePaginatedData();
        }
    }

    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage += 1;
            this.updatePaginatedData();
        }
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
            this.fetchSpareParts();

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
        this.fetchSpareParts();

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
        this.fetchSpareParts();
    }

    handleModelNumberChangeCustomLookupUnitary(event) {
        console.log("option clicked: ");

        this.modelNumber = event.currentTarget.dataset.value;
        console.log("option clicked: " + this.modelNumber);
        this.fetchSpareParts();
        this.showAvailableCodesUnitary = false;
        
    }

    
}