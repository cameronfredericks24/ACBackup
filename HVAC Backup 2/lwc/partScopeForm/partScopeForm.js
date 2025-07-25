import { LightningElement, track , wire, api} from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import MATERIAL_GROUP_FIELD from '@salesforce/schema/Part_Scope__c.Material_group__c';
import OBLIGATION_FIELD from '@salesforce/schema/Part_Scope__c.Obligation__c';
import SUB_TYPE_FIELD from '@salesforce/schema/Part_Scope__c.Sub_Type__c';
import DEPARTMENT_FIELD from '@salesforce/schema/Part_Scope__c.Department__c';
import SCOPE_FIELD from '@salesforce/schema/Part_Scope__c.Scope__c';
import PART_SCOPE_OBJECT from '@salesforce/schema/Part_Scope__c';
import insertPartScope from '@salesforce/apex/CreateWarrantyController.insertPartScope';
import insertPolicy from '@salesforce/apex/CreateWarrantyController.insertPolicy';
import { NavigationMixin } from 'lightning/navigation';
export default class PartScopeForm extends NavigationMixin(LightningElement) {
    
    @track modals = [];
    @track picklistOptions = [];
    @api startDate;
    @api endDate;
    @api policyName;
    @api effectiveStartDate;
    @api policyType;
    @api duration;
    @api jsonString = '';
    showSelected = true;
    SelectAllLabel = "Select All";
    SelectOrUnselectAll = true;   

  @wire(getObjectInfo, { objectApiName: PART_SCOPE_OBJECT })
  objectInfo
  
