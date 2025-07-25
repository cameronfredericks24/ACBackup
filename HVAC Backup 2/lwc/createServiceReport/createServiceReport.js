import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class CreateServiceReport extends NavigationMixin(LightningElement) {

    openFlow() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'flow',
            },
            state: {
                flowParams: {
                    // Specify your flow's API name and any input variables here
                    flowApiName: 'Service_Report_Flow'
                    
                }
            }
        });
    }
}