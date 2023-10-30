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
		// no need 
		Test.stopTest();
	}

	static testMethod void testAddNewRecipes(){
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
}