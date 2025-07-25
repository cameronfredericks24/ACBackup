// startWorkComponent.js
import { LightningElement, api } from 'lwc';
import startWork from "./startworkcomponent.html";
import registerProduct from "./productregistrationfsl.html";
import rejectWork from "./rejectworkcomponent.html";
import mainPage from "./jumboButton.html";
fSLCompleteWorkOrder
export default class StartWorkComponent extends LightningElement {
    @api recordId;
    showTemplateName = 'na';

    render() {
        if(this.showTemplateName == 'na'){
            return mainPage;
        }
        if(this.showTemplateName == 'start_work'){
            return startWork;
        }
        if(this.showTemplateName == 'cancel_form'){
            return registerProduct;
        }
        if(this.showTemplateName == 'reject_work'){
            return rejectWork;
        }
    }

    switchTemplate() {
        let buttonName = event.target.dataset.name;
        if(buttonName == 'start_work'){
            this.showTemplateName = 'start_work';
            return;
        }
        if(buttonName == 'cancel_form'){
            this.showTemplateName = 'cancel_form';
            return;
        }
        if(buttonName == 'reject_work'){
            this.showTemplateName = 'reject_work';
            return;
        }
    }

}