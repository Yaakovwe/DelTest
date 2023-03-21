public with sharing class PartyService {
	@AuraEnabled
	public static List<Party__c> fetchParties(){
		try {
			List<Party__c> parties = [
				SELECT Name,Party_Code__c,Description__c,Chairman__c
				FROM Party__c
			];
			return parties;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static Boolean deleteParty(String partyId){
		try {
            Database.delete(new Party__c(Id = partyId));
            return true;
		} catch (Exception e) {
			return false;
		}
	}

    @AuraEnabled
	public static Boolean upsertParty(Party__c party){
		try {
            Database.upsert(party);
            return true;
		} catch (Exception e) {
			return false;
		}
	}
}