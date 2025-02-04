Scriptname LightsBaneLanternLight Extends ObjectReference


Light Property LB_LanternLight Auto
MiscObject Property LanternRemains Auto
Activator Property LB_Marker Auto
FormList Property LB_On Auto
FormList Property LB_Off Auto
Sound Property LB_LanternBreakingSound Auto
Explosion Property LB_DustDropExplosionSm Auto

GlobalVariable Property LB_DL_Toggle Auto
GlobalVariable Property LB_SearchAllowed Auto
GlobalVariable Property LB_CD_Slider Auto

ObjectReference LB_LightFlagClose
ObjectReference LB_RemainsFlag
ActorBase ownerActor
Faction ownerFaction

Float scale
String model


Function LB_Break()

    self.DamageObject(90.0)
    LB_LanternBreakingSound.Play(self)
    self.PlaceAtMe(LB_DustDropExplosionSm)

    If (LB_SearchAllowed.GetValue() == 1.0)
        LB_DisableLightClose()
    EndIf

    LB_RemainsFlag = self.PlaceAtMe(LanternRemains, 1, True, True) as ObjectReference
    LB_RemainsFlag.SetScale(scale)
    LB_RemainsFlag.Enable()
    
    If self.IsInInterior()
        self.Disable()
    Else
        ObjectReference markerRef = self.PlaceAtMe(LB_Marker, 1, True) as ObjectReference
        StorageUtil.SetIntValue(None, "LB_MarkerRef_" + markerRef.GetFormID(), self.GetBaseObject().GetFormID())
        StorageUtil.SetFloatValue(None, "LB_LanternRefScale_" + markerRef.GetFormID(), self.GetScale())
        self.Delete()
    EndIf

EndFunction


Function LB_Ownership(Actor akActionRef)

    Cell akCell = Game.GetPlayer().GetParentCell()
    ownerActor = akCell.GetActorOwner()
    ownerFaction = akCell.GetFactionOwner()

    If ownerActor
        self.SetActorOwner(ownerActor)
        self.SendStealAlarm(akActionRef)
    ElseIf ownerFaction
        self.SetFactionOwner(ownerFaction)
        self.SendStealAlarm(akActionRef)
    EndIf

EndFunction


Function LB_DisableLightClose()

	Cell kCell = Game.GetPlayer().GetParentCell()
	Int i = kCell.GetNumRefs(31) - 1
    Float maxDistance = LB_CD_Slider.GetValue()

	While i >= 0
        LB_LightFlagClose = kCell.GetNthRef(i, 31)
        Float distance = self.GetDistance(LB_LightFlagClose)
        If distance < maxDistance
            ConsoleUtil.SetSelectedReference(LB_LightFlagClose)
            ConsoleUtil.ExecuteCommand("Disable")
        EndIf
        i -= 1
	EndWhile

    ConsoleUtil.SetSelectedReference(None)

EndFunction


Event OnCellAttach()

    If (LB_DL_Toggle.GetValue() != 0.0)

        self.Enable()

        If (LB_SearchAllowed.GetValue() == 1.0)
            self.PlaceAtMe(LB_LanternLight, 1, True)
        EndIf
        
        If LB_RemainsFlag != None
            LB_RemainsFlag.Delete()
        EndIf

    EndIf

EndEvent


Event OnActivate(ObjectReference akActionRef)

    GoToState("Busy")

    ; Blow Out
    If LB_On.HasForm(self.GetBaseObject())

        Int index = LB_On.Find(self.GetBaseObject())

        If LB_SearchAllowed.GetValue() == 1.0
            LB_DisableLightClose()
        EndIf

        scale = self.GetScale()
        ObjectReference LB_LanternOff = self.PlaceAtMe(LB_Off.GetAt(index), 1, True, True) as ObjectReference
        StorageUtil.SetIntValue(None, "LB_LanternOffInit_" + LB_LanternOff.GetFormID(), 1)

        LB_LanternOff.SetScale(scale)
        LB_LanternOff.Enable()

        self.Disable()

        Utility.Wait(0.8)

        self.Delete()

    EndIf

    GoToState("")

EndEvent


Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
    
    If (LB_DL_Toggle.GetValue() != 0.0)

        scale = self.GetScale()

        GoToState("Busy")
        LB_Ownership((akAggressor as Actor))
        LB_Break()
        GoToState("")

    EndIf

EndEvent


State Busy

    Event OnActivate(ObjectReference akActionRef)
    EndEvent

    Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
    EndEvent

EndState
