trigger FaultCodeBloqueadoValidacao on Fault_Code_Bloqueado__c (before insert, before update) {
	List<Atribuicao_Fault_Codes__c> faultCodes =  new List<Atribuicao_Fault_Codes__c>();   
	integer iCodigoDefeito;
	integer iSubConjunto;
	String sLinhaProduto;
	
	for (Fault_Code_Bloqueado__c fCB : Trigger.new){
		if (fCB.CodigoDefeito__c  != null && fCB.CodigoSubConjunto__c != null){
			iCodigoDefeito	= fCB.CodigoDefeito__c.intValue();
			iSubConjunto	= fCB.CodigoSubconjunto__c.intValue();
			sLinhaProduto = fCB.Linha_do_Produto__c; 
		}		
		
	}
		
	if (iSubConjunto != null && iCodigoDefeito != null){			
		faultCodes = [select Linha_de_Servico__r.Name,
							 Instalacao__c,
		                     Fault_Code__r.Descricao_do_Defeito__c,
		                     Sub_Conjunto_Fault_Code__r.Descricao_Sub_Conjunto__c
		                from Atribuicao_Fault_Codes__c
		               where Fault_Code__r.Name = :iCodigoDefeito.format() 
		                 and Sub_Conjunto_Fault_Code__r.Name = :iSubConjunto.format()
		                 and Linha__c = :sLinhaProduto];		
		System.debug('Linha do produto = '+sLinhaProduto);
	}
	//Se nenhum registro é retornado a mensagem de erro é exibida
	if (faultCodes.size() == 0){
		for (Fault_Code_Bloqueado__c fCB : Trigger.new){
	   		fCB.addError(' Combinação de Sub-Conjunto e Defeito é inválida');
		}
				
	//OS é atualizada com valores de linha de serviço e descrições   
	} else {
		
		for (Fault_Code_Bloqueado__c fCB : Trigger.new){
			fCB.DescricaoDefeito__c 		= faultCodes[0].Fault_Code__r.Descricao_do_Defeito__c;
		   	fCB.DescricaoSubConjunto__c 	= faultCodes[0].Sub_Conjunto_Fault_Code__r.Descricao_Sub_Conjunto__c;
		}	   	
			
	}


}