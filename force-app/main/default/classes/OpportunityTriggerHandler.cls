public with sharing class OpportunityTriggerHandler {
  public void onBeforeUpdate(Map<Id, Opportunity> oldOppsMap, Map<Id, Opportunity> updatedOppsMap) {
    OpportunityTriggerHelper.addTasks(oldOppsMap, updatedOppsMap, null);
  }
}
