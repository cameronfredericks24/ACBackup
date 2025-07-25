import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CustomToastWithLink extends LightningElement {
    @api modalHeader;

    closeModal() {
        this.dispatchEvent(new CustomEvent('close'));
    }
 //Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, An Breakdown ticket <a href="/500Bi000009OZ2f" target="_self">B01989</a> for this product has already been registered.: []

    showToast() {

        debugger;
        const regex = /<a\s+(?:[^>]*?\s+)?href=(["'])(.*?)\1[^>]*?>(.*?)<\/a>/i;

        // Extracting URL and label using regex
        var errorMessage = 'Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, An Breakdown ticket <a href="/500Bi000009OZ2f" target="_self">B01989</a> for this product has already been registered.: []';
        var errorMessage2 = 'Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, An Breakdown ticket for this product has already been registered.: []'
        const matches = errorMessage.match(regex);
        const matches2 = errorMessage2.match(regex);
        console('matches',matches);
        console('matches2',matches2);
        const url = matches ? matches[2] : null;
        const label = matches ? matches[3] : null;

        // Replacing the anchor tag with placeholder
        const modifiedErrorMessage = errorMessage.replace(regex, `{0}`);

        console.log("Modified Error Message:", modifiedErrorMessage);
        console.log("URL:", url);
        console.log("Label:", label);

        const event = new ShowToastEvent({
            title: 'Error',
            message: 'Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, An Breakdown ticket {0} for this product has already been registered.: []',
            variant: 'Error',
            mode: 'sticky',
            messageData:[
                {
                    url :'/500Bi000009OZ2f',
                    label : 'B01989'
                }
            ]
        });
        this.dispatchEvent(event);
    }
}