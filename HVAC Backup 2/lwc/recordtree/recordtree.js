import { LightningElement,api } from "lwc";

export default class Recordtree extends LightningElement {

    @api record;
    @api allRecords;

    get hasChildren() {
        debugger;
        return this.allRecords.some(child => child.ParentId === this.record.Id);
    }

    get children() {
        debugger
        return this.allRecords.filter(child => child.ParentId === this.record.Id);
    }
    get tableData() {
        var headerLength = (this.headers).length;
        return this.allRecords.map(row => Object.values(row).slice(0, headerLength));
    }
}