import { LightningElement, api } from 'lwc';
import getCurrentUserContactLocation from '@salesforce/apex/PlaceOrderComponentController.getCurrentUserContactLocation';

export default class CreateRMRDefectiveItems extends LightningElement {
    @api recordId;
    enableFlow = false;

    connectedCallback() {
        getCurrentUserContactLocation()
            .then((result) => {
                console.log('result', result);
                if (result != null) {
                    this.recordId = result;
                    this.enableFlow = true;
                    this.startFlow();
                }
            })
            .catch((error) => {
                console.error('Error:', error);
            });
    }

    get inputVariables() {
        return [
            {
                name: 'recordId',
                type: 'String',
                value: this.recordId
            }
        ];
    }

    startFlow() {
        if (this.enableFlow) {
            const flow = this.template.querySelector('lightning-flow');
            if (flow) {
                flow.startFlow('Defective_Product_Line_Item_GRN', this.inputVariables);
            }
        }
    }

    handleStatusChange(event) {
        if (event.detail.status === 'FINISHED') {
            // Handle what happens after the flow finishes
            console.log('Flow finished with status: ', event.detail.status);
        }
    }}