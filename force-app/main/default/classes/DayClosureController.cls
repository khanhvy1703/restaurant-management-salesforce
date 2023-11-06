public with sharing class DayClosureController {
	private static Decimal totalExpectedAmount = 0;
	private static Decimal totalGainedAmount = 0;
	private static Decimal totalPenny = 0;
	private static Decimal totalDime = 0;
	private static Decimal totalNickel = 0;
	private static Decimal totalQuarter = 0;
	private static Decimal totalOne = 0;
	private static Decimal totalTwo = 0;
	private static Decimal totalFive = 0;
	private static Decimal totalTen = 0;
	private static Decimal totalTwenty = 0;
	private static Decimal totalFifty = 0;
	private static Decimal totalHundred = 0;
	private static Decimal totalCard = 0;
	private static Integer canceledOrders = 0;
	private static Integer paidOrders = 0;
	private static Integer unpaidOrders = 0;

	@AuraEnabled(cacheable=true)
	public static DayClosureInnerClass getSalesInfo() {
		Date today = System.now().date();
		List<Opportunity> listOpp = [
			select Id, Name, CloseDate, Amount_Paid__c, Amount, Order_Status__c, Paid__c, 
			Card__c, Penny__c, Dime__c, Nickle__c, Quarter__c, One_Dollar__c, Two_Dolla__c, Five_Dollars__c, Ten_Dollars__c, 
			Twenty_Dollars__c, Fifty_Dollars__c, One_Hundred_Dollars__c
		from Opportunity 
		where CloseDate =: today];

		for (Opportunity opp : listOpp) {
			System.debug(opp);
			totalGainedAmount += opp.Amount_Paid__c;
			totalPenny += opp.Penny__c;
			totalDime += opp.Dime__c;
			totalNickel += opp.Nickle__c;
			totalQuarter += opp.Quarter__c;
			totalOne += opp.One_Dollar__c;
			totalTwo += opp.Two_Dolla__c;
			totalFive += opp.Five_Dollars__c;
			totalTen += opp.Ten_Dollars__c;
			totalTwenty += opp.Twenty_Dollars__c;
			totalFifty += opp.Fifty_Dollars__c;
			totalHundred += opp.One_Hundred_Dollars__c;
			totalCard += opp.Card__c;
			if (opp.Order_Status__c == 'Canceled') {
				canceledOrders += 1;
			}
			if (opp.Order_Status__c != 'Canceled') {
				totalExpectedAmount += opp.Amount;
				if (!opp.Paid__c) {
					unpaidOrders += 1;
				}
			}
			if (opp.Paid__c) {
				paidOrders += 1;
			}
		}

		DayClosureInnerClass result = new DayClosureInnerClass();
		result.numOfSales = listOpp.size();
		result.expectedAmount = totalExpectedAmount;
		result.gainedAmount = totalGainedAmount;
		result.penny = totalPenny;
		result.dime = totalDime;
		result.quarter = totalQuarter;
		result.nickel = totalNickel;
		result.one = totalOne;
		result.two = totalTwo;
		result.five = totalFive;
		result.ten = totalTen;
		result.twenty = totalTwenty;
		result.fifty = totalFifty;
		result.hundred = totalHundred;
		result.card = totalCard;
		result.paids = paidOrders;
		result.unpaids = unpaidOrders;
		result.canceleds = canceledOrders;

		return result;
	}

	public class DayClosureInnerClass {
		@AuraEnabled public Integer numOfSales {get; set;}
		@AuraEnabled public Decimal expectedAmount {get; set;}
		@AuraEnabled public Decimal gainedAmount {get; set;}
		@AuraEnabled public Decimal penny {get; set;}
		@AuraEnabled public Decimal dime {get; set;}
		@AuraEnabled public Decimal nickel {get; set;}
		@AuraEnabled public Decimal quarter {get; set;}
		@AuraEnabled public Decimal one {get; set;}
		@AuraEnabled public Decimal two {get; set;}
		@AuraEnabled public Decimal five {get; set;}
		@AuraEnabled public Decimal ten {get; set;}
		@AuraEnabled public Decimal twenty {get; set;}
		@AuraEnabled public Decimal fifty {get; set;}
		@AuraEnabled public Decimal hundred {get; set;}
		@AuraEnabled public Decimal card {get; set;}
		@AuraEnabled public Integer paids {get; set;}
		@AuraEnabled public Integer unpaids {get; set;}
		@AuraEnabled public Integer canceleds {get; set;}
	}
}