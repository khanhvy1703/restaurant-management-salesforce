import addNewRecipe from '@salesforce/apex/AddRecipeController.addNewRecipe';
import summaryApex from '@salesforce/apex/AddRecipeController.summary';
import getIngredientsApex from '@salesforce/apex/AddRecipeController.getIngredients';
import getRecipeNameApex from '@salesforce/apex/AddRecipeController.getRecipeName';
import updateRecipeApex from '@salesforce/apex/AddRecipeController.updateRecipe';
import { LightningElement, track } from 'lwc';

export default class AddRecipeForm extends LightningElement {
  currentIndex = 1;
  confirmation = '';
  summaryIngredient = [];
  isUpdate = false;
  showAddIngredient = false;
  editRecipeName = '';

  @track recipeName = '';
  @track ingredients = [{
    name: '',
    quantity: 1,
    isProduct: true,
    isRecipe: false,
    id: 0,
    index: this.currentIndex,
  }];
  @track isShowModal = false;
  @track editRecipeId = '';

  get labelText() {
    return this.isUpdate ? 'Updating Recipe' : 'Adding New Recipe';
  }

  get RecipeNameShow() {
    return this.isUpdate ? this.editRecipeName : this.recipeName;
  }

  hideModalBox() {
    this.isShowModal = false;
  }

  handleRecipeNameChange(event) {
    this.recipeName = event.target.value;
  }

  handleIsProductChange(event) {
    const index = event.target.dataset.index;
    console.log(index, '-', event.target.checked, '-', this.currentIndex);
    this.ingredients[index].isProduct = event.target.checked;
    this.ingredients[index].isRecipe = !event.target.checked;
  }

  handleIsRecipeChange(event) {
    const index = event.target.dataset.index;
    console.log(index, '-', event.target.checked, '-', this.currentIndex);
    this.ingredients[index].isRecipe = event.target.checked;
    this.ingredients[index].isProduct = !event.target.checked;
  }

  handleNewProductSelected(event) {
    const index = event.target.dataset.index;
    console.log(index, '-', event.target.checked, '-', this.currentIndex);
    this.ingredients[index].isProduct = !event.target.checked;
    this.ingredients[index].isRecipe = !event.target.checked;
  }

  handleNewProductNameChange(event) {
    const index = event.target.dataset.index;
    console.log(index, '-', event.target.value, '-', this.currentIndex);
    this.ingredients[index].name = event.target.value;
  }

  handleQuantityChange(event) {
    const index = event.target.dataset.index;
    console.log(index, '-', event.target.value, '-', this.currentIndex);
    this.ingredients[index].quantity = event.target.value;
  }

  handleQuantityChangeSummary(event) {
    const indexId = event.target.dataset.index;
    console.log(indexId);
    this.summaryIngredient = this.summaryIngredient.map(value => {
      if (value.productId == indexId) {
        return value.quantity = event.target.value;
      }
    })
    console.log(this.summaryIngredient);
  }

  handleDelete(event) {
    const indexId = event.target.dataset.index;
    this.summaryIngredient = this.summaryIngredient.filter(value => {
      return value.productId != indexId;
    })
  }

  handleRecipeChoice(event) {
    const objId = event.detail.value[0];
    const index = event.target.dataset.index;
    console.log(objId);
    console.log(index);
    console.log(index, '-', event.target.value, '-', this.currentIndex);
    this.ingredients[index].name = objId;
    // console.log('You selected a recipe: ' + event.detail.value[0]);
    // console.log('Detail: ' + event.detail);
  }

  handleProductChoice(event) {
    const objId = event.detail.value[0];
    const index = event.target.dataset.index;
    console.log(objId);
    console.log(index);
    this.ingredients[index].name = objId;
  }

  handleEditingRecipe(event) {
    const objId = event.detail.value[0];
    console.log(objId);
    this.editRecipeId = objId;
  }

  addMoreIngredients(event) {
    var currentIngredients = this.ingredients;
    this.ingredients = [...currentIngredients, {
      name: '',
      quantity: 1,
      id: this.currentIndex,
      isProduct: true,
      isRecipe: false,
      index: this.currentIndex + 1,
    }];
    this.currentIndex++;
  }

  handleAddNewRecipeChoice(event) {
    this.confirmation = '';
    this.showAddIngredient = true;
    this.isUpdate = false;
    this.currentIndex = 1;
    this.ingredients = [{
      name: '',
      quantity: 1,
      isProduct: true,
      isRecipe: false,
      id: 0,
      index: this.currentIndex,
    }];
  }

  async handleEditRecipe(event) {
    this.confirmation = '';
    await getIngredientsApex({ recipeId: this.editRecipeId }).then(result => {
      this.showAddIngredient = true;
      this.isUpdate = true;
      if (result.length != 0) {
        this.ingredients = result;
      } else {
        this.ingredients = [{
          name: '',
          quantity: 1,
          isProduct: true,
          isRecipe: false,
          id: 0,
          index: this.currentIndex,
        }];
      }
      this.currentIndex = this.ingredients.length;
    }).catch(error => {
      console.log('Can not get the ingredients: ', error.body.message);
    })
  }

  async showSummary(event) {
    this.ingredients.forEach((value, i) => {
      console.log('ingredient ' + i, value.name, '-', value.quantity);
    });
    console.log('recipeName: ', this.recipeName);

    const ingredientsToSend = this.ingredients.map(value => {
      return {
        ingredientName: value.name,
        quantity: value.quantity,
        isProduct: value.isProduct,
        isRecipe: value.isRecipe,
      }
    });

    await getRecipeNameApex({ recipeId: this.editRecipeId }).then(result => {
      this.editRecipeName = result;
    }).catch(error => {
      console.log(error);
    });

    await summaryApex({ listOfIngredients: ingredientsToSend }).then(result => {
      this.summaryIngredient = result;
      this.isShowModal = true;
      console.log(this.summaryIngredient);
    }).catch(error => {
      console.log(error);
    })
  }

  
  async saveRecipe(event) {
    await addNewRecipe({ recipeName: this.recipeName, listOfIngredients: this.summaryIngredient }).then(result => {
      this.isShowModal = false;
      this.confirmation = 'Added ' + this.recipeName + ' recipe';
      this.ingredients = this.summaryIngredient.map((value, index) => {
        return {
          name: value.productId,
          quantity: value.quantity,
          isProduct: true,
          isRecipe: false,
          id: index,
          index: index + 1,
        }
      });
      this.currentIndex = this.ingredients.length;
    }).catch(error => {
      console.log(error);
    })
  }

  async updateRecipe(event) {
    
    await updateRecipeApex({ recipeId: this.editRecipeId, editRecipeName: this.editRecipeName, listOfIngredients: this.summaryIngredient }).then(result => {
      this.isShowModal = false;
      this.confirmation = 'Updated ' + this.editRecipeName + ' recipe';
      this.ingredients = this.summaryIngredient.map((value, index) => {
        return {
          name: value.productId,
          quantity: value.quantity,
          isProduct: true,
          isRecipe: false,
          id: index,
          index: index + 1,
        }
      });
      this.currentIndex = this.ingredients.length;
    }).catch(error => {
      console.log(error);
    })
  }
}