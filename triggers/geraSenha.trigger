trigger geraSenha on Contact (before insert, before update) {
	String sSenha = '',sPadrao = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMOPQRSTUVWXYZ1234567890';
   	Integer i,j;

   	for (Contact C : trigger.new) {
    	sSenha = '';
      	if (C.Acesso_informativo__c == True){
          	for (i = 0;i < 8;i++){
               	j = Integer.valueOf(Math.round(Math.random()*60));
               	sSenha = sSenha + sPadrao.substring(j,j+1);
          	}
          	C.Senha_Informativo__c = sSenha;
          
          	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
          	String[] toAddresses = new String[] {C.Email}; 
          	mail.setToAddresses(toAddresses);
          	mail.setSenderDisplayName('Electrolux Brasil');
          	mail.setSubject('Sua senha para acesso ao informativo');
          	mail.setPlainTextBody('Sua senha para acesso ao informativo é ' + sSenha);
          	try {
             	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
          	}
          	catch (Exception e){
             	C.addError(' Insira um endereço de e-mail válido.');
          	}
      	}
   	}
}