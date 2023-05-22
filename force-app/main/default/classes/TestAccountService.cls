@isTest
private class TestAccountService {
    // Méthode de configuration pour les données de test
    @TestSetup
    static void setupTestData() {
        Integer nbAccounts = 500; // Nombre de comptes à créer
        TestDataFactory.createTestAccounts(nbAccounts); 
    }
    
    @isTest
    static void testUpdateAccountRevenueBatch() {
        Test.startTest();
        UpdateAccountRevenueBatch batch = new UpdateAccountRevenueBatch();
        Database.executeBatch(batch, 600); 
        Test.stopTest();
        
        Map<Id, Decimal> expectedRevenue = new Map<Id, Decimal>();
        for (Order ord : [SELECT Id, AccountId, TotalAmount FROM Order WHERE Status = 'Ordered']) {
            if (!expectedRevenue.containsKey(ord.AccountId)) {
                expectedRevenue.put(ord.AccountId, 0);
            }
            expectedRevenue.put(ord.AccountId, expectedRevenue.get(ord.AccountId) + ord.TotalAmount);
        }

        for(Account acc : [SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Id IN :expectedRevenue.keySet()]) {
            System.assertEquals(expectedRevenue.get(acc.Id), acc.Chiffre_d_affaire__c, 'Chiffre d\'Affaire should be updated');
        }
    }

    

    @isTest
    static void testUpdateAllAccountsRevenueBatch() {
        Test.startTest();
        UpdateAllAccountsRevenueBatch batch = new UpdateAllAccountsRevenueBatch();
        
        List<Order> ordersToUpdate = [SELECT Id, AccountId, TotalAmount FROM Order WHERE Status = 'Ordered'];
        Set<Id> accountIds = new Set<Id>();
        for(Order ord : ordersToUpdate){
            accountIds.add(ord.AccountId);
        }
        
        AggregateResult initialTotal = [SELECT SUM(Chiffre_d_affaire__c) somme FROM Account WHERE Id IN :accountIds];
        Decimal initialTotalValue = (Decimal)initialTotal.get('somme');
        initialTotalValue = (initialTotalValue == null) ? 0 : initialTotalValue;

        Id batchJobId = Database.executeBatch(batch, 600); // Réduit la taille du lot
        Test.stopTest();
        
        // Récupère la somme totale de Chiffre_d'affaire__c après mise à jour
        AggregateResult postUpdateSum = [SELECT SUM(Chiffre_d_affaire__c) total FROM Account WHERE Id IN :accountIds];
        Decimal postUpdateTotal = (Decimal)postUpdateSum.get('total');
        
        // Calcule la somme attendue de toute les commande liée aux comptes mis à jour et l'additionne à la somme initiale
        AggregateResult expectedSum = [SELECT SUM(TotalAmount) total FROM Order WHERE AccountId IN :accountIds];
        Decimal expectedTotal = initialTotalValue + (Decimal)expectedSum.get('total');
        
        System.assertEquals(expectedTotal, postUpdateTotal, 'Total revenue not updated correctly');
        
    }
}
