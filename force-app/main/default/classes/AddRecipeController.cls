public with sharing class AddRecipeController {
  public class IngredientsInnerClass {
    @AuraEnabled public String ingredientName {get; set;}
    @AuraEnabled public Integer quantity {get; set;}
    @AuraEnabled public Boolean isProduct {get; set;}
    @AuraEnabled public Boolean isRecipe {get; set;}
    @AuraEnabled public Boolean isNewProduct {get; set;}
  }

  @AuraEnabled
  public static void addNewRecipe(String recipeName, List<IngredientsInnerClass> listOfIngredients){
    // Add recipe
    Recipe__c newrecipe = new Recipe__c();
    newrecipe.Name = recipeName;
    insert newrecipe;

    // Add Ingredients
    Map<String, Integer> recipes = new Map<String, Integer>();
    Map<String, Integer> products = new Map<String, Integer>();
    //Map<String, Integer> newProducts = new Map<String, Integer>();

    for (IngredientsInnerClass i : listOfIngredients) {
      if (i.isRecipe) {
        recipes.put(i.ingredientName, i.quantity);
      } 
      if(i.isProduct) {
        products.put(i.ingredientName, i.quantity);
      } 
      // if(i.isNewProduct) {
      //   newProducts.put(i.ingredientName.trim(), i.quantity);
      // }
    }

    List<Ingredient__c> ingredients = new List<Ingredient__c>();

    // iterate through recipes map
    for (String key : recipes.keySet()) {
      Integer quantity = recipes.get(key);
      Ingredient__c ingredient = new Ingredient__c();
      Recipe__c recipe = [select Id, Name from Recipe__c where Id =: key];

      ingredient.Name = recipeName + ': ' + recipe.Name;
      ingredient.Related_Recipe__c = newrecipe.id;
      ingredient.Recipe__c = key;
      ingredient.Quantity__c = quantity;
      ingredients.add(ingredient);
    }

    // iterate through existing peoducts map
    for (String key: products.keySet()) {
      Integer quantity = products.get(key);
      Ingredient__c ingredient = new Ingredient__c();
      Product2 product = [select Id, Name from Product2 where Id =: key];

      ingredient.Name = recipeName + ': ' + product.Name;
      ingredient.Related_Recipe__c = newrecipe.id;
      ingredient.Product__c = key;
      ingredient.Quantity__c = quantity;
      ingredients.add(ingredient);
    }
    
    insert ingredients;

    // List<Ingredient__c> ingredientsForNewProducts = new List<Ingredient__c>();
    // List<Product2> insertedNewProducts = new List<Product2>();
    // // iterate through new products map
    // for (String key : newProducts.keySet()) {
    //   Integer quantity = newProducts.get(key);
    //   Ingredient__c ingredient = new Ingredient__c();
    //   String code = key.replaceAll('\\s+', '');

    //   Product2 newProduct = new Product2();
    //   newProduct.Name = key;
    //   newProduct.ProductCode = code.toUppercase();
    //   newProduct.IsActive = true;
    //   insertedNewProducts.add(newProduct);

    //   ingredient.Name = recipeName + ': ' + key;
    //   ingredient.Related_Recipe__c = newrecipe.id;
    //   ingredient.Quantity__c = quantity;
    //   ingredientsForNewProducts.add(ingredient);
    // }
    
    // insert insertedNewProducts;

    // for (Integer i = 0; i < insertedNewProducts.size(); i++) {
    //   ingredientsForNewProducts[i].Product__c = insertedNewProducts[i].id;
    // }

    // insert ingredientsForNewProducts;

    System.debug(ingredients);
    //System.debug(insertedNewProducts);
  }
}