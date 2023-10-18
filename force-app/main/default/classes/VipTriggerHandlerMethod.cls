public with sharing class VipTriggerHandlerMethod {
	private static Restaurant_Discount__mdt setting;
	private static Decimal discount;

	public static void addDiscountForVip(List<Account> newList, map<Id,Account> newMap, List<Account> oldList, map<Id,Account> oldMap ) {
		// Fetching VIP Discount
		setting = [select DeveloperName, Percentage__c from Restaurant_Discount__mdt where DeveloperName = 'VIP_Discount' limit 1];
		if(setting != null) {
      discount = setting.Percentage__c; 
    } else {
      discount = 0;
    }

		for (Account a : newList) {
			Account oldAcc = oldMap.get(a.Id);
			if (a.VIP__c == true && !oldAcc.VIP__c) {
				a.Discount__c = discount;
			}
		}

		System.debug(newList[0].Discount__c);

		update newList;
	}
}