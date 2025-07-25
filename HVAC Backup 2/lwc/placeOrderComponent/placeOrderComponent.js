import { LightningElement, api, track } from 'lwc';
import getAccountList from '@salesforce/apex/PlaceOrderComponentController.getAccountList';

export default class PlaceSalesOrderComponent extends LightningElement {
    @api locationId;
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
    @track searchKey = '';
    @track showOrderSummary = false;
    @track selectedAccounts = [];

    @track selectedItems = new Map(); // Map to store selected items
    @track enteredQuantities = new Map(); // Map to store entered quantities and updated prices
    @track isIGSTChecked = false; 
    connectedCallback() {
        this.getAccounts();
    }

    handleNext() {
        this.pageNumber = this.pageNumber + 1;
        this.getAccounts();
    }

    handlePrev() {
        this.pageNumber = this.pageNumber - 1;
        this.getAccounts();
    }

    handBack() {
        this.showOrderSummary = false;
    }

    handleSearchChange(event) {
        this.searchKey = event.target.value;
        this.pageNumber = 1; // Reset to the first page on a new search
        this.getAccounts();
    }

    handleQuantityChange(event) {
        const itemId = event.target.dataset.id;
        const originalPrice = parseFloat(event.target.dataset.price);
        const newQuantity = parseInt(event.target.value, 10);
    
        if (isNaN(newQuantity) || newQuantity <= 0) {
            console.log(`Quantity is zero, invalid, or NaN, resetting to original price and deselecting item ${itemId}`);
            
            // If the quantity is invalid, reset to original price and deselect
            this.selectedItems.delete(itemId);
            this.enteredQuantities.delete(itemId); // Remove entry from map
    
            this.accounts = this.accounts.map(account => {
                if (account.itemId === itemId) {
                    return {
                        ...account,
                        quantity: '', // Set quantity to empty
                        itemPrice: account.originalPrice, // Reset price to original
                        isSelected: false // Deselect the row
                    };
                }
                return account;
            });
        } else {
            // Get the original price from the account
        const account = this.accounts.find(acc => acc.itemId === itemId);
        const updatedPrice = newQuantity * account.originalPrice;

        // Store the updated quantity and calculated price in the map
        this.enteredQuantities.set(itemId, { 
            quantity: newQuantity, 
            updatedPrice: updatedPrice.toFixed(2) // Use the updated price calculated with account's original price
        });

    
          
    
            // Update the account in the current list
            this.accounts = this.accounts.map(account => {
                if (account.itemId === itemId) {
                    return {
                        ...account,
                        quantity: newQuantity,
                        itemPrice: (newQuantity * account.originalPrice).toFixed(2),
                        // Assign updated price based on new quantity
                        isSelected: true // Auto-select the row if quantity is greater than 0
                    };
                    //this.enteredQuantities.set(itemId, { quantity: newQuantity, newQuantity * account.originalPrice });
                }
                return account;
            });
    
            // Store the selection state
            this.selectedItems.set(itemId, true);
            console.log(`Item ${itemId} selected with quantity ${newQuantity}`);
        }
    
        // Update the selectedAccounts array based on selectedItems map
        this.updateSelectedAccounts();
    
        console.log('Updated accounts:', this.accounts);
        console.log('Selected items:', Array.from(this.selectedItems.keys()));
        console.log('Entered quantities:', Array.from(this.enteredQuantities.entries()));
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

    handleRowSelection(event) {
        const itemId = event.target.dataset.id;
        const isSelected = event.target.checked;

        // Update the selection state in the accounts list
        this.accounts = this.accounts.map(account => {
            if (account.itemId === itemId) {
                if (isSelected) {
                    if (account.quantity === '' || account.quantity === 0) {
                        account.quantity = 1; // Set default quantity
                        account.itemPrice = account.originalPrice; // Reset to original price
                        this.enteredQuantities.set(itemId, { quantity: 1, updatedPrice: account.itemPrice });
                    }
                    this.selectedItems.set(itemId, true);
                } else {
                    account.quantity = '';
                    account.itemPrice = account.originalPrice; 
                    this.selectedItems.delete(itemId);
                    this.enteredQuantities.delete(itemId);
                }
                account.isSelected = isSelected;
            }
            return account;
        });

        // Update the selectedAccounts array based on selectedItems map
        this.updateSelectedAccounts();
    }

    getAccounts() {
        this.loader = true;
        getAccountList({ pageSize: this.pageSize, pageNumber: this.pageNumber, searchKey: this.searchKey })
            .then(result => {
                this.loader = false;
                if (result) {
                    const resultData = JSON.parse(result);
                    console.log('resultData '+ JSON.stringify(resultData));
                    this.accounts = resultData.accounts.map(account => {
                        const storedData = this.enteredQuantities.get(account.itemId);
                        return {
                            ...account,
                            isSelected: this.selectedItems.has(account.itemId), // Reapply selection state
                            quantity: storedData ? storedData.quantity : '', // Reapply quantity
                            itemPrice: storedData ? storedData.updatedPrice : account.originalPrice, // Reapply updated price or use original price
                            originalPrice: account.originalPrice // Ensure original price remains consistent
                            
                        };
                    });
                    this.locationId = resultData.recordId;
                    this.pageNumber = resultData.pageNumber;
                    this.totalRecords = resultData.totalRecords;
                    this.recordStart = resultData.recordStart;
                    this.recordEnd = resultData.recordEnd;
                    this.totalPages = Math.ceil(resultData.totalRecords / this.pageSize);
                    this.isNext = (this.pageNumber === this.totalPages || this.totalPages === 0);
                    this.isPrev = (this.pageNumber === 1 || this.totalRecords < this.pageSize);
                }

                // After loading new page, update the selectedAccounts array
                this.updateSelectedAccounts();
            })
            .catch(error => {
                this.loader = false;
                this.error = error;
            });
    }

    updateSelectedAccounts() {
        // Merge selected accounts across pages
        const newSelectedAccounts = Array.from(this.selectedItems.keys()).map(itemId => {
            return this.accounts.find(account => account.itemId === itemId);
        }).filter(account => account !== undefined);

        // Remove duplicates by ensuring itemId uniqueness
        const uniqueSelectedAccounts = [...this.selectedAccounts, ...newSelectedAccounts]
            .reduce((acc, current) => {
                const x = acc.find(item => item.itemId === current.itemId);
                if (!x) {
                    return acc.concat([current]);
                } else {
                    return acc;
                }
            }, []);

        // Update selectedAccounts by filtering out deselected items
        this.selectedAccounts = uniqueSelectedAccounts.filter(account => this.selectedItems.has(account.itemId));
    }

    handleSubmit() {
        this.updateSelectedAccounts();

        // Prepare the final list of selected accounts with the latest quantities and prices
        const finalSelectedAccounts = this.selectedAccounts.map(account => {
            const enteredData = this.enteredQuantities.get(account.itemId);
            return {
                ...account,
                quantity: enteredData ? enteredData.quantity : account.quantity,
                itemPrice: enteredData ? enteredData.updatedPrice : account.itemPrice
            };
        });
    
        console.log('Final selected accounts:', finalSelectedAccounts);
        this.selectedAccounts = finalSelectedAccounts;

        console.log('Final selected accounts:', JSON.stringify(this.selectedAccounts));
        if (finalSelectedAccounts.length > 0) {
            this.showOrderSummary = true;
        }
    
        // Pass finalSelectedAccounts to the child component
       /* const viewOrderComponent = this.template.querySelector('c-view-order-component');
        if (viewOrderComponent) {
            viewOrderComponent.selectedRows = finalSelectedAccounts;
        }*/
    }

    get isDisplayNoRecords() {
        return this.accounts.length === 0;
    }
}