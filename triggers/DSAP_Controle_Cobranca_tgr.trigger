trigger DSAP_Controle_Cobranca_tgr on DSAP_Controle_Cobranca__c (after insert, after update, before insert, before update) {
    System.debug('__[trg DSAP_Controle_Cobranca_tgr - DSAP_Controle_Cobranca__c] ..START..');
    if(trigger.isUpdate && trigger.isAfter){
        DSAP_EnviaSAP_ControleCob_cls.sendToFutureMethod(trigger.new); 
        DSAP_AbonarCredito.seacherIDs(trigger.new);         
    }
    System.debug('__[trg DSAP_Controle_Cobranca_tgr - DSAP_Controle_Cobranca__c] ..END.. ');
 }