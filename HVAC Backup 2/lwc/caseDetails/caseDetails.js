import { LightningElement, api, wire, track } from 'lwc';
import getCaseDetails from '@salesforce/apex/CaseDetailsController.getCaseDetails';
import logoResource from '@salesforce/resourceUrl/OfficialLogoBlueStar';

export default class CaseDetails extends LightningElement {

    @api caseNumber;
    @track case;

    connectedCallback() {
        this.loadCaseDetails();
    }

    loadCaseDetails() {
        getCaseDetails({ caseNumber: this.caseNumber })
            .then(result => {
                this.case = result;
            })
            .catch(error => {
                console.error('Error fetching case details:', error);
            });
    }

     get suppliedName() {
        return this.case ? this.case.SuppliedName : '';
    }

    get caseNumberValue() {
        return this.case ? this.case.CaseNumber : '';
    }

    get caseStatus() {
        return this.case ? this.case.Status : '';
    }
    get logoUrl() {
        return logoResource;
    }
    
    
}