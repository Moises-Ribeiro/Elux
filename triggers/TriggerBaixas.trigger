trigger TriggerBaixas on Relatorio_FIFO__c (before insert, before update, after insert, after update, after delete) {
    new RelatorioFifoTriggerHandler().run();
}