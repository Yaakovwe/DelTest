public with sharing class PartyService {
	@AuraEnabled
	public static List<Party__c> fetchParties(){
		try {
			List<Party__c> parties = [
				SELECT Party_Code__c,Description__c
				FROM Party__c
			];
			return parties;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}
}