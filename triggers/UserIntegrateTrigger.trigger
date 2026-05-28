//LUNA
trigger UserIntegrateTrigger on User (after update) {
    List<User> users = Trigger.new;
    List<id> userIds = new List<id>();
    Map<id, id> userAccount = new Map<id, id>();
    

    for(User u: users){
        userIds.add(u.Id);
    }
        
	List<Account> backoffice = [Select Id, Name, backoffice__c from Account Where backoffice__c IN: userIds];
    List<Account> consultor = [Select Id, Name, Consultor_de_Servicos__c from Account Where Consultor_de_Servicos__c IN: userIds];
   
    for(User u: users){
        for(Account bckOffice : backoffice){
            if(bckOffice.backoffice__c == u.Id){
        		userAccount.put(u.id, bckOffice.id);
            }
    	}    
        for(Account consul : consultor){
            if(consul.Consultor_de_Servicos__c == u.id){
            	userAccount.put(u.id, consul.id);
            }
        }
    }
    
    if(userAccount.size() > 0){
        Database.executeBatch(new UserIntegrateBatch(userAccount), 40); // Calling batch class.
    }
    
  //  for(id key : userAccount.keySet()){
    //    UserIntegrateWrapper.getResource(key);
    //}
    /* for (User u:users){

            for (Account b:backoffice){
                UserIntegrateWrapper.getResource(u.Id);
            }
            for (Account c:consultor){
                UserIntegrateWrapper.getResource(u.Id);
            }
    } */
}