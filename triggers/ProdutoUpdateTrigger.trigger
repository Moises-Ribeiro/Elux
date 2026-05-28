trigger ProdutoUpdateTrigger on Produto_Update_Temp__c (before insert, after insert) {
    new ProdutoUpdateTriggerHandler().run();
    
}