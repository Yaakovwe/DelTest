import { LightningElement, track } from "lwc";
import getParties from "@salesforce/apex/PartyService.fetchParties";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class Parties extends LightningElement {
  @track parties = [];
  @track party = {};
  currPageParties = [];
  renderPagination = false;
  hasPageChanged = false;
  modalHeading = "New Party";
  modalContentStyle = "height:65%";
  modalGridStyleClass = "slds-medium-size_1-of-2";
  showAddParty = true;
  show = false;

  get isReady() {
    return this.showAddParty;
  }
  get partiesToRender() {
    return this.currPageParties;
  }
  async connectedCallback() {
    this.getParties();
  }

  handlePagination(event) {
    this.hasPageChanged = !this.hasPageChanged;
    this.currPageParties = event.detail.records;
  }

  add() {
    this.show = false;
    this.showAddParty = false;
    this.getParties();
    this.show = true;
    this.showAddParty = true;
  }

  del() {
    this.show = false;
    this.showAddParty = false;
    this.getParties();
    this.show = true;
    this.showAddParty = true;
  }

  showToastMsg(title, message, variant) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
      })
    );
  }

  async getParties() {
    const results = await getParties();
    if (results) {
      console.log(results);
      this.parties = results;
      this.renderPagination = true;
      this.show = true;
    } else {
      console.log("oops");
    }
  }
}
