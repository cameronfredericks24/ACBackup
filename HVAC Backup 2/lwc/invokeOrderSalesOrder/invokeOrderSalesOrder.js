import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";

export default class InvokeOrderSalesOrder extends LightningElement {

  @api recordId;

  @api invoke() {
    this[NavigationMixin.Navigate]({
      type: "standard__navItemPage",
      attributes: {
        apiName: "Create_Order",
        recordId: this.recordId,
      },
    });
  }
  
}