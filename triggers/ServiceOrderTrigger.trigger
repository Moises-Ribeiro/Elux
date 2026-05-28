trigger ServiceOrderTrigger on Service_Order__c(
  before insert,
  before update,
  after insert,
  after update
) {
  try {
    new ServiceOrderTriggerHandler().run();
  } catch (TriggerHandler.TriggerHandlerException the) {
    System.debug(
      'ServiceOrderTrigger: Loop recursion exception in ServiceOrderTriggerHandler: ' +
      the.toString()
    );
  }

}