public class AccountService {
    public static void updateAccountRevenue(List<Order> orders) {
        Set<Id> accountIds = new Set<Id>();
        for (Order order : orders) {
            if (order.AccountId != null) {
                accountIds.add(order.AccountId);
            }
        }
    
        Map<Id, Decimal> accountToTotalAmount = new Map<Id, Decimal>();
        for (AggregateResult result : [
            SELECT AccountId, SUM(TotalAmount) somme
            FROM Order 
            WHERE AccountId IN :accountIds AND AccountId != null
            GROUP BY AccountId
        ]) {
            Id accountId = (Id)result.get('AccountId');
            Decimal amount = (Decimal)result.get('somme');
            if (accountId != null && amount != null) {
                accountToTotalAmount.put(accountId, amount);
            }
        }
        
        List<Account> accountsToUpdate = [SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Id IN :accountIds];
        for (Account acc : accountsToUpdate) {
            Decimal amount = accountToTotalAmount.get(acc.Id);
            if (amount != null) {
                acc.Chiffre_d_affaire__c = (acc.Chiffre_d_affaire__c != null) ? acc.Chiffre_d_affaire__c + amount : amount;
            }
        }
        update accountsToUpdate;
    }
    
    
    
       public static void updateAccount(Map<Id, SObject> oldOrderMap, List<SObject> newOrders) {
        List<Id> orderIds = new List<Id>();
        for (SObject obj : newOrders) {
            Order ord = (Order) obj;
            orderIds.add(ord.Id);
        }
        
        Map<Id, OrderItem> oldOrderItems = getOrderItemsById(orderIds);
        Map<Id, OrderItem> newOrderItems = getOrderItemsById(orderIds);
        
        for (SObject obj : newOrders) {
            Order newOrder = (Order) obj;
            Order oldOrder = (Order) oldOrderMap.get(newOrder.Id);
            
            OrderItem newOrderItem = newOrderItems.get(newOrder.Id);
            OrderItem oldOrderItem = oldOrderItems.get(oldOrder.Id);
            
            if (oldOrderItem != null && newOrderItem != null) {
                Decimal oldTotalAmount = oldOrderItem.UnitPrice * oldOrderItem.Quantity;
                Decimal newTotalAmount = newOrderItem.UnitPrice * newOrderItem.Quantity;
                
                Decimal amountDifference = newTotalAmount - oldTotalAmount;
                
                if (amountDifference != 0) {
                    Account acc = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :newOrder.AccountId];
                    acc.Chiffre_d_affaire__c += amountDifference;
                    update acc;
                }
            }
        }
    }
    
    
    public static Map<Id, OrderItem> getOrderItemsById(List<Id> orderItemIds) {
        Map<Id, OrderItem> orderItems = new Map<Id, OrderItem>([SELECT Id, OrderId, UnitPrice, Quantity FROM OrderItem WHERE Id IN :orderItemIds]);
        return orderItems;
    }
       
    
    
}
