public with sharing class AccountTriggerHandlerMethods {
	public static void vipTrigger(List<Account> newList,map<Id,Account> newMap, List<Account> oldList,map<Id,Account> oldMap) {
		Restaurant_Discount__mdt setting = [select DeveloperName, Percentage__c from Restaurant_Discount__mdt where DeveloperName = 'VIP_Discount' limit 1];
		Decimal discount = 0;
		if(setting != null) {
			discount = setting.Percentage__c; 
		}

		for (Account a : newList) {
			Account oldacc = oldMap.get(a.Id);
			if (a.Number_of_Sales__c >= 100 && !oldacc.VIP__c) {
				a.VIP__c = true;
				a.Discount__c = discount;
			}
		}
	}
}