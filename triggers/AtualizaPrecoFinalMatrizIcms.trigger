/**
 * Caso as alíquotas de ICMS sejam alteradas, recalcular preços finais dos produtos.
 * Ricardo Bueno - 09/08/2013
 * Ajustes Ricardo Bueno - Garantia Estendida - 23/07/2014
 * Ajustes Vinicius Ferraz - Alterado de 18 para 12 em PR importados - 13/04/2015
 */

trigger AtualizaPrecoFinalMatrizIcms on Matriz_de_ICMS__c (after insert, after update) 
{
  Boolean executarBatch = false;
  
  if (trigger.isUpdate)
  {
    /** Se alguma alíquota foi alterada, executar o batch. **/
    for (Matriz_de_ICMS__c icms : trigger.new)
    {
      Matriz_de_ICMS__c icmsOld = trigger.oldMap.get(icms.Id);
      
      if (icms.Aliquota_de_ICMS__c != icmsOld.Aliquota_de_ICMS__c)
      {
        /** marcar para executar e sair..**/
        executarBatch = true;
        break;
      }
    }
  }
  else
  {
    /** se uma nova alíquota foi inserida, sempre executar o batch. **/
    executarBatch = true;
  }  
  
  /** executar o batch se as condições anteriores foram atendidas. **/
  //if (executarBatch)
  //{
  //  CalculaPrecoFinalDeleteBatch batch = new CalculaPrecoFinalDeleteBatch();
  //  batch.CalcularTudo = true;
  //  Database.executeBatch(batch);
  //}
}