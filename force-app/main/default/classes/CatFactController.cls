public with sharing class CatFactController {
	@future(callout = true)
	public static void getCatFact(String oppId) {
		String catfact = APIController.fetchCatFactApi().fact;
		Opportunity updateOpp = [select Id, Customer_Cat_Fact__c from Opportunity where Id =: oppId];
		updateOpp.Customer_Cat_Fact__c = catfact;
		update updateOpp;
	}
}