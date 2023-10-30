@isTest
private with sharing class Tests {
	static testMethod void testLoadDiscountSetting() {
		Test.startTest();
    AddDiscountRegularCustomerController.loadDiscountSetting();
    System.assertEquals(5, AddDiscountRegularCustomerController.discount, 'Should have added discount of 5%');
		Test.stopTest();
  }

	static testMethod void testCheckDiscountApex() {
		Test.startTest();		

		Account testAccount = new Account(
			Name = 'Test Regular Customer',
			VIP__c = false,
			Is_Regular_Discount_Added__c = true
		);
		insert testAccount;

    Boolean result = AddDiscountRegularCustomerController.checkDiscountApex();
		System.assertEquals(true, result, 'should have regular discount');

		delete testAccount;
		Account testAccount2 = new Account(
			Name = 'Test Regular Customer',
			VIP__c = false,
			Is_Regular_Discount_Added__c = false
		);
		insert testAccount2;

		Boolean result2 = AddDiscountRegularCustomerController.checkDiscountApex();
		System.assertEquals(false, result2, 'should have regular discount');

		Test.stopTest();
  }

	static testMethod void testAddRegularDiscountApex() {
		Test.startTest();
		Account testAccount2 = new Account(
			Name = 'Test Regular Customer',
			VIP__c = false,
			Is_Regular_Discount_Added__c = false
		);
		insert testAccount2;

		List<Account> result = AddDiscountRegularCustomerController.addRegularDiscountApex();
		for (Account a : result) {
			System.assertEquals(false, a.VIP__c, 'not VIP acc');
			System.assertEquals(true, a.Is_Regular_Discount_Added__c, 'add regular discount');
			System.assertEquals(5, a.Discount__c, '5% discount added');
		}

		Test.stopTest();
	}

	static testMethod void testRemoveRegularDiscountApex() {
		Test.startTest();
		Account testAccount2 = new Account(
			Name = 'Test Regular Customer',
			VIP__c = false,
			Is_Regular_Discount_Added__c = true,
			Discount__c = 5
		);
		insert testAccount2;

		List<Account> result = AddDiscountRegularCustomerController.removeRegularDiscountApex();
		for (Account a : result) {
			System.assertEquals(false, a.VIP__c, 'not VIP acc');
			System.assertEquals(false, a.Is_Regular_Discount_Added__c, 'removed regular discount');
			System.assertEquals(0, a.Discount__c, 'no discount');
		}

		Test.stopTest();
	}

	static testMethod void testVIPTrigger() {
		Account testAccount = new Account(
			Name = 'Test Account',
			VIP__c = false
		);
		insert testAccount;

		List<Opportunity> opps = new List<Opportunity>();
		for (Integer i = 0; i < 110; i++) {
			Opportunity opp = new Opportunity (
				Name = 'Opp' + i,
				AccountId = testAccount.Id,
				CloseDate = Date.today(), 
				StageName = 'Closed Won'
			);
			opps.add(opp);
		}
		insert opps;

		Test.startTest();
		Account updateAccount = [Select Id, VIP__c from Account where Id =: testAccount.Id];
		System.assertEquals(true, updateAccount.VIP__c, 'true VIP');
		Test.stopTest();
	}

	static testMethod void testAddNewRecipes() {
		Recipe__c recipeIngredient = new Recipe__c(
			Name = 'Recipe Ingredient'
		);
		insert recipeIngredient;
		Product2 productIngredient = new Product2(
			Name = 'Product Ingredient',
			ProductCode = 'ABCDEFG'
		);
		insert productIngredient;

		List<AddRecipeController.IngredientsInnerClass> listOfIngredients = new List<AddRecipeController.IngredientsInnerClass>();
		AddRecipeController.IngredientsInnerClass ingredient1 = new AddRecipeController.IngredientsInnerClass();
		ingredient1.ingredientName = productIngredient.Id;
		ingredient1.isNewProduct = false;
		ingredient1.isProduct = true;
		ingredient1.isRecipe = false;
		ingredient1.quantity = 1;
		listOfIngredients.add(ingredient1);
		AddRecipeController.IngredientsInnerClass ingredient2 = new AddRecipeController.IngredientsInnerClass();
		ingredient2.ingredientName = recipeIngredient.Id;
		ingredient2.isNewProduct = false;
		ingredient2.isProduct = false;
		ingredient2.isRecipe = true;
		ingredient2.quantity = 3;
		listOfIngredients.add(ingredient2);

		Test.startTest();
		AddRecipeController.addNewRecipe('Test Recipe', listOfIngredients);
		List<Ingredient__c> testRecipe = [select Id, Name, Related_Recipe__r.Name from Ingredient__c where Related_Recipe__r.Name = 'Test Recipe'];
		System.assertEquals(2, testRecipe.size(), 'has 2 ingredients');
		Test.stopTest();
	}

	static testMethod void testAddNewRecipeIntoOpp(){
		Account testAccount = new Account(
			Name = 'Test Regular Customer',
			VIP__c = false,
			Is_Regular_Discount_Added__c = true,
			Discount__c = 5
		);
		insert testAccount;

		Recipe__c testRecipe = new Recipe__c(
			Name = 'Test Recipe'
		);
		insert testRecipe;

		Recipe__c recipeIngredient = new Recipe__c(
			Name = 'Recipe 1'
		);
		insert recipeIngredient;

		Product2 testProduct = new Product2(
			Name = 'Product Ingredient',
			ProductCode = 'ABCDEFG'
		);
		insert testProduct;

		PricebookEntry testPricebookEntry = new PricebookEntry(
			Pricebook2Id = Test.getStandardPricebookId(), 
			Product2Id = testProduct.Id,
			IsActive = true,
			UnitPrice = 300
		);
		insert testPricebookEntry;

		Ingredient__c testIngredient1 = new Ingredient__c(
			Name = 'Test Ingredient',
			Product__c = testProduct.Id,
			Related_Recipe__c = testRecipe.Id,
			Quantity__c = 2
		);
		insert testIngredient1;

		Ingredient__c testIngredient2 = new Ingredient__c(
			Name = 'Test Ingredient 2',
			Product__c = testProduct.Id,
			Related_Recipe__c = recipeIngredient.Id,
			Quantity__c = 2
		);
		insert testIngredient2;

		Ingredient__c testIngredient3 = new Ingredient__c(
			Name = 'Test Ingredient 3',
			Recipe__c = recipeIngredient.Id,
			Related_Recipe__c = testRecipe.Id,
			Quantity__c = 2
		);
		insert testIngredient3;

		Opportunity testOpp = new Opportunity(
			Name = 'Test Opp',
			AccountId = testAccount.Id,
			Pricebook2Id = Test.getStandardPricebookId(),
			CloseDate = Date.today(), 
			StageName = 'Qualification'
		);
		insert testOpp;

		Test.startTest();
		AddRecipeIntoOppController.addRecipeIntoOpp(testRecipe.Id, testOpp.Id);
		List<OpportunityLineItem> result = [Select Id, Name, OpportunityId, Product2Id, Quantity, Discount from OpportunityLineItem where OpportunityId =: testOpp.Id];
		System.assertEquals(1, result.size(), 'has 1 product');
		System.assertEquals(10, result[0].Discount, 'has 10% of discount');
		System.assertEquals(4, result[0].Quantity, 'has 4');
		Test.stopTest();
	}

	static testMethod void testDayClosure() {
		List<Opportunity> listOfOpp = new List<Opportunity>();
		Opportunity opp1 = new Opportunity(
			Name = 'Test Opportunity',
			CloseDate = System.today(),
			Amount = 200.00,
			Order_Status__c = 'Canceled',
			StageName = 'Closed Lost',
			Card__c = 0,
			Penny__c = 0,
			Dime__c = 0,
			Nickle__c = 0,
			Quarter__c = 0,
			One_Dollar__c = 0,
			Two_Dolla__c = 0,
			Five_Dollars__c = 0,
			Ten_Dollars__c = 0,
			Twenty_Dollars__c = 0,
			Fifty_Dollars__c = 0,
			One_Hundred_Dollars__c = 0
		);
		listOfOpp.add(opp1);

		Opportunity opp2 = new Opportunity(
			Name = 'Test Opportunity 2',
			CloseDate = System.today(),
			Amount = 200.00,
			Order_Status__c = 'Delivered',
			StageName = 'Closed Won',
			Card__c = 200,
			Penny__c = 0,
			Dime__c = 0,
			Nickle__c = 0,
			Quarter__c = 0,
			One_Dollar__c = 0,
			Two_Dolla__c = 0,
			Five_Dollars__c = 0,
			Ten_Dollars__c = 0,
			Twenty_Dollars__c = 0,
			Fifty_Dollars__c = 0,
			One_Hundred_Dollars__c = 0,
			Payment_Method__c = 'Credit Card'
		);
		listOfOpp.add(opp2);

		Opportunity opp3 = new Opportunity(
			Name = 'Test Opportunity 3',
			CloseDate = System.today(),
			Amount = 200.00,
			Order_Status__c = 'Ready',
			StageName = 'Qualification',
			Card__c = 100,
			Penny__c = 0,
			Dime__c = 0,
			Nickle__c = 0,
			Quarter__c = 0,
			One_Dollar__c = 0,
			Two_Dolla__c = 0,
			Five_Dollars__c = 0,
			Ten_Dollars__c = 0,
			Twenty_Dollars__c = 0,
			Fifty_Dollars__c = 0,
			One_Hundred_Dollars__c = 0,
			Payment_Method__c = 'Credit Card'
		);
		listOfOpp.add(opp3);

		insert listOfOpp;

		Test.startTest();
		DayClosureController.DayClosureInnerClass result = DayClosureController.getSalesInfo();
		System.assertEquals(1, result.canceleds, '1 canceled order');
		System.assertEquals(1, result.paids, '1 paid order');
		System.assertEquals(1, result.unpaids, '1 unpaid order');
		System.assertEquals(300, result.card, '300 in credit card');
		Test.stopTest();
	}

	static testMethod void testGetOppApex() {
		Opportunity opp1 = new Opportunity(
			Name = 'Test Opportunity',
			CloseDate = System.today(),
			Amount = 200.00,
			Order_Status__c = 'Canceled',
			StageName = 'Closed Lost'
		);
		insert opp1;

		Test.startTest();
		Opportunity result = MoveSalesStatusController.getOppApex(opp1.Id);
		System.assertEquals('Canceled', result.Order_Status__c, 'canceled order');
		Test.stopTest();
	}

	static testMethod void testChangeStatusApexSuccess() {
		Opportunity opp = new Opportunity(
			Name = 'Test Opportunity',
			CloseDate = System.today(),
			Amount = 200.00,
			Order_Status__c = 'Ordered',
			StageName = 'Qualification'
		);
		insert opp;

		Test.startTest();
		String result = MoveSalesStatusController.changeStatusApex(opp.Id);
		Opportunity updatedOpportunity = [SELECT Id, Order_Status__c FROM Opportunity WHERE Id = :opp.Id];
		System.assertEquals('Preparing', updatedOpportunity.Order_Status__c, 'preparing order');
		System.assertEquals('Success. Status changed to Preparing', result, 'Success');
		Test.stopTest();
	}

	static testMethod void testChangeStatusApexFail() {
		Opportunity opp = new Opportunity(
			Name = 'Test Opportunity',
			CloseDate = System.today(),
			Amount = 200.00,
			Order_Status__c = 'Delivered',
			StageName = 'Qualification'
		);
		insert opp;

		Test.startTest();
		String result = MoveSalesStatusController.changeStatusApex(opp.Id);
		Opportunity updatedOpportunity = [SELECT Id, Order_Status__c FROM Opportunity WHERE Id = :opp.Id];
		System.assertEquals('Delivered', updatedOpportunity.Order_Status__c, 'preparing order');
		System.assertEquals('Error', result, 'Error');
		Test.stopTest();
	}

	static testMethod void testCancelOrderApex() {
		Opportunity opp = new Opportunity(
			Name = 'Test Opportunity',
			CloseDate = System.today(),
			Amount = 200.00,
			Order_Status__c = 'Ordered',
			StageName = 'Qualification',
			Canceled_Approval_Waiting__c = false
		);
		insert opp;

		Test.startTest();
		MoveSalesStatusController.cancelOrderApex(opp.Id);
		Opportunity updateOpp = [SELECT Id, Canceled_Approval_Waiting__c from Opportunity where Id =: opp.Id];
		System.assertEquals(true, updateOpp.Canceled_Approval_Waiting__c, 'waiting approval');
		Test.stopTest();
	}

	static testMethod void testGetCancelStatus() {
		Test.startTest();
		Opportunity opp = new Opportunity(
			Name = 'Test Opportunity',
			CloseDate = System.today(),
			Amount = 200.00,
			Order_Status__c = 'Ordered',
			StageName = 'Qualification',
			Canceled_Approval_Waiting__c = true
		);
		

		Opportunity opp1 = new Opportunity(
			Name = 'Test Opportunity 1',
			CloseDate = System.today(),
			Amount = 200.00,
			StageName = 'Closed Lost'
		);
		
		Opportunity opp2 = new Opportunity(
			Name = 'Test Opportunity 2',
			CloseDate = System.today(),
			Amount = 200.00,
			StageName = 'Closed Won'
		);

		List<Opportunity> opps = new List<Opportunity>();
		opps.add(opp);
		opps.add(opp1);
		opps.add(opp2);
		insert opps;

		Boolean result = MoveSalesStatusController.getCancelStatus(opp.Id);
		System.assertEquals(true, result, 'true');
		Boolean result1 = MoveSalesStatusController.getCancelStatus(opp1.Id);
		System.assertEquals(true, result1, 'true');
		Boolean result2 = MoveSalesStatusController.getCancelStatus(opp2.Id);
		System.assertEquals(true, result2, 'true');
		Test.stopTest();
	}

	static testMethod void testOpportunityTriggerHandlerMethods() {
		Account testAccount = new Account(
			Name = 'Test Regular Customer',
			VIP__c = false
		);
		insert testAccount;

		Contact testContact = new Contact(
			AccountId = testAccount.Id,
			LastName = 'Salute',
			Primary__c = true,
			Email = 'hahah@gmail.com'
		);
		insert testContact;

		Opportunity testOpp = new Opportunity(
			Name = 'Test Opp',
			AccountId = testAccount.Id,
			CloseDate = Date.today(), 
			StageName = 'Qualification',
			Amount = 100
		);
		insert testOpp;

		Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>();
		oldMap.put(testOpp.Id, testOpp);

		testOpp.Card__c = 100;
		testOpp.Payment_Method__c = 'Credit Card';
		update testOpp;

		List<Opportunity> newList = new List<Opportunity>();
		newList.add(testOpp);

		Test.startTest();
		OpportunityTriggerHandlerMethods.closedOnPaidTrigger(newList, new Map<Id,Opportunity>(), new List<Opportunity>(), oldMap);
		Opportunity checkOpp = [Select Id, Paid__c, StageName, Amount_Paid__c from Opportunity where Id =: testOpp.Id];
		System.assertEquals(true, checkOpp.Paid__c, 'Paid');
		System.assertEquals('Closed Won', checkOpp.StageName, 'Closed Won');
		System.assertEquals(100, checkOpp.Amount_Paid__c, 'Update amount');
		Test.stopTest();
	}
}