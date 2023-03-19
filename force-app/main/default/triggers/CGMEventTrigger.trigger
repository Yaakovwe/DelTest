trigger CGMEventTrigger on Collaboration_Group_Member__e (after insert) {
	if(Trigger.isInsert && Trigger.isAfter){
		CGMEventTriggerHelper.onAfterInsert(Trigger.new);
	}
}