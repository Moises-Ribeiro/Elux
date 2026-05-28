trigger DSAP_Product2_trg on Product2 (
	before insert, 
	before update, 
	before delete, 
	after insert, 
	after update, 	 
	after undelete) {
	new Product2TriggerHandler().run();
}