-- ============================================
-- Event Menu Shared
-- Общие функции и сетевые сообщения
-- ============================================

-- Конфигурация загружается автоматически первой (sh_event_menu_00_config.lua)

-- Регистрация сетевых сообщений
if SERVER then
    util.AddNetworkString("EventMenu_RequestPlayers")
    util.AddNetworkString("EventMenu_UpdatePlayers")
    util.AddNetworkString("EventMenu_AssignTeam")
    util.AddNetworkString("EventMenu_ExecuteAction")
    util.AddNetworkString("EventMenu_SetMaxPlayers")
    util.AddNetworkString("EventMenu_ToggleEvent")
    util.AddNetworkString("EventMenu_StartEvent")
    util.AddNetworkString("EventMenu_EndEvent")
    util.AddNetworkString("EventMenu_CheckAccess")
    util.AddNetworkString("EventMenu_SaveTemplate")
    util.AddNetworkString("EventMenu_ApplyTemplate")
    util.AddNetworkString("EventMenu_RequestTemplates")
    util.AddNetworkString("EventMenu_SendTemplates")
    util.AddNetworkString("EventMenu_DeleteTemplate")
    util.AddNetworkString("EventMenu_AvatarUpdate")
    util.AddNetworkString("EventMenu_OpenBestart")
    util.AddNetworkString("EventMenu_BestartStart")
    util.AddNetworkString("EventMenu_OpenEventMenu")
    util.AddNetworkString("EventMenu_BulkAction")
    util.AddNetworkString("EventMenu_WeaponPreset")
    util.AddNetworkString("EventMenu_RequestWeaponPresets")
    util.AddNetworkString("EventMenu_SendWeaponPresets")
    util.AddNetworkString("EventMenu_SetStartTemplate")
    util.AddNetworkString("EventMenu_Invitation")
end

-- Константы действий
EventMenuActions = EventMenuActions or {
    WALK_SPEED = "walk_speed",
    RUN_SPEED = "run_speed",
    TELEPORT = "teleport",
    GIVE_HEALTH = "give_health",
    GIVE_ARMOR = "give_armor",
    GODMODE = "godmode",
    GIVE_WEAPON = "give_weapon",
    STRIP_WEAPON = "strip_weapon",
    MUTE = "mute",
    GAG = "gag",
    KICK_FROM_EVENT = "kick_from_event"
}

-- Цвета команд (shared для использования на клиенте и сервере)
EventMenuTeamColors = EventMenuTeamColors or {
    ["red"] = Color(248, 113, 113),
    ["blue"] = Color(96, 165, 250),
    ["green"] = Color(74, 222, 128),
    ["yellow"] = Color(250, 204, 21),
    ["purple"] = Color(192, 132, 252),
    ["none"] = Color(82, 82, 91)
}