           // Wire decorators to fetch picklist values for each field
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId',fieldApiName: MATERIAL_GROUP_FIELD })
    wiredMaterialGroupPicklistValues({data, error}) {
        if(data) {
            this.modals.push({
                id: '1',
                show: false,
                Name: 'Material Group',
                multipleSelect: true,
                options: data.values.map(picklistValue => ({
                    label: picklistValue.label,
                    value: picklistValue.value,
                    checked: false,
                    scope: ''
                }))
            });
            console.log(this.modals);
        } else if (error) {
            console.log(error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId',fieldApiName: OBLIGATION_FIELD })
    wiredObligationPicklistValues({data, error}) {
        if(data) {
            const warrantyObligation = this.policyType == 'Promotional' ? 'PEXWTY' : this.policyType == 'Standard' ? 'WTY' : this.policyType == 'Extended' ? 'EXWTY' : 'NIC';
            this.modals.push({
                id: '2',
                show: false,
                Name: 'Obligation',
                multipleSelect: false,
                options: data.values
                    .filter(picklistValue => picklistValue.label === warrantyObligation)
                    .map(picklistValue => ({
                        label: picklistValue.label,
                        value: picklistValue.value,
                        checked: false, // Since these values are filtered to be mapped, they are checked
                        scope: ''
                    }))
            });
            console.log(this.modals);
        } else if (error) {
            console.log(error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId',fieldApiName: SUB_TYPE_FIELD })
    wiredSubTypePicklistValues({data, error}) {
        if(data) {
            this.modals.push({
                id: '3',
                show: false,
                Name: 'Sub Type',
                multipleSelect: true,
                options: data.values.map(picklistValue => ({
                    label: picklistValue.label,
                    value: picklistValue.value,
                    checked: false,
                    scope: ''
                }))
            });
            console.log(this.modals);
        } else if (error) {
            console.log(error);
        }
    }

    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: DEPARTMENT_FIELD })
    wiredDepartmentPicklistValues({data, error}) {
        if(data) {
            console.log(data);
            this.modals.push({
                id: '4',
                show: false,
                Name: 'Department',
                multipleSelect: true,
                options: data.values.map(picklistValue => ({
                    label: picklistValue.label,
                    value: picklistValue.value,
                    checked: false,
                    scope: ''
                }))
            });
            console.log(this.modals);
        } else if (error) {
            console.log(error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId',fieldApiName: SCOPE_FIELD })
    wiredScopePicklistValues({data, error}) {
        if(data) {
           // Reset picklistOptions array before pushing new values
           this.picklistOptions = [];
           data.values.forEach(picklistValue => {
               this.picklistOptions.push({
                   label: picklistValue.label,
                   value: picklistValue.value
               });
           });
        } else if (error) {
            console.log(error);
        }
    }
          
            
            @track combinations = [];
            @track showCombinationsTable = false;
            @track selectedOptions = [];
            @track canShowCombinations = true;
            @track showError = false;
            @track showSubmit = false;
        
            openModal(event) {
                
                const modalId = event.target.dataset.modalId;
                const modal = this.modals.find(modal => modal.id === modalId);
                modal.show = true;
            }
        
            closeModal(event) {
                const modalId = event.target.dataset.modalId;
                const modal = this.modals.find(modal => modal.id === modalId);
                modal.show = false;
                this. SelectAllLabel = "Select All";
                this.SelectOrUnselectAll = true;
            }
        
            handleChange(event) {
                this.showSelected = true;
                const modalId = event.target.closest('.slds-modal').querySelector('.slds-modal__footer lightning-button').dataset.modalId;
                const modal = this.modals.find(modal => modal.id === modalId);
                const selectedValue = event.target.value;
                if(modalId != 2){
                    modal.options = modal.options.map(option => ({
                        ...option,
                        checked: option.value === selectedValue ? event.target.checked : option.checked
                    }));
                }else{
                    modal.options = modal.options.map(option => ({
                        ...option,
                        checked: option.value === selectedValue ? event.target.checked : false
                    }));
                }
                
                this.checkCombinationsValidity();
            }
        
                   
            selectAll(event) {
                this.showSelected = true;
                const modalId = event.target.dataset.modalId;
                const modal = this.modals.find(modal => modal.id === modalId);
                
                if(this.SelectOrUnselectAll){
                    modal.options = modal.options.map(option => ({
                        ...option,
                        checked: true
                    }));        
                    this.SelectAllLabel = "Unselect All"
                }else if(this.SelectOrUnselectAll == false){
                    modal.options = modal.options.map(option => ({
                        ...option,
                        checked: false
                    }));
        
                   this. SelectAllLabel = "Select All"
                }
                this.SelectOrUnselectAll = !this.SelectOrUnselectAll;
                this.checkCombinationsValidity();
            }
        
        
            checkCombinationsValidity() {
                this.canShowCombinations = this.modals.every(modal => modal.options.some(option => option.checked));
                
                    this.canShowCombinations = !this.canShowCombinations;
             
                this.selectedOptions = this.modals.reduce((acc, modal) => {
                    const selected = modal.options.filter(option => option.checked).map(option => option.label);
                    return acc.concat(selected);
                }, []);
            }
            
            
            
            
        
            showCombinations() {
                let selectedOptions = new Map();
                this.modals.forEach(modal => {
                    selectedOptions.set(modal.Name, modal.options.filter(option => option.checked).map(option => option.label))
                });
               this.generateCombinations(selectedOptions);                
               this.showSubmit = true;
            }
        
            generateCombinations(selectedOptions) {
                let result = [];
                let departmentList = selectedOptions.get('Department');
                let subTypeList = selectedOptions.get('Sub Type');
                let materialGroupList = selectedOptions.get('Material Group');
                let obligationList = selectedOptions.get('Obligation');
                
                for (let i = 0; i < materialGroupList.length; i++) {
                    for (let j = 0; j < obligationList.length; j++) {
                        for (let k = 0; k < subTypeList.length; k++) {
                            for (let l = 0; l < departmentList.length; l++) {
                                result.push({
                                    MaterialGroup: materialGroupList[i],
                                     Obligation : obligationList[j],
                                    Subtype: subTypeList[k],
                                    Department: departmentList[l]
                                });
                            }
                        }
                    }
                }
                this.combinations = result;
                for (let i = 0; i <  this.combinations.length; i++) {
                    this.combinations[i].scope = '';
                }
                this.showCombinationsTable = true;
            }

            // Handle picklist change
handlePicklistChange(event) {
    const value = event.detail.value;
    const index = event.target.dataset.index; 
    this.combinations[index].scope = value;
}

// Handle delete row
handleDeleteRow(event) {
    const index = event.target.dataset.index;
    this.combinations.splice(index, 1);
    this.combinations = [...this.combinations]; // Trigger reactivity
}

    // Handle submit
handleSubmit() {
    if (this.validatePicklist()) {
        this.showError = true; // Show error message
        console.log("error");
    } else {
        this.showError = false; // Hide error message
        console.log("this.jsonString; ", this.jsonString);
        console.log("this.startDate: ", this.startDate);
        console.log("this.endDate: ", this.endDate);
        console.log("this.policyName: ", this.policyName);
        console.log("this.effectiveStartDate: ", this.effectiveStartDate);
        console.log("this.policyType: ", this.policyType);
        console.log("this.duration: ", this.duration);
        insertPolicy({ data : this.jsonString,
            startDate: this.startDate, 
            endDate: this.endDate, 
            policyName: this.policyName,
            effectiveStartDate: this.effectiveStartDate,
            policyType: this.policyType,
            duration: this.duration
            })
   .then(result => {
    var id = result;
       console.log('Data processed successfully:', result);
       insertPartScope({ data: this.combinations,  id: result })
       .then(result => {
           // Handle success
           console.log('Data processed successfully:', result);
           
   this.showToast('success', 'Policy and Part Scope created successfully!');
   this[NavigationMixin.Navigate]({
    type: 'standard__recordPage',
    attributes: {
        recordId: id,
        actionName: 'view'
    }
});

       })
       .catch(error => {
           // Handle error
           console.error('Error processing data:', error);
       });
   })
   .catch(error => {
       console.error('Error processing data:', error);
   }); 
    }
}
        // Check if any combination is missing a picklist value
validatePicklist() {
    var valid = false;
    for (let i = 0; i <  this.combinations.length; i++) {
        if(this.combinations[i].scope == ''){
          valid = true;
          break;
        }
    }
    return valid;
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
        this.dispatchEvent(new CustomEvent("previous"));
    }

    handleScopeForAll(event){
        const selectedScope = event.target.value;
        for (let i = 0; i <  this.combinations.length; i++) {
            this.combinations[i].scope = selectedScope;
        }
    }
        }