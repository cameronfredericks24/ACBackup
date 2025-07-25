import { LightningElement, track } from 'lwc';
import findESA from '@salesforce/apex/ESAFinder.findESA';

export default class FindESA extends LightningElement {
    @track departmentNumber = '';
    @track pincodeValue = '';
    @track productFamilyCode = '';
    @track callType = '';
    @track sector = '';
    @track esaResult = '';

    get departmentOptions() {
        return [
            { label: '10', value: '10' },
            { label: '30', value: '30' },
            { label: '32', value: '32' },
            { label: '33', value: '33' },
            { label: '35', value: '35' },
            { label: '36', value: '36' },
            { label: '40', value: '40' },
            { label: '42', value: '42' },
            { label: '43', value: '43' },
            { label: '50', value: '50' },
            { label: '51', value: '51' },
            { label: '52', value: '52' },
            { label: '53', value: '53' },
            { label: '56', value: '56' },
            { label: '57', value: '57' },
            { label: '58', value: '58' },
            { label: '90', value: '90' }
        ];
    }

    get callTypeOptions() {
        return [
            { label: 'None', value: '' },
            { label: 'Breakdown', value: 'Breakdown' },
            { label: 'Demo ', value: 'Demo' },
            { label: 'Enquiry', value: 'Enquiry' },
            { label: 'Installation', value: 'Installation' },
            { label: 'PMS', value: 'PMS' },
            { label: 'Regular Service', value: 'Regular Service' },
            { label: 'Stock Defective', value: 'Stock Defective' },
            { label: 'Predispatch Inspection', value: 'Predispatch Inspection' }
            
        ];
    }

    handleInputChange(event) {
        const field = event.target.name;
        this[field] = event.target.value;
    }

    handleFindESA() {
        findESA({
            departmentNumber: this.departmentNumber,
            pincodeValue: this.pincodeValue,
            productFamilyCode: this.productFamilyCode,
            callType: this.callType,
            sector: this.sector
        })
        .then(result => {
            this.esaResult = result;
        })
        .catch(error => {
            this.esaResult = 'Error finding ESA';
            console.error(error);
        });
    }
}