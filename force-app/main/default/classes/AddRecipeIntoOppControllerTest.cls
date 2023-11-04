@isTest
private with sharing class AddRecipeIntoOppControllerTest {
	@isTest
	static void testAddRecipeIntoOppController() {
		Product2 product = new Product2();
		product.Name = 'ABC';
		product.productCode = '3445';
		insert product;

		Recipe__c recipe1 = new Recipe__c();
		recipe1.Name = 'This is Test Recipe';
		insert recipe1;

		Ingredient__c  ingredient = new Ingredient__c();
		ingredient.Name = 'Test Ingredient';
		ingredient.Related_Recipe__c = recipe1.Id;
		ingredient.Product__c = product.Id;
		ingredient.Quantity__c = 3;
		insert ingredient;

		Account acc = new Account();
		acc.Name = 'Test Account';
		acc.Discount__c = 15;
		insert acc;

		Opportunity opp = new Opportunity();
		opp.Name = 'Test Opp';
		opp.Pricebook2Id = Test.getStandardPricebookId();
		opp.StageName = 'Qualification';
		opp.CloseDate = System.now().date();
		opp.AccountId = acc.Id;
		insert opp;

		PricebookEntry testEntry = new PricebookEntry();
		testEntry.Pricebook2Id = Test.getStandardPricebookId();
		testEntry.Product2Id = product.Id;
		testEntry.UnitPrice = 300;
		testEntry.IsActive = true;
		insert testEntry;

		Test.startTest();
		AddRecipeIntoOppController.addRecipeIntoOpp(recipe1.Id, opp.Id);
		Test.stopTest();

		Opportunity updateOpp = [Select Id, Name, Recipe__c, Recipe__r.Name from Opportunity where Id =: opp.Id];
		System.assertEquals('This is Test Recipe', updateOpp.Recipe__r.Name, 'match name');

		List<OpportunityLineItem> updateOppLineItem = [Select Id, Name, UnitPrice, Quantity, Product2Id, TotalPrice, Discount, OpportunityId from OpportunityLineItem where OpportunityId =: opp.Id];
		System.assertEquals(1, updateOppLineItem.size(), 'has 1 product');
		System.assertEquals(20, updateOppLineItem[0].Discount, 'has 20 of Discount');
		System.assertEquals(300, updateOppLineItem[0].UnitPrice, 'cost 300 unit price');
		System.assertEquals(720, updateOppLineItem[0].TotalPrice, 'cost $240');
		System.assertEquals(3, updateOppLineItem[0].Quantity, 'has 3');
	}
}