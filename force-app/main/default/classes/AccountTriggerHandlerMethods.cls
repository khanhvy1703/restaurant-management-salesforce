public with sharing class AccountTriggerHandlerMethods {
	public static void vipTrigger(List<Account> newList,map<Id,Account> newMap, List<Account> oldList,map<Id,Account> oldMap) {
		Restaurant_Discount__mdt setting = [select DeveloperName, Percentage__c from Restaurant_Discount__mdt where DeveloperName = 'VIP_Discount' limit 1];
		Decimal discount = 0;
		String numSales = System.Label.Number_Of_Sales;
		Integer sales = Integer.valueOf(numSales);

		if(setting != null) {
			discount = setting.Percentage__c; 
		}

		for (Account a : newList) {
			Account oldacc = oldMap.get(a.Id);
			if (a.Number_of_Sales__c >= sales && !oldacc.VIP__c) {
				a.VIP__c = true;
				a.Discount__c = discount;
			}
		}
	}
}