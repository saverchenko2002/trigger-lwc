trigger OpportunityTrigger on Opportunity(before update) {
  if (Trigger.isBefore && Trigger.isUpdate) {
    OpportunityTriggerHandler.onBeforeUpdate(Trigger.oldMap, Trigger.newMap);
  }
}
