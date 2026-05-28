trigger AtualizaControleHistoricoBaixa on Historico_de_Baixa__c (before insert, before update) {
	Integer a = 0;
	for(Historico_de_Baixa__c h : trigger.new){
		String controle = '';
		if(trigger.isInsert){
			a++;
			controle = a+'_'+h.Saldo_Consumido__c;//+;
			h.Controle_Registro__c = controle;
		}else{
			controle = h.Name+'_'+h.Saldo_Consumido__c;//+;
			System.debug('Controle composto = '+controle);
			h.Controle_Registro__c = controle;	
		}		
	}
}