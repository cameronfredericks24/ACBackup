import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLocation from '@salesforce/apex/CreateSaleOrderController.getLocation';
import getProductItem from '@salesforce/apex/CreateSaleOrderController.getProductItem';
import getTotalProductItemCount from '@salesforce/apex/CreateSaleOrderController.getTotalProductItemCount';
import insertSalesOrderAndItems from '@salesforce/apex/CreateSaleOrderController.insertSalesOrderAndItems';
import getAccounts from '@salesforce/apex/CreateSaleOrderController.getAccounts';
import getContactsForAccount from '@salesforce/apex/CreateSaleOrderController.getContactsForAccount';
import getWorkOrdersForAccount from '@salesforce/apex/CreateSaleOrderController.getWorkOrdersForAccount';
import getDealerPrice from '@salesforce/apex/CreateSaleOrderController.getDealerPrice';
import getTaxDetails from '@salesforce/apex/CreateSaleOrderController.getTaxDetails';  // Import the method to fetch tax details

export default class createSaleOrder extends LightningElement {
    @track totalPriceOfAllProducts = 0;
    @track location = [];
    @track pagedProducts = [];
    @track totalProductCount = 0;
    @track selectedItems = new Map(); // Track selected product items
    @track selectedProductSummary = []; // Store selected products for summary
    @track enteredQuantities = new Map();  // Map to store quantity, discount, and checkbox state
    @track showOrderSummary = false;
    @track currentPage = 1;
    @track totalPages = 1;
    productsPerPage = 10;
    loader = false;
    productSearchKey = ''; // Search key for product search

    // For Account, Contact, and Service Ticket
    @track accountSearchKey = '';
    @track accountOptions = [];
    @track filteredAccounts = [];
    @track showAccountList = false;
    @track selectedAccountId = null;
    @track selectedAccountName = '';
    @track contactOptions = [];
    @track workOrderOptions = [];
    @track selectedContactId = null;
    @track selectedContactName = '';
    @track selectedWorkOrderId = null;
    @track selectedWorkOrderName = '';

    // Columns for the datatable in the Order Summary
    columns = [
        { label: 'Product Name', fieldName: 'ProductName', type: 'text' },
        { label: 'Quantity Needed', fieldName: 'Quantity', type: 'number' },
        { label: 'Unit Price', fieldName: 'UnitPrice', type: 'currency' },
        { label: 'Discount (%)', fieldName: 'Discount', type: 'number' },
        { label: 'Tax (%)', fieldName: 'TotalTaxPercentage', type: 'number' },
        { label: 'Tax (CGST+SGST+IGST)', fieldName: 'Tax', type: 'currency' },
        { label: 'Total Price (incl. Tax)', fieldName: 'TotalPrice', type: 'currency' }
    ];
    
    

    connectedCallback() {
        this.fetchLocations(); // Automatically fetch location and products on load
    }

    fetchLocations() {
        this.loader = true;
        getLocation()
            .then(result => {
                this.loader = false;
                this.location = result;
                if (this.location.length > 0) {
                    this.fetchTotalProductCount();
                    this.fetchProducts(); // Fetch initial set of products
                } else {
                    this.showToast('No locations found for the user.', 'error');
                }
            })
            .catch(error => {
                this.loader = false;
                this.showToast('Error fetching locations.', 'error');
                console.error('Error fetching locations:', error);
            });
    }

    fetchTotalProductCount() {
        getTotalProductItemCount({ locationId: this.location[0].Id })
            .then(result => {
                this.totalProductCount = result;
                this.totalPages = Math.ceil(this.totalProductCount / this.productsPerPage);
            })
            .catch(error => {
                this.showToast('Error fetching total product count.', 'error');
                console.error('Error fetching total product count:', error);
            });
    }

    fetchProducts() {
        this.loader = true;
        getProductItem({
            locationId: this.location[0].Id,
            pageSize: this.productsPerPage,
            pageNumber: this.currentPage,
            searchKey: this.productSearchKey // Send search key to the server
        })
        .then(result => {
            let productPromises = result.map(prod => {
                return getDealerPrice({ productId: prod.Product2.Id })
                    .then(dealerPrice => {
                        prod.unitPrice = dealerPrice; // Assign the fetched dealer price
                        prod.disabled = prod.QuantityOnHand === 0; // Disable if quantity is 0
                        prod.discountDisabled = prod.QuantityOnHand === 0; // Disable discount if quantity is 0
                        return prod;
                    });
            });

            // Wait for all price fetches to complete
            Promise.all(productPromises).then(productsWithPrices => {
                this.loader = false;
                this.pagedProducts = productsWithPrices;
                this.restoreSelections(); // Restore checkbox, quantity, and discount
            });
        })
        .catch(error => {
            this.loader = false;
            this.showToast('Error fetching products.', 'error');
            console.error('Error fetching products:', error);
        });
    }

    restoreSelections() {
        this.pagedProducts = this.pagedProducts.map(prod => {
            if (this.enteredQuantities.has(prod.Id)) {
                // Retrieve quantity, discount, and selection state from the map
                const { quantity, discount, isSelected } = this.enteredQuantities.get(prod.Id);
                prod.quantity = quantity;
                prod.discount = discount;
                prod.isSelected = isSelected;
            }
            prod.disabled = prod.QuantityOnHand === 0; // Disable if quantity is 0
            prod.discountDisabled = prod.QuantityOnHand === 0; // Disable discount if quantity is 0
            return prod;
        });
    }
    

    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage += 1; // Increment the page number
            this.fetchProducts(); // Fetch products for the new page
        }
    }

    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage -= 1; // Decrement the page number
            this.fetchProducts(); // Fetch products for the new page
        }
    }

    handleProductSearch(event) {
        this.productSearchKey = event.target.value.toLowerCase(); // Capture search key
        this.currentPage = 1; // Reset to the first page when searching
        this.fetchProducts(); // Fetch products based on search key
    }

    handleRowSelection(event) {
        const itemId = event.target.dataset.id;
        const isSelected = event.target.checked;
    
        this.pagedProducts = this.pagedProducts.map(prod => {
            if (prod.Id === itemId) {
                const quantity = this.enteredQuantities.has(itemId) ? this.enteredQuantities.get(itemId).quantity : 1;
                const discount = this.enteredQuantities.has(itemId) ? this.enteredQuantities.get(itemId).discount : 0;
    
                // Store the current state in the enteredQuantities map
                this.enteredQuantities.set(itemId, { quantity, discount, isSelected });
    
                // Track selected items
                if (isSelected) {
                    this.selectedItems.set(itemId, { ...prod, quantity, discount }); // Store the full product object with quantity and discount
                } else {
                    this.selectedItems.delete(itemId); // Remove from selected if unchecked
                }
    
                prod.isSelected = isSelected;
            }
            return prod;
        });
    }
    
    handleQuantityChange(event) {
        const itemId = event.target.dataset.id;
        const enteredQuantity = parseInt(event.target.value, 10); // Quantity entered by the user
        const product = this.pagedProducts.find(prod => prod.Id === itemId); // Get the product details
        const availableQuantity = product.QuantityOnHand; // Available quantity in hand
    
        // If entered quantity is greater than available, set to available and show a toast
        if (enteredQuantity > availableQuantity) {
            this.showToast(`Entered quantity exceeds available quantity. Setting it to ${availableQuantity}`, 'warning');
            event.target.value = availableQuantity; // Set the input value to the available quantity
            this.enteredQuantities.set(itemId, { ...this.enteredQuantities.get(itemId), quantity: availableQuantity });
        } else {
            this.enteredQuantities.set(itemId, { ...this.enteredQuantities.get(itemId), quantity: enteredQuantity });
        }
    
        // Update the quantity in the selected items map
        if (this.selectedItems.has(itemId)) {
            let selectedItem = this.selectedItems.get(itemId);
            selectedItem.quantity = enteredQuantity > availableQuantity ? availableQuantity : enteredQuantity;
            this.selectedItems.set(itemId, selectedItem); // Update the map
        }
    }
    

    handleDiscountChange(event) {
        const itemId = event.target.dataset.id;
        let discount = parseFloat(event.target.value); // Get the updated discount
    
        // Ensure the discount is between 0 and 100
        if (discount > 100) {
            this.showToast('Discount cannot be more than 100%. Setting it to 100%.', 'warning');
            discount = 100;
            event.target.value = 100; // Update the input field with the adjusted value
        } else if (discount < 0) {
            this.showToast('Discount cannot be less than 0%. Setting it to 0%.', 'warning');
            discount = 0;
            event.target.value = 0; // Update the input field with the adjusted value
        }
    
        const existingData = this.enteredQuantities.has(itemId) ? this.enteredQuantities.get(itemId) : { quantity: 1, isSelected: false };
        this.enteredQuantities.set(itemId, { ...existingData, discount }); // Update the discount
    
        // Update the discount in the selected items map
        if (this.selectedItems.has(itemId)) {
            let selectedItem = this.selectedItems.get(itemId);
            selectedItem.discount = discount;
            this.selectedItems.set(itemId, selectedItem); // Update the map
        }
    }
    
    handleSubmit() {
        // Check if an account, contact, or at least one product is selected
        if (!this.selectedAccountId) {
            this.showToast('Please select an account before proceeding.', 'warning');
            return;
        }
    
        if (!this.selectedContactId) {
            this.showToast('Please select a contact before proceeding.', 'warning');
            return;
        }
    
        if (this.selectedItems.size === 0) {
            this.showToast('Please select at least one product before proceeding.', 'warning');
            return;
        }
    
        // If all validations pass, prepare the summary of selected products
        this.prepareProductSummary();
        this.showOrderSummary = true;
    }
    

    async prepareProductSummary() {
        this.selectedProductSummary = []; // Clear previous data
        this.totalPriceOfAllProducts = 0; // Reset total price
    
        // Prepare product summary data
        const productPromises = Array.from(this.selectedItems.values()).map(async (product) => {
            try {
                // Fetch the tax details based on HSN Code
                const taxDetails = await getTaxDetails({ hsnCode: product.Product2.HSN_No__c });
    
                // Ensure the tax values are properly retrieved and set to 0 if missing
                const cgst = taxDetails?.CGST || 0;
                const sgst = taxDetails?.SGST || 0;
                const igst = taxDetails?.IGST || 0;
    
                // Calculate the total tax percentage
                const totalTaxPercentage = parseFloat(cgst) + parseFloat(sgst) + parseFloat(igst);
    
                // Ensure that unitPrice, discount, and quantity are valid numbers
                const unitPrice = parseFloat(product.unitPrice) || 0;
                const discount = parseFloat(product.discount) || 0;
                const quantity = parseFloat(product.quantity) || 0;
    
                // Calculate the price after discount
                const discountedPrice = unitPrice - (unitPrice * (discount / 100));
                const totalProductPrice = discountedPrice * quantity;
    
                // Calculate the total tax based on total tax percentage
                const totalTax = totalProductPrice * (totalTaxPercentage / 100);
    
                // Total price including tax
                const totalPriceWithTax = totalProductPrice + totalTax;
    
                // Accumulate the total price
                this.totalPriceOfAllProducts += parseFloat(totalPriceWithTax.toFixed(2));
    
                // Push the product summary
                return {
                    Id: product.Id,
                    ProductName: product.Product2.Name,
                    HSNCode: product.Product2.HSN_No__c,
                    Quantity: quantity, // Use parsed quantity
                    UnitPrice: unitPrice, // Use parsed unit price
                    Discount: discount, // Use parsed discount
                    TotalTaxPercentage: totalTaxPercentage.toFixed(2), // Total tax percentage
                    Tax: totalTax.toFixed(2), // Total tax from CGST, SGST, and IGST
                    TotalPrice: totalPriceWithTax.toFixed(2) // Total price including tax
                };
            } catch (error) {
                console.error('Error fetching tax details: ', error);
                this.showToast('Error fetching tax details.', 'error');
            }
        });
    
        // Await all promises together and update the selectedProductSummary
        const productSummaries = await Promise.all(productPromises);
        this.selectedProductSummary = productSummaries.filter(product => product !== undefined);
    }
    
    
    
    
    
    

    handleFinalSubmit() {
        // Prepare the order data to be sent to the server
        let salesOrderItemsMap = {};
        this.selectedItems.forEach((product, id) => {
            const { quantity, discount } = this.enteredQuantities.get(id); // Get quantity and discount from the map
            salesOrderItemsMap[id] = {
                quantity: quantity, // Use the correct quantity
                unitPrice: product.unitPrice,
                discount: discount // Use the correct discount
            };
        });

        // Convert the sales order items map to JSON format
        const salesOrderItemsJson = JSON.stringify(salesOrderItemsMap);

        // Call the Apex method to insert the sale order and items
        insertSalesOrderAndItems({
            salesOrderItemsMap: salesOrderItemsJson,
            accountId: this.selectedAccountId,
            contactId: this.selectedContactId,
            workOrderId: this.selectedWorkOrderId
        })
        .then(result => {
            // Handle success
            this.showToast('Sales order created successfully!', 'success');
            window.location.href = 'https://bluestarlimited--staging.sandbox.my.site.com/channelpartnerportal/s/sale-order/' + result;
            console.log('Sales Order ID:', result);
        })
        .catch(error => {
            // Handle error
            this.showToast('Error creating sales order: ' + error.body.message, 'error');
            console.error('Error creating sales order:', error);
        });
    }

    // Handle Back button click
    handleBack() {
        this.showOrderSummary = false;  // Navigate back to the product selection page
        this.restoreSelections();       // Restore the previously selected items and their quantities/discounts
    }
    

    showToast(message, variant) {
        const evt = new ShowToastEvent({
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    handleAccountSearch(event) {
        this.accountSearchKey = event.target.value.toLowerCase();
        if (this.accountSearchKey.length > 0) {
            getAccounts({ searchKey: this.accountSearchKey })
                .then(result => {
                    this.filteredAccounts = result.map(account => ({
                        label: account.Name,
                        value: account.Id
                    }));
                    this.showAccountList = true;
                })
                .catch(error => {
                    this.showToast('Error fetching accounts.', 'error');
                });
        } else {
            this.filteredAccounts = [];
            this.showAccountList = false;
        }
    }

    selectAccount(event) {
        const accountId = event.currentTarget.dataset.id;
        const accountName = event.currentTarget.innerText; // Get the selected Account Name
        this.selectedAccountId = accountId;
        this.selectedAccountName = accountName; // Store the Account Name
        this.accountSearchKey = accountName;
        this.showAccountList = false;
        this.fetchContacts();
        this.fetchWorkOrders();
    }

    fetchContacts() {
        if (this.selectedAccountId) {
            getContactsForAccount({ accountId: this.selectedAccountId })
                .then(result => {
                    this.contactOptions = result.map(contact => ({
                        label: contact.Name,
                        value: contact.Id
                    }));
                })
                .catch(error => {
                    this.showToast('Error fetching contacts.', 'error');
                });
        }
    }

    fetchWorkOrders() {
        if (this.selectedAccountId) {
            getWorkOrdersForAccount({ accountId: this.selectedAccountId })
                .then(result => {
                    this.workOrderOptions = result.map(workOrder => ({
                        label: workOrder.Ticket_Number_Read_Only__c,
                        value: workOrder.Id
                    }));
                })
                .catch(error => {
                    this.showToast('Error fetching work orders.', 'error');
                });
        }
    }

    handleContactChange(event) {
        this.selectedContactId = event.detail.value;
        const selectedContact = this.contactOptions.find(contact => contact.value === this.selectedContactId);
        this.selectedContactName = selectedContact ? selectedContact.label : ''; // Store the Contact Name
    }

    handleWorkOrderChange(event) {
        this.selectedWorkOrderId = event.detail.value;
        const selectedWorkOrder = this.workOrderOptions.find(workOrder => workOrder.value === this.selectedWorkOrderId);
        this.selectedWorkOrderName = selectedWorkOrder ? selectedWorkOrder.label : ''; // Store the Service Ticket Name
    }

    get isPreviousDisabled() {
        return this.currentPage === 1;
    }

    get isNextDisabled() {
        return this.currentPage === this.totalPages;
    }
}