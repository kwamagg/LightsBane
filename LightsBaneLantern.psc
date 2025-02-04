Scriptname LightsBaneLantern Extends ObjectReference


Light Property LB_LanternLight Auto
MiscObject Property LanternRemains Auto
Activator Property LB_Marker Auto
FormList Property LB_On Auto
FormList Property LB_Off Auto
Sound Property LB_LanternBreakingSound Auto

GlobalVariable Property LB_DL_Toggle Auto
GlobalVariable Property LB_SearchAllowed Auto

ObjectReference LB_RemainsFlag
ActorBase ownerActor
Faction ownerFaction

Float scale



Function LB_Break()
    
    self.DamageObject(90.0)
    LB_LanternBreakingSound.Play(self)
    LB_RemainsFlag = self.PlaceAtMe(LanternRemains, 1, True, True) as ObjectReference
    LB_RemainsFlag.SetScale(scale)
    LB_RemainsFlag.Enable()

    If StorageUtil.GetIntValue(None, "LB_LanternOffInit_" + self.GetFormID()) != 1

        If self.IsInInterior()
            self.Disable()
        Else
            ObjectReference markerRef = self.PlaceAtMe(LB_Marker, 1, True) as ObjectReference
            StorageUtil.SetIntValue(None, "LB_MarkerRef_" + markerRef.GetFormID(), self.GetBaseObject().GetFormID())
            StorageUtil.SetFloatValue(None, "LB_LanternRefScale_" + markerRef.GetFormID(), self.GetScale())
            self.Delete()
        EndIf

    Else
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


Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
    
    If (LB_DL_Toggle.GetValue() != 0.0)

        scale = self.GetScale()

        GoToState("Busy")
        LB_Ownership((akAggressor as Actor))
        LB_Break()
        GoToState("")

    EndIf

EndEvent


Event OnActivate(ObjectReference akActionRef)

    GoToState("Busy")

    ; Light
    If LB_Off.HasForm(self.GetBaseObject())

        Int index = LB_Off.Find(self.GetBaseObject())
        scale = self.GetScale()
        ObjectReference LB_LanternOn = self.PlaceAtMe(LB_On.GetAt(index), 1, True, True) as ObjectReference

        LB_LanternOn.SetScale(scale)
        LB_LanternOn.Enable()

        If (LB_SearchAllowed.GetValue() == 1.0)
            LB_LanternOn.PlaceAtMe(LB_LanternLight, 1, True)
        EndIf

        StorageUtil.UnsetIntValue(None, "LB_LanternOffInit_" + self.GetFormID())

        self.Disable()

        Utility.Wait(0.8)

        self.Delete()

    Else
        Game.GetPlayer().AddItem(LanternRemains, 1, True)
        self.Delete()
    EndIf

    GoToState("")

EndEvent


Event OnCellAttach()

    If StorageUtil.GetIntValue(None, "LB_LanternOffInit_" + self.GetFormID()) == 1

        Int index = LB_Off.Find(self.GetBaseObject())
        scale = self.GetScale()
        ObjectReference LB_LanternOn = self.PlaceAtMe(LB_On.GetAt(index), 1, True, True) as ObjectReference

        LB_LanternOn.SetScale(scale)
        LB_LanternOn.Enable()

        If (LB_SearchAllowed.GetValue() == 1.0)
            LB_LanternOn.PlaceAtMe(LB_LanternLight, 1, True)
        EndIf

        StorageUtil.UnsetIntValue(None, "LB_LanternOffInit_" + self.GetFormID())

        self.Delete()

    EndIf

EndEvent


State Busy

    Event OnActivate(ObjectReference akActionRef)
    EndEvent

    Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
    EndEvent

EndState
