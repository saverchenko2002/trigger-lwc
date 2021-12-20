import { api, LightningElement } from "lwc";
import addTasks from "@salesforce/apex/OpportunityTriggerHelper.addTasks";

export default class AddTasksButtonComponent extends LightningElement {
  @api recordId;
  async handleClick() {
    await addTasks({ oldOppsMap: null, updatedOppsMap: null, manualOppId: this.recordId });
  }
}
