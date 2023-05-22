@isTest
private class TestOrderService {
    // Méthode de configuration pour les données de test
    @TestSetup
    static void setupTestData() {
        Integer nbAccounts = 10;  // Mettez ici le nombre de comptes que vous souhaitez créer
        TestDataFactory.createTestAccounts(nbAccounts);
    }

    @isTest
    static void testGetTotalOrderAmount() {
        Test.startTest();
        // Calcule le montant total attendu de toutes les commandes
        Decimal expectedTotalAmount = 0;
        List<Order> allOrders = [SELECT Id FROM Order];
        for (Order order : allOrders) {
            List<OrderItem> orderItems = [SELECT UnitPrice, Quantity FROM OrderItem WHERE OrderId = :order.Id];
            for (OrderItem item : orderItems) {
                expectedTotalAmount += item.UnitPrice * item.Quantity;
            }
        }

        // Appelle la méthode getTotalOrderAmount() et compare le montant total réel au montant total attendu
        Decimal totalOrderAmount = OrderService.getTotalOrderAmount();
        System.assertNotEquals(null, totalOrderAmount, 'Total order amount should not be null');
        System.assertEquals(expectedTotalAmount, totalOrderAmount, 'Total order amount should match expected amount');
        Test.stopTest();
    }


    @isTest
    static void testOrderNetAmount() {
        Test.startTest();
        List<Account> testAccounts = [SELECT Id FROM Account LIMIT 10];
    
        for(Account testAccount : testAccounts){
            Order testOrder = [SELECT Id, ShipmentCost__c, NetAmount__c, TotalAmount FROM Order WHERE AccountId = :testAccount.Id LIMIT 1];

            if (testOrder == null) {
                continue; // skip to the next account if no order is found
            }
            OrderItem testOrderItem = [SELECT UnitPrice, Quantity FROM OrderItem WHERE OrderId = :testOrder.Id LIMIT 1];
            if (testOrderItem == null) {
                continue; // skip to the next account if no order item is found
            }
            Decimal expectedNetAmount = testOrderItem.UnitPrice * testOrderItem.Quantity - testOrder.ShipmentCost__c;
    
            
            OrderService.orderNetAmount(new List<Order>{testOrder});
            update testOrder;
    
            List<Order> updatedOrders = [SELECT NetAmount__c, TotalAmount, ShipmentCost__c FROM Order WHERE Id = :testOrder.Id];
            for(Order updatedOrder : updatedOrders){
                System.assertEquals(expectedNetAmount, updatedOrder.NetAmount__c, 'NetAmount__c is not updated correctly');
            }
            
        }
        Test.stopTest();
    }
    
}
