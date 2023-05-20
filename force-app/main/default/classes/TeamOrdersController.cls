public without sharing class TeamOrdersController {
    @AuraEnabled(cacheable=true)
    public static Decimal getSumOrders() {
        AggregateResult groupedResults = [SELECT SUM(TotalAmount) total FROM Order];
        return (Decimal)groupedResults.get('total');
    }

    @AuraEnabled(cacheable=true)
    public static List<OrdersBySalesRep> getOrdersBySalesRep() {
        List<OrdersBySalesRep> ordersBySalesRepsList = new List<OrdersBySalesRep>();
        for (AggregateResult ar : [
            SELECT SUM(TotalAmount) total, Owner.Name salesRep
            FROM Order
            GROUP BY Owner.Name
            ]) {
                ordersBySalesRepsList.add(new OrdersBySalesRep(ar));
        }
        return ordersBySalesRepsList;
    }

    public class OrdersBySalesRep {
        public String SalesRep { get; set; }
        public Decimal Total { get; set; }

        public OrdersBySalesRep(AggregateResult ar) {
            SalesRep = (String)ar.get('salesRep');
            Total = (Decimal)ar.get('total');
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getTeamOrders() {
        Map<String, Object> result = new Map<String, Object>();
        result.put('SumOrders', getSumOrders());
        result.put('OrdersBySalesRep', getOrdersBySalesRep());
        return result;
    }
}
