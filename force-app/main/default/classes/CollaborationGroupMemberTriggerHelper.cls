public with sharing class CollaborationGroupMemberTriggerHelper {
	private static Boolean hasTriggerRan = false;
	private class CustomException extends Exception{}

	/**
	 * @description handeling List of CollaborationGroupMember. 
		this method handles all after insert event triggers on CollaborationGroupMember sObject
	 * @param  newGroupMembers List of CollaborationGroupMember
	 */
	public static void onAfterInsert(List<CollaborationGroupMember> newGroupMembers) {
		if(!hasTriggerRan){
			publishEvents(newGroupMembers);
		}
	}

	public static void onBeforeDelete(List<CollaborationGroupMember> deletedGroupMembers) {
		deleteExistingGroups(deletedGroupMembers);
		
	}

		/**
	 * @description handeling List of CollaborationGroupMember. 
		this method gets CollaborationGroup Names for all  CollaborationGroupMembers that are in the trigger.
		It then create an instance of platform event Collaboration_Group_Member__e and publishes the events
	 * @param  newGroupMembers List of CollaborationGroupMember
	 */
	private static void publishEvents(List<CollaborationGroupMember> newGroupMembers){
		try {
			Set<Id> newMemberIds = new Set<Id>();
			for (CollaborationGroupMember newMember : newGroupMembers) {
				if(newMember.CollaborationRole == 'Admin'){ //make sure trigger doesn't run on admin records
					continue;
				}
				newMemberIds.add(newMember.Id);
			}
			if(newMemberIds.isEmpty()){
				return;
			}
			hasTriggerRan = true;
			List<CollaborationGroupMember> newMembersFromDb = fetchGroupMembersWithGroupNames(newMemberIds);
			processMembersAndPublishEvents(newMembersFromDb);
		} catch (CustomException ex) {
			System.debug(ex);
			throw ex;
		}
	}

	/**
	 * @description 
	 * fetches all CollaborationGroupMembers from the trigger with there respective CollaborationGroup.Name
	 * @param  newMemberIds Set<Id> 
	 * 	 * @return  returns  a list of CollaborationGroupMember from the DB with the CollaborationGroup.Name
	 */
	private static List<CollaborationGroupMember> fetchGroupMembersWithGroupNames(Set<Id> newMemberIds) {
		List<CollaborationGroupMember> newMembersFromDb = [
			SELECT CollaborationGroup.Name,MemberId
			FROM CollaborationGroupMember
			WHERE Id IN :newMemberIds 
		];
		return newMembersFromDb;
	}

		/**
	 * @description 
	 * Creates a Collaboration_Group_Member__e (platform event) instance for each CollaborationGroupMember
	 * @param  newMembersFromDb List<CollaborationGroupMember>
	 */
	private static void processMembersAndPublishEvents(List<CollaborationGroupMember> newMembersFromDb) {
		List<Collaboration_Group_Member__e> publishEvents = new List<Collaboration_Group_Member__e>();
		for (CollaborationGroupMember newMember : newMembersFromDb) {
			Collaboration_Group_Member__e event  = new Collaboration_Group_Member__e();
			event.Member_Id__c = newMember.MemberId;
			event.Collaboration_Group_Name__c = newMember.CollaborationGroup.Name;
			event.Collaboration_Group_Id__c = newMember.Id;
			publishEvents.add(event);
		}
	
		if(!publishEvents.isEmpty()){
			EventBus.publish(publishEvents);
		}
	}

	private static void deleteExistingGroups(List<CollaborationGroupMember> deletedGroupMember){
		List<GroupMember> membersFromDb = fetchMembersFromDb(deletedGroupMember);
		if(!membersFromDb.isEmpty()){
			Database.delete(membersFromDb);
		}
	}

	private static List<GroupMember> fetchMembersFromDb(List<CollaborationGroupMember> deletedGroupMembers){
		Set<String> memberIds = new Set<String>();
		Set<String> groupNames = new Set<String>();
		Set<Id> recordIds = new Set<Id>();
		for (CollaborationGroupMember newMember : deletedGroupMembers) {
			memberIds.add(newMember.MemberId);
			recordIds.add(newMember.Id);
		}
		List<CollaborationGroupMember> colGroupMembers = [
			SELECT CollaborationGroup.Name 
			FROM CollaborationGroupMember
			WHERE Id IN :recordIds
		];

		for (CollaborationGroupMember newMember : colGroupMembers) {
			groupNames.add(newMember.CollaborationGroup.Name);
		}

		List<GroupMember> membersFromDb = [
			SELECT Group.Name, UserOrGroupId
			FROM GroupMember
			WHERE Group.Name IN :groupNames
			AND UserOrGroupId IN :memberIds
		];
		return membersFromDb;
	}
}