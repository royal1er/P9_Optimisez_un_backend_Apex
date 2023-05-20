public class OrderService {
    
    public static Decimal getTotalOrderAmount() {
        AggregateResult groupedResults = [SELECT SUM(TotalAmount) total FROM Order];
        return (Decimal)groupedResults.get('total');
    }

    public static void orderNetAmount(List<Order> newOrders) {
        for (Order newOrder : newOrders) {
            if (newOrder.TotalAmount != null && newOrder.ShipmentCost__c != null) {
                newOrder.NetAmount__c = newOrder.TotalAmount - newOrder.ShipmentCost__c;
            }
        }
    }
    
    
}