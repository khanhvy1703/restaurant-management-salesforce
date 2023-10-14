import { LightningElement, track } from 'lwc';

export default class AddRecipeForm extends LightningElement {
  currentIndex = 1;

  @track recipeName = '';
  @track ingredients = [{
    name: '',
    quantity: 1,
    Id: 0,
  }];

  handleRecipeNameChange(event) {
    this.recipeName = event.target.value;
  }

  handleIngredientNameChange(event) {
    const index = event.target.dataset.index;
    this.ingredients[index].name = event.target.value;
  }

  handleQuantityChange(event) {
    const index = event.target.dataset.index;
    this.ingredients[index].quantity = event.target.value;
  }

  addMoreIngredients(event) {
    console.log('adding ...')
    this.ingredients.forEach((value, i) => {
      console.log('value ' + i, value);
    });
    this.ingredients.push({
      name: '',
      quantity: 1,
      Id: this.currentIndex,
    });
    currentIndex++;
    
  }

  removeIngredients(event) {
    console.log('removing ...')
    this.ingredients.forEach((value, i) => {
      console.log('value ' + i, value);
    });
    const index = event.target.dataset.index;
    this.ingredients.splice(index, 1);

    // Update Id
    for (let i = 0; i < this.ingredients.length; i++) {
        this.ingredients[i].Id = i;
    }

    this.currentIndex = this.ingredients.length + 1;
  }

  saveRecipe(event) {
    this.ingredients.forEach((value, i) => {
      console.log('value ' + i, value);
    });
    console.log('recipeName: ', this.recipeName);
  }
}