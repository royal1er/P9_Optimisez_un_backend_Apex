import { LightningElement, wire, track } from 'lwc';
import getTeamOrders from '@salesforce/apex/TeamOrdersController.getTeamOrders';

export default class MyTeamOrders extends LightningElement {
    @track getSumOrders;
    @track getOrdersBySalesRep;
    columns = [
        { label: 'Sales Rep', fieldName: 'SalesRep', type: 'text' },
        { label: 'Total Amount', fieldName: 'Total', type: 'currency' },
    ];

    @wire(getTeamOrders)
    wiredTeamOrders({ error, data }) {
        if (data) {
            this.getSumOrders = data.SumOrders;
            this.getOrdersBySalesRep = data.OrdersBySalesRep;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.getSumOrders = undefined;
            this.getOrdersBySalesRep = undefined;
        }
    }
}
