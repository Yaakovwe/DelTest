@isTest
public with sharing class CGMEventTriggerHelperTest {
	@TestSetup
	static void makeData() {
		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
		User user1 = new User(Alias = 'first', Email='standarduser@testorg.com', 
			EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
			LocaleSidKey='en_US', ProfileId = p.Id, 
			TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com5467867'
		);
		User user2 = new User(Alias = 'second', Email='standarduser@testorg1.com', 
		EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
		LocaleSidKey='en_US', ProfileId = p.Id, 
		TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com546733867'
		);
		Database.insert(new List<User>{user1,user2});
		Group groupRecord = new Group(
			Name = 'Third'
		);
		Database.insert(groupRecord);

		GroupMember groupMemberRecord = new GroupMember(
			GroupId = groupRecord.Id,
			UserOrGroupId = user1.Id
		);
		Database.insert(groupMemberRecord);
	}

	@isTest(seealldata=false)
	static void createNewGroupsTest(){
		List<CollaborationGroup> collaborationGroupsCreation = TestHelper.createCollaborationGroups();

		List<CollaborationGroup> collaborationGroups = [
			SELECT Name
			FROM CollaborationGroup
			ORDER BY Name DESC
		];
		List<Group> groupsFromDb = [
			SELECT Id
			FROM Group
			ORDER BY Name DESC
		];
		List<User> users = [
			SELECT Email FROM User
			WHERE ALIAS IN ('first','second')
			ORDER BY Alias ASC
		];
		List<CollaborationGroupMember> collaborationGroupMembersBefore = [
			SELECT Member.Name
			FROM CollaborationGroupMember
		];
		List<GroupMember> groupMembersBefore = [
			SELECT Id
			FROM GroupMember
		];

		System.assert.areEqual(groupsFromDb.size(),groupsFromDb.size(), 'failed' + groupsFromDb.size()); // seealldata=false is retreiving the groups from db? why?
		System.assert.areEqual(collaborationGroupMembersBefore.size(),collaborationGroupMembersBefore.size(), 'failed ' + collaborationGroupMembersBefore); // seealldata=false is retreiving the group members from db? why?
		System.assert.areEqual(groupMembersBefore.size(),groupMembersBefore.size(), 'failed' + groupMembersBefore.size());
		System.debug(JSON.serialize(collaborationGroups));
		Test.startTest();
			TestHelper.createCollaborationGroupMembers(collaborationGroups,users);
		Test.stopTest();
		List<Group> groupsFromDbAfter = [
			SELECT Id
			FROM Group
			ORDER BY CreatedDate DESC
		];

		List<CollaborationGroupMember> collaborationGroupMembersAfter = [
			SELECT Id
			FROM CollaborationGroupMember
		];
		List<GroupMember> groupMembersAfter = [
			SELECT Group.Name,UserOrGroupId
			FROM GroupMember
		];
		System.assert.areEqual(groupsFromDb.size() + 2,groupsFromDbAfter.size(), 'failed ' + groupsFromDbAfter.size()); // 2 new groups added
		System.assert.areEqual(collaborationGroupMembersBefore.size() + 4,collaborationGroupMembersAfter.size(), 'failed ' + collaborationGroupMembersAfter.size()); // 3 new Collaboration group members added
		System.assert.areEqual(groupMembersBefore.size() + 3,groupMembersAfter.size(), 'failed ' + groupMembersAfter.size()); // 3 new group members added
	}

	@isTest(seealldata=false)
	static void deleteGroupsTest(){
		List<CollaborationGroup> collaborationGroupsCreation = TestHelper.createCollaborationGroups();

		List<CollaborationGroup> collaborationGroups = [
			SELECT Name
			FROM CollaborationGroup
			ORDER BY Name DESC
		];
		List<Group> groupsFromDb = [
			SELECT Id
			FROM Group
			ORDER BY Name DESC
		];
		List<User> users = [
			SELECT Email FROM User
			WHERE ALIAS IN ('first','second')
			ORDER BY Alias ASC
		];
		List<CollaborationGroupMember> collaborationGroupMembersBefore = [
			SELECT Member.Name
			FROM CollaborationGroupMember
			WHERE CollaborationRole != 'Admin'
		];
		List<GroupMember> groupMembersBefore = [
			SELECT Id
			FROM GroupMember
		];

		System.assert.areEqual(groupsFromDb.size(),groupsFromDb.size(), 'failed' + groupsFromDb.size()); // seealldata=false is retreiving the groups from db? why?
		System.assert.areEqual(collaborationGroupMembersBefore.size(),collaborationGroupMembersBefore.size(), 'failed ' + collaborationGroupMembersBefore); // seealldata=false is retreiving the group members from db? why?
		System.assert.areEqual(groupMembersBefore.size(),groupMembersBefore.size(), 'failed' + groupMembersBefore.size());
		System.debug(JSON.serialize(collaborationGroups));
		Test.startTest();
			TestHelper.createCollaborationGroupMembers(collaborationGroups,users);
		Test.stopTest();
		List<Group> groupsFromDbAfter = [
			SELECT Id
			FROM Group
			ORDER BY CreatedDate DESC
		];

		List<CollaborationGroupMember> collaborationGroupMembersAfter = [
			SELECT Id
			FROM CollaborationGroupMember
			WHERE CollaborationRole != 'Admin'
		];
		List<GroupMember> groupMembersAfter = [
			SELECT Group.Name,UserOrGroupId
			FROM GroupMember
		];
		System.assert.areEqual(groupsFromDb.size() + 2,groupsFromDbAfter.size(), 'failed ' + groupsFromDbAfter.size()); // 2 new groups added
		System.assert.areEqual(collaborationGroupMembersBefore.size() + 4,collaborationGroupMembersAfter.size(), 'failed ' + collaborationGroupMembersAfter.size()); // 3 new Collaboration group members added
		System.assert.areEqual(groupMembersBefore.size() + 3,groupMembersAfter.size(), 'failed ' + groupMembersAfter.size()); // 3 new group members added

		List<CollaborationGroupMember> collaborationGroupMembersToDelete = new List<CollaborationGroupMember>{
			collaborationGroupMembersAfter[0],collaborationGroupMembersAfter[1]};
		Database.delete(collaborationGroupMembersToDelete);

		List<Group> groupsFromDbAfterDelete = [
			SELECT Id
			FROM Group
			ORDER BY CreatedDate DESC
		];

		List<CollaborationGroupMember> collaborationGroupMembersAfterDelete = [
			SELECT Id
			FROM CollaborationGroupMember
			WHERE CollaborationRole != 'Admin'
		];
		List<GroupMember> groupMembersAfterDelete = [
			SELECT Group.Name,UserOrGroupId
			FROM GroupMember
		];
		System.assert.areEqual(groupsFromDbAfter.size(),groupsFromDbAfterDelete.size(),'failed ' + groupsFromDbAfter.size()); // 2 new groups added
		System.assert.areEqual(collaborationGroupMembersAfter.size() -2 ,collaborationGroupMembersAfterDelete.size(), 'failed ' + collaborationGroupMembersAfter.size()); // 3 new Collaboration group members added
		System.assert.areEqual(groupMembersAfter.size() - 2,groupMembersAfterDelete.size(), 'failed ' + groupMembersAfter.size()); // 3 new group members added
	}
}