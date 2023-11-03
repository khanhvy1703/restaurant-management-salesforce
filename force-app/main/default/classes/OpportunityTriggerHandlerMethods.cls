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
		if(setting != null) {
			discount = setting.Percentage__c; 
		}

    for (Opportunity opp : newList) {
      Opportunity oldOpp = oldMap.get(opp.Id);
      Account acc = [Select Id, Number_of_Sales__c, VIP__c from Account where Id =: opp.AccountId];
      if (acc.Number_of_Sales__c >= 1) {
        acc.VIP__c = true;
        acc.Discount__c = discount;
      }
    }
  }
}