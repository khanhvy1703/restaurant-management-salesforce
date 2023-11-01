import addNewRecipe from '@salesforce/apex/AddRecipeController.addNewRecipe';
import { LightningElement, track } from 'lwc';

export default class AddRecipeForm extends LightningElement {
  currentIndex = 1;
  confirmation = '';

  @track recipeName = '';
  @track ingredients = [{
    name: '',
    quantity: 1,
    isProduct: true,
    isRecipe: false,
    isNewProduct: false,
    id: 0,
    index: this.currentIndex,
  }];

  @track isShowModal = false;

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
    this.ingredients[index].isNewProduct = !event.target.checked;
  }

  handleIsRecipeChange(event) {
    const index = event.target.dataset.index;
    console.log(index, '-', event.target.checked, '-', this.currentIndex);
    this.ingredients[index].isRecipe = event.target.checked;
    this.ingredients[index].isProduct = !event.target.checked;
    this.ingredients[index].isNewProduct = !event.target.checked;
  }

  handleNewProductSelected(event) {
    const index = event.target.dataset.index;
    console.log(index, '-', event.target.checked, '-', this.currentIndex);
    this.ingredients[index].isNewProduct = event.target.checked;
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

  handleSuccess(event) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: 'Success',
        message: event.detail.apiName + ' created.',
        variant: 'success',
      })
    );
  }

  addMoreIngredients(event) {
    var currentIngredients = this.ingredients;
    this.ingredients = [...currentIngredients, {
      name: '',
      quantity: 1,
      id: this.currentIndex,
      isProduct: true,
      isRecipe: false,
      isNewProduct: false,
      index: this.currentIndex + 1,
    }];
    this.currentIndex++;
  }

  // removeIngredients(event) {
  //   console.log('removing ...')
  //   const index = event.target.dataset.index;
  //   console.log(index, '-', this.currentIndex);
  //   this.ingredients.splice(index, 1);
  //   // Update id
  //   this.ingredients = this.ingredients
  //     .map((ingredient, i) => ({ ...ingredient, id: i }));
  //   this.currentIndex = this.ingredients.length;
  // }

  async showSummary(event) {
    this.ingredients = this.ingredients.filter(value => {
      return value.name !== '' && value.name !== undefined
    });

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
        isNewProduct: value.isNewProduct,
      }
    });

    this.isShowModal = true;
  }

  
  async saveRecipe(event) {
    this.ingredients = this.ingredients.filter(value => {
      return value.name !== '' && value.name !== undefined
    });

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
        isNewProduct: value.isNewProduct,
      }
    });

    await addNewRecipe({ recipeName: this.recipeName, listOfIngredients: ingredientsToSend }).then(result => {
      this.confirmation = "You successfully add a new recipe."
    }).catch(error => {
      console.log(error);
    })
  }
}