public with sharing class OpportunityTriggerHandlerMethods {
  public static void closedOnPaidTrigger(List<Opportunity> newList,map<Id,Opportunity> newMap, List<Opportunity> oldList,map<Id,Opportunity> oldMap) {
    for (Opportunity opp : newList) {
      Opportunity oldOpp = oldMap.get(opp.Id);
      if (opp.Paid__c && !oldOpp.Paid__c) {
        opp.StageName = 'Paid';
        opp.Order_Status__c = 'Paid';
        opp.CloseDate = System.now().date();
        CatFactController.getCatFact(opp.Id);
      }
    }
  }
  
  public static void vipTrigger(List<Opportunity> newList,map<Id,Opportunity> newMap, List<Opportunity> oldList,map<Id,Opportunity> oldMap) {
    Restaurant_Discount__mdt setting = [select DeveloperName, Percentage__c from Restaurant_Discount__mdt where DeveloperName = 'VIP_Discount' limit 1];
    Decimal discount = 0;
    String numSales = System.Label.Number_Of_Sales;
    Integer sales = Integer.valueOf(numSales);
    
    if(setting != null) {
      discount = setting.Percentage__c; 
    }
    Set<String> accIds = new Set<String>();
    for (Opportunity opp : newList) {
      accIds.add(opp.AccountId);
    }
    List<Account> accs = [Select Id, Number_of_Sales__c, VIP__c from Account where Id =: accIds];
    
    for (Account acc : accs) {
      if (acc.Number_of_Sales__c >= sales) {
        acc.VIP__c = true;
        acc.Discount__c = discount;
      }
    }
    update accs;
  }

  public static void preventNewOpp(List<Opportunity> newList,map<Id,Opportunity> newMap) {
    Set<String> accIds = new Set<String>();
    for (Opportunity opp : newList) {
      accIds.add(opp.AccountId);
    }

    Map<String, Boolean> hasOpenOpps = new Map<String, Boolean>();
    List<Opportunity> existingOpps = [Select Id, Name, StageName, AccountId, isClosed from Opportunity where AccountId IN :accIds];

    for (Opportunity opp : existingOpps) {
      if (!opp.isClosed) {
        if (!hasOpenOpps.containsKey(opp.AccountId)) {
          hasOpenOpps.put(opp.AccountId, true);
        }
      }
    }

    for (Opportunity newOpp : newList) {
      if (hasOpenOpps.containsKey(newOpp.AccountId) && hasOpenOpps.get(newOpp.AccountId)) {
        newOpp.addError('Can not open a new one since the account already has an open sale');
      } else {
        newOpp.Stage_Entry_Time__c = System.now();
      }
    }
  }

  public static void stageTracker(List<Opportunity> newList,map<Id,Opportunity> newMap, List<Opportunity> oldList,map<Id,Opportunity> oldMap) {
    List<Opportunity_Stage_Time_Tracker__c> trackers = new List<Opportunity_Stage_Time_Tracker__c>();
    for (Opportunity newOpp: newList) {
      Opportunity oldOpp = oldMap.get(newOpp.Id);

      String previousStage = oldOpp.StageName;
      String currentStage = newOpp.StageName;

      if (previousStage != currentStage) {
        newOpp.Stage_Entry_Time__c = System.now();
        Datetime previousDataTime = oldOpp.Stage_Entry_Time__c;
        Opportunity_Stage_Time_Tracker__c tracker = new Opportunity_Stage_Time_Tracker__c();
        tracker.Name = previousStage + ' to ' + currentStage;
        tracker.OpportunityId__c = newOpp.Id;
        tracker.Previous_Stage__c = previousStage;
        tracker.Current_Stage__c = currentStage;

        Long previousTimeMil = previousDataTime.getTime();
        Long currentTimeMil = DateTime.now().getTime();
        Long milliseconds = currentTimeMil - previousTimeMil;
        Long timeDifference = milliseconds / 1000;

        Integer hours = Integer.valueOf(Math.mod(timeDifference, 86400) / 3600);
        Integer minutes = Integer.valueOf(Math.mod(timeDifference, 3600) / 60);
        Integer seconds = Integer.valueOf(Math.mod(timeDifference, 60));

        System.debug(hours);
        System.debug(minutes);
        System.debug(seconds);

        tracker.Time__c = String.valueOf(hours) + 'h:' + String.valueOf(minutes) + 'm:' + String.valueOf(seconds) + 's';
        trackers.add(tracker);
      }
    System.debug(oldOpp.Stage_Entry_Time__c);
    System.debug(newOpp.Stage_Entry_Time__c);

    insert trackers;
    }
  }
}