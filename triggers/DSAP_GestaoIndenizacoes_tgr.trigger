trigger DSAP_GestaoIndenizacoes_tgr on DSAP_Indenizacoes__c (before insert, before update) {
    
    preecheChave(trigger.new);
    
    public void preecheChave(List<DSAP_Indenizacoes__c> lstIndenizacoes){
    	
    	for(DSAP_Indenizacoes__c item:lstIndenizacoes){
    			item.DSAP_ValidaTipoIndenizacao__c=item.DSAP_Indenizacao__c+item.DSAP_TipoIndenizacao__c;
    	}
    }
    
}