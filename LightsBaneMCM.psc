Scriptname LightsBaneMCM extends MCM_ConfigBase

Quest Property LB_ShadowSneakQuest Auto
GlobalVariable Property LB_DL_Toggle Auto
GlobalVariable Property LB_HID_Toggle Auto
GlobalVariable Property LB_SearchAllowed Auto
GlobalVariable Property LB_CD_Slider Auto

Bool migrated = False

Int Function GetVersion()
    return 1
EndFunction

Event OnUpdate()
    parent.OnUpdate()
    If !migrated
        MigrateToMCMHelper()
        migrated = True
    EndIf
EndEvent

Event OnGameReload()
    parent.OnGameReload()
    If !migrated
        MigrateToMCMHelper()
        migrated = True
    EndIf
    If GetModSettingBool("bLoadSettingsonReload:Maintenance")
        LoadSettings()
    EndIf
EndEvent

Event OnConfigOpen()
    parent.OnConfigOpen()
    If !migrated
        MigrateToMCMHelper()
        migrated = True
    EndIf
EndEvent

Event OnConfigInit()
    parent.OnConfigInit()
    migrated = True
    LoadSettings()
EndEvent

Event OnSettingChange(String a_ID)
    parent.OnSettingChange(a_ID)
    If a_ID == "bDL_Toggle:General"
        LB_DL_Toggle.SetValue(GetModSettingBool("bDL_Toggle:General") as Float)
        (LB_ShadowSneakQuest.GetAlias(0) as ReferenceAlias).OnPlayerLoadGame()
        RefreshMenu()
    ElseIf a_ID == "bHID_Toggle:General"
        LB_HID_Toggle.SetValue(GetModSettingBool("bHID_Toggle:General") as Float)
        (LB_ShadowSneakQuest.GetAlias(0) as ReferenceAlias).OnPlayerLoadGame()
        RefreshMenu()
    ElseIf a_ID == "bSearchAllowed:General"
        LB_SearchAllowed.SetValue(GetModSettingBool("bSearchAllowed:General") as Float)
        (LB_ShadowSneakQuest.GetAlias(0) as ReferenceAlias).OnPlayerLoadGame()
        RefreshMenu()
    ElseIf a_ID == "fCD_Slider:General"
        LB_CD_Slider.SetValue(GetModSettingFloat("fCD_Slider:General") as Float)
        (LB_ShadowSneakQuest.GetAlias(0) as ReferenceAlias).OnPlayerLoadGame()
        RefreshMenu()
    EndIf
EndEvent

Event OnPageSelect(String a_page)
    parent.OnPageSelect(a_page)
EndEvent

Function Default()
    SetModSettingBool("bDL_Toggle:General", True)
    SetModSettingBool("bHID_Toggle:General", True)
    SetModSettingBool("bSearchAllowed:General", True)
    SetModSettingFloat("fCD_Slider:General", 25.0)

    SetModSettingBool("bEnabled:Maintenance", True)
    SetModSettingInt("iLoadingDelay:Maintenance", 0)
    SetModSettingBool("bLoadSettingsonReload:Maintenance", False)
    Load()
EndFunction

Function Load()
    LB_DL_Toggle.SetValue(GetModSettingBool("bDL_Toggle:General") as Float)
    LB_HID_Toggle.SetValue(GetModSettingBool("bHID_Toggle:General") as Float)
    LB_SearchAllowed.SetValue(GetModSettingBool("bSearchAllowed:General") as Float)
    LB_CD_Slider.SetValue(GetModSettingFloat("fCD_Slider:General") as Float)
    (LB_ShadowSneakQuest.GetAlias(0) as ReferenceAlias).OnPlayerLoadGame()
EndFunction

Function LoadSettings()
    If GetModSettingBool("bEnabled:Maintenance") == False
        Return
    EndIf
    Utility.Wait(GetModSettingInt("iLoadingDelay:Maintenance"))
    Load()
EndFunction

Function MigrateToMCMHelper()
    SetModSettingBool("bDL_Toggle:General", LB_DL_Toggle.GetValue() as Bool)
    SetModSettingBool("bHID_Toggle:General", LB_HID_Toggle.GetValue() as Bool)
    SetModSettingBool("bSearchAllowed:General", LB_SearchAllowed.GetValue() as Bool)
    SetModSettingFloat("fCD_Slider:General", LB_CD_Slider.GetValue() as Float)
EndFunction
