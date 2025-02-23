Scriptname LightsBaneMarker Extends ObjectReference


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
    GoToState("Busy")
    Int storedFormID = StorageUtil.GetIntValue(None, "LB_MarkerRef_" + self.GetFormID())
    Int storedRemainsFormID = StorageUtil.GetIntValue(None, "LB_MarkerRemainsRef_" + self.GetFormID())
    Float storedScale = StorageUtil.GetFloatValue(None, "LB_LanternRefScale_" + self.GetFormID())
    String disabledListCountKey = "LB_DisabledLightsCount_" + self.GetFormID()
    Form lanternForm = Game.GetFormEx(storedFormID)
    ObjectReference lanternRemains = Game.GetFormEx(storedRemainsFormID) as ObjectReference
    
    If (Game.GetPlayer().GetItemCount(lanternRemains) == 0)
        lanternRemains.Delete()
    EndIf

    If StorageUtil.GetIntValue(self, disabledListCountKey) > 0
        LB_EnableLightClose(self)
    EndIf

    ObjectReference newLantern = self.PlaceAtMe(lanternForm, 1, True) as ObjectReference
    newLantern.MoveTo(self)
    newLantern.SetScale(storedScale)

    StorageUtil.UnsetIntValue(None, "LB_MarkerRef_" + self.GetFormID())
    StorageUtil.UnsetFloatValue(None, "LB_LanternRefScale_" + self.GetFormID())
    StorageUtil.UnsetIntValue(None, "LB_MarkerRemainsRef_" + self.GetFormID())
    Utility.Wait(1)
    GoToState("")
    self.Delete()
EndEvent


State Busy

    Event OnCellAttach()
    EndEvent

EndState
