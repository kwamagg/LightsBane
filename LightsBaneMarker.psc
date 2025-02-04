Scriptname LightsBaneMarker Extends ObjectReference


Event OnCellAttach()
    GoToState("Busy")
    Int storedFormID = StorageUtil.GetIntValue(None, "LB_MarkerRef_" + self.GetFormID())
    Float storedScale = StorageUtil.GetFloatValue(None, "LB_LanternRefScale_" + self.GetFormID())
    Form lanternForm = Game.GetFormEx(storedFormID)
    ObjectReference newLantern = self.PlaceAtMe(lanternForm, 1, True) as ObjectReference
    newLantern.SetScale(storedScale)
    StorageUtil.UnsetIntValue(None, "LB_MarkerRef_" + self.GetFormID())
    StorageUtil.UnsetFloatValue(None, "LB_LanternRefScale_" + self.GetFormID())
    Utility.Wait(1)
    GoToState("")
    self.Delete()
EndEvent

State Busy

    Event OnCellAttach()
    EndEvent

EndState
