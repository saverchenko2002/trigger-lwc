trigger OpportunityTrigger on Opportunity(after update) {
  if (Trigger.isAfter && Trigger.isUpdate) {
    OpportunityTriggerHandler.onAfterUpdate(Trigger.oldMap, Trigger.new);
  }
}
