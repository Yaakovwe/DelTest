trigger CollaborationGroupMemberTrigger on CollaborationGroupMember (after insert,before delete) {
	if(Trigger.isInsert && Trigger.isAfter){
		CollaborationGroupMemberTriggerHelper.onAfterInsert(Trigger.new); 
	}

    if(Trigger.isDelete && Trigger.isBefore){
		CollaborationGroupMemberTriggerHelper.onBeforeDelete(Trigger.old); 
	}
}