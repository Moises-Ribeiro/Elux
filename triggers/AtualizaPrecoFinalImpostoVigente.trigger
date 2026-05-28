/**
 * Atualiza os preços finais dos produtos caso PIS ou COFINS sejam alteradas.
 * Ricardo Bueno - 09/08/2013
 * Ajustes Ricardo Bueno - Garantia Estendida - 23/07/2014
 * Ajustes Vinicius Ferraz - Alterado de 18 para 12 em PR importados - 13/04/2015
 */
 
trigger AtualizaPrecoFinalImpostoVigente on Imposto_Vigente__c (after insert, after update) 
{
  Boolean executarBatch = false;
  
  if (trigger.isUpdate)
  {
    /** Se alguma alíquota foi alterada, executar o batch. **/
    for (Imposto_Vigente__c imp : trigger.new)
    {
      Imposto_Vigente__c impOld = trigger.oldMap.get(imp.Id);
      
      if (imp.COFINS__c != impOld.COFINS__c || imp.PIS__c != impOld.PIS__c)
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
  
  /** executar o batch se as condições anteriores forem atendidas. **/
  //if (executarBatch)
  //{
  //  CalculaPrecoFinalDeleteBatch batch = new CalculaPrecoFinalDeleteBatch();
  //  batch.CalcularTudo = true;
  //  Database.executeBatch(batch);
  //}
}