Scriptname LightsBaneQuest extends ReferenceAlias

Actor Property LB_Player Auto
Spell Property LB_ShadowSneak Auto
GlobalVariable Property LB_HID_Toggle Auto

Event OnInit()
	If LB_HID_Toggle.GetValue() == 1.0
		LB_Player.AddSpell(LB_ShadowSneak)
	ElseIf LB_HID_Toggle.GetValue() == 0.0
		If LB_Player.HasSpell(LB_ShadowSneak)
			LB_Player.RemoveSpell(LB_ShadowSneak)
		EndIf
	EndIf
EndEvent

Event OnPlayerLoadGame()
	If LB_HID_Toggle.GetValue() == 1.0
		LB_Player.AddSpell(LB_ShadowSneak)
	ElseIf LB_HID_Toggle.GetValue() == 0.0
		If LB_Player.HasSpell(LB_ShadowSneak)
			LB_Player.RemoveSpell(LB_ShadowSneak)
		EndIf
	EndIf
EndEvent
