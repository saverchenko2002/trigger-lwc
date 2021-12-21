public with sharing class OpportunityTriggerHandler {
  public static void onBeforeUpdate(Map<Id, Opportunity> oldOppsMap, Map<Id, Opportunity> updatedOppsMap) {
    List<Id> oppIdsStageChange = OpportunityTriggerHelper.retrieveRelevantIds(oldOppsMap, updatedOppsMap);
    OpportunityTriggerHelper.addTasks(oppIdsStageChange);
  }
}
