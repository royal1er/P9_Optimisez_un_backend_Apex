@isTest(seeAllData=false)
private class TestTeamOrdersController {
    // Méthode de configuration pour les données de test
    @TestSetup
    static void setupTestData() {
        Integer nbAccounts = 1;  // Mettez ici le nombre de comptes que vous souhaitez créer
        TestDataFactory.createTestAccounts(nbAccounts);
    }
    
    
    
    
    @isTest
    static void testTeamOrdersController() {
        Decimal expectedSumOrders = 2000;

        System.assertEquals(expectedSumOrders, TeamOrdersController.getSumOrders(), 'SumOrders should match the expected value');

        List<TeamOrdersController.OrdersBySalesRep> ordersBySalesRepList = TeamOrdersController.getOrdersBySalesRep();
        System.assertEquals(1, ordersBySalesRepList.size(), 'There should be 1 OrdersBySalesRep record');
        System.assertEquals(expectedSumOrders, ordersBySalesRepList[0].Total, 'Total for the SalesRep should match the expected value');
    }
}
