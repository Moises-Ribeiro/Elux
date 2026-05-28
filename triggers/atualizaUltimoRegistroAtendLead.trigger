trigger atualizaUltimoRegistroAtendLead on Registro_de_Atendimento__c (before insert) {


    Map<Id, String> TipoReg = new Map<Id, String>();
    
    for(Registro_de_Atendimento__c  reg: trigger.new){    
        TipoReg.put(reg.Nome_do_Contato__c, reg.Tipo__c);              
    }
    
    List<Lead> leads = ([SELECT id FROM Lead WHERE id in: TipoReg.keySet()]);
    
     for(Lead l: leads ){     
         l.TipoRegistroAtendimento__c = TipoReg.get(l.Id);
     }
     
     update leads;
    
}