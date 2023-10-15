import { LightningElement, track } from 'lwc';

export default class AddRecipeForm extends LightningElement {
  currentIndex = 1;
  ObjIdChoice = ''

  @track recipeName = '';
  @track ingredients = [{
    name: '',
    quantity: 1,
    id: 0,
  }];

  handleRecipeNameChange(event) {
    this.recipeName = event.target.value;
  }

  handleIngredientNameChange(event) {
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
    console.log(typeof objId);
    console.log(index);
    this.ingredients[index].name = objId;
    // console.log('You selected a recipe: ' + event.detail.value[0]);
    // console.log('Detail: ' + event.detail);
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
    var currentIngredients = this.ingredients
    this.ingredients = [...currentIngredients, {
      name: '',
      quantity: 1,
      id: this.currentIndex,
    }];
    this.currentIndex++;
  }

  removeIngredients(event) {
    console.log('removing ...')
    const index = event.target.dataset.index;
    console.log(index, '-', this.currentIndex);
    this.ingredients.splice(index, 1);

    // Update id
    for (let i = 0; i < this.ingredients.length; i++) {
      this.ingredients[i].id = i;
    }

    this.currentIndex = this.ingredients.length;
  }

  saveRecipe(event) {
    this.ingredients.forEach((value, i) => {
      console.log('ingredient ' + i, value.name, '-', value.quantity);
    });
    console.log('recipeName: ', this.recipeName);
  }
}