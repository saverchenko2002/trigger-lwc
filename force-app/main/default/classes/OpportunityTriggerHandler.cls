public with sharing class OpportunityTriggerHandler {
  public static void onBeforeUpdate(Map<Id, Opportunity> oldOppsMap, Map<Id, Opportunity> updatedOppsMap) {
    OpportunityTriggerHelper.getIdsAndAddTasks(oldOppsMap, updatedOppsMap);
  }
}