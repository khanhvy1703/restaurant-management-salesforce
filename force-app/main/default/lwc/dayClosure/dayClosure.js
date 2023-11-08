import { LightningElement, wire } from 'lwc';
import getSalesInfo from '@salesforce/apex/DayClosureController.getSalesInfo';

export default class DayClosureLWC extends LightningElement {
  salesInfo;
  amount = 0;
  penny = 0;
  nickel = 0;
  dime = 0;
  quarter = 0;
  one = 0;
  two = 0;
  five = 0;
  ten = 0;
  twenty = 0;
  fifty = 0;
  hundred = 0;
  card = 0;
  result = '';
  isShown = false;

  handleAmountChange(event) {
    console.log("changing...");
    var inputValue = parseFloat(event.target.value) || 0;
    var inputName = event.target.name;
    console.log(inputValue);
    console.log(inputName);
    console.log(event.target.defaultValue);

    switch (inputName) {
      case "penny_input":
        this.amount = this.amount - (this.penny * 0.01) + (inputValue * 0.01);
        this.penny = inputValue;
        break;
      case "nickel_input":
        this.amount = this.amount - (this.nickel * 0.05) + (inputValue * 0.05);
        this.nickel = inputValue;
        break;
      case "dime_input":
        this.amount = this.amount - (this.dime * 0.1) + (inputValue * 0.1);
        this.dime = inputValue;
        break;
      case "quarter_input":
        this.amount = this.amount - (this.quarter * 0.25) + (inputValue * 0.25);
        this.quarter = inputValue;
        break;
      case "one_input":
        this.amount = this.amount - (this.one * 1) + (inputValue * 1);
        this.one = inputValue;
        break;
      case "two_input":
        this.amount = this.amount - (this.two * 2) + (inputValue * 2);
        this.two = inputValue;
        break;
      case "five_input":
        this.amount = this.amount - (this.five * 5) + (inputValue * 5);
        this.five = inputValue;
        break;
      case "ten_input":
        this.amount = this.amount - (this.ten * 10) + (inputValue * 10);
        this.ten = inputValue;
        break;
      case "twenty_input":
        this.amount = this.amount - (this.twenty * 20) + (inputValue * 20);
        this.twenty = inputValue;
        break;
      case "fifty_input":
        this.amount = this.amount - (this.fifty * 50) + (inputValue * 50);
        this.fifty = inputValue;
        break;
      case "hundred_input":
        this.amount = this.amount - (this.hundred * 100) + (inputValue * 100);
        this.hundred = inputValue;
        break;
      case "card_input":
        this.amount = this.amount - (this.card * 1) + (inputValue * 1);
        this.card = inputValue;
        break;
      default:
        break;
    }
    this.amount = parseFloat(this.amount).toFixed(2);
  }

  handleCheck(event) {
    this.isShown = true;
    if (this.amount > this.salesInfo.expectedAmount) {
      this.result = 'We have discovered that there is more cash in the register than expected based on our total sales.' +
        'We will taken steps to review the transactions, and double - check the counts.'
    } else if (this.amount < this.salesInfo.expectedAmount) {
      this.result = 'We have discovered that there is less cash in the register than expected based on our total sales.' +
                    'We will taken steps to review the transactions, and double - check the counts.'
    } else {
      this.result = 'The amount in the cashier is the same the expected amount.'
    }
  }

  @wire(getSalesInfo)
  wiredSalesInfo({ error, data }) {
    if (data) {
      this.salesInfo = data;
    } else if (error) {
      console.log('Error loading sales info: ' + error.body.message);
    }
  }
}