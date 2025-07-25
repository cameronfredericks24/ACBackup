import { LightningElement, api, track } from 'lwc';
import getAccountList from '@salesforce/apex/AuditInventoryController.getAccountList';
import createAuditInventory from '@salesforce/apex/AuditInventoryController.createAuditInventory';

export default class AuditInventoryComponent extends LightningElement {
    //@api locationId;
    @track loader = false;
    @track error = null;
    @track pageSize = 10;
    @track pageNumber = 1;
    @track totalRecords = 0;
    @track totalPages = 0;
    @track recordEnd = 0;
    @track recordStart = 0;
    @track isPrev = true;
    @track isNext = true;
    @track accounts = []; // Holds the account list from Apex
    @track selectedAccounts = []; // Tracks selected rows
    selectedItems = new Map(); // Map for tracking selected rows
    enteredQuantities = new Map(); // Map for tracking entered quantities
    @track searchKey = '';
    @track showOrderSummary = false;
    @track isIGSTChecked = false;
    @track auditNeeded = false;

    connectedCallback() {
        this.getAccounts();
    }

    handleNext() {
        if (this.pageNumber < this.totalPages) {
            this.pageNumber += 1;
            this.getAccounts();
        }
    }

    handlePrev() {
        if (this.pageNumber > 1) {
            this.pageNumber -= 1;
            this.getAccounts();
        }
    }

    handleSearchChange(event) {
        this.searchKey = event.target.value;
        this.pageNumber = 1; // Reset to first page when searching
        this.getAccounts();
    }

    handleQuantityChange(event) {
        const itemId = event.target.dataset.id;
        const newQuantity = event.target.value.trim();

        if (newQuantity && !isNaN(newQuantity) && Number(newQuantity) > 0) {
            this.enteredQuantities.set(itemId, Number(newQuantity));
            this.selectedItems.set(itemId, true); // Auto-select row
        } else {
            this.enteredQuantities.delete(itemId);
            this.selectedItems.delete(itemId); // Deselect if quantity is invalid
        }

        this.updateAccountList();
    }

    handleRowSelection(event) {
        const itemId = event.target.dataset.id;
        const isSelected = event.target.checked;

        if (isSelected) {
            this.selectedItems.set(itemId, true);
        } else {
            this.selectedItems.delete(itemId);
            this.enteredQuantities.delete(itemId); // Clear quantity if deselected
        }

        this.updateAccountList();
    }

    getAccounts() {
        this.loader = true;
        getAccountList({
            pageSize: this.pageSize,
            pageNumber: this.pageNumber,
            searchKey: this.searchKey,
        })
            .then((result) => {
                this.loader = false;

                if (result) {
                    const resultData = JSON.parse(result);
                    console.log('resultData.auditNeeded', resultData.auditNeeded);
                    this.auditNeeded = resultData.auditNeeded;
                    if (resultData.auditNeeded) {
                        this.accounts = resultData.accounts.map((account) => ({
                            ...account,
                            isSelected: this.selectedItems.has(account.itemId),
                            newQuantity: this.enteredQuantities.get(account.itemId) || '', // Restore quantity
                        }));

                        this.pageNumber = resultData.pageNumber;
                        this.totalRecords = resultData.totalRecords;
                        this.recordStart = resultData.recordStart;
                        this.recordEnd = resultData.recordEnd;
                        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
                        this.isNext = this.pageNumber >= this.totalPages;
                        this.isPrev = this.pageNumber <= 1;
                    }else{

                    }
                }
            })
            .catch((error) => {
                this.loader = false;
                this.error = error;
            });
    }

    updateAccountList() {
        this.accounts = this.accounts.map((account) => {
            const itemId = account.itemId;
            return {
                ...account,
                newQuantity: this.enteredQuantities.get(itemId) || '',
                isSelected: this.selectedItems.has(itemId),
            };
        });
    }

    handleSubmit() {
        this.updateSelectedAccounts(); // Ensure selectedAccounts is updated

        if (!this.selectedAccounts.length) {
            alert('Please select at least one product and enter a quantity!');
            return;
        }

        this.loader = true;
        console.log('Submitting selectedAccounts:', JSON.stringify(this.selectedAccounts));

        createAuditInventory({
           
            selectedAccountsJson: JSON.stringify(this.selectedAccounts)
        })
            .then((result) => {
                this.loader = false;
                alert('Audit Inventory created successfully! ' + result);

                // Redirect to details page
                window.location = '/channelpartnerportal/s/detail/' + result;

                // Clear selections after submission
                this.selectedItems.clear();
                this.enteredQuantities.clear();
                this.accounts = this.accounts.map(account => ({
                    ...account,
                    isSelected: false,
                    newQuantity: ''
                }));
            })
            .catch((error) => {
                this.loader = false;
                console.error('Error creating Audit Inventory:', error);
                alert('Error creating Audit Inventory: ' + (error.body ? error.body.message : error.message));
            });
    }

    updateSelectedAccounts() {
    this.selectedAccounts = this.accounts
        .filter((account) => this.selectedItems.has(account.itemId))
        .map((account) => ({
            itemId: account.itemId,
            newQuantity: this.enteredQuantities.get(account.itemId) || 1, // Entered quantity
            existingQuantity: account.itemQuantity || 0 // Existing quantity from system
        }));

    console.log('Updated selectedAccounts:', JSON.stringify(this.selectedAccounts));
}

    get isDisplayNoRecords() {
        return this.accounts.length === 0;
    }
}