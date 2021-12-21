public with sharing class OpportunityTriggerHandler {
  public static void onAfterUpdate(Map<Id, Opportunity> oldOppsMap, List<Opportunity> updatedOpps) {
    OpportunityTriggerHelper.getIdsAndAddTasks(oldOppsMap, updatedOpps);
  }
}
