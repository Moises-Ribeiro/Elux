trigger ValidaPesoPorPrioridade on PesoPorPrioridade__c (before insert, before update) {
    
    for(PesoPorPrioridade__c ppp: trigger.new){
        ppp.Unique__c = ppp.Prioridade__c + '-' + RecordTypeDAO.getInstance().getName(ppp.RecordTypeId);
        
        if(trigger.isUpdate ){           
            
            if(Datetime.now().time() >  Time.newInstance(7, 30, 0, 00) && Datetime.now().time() < Time.newInstance(22, 00, 0, 00) && !Test.isRunningTest()){
               
               ppp.addError(' Edições não podem realizadas entre 7:30 e 22:00');                     
                
            } 
        }
    }
    
}