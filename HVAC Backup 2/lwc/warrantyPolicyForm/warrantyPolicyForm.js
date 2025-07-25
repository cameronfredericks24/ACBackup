import { LightningElement , track, wire} from 'lwc';
import insertPolicy from '@salesforce/apex/CreateWarrantyController.insertPolicy';
import getOptions from '@salesforce/apex/CreateWarrantyController.getOptions';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import WarrantyTerm_OBJECT from '@salesforce/schema/WarrantyTerm';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import EffectiveStartDate_FIELD from '@salesforce/schema/WarrantyTerm.EffectiveStartDate';
import WarrantyType_FIELD from '@salesforce/schema/WarrantyTerm.WarrantyType';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class WarrantyPolicyForm extends LightningElement {EffectiveStartDate
   
    show = false;
    SelectAllLabel = "Select All";
    SelectOrUnselectAll = true;
    startDate = '';
    endDate = '';
    policyName = '';
    showChild = false;
    showParent = true;
    jsonString = '';
    @track data;
    @track EffectiveStartDateOptions = [];
    @track WarrantyTypeOptions = [];
    @track modalData = {};
    effectiveStartDate = '';
    policyType = '';
    duration = '';
   
@wire(getOptions)
    wiredOptions({ error, data }) {
        if (data) {
            this.data = JSON.parse(JSON.stringify(data));
            console.log('this.dataKLKL: ', this.data);
        } else if (error) {
            // Handle the error
        }
    }

    @wire(getObjectInfo, { objectApiName: WarrantyTerm_OBJECT })
    objectInfo

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId',fieldApiName: EffectiveStartDate_FIELD})
    wiredEffectiveStartDatePicklistValues({data, error}) {
        if(data) {
            this.EffectiveStartDateOptions = [];
            data.values.forEach(picklistValue => {
                this.EffectiveStartDateOptions.push({
                    label: picklistValue.label,
                    value: picklistValue.value
                });
            });
            console.log("option: ",this.EffectiveStartDateOptions );
         } else if (error) {
             console.log(error);
         }
     }

     @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId',fieldApiName: WarrantyType_FIELD})
     wiredWarrantyTypePicklistValues({data, error}) {
         if(data) {
             this.WarrantyTypeOptions = [];
             data.values.forEach(picklistValue => {
                 this.WarrantyTypeOptions.push({
                     label: picklistValue.label,
                     value: picklistValue.value
                 });
             });
             console.log("option: ",this.WarrantyTypeOptions );
          } else if (error) {
              console.log(error);
          }
      }

    openModal(event){
                console.log('this.modalData: ',this.modalData);
                const modalId = event.target.dataset.modalId;
                this.modalData = this.data.find(entry => entry.id === modalId);
                this.show = true;
                console.log('this.modalData: ',this.modalData);
    }

    handlePicklistChange(event){
        const selectedValue = event.detail.value;
        const fieldName = event.target.name;

        if (fieldName === 'EffectiveStartDate') {
            this.effectiveStartDate = event.target.value;
        } else if (fieldName === 'WarrantyType') {
            this.policyType = event.target.value;
        }
    }

    closeModal(event) {
        const modalId = event.target.dataset.modalId;
        const modal = this.data.find(modal => modal.id === modalId);
        modal =  { ...this.modalData };
        this.show = false;
        this. SelectAllLabel = "Select All";
        this.SelectOrUnselectAll = true;
    }    

    handleChange(event){
        const modalId = event.target.closest('.slds-modal').querySelector('.slds-modal__footer lightning-button').dataset.modalId;
        const selectedValue = event.target.value;
        let options = this.modalData.options.map(option => ({
            ...option,
            checked: option.value == selectedValue ? event.target.checked : option.checked
        }));
        this.modalData.options  = [...options];   
    }

    handleInput(event){
         const value = event.target.value;
         const modalId = event.target.dataset.modalId;
         if (modalId === 'StartDate') {
            this.startDate = value;
         } else if (modalId === 'EndDate') {
            this.endDate = value;
         }else if (modalId === 'Name') {
            this.policyName = value;
        }else if (modalId === 'Duration') {
            this.duration = value;
        }else if (modalId === 'Search') {
            console.log('Name:', value);
        }
    }

    selectAll(event){
        const modalId = event.target.dataset.modalId;
        if(this.SelectOrUnselectAll){
            this.modalData.options = this.modalData.options.map(option => ({
                ...option,
                checked: true
            })); 

            this.SelectAllLabel = "Unselect All"
        }else if(this.SelectOrUnselectAll == false){
            this.modalData.options = this.modalData.options.map(option => ({
                ...option,
                checked: false
            })); 

           this. SelectAllLabel = "Select All"
        }
        this.SelectOrUnselectAll = !this.SelectOrUnselectAll;
          
    }

    handleSubmit(){
       insertPolicy({ data : jsonString,
                     startDate: this.startDate, 
                     endDate: this.endDate, 
                     policyName: this.policyName,
                     effectiveStartDate: this.effectiveStartDate
                     })
            .then(result => {
                console.log('Data processed successfully:', result);
            })
            .catch(error => {
                console.error('Error processing data:', error);
            }); 
    }

    handleNext(){
        if(this.policyName == ''){
            this.showToast('error', 'Please enter Policy Name.');
        }else if(this.duration == ''){
            this.showToast('error', 'Please enter Policy Duration.');
        }else if(this.effectiveStartDate == ''){
            this.showToast('error', 'Please select Policy Effective Start Date.');
        }else if(this.startDate == ''){
            this.showToast('error', 'Please enter Policy Start Date.');
        }else if(this.endDate == ''){
            this.showToast('error', 'Please enter Policy End Date.');
        }else if(this.policyType == ''){
            this.showToast('error', 'Please select Policy Type.');
        }
        else if(this.startDate > this.endDate){
            this.showToast('error', 'Enter valid Start Date and End Date. End Date must be after Start Date');
        }else{
            this.showChild = true;
        this.showParent = false;
        let selectedOptionsObject = {};
        this.data.forEach(entry => {
            const selectedValues = entry.options.filter(option => option.checked).map(option => option.value);
            selectedOptionsObject[entry.id] = selectedValues;
        });
        
        this.jsonString = JSON.stringify(selectedOptionsObject);
        }
    }

    showToast(type, message) {
        const event = new ShowToastEvent({
            title: type === 'error' ? 'Error' : 'Success',
            message: message,
            variant: type,
        });
        this.dispatchEvent(event);
    }

    handlePrevious(){
        this.showChild = false;
        this.showParent = true;
    }
}