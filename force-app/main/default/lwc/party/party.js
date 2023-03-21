import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import deleteParty from "@salesforce/apex/PartyService.deleteParty";
import upsertParty from "@salesforce/apex/PartyService.upsertParty";

export default class Party extends LightningElement {
  @api party = {};
  @api showAddParty = false;

  get sectionName() {
    return this.party.Party_Code__c;
  }
  modalHeading = "New Party";
  modalContentStyle = "height:65%";
  modalGridStyleClass = "slds-medium-size_1-of-2";
  temp = {};
  show = false;
  cols = [
    {
      index: 1,
      inputs: [
        { Id: 1, label: "Name", isText: true, key: "Name" },
        { Id: 2, label: "Description", isText: true, key: "Description__c" }
      ]
    },
    {
      index: 2,
      inputs: [
        { Id: 3, label: "Party Code", isText: true, key: "Party_Code__c" },
        { Id: 4, label: "Chairman", isText: true, key: "Chairman__c" }
      ]
    }
  ];

  columns = [
    {
      index: 1,
      inputs: [
        { Id: 1, label: "Name", isText: true, key: "Name" },
        { Id: 2, label: "Description", isText: true, key: "Description__c" }
      ]
    },
    {
      index: 2,
      inputs: [
        { Id: 3, label: "Party Code", isText: true, key: "Party_Code__c" },
        { Id: 4, label: "Chairman", isText: true, key: "Chairman__c" }
      ]
    }
  ];

  get isReady() {
    return this.show;
  }

  connectedCallback() {
    this.addValuesFromParent();
    this.show = true;
  }

  addValuesFromParent() {
    this.columns.forEach((col) => {
      col.inputs.forEach((input) => {
        const value = this.party[input.key];
        input.value = value;
      });
    });
  }

  handleEdit() {
    this.modalHeading = "Edit Party";
    this.template.querySelector("c-modal").openModal();
  }

  handleOpen() {
    this.columns = [];
    this.columns = this.cols;
    this.user = {};
    this.template.querySelector("c-modal").openModal();
  }

  closeConformationModal() {
    this.template.querySelector("c-modal").closeModal();
  }

  handleModalConfirmation() {
    this.show = false;
    this.handleSaveData();
    let message = this.isNew ? " Added" : " Modified";
    if (this.showAddParty) {
      const data = this.party;
      const dataToSend = new CustomEvent("handleadd", {
        detail: data
      });

      this.dispatchEvent(dataToSend);
    }
    this.showToastMsg("Success", "Party Successfully" + message, "success");
    this.closeConformationModal();
    this.addValuesFromParent();
    this.show = true;
  }

  async handleSaveData() {
    const result = await upsertParty({ party: this.party });
    console.log(JSON.stringify(this.party));
    console.log(result);
  }

  handleInputChanged(event) {
    const keyToLabel = {
      "Party Code": "Party_Code__c",
      Name: "Name",
      Description: "Description__c",
      Chairman: "Chairman__c"
    };
    const data = event.detail;
    const field = keyToLabel[data.label];
    let party = { ...this.party };
    party[field] = data.value;
    this.party = undefined;
    this.party = party;
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

  async handleDelete() {
    this.show = false;
    const result = await deleteParty({ partyId: this.party.Id });
    if (result) {
      this.showToastMsg(
        "Success",
        "Successfully Deleted the Party Record",
        "Success"
      );
      console.log(result);
      const dataToParent = new CustomEvent("handledelete", {
        detail: this.party
      });
      this.show = true;
      this.dispatchEvent(dataToParent);
    } else {
      this.showToastMsg("", "Failed to Delete the Party Record", "error");
    }
  }
}
