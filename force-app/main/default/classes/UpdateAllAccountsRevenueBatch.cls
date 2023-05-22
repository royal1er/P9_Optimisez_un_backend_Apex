global class UpdateAllAccountsRevenueBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator('SELECT Id, AccountId, TotalAmount FROM Order');
    }

    global void execute(Database.BatchableContext context, List<Order> scope) {
        AccountService.updateAccountRevenue(scope);
    }

    global void finish(Database.BatchableContext info) {
    }
}
