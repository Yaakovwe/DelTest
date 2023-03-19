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
		return this.show;
	}
	get partiesToRender() {
		return this.currPageParties;
	}
	async connectedCallback() {
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

	handlePagination(event) {
		this.hasPageChanged = !this.hasPageChanged;
		this.currPageParties = event.detail.records;
	}

	add(event) {
		this.showAddParty = false;
		const parties = this.parties;
		const party = event.detail;
		parties.push(event.detail);
		this.parties = parties;
		this.party = undefined;
		this.showAddParty = true;
	}

	del(event) {
		this.show = false;
		const email = JSON.parse(JSON.stringify(event.detail.data));
		const parties = this.parties;
		this.showToastMsg("Success", "Party Successfully Deleted", "success");
		this.show = true;
	}

	showToastMsg(title, message, variant) {
		this.dispatchEvent(
			new ShowToastEvent({
				title: title,
				message: message,
				variant: variant,
			})
		);
	}
}
