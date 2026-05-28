trigger DSAP_Saldo_MPT_trg on Saldo_MPT__c (before insert, before update, after insert, after update, after delete) {
    new SaldoMPTTriggerHandler().run();
}