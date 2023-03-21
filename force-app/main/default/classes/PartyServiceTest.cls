@isTest
public with sharing class PartyServiceTest {
    @TestSetup
    static void makeData(){
        Database.insert(
            new Party__c(
                Name = 'Test',
                Chairman__c = 'Moshe',
                Party_Code__c ='abc',
                Description__c = 'Best Part Ever'
        ));
    }
    @isTest
    static void fetchPartiesTest() {
        List<Party__c> parties = PartyService.fetchParties();
        System.assert.areEqual(1,parties.size(),'failed');
    }

    @isTest
    static void deletePartyTest() {
        List<Party__c> parties = PartyService.fetchParties();
        System.assert.areEqual(1,parties.size(),'failed');
        Boolean deleted =  PartyService.deleteParty(parties[0].Id);
        System.assert.areEqual(true,deleted,'failed');
    }

    
    @isTest
    static void upsertPartyTest() {
        List<Party__c> parties = PartyService.fetchParties();
        System.assert.areEqual(1,parties.size(),'failed');
        parties[0].Name = 'Shlomo';
        Boolean updated  = PartyService.upsertParty(parties[0]);
        System.assert.areEqual(true,updated,'failed');
    }
}