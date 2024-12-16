Scriptname LightsBaneLanternLight extends ObjectReference

ActorBase Property ownerActor = None Auto
Faction Property ownerFaction = None  Auto
MiscObject Property LB_LanternRemains Auto
MiscObject Property Lantern Auto
Sound Property LB_LanternBreakingSound Auto
Explosion Property LB_DustDropExplosionSm Auto

ObjectReference LB_LightFlagClose
ObjectReference LB_RemainsFlag
ObjectReference LB_DestructibleFlag

Bool LB_WasBroken = False
Bool LB_WasTaken = False

Event OnCellLoad()
    LB_SearchLightClose()
    self.Reset()
	  self.ClearDestruction()
    If LB_DestructibleFlag != None
        ConsoleUtil.ExecuteCommand("Enable")
    EndIf
    If LB_RemainsFlag != None
        LB_RemainsFlag.Delete()
    EndIf
    LB_WasBroken = False
EndEvent

Event OnContainerChanged(ObjectReference akNewContainer, ObjectReference akOldContainer)
    If akNewContainer == Game.GetPlayer()
        LB_Ownership()
        Game.GetPlayer().RemoveItem(self.GetBaseObject(), 1, True)
        Game.GetPlayer().AddItem(Lantern, 1, True)
        LB_WasTaken = True
    EndIf
EndEvent

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
    If !LB_WasBroken
        LB_Act()
    EndIf
EndEvent

Function LB_Act()
    LB_Ownership()
    LB_Break()
    LB_WasBroken = True
EndFunction

Function LB_Break()
    LB_LanternBreakingSound.Play(self)
    self.PlaceAtMe(LB_DustDropExplosionSm)
    LB_RemainsFlag = self.PlaceAtMe(LB_LanternRemains)
    self.DamageObject(90.0)
    LB_DestructibleFlag = ConsoleUtil.SetSelectedReference(self)
    ConsoleUtil.ExecuteCommand("Disable")
EndFunction

Function LB_Ownership()
    Cell akCell = Game.GetPlayer().GetParentCell()
    ownerActor = akCell.GetActorOwner()
    ownerFaction = akCell.GetFactionOwner()
    If ownerActor
        self.SetActorOwner(ownerActor)
        self.SendStealAlarm(Game.GetPlayer())
    ElseIf ownerFaction
        self.SetFactionOwner(ownerFaction)
        self.SendStealAlarm(Game.GetPlayer())
    EndIf
EndFunction

Function LB_SearchLightClose()
	Cell kCell = Game.GetPlayer().GetParentCell()
    ObjectReference closestLightRef = None
	  Int i = kCell.GetNumRefs(31) - 1
    Float closestDistance = 25.0
	  While i >= 0
        LB_LightFlagClose = kCell.GetNthRef(i, 31)
        Float distance = self.GetDistance(LB_LightFlagClose)
        If (LB_LightFlagClose != None) && (distance < closestDistance) && (LB_LightFlagClose != self)
            ConsoleUtil.SetSelectedReference(LB_LightFlagClose)
            ConsoleUtil.ExecuteCommand("Disable")
        EndIf
        i -= 1
	EndWhile
EndFunction
