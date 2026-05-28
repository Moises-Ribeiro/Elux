/****************************************************************************************************
* Trigger que flag campo ODC em conta quando um objeto ODC é criado em caso.		    			*
* 												    												*
* #01	Danilo Afonso Zanin		27/07/2010		Criação da trigger		    						*
/***************************************************************************************************/

trigger FlagODCNaConta on ODC__c (after insert) {
	Set<Id> lista_idCasos = new Set<Id>();
	Set<Id> lista_idContas = new Set<Id>();
	List<Account> lista_contas = new List<Account>();
		
	for (ODC__c oODC:trigger.new){
		lista_idCasos.add(oODC.Caso__c);
	}
	
	if(lista_idCasos.size()>0){
		Map<id, Case> lista_casos = new Map<id, Case>([SELECT id, AccountId   
													   FROM Case
                                                       WHERE id in:lista_idCasos]);
                                                       		
		for (ODC__c oODC:trigger.new){ 
			if(lista_casos.get(oODC.Caso__c) != null){  
      			System.debug('>> Eh diferente de null'); 
				Case oCaso = lista_casos.get(oODC.Caso__c);
			
				lista_idContas.add(oCaso.AccountId);
			}
		}
	
		if(lista_idContas.size()>0){
			lista_contas = ([SELECT id, ODC__c   
							 FROM Account
                             WHERE id in:lista_idContas]);
        			
			for(Account oConta : lista_contas){
				oConta.ODC__c = true;
			
				try{
					update oConta;
				}
				catch(Exception e){
					System.debug('>>> Erro ao flegar campo ODC na conta '+oConta.Name);	
				}	
			}	
		}		
	}
}