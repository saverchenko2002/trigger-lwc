trigger OpportunityTrigger on Opportunity(before update) {
  OpportunityTriggerHandler handler = new OpportunityTriggerHandler();

  if (Trigger.isBefore && Trigger.isUpdate) {
    handler.onBeforeUpdate(Trigger.oldMap, Trigger.newMap);
  }
}
