trigger OpportunityTrigger on Opportunity(
  before insert,
  before update,
  before delete,
  after insert,
  after update,
  after delete
) {
  System.debug('OpportunityTrigger before - Limit: ' +Limits.getQueries() +'/' +Limits.getLimitQueries());
  new OpportunityTriggerHandler().run();
  System.debug('OpportunityTrigger after - Limit: ' +Limits.getQueries() +'/' +Limits.getLimitQueries());
}