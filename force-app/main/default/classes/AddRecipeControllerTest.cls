@isTest
private with sharing class AddRecipeControllerTest {
	@isTest
	static void testAddRecipeController() {
		Product2 product = new Product2();
		product.Name = 'ABC';
		product.productCode = '3445';
		insert product;

		Recipe__c recipe1 = new Recipe__c();
		recipe1.Name = 'This is Test recipe';
		insert recipe1;

		Ingredient__c  ingredient = new Ingredient__c();
		ingredient.Name = 'sadasd';
		ingredient.Related_Recipe__c = recipe1.Id;
		ingredient.Product__c = product.Id;
		ingredient.Quantity__c = 3;
		insert ingredient;

		List<AddRecipeController.IngredientsInnerClass> ingredientsList = new List<AddRecipeController.IngredientsInnerClass>();
		AddRecipeController.IngredientsInnerClass ingredientClassProduct = new AddRecipeController.IngredientsInnerClass();
		ingredientClassProduct.ingredientName = product.Id;
		ingredientClassProduct.isProduct = true;
		ingredientClassProduct.isRecipe = false;
		ingredientClassProduct.quantity = 2;
		AddRecipeController.IngredientsInnerClass ingredientClassProduct2 = new AddRecipeController.IngredientsInnerClass();
		ingredientClassProduct2.ingredientName = product.Id;
		ingredientClassProduct2.isProduct = true;
		ingredientClassProduct2.isRecipe = false;
		ingredientClassProduct2.quantity = 1;
		AddRecipeController.IngredientsInnerClass ingredientClassRecipe = new AddRecipeController.IngredientsInnerClass();
		ingredientClassRecipe.ingredientName  = recipe1.Id;
		ingredientClassRecipe.isProduct = false;
		ingredientClassRecipe.isRecipe = true;
		ingredientClassRecipe.quantity = 1;
		AddRecipeController.IngredientsInnerClass ingredientClassRecipe2 = new AddRecipeController.IngredientsInnerClass();
		ingredientClassRecipe2.ingredientName  = recipe1.Id;
		ingredientClassRecipe2.isProduct = false;
		ingredientClassRecipe2.isRecipe = true;
		ingredientClassRecipe2.quantity = 1;

		ingredientsList.add(ingredientClassProduct);
		ingredientsList.add(ingredientClassRecipe);
		ingredientsList.add(ingredientClassProduct2);
		ingredientsList.add(ingredientClassRecipe2);

		Test.startTest();

		List<AddRecipeController.IngredientsSummaryInnerClass> resultSummary = AddRecipeController.summary(ingredientsList);
		System.assertEquals(1, resultSummary.size(), '1 product');
		System.assertEquals(9, resultSummary[0].quantity, '5');
		System.assertEquals('ABC', resultSummary[0].productName, 'name of product');

		AddRecipeController.addNewRecipe('Test Recipe', resultSummary);
		List<Ingredient__c>  resultAddNewRecipe = [Select Id, Name, Product__c, Related_Recipe__r.Name, Quantity__c from Ingredient__c where Related_Recipe__r.Name = 'Test Recipe'];
		System.assertEquals(1, resultAddNewRecipe.size(), 'size of ingredients');
		System.assertEquals(9, resultAddNewRecipe[0].Quantity__c, 'quantity of 9');

		Test.stopTest();
	}
}