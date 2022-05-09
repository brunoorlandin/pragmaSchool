@isTest
public class AtualizaNomeOportunidadeTeste {
	
    @isTest 
    static void testandoPreenchimentoNome(){
        
        //Criando uma conta
        Account conta1 = new Account(
          Name = 'Conta 1',
          Phone = '11 1111-1111',
          Rating = 'Hot',
          AccountSource = 'Web'
        );
        insert conta1;
        
        //Criando uma oportunidade
        Opportunity oportunidade1 = new Opportunity(
          AccountId = conta1.Id,
          Name = 'Conta 1',
          CloseDate = Date.today() + 1,
          StageName = 'Propecting'
        );
        
        //Preparando a data para o formato que esperamos que ela esteja
        Date dataHoje = Date.today();
        String dataFormatada = dataHoje.day() +'/'  +
                               dataHoje.month()+'/'  +
                               dataHoje.year();
        //Iniciando o teste        
        Test.startTest();
        	//Inserindo a oportunidade
            insert oportunidade1;
        	
            //Trazendo os dados atualizados para verificar como ficou o nome
        	Opportunity oportunidade = [SELECT ID, Name FROM Opportunity WHERE ID = :oportunidade1.Id];
        	
        	//Comparando o resultado desejado com o resultado final
            System.assertEquals(conta1.name + ' | ' + dataFormatada, oportunidade.name);
        
        //Finalizando o teste
        Test.stopTest();        
    }
}