/**
 * @author: Eduardo Ribeiro de Carvalho - ercarval
 */
trigger EventConsumer on Queue__c (before insert, before update, after insert, after update) {
    new EventQueueTH().run();
}