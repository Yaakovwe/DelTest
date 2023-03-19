public with sharing class CGMEventTriggerHelper {
	private class CustomException extends Exception{}
	/**
	 * @description handeling List of Collaboration_Group_Member__e (platform event object). 
		this method handles all after insert event triggers on Collaboration_Group_Member__e sObject
	 * @param  newMemberEvents List of Collaboration_Group_Member__e
	 */
	public static void onAfterInsert(List<Collaboration_Group_Member__e> newMemberEvents) {
		if(!newMemberEvents[0].Is_Delete__c){
			createNewGroups(newMemberEvents);
		} 
			
	}
	/**
	 * @description handeling List of Collaboration_Group_Member__e (platform event object). 
		this method gets all Collaboration_Group_Member__e created and check if need to add a public group + member 
		if one of the above is missing we add it
	 * @param  newMemberEvents List of Collaboration_Group_Member__e
	 */
	private static void createNewGroups(List<Collaboration_Group_Member__e> newMemberEvents) {
		try {
			Map<String,Group> groupNameToGroupRecord = fetchGroupsWithMembersFromDb(newMemberEvents);
			Map<String,Group> groupsToAdd = new Map<String,Group>();
			List<GroupMember> membersToAdd = new List<GroupMember>();
			processMembersAndCreateNewGroupsWithMembers(newMemberEvents,groupNameToGroupRecord,groupsToAdd,membersToAdd);
			if(!groupsToAdd.isEmpty()){
				Database.insert(groupsToAdd.values());
			}
			if (!membersToAdd.isEmpty()) {
				List<GroupMember> filteredMembersToAdd = new List<GroupMember>();
				for (GroupMember newGroupMember : membersToAdd) { // add ids to members from new groups
					Group groupRecord = groupsToAdd.get(newGroupMember.Group.Name);
					if(groupRecord != null){
						newGroupMember.GroupId = groupRecord.Id;
						filteredMembersToAdd.add(newGroupMember);
					}
				}		
				Database.insert(filteredMembersToAdd);
			}
		} catch (CustomException ex) {
			System.debug(ex);
		}
	}

		/**
	 * @description handeling List of Collaboration_Group_Member__e (platform event object). 
		1.this method gets all Collaboration_Group_Member__e and arranges them in sets using memberIds and groupNames from the newMemberEvents records
		2.we select all public froups with their members from the FB
		3.finally we arrange the records from the db in a map in which the key is the group name and the values is the group
		if one of the above is missing we add it
	 * @param  newMemberEvents List of Collaboration_Group_Member__e
	 * * @return Map<String,Group> groupNameToGroupRecord the map from step 3
	 */
	private static Map<String,Group> fetchGroupsWithMembersFromDb(List<Collaboration_Group_Member__e> newMemberEvents){
		Set<String> memberIds = new Set<String>();
		Set<String> groupNames = new Set<String>();
		for (Collaboration_Group_Member__e newMember : newMemberEvents) {
			memberIds.add(newMember.Member_Id__c);
			groupNames.add(newMember.Collaboration_Group_Name__c);
		}
		Map<Id,Group> groupsWithMembersFromDb = new Map<Id,Group>([
			SELECT Name,
			(SELECT Group.Name, UserOrGroupId FROM GroupMembers WHERE UserOrGroupId IN :memberIds)
			FROM Group
			WHERE Name IN :groupNames
		]);
		Map<String,Group> groupNameToGroupRecord = new Map<String,Group>();
		if(!groupsWithMembersFromDb.isEmpty()){
			for (Group groupRecord : groupsWithMembersFromDb.values()) { // create a map with key as existing group names 
				groupNameToGroupRecord.put(groupRecord.Name,groupRecord);
			}
		}
		return groupNameToGroupRecord;
	}

	/**
	 * @description:
		1.this method iterates through all Collaboration_Group_Member__e we got from the trigger event
		2.checks if we got a respective group or group member
		3. if both from step 3 don't exist we check if we created a new group in Map<String,Group> groupsToAdd and add it if not
		4. we create the group member and assign the group from step 2 or 3 to eh newly created member instance
	 * @param  newMemberEvents - List of Collaboration_Group_Member__e List of Collaboration_Group_Member__e (platform event object)
	 * @param  Map<String,Group> - groupNameToGroupRecord map we got from fetchGroupsWithMembersFromDb
	 * @param  Map<String,Group> - groupsToAdd map of groups we need to add (data type is map to prevent multiple additions)
	 * @param  List<GroupMember> - membersToAdd - list of group members we need to add
	 */
	private static void processMembersAndCreateNewGroupsWithMembers(List<Collaboration_Group_Member__e> newMemberEvents,Map<String,Group> groupNameToGroupRecord,
		Map<String,Group> groupsToAdd,List<GroupMember> membersToAdd){
			System.debug(newMemberEvents.size() + ' sizey');
		for (Collaboration_Group_Member__e newMember : newMemberEvents) {
			System.debug(membersToAdd.size() + ' sizey');
			Group groupRecord = groupNameToGroupRecord.get(newMember.Collaboration_Group_Name__c);
			Boolean createMemberRecord = groupRecord == null || groupRecord.GroupMembers.isEmpty(); //This means the group might or might not exist but the group member doesn't exist
			if(groupRecord == null){ // this means there is no group and no user group member record so we need to add both
				groupRecord = getOrCreateGroupRecord(newMember.Collaboration_Group_Name__c,groupsToAdd);

			}
			if(createMemberRecord){ 
				membersToAdd.add(createMemberRecord(newMember,groupRecord));
			}
		}
	}

		/**
	 * @description - Creates a new GroupMember witht he proper userId and group, we add the group as well as the groupId for group instances that are not in the DB yet
	 * @param  Collaboration_Group_Member__e newMember - memberEventRecord from the trigger
	 * @param  Group groupRecord - groupRecordFrom the DB or from the map
	 * @return the new GroupMember w intance we created
	 */
	private static GroupMember createMemberRecord(Collaboration_Group_Member__e newMember, Group groupRecord){
		return new GroupMember(
			UserOrGroupId = newMember.Member_Id__c,
			Group = groupRecord,
			GroupId = groupRecord.Id
		);
	}

	   /**
	 * @description - Check if a new group already exists in thr map with the same group name and creates a new one of not
	 * @param  Collaboration_Group_Member__e newMember - memberEventRecord from the trigger
	 * @param  Group groupRecord - groupRecordFrom the DB or from the map
	 * @return the new GroupMember instance we created
	 */
	private static Group getOrCreateGroupRecord(String groupName, Map<String,Group> groupsToAdd){
		Group groupRecord = groupsToAdd.get(groupName);
		if(groupRecord == null){ //doesn't exist in the map
			groupRecord = new Group(
				Name = groupName
			);
			groupsToAdd.put(groupName,groupRecord);
		}
		return groupRecord;
	}
}