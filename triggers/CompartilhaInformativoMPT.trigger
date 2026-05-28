/********************************************************************************************************
* Trigger que faz o compartilhamento do Informativo MPT com o SAE proprietário							*
* 																										*
* #01	Fabricio Carrico		09/09/2010			Criação da trigger		    						*
/*******************************************************************************************************/
 
trigger CompartilhaInformativoMPT on Informativo_MPT__c (before insert, before update) {
	
	Set<String> sAN8 = new Set<String>();
	
	for(Informativo_MPT__c oInfoMPT:Trigger.new){	
		sAN8.add(oInfoMPT.AN8__c);
		System.debug('>>> AN8 Informado - ' +oInfoMPT.AN8__c);
	}
	
	List<User> lUsers = [Select Id,
								AN8_Cliente__c,
								Contact.AccountId
					 	   from User
						  where AN8_Cliente__c in :sAN8];
						  
	System.debug('>>> Quantidade de registros listados - ' +lUsers.size());
	
	//Mudanca tipo de dado an8 JulioMoreno Avanxo
	Map<String,User> mUsers = new Map<String,User>();
	
	//Carrega o MAP utilizando o AN8 como chave 
	
	
	for(Integer i=0; i < lUsers.size(); i++){
		 mUsers.put(lUsers.get(i).AN8_Cliente__c, lUsers.get(i));	
	}
	
	//Compartilha o Informativo com a conta localizada
	for(Informativo_MPT__c oInfoMPT:Trigger.new){
		try{
		    //Mudanca tipo de dado an8 JulioMoreno Avanxo
			String sAN8Fornec	= oInfoMPT.AN8__c;
			oInfoMPT.OwnerId	= mUsers.get(sAN8Fornec).Id;
			oInfoMPT.Conta__c	= mUsers.get(sAN8Fornec).Contact.AccountId;
			
			System.debug('>>> AN8 na busca do usuario - ' +sAN8Fornec);

		}catch(Exception e){
			System.debug('>>> ERRO: Não foi possivel atribuir o proprietário no informativo');
		}				
	}
}