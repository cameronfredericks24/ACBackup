import { LightningElement, track, api } from 'lwc';
import getCityAndStateByPinCode from '@salesforce/apex/AddressFormCtrl.getCityAndStateByPinCode';
import getLocality from '@salesforce/apex/AddressFormCtrl.getLocality';
import getSector from '@salesforce/apex/AddressFormCtrl.getSector';
//import saveAddressToLead from '@salesforce/apex/AddressFormCtrl.saveAddressToLead';
//import fetchLeadRecord from '@salesforce/apex/AddressFormCtrl.fetchLeadRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AddressForm extends LightningElement {
    @api recordId;
    @api objectType;

    @api streetAddress = '';
    @api flatNumber = '';
    @api city = '';
    @api state = '';
    @api country = 'India';
    @api pinCode = '';
    isAddressFieldsDisabled = true;
    localityMap = new Map();
    localities = [];
    @api selectedLocality = '';
    @track sublocalities = [];
    @api selectedSublocality = '';
    showLocality = false;
    showSector = false;
    @track sectors = [];
    @api selectedSector = '';
    errorMessage = '';
    showError = false;
    @api label;

    connectedCallback() {
        console.log('this.label', this.label);
        if(this.label==null){
            this.label = 'Shipping address';
        }
        if (this.validatePinCode(this.pinCode)) {
            this.fetchCityAndState();
            this.getLocalityJs();
            this.getSectorJs();
        }
        //this.getLeadRecord();
        
    }

   /* getLeadRecord(){
        fetchLeadRecord({
            leadId : this.recordId
            }).then(result=>{
                if(result!=null){
                    this.pinCode = result.PostalCode;
                    this.city = result.City;
                    this.state = result.State;
                    const regex = /^(\d+)\s(.+)$/;
                    let flaVsStreet = result.Street;
                    if(flaVsStreet!=null && flaVsStreet!=undefined && flaVsStreet!=''){
                        const match = flaVsStreet.match(regex);
                        if (match){
                            const flatNumber = match[1];
                            const streetAdd = match[2];
                            this.flatNumber = flatNumber;
                            this.streetAddress = streetAdd;
                        } else {
                        console.log("No match found");
                        }
                    }

                }
            })
    }*/

    handlePinCodeChange(event) {
        this.pinCode = event.target.value;
        this.selectedSector = '';
        this.selectedLocality = '';
        this.selectedSublocality = '';
        if (this.validatePinCode(this.pinCode)) {
            this.fetchCityAndState();
            this.getLocalityJs();
            this.getSectorJs();
        }
    }

    validatePinCode(pinCode) {
        const pinCodePattern = /^[0-9]{6}$/;
        return pinCodePattern.test(pinCode);
    }

    fetchCityAndState() {
        getCityAndStateByPinCode({ pinCode: this.pinCode })
            .then(result => {
                this.city = result.city;
                this.state = result.state;
                this.isAddressFieldsDisabled = false;
            })
            .catch(error => {
                console.error('Error fetching city and state:', error);
                this.city = '';
                this.state = '';
                this.isAddressFieldsDisabled = true;
            });
    }

    getLocalityJs() {
        this.localities = [];
        getLocality({ pincode: this.pinCode })
            .then(result => {
                if (result.length > 0) {
                    this.localityMap = new Map();
                    this.createLocalityMap(result);
                    this.localities = Array.from(this.localityMap.keys()).map(locality => {
                        return { label: locality, value: locality };
                    });
                    this.localities =this.localities.sort((a, b) => a.label.localeCompare(b.label));;
                    this.showLocality = true;
                } else {
                    this.showLocality = false;
                }
            })
            .catch(error => {
                this.showToast('Error', 'Error occurred while fetching localities: ' + error.body.message, 'error');
            });
    }

    createLocalityMap(localities) {
        localities.forEach(record => {
            if (!this.localityMap.has(record.Locality__c)) {
                this.localityMap.set(record.Locality__c, []);
            }
            this.localityMap.get(record.Locality__c).push({ label: record.Sub_Locality__c, value: record.Sub_Locality__c });
        });
    }

    handleLocalityChange(event) {
        this.selectedLocality = event.detail.value;
        this.sublocalities = this.localityMap.get(this.selectedLocality) || [];
        this.sublocalities = this.sublocalities.sort((a, b) => a.label.localeCompare(b.label));
        this.selectedSublocality = '';
    }

    handleSublocalityChange(event) {
        this.selectedSublocality = event.detail.value;
    }

    handleFlatNumberChange(event) {
        this.flatNumber = event.detail.value;
    }

    handleStreetChange(event) {
        this.streetAddress = event.detail.value;
    }

    getSectorJs() {
        getSector({ pincode: this.pinCode })
            .then(result => {
                if (result.length > 0) {
                    this.sectors = result.map(record => {
                        return { label: record.Sector__c, value: record.Sector__c };
                    });
                    this.showSector = true;
                } else {
                    this.showSector = false;
                }
            })
            .catch(error => {
                this.showToast('Error', 'Error occurred while fetching sectors: ' + error.body.message, 'error');
            });
    }

    handleSectorChange(event) {
        this.selectedSector = event.detail.value;
    }

    handleSave() {
        if (this.validateFields()) {
            if (this.objectType === 'Lead') { // Check if the object type is Lead
                //this.saveAddressToLead();
            } else {
                // Handle other object types if necessary
                this.dispatchCityStateChangeEvent();
            }
        }
    }

    validateFields() {
        if (!this.streetAddress) {
            this.errorMessage = 'Street cannot be blank';
            this.showError = true;
            return false;
        }else{
            const streetRegex = /^[A-Za-z0-9\s\-\,\.\/\\\&\(\)\[\]{}]+$/;
 
            const hasCharOrNumber = /[A-Za-z]/;
            if (!streetRegex.test(this.streetAddress) || !hasCharOrNumber.test(this.streetAddress)) {
                this.errorMessage = 'Street can only contain letters, numbers, spaces, hyphens, commas, slashes, ampersands, and brackets. It must also include at least one character.';
                this.showError = true;
                return false;
            }
        }

        if(this.flatNumber){
            const streetRegex = /^[A-Za-z0-9\s\-\,\/\\\&\(\)\[\]{}]+$/;
            const hasCharOrNumber = /[A-Za-z0-9]/;
            if (!streetRegex.test(this.flatNumber) || !hasCharOrNumber.test(this.flatNumber)) {
                this.errorMessage = 'House number can only contain letters, numbers, spaces, hyphens, commas, slashes, ampersands, and brackets. It must also include at least one character or number.';
                this.showError = true;
                return false;
            }
            /*const houseNumberRegex = /^[A-Za-z0-9\s]+$/;
            if (!houseNumberRegex.test(this.flatNumber)) {
                this.errorMessage = 'House number can only contain letters, numbers, or a combination of both.';
                this.showError = true;
                return false;
            }*/
        }

        if (!this.city) {
            this.errorMessage = 'City cannot be blank';
            this.showError = true;
            return false;
        }
        if (!this.state) {
            this.errorMessage = 'State cannot be blank';
            this.showError = true;
            return false;
        }
        if (!this.country) {
            this.errorMessage = 'Country cannot be blank';
            this.showError = true;
            return false;
        }
        if (!this.pinCode) {
            this.errorMessage = 'Pincode cannot be blank';
            this.showError = true;
            return false;
        }
        this.showError = false;
        return true;
    }

    /*saveAddressToLead() {
        saveAddressToLead({
            leadId: this.recordId,
            flat: this.flatNumber,
            city: this.city,
            state: this.state,
            street: this.streetAddress,
            country: this.country,
            pincode: this.pinCode,
            sector: this.selectedSector,
            locality: this.selectedLocality,
            sublocality: this.selectedSublocality
        })
            .then(() => {
                this.dispatchCityStateChangeEvent();
                this.showToast('Success', 'Address saved successfully', 'success');
            })
            .catch(error => {
                this.showToast('Error', 'Failed to save address: ' + error.body.message, 'error');
            });
    }*/

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }

    dispatchCityStateChangeEvent() {
        const cityStateChangeEvent = new CustomEvent('citystatechange', {
            detail: {
                flat: this.flatNumber,
                city: this.city,
                state: this.state,
                street: this.streetAddress,
                country: this.country,
                pincode: this.pinCode,
                sector: this.selectedSector,
                locality: this.selectedLocality,
                sublocality: this.selectedSublocality
            }
        });
        this.dispatchEvent(cityStateChangeEvent);
    }
}