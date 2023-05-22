global class UpdateAccountRevenueBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext context) {
        // Requête sur les commandes liées à des comptes avec le statut 'Ordered'
        return Database.getQueryLocator('SELECT Id, AccountId, TotalAmount FROM Order WHERE Status = \'Ordered\'');
    }
    global void execute(Database.BatchableContext context, List<Order> scope) {
        AccountService.updateAccountRevenue(scope);
    }

    global void finish(Database.BatchableContext info) {
    }
}
