trigger AtividadePRMTrigger on Atividades_PRM__c (  
  before insert,
  before update,
  before delete,
  after insert,
  after update,
  after delete) {
    System.debug('AtividadePRMTrigger before - Limit: ' + Limits.getQueries() +'/' + Limits.getLimitQueries());
    new AtividadePRMTriggerHandler().run();
    System.debug('AtividadePRMTrigger after - Limit: ' + Limits.getQueries() +'/' + Limits.getLimitQueries());
}