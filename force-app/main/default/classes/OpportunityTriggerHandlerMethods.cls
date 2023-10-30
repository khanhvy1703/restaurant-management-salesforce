public with sharing class OpportunityTriggerHandlerMethods {
	public static void closedOnPaidTrigger(List<Opportunity> newList,map<Id,Opportunity> newMap, List<Opportunity> oldList,map<Id,Opportunity> oldMap) {
		for (Opportunity opp : newList) {
      Opportunity oldOpp = oldMap.get(opp.Id);
      if (opp.Paid__c && !oldOpp.Paid__c) {
        opp.StageName = 'Closed Won';
        opp.Order_Status__c = 'Delivered';
        opp.CloseDate = System.now().date();
        CatFactController.getCatFact(opp.Id);
      }
    }
	}
}