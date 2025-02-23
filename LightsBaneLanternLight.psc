Scriptname LightsBaneLanternLight Extends ObjectReference


Keyword Property LB_Frost Auto
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

    ObjectReference markerRef = self.PlaceAtMe(LB_Marker, 1, True) as ObjectReference
    markerRef.MoveTo(self)

    If (LB_SearchAllowed.GetValue() == 1.0)
        If self.IsInInterior()
            markerRef.Delete()
            LB_DisableLightClose(self)
        Else
            LB_DisableLightClose(markerRef)
        EndIf
    EndIf

    LB_RemainsFlag = self.PlaceAtMe(LanternRemains, 1, True, True) as ObjectReference
    LB_RemainsFlag.SetScale(scale)
    LB_RemainsFlag.Enable()
    
    If self.IsInInterior()
        self.Disable()
    Else
        StorageUtil.SetIntValue(None, "LB_MarkerRef_" + markerRef.GetFormID(), self.GetBaseObject().GetFormID())
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


Function LB_DisableLightClose(ObjectReference marker)

	Cell kCell = Game.GetPlayer().GetParentCell()
	Int i = kCell.GetNumRefs(31) - 1
    Float maxDistance = LB_CD_Slider.GetValue()
    String disabledListKey = "LB_DisabledLights_" + marker.GetFormID()
    String disabledListCountKey = "LB_DisabledLightsCount_" + marker.GetFormID()
    Int disabledListCount = 0

	While i >= 0

        LB_LightFlagClose = kCell.GetNthRef(i, 31)
        Float distance = self.GetDistance(LB_LightFlagClose)
        i -= 1

        If distance < maxDistance
            disabledListCount += 1
            StorageUtil.FormListAdd(marker, disabledListKey, LB_LightFlagClose)
            ConsoleUtil.SetSelectedReference(LB_LightFlagClose)
            ConsoleUtil.ExecuteCommand("Disable")
        EndIf
        
	EndWhile

    StorageUtil.SetIntValue(marker, disabledListCountKey, disabledListCount)
    ConsoleUtil.SetSelectedReference(None)

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


Event OnCellAttach()

    If (LB_DL_Toggle.GetValue() != 0.0)

        self.Enable()
        String disabledListCountKey = "LB_DisabledLightsCount_" + self.GetFormID()

        If (LB_SearchAllowed.GetValue() == 1.0) && self.IsInInterior()
            If (StorageUtil.GetIntValue(self, disabledListCountKey) > 0)
                LB_EnableLightClose(self)
            EndIf
        EndIf
        
        If (LB_RemainsFlag != None) && (Game.GetPlayer().GetItemCount(LB_RemainsFlag) == 0)
            LB_RemainsFlag.Delete()
        EndIf

    EndIf

EndEvent


Event OnActivate(ObjectReference akActionRef)
    GoToState("Busy")

    ;If !(Game.GetCameraState() == 0) && !(Game.GetPlayer().IsWeaponDrawn())
        ;Debug.SendAnimationEvent(Game.GetPlayer(), "IdleActivatePickUp")
        ;Utility.Wait(0.6)
        ;Debug.SendAnimationEvent(Game.GetPlayer(), "IdleStop")
    ;EndIf

    ; Blow Out
    Int index = LB_On.Find(self.GetBaseObject())

    scale = self.GetScale()
    ObjectReference LB_LanternOff = self.PlaceAtMe(LB_Off.GetAt(index), 1, True, True) as ObjectReference
    StorageUtil.SetIntValue(None, "LB_LanternOffInit_" + LB_LanternOff.GetFormID(), 1)

    If LB_SearchAllowed.GetValue() == 1.0
        LB_DisableLightClose(LB_LanternOff)
    EndIf

    LB_LanternOff.SetScale(scale)
    LB_LanternOff.Enable()

    self.Disable()
    Utility.Wait(0.8)
    self.Delete()

    GoToState("")
EndEvent


Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
    GoToState("Busy")

    If !akSource.HasKeyword(LB_Frost) && (LB_DL_Toggle.GetValue() != 0.0)

        scale = self.GetScale()
        LB_Ownership((akAggressor as Actor))
        LB_Break()

    ElseIf akSource.HasKeyword(LB_Frost) && (LB_DL_Toggle.GetValue() != 0.0)

        Int index = LB_On.Find(self.GetBaseObject())

        scale = self.GetScale()
        ObjectReference LB_LanternOff = self.PlaceAtMe(LB_Off.GetAt(index), 1, True, True) as ObjectReference
        StorageUtil.SetIntValue(None, "LB_LanternOffInit_" + LB_LanternOff.GetFormID(), 1)

        If LB_SearchAllowed.GetValue() == 1.0
            LB_DisableLightClose(LB_LanternOff)
        EndIf

        LB_LanternOff.SetScale(scale)
        LB_LanternOff.Enable()

        self.Disable()
        Utility.Wait(0.8)
        self.Delete()

    EndIf
    GoToState("")
EndEvent


Event OnMagicEffectApply(ObjectReference akCaster, MagicEffect akEffect)
    GoToState("Busy")

    If !akEffect.HasKeyword(LB_Frost) && (LB_DL_Toggle.GetValue() != 0.0)

        scale = self.GetScale()
        LB_Ownership((akCaster as Actor))
        LB_Break()

    ElseIf akEffect.HasKeyword(LB_Frost) && (LB_DL_Toggle.GetValue() != 0.0)

        Int index = LB_On.Find(self.GetBaseObject())

        scale = self.GetScale()
        ObjectReference LB_LanternOff = self.PlaceAtMe(LB_Off.GetAt(index), 1, True, True) as ObjectReference
        StorageUtil.SetIntValue(None, "LB_LanternOffInit_" + LB_LanternOff.GetFormID(), 1)

        If LB_SearchAllowed.GetValue() == 1.0
            LB_DisableLightClose(LB_LanternOff)
        EndIf

        LB_LanternOff.SetScale(scale)
        LB_LanternOff.Enable()

        self.Disable()
        Utility.Wait(0.8)
        self.Delete()

    EndIf
    GoToState("")
EndEvent


State Busy

    Event OnActivate(ObjectReference akActionRef)
    EndEvent

    Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
    EndEvent

    Event OnMagicEffectApply(ObjectReference akCaster, MagicEffect akEffect)
    EndEvent

EndState
