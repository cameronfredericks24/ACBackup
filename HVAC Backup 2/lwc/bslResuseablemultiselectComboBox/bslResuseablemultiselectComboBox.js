import { LightningElement, api, track } from "lwc";
export default class MultiPickList extends LightningElement {
  @api label = ""; //Name of the dropDown
  @api maxselected = 2; //Max selected item display
  @api options; // List of items to display
  @api showfilterinput = false; //show filterbutton
  @api showrefreshbutton = false; //show the refresh button
  @api showclearbutton = false; //show the clear button
  @api comboplaceholder = "Select a value";
  @api disableonmousehover = false;
  @track _initializationCompleted = false;
  @track _selectedItems = "Select a value";
  @track _filterValue;
  @track _mOptions;
  @track showselectall;
  @api storeAllSelectedValue = [];
   @api isDisabled = false;
  
  @api 
  setDisabled(disableStatus){
    this.isDisabled = disableStatus;
  }
  constructor() {
    super();
    this._filterValue = "";
    //this.showfilterinput = true;
    //this.showrefreshbutton = true;
    //this.showclearbutton = true;
  }
  connectedCallback() {
    this.initArray(this);
  }
  initArray(context) {
    context._mOptions = new Array();
    context.options.forEach(function (eachItem) {
      context._mOptions.push(JSON.parse(JSON.stringify(eachItem)));
    });
  }
  renderedCallback() {
    let self = this;
    if (!this._initializationCompleted) {
      this.template
        .querySelector(".ms-input")
        .addEventListener("click", function (event) {
          console.log("multipicklist clicked");
          console.log("_mOptions ->"+JSON.stringify(this._mOptions));
          //self.onRefreshClick(event.target);
          self.onDropDownClick(event.target);
          event.stopPropagation();
        });
      this.template.addEventListener("click", function (event) {
        console.log("multipicklist-1 clicked");
        event.stopPropagation();
      });
      document.addEventListener("click", function (event) {
        console.log("document clicked");
        self.closeAllDropDown();
      });
      this._initializationCompleted = true;
      this.setPickListName();
    }
  }
  handleItemSelected(event) {
    let self = this;
    this._mOptions.forEach(function (eachItem) {
      if (eachItem.key == event.detail.item.key) {
        eachItem.selected = event.detail.selected;
        return;
      }
    });
    this.setPickListName();
    this.onItemSelected();
  }
  filterDropDownValues(event) {
    this._filterValue = event.target.value;
    this.updateListItems(this._filterValue);
  }
  closeAllDropDown() {
    Array.from(this.template.querySelectorAll(".ms-picklist-dropdown")).forEach(
      function (node) {
        node.classList.remove("slds-is-open");
      }
    );
  }
  closeAllDropDownOnMouseHover() {
    if(this.disableonmousehover == false){
      setTimeout((function () {
        Array.from(this.template.querySelectorAll(".ms-picklist-dropdown")).forEach(
          function (node) {
            node.classList.remove("slds-is-open");
          }
        );
        }).bind(this), 500);
    
    }
  }

  onDropDownClick(dropDownDiv) {
    let classList = Array.from(
      this.template.querySelectorAll(".ms-picklist-dropdown")
    );
    if (!classList.includes("slds-is-open")) {
      this.closeAllDropDown();
      Array.from(
        this.template.querySelectorAll(".ms-picklist-dropdown")
      ).forEach(function (node) {
        node.classList.add("slds-is-open");
      });
    } else {
      this.closeAllDropDown();
    }
  }
  @api
  onRefreshClick(event) {
    this._filterValue = "";
    this.initArray(this);
    this.updateListItems("");
    this.onItemSelected();
  }
  onClearClick(event) {
    this._filterValue = "";
    this.updateListItems("");
  }
  updateListItems(inputText) {
    Array.from(this.template.querySelectorAll("c-b-s-l-reuseable-multiselect-combobox-child")).forEach(
      function (node) {
        if (!inputText) {
          node.style.display = "block";
        } else if (
          node.item.value
            .toString()
            .toLowerCase()
            .indexOf(inputText.toString().trim().toLowerCase()) != -1
        ) {
          node.style.display = "block";
        } else {
          node.style.display = "none";
        }
      }
    );
    this.setPickListName();
  }
  setPickListName() {
    console.log('setPickListName');
    let selecedItems = this.getSelectedItems();
    let selections = "";
    if (selecedItems.length < 1) {
      selections = this.comboplaceholder;
    } else if (selecedItems.length > this.maxselected) {
      selections = selecedItems.length + " Options Selected";
    } else {
      selecedItems.forEach((option) => {
        selections += option.value + ",";
      });
    }
    this._selectedItems = selections;
  }
  @api
  getSelectedItems() {
    console.log('get selected item');
    let resArray = new Array();
    this._mOptions.forEach(function (eachItem) {
      if (eachItem.selected) {
        resArray.push(eachItem);
        //console.log('resArray-->'+JSON.stringify(resArray));
      }
    });
    return resArray;
  }

  @api onItemSelected() {
    const evt = new CustomEvent("itemselected", {
      detail: this.getSelectedItems(),
    });
    console.log('this.getSelectedItems()',this.getSelectedItems());
    this.dispatchEvent(evt);
    console.log('this.getSelectedItems()',this.getSelectedItems());
    
  }
  selectAllOption(){
        console.log('allcli');
        let allselectedArray = new Array();
        this._mOptions.forEach(function (eachItem) {
        eachItem.selected = true;
        allselectedArray.push(eachItem);
        console.log('allselectedArray--->'+JSON.stringify(allselectedArray));
        //this.handleItemSelected(allselectedArray);
        
    });
    this.setPickListName();
    this.onItemSelected();
    return this._mOptions;

  }
}