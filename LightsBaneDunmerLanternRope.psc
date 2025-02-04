Scriptname LightsBaneDunmerLanternRope Extends ObjectReference


Activator Property LB_DunmerLantern Auto
Activator Property LB_Marker Auto
FormList Property LB_DunmerRopesList Auto
FormList Property LB_DunmerLanternsList Auto
GlobalVariable Property LB_ScaleDisallowed Auto



Function SetLanternRef(String nodeName)

    ObjectReference markerRef = self.PlaceAtMe(LB_Marker, 1, True) as ObjectReference
    markerRef.MoveToNode(self, nodeName)
    
    ObjectReference foundLamp = Game.FindClosestReferenceOfAnyTypeInListFromRef(LB_DunmerLanternsList, markerRef, 0.1)

    If foundLamp == None
        foundLamp = self.PlaceAtMe(LB_DunmerLantern, 1, True) as ObjectReference
    EndIf

    foundLamp.MoveToNode(self, nodeName)

    If LB_ScaleDisallowed.GetValue() != 1.0
        foundLamp.SetScale(self.GetScale() * 0.8)
    Else
        foundLamp.SetScale(self.GetScale() * 1.8)
    EndIf

EndFunction


Event OnCellAttach()

    GoToState("Busy")
    
    Int index = LB_DunmerRopesList.Find(self.GetBaseObject())

    If index >= 0 && index < 11
        Utility.Wait(0.5)
        SetLanternRef("Lantern1")
        SetLanternRef("Lantern2")
        SetLanternRef("Lantern3")
    ElseIf index >= 11 && index < 23
        Utility.Wait(0.4)
        SetLanternRef("Lantern1")
        SetLanternRef("Lantern2")
    ElseIf index >= 23 && index < 35
        Utility.Wait(0.3)
        SetLanternRef("Lantern1")
    ElseIf index >= 35 && index < 47
        Utility.Wait(0.2)
        SetLanternRef("Lantern1")
    ElseIf index >= 47
        Utility.Wait(0.1)
        SetLanternRef("Lantern1")
    EndIf

    GoToState("")

EndEvent


State Busy

    Event OnCellAttach()
    EndEvent

EndState
