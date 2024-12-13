Scriptname LightsBaneLantern extends ObjectReference

Sound Property LB_LanternBreakingSound Auto
ActorBase Property ownerActor = None Auto
Faction Property ownerFaction = None  Auto
MiscObject Property LB_Lantern Auto
MiscObject Property LB_LanternLit Auto
Bool wasBroken = False

Event OnContainerChanged(ObjectReference akNewContainer, ObjectReference akOldContainer)
    If akNewContainer == Game.GetPlayer()
        Game.GetPlayer().RemoveItem(LB_LanternLit, 1, True)
        Game.GetPlayer().AddItem(LB_Lantern, 1, True)
    EndIf
EndEvent

Event OnCellLoad()
	self.Reset()
	self.ClearDestruction()
  wasBroken = False
EndEvent

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
    If !wasBroken
        LB_Act()
    EndIf
EndEvent

Function LB_Act()
    LB_Ownership()
    LB_Break()
    wasBroken = True
EndFunction

Function LB_Break()
	self.DamageObject(90.0)
    LB_LanternBreakingSound.Play(self)
EndFunction

Function LB_Ownership()
    ownerActor = self.GetActorOwner()
    ownerFaction = self.GetFactionOwner()
    If ownerActor
        self.SetActorOwner(ownerActor)
        self.SendStealAlarm(Game.GetPlayer())
    ElseIf ownerFaction
        self.SetFactionOwner(ownerFaction)
        self.SendStealAlarm(Game.GetPlayer())
    EndIf
EndFunction
