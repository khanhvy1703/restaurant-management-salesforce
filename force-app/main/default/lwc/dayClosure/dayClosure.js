import { LightningElement, wire } from 'lwc';
import getSalesInfo from '@salesforce/apex/DayClosureController.getSalesInfo';

export default class DayClosureLWC extends LightningElement {
  salesInfo;

  @wire(getSalesInfo)
  wiredSalesInfo({ error, data }) {
    if (data) {
      this.salesInfo = data;
    } else if (error) {
      console.log('Error loading sales info: ' + error.body.message);
    }
  }
}