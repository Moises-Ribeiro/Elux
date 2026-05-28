trigger InstalledProductTrigger on Installed_Product__c(
  before insert,
  before update,
  after insert,
  after update,
  before delete,
  after delete
) {
  new InstalledProductTriggerHandler().run();
}