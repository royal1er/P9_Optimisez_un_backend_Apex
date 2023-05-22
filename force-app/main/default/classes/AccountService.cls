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
    
}
