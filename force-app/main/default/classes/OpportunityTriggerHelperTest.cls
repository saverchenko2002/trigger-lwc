@isTest
private class OpportunityTriggerHelperTest {
  @TestSetup
  static void makeData() {
    List<String> subjects = new List<String>{ 'green', 'red', 'blue' };
    Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

    User testUser = new User(
      LastName = 'LIVESTON',
      FirstName = 'SERGEY',
      Alias = 'sliv',
      Email = 'sergey.liveston@asdf.com',
      Username = 'sergey.liveston@asdf.com',
      ProfileId = profileId.id,
      TimeZoneSidKey = 'GMT',
      LanguageLocaleKey = 'en_US',
      EmailEncodingKey = 'UTF-8',
      LocaleSidKey = 'en_US'
    );

    insert testUser;

    Account acc = new Account(Name = 'Test1');
    insert acc;

    RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND Name = 'Master'];

    List<Opportunity> opps = new List<Opportunity>();
    List<Opportunity_Subject_Entry__c> oses = new List<Opportunity_Subject_Entry__c>();
    List<Task> testTasks = new List<Task>();

    for (Integer i = 0; i < 3; i++) {
      Opportunity opp = new Opportunity(
        Name = 'Test' + i,
        RecordTypeId = rt.Id,
        Type = 'Value Proposition',
        CloseDate = Date.today(),
        StageName = 'Created',
        AccountId = acc.Id,
        OwnerId = testUser.Id
      );
      opps.add(opp);

      Opportunity_Subject_Entry__c ose = new Opportunity_Subject_Entry__c(Subject_Entry__c = subjects[i]);
      oses.add(ose);
    }

    insert opps;
    insert oses;

    for (Integer i = 0; i < 3; i++) {
      Task tsk = new Task(
        Subject = subjects[i],
        Status = 'Open',
        Priority = 'Normal',
        WhatId = opps[0].Id,
        OwnerId = testUser.Id
      );
      testTasks.add(tsk);
    }

    Task tsk4 = new Task(
      Subject = oses[1].Subject_Entry__c,
      Status = 'Open',
      Priority = 'Normal',
      WhatId = opps[1].Id,
      OwnerId = testUser.Id
    );

    testTasks.add(tsk4);

    insert testTasks;
  }

  @isTest
  static void setupDataAccuracyTest() {
    System.assertEquals(1, [SELECT COUNT() FROM Account]);
    System.assertEquals(1, [SELECT COUNT() FROM User WHERE LastName = 'LIVESTON']);
    System.assertEquals(3, [SELECT COUNT() FROM Opportunity]);
    System.assertEquals(4, [SELECT COUNT() FROM Task]);
    System.assertEquals(3, [SELECT COUNT() FROM Opportunity_Subject_Entry__c]);
  }

  @isTest
  static void noTasksOpportunityTest() {
    List<Opportunity> opps = [SELECT Id, StageName, (SELECT Id, Subject FROM Tasks) FROM Opportunity];

    Opportunity oppWithNoTasks = null;
    for (Opportunity opp : opps) {
      if (opp.Tasks.size() == 0) {
        oppWithNoTasks = opp;
        break;
      }
    }

    oppWithNoTasks.StageName = 'Needs Analysis';

    Test.startTest();
    update oppWithNoTasks;
    Test.stopTest();

    List<Opportunity> updatedOpp = [
      SELECT Id, StageName, (SELECT Id, Subject FROM Tasks)
      FROM Opportunity
      WHERE Id = :oppWithNoTasks.Id
    ];

    System.assertEquals(3, updatedOpp[0].Tasks.size());
  }

  @isTest
  static void allTasksExistTest() {
    List<Opportunity> opps = [SELECT Id, StageName, (SELECT Id, Subject FROM Tasks) FROM Opportunity];
    Integer oppSubjectsCount = [SELECT COUNT() FROM Opportunity_Subject_Entry__c];
    Integer summaryCountOfTasks = [SELECT COUNT() FROM Task];

    Opportunity oppWithAllTheTasks = null;
    for (Opportunity opp : opps) {
      if (opp.Tasks.size() == oppSubjectsCount) {
        oppWithAllTheTasks = opp;
        break;
      }
    }

    oppWithAllTheTasks.StageName = 'Needs Analysis';

    Test.startTest();
    update oppWithAllTheTasks;
    Test.stopTest();

    System.assertEquals(summaryCountOfTasks, [SELECT COUNT() FROM Task]);
  }

  @isTest
  static void partialTaskExistenceTest() {
    List<Opportunity> opps = [SELECT Id, StageName, (SELECT Id, Subject FROM Tasks) FROM Opportunity];
    Integer oppSubjectsCount = [SELECT COUNT() FROM Opportunity_Subject_Entry__c];

    Opportunity oppWithPartialTasks = null;
    for (Opportunity opp : opps) {
      if (opp.Tasks.size() < oppSubjectsCount && opp.Tasks.size() > 0) {
        oppWithPartialTasks = opp;
        break;
      }
    }

    List<String> existingSubjects = new List<String>();
    for (Task tsk : oppWithPartialTasks.Tasks) {
      existingSubjects.add(tsk.Subject);
    }

    System.assertEquals(1, existingSubjects.size());
    System.assertEquals('red', existingSubjects[0]);

    oppWithPartialTasks.StageName = 'Needs Analysis';

    Test.startTest();
    update oppWithPartialTasks;
    Test.stopTest();

    List<Task> oppRelatedTasks = [
      SELECT Id, Subject, WhatId
      FROM Task
      WHERE WhatId = :oppWithPartialTasks.Id
    ];
    System.assertEquals(3, oppRelatedTasks.size());

    List<Opportunity_Subject_Entry__c> oses = [SELECT Id, Subject_Entry__c FROM Opportunity_Subject_Entry__c];
    Map<String, Integer> subjectsCount = new Map<String, Integer>();
    for (Opportunity_Subject_Entry__c ose : oses) {
      subjectsCount.put(ose.Subject_Entry__c, 0);
    }
    for (Task tsk : oppRelatedTasks) {
      for (String subject : subjectsCount.keySet()) {
        if (tsk.Subject == subject) {
          Integer countOfTasksWithUniqueSubject = subjectsCount.get(subject);
          countOfTasksWithUniqueSubject++;
          subjectsCount.put(subject, countOfTasksWithUniqueSubject);
        }
      }
    }

    for (String key : subjectsCount.keySet()) {
      System.assertEquals(1, subjectsCount.get(key));
    }
  }
}
