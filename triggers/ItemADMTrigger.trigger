/**
 * File Name : ItemADMTrigger.trigger
 *
 * @author Wipro Technologies
 * @since 16/05/2016
 * @version 1.0
 *
 * Project : Electrolux Brasil
 * Description : Trigger for the object ADM__c
 *
 * Change Control.
 * -------------------------------------
 * Version   Date          Author                         Description
 * -------   ----------    --------------------           ---------------
 * 1.0       16/05/2016    Guilherme Nichetti             Trigger created
 */
trigger ItemADMTrigger on Item_ADM__c(
  before insert,
  before update,
  before delete,
  after insert,
  after update,
  after delete,
  after undelete
) {
  new ItemADMTriggerHandler().run();
}