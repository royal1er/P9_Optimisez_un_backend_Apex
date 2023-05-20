trigger OrderUpdate on Order (before insert, before update, after insert, after update) {
    if (Trigger.isBefore && Trigger.isUpdate) {
        OrderService.orderNetAmount(Trigger.new);
    }
    
    if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            AccountService.updateAccountRevenue(Trigger.new);
        }
    }
}
