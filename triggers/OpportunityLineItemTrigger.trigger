trigger OpportunityLineItemTrigger on OpportunityLineItem(
  before insert,
  before update,
  before delete,
  after insert,
  after update,
  after delete
) {
  System.debug('OpportunityLineItemTrigger before - Limit: ' +Limits.getQueries() + '/' + Limits.getLimitQueries() );
  new OpportunityLineItemTriggerHandler().run();
  System.debug('OpportunityLineItemTrigger after - Limit: ' + Limits.getQueries() + '/' + Limits.getLimitQueries() );
}