public with sharing class TestHelper {
	public static List<CollaborationGroup> createCollaborationGroups() {
		CollaborationGroup collaborationGroup1 = new CollaborationGroup( 
			CollaborationType = 'Private',
			Name = 'First'
		);

		CollaborationGroup collaborationGroup2 = new CollaborationGroup( 
			CollaborationType = 'Private',
			Name = 'Second'
		);
		
		CollaborationGroup collaborationGroup3 = new CollaborationGroup( 
			CollaborationType = 'Private',
			Name = 'Third'
		);
		List<CollaborationGroup> collaborationGroups = new List<CollaborationGroup>{collaborationGroup1,collaborationGroup2,collaborationGroup3};
		Database.insert(collaborationGroups);
		return collaborationGroups;
	}

	public static List<CollaborationGroupMember> createCollaborationGroupMembers(List<CollaborationGroup> collaborationGroups,List<User> users){	
		CollaborationGroupMember groupMember = new CollaborationGroupMember( // group + member already exists group + member shouldn't be added
			MemberId = users[0].Id,
			CollaborationGroupId = collaborationGroups[0].Id 
		);

		CollaborationGroupMember groupMember1 = new CollaborationGroupMember(
			MemberId = users[0].Id,
			CollaborationGroupId = collaborationGroups[2].Id
		);

		CollaborationGroupMember groupMember2 = new CollaborationGroupMember(
			MemberId = users[1].Id,
			CollaborationGroupId = collaborationGroups[1].Id
		);

		CollaborationGroupMember groupMember3 = new CollaborationGroupMember(
			MemberId = users[1].Id,
			CollaborationGroupId = collaborationGroups[2].Id
		);

		List<CollaborationGroupMember> collaborationGroupMembers = new List<CollaborationGroupMember>{groupMember,groupMember1,groupMember2,groupMember3};
		Database.insert(collaborationGroupMembers);
		return collaborationGroupMembers;
	}
}