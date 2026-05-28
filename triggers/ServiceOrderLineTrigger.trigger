/**
 * File Name : ServiceOrderTrigger.trigger
 *
 * @author Wipro Technologies
 * @since 12/04/2016
 * @version 1.1
 *
 * Project : Electrolux Brasil
 * Description : Trigger for the object Service_Order_Line__c
 *
 * Change Control
 * -------------------------------------
 * Version   Date          Author                         Description
 * -------   ----------    --------------------           ---------------
 * 1.0       12/04/2016    Guilherme Nichetti             Trigger created
 * 1.1       27/06/2016    Rodrigo Lara                   Inclusion of BEFORE processing
 */
trigger ServiceOrderLineTrigger on Service_Order_Line__c (before insert,
                                    before update, before delete, after insert, after update, after delete) {
    
    // Instantiate the handler for this trigger
    new ServiceOrderLineItemTriggerHandler().run();

}