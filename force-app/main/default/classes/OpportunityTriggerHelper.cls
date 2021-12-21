public class OpportunityTriggerHelper {
  private static final String triggeredStageValue = 'Needs Analysis';

  public static void getIdsAndAddTasks(Map<Id, Opportunity> oldOppsMap, List<Opportunity> updatedOpps) {
    List<Id> relevantOppIds = new List<Id>();

    for (Opportunity opp : updatedOpps) {
      Opportunity oldOpp = oldOppsMap.get(opp.Id);
      if (oldOpp != null && oldOpp.StageName != opp.StageName && opp.StageName == triggeredStageValue) {
        relevantOppIds.add(opp.Id);
      }
    }

    if (!relevantOppIds.isEmpty()) {
      addTasks(relevantOppIds);
    }
  }

  @InvocableMethod(label='addTasks')
  public static void addTasks(List<Id> oppIds) {
    final String nonRelevantTaskStatus = 'Completed';

    List<Opportunity_Subject_Entry__c> relevantSubjects = [
      SELECT Id, Subject_Entry__c
      FROM Opportunity_Subject_Entry__c
    ];

    List<String> relevantSubjectsStringList = new List<String>();
    for (Opportunity_Subject_Entry__c oppSubjectEntry : relevantSubjects) {
      relevantSubjectsStringList.add(oppSubjectEntry.Subject_Entry__c);
    }

    List<Task> relevantTasks = [
      SELECT Id, WhatId, Status, Subject
      FROM Task
      WHERE WhatId IN :oppIds AND Subject IN :relevantSubjectsStringList AND Status != :nonRelevantTaskStatus
    ];

    List<Task> tasksToInsert = new List<Task>();

    for (Id oppId : oppIds) {
      List<Task> oppRelatedTasks = getOppTasks(oppId, relevantTasks);
      tasksToInsert.addAll(createTasksBundle(relevantSubjects, oppId, oppRelatedTasks));
    }

    insert tasksToInsert;
  }

  private static List<Task> createTasksBundle(
    List<Opportunity_Subject_Entry__c> relevantSubjects,
    Id oppId,
    List<Task> oppRelatedTasks
  ) {
    List<Task> tasksList = new List<Task>();

    for (Opportunity_Subject_Entry__c ose : relevantSubjects) {
      if (!existsBySubject(ose.Subject_Entry__c, oppRelatedTasks)) {
        tasksList.add(new Task(Subject = ose.Subject_Entry__c, WhatId = oppId));
      }
    }

    return tasksList;
  }

  private static List<Task> getOppTasks(Id oppId, List<Task> allTasksList) {
    List<Task> relevantOppTasksList = new List<Task>();

    for (Task tsk : allTasksList) {
      if (tsk.WhatId == oppId) {
        relevantOppTasksList.add(tsk);
      }
    }
    return relevantOppTasksList;
  }

  private static Boolean existsBySubject(String subjectEntry, List<Task> oppTasks) {
    for (Task tsk : oppTasks) {
      if (tsk.Subject == subjectEntry) {
        return true;
      }
    }
    return false;
  }
}