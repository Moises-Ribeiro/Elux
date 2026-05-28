/**
* Avanxo Colombia
* @author           Oscar angel href=<oangel@avanxo.com>
* Proyect:          Electrolux Brasil
* Description:      Trigger Clone AtualizaCustoDetalheNota
*
* Changes (Version)
* -------------------------------------
*           No.     Fecha           Autor                   Descripción
*           -----   ----------      --------------------    ---------------
* @version   1.0    2015-01-15      Oscar Angel (OA)        Creation Trigger
*************************************************************************************************************/

trigger AtualizaCustoDetalheNota_DSM on Detalhe_de_Nota_Fiscal__c (before insert, before update) {

	Set<String> item = new Set<String>();
	Set<Id> idNF = new Set<Id>();
	Set<String> idExterno = new Set<String>();
	Map<Id,String> notaLocation = new Map<Id,String>();
	Map<Id,String> itemLocation = new Map<Id,String>();
	Map<String,Double> itemCusto = new Map<String,Double>();
	Double custo;
	Double custoLinha;
	String chave;
	List<Nota_Fiscal__c> nf = new List<Nota_Fiscal__c>();
	List<Product_Stock__c> stock = new List<Product_Stock__c>();
	
		for (Detalhe_de_Nota_Fiscal__c linha:trigger.new) {
			item.add(linha.Name);
			idNF.add(linha.Nota_Fiscal__c);
		}
	       	     
	    nf = [Select Id, Local_de_Envio__c
	            from Nota_Fiscal__c
	           where Id in :idNF];
			
	    for (Nota_Fiscal__c n:nf){
	    	notaLocation.put(n.Id,n.Local_de_Envio__c);
	    }
	    
	 	for (Detalhe_de_Nota_Fiscal__c linha:trigger.new) {
	 		itemLocation.put(linha.Id,notaLocation.get(linha.Nota_Fiscal__c)+linha.Name);
	 		idExterno.add(notaLocation.get(linha.Nota_Fiscal__c)+linha.Name);
		}   
		
		/* OA: 02-02-2017 uso diferente do product stock
		stock = [Select Id_externo_JDE__c, 
		                Product_Cost__c 
		           from Product_Stock__c
		          where Id_externo_JDE__c in :idExterno];
		            
		for (Product_Stock__c s:stock){
			itemCusto.put(s.Id_externo_JDE__c,s.Product_Cost__c);
		}
		
		for (Detalhe_de_Nota_Fiscal__c linha:trigger.new) {
			chave = itemLocation.get(linha.Id);
			System.debug('-> Identificador: '+ chave);
			try {
				custo = itemCusto.get( chave );
				System.debug('-> Custo obtido:' + custo);
				custoLinha = custo * linha.Quantidade__c;
			} catch(Exception e){
				System.debug('Erro ao recuperar custo: '+ e.getMessage());
				custo = 0.0;
				custoLinha = 0.0;			
			}
			
			System.debug('-> Custo: '+ custo);
			linha.Custo_Unitario__c=custo;
			linha.Custo_da_Linha__c=custoLinha;
			
		}	*/

}