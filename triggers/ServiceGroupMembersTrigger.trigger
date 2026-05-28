trigger ServiceGroupMembersTrigger on Service_Group_Members__c (before insert, before update,after insert, after update, before delete, after delete) {
	new ServiceGroupMembersTriggerHandler().run();
}