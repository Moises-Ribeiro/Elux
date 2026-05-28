/*  Criado Por Marcelo Resende 02/08/2019 

Classe de teste DSAP_MatrizPecasGarantia_tst  */ 

trigger DSAP_MatrizPecasGarantia_tgr on Item_Matriz_Pecas_Garantia__c (
    before delete) {
        if (Trigger.isBefore) {
            if(trigger.isDelete){
                DSAP_MatrizPecasGarantia_ctr.saveHistory(trigger.old);	
            }	
        }
}