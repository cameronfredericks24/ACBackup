import { LightningElement, api, wire } from 'lwc';
import getAccountNotice from '@salesforce/apex/ShowAccountNoticeController.getAccountNotice';

export default class DisplayNoticeOnRecord extends LightningElement {
    @api recordId;
    accountNotice;
    containerStyle = '';

    @wire(getAccountNotice, { recordId: '$recordId' })
    wiredAccountNotice({ error, data }) {
        if (data) {
            this.accountNotice = data;
            this.updateContainerStyle();
        } else if (error) {
            console.error('Error retrieving Account Notice:', error);
        }
    }

    updateContainerStyle() {
        // Calculate the height based on the number of lines in the notice
        const lineHeight = 20;
        const numberOfLines = this.accountNotice ? this.accountNotice.split('\n').length : 1;
        const height = numberOfLines * lineHeight + 'px';
        this.containerStyle = `height: ${height};`;
    }
}