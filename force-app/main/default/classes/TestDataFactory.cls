public class TestDataFactory {
    public static List<Account> createTestAccounts(Integer nbAccounts) {
        Test.startTest();
        List<Account> accounts = new List<Account>();
        Product2 testProduct = createTestProduct('Test Product');
        PricebookEntry testPricebookEntry = createTestPricebookEntry(testProduct.Id, 200.00);
    
        for (Integer i = 0; i < nbAccounts; i++) {
            Account testAccount = new Account(
                Name = 'Test Account ' + i,
                Website = 'https://allebemathys.com/',
                Industry = 'Technology'
            );
    
            accounts.add(testAccount);
        }
    
        insert accounts;
        
        List<Order> orders = new List<Order>();
        List<OrderItem> orderItems = new List<OrderItem>();
    
        for (Account acc : accounts) {
            Order testOrder = new Order(
                AccountId = acc.Id, 
                Status = 'Ordered', 
                Pricebook2Id = testPricebookEntry.Pricebook2Id, 
                EffectiveDate = Date.today(), 
                ShipmentCost__c = 10.0,  // Remplacez par la valeur par défaut que vous voulez
                NetAmount__c = 0.0  // Remplacez par la valeur par défaut que vous voulez
            );
            orders.add(testOrder);
            
            // Vous ne pouvez pas créer de OrderItems ici car vous devez d'abord insérer les Orders pour obtenir leurs Ids
            // Nous allons donc créer les OrderItems après avoir inséré les Orders.
        }
        
        insert orders;
        
        for (Order ord : orders) {
            OrderItem testOrderItem = new OrderItem(OrderId = ord.Id, PricebookEntryId = testPricebookEntry.Id, UnitPrice = 200, Quantity = 1);
            orderItems.add(testOrderItem);
        }
        
        insert orderItems;
        
        Test.stopTest();
        return accounts;
    }
    
    
    

    public static Order createTestOrder(Id accountId, String status, Id pricebookId) {
        Order testOrder = new Order(
            AccountId = accountId, 
            Status = status, 
            Pricebook2Id = pricebookId, 
            EffectiveDate = Date.today(), 
            ShipmentCost__c = 10.0,  // Remplacez par la valeur par défaut que vous voulez
            NetAmount__c = 0.0  // Remplacez par la valeur par défaut que vous voulez
        );
        insert testOrder;
        return testOrder;
    }
    

    public static OrderItem createTestOrderItem(Id orderId, Id pricebookEntryId, Decimal unitPrice, Decimal quantity) {
        OrderItem testOrderItem = new OrderItem(OrderId = orderId, PricebookEntryId = pricebookEntryId, UnitPrice = unitPrice, Quantity = quantity);
        insert testOrderItem;
        return testOrderItem;
    }

    
    public static Id getStandardPricebookId() {
        return Test.getStandardPricebookId();
    }    
    

    public static PricebookEntry createTestPricebookEntry(Id productId, Decimal unitPrice) {
        // Get the standard Pricebook Id
        Id standardPricebookId = getStandardPricebookId();
    
        // Create a PricebookEntry in the standard Pricebook for the product
        PricebookEntry standardPricebookEntry = new PricebookEntry(Pricebook2Id = standardPricebookId, Product2Id = productId, UnitPrice = unitPrice, IsActive = true);
        insert standardPricebookEntry;
    
        return standardPricebookEntry;
    }

    public static Product2 createTestProduct(String name) {
        Product2 testProduct = new Product2(Name = name, IsActive = true);
        insert testProduct;
        return testProduct;
    }
}
