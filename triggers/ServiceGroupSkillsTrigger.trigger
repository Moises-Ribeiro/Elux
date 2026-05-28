trigger ServiceGroupSkillsTrigger on Service_Group_Skills__c(
  before insert,
  before update,
  before delete,
  after insert,
  after update,
  after delete,
  after undelete
) {
  new ServiceGroupSkillsTriggerHandler().run();
}