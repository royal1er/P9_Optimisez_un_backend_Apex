@isTest
private class TestAccountService {
    // Méthode de configuration pour les données de test
    @TestSetup
    static void setupTestData() {
        Integer nbAccounts = 1; // Nombre de comptes à créer
        TestDataFactory.createTestAccounts(nbAccounts,40); 
    }
    
    @isTest
    static void testUpdateAccountRevenue() {
        Test.startTest();
        List<Order> orders = [SELECT Id, AccountId, TotalAmount FROM Order];
        Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Id IN (SELECT AccountId FROM Order)]);
        
        AccountService.updateAccountRevenue(orders);
        
        for(Account testAccount : accounts.values()){
            Account updatedAccount = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :testAccount.Id];
            Decimal expectedRevenue = testAccount.Chiffre_d_affaire__c;
            for (Order order : orders) {
                if (order.AccountId == testAccount.Id) {
                    expectedRevenue += order.TotalAmount;
                }
            }
            System.assertEquals(expectedRevenue, updatedAccount.Chiffre_d_affaire__c, 'Chiffre d\'Affaire should be updated correctly');
        }
        Test.stopTest();
    }
    
    

    @isTest
    static void testUpdateAccountRevenueBatch() {
        Test.startTest();
        UpdateAllAccountsRevenueBatch batch = new UpdateAllAccountsRevenueBatch();
        
        // Récupère tous les Orders liés à un Account qui est dans un état 'Ordered'.
        List<Order> ordersToUpdate = new List<Order>([SELECT Id, AccountId, TotalAmount FROM Order WHERE Status = 'Ordered']);
        
        // Exécuter la méthode execute de votre batch avec les orders récupéré, puis exe.
        batch.execute(null, ordersToUpdate);
        
        // Récupère la liste des Accounts qui devraient être mis à jour.
        List<Account> accountsToUpdate = new List<Account>([SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Id IN (SELECT AccountId FROM Order WHERE Status = 'Draft')]);
    
        // Vérifie que chaque Account a été correctement mis à jour.
        for(Account acc : accountsToUpdate) {
            Account updatedAccount = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :acc.Id];
            System.assertEquals(8000, updatedAccount.Chiffre_d_affaire__c, 'Chiffre d\'Affaire should be updated');
        }
    
        Test.stopTest();
    }
    
    
    @isTest
    static void testUpdateAllAccountsRevenueBatch() {
        Test.startTest();
        UpdateAllAccountsRevenueBatch batch = new UpdateAllAccountsRevenueBatch();
        
        List<Order> ordersToUpdate = new List<Order>([SELECT Id, AccountId, TotalAmount FROM Order WHERE Status = 'Ordered']);
        Set<Id> accountIds = new Set<Id>();
        for(Order ord : ordersToUpdate){
            accountIds.add(ord.AccountId);
        }
        
        AggregateResult initialTotal = [SELECT SUM(Chiffre_d_affaire__c) somme FROM Account WHERE Id IN :accountIds];
        Decimal initialTotalValue = (Decimal)initialTotal.get('somme');
        initialTotalValue = (initialTotalValue == null) ? 0 : initialTotalValue;

        batch.execute(null, ordersToUpdate);
        Id batchJobId = Database.executeBatch(batch);
        
        // Récupère la somme totale de Chiffre_d'affaire__c après mise à jour
        AggregateResult postUpdateSum = [SELECT SUM(Chiffre_d_affaire__c) total FROM Account WHERE Id IN :accountIds];
        Decimal postUpdateTotal = (Decimal)postUpdateSum.get('total');
        
        // Calcule la somme attendue de toute les commande liée aux comptes mis à jour et l'additionne à la somme initiale
        AggregateResult expectedSum = [SELECT SUM(TotalAmount) total FROM Order WHERE AccountId IN :accountIds];
        Decimal expectedTotal = initialTotalValue + (Decimal)expectedSum.get('total');
        
        System.assertEquals(expectedTotal, postUpdateTotal, 'Total revenue not updated correctly');
        Test.stopTest();
    }
    
    

}
