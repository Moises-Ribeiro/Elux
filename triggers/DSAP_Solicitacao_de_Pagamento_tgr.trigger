trigger DSAP_Solicitacao_de_Pagamento_tgr on Solicitacao_de_Pagamento__c (before insert, before update, after update) {
   if(trigger.isBefore && trigger.isUpdate){
    	DSAP_SolitPagTo_cls.fillsUniqueField(trigger.new);
    }else if(trigger.isBefore && trigger.isInsert){
    	DSAP_SolitPagTo_cls.fillsUniqueField(trigger.new);
    }else if(trigger.isAfter && trigger.isUpdate){
    	DSAP_SolitPagTo_cls.PAGValidas(trigger.new, trigger.oldMap);
    }
}