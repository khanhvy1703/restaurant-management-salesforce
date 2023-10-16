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
    Map<String, Integer> newProducts = new Map<String, Integer>();

    for (IngredientsInnerClass i : listOfIngredients) {
      if (i.isRecipe) {
        recipes.put(i.ingredientName, i.quantity);
      } 
      if(i.isProduct) {
        products.put(i.ingredientName, i.quantity);
      } 
      if(i.isNewProduct) {
        newProducts.put(i.ingredientName.trim(), i.quantity);
      }
    }

    List<Ingredient__c> ingredients = new List<Ingredient__c>();
    List<Product2> insertedNewProducts = new List<Product2>();

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

    for (String key : newProducts.keySet()) {
      Integer quantity = newProducts.get(key);
      Ingredient__c ingredient = new Ingredient__c();

      Product2 product = new Product2();
      product.Name = key.trim();
      insertedNewProducts.add(product);

      ingredient.Name = recipeName + ': ' + key;
      ingredient.Related_Recipe__c = newrecipe.id;
      ingredient.Product__c = product.id;
      ingredient.Quantity__c = quantity;
      ingredients.add(ingredient);
    }

    System.debug(ingredients);
    System.debug(insertedNewProducts);
    insert insertedNewProducts;
    insert ingredients;

  }
}