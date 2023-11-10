public with sharing class OpportunityTriggerHandler {
	public static void beforeInsert(List<Opportunity> newList,map<Id,Opportunity> newMap){
		if (Utils.triggerHandle.get('preventNewOpp')) {
			OpportunityTriggerHandlerMethods.preventNewOpp(newList, newMap);
		}
	}

	public static void afterInsert(List<Opportunity> newList,map<Id,Opportunity> newMap){}

	public static void beforeUpdate(List<Opportunity> newList,map<Id,Opportunity> newMap, List<Opportunity> oldList,map<Id,Opportunity> oldMap){
		if (Utils.triggerHandle.get('closedOnPaidTrigger')) {
			OpportunityTriggerHandlerMethods.closedOnPaidTrigger(newList, newMap, oldList, oldMap);
		}
		if (Utils.triggerHandle.get('stageTracker')) {
			OpportunityTriggerHandlerMethods.stageTracker(newList, newMap, oldList, oldMap);
		}								
	}

	public static void afterUpdate(List<Opportunity> newList,map<Id,Opportunity> newMap, List<Opportunity> oldList,map<Id,Opportunity> oldMap){
		if (Utils.triggerHandle.get('vipTrigger')) {
			OpportunityTriggerHandlerMethods.vipTrigger(newList, newMap, oldList, oldMap);
		}
	}

	public static void beforeDelete(List<Opportunity> oldList,map<Id,Opportunity> oldMap){}

	public static void afterDelete(List<Opportunity> oldList,map<Id,Opportunity> oldMap){}
}