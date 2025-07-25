import { LightningElement, track, api } from 'lwc';

export default class CustomLookup extends LightningElement {
    @api productOptionsParent = [];
    @track productOptions = [];
    @track filteredOptions = [];
    @track showOptions = false;
    @track selectedOption;
    @track modelNumber;
    @api recordId;
    @api label;

    connectedCallback(){
        this.productOptions = this.productOptionsParent;
        console.log('this',this.productOptions);

    }


    @api
    setproductOption(){
        this.productOptions = this.productOptionsParent;
        this.filteredOptions = this.productOptions;
        console.log('this',this.productOptions);
    }

    HandleOnClickCustomLookup(event) {
        this.filteredOptions = this.productOptions;
        this.showOptions = this.filteredOptions.length > 0;
    }

    HandleOnChangeCustomLookup(event) {
        const searchTerm = event.target.value.toLowerCase();
        console.log('searcTerm',searchTerm);
        this.filteredOptions = this.productOptions.filter(option => option.label.toLowerCase().includes(searchTerm));
        this.showOptions = this.filteredOptions.length > 0;
    }

    HandleOnFocusCustomLookup() {
        this.showOptions = true;
    }

    HandleOnBlurCustomLookup() {
        // Using setTimeout to wait a bit before hiding options so click on options can be captured
        setTimeout(() => {
            this.showOptions = false;
        }, 300);
    }

    handleOptionClick(event) {
        const selectedOption = event.currentTarget.dataset.value;
        const foundItem = this.productOptions.find(option => option.value === selectedOption);
        this.modelNumber = foundItem.label;
        console.log(' this.modelNumber- ' + this.modelNumber);
        this.showOptions = false;
        const selectEvent = new CustomEvent('submitselection', {
            detail: selectedOption
        });
        console.log('event detail',selectEvent.detail);
        // Fire the custom event
        this.dispatchEvent(selectEvent);
    }
    handleKeyDown(event){
        console.log('inside');
    }
    
}