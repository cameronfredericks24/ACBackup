import { LightningElement } from 'lwc';
import { RefreshEvent } from 'lightning/refresh';

export default class RefereshPage extends LightningElement {
    connectedCallback(){
        this.dispatchEvent(new RefreshEvent());
    }
}