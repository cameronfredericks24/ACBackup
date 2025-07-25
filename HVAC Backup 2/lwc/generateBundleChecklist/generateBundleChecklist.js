import { LightningElement, wire, track } from 'lwc';
import getCustomerPMSCounts from '@salesforce/apex/BundleChecklist.getCustomerPMSCounts';
import createPMSBundleWorkOrder from '@salesforce/apex/BundleChecklist.createPMSBundleWorkOrder';
import { refreshApex } from '@salesforce/apex';

export default class GenerateBundleChecklist extends LightningElement {
    @track data;
    @track error;
    @track selectedAccountId;
    @track selectedBundleCount;
    @track showNewWorkOrder = false;
    @track ticketNumber;
    @track showDataScreen = false;
    @track isLoadingData = false;
    @track isCreatingWorkOrder = false;
    
    wiredPMSCountsResult;
    touchStartY = 0;
    touchEndY = 0;

    get hasData() {
        return this.data && this.data.length > 0;
    }

    get isButtonDisabled() {
        return !this.hasData || this.isCreatingWorkOrder;
    }

    @wire(getCustomerPMSCounts)
    wiredPMSCounts(result) {
        this.wiredPMSCountsResult = result;
        const { error, data } = result;
        if (data) {
            this.data = data;
            this.error = undefined;
        } else if (error) {
            this.error = error.body.message;
            this.data = undefined;
        }
        this.isLoadingData = false;
    }

    connectedCallback() {
        this.handleFetchData();
        this.addSwipeListener();
    }

    addSwipeListener() {
        this.template.addEventListener('touchstart', (e) => {
            this.touchStartY = e.touches[0].clientY;
        });

        this.template.addEventListener('touchend', (e) => {
            this.touchEndY = e.changedTouches[0].clientY;
            this.handleSwipe();
        });
    }

    handleSwipe() {
        const swipeThreshold = 50; // Minimum swipe distance to trigger refresh
        if (this.touchEndY - this.touchStartY > swipeThreshold) {
            this.refreshComponent(); // Refresh component data instead of full reload
        }
    }

    refreshComponent() {
        this.isLoadingData = true;
        refreshApex(this.wiredPMSCountsResult)
            .finally(() => {
                this.isLoadingData = false;
            });
    }

    handleSelection(event) {
        const selectedValue = event.target.dataset.value;
        this.selectedAccountId = selectedValue.split('::')[0];
        this.selectedBundleCount = parseInt(selectedValue.split('::')[2], 10);
        
        // Update selected radio button
        this.template.querySelectorAll('input[name="account"]').forEach(input => {
            input.checked = input.value === selectedValue;
        });
    }

    handleFetchData() {
        this.isLoadingData = true;
        this.showDataScreen = true;
        refreshApex(this.wiredPMSCountsResult)
            .finally(() => {
                this.isLoadingData = false;
            });
    }

    handleSubmit() {
        if (this.selectedAccountId && this.selectedBundleCount) {
            this.isCreatingWorkOrder = true;
            createPMSBundleWorkOrder({ 
                accountId: this.selectedAccountId,
                bundleCount: this.selectedBundleCount 
            })
                .then((result) => {
                    this.ticketNumber = result.ticketNumber;
                    this.showNewWorkOrder = true;
                    this.isCreatingWorkOrder = false;
                    this.refreshComponent(); 
                })
                .catch((error) => {
                    this.error = error.body.message;
                    this.isCreatingWorkOrder = false;
                });
        } else {
            this.error = 'No account selected';
        }
    }

    handleBack() {
        this.showNewWorkOrder = false;
        this.ticketNumber = null;
        this.refreshComponent();
    }
}