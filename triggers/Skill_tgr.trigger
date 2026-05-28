trigger Skill_tgr on Skill__c(
  before insert,
  before update,
  before delete,
  after insert,
  after update,
  after delete,
  after undelete
) {
  new SkillTriggerHandler().run();
}