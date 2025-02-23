Scriptname LightsBaneLantern Extends ObjectReference


Keyword Property LB_Fire Auto
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

    If self.IsInInterior()
        self.Disable()
    Else
        ObjectReference markerRef = self.PlaceAtMe(LB_Marker, 1, True) as ObjectReference
        markerRef.MoveTo(self)

        If StorageUtil.GetIntValue(None, "LB_LanternOffInit_" + self.GetFormID()) != 1
            StorageUtil.SetIntValue(None, "LB_MarkerRef_" + markerRef.GetFormID(), self.GetBaseObject().GetFormID())
        Else
            Int index = LB_Off.Find(self.GetBaseObject())
            StorageUtil.SetIntValue(None, "LB_MarkerRef_" + markerRef.GetFormID(), LB_On.GetAt(index).GetFormID())
        EndIf

        StorageUtil.SetIntValue(None, "LB_MarkerRemainsRef_" + markerRef.GetFormID(), LB_RemainsFlag.GetFormID())
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


Function LB_EnableLightClose(ObjectReference marker)
    String disabledListKey = "LB_DisabledLights_" + marker.GetFormID()
    String disabledListCountKey = "LB_DisabledLightsCount_" + marker.GetFormID()
    Int count = StorageUtil.GetIntValue(marker, disabledListCountKey)

    If count <= 0
        Return
    EndIf

    While count > 0

        count -= 1
        Form disabledForm = StorageUtil.FormListGet(marker, disabledListKey, count)

        If disabledForm != None

            ObjectReference disabledRef = disabledForm as ObjectReference
            If disabledRef != None
                ConsoleUtil.SetSelectedReference(disabledRef)
                ConsoleUtil.ExecuteCommand("Enable")
            EndIf

        EndIf

    EndWhile

    ConsoleUtil.SetSelectedReference(None)
    StorageUtil.UnsetIntValue(marker, disabledListCountKey)
    StorageUtil.FormListClear(marker, disabledListKey)

EndFunction


Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
    GoToState("Busy")
    
    If !akSource.HasKeyword(LB_Fire) && (LB_DL_Toggle.GetValue() != 0.0)

        scale = self.GetScale()
        LB_Ownership((akAggressor as Actor))
        LB_Break()
        
    ElseIf akSource.HasKeyword(LB_Fire) && (LB_DL_Toggle.GetValue() != 0.0)

        ; Light
        Int index = LB_Off.Find(self.GetBaseObject())
        String disabledListCountKey = "LB_DisabledLightsCount_" + self.GetFormID()
        scale = self.GetScale()
        ObjectReference LB_LanternOn = self.PlaceAtMe(LB_On.GetAt(index), 1, True, True) as ObjectReference

        LB_LanternOn.SetScale(scale)
        LB_LanternOn.Enable()

        If (LB_SearchAllowed.GetValue() == 1.0)
            If StorageUtil.GetIntValue(self, disabledListCountKey) > 0
                LB_EnableLightClose(self)
            EndIf
        EndIf

        StorageUtil.UnsetIntValue(None, "LB_LanternOffInit_" + self.GetFormID())

        self.Disable()
        Utility.Wait(0.8)
        self.Delete()

    EndIf
    GoToState("")
EndEvent


Event OnMagicEffectApply(ObjectReference akCaster, MagicEffect akEffect)
    GoToState("Busy")
    
    If !akEffect.HasKeyword(LB_Fire) && (LB_DL_Toggle.GetValue() != 0.0)

        scale = self.GetScale()
        LB_Ownership((akCaster as Actor))
        LB_Break()
        
    ElseIf akEffect.HasKeyword(LB_Fire) && (LB_DL_Toggle.GetValue() != 0.0)

        ; Light
        Int index = LB_Off.Find(self.GetBaseObject())
        String disabledListCountKey = "LB_DisabledLightsCount_" + self.GetFormID()
        scale = self.GetScale()
        ObjectReference LB_LanternOn = self.PlaceAtMe(LB_On.GetAt(index), 1, True, True) as ObjectReference

        LB_LanternOn.SetScale(scale)
        LB_LanternOn.Enable()

        If (LB_SearchAllowed.GetValue() == 1.0)
            If StorageUtil.GetIntValue(self, disabledListCountKey) > 0
                LB_EnableLightClose(self)
            EndIf
        EndIf

        StorageUtil.UnsetIntValue(None, "LB_LanternOffInit_" + self.GetFormID())

        self.Disable()
        Utility.Wait(0.8)
        self.Delete()

    EndIf
    GoToState("")
EndEvent


Event OnActivate(ObjectReference akActionRef)
    GoToState("Busy")

    ;If !(Game.GetCameraState() == 0) && !(Game.GetPlayer().IsWeaponDrawn())
        ;Debug.SendAnimationEvent(Game.GetPlayer(), "IdleActivatePickUp")
        ;Utility.Wait(0.6)
        ;Debug.SendAnimationEvent(Game.GetPlayer(), "IdleStop")
    ;EndIf

    ; Light
    Int index = LB_Off.Find(self.GetBaseObject())
    String disabledListCountKey = "LB_DisabledLightsCount_" + self.GetFormID()
    scale = self.GetScale()
    ObjectReference LB_LanternOn = self.PlaceAtMe(LB_On.GetAt(index), 1, True, True) as ObjectReference

    LB_LanternOn.SetScale(scale)
    LB_LanternOn.Enable()

    If (LB_SearchAllowed.GetValue() == 1.0)
        If StorageUtil.GetIntValue(self, disabledListCountKey) > 0
            LB_EnableLightClose(self)
        EndIf
    EndIf

    StorageUtil.UnsetIntValue(None, "LB_LanternOffInit_" + self.GetFormID())

    self.Disable()
    Utility.Wait(0.8)
    self.Delete()

    GoToState("")
EndEvent


Event OnCellAttach()

    If StorageUtil.GetIntValue(None, "LB_LanternOffInit_" + self.GetFormID()) == 1

        Int index = LB_Off.Find(self.GetBaseObject())
        String disabledListCountKey = "LB_DisabledLightsCount_" + self.GetFormID()
        scale = self.GetScale()
        ObjectReference LB_LanternOn = self.PlaceAtMe(LB_On.GetAt(index), 1, True, True) as ObjectReference

        LB_LanternOn.SetScale(scale)
        LB_LanternOn.Enable()

        If (LB_SearchAllowed.GetValue() == 1.0)
            If StorageUtil.GetIntValue(self, disabledListCountKey) > 0
                LB_EnableLightClose(self)
            EndIf
        EndIf

        StorageUtil.UnsetIntValue(None, "LB_LanternOffInit_" + self.GetFormID())

        self.Delete()

    Else
        
        If (LB_DL_Toggle.GetValue() != 0.0)

            self.Enable()
            
            If (LB_RemainsFlag != None) && (Game.GetPlayer().GetItemCount(LB_RemainsFlag) == 0)
                LB_RemainsFlag.Delete()
            EndIf
    
        EndIf

    EndIf

EndEvent


State Busy

    Event OnActivate(ObjectReference akActionRef)
    EndEvent

    Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
    EndEvent

    Event OnMagicEffectApply(ObjectReference akCaster, MagicEffect akEffect)
    EndEvent

EndState
