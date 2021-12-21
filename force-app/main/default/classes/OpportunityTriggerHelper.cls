public class OpportunityTriggerHelper {
  private static final String triggeredStageValue = 'Needs Analysis';

  public static void getIdsAndAddTasks(Map<Id, Opportunity> oldOppsMap, Map<Id, Opportunity> updatedOppsMap) {
    List<Id> relevantOppIds = new List<Id>();

    for (Id oppId : oldOppsMap.keySet()) {
      if (
        oldOppsMap.get(oppId).StageName != triggeredStageValue &&
        updatedOppsMap.get(oppId).StageName == triggeredStageValue
      ) {
        relevantOppIds.add(oppId);
      }
    }

    if (relevantOppIds.size() > 0) {
      addTasks(relevantOppIds);
    }
  }

  @InvocableMethod(label='addTasks')
  public static void addTasks(List<Id> oppIds) {
    List<String> nonRelevantTaskStatuses = new List<String>{ 'Completed' };

    final String taskStatus = 'Not Started';
    final String taskPriority = 'Normal';

    List<Opportunity_Subject_Entry__c> relevantSubjects = [
      SELECT Id, Subject_Entry__c
      FROM Opportunity_Subject_Entry__c
    ];

    List<Opportunity> relevantOpps = [
      SELECT
        Id,
        StageName,
        OwnerId,
        (SELECT Id, Subject, Status FROM Tasks WHERE Status NOT IN :nonRelevantTaskStatuses)
      FROM Opportunity
      WHERE Id IN :oppIds
    ];

    List<Task> tasksToInsert = new List<Task>();

    for (Opportunity opp : relevantOpps) {
      if (opp.Tasks.size() > 0) {
        tasksToInsert.addAll(
          createTasksBundleBasedOnExistingTasks(relevantSubjects, opp, taskStatus, taskPriority)
        );
      } else {
        tasksToInsert.addAll(createDefaultTasksBundle(relevantSubjects, opp, taskStatus, taskPriority));
      }
    }

    insert tasksToInsert;
  }

  private static List<Task> createDefaultTasksBundle(
    List<Opportunity_Subject_Entry__c> relevantSubjects,
    Opportunity opp,
    String taskStatus,
    String taskPriority
  ) {
    List<Task> taskList = new List<Task>();
    for (Opportunity_Subject_Entry__c ose : relevantSubjects) {
      taskList.add(
        new Task(
          Subject = ose.Subject_entry__c,
          Status = taskStatus,
          Priority = taskPriority,
          WhatId = opp.Id,
          OwnerId = opp.OwnerId
        )
      );
    }
    return taskList;
  }

  private static List<Task> createTasksBundleBasedOnExistingTasks(
    List<Opportunity_Subject_Entry__c> relevantSubjects,
    Opportunity opp,
    String taskStatus,
    String taskPriority
  ) {
    List<Task> taskList = new List<Task>();

    Map<String, Boolean> taskExistenceBySubjectMap = new Map<String, Boolean>();
    for (Opportunity_Subject_Entry__c ose : relevantSubjects) {
      taskExistenceBySubjectMap.put(ose.Subject_Entry__c, false);
    }

    for (Opportunity_Subject_Entry__c ose : relevantSubjects) {
      for (Task existingTask : opp.Tasks) {
        if (existingTask.Subject == ose.Subject_Entry__c) {
          taskExistenceBySubjectMap.put(existingTask.Subject, true);
          break;
        }
      }
    }

    for (String subject : taskExistenceBySubjectMap.keySet()) {
      if (taskExistenceBySubjectMap.get(subject)) {
        continue;
      } else {
        taskList.add(
          new Task(
            Subject = subject,
            Status = taskStatus,
            Priority = taskPriority,
            WhatId = opp.Id,
            OwnerId = opp.OwnerId
          )
        );
      }
    }
    return taskList;
  }
}
