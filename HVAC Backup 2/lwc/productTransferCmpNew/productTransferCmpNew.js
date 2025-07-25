import { LightningElement, track, api } from 'lwc';
import getAccountList from '@salesforce/apex/PaginationController.getAccountList';
import saveMSLProductLines from '@salesforce/apex/PaginationController.saveMSLProductLines';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLastProductRequestDate from '@salesforce/apex/PaginationController.getLastProductRequestDate';

export default class AccountList extends LightningElement {
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
    @track accounts = [];
    @track selectedAccounts = []; // Array to hold selected accounts
    @track searchKey = '';
    @track pls = [];
    @track recId;
    @track isAllSelected = false;
    @track showOrderSummary = false;
    @track isIGSTChecked = false; 

    connectedCallback() {
        this.checkLastProductRequestDate();
    }

    checkLastProductRequestDate() {
        getLastProductRequestDate()
            .then((result) => {
                console.log('createMSlres',result);
                if (result == false) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'MSL cannot be created as the last order was placed less than 15 days ago.',
                            variant: 'error',
                        })
                    );
                    this.loading = false;
                    return;
                } else {
                    console.log('createMSl');
                    this.getAccounts();
                    this.selectedOM = false;
                }
            })
            .catch((error) => {
                console.error('Error fetching last product request date', error);
                this.loading = false;
            });
    }
    handleIGSTChange(event) {
        this.isIGSTChecked = event.target.checked;
        console.log('IGST checkbox changed:', this.isIGSTChecked);
        
        // Based on the checkbox value, call different tax calculation logic
        if (this.isIGSTChecked) {
             
        } else {
              // Call method to apply CGST + SGST
        }
    }

    handleNext() {
        this.pageNumber += 1;
        this.getAccounts();
    }

    handlePrev() {
        this.pageNumber -= 1;
        this.getAccounts();
    }

    handleSearchChange(event) {
        this.searchKey = event.target.value;
        this.pageNumber = 1; // Reset to the first page on a new search
        this.getAccounts();
    }

    handleRowSelection(event) {
        const itemId = event.target.dataset.id;
        const selected = event.target.checked;
    
        // Find the selected account object
        const selectedAccount = this.accounts.find(account => account.itemId === itemId);
    
        if (selected) {
            // Add to selectedAccounts array if not already present
            if (!this.selectedAccounts.some(account => account.itemId === itemId)) {
                this.selectedAccounts = [...this.selectedAccounts, selectedAccount]; // Use spread operator to create a new array
            }
        } else {
            // Remove from selectedAccounts array
            this.selectedAccounts = this.selectedAccounts.filter(account => account.itemId !== itemId); // Create a new array after filtering
        }
    
        console.log('this.selectedAccounts', this.selectedAccounts);
        this.updateSelectionState();
    }

    handleSelectAll(event) {
        const isSelected = event.target.checked;
        this.isAllSelected = isSelected;

        this.accounts.forEach(acc => {
            if (isSelected) {
                // Add to selectedAccounts array if not already present
                if (!this.selectedAccounts.some(account => account.itemId === acc.itemId)) {
                    this.selectedAccounts.push(acc);
                }
            } else {
                // Remove from selectedAccounts array
                this.selectedAccounts = this.selectedAccounts.filter(account => account.itemId !== acc.itemId);
            }
        });

        this.updateSelectionState();
    }

    getAccounts() {
        this.loader = true;
        console.log('createMSl');
    getAccountList({ pageSize: this.pageSize, pageNumber: this.pageNumber, searchKey: this.searchKey })
        .then(result => {
            this.loader = false;
            if (result) {
                console.log('createMSl',result);
                let resultData = JSON.parse(result);
                this.accounts = resultData.accounts;
                this.pageNumber = resultData.pageNumber;
                this.totalRecords = resultData.totalRecords;
                this.recordStart = resultData.recordStart;
                this.recordEnd = resultData.recordEnd;
                this.recId = resultData.recordId;
                this.totalPages = Math.ceil(resultData.totalRecords / this.pageSize);
                this.isNext = (this.pageNumber === this.totalPages || this.totalPages === 0);
                this.isPrev = (this.pageNumber === 1 || this.totalRecords < this.pageSize);

                // Check against selectedAccounts and update the selection state
                this.updateSelectionState();
            }
        })
        .catch(error => {
            this.loader = false;
            this.error = error;
            console.log('this.err',JSON.stringify(error));
            console.log('this.err',this.error);
        });
    }

    updateSelectionState() {
       // Re-apply selection state based on selectedAccounts
    this.accounts = this.accounts.map(account => {
        account.isSelected = this.selectedAccounts.some(selectedAccount => selectedAccount.itemId === account.itemId);
        return account;
    });
    this.isAllSelected = this.accounts.every(acc => acc.isSelected);
    }

    get isDisplayNoRecords() {
        return !this.accounts || this.accounts.length === 0;
    }

    handlePLMSLSubmit(event) {
        event.preventDefault();
        this.loader = true;
        console.log('this.selected2',this.selectedAccounts);
        // Filter accounts based on current selection
        const selectedProductLines = this.selectedAccounts.filter(account => account.itemMSLLimit > 0);

        if (selectedProductLines.length > 0) {
            this.pls = selectedProductLines.map(item => ({
                productLineId: item.itemId,
                productLineQuantity: item.itemMSLLimit,
                productLineName: item.itemName,
                productLineCode: item.itemCode,
                productLinePrice: item.originalPrice,
                productLineOriginalPrice: item.originalPrice,
                itemCGST: item.itemCGST,
                itemSGST: item.itemSGST,
                itemIGST: item.itemIGST,


            }));
            console.log('this.pp',this.pls);

            if (this.pls.length > 0) {
                this.loader = false;
                this.showOrderSummary = true;

                // Here, pass the selected accounts to another component
                // Example: dispatch an event with the selected accounts
                this.dispatchEvent(new CustomEvent('submitselectedaccounts', {
                    detail: { selectedAccounts: this.selectedAccounts }
                }));

            } else {
                this.loader = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Please ensure that selected items have a valid quantity.',
                        variant: 'error',
                    })
                );
            }
        } else {
            this.loader = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select Part Items',
                    variant: 'error',
                })
            );
        }
    }

    handMSLBack(){
        this.showOrderSummary = false;
    }
}