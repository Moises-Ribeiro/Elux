/********************************************************************************************************
* Atribui conta e proprietário para as Notas Fiscais                                                    *
*                                                                                                       *
*                                                                                                       *
* #01   Dejair Medeiros         15/01/2010      Criação da trigger
* #02   Flavio Candian          23/03/2010      Alteração conforme release 00434/2010           *
* #03   Rodrigo FRancis         07/06/2017      alterado o parametro do select para buscar pelo codigosoldto *
/*******************************************************************************************************/
 

trigger AtualizaContaNF on Nota_Fiscal__c (before insert) {

    Id idConta;
    // Mudanca Tipo de dado 
    String an8;
    Id idUsuario;
    Set<String> an8s = new Set<String>();
    for ( Nota_Fiscal__c nf:trigger.new ){
        if (nf.DSAP_CodigoClSoldTo__c != null) {
            an8s.add(nf.DSAP_CodigoClSoldTo__c);
        }        
    }
    if (an8s.isEmpty()) {
        return;
    }
    List<User> users = [select Id,AccountId, AN8_Cliente__c
                              from User 
                              where AN8_Cliente__c =: an8s];
    Map<String, User> userByAN8 = new Map<String, User>();
    for (User user: users) {
        userByAN8.put(user.AN8_Cliente__c, user);
    }
    for ( Nota_Fiscal__c nf:trigger.new ){
        User user = userByAN8.get(nf.DSAP_CodigoClSoldTo__c);
        if (user != null) {
            nf.OwnerId = user.Id;
            nf.Conta__c = user.AccountId;
        }
    }
                             
}