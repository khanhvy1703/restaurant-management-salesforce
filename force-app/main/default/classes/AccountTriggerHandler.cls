public with sharing class AccountTriggerHandler {
	public static void beforeInsert(List<Account> newList,map<Id,Account> newMap){}

	public static void afterInsert(List<Account> newList,map<Id,Account> newMap){}

	public static void beforeUpdate(List<Account> newList,map<Id,Account> newMap, List<Account> oldList,map<Id,Account> oldMap){
		if (Utils.triggerHandle.get('vipTrigger')) {
			AccountTriggerHandlerMethods.vipTrigger(newList, newMap, oldList, oldMap);
		}															
	}

	public static void afterUpdate(List<Account> newList,map<Id,Account> newMap, List<Account> oldList,map<Id,Account> oldMap){}

	public static void beforeDelete(List<Account> oldList,map<Id,Account> oldMap){}

	public static void afterDelete(List<Account> oldList,map<Id,Account> oldMap){}
}