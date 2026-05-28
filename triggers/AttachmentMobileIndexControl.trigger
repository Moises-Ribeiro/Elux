/*
Nome do Arquivo:						AttachmentMobileIndexControl.trigger
Empresa:								Wipro
Desenvolvedor:							Renato Cohen
Descrição do Código:					Trigger responsável por replicar o Id do Anexo, do registro relacionado para um objeto de indíce


Histórico de Alterações:
Versão			Data				Responsável				Descrição da Alteração
1.0			13/12/2013				Renato Cohen			Criação da trigger
*/

trigger AttachmentMobileIndexControl on Attachment (after delete, after insert, after undelete, 
after update) {
	
	List<IndexAppEluxD__c> lstIndex								= new List<IndexAppEluxD__c>();
	List<IndexAppEluxD__c> lstIndexDel							= new List<IndexAppEluxD__c>();
	List<IndexAppEluxD__c> lstUpdate							= new List<IndexAppEluxD__c>();
	List<IndexAppEluxD__c> lstInsert							= new List<IndexAppEluxD__c>();
	List<IndexAppEluxD__c> lstDelete							= new List<IndexAppEluxD__c>();
	map <String, Attachment> mapaAnexos							= new map<String,Attachment>();
	map <String, Attachment> mapaAnexosDel						= new map<String,Attachment>();
	map <String, IndexAppEluxD__c> mapaIndex					= new map<String,IndexAppEluxD__c>();
	IndexAppEluxD__c Index										= new IndexAppEluxD__c();
	List<Id> IndexIDs											= new List<Id>();
	Boolean ver													= false; // se começa com ver (Verificação)
	Boolean vd													= false; // se começa com vd (Vídeo da verificação)
	Boolean sol													= false; // se começa com sol (Soluções)
	Boolean pr													= false; // se começa com pr (Produto)
	Boolean el													= false; // se começa com el (Esquema Elétrico do produto)
	Boolean cj													= false; // se começa com cj (Conjunto)
	Boolean pc													= false; // se começa com pc (Peça)
	Boolean ver_old												= false; // se o antigo começa com ver (Verificação)
	Boolean vd_old												= false; // se o antigo começa com vd (Vídeo da verificação)
	Boolean sol_old												= false; // se o antigo começa com sol (Soluções)
	Boolean pr_old												= false; // se o antigo começa com pr (Produto)
	Boolean el_old												= false; // se o antigo começa com el (Esquema Elétrico do produto)
	Boolean cj_old												= false; // se o antigo começa com cj (Conjunto)
	Boolean pc_old												= false; // se o antigo começa com pc (peça)
	
	
	
	
	if(Trigger.isDelete){ // se for deletado
		IndexIDs												= new List<Id>();
		for(Attachment att : Trigger.old){ // para cada registro a ser excluído
			ver													= att.Name.startsWith('VER');
			vd													= att.Name.startsWith('VD');
			sol													= att.Name.startsWith('SOL');
			pr													= att.Name.startsWith('PR');
			el													= att.Name.startsWith('EL');
			cj													= att.Name.startsWith('CJ');
			pc													= att.Name.startsWith('PC');
			if(ver || vd || sol || pr || el || cj || pc){ // verifica se o nome do registro será enviado para o aplicativo mobile
				IndexIDs.add(att.Id);
			}
		} // for(att)
		if(IndexIDs.size()>0){ // se foram encontrados IDs de registros a serem excluídos
			lstIndex											= new List<IndexAppEluxD__c>();
			lstIndex											= [SELECT Id, ID__c
																	FROM IndexAppEluxD__c
																	WHERE ID__c in: IndexIDs];
			if(lstIndex.size()>0){ // se foram encontrados registros a serem excluídos
				try{
					delete lstIndex;
				}catch(Exception e){
					for(IndexAppEluxD__c ind : lstIndex){ // para cada registro a ser excluído, adicionar o erro
						ind.addError('Não foi possível excluir os registros. Erro: ' + e);
					}
				}
			}
		}
	}else{
		if(Trigger.isUnDelete || Trigger.isInsert){ // se for novo ou recuperado da lixeira
			lstIndex											= new List<IndexAppEluxD__c>();
			for(Attachment att : Trigger.new){ // para cada registro a ser inserido (novo ou recuperado da lixeira)
				ver												= att.Name.startsWith('VER');
				vd												= att.Name.startsWith('VD');
				sol												= att.Name.startsWith('SOL');
				pr												= att.Name.startsWith('PR');
				el												= att.Name.startsWith('EL');
				cj												= att.Name.startsWith('CJ');
				pc												= att.Name.startsWith('PC');
				if(ver || vd || sol || pr || el || cj || pc){ // verifica se o nome do registro será enviado para o aplicativo mobile
					Index										= new IndexAppEluxD__c();
					Index.ID__c									= att.Id;
					Index.ParentID__c							= att.ParentId;
					
					lstIndex.add(Index);
				}
			} // for(att)
			if(lstIndex.size()>0){ // se forem encontrados registros a serem inseridos
				try{
					insert lstIndex;
				}catch(Exception e){
					for(IndexAppEluxD__c ind : lstIndex){ // para cada registro a ser excluído, adicionar o erro
						ind.addError('Não foi possível inserir os registros. Erro: ' + e);
					}
				}
			}
		}// if(insert or undelete)
		else{
			if(Trigger.isUpdate){ // se for atualizar
				IndexIDs										= new List<Id>();
				for(Attachment att : Trigger.new){ // para cada registro a ser inserido (novo ou recuperado da lixeira)
					ver											= att.Name.startsWith('VER');
					vd											= att.Name.startsWith('VD');
					sol											= att.Name.startsWith('SOL');
					pr											= att.Name.startsWith('PR');
					el											= att.Name.startsWith('EL');
					cj											= att.Name.startsWith('CJ');
					pc											= att.Name.startsWith('PC');
					ver_old										= Trigger.oldMap.get(att.Id).Name.startsWith('VER');
					vd_old										= Trigger.oldMap.get(att.Id).Name.startsWith('VD');
					sol_old										= Trigger.oldMap.get(att.Id).Name.startsWith('SOL');
					pr_old										= Trigger.oldMap.get(att.Id).Name.startsWith('PR');
					el_old										= Trigger.oldMap.get(att.Id).Name.startsWith('EL');
					cj_old										= Trigger.oldMap.get(att.Id).Name.startsWith('CJ');
					pc_old										= Trigger.oldMap.get(att.Id).Name.startsWith('PC');
					if(ver || vd || sol || pr || el || cj || pc || ver_old || vd_old || sol_old || pr_old || el_old || cj_old || pc_old ){ // verifica se o nome do registro será enviado para o aplicativo mobile
						if(att.Name != Trigger.oldMap.get(att.Id).Name || att.Description != Trigger.oldMap.get(att.Id).Description){ // se mudou o Name ou a Descrição
							IndexIDs.add(att.Id);
							mapaAnexos.put(att.Id,att);
							if((ver_old || vd_old || sol_old || pr_old || el_old || cj_old || pc_old) && (!ver && !vd && !sol && !pr && !el && !cj && !pc) ){ // se o nome não tem mais os prefixos necessários
								mapaAnexosDel.put(att.Id,att);
							}
						}
					}
				} // for(att)
				if(IndexIDs.size()>0){
					lstIndex									= new List<IndexAppEluxD__c>();
					lstIndex									= [SELECT Id, ID__c, ParentID__c
																	FROM IndexAppEluxD__c
																	WHERE ID__c in: IndexIDs];
					if(lstIndex.size()>0){
						for(IndexAppEluxD__c ind : lstIndex){ // para cada indíce encontrado no SF
							mapaIndex.put(ind.ID__c,ind);
						}
					}
							
					for(Id i : IndexIDs){ // para cada valor do id encontrado
						if(mapaAnexosDel.containsKey(i)){ // se tiver registro a ser excluido
							if(mapaIndex.containsKey(i)){ // se já existir um registro criado, excluir
								IndexAppEluxD__c ind			= new IndexAppEluxD__c ();
								ind								= mapaIndex.get(i);
								lstDelete.add(ind);
							}
						}else{
							if(mapaIndex.containsKey(i)){ // se já existir um registro criado, atualizar
								IndexAppEluxD__c ind			= new IndexAppEluxD__c ();
								ind								= mapaIndex.get(i);
								lstUpdate.add(ind);
							}else{ // se não tiver um registro criado, criar
								IndexAppEluxD__c ind			= new IndexAppEluxD__c ();
								ind.ParentID__c					= mapaAnexos.get(i).ParentId;
								ind.ID__c						= i;
								lstInsert.add(ind);
							}
						}
					}
					try{
						if(lstUpdate.size()>0){
							update lstUpdate;
						}
						if(lstInsert.size()>0){
							insert lstInsert;
						}
						if(lstDelete.size()>0){
							delete lstDelete;
						}
					}catch(exception e){
						for(IndexAppEluxD__c ind : lstUpdate){ // para cada registro a ser atualizado, adicionar o erro
							ind.addError('Não foi possível atualizar os registros. Erro: ' + e);
						}
						for(IndexAppEluxD__c ind : lstInsert){ // para cada registro a ser inserido, adicionar o erro
							ind.addError('Não foi possível inserir os registros. Erro: ' + e);
						}
						for(IndexAppEluxD__c ind : lstInsert){ // para cada registro a ser inserido, adicionar o erro
							ind.addError('Não foi possível excluir os registros. Erro: ' + e);
						}
					}
				} // if(IndexIDs>0)
			} // if(update)
		} // else
	} // if(delete)
	
	
	
	
}