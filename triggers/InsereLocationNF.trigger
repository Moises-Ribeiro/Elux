trigger InsereLocationNF on Pedido_x_Nota_Fiscal__c(before insert,before update) {
  /* Logica alterada para o DSAP_NotasFiscais_ws
  Set<Id> opportunityIds = new Set<Id>();
  for (Pedido_x_Nota_Fiscal__c p : Trigger.new){
    opportunityIds.add(p.Pedido__c);
  }
  Map<Id, Opportunity> opportunityById = new Map<Id, Opportunity>([
      SELECT Id, Local_de_Envio_DSM__r.Name, AccountId
      FROM Opportunity
      WHERE Id IN :opportunityIds]);

  Map<Id, Nota_Fiscal__c> nfById = new Map<Id, Nota_Fiscal__c>();
  for (Pedido_x_Nota_Fiscal__c p : Trigger.new) {
    Opportunity opp = opportunityById.get(p.Pedido__c);
    if (opp == null){continue;}
    String localEnvio = opp?.Local_de_Envio_DSM__r?.Name;
    Nota_Fiscal__c nf = new Nota_Fiscal__c(
      Id = p.Numero_Nota_Fiscal__c,
      Local_de_Envio__c = localEnvio,
      Conta__c = opp.AccountId);
    nfById.put(nf.Id, nf);
  }
  if (!nfById.isEmpty()) {
	  List<Database.SaveResult> srs = database.update(nfById.values(), false);
	  DSAP_AdminLogServices_cls.criarLog(srs, nfById.values(), Datetime.now(), 'InsereLocationNF');
  }
  */
}