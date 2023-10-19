import { LightningElement, track, api } from 'lwc';
import addRecipeIntoOppApex from '@salesforce/apex/AddRecipeIntoOppController.addRecipeIntoOpp';

export default class AddRecipeIntoOpp extends LightningElement {
  @api recordId;
  @track selectedId;

  handleSuccess(event) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: 'Success',
        message: event.detail.apiName + ' created.',
        variant: 'success',
      })
    );
  }

  handleChoice(event) {
    const objId = event.detail.value[0];
    this.selectedId = objId;
  }

  async addRecipeIntoOppFunc(event) {
    console.log('id: ', this.selectedId);
    console.log('obj id: ', this.recordId);
    await addRecipeIntoOppApex({ recipeId: this.selectedId, oppId: this.recordId }).then(result => {
      // do nothing.
    }).catch(error => {
      console.log(error);
    })
  }
}