public with sharing class DayClosureController {
	private static Decimal totalExpectedAmount = 0;

	@AuraEnabled(cacheable=true)
	public static DayClosureInnerClass getSalesInfo() {
		Date today = System.now().date();
		List<Opportunity> listOpp = [
			select Id, Name, CloseDate, Amount, Order_Status__c
		  from Opportunity 
		  where CloseDate =: today];

		for (Opportunity opp : listOpp) {
			if (opp.Order_Status__c != 'Canceled') {
				totalExpectedAmount += opp.Amount;
			}
		}

		DayClosureInnerClass result = new DayClosureInnerClass();
		result.numOfSales = listOpp.size();
		result.expectedAmount = totalExpectedAmount;

		return result;
	}

	public class DayClosureInnerClass {
		@AuraEnabled public Integer numOfSales {get; set;}
		@AuraEnabled public Decimal expectedAmount {get; set;}
	}
}