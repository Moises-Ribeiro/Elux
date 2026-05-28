/******************************************************************************************************
* Antes de gravar Conta Resumida deve resgatar os dados de lgpd do objeto PreConta
*******************************************************************************************************/
trigger PreContaResumida on Lead (before insert) {
   System.debug('__[trg PreContaResumida - Lead] ..START..');

    if(trigger.isBefore) {

        if(trigger.isInsert){
            for(Lead lead : trigger.new){
                //lgpd Wilson Paulino - 26082020 - Ini
                if((lead.CPF__c != null) && (lead.CPF__c !='')){
                    String  lsCpfCnpj = lead.CPF__c;
                    lsCpfCnpj = lsCpfCnpj.replaceAll('[^a-zA-Z0-9]', '');
                    List<PreConta__c> lListSelect = WSAccountConsent.SelecionaPreConta(lsCpfCnpj);
     
                    if(lListSelect.Size() > 0 ){
                        for (PreConta__c varFor : lListSelect){
                            lead.Termo_Consentimento__c = varFor.Termo_Consentimento__c;
                            lead.Ura_Identificacao__c = varFor.Ura_Identificacao__c;
                            lead.Canal_Consentimento__c = varFor.Canal_Consentimento__c;
                        }
                    }
                }
            }
        }
    }
     System.debug('__[trg PreContaResumida - Lead] ..END..');

}