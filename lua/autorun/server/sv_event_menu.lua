if CLIENT then return end -- Этот скрипт только для сервера

-- ============================================
-- Event Menu Server Side
-- Управление событиями и игроками
-- ============================================

-- API ключ для аватарок (из конфига или запасной)
EventMenuConfig = EventMenuConfig or {}
if not EventMenuConfig.SteamAPIKey or EventMenuConfig.SteamAPIKey == "" then
    EventMenuConfig.SteamAPIKey = "YOUR_STEAM_API_KEY_HERE" -- Вставьте сюда ваш Steam API ключ
end

-- Регистрация сетевых сообщений (должно быть первым делом!)
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
util.AddNetworkString("EventMenu_SetStartTemplate")
util.AddNetworkString("EventMenu_SaveCustomTemplate")
util.AddNetworkString("EventMenu_Invitation")
util.AddNetworkString("EventMenu_RequestWeaponList")
util.AddNetworkString("EventMenu_SendWeaponList")

-- Таблица для хранения данных игроков в событии
EventMenu = EventMenu or {}
EventMenu.Players = EventMenu.Players or {} -- { [steamid] = { team = "red", ... } } — только игроки, вступившие через !join
EventMenu.MaxPlayers = EventMenu.MaxPlayers or 100 -- лимит на ивент, не на сервер
EventMenu.EventOpen = EventMenu.EventOpen or false
EventMenu.EventActive = EventMenu.EventActive or false -- ивент запущен (Start/End кнопки)
EventMenu.EventName = EventMenu.EventName or ""
EventMenu.EventType = EventMenu.EventType or "standard" -- standard, elimination, creative
EventMenu.StripWeapons = EventMenu.StripWeapons or false
EventMenu.StartPos = EventMenu.StartPos or Vector(0,0,0)
EventMenu.StartAng = EventMenu.StartAng or Angle(0,0,0)
EventMenu.Templates = EventMenu.Templates or {}
EventMenu.TemplateNextId = EventMenu.TemplateNextId or 1
EventMenu.AvatarCache = EventMenu.AvatarCache or {}
EventMenu.SpawnPoints = EventMenu.SpawnPoints or {} -- { all = {pos,ang}, red = {pos,ang}, ... }
EventMenu.PlayerWeaponPreset = EventMenu.PlayerWeaponPreset or {} -- steamid -> {weapons}
EventMenu.PlayerModelPreset = EventMenu.PlayerModelPreset or {} -- steamid -> {model, runspeed, walkspeed, modelscale}
EventMenu.CollisionEnabled = EventMenu.CollisionEnabled or true
EventMenu.StartTemplateId = EventMenu.StartTemplateId or "" -- шаблон для выдачи при заходе в ивент

local TEMPLATES_FILE = "event_menu/templates.txt"

-- Получить SteamID64 (используем встроенные функции GMod)
local function SteamIDTo64Fallback(steamid)
    local x, y = string.match(steamid, "STEAM_%d+:(%d+):(%d+)")
    if x and y then
        x, y = tonumber(x) or 0, tonumber(y) or 0
        return tostring(76561197960265728 + y * 2 + x)
    end
    return nil
end
local function GetSteamID64(plyOrSteamid)
    if not plyOrSteamid then return nil end
    if type(plyOrSteamid) == "Player" and IsValid(plyOrSteamid) then
        local sid64 = plyOrSteamid:SteamID64()
        if sid64 and sid64 ~= "0" and sid64 ~= "" then return tostring(sid64) end
        local sid = plyOrSteamid:SteamID()
        return (util.SteamIDTo64 and util.SteamIDTo64(sid)) or SteamIDTo64Fallback(sid)
    end
    local steamid = type(plyOrSteamid) == "string" and plyOrSteamid or nil
    if not steamid or steamid == "" or steamid == "STEAM_ID_PENDING" or steamid == "STEAM_ID_LAN" then return nil end
    return (util.SteamIDTo64 and util.SteamIDTo64(steamid)) or SteamIDTo64Fallback(steamid)
end

-- Проверка прав доступа (нужна для SendAvatarToAdmins)
local function HasEventMenuAccess(ply)
    if not IsValid(ply) then return false end
    if ply.IsSuperAdmin and ply:IsSuperAdmin() then return true end
    if ply:IsAdmin() then return true end
    if EventMenuConfig and EventMenuConfig.HasAccess then
        if EventMenuConfig.HasAccess(ply) then return true end
    end
    return false
end

-- Отправить аватарку всем админам (должна быть объявлена до FetchAvatars)
local function SendAvatarToAdmins(steamid, avatarData)
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and HasEventMenuAccess(ply) then
            net.Start("EventMenu_AvatarUpdate")
            net.WriteString(steamid)
            net.WriteString(avatarData)
            net.Send(ply)
        end
    end
end

-- Загрузка аватарок через Steam API
local avatarFetchQueue = {}
local avatarFetchTimer = nil

local function FetchAvatars()
    if not EventMenuConfig or not EventMenuConfig.SteamAPIKey or EventMenuConfig.SteamAPIKey == "" then
        print("[EventMenu] Аватарки: API ключ не настроен")
        return
    end
    if next(avatarFetchQueue) == nil then return end
    
    local ids = {}
    for steamid, _ in pairs(avatarFetchQueue) do
        local sid64 = GetSteamID64(steamid)
        if sid64 then
            table.insert(ids, sid64)
        else
            print("[EventMenu] Пропущен steamid (не конвертируется): " .. tostring(steamid))
        end
        avatarFetchQueue[steamid] = nil
    end
    if #ids == 0 then return end
    
    local apiKey = EventMenuConfig.SteamAPIKey or ""
    local url = "https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v2/?key=" .. apiKey .. "&steamids=" .. table.concat(ids, ",")
    print("[EventMenu] Запрос аватарок для " .. #ids .. " игроков, steamids: " .. table.concat(ids, ","))
    
    http.Fetch(url, function(body, len, headers, code)
        if code ~= 200 or not body then
            if code and code ~= 200 then print("[EventMenu] Steam API: code " .. tostring(code)) end
            return
        end
        local ok, data = pcall(util.JSONToTable, body)
        if not ok or not data then
            print("[EventMenu] Steam API: invalid JSON")
            return
        end
        if not data.response then
            print("[EventMenu] Steam API: нет response, body: " .. (body and body:sub(1, 500) or "nil"))
            return
        end
        data.response.players = data.response.players or {}
        
        EventMenu.AvatarCache = EventMenu.AvatarCache or {}
        local toFetch = {}
        if #data.response.players == 0 then
            if data.response.error then
                print("[EventMenu] Steam API error: " .. tostring(data.response.error))
            else
                print("[EventMenu] Steam API: 0 игроков. Проверьте: 1) steamid в логе выше 2) ключ без ограничения домена. Ответ: " .. (body and body:sub(1, 400) or "nil"))
            end
        end
        print("[EventMenu] Steam API: получено " .. #data.response.players .. " игроков")
        for _, p in ipairs(data.response.players) do
            local steamid64 = p.steamid
            local avatarUrl = p.avatar or p.avatarmedium or p.avatarfull
            if avatarUrl then
                for _, ply in ipairs(player.GetAll()) do
                    if IsValid(ply) and tostring(ply:SteamID64()) == tostring(steamid64) then
                        toFetch[#toFetch + 1] = { steamid = ply:SteamID(), url = avatarUrl }
                        break
                    end
                end
            end
        end
        
        local idx = 1
        local function fetchNext()
            if idx > #toFetch then return end
            local t = toFetch[idx]
            idx = idx + 1
            http.Fetch(t.url, function(imgBody, imgLen, imgHeaders, imgCode)
                if imgCode == 200 and imgBody and #imgBody > 0 and #imgBody < 20000 then
                    local ok, b64 = pcall(util.Base64Encode, imgBody, true)
                    if ok and b64 and type(b64) == "string" and #b64 > 0 and #b64 < 30000 then
                        local dataUri = "data:image/jpeg;base64," .. b64
                        EventMenu.AvatarCache[t.steamid] = dataUri
                        SendAvatarToAdmins(t.steamid, dataUri)
                        print("[EventMenu] Аватар загружен: " .. t.steamid)
                    end
                end
                timer.Simple(0.1, fetchNext)
            end, function()
                timer.Simple(0.1, fetchNext)
            end)
        end
        if #toFetch > 0 then fetchNext() end
    end, function(err)
        print("[EventMenu] Steam API failed: " .. tostring(err))
    end)
end

local function QueueAvatarFetch(steamid)
    if not steamid or steamid == "STEAM_ID_PENDING" or steamid == "STEAM_ID_LAN" then return end
    if EventMenu.AvatarCache and EventMenu.AvatarCache[steamid] then return end
    if not GetSteamID64(steamid) then return end -- не конвертируется — не запрашиваем
    avatarFetchQueue[steamid] = true
    if not avatarFetchTimer then
        avatarFetchTimer = true
        timer.Simple(0.2, function()
            avatarFetchTimer = nil
            FetchAvatars()
        end)
    end
end

local function LoadTemplates()
    file.CreateDir("event_menu")
    local data = file.Read(TEMPLATES_FILE, "DATA")
    if data and data ~= "" then
        local ok, tbl = pcall(util.JSONToTable, data)
        if ok and tbl then
            local rawTemplates = tbl.templates or {}
            -- Нормализуем ключи: JSON может преобразовать строковые числа в Lua-числа
            local normalized = {}
            for k, v in pairs(rawTemplates) do
                normalized[tostring(k)] = v
            end
            EventMenu.Templates = normalized
            EventMenu.TemplateNextId = tbl.nextId or 1
        end
    end
end

local function SaveTemplates()
    file.CreateDir("event_menu")
    local data = util.TableToJSON({
        templates = EventMenu.Templates,
        nextId = EventMenu.TemplateNextId
    })
    file.Write(TEMPLATES_FILE, data)
end

LoadTemplates()


-- Цвета команд
EventMenu.Teams = {
    ["red"] = Color(248, 113, 113),
    ["blue"] = Color(96, 165, 250),
    ["green"] = Color(74, 222, 128),
    ["yellow"] = Color(250, 204, 21),
    ["purple"] = Color(192, 132, 252),
    ["none"] = Color(82, 82, 91)
}

-- Получить данные игрока для меню (avatar отправляется отдельно)
local function GetPlayerData(ply)
    if not IsValid(ply) then return nil end
    
    local steamid = ply:SteamID()
    if not EventMenu.Players[steamid] then return nil end
    
    local team = EventMenu.Players[steamid].team or "none"
    
    QueueAvatarFetch(steamid)
    
    return {
        id = ply:UserID(),
        name = ply:Nick(),
        team = team,
        steamId = steamid,
        avatar = EventMenu.AvatarCache and EventMenu.AvatarCache[steamid],
        muted = ply:GetNWBool("EventMuted", false),
        gagged = ply:GetNWBool("EventGagged", false),
        godmode = ply:GetNWBool("EventGodmode", false)
    }
end

-- Получить список игроков в ивенте (только те, кто !join)
local function GetAllPlayersData()
    local playersData = {}
    
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) then
            local steamid = ply:SteamID()
            if EventMenu.Players[steamid] then
                table.insert(playersData, GetPlayerData(ply))
            end
        end
    end
    
    return playersData
end

-- Сохранить шаблон с позиции игрока
local function SaveTemplateFromPlayer(ply, name)
    if not IsValid(ply) or not name or name == "" then return nil end
    
    local pos = ply:GetPos()
    local ang = ply:GetAngles()
    local model = ply:GetModel()
    
    local health = ply:Health()
    local maxHealth = ply:GetMaxHealth()
    local armor = ply:Armor()
    local walkSpeed = ply:GetWalkSpeed()
    local runSpeed = ply:GetRunSpeed()
    
    local weapons = {}
    for _, wep in ipairs(ply:GetWeapons()) do
        if IsValid(wep) and wep:IsWeapon() then
            local cls = wep:GetClass()
            if cls and cls ~= "weapon_physcannon" and cls ~= "weapon_physgun" and cls ~= "gmod_tool" then
                table.insert(weapons, cls)
            end
        end
    end
    
    local id = tostring(EventMenu.TemplateNextId)
    EventMenu.TemplateNextId = EventMenu.TemplateNextId + 1
    
    EventMenu.Templates[id] = {
        name = name,
        model = model,
        pos = {pos.x, pos.y, pos.z},
        ang = {ang.p, ang.y, ang.r},
        weapons = weapons,
        health = health,
        maxHealth = maxHealth,
        armor = armor,
        walkSpeed = walkSpeed,
        runSpeed = runSpeed
    }
    
    SaveTemplates()
    return id
end

-- Применить шаблон к игрокам
local function ApplyTemplateToPlayers(templateId, playerIds, adminPos)
    local tpl = EventMenu.Templates[templateId]
    if not tpl then return 0 end
    
    local pos = Vector(tpl.pos[1], tpl.pos[2], tpl.pos[3])
    local ang = Angle(tpl.ang[1], tpl.ang[2], tpl.ang[3])
    
    local count = 0
    for i, playerId in ipairs(playerIds) do
        local target = Player(playerId)
        if IsValid(target) then
            -- Модель
            if tpl.model and tpl.model ~= "" and util.IsValidModel(tpl.model) then
                target:SetModel(tpl.model)
            end
            
            -- Позиция (небольшой сдвиг по Z чтобы не пересекались)
            local offset = Vector(0, 0, (i - 1) * 3)
            target:SetPos(pos + offset)
            target:SetAngles(ang)
            
            if tpl.health then target:SetHealth(tpl.health) end
            if tpl.maxHealth then target:SetMaxHealth(tpl.maxHealth) end
            if tpl.armor then target:SetArmor(tpl.armor) end
            if tpl.walkSpeed then target:SetWalkSpeed(tpl.walkSpeed) end
            if tpl.runSpeed then target:SetRunSpeed(tpl.runSpeed) end
            
            -- Оружие
            target:StripWeapons()
            for _, wepClass in ipairs(tpl.weapons or {}) do
                target:Give(wepClass)
            end
            
            -- Сохранение пресета для восстановления при спавне
            local steamid = target:SteamID()
            EventMenu.PlayerWeaponPreset[steamid] = tpl.weapons or {}
            EventMenu.PlayerModelPreset[steamid] = {
                model = tpl.model or target:GetModel(),
                runspeed = tpl.runSpeed or target:GetRunSpeed(),
                walkspeed = tpl.walkSpeed or target:GetWalkSpeed(),
                modelscale = target.GetModelScale and target:GetModelScale() or 1,
                health = tpl.health,
                maxhealth = tpl.maxHealth,
                armor = tpl.armor
            }
            
            count = count + 1
        end
    end
    
    return count
end

-- Отправить список шаблонов игроку (включая стартовый шаблон)
local function SendTemplatesToPlayer(ply)
    if not HasEventMenuAccess(ply) then return end
    
    local list = {}
    for id, tpl in pairs(EventMenu.Templates) do
        table.insert(list, {
            id = id,
            name = tpl.name or "Без названия",
            model = tpl.model or "",
            weaponsCount = #(tpl.weapons or {})
        })
    end
    
    net.Start("EventMenu_SendTemplates")
    net.WriteTable({
        list = list,
        startTemplateId = EventMenu.StartTemplateId or ""
    })
    net.Send(ply)
end

-- Отправить список доступного оружия игроку
local function SendWeaponListToPlayer(ply)
    if not HasEventMenuAccess(ply) then return end
    
    local weaponList = {}
    local weaponClasses = weapons.GetList()
    local addedClasses = {}
    
    -- Базовые HL2 пушки (они часто не попадают в weapons.GetList(), так как вшиты в движок)
    local baseHL2 = {
        { name = "Magnum .357", cls = "weapon_357", cat = "Half-Life 2" },
        { name = "AR2", cls = "weapon_ar2", cat = "Half-Life 2" },
        { name = "Crossbow", cls = "weapon_crossbow", cat = "Half-Life 2" },
        { name = "Crowbar", cls = "weapon_crowbar", cat = "Half-Life 2" },
        { name = "Frag Grenade", cls = "weapon_frag", cat = "Half-Life 2" },
        { name = "Pistol", cls = "weapon_pistol", cat = "Half-Life 2" },
        { name = "RPG", cls = "weapon_rpg", cat = "Half-Life 2" },
        { name = "Shotgun", cls = "weapon_shotgun", cat = "Half-Life 2" },
        { name = "SMG", cls = "weapon_smg1", cat = "Half-Life 2" },
        { name = "357", cls = "weapon_357", cat = "Half-Life 2" },
        { name = "Bugbait", cls = "weapon_bugbait", cat = "Half-Life 2" },
        { name = "Stunstick", cls = "weapon_stunstick", cat = "Half-Life 2" },
        { name = "Slam", cls = "weapon_slam", cat = "Half-Life 2" }
    }

    for _, w in ipairs(baseHL2) do
        table.insert(weaponList, w)
        addedClasses[w.cls] = true
    end
    
    for _, wep in ipairs(weaponClasses) do
        local cls = wep.ClassName
        if not cls or cls == "" or addedClasses[cls] then continue end
        
        -- Пропускаем базовые или ненужные инструменты, если нужно
        if cls == "weapon_physgun" or cls == "gmod_tool" or cls == "weapon_physcannon" then continue end
        
        table.insert(weaponList, {
            name = wep.PrintName or cls,
            cls = cls,
            cat = wep.Category or "Прочее"
        })
    end
    
    -- Сортировка по алфавиту для удобства
    table.sort(weaponList, function(a, b) return a.name < b.name end)

    net.Start("EventMenu_SendWeaponList")
    net.WriteTable(weaponList)
    net.Send(ply)
end

-- Обработка запроса списка оружия
net.Receive("EventMenu_RequestWeaponList", function(len, ply)
    if not HasEventMenuAccess(ply) then return end
    SendWeaponListToPlayer(ply)
end)

-- Отправить обновленный список игроков и состояние события всем админам
local function SendPlayersUpdate()
    local playersData = GetAllPlayersData()
    local payload = { 
        players = playersData, 
        eventOpen = EventMenu.EventOpen, 
        eventActive = EventMenu.EventActive,
        maxPlayers = EventMenu.MaxPlayers 
    }
    
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and HasEventMenuAccess(ply) then
            net.Start("EventMenu_UpdatePlayers")
            net.WriteTable(payload)
            net.Send(ply)
        end
    end
end

-- Общая функция для завершения события
function EventMenu.StopEvent()
    print("[EventMenu] Запуск завершения события...")
    if not EventMenu.EventActive then 
        print("[EventMenu] Ошибка: Попытка завершить неактивное событие.")
        return 
    end

    -- Сброс эффектов только у участников ивента
    for steamid, _ in pairs(EventMenu.Players) do
        local p = player.GetBySteamID(steamid)
        if IsValid(p) then
            print("[EventMenu] Сброс параметров для: " .. p:Nick())
            p:GodDisable()
            p:SetMuted(false)
            p:SetWalkSpeed(200)
            p:SetRunSpeed(400)
            p:SetNWBool("EventMuted", false)
            p:SetNWBool("EventGagged", false)
            p:SetNWBool("EventGodmode", false)
            p:KillSilent() -- Умирает при завершении ивента
        end
    end
    
    EventMenu.Players = {}
    EventMenu.EventOpen = false
    EventMenu.EventActive = false
    EventMenu.StartTemplateId = ""
    EventMenu.SpawnPoints = {}
    EventMenu.PlayerWeaponPreset = {}
    EventMenu.PlayerModelPreset = {}
    
    -- Полная очистка всех шаблонов
    print("[EventMenu] Очистка всех шаблонов после ивента...")
    EventMenu.Templates = {}
    EventMenu.TemplateNextId = 1
    SaveTemplates()

    -- Отправляем обновленные данные всем админам
    for _, p in ipairs(player.GetAll()) do
        if IsValid(p) and HasEventMenuAccess(p) then
            SendTemplatesToPlayer(p)
        end
    end
    
    SendPlayersUpdate()
    for _, p in ipairs(player.GetAll()) do
        if IsValid(p) then p:ChatPrint("[EventMenu] Ивент завершён") end
    end
    print("[EventMenu] Событие успешно завершено.")
end

-- ============================================
-- СЕТЕВЫЕ СООБЩЕНИЯ
-- ============================================

-- Проверка прав доступа (запрос от клиента)
net.Receive("EventMenu_CheckAccess", function(len, ply)
    if not IsValid(ply) then return end
    
    local hasAccess = HasEventMenuAccess(ply)
    net.Start("EventMenu_CheckAccess")
    net.WriteBool(hasAccess)
    net.Send(ply)
end)

-- Запрос списка игроков
net.Receive("EventMenu_RequestPlayers", function(len, ply)
    if not HasEventMenuAccess(ply) then return end
    
    local playersData = GetAllPlayersData()
    local payload = { 
        players = playersData, 
        eventOpen = EventMenu.EventOpen, 
        eventActive = EventMenu.EventActive,
        maxPlayers = EventMenu.MaxPlayers 
    }
    net.Start("EventMenu_UpdatePlayers")
    net.WriteTable(payload)
    net.Send(ply)
end)

-- Установка команды игрокам
net.Receive("EventMenu_AssignTeam", function(len, ply)
    if not HasEventMenuAccess(ply) then return end
    
    local team = net.ReadString()
    local playerIds = net.ReadTable()
    
    local count = 0
    for _, playerId in ipairs(playerIds) do
        local target = Player(playerId)
        if IsValid(target) then
            local steamid = target:SteamID()
            if not EventMenu.Players[steamid] then
                EventMenu.Players[steamid] = {}
            end
            EventMenu.Players[steamid].team = team
            
            -- Визуальная индикация команды (можно расширить)
            if team ~= "none" then
                local color = EventMenu.Teams[team] or EventMenu.Teams["none"]
                -- Можно добавить эффекты, например, свечение
            end
            
            count = count + 1
        end
    end
    
    SendPlayersUpdate()
    ply:ChatPrint("[EventMenu] Команда '" .. team .. "' назначена " .. count .. " игрокам")
end)

-- Выполнение действия
net.Receive("EventMenu_ExecuteAction", function(len, ply)
    if not HasEventMenuAccess(ply) then return end
    
    local action = net.ReadString()
    local playerIds = net.ReadTable()
    local value = net.ReadFloat()
    local needStr = (action == "give_weapon" or action == "model_color" or action == "set_model")
    local extraStr = needStr and net.ReadString() or ""
    
    local count = 0
    for _, playerId in ipairs(playerIds) do
        local target = Player(playerId)
        if not IsValid(target) then continue end
        
        if action == "walk_speed" then
            target:SetWalkSpeed(value > 0 and value or 200)
            count = count + 1
            
        elseif action == "run_speed" then
            target:SetRunSpeed(value > 0 and value or 400)
            count = count + 1
            
        elseif action == "teleport" then
            -- Телепорт к позиции админа (можно расширить)
            local adminPos = ply:GetPos()
            target:SetPos(adminPos + Vector(0, 0, 50))
            count = count + 1
            
        elseif action == "give_health" then
            local health = math.Clamp(value > 0 and value or 100, 1, 1000)
            target:SetHealth(health)
            target:SetMaxHealth(health)
            count = count + 1
            
        elseif action == "give_armor" then
            local armor = math.Clamp(value > 0 and value or 100, 0, 255)
            target:SetArmor(armor)
            count = count + 1
            
        elseif action == "godmode" then
            -- Toggle годмод
            local isGodmode = target:GetNWBool("EventGodmode", false)
            if isGodmode then
                target:GodDisable()
                target:SetNWBool("EventGodmode", false)
            else
                target:GodEnable()
                target:SetNWBool("EventGodmode", true)
            end
            count = count + 1
            
        elseif action == "toggle_nick_visibility" then
            local hidden = not target:GetNWBool("PlayerNickHidden", false)
            target:SetNWBool("PlayerNickHidden", hidden)
            count = count + 1
            
        elseif action == "give_weapon" then
            if extraStr and extraStr ~= "" then
                target:Give(extraStr)
                count = count + 1
            end
            
        elseif action == "strip_weapon" then
            target:StripWeapons()
            count = count + 1
            
        elseif action == "mute" then
            -- Toggle мут текстового чата
            local isMuted = target:GetNWBool("EventMuted", false)
            if isMuted then
                target:SetNWBool("EventMuted", false)
            else
                target:SetNWBool("EventMuted", true)
            end
            count = count + 1
            
        elseif action == "gag" then
            -- Toggle гаг голосового чата
            local isGagged = target:GetNWBool("EventGagged", false)
            if isGagged then
                target:SetMuted(false)
                target:SetNWBool("EventGagged", false)
            else
                target:SetMuted(true)
                target:SetNWBool("EventGagged", true)
            end
            count = count + 1
            
        elseif action == "kick_from_event" then
            local steamid = target:SteamID()
            if EventMenu.Players[steamid] then
                target:GodDisable()
                target:SetMuted(false)
                target:SetNWBool("EventMuted", false)
                target:SetNWBool("EventGagged", false)
                target:SetNWBool("EventGodmode", false)
                EventMenu.Players[steamid] = nil
                target:KillSilent() -- Умирает при кике с ивента
            end
            count = count + 1
            
        elseif action == "model_scale" then
            local scale = math.Clamp(value > 0 and value or 1, 0.1, 5)
            if target.SetModelScale then
                target:SetModelScale(scale, 0)
                -- Пересчет позиции камеры для корректного отображения при изменении размера
                local currentPos = target:GetPos()
                target:SetPos(currentPos + Vector(0, 0, 0.1))
                timer.Simple(0.01, function()
                    if IsValid(target) then
                        target:SetPos(currentPos)
                    end
                end)
                count = count + 1
            end
            
        elseif action == "model_color" then
            if extraStr and extraStr ~= "" then
                local colorStr = extraStr
                local r, g, b = 255, 255, 255
                local parts = {}
                for p in string.gmatch(colorStr, "[^,]+") do table.insert(parts, tonumber(p)) end
                r = math.Clamp(parts[1] or 255, 0, 255)
                g = math.Clamp(parts[2] or 255, 0, 255)
                b = math.Clamp(parts[3] or 255, 0, 255)
                target:SetColor(Color(r, g, b))
                count = count + 1
            end
            
        elseif action == "give_hunger" then
            if target.SetHunger then
                target:SetHunger(math.Clamp(value >= 0 and value or 100, 0, 100))
                count = count + 1
            end
            
        elseif action == "set_model" then
            if extraStr and extraStr ~= "" and util.IsValidModel(extraStr) then
                target:SetModel(extraStr)
                count = count + 1
            end
            
            
        elseif action == "save_model_preset_death" then
            local steamid = target:SteamID()
            if EventMenu.Players[steamid] then
                EventMenu.PlayerModelPreset[steamid] = {
                    model = target:GetModel(),
                    runspeed = target:GetRunSpeed(),
                    walkspeed = target:GetWalkSpeed(),
                    modelscale = target.GetModelScale and target:GetModelScale() or 1,
                    health = target:Health(),
                    maxhealth = target:GetMaxHealth(),
                    armor = target:Armor()
                }
                count = count + 1
            end
            
            
        elseif action == "set_spawn_team" then
            if EventMenu.Players[target:SteamID()] then
                local team = EventMenu.Players[target:SteamID()].team or "none"
                if team ~= "none" then
                    EventMenu.SpawnPoints[team] = { pos = ply:GetPos(), ang = ply:GetAngles() }
                    count = count + 1
                end
            end
            
        elseif action == "respawn_team" then
            if EventMenu.Players[target:SteamID()] then
                local team = EventMenu.Players[target:SteamID()].team or "none"
                local sp = EventMenu.SpawnPoints[team] or EventMenu.SpawnPoints["all"] or { pos = EventMenu.StartPos, ang = EventMenu.StartAng }
                target:Spawn()
                target:SetPos(sp.pos)
                target:SetAngles(sp.ang)
                count = count + 1
            end

        elseif action == "kill" then
            target:Kill()
            count = count + 1

        elseif action == "jump_height" then
            target:SetJumpPower(value > 0 and value or 200)
            count = count + 1

        elseif action == "respawn" then
            target:Spawn()
            count = count + 1

        elseif action == "punch" then
            target:SetVelocity(Vector(math.random(-250, 250), math.random(-250, 250), 500))
            count = count + 1

        elseif action == "ignite" then
            target:Ignite(10)
            count = count + 1
        end
    end
    
    SendPlayersUpdate()
    ply:ChatPrint("[EventMenu] Действие '" .. action .. "' применено к " .. count .. " игрокам")
end)

-- Массовые действия (без выбора игроков или с особым контекстом)
net.Receive("EventMenu_BulkAction", function(len, ply)
    if not HasEventMenuAccess(ply) then return end
    
    local action = net.ReadString()
    local team = net.ReadString()
    
    if action == "set_spawn_all" then
        EventMenu.SpawnPoints["all"] = { pos = ply:GetPos(), ang = ply:GetAngles() }
        ply:ChatPrint("[EventMenu] Спавн для всех установлен")
        
    elseif action == "set_spawn_team" then
        if team and team ~= "" and team ~= "none" then
            EventMenu.SpawnPoints[team] = { pos = ply:GetPos(), ang = ply:GetAngles() }
            ply:ChatPrint("[EventMenu] Спавн для команды '" .. team .. "' установлен")
        else
            ply:ChatPrint("[EventMenu] Выберите команду для спавна")
        end
        
    elseif action == "teleport_all" then
        local adminPos = ply:GetPos()
        local count = 0
        for steamid, _ in pairs(EventMenu.Players) do
            local p = player.GetBySteamID(steamid)
            if IsValid(p) then
                p:SetPos(adminPos + Vector(0, 0, count * 2))
                p:SetAngles(ply:GetAngles())
                count = count + 1
            end
        end
        ply:ChatPrint("[EventMenu] Телепортировано " .. count .. " игроков")
        
    elseif action == "toggle_collision" then
        EventMenu.CollisionEnabled = not EventMenu.CollisionEnabled
        local group = EventMenu.CollisionEnabled and COLLISION_GROUP_PLAYER or COLLISION_GROUP_PASSABLE_DOOR
        for steamid, _ in pairs(EventMenu.Players) do
            local p = player.GetBySteamID(steamid)
            if IsValid(p) then p:SetCollisionGroup(group) end
        end
        ply:ChatPrint("[EventMenu] Столкновение " .. (EventMenu.CollisionEnabled and "включено" or "выключено"))
    end
    SendPlayersUpdate()
end)


-- Установка лимита игроков
net.Receive("EventMenu_SetMaxPlayers", function(len, ply)
    if not HasEventMenuAccess(ply) then return end
    
    EventMenu.MaxPlayers = net.ReadUInt(16)
    ply:ChatPrint("[EventMenu] Лимит игроков установлен: " .. EventMenu.MaxPlayers)
end)

-- Сохранить шаблон с текущей позиции админа
net.Receive("EventMenu_SaveTemplate", function(len, ply)
    if not HasEventMenuAccess(ply) then return end
    
    local name = net.ReadString()
    if not name or name == "" then return end
    
    local id = SaveTemplateFromPlayer(ply, name)
    if id then
        SendTemplatesToPlayer(ply)
        ply:ChatPrint("[EventMenu] Шаблон '" .. name .. "' сохранён")
    end
end)

-- Сохранить кастомный шаблон (с ручной настройкой)
net.Receive("EventMenu_SaveCustomTemplate", function(len, ply)
    if not HasEventMenuAccess(ply) then return end
    
    local data = net.ReadTable()
    if not data or not data.name or data.name == "" then return end
    
    local pos = ply:GetPos()
    local ang = ply:GetAngles()
    
    local id = tostring(EventMenu.TemplateNextId)
    EventMenu.TemplateNextId = EventMenu.TemplateNextId + 1
    
    EventMenu.Templates[id] = {
        name = data.name,
        model = data.model or "models/player/kleiner.mdl",
        pos = {pos.x, pos.y, pos.z},
        ang = {ang.p, ang.y, ang.r},
        weapons = data.weapons or {},
        health = tonumber(data.health) or 100,
        maxHealth = tonumber(data.health) or 100,
        armor = tonumber(data.armor) or 0,
        walkSpeed = tonumber(data.walkSpeed) or 200,
        runSpeed = tonumber(data.runSpeed) or 400
    }
    
    SaveTemplates()
    SendTemplatesToPlayer(ply)
    ply:ChatPrint("[EventMenu] Кастомный шаблон '" .. data.name .. "' сохранён")
end)

-- Применить шаблон к игрокам
net.Receive("EventMenu_ApplyTemplate", function(len, ply)
    if not HasEventMenuAccess(ply) then return end
    
    local templateId = net.ReadString()
    local playerIds = net.ReadTable()
    
    local count = ApplyTemplateToPlayers(templateId, playerIds, ply:GetPos())
    SendPlayersUpdate()
    ply:ChatPrint("[EventMenu] Шаблон применён к " .. count .. " игрокам")
end)

-- Запрос списка шаблонов
net.Receive("EventMenu_RequestTemplates", function(len, ply)
    if not HasEventMenuAccess(ply) then return end
    SendTemplatesToPlayer(ply)
end)

-- Удалить шаблон
net.Receive("EventMenu_DeleteTemplate", function(len, ply)
    if not HasEventMenuAccess(ply) then return end
    
    local templateId = net.ReadString()
    if EventMenu.Templates[templateId] then
        EventMenu.Templates[templateId] = nil
        SaveTemplates()
        SendTemplatesToPlayer(ply)
        ply:ChatPrint("[EventMenu] Шаблон удалён")
    else
        ply:ChatPrint("[EventMenu] Ошибка: Шаблон с ID '" .. tostring(templateId) .. "' не найден.")
    end
end)

-- Установить стартовый шаблон (выдаётся при заходе в ивент)
net.Receive("EventMenu_SetStartTemplate", function(len, ply)
    if not HasEventMenuAccess(ply) then return end
    
    local templateId = net.ReadString()
    if templateId == "" or not EventMenu.Templates[templateId] then
        EventMenu.StartTemplateId = ""
    else
        EventMenu.StartTemplateId = templateId
    end
    SendTemplatesToPlayer(ply)
end)

-- Применить шаблон к игроку при заходе (модель, оружие, позиция)
local function ApplyStartTemplateToPlayer(ply, index)
    local tpl = EventMenu.Templates[EventMenu.StartTemplateId]
    if not tpl or not IsValid(ply) then return end
    
    local pos = Vector(tpl.pos[1], tpl.pos[2], tpl.pos[3])
    local ang = Angle(tpl.ang[1], tpl.ang[2], tpl.ang[3])
    local offset = Vector(0, 0, (index - 1) * 3)
    
    if tpl.model and tpl.model ~= "" and util.IsValidModel(tpl.model) then
        ply:SetModel(tpl.model)
    end
    ply:StripWeapons()
    for _, wepClass in ipairs(tpl.weapons or {}) do
        ply:Give(wepClass)
    end
    ply:SetPos(pos + offset)
    ply:SetAngles(ang)
    
    if tpl.health then ply:SetHealth(tpl.health) end
    if tpl.maxHealth then ply:SetMaxHealth(tpl.maxHealth) end
    if tpl.armor then ply:SetArmor(tpl.armor) end
    if tpl.walkSpeed then ply:SetWalkSpeed(tpl.walkSpeed) end
    if tpl.runSpeed then ply:SetRunSpeed(tpl.runSpeed) end

    -- Сохранение пресета для восстановления при спавне
    local steamid = ply:SteamID()
    EventMenu.PlayerWeaponPreset[steamid] = tpl.weapons or {}
    EventMenu.PlayerModelPreset[steamid] = {
        model = tpl.model or ply:GetModel(),
        runspeed = tpl.runSpeed or ply:GetRunSpeed(),
        walkspeed = tpl.walkSpeed or ply:GetWalkSpeed(),
        modelscale = ply.GetModelScale and ply:GetModelScale() or 1,
        health = tpl.health,
        maxhealth = tpl.maxHealth,
        armor = tpl.armor
    }
end

-- Применить настройки ивента к игроку при входе
local function ApplyEventToPlayer(ply)
    if not IsValid(ply) then return end
    
    ply:GodDisable()
    ply:SetWalkSpeed(200)
    ply:SetRunSpeed(400)
    
    if EventMenu.StartTemplateId and EventMenu.StartTemplateId ~= "" and EventMenu.Templates[EventMenu.StartTemplateId] then
        -- Шаблон применяется в JoinEvent с индексом
        return
    end
    
    if EventMenu.StripWeapons then
        ply:StripWeapons()
    end
    
    if EventMenu.EventType == "creative" then
        ply:Give("gmod_tool")
        ply:Give("weapon_physgun")
        ply:Give("weapon_physcannon")
    end
end

-- Запуск ивента из меню !eventstart (config + with/without notification)
net.Receive("EventMenu_BestartStart", function(len, ply)
    if not HasEventMenuAccess(ply) then return end
    if EventMenu.EventActive then return end -- ивент уже идёт
    
    local etype = net.ReadString()
    local strip = net.ReadBool()
    local limit = math.Clamp(net.ReadUInt(16), 0, 110)
    local withNotification = net.ReadBool()
    local eventName = net.ReadString()
    
    EventMenu.EventType = (etype == "elimination" or etype == "creative") and etype or "standard"
    EventMenu.StripWeapons = strip
    EventMenu.MaxPlayers = limit
    EventMenu.EventName = (eventName and eventName ~= "") and eventName or "Ивент"
    EventMenu.Players = {}
    EventMenu.StartPos = ply:GetPos()
    EventMenu.StartAng = ply:GetAngles()
    
    if withNotification then
        EventMenu.EventOpen = true
        EventMenu.EventActive = true
        local name = EventMenu.EventName ~= "" and EventMenu.EventName or "Ивент"
        for _, p in ipairs(player.GetAll()) do
            if IsValid(p) then
                p:ChatPrint("[EventMenu] ★ Начался ивент: " .. name .. " (лимит: " .. limit .. "). Войдите командой !join или /join")
            end
        end
        
        -- Вызов менюшки приглашения для всех
        net.Start("EventMenu_Invitation")
        net.WriteString(name)
        net.WriteUInt(limit, 16)
        net.Broadcast()
        
        ply:ChatPrint("[EventMenu] Ивент запущен с уведомлением")
    else
        EventMenu.EventOpen = false
        EventMenu.EventActive = false
        ply:ChatPrint("[EventMenu] Ивент подготовлен. Откройте меню и нажмите «Начать событие», когда будете готовы.")
    end
    
    SendPlayersUpdate()
    
    -- Открыть event_menu на клиенте
    net.Start("EventMenu_OpenEventMenu")
    net.Send(ply)
end)

-- Начать событие (позиция берётся с админа) — из кнопки в event_menu
net.Receive("EventMenu_StartEvent", function(len, ply)
    if not HasEventMenuAccess(ply) then return end
    if EventMenu.EventActive then return end -- ивент уже идёт
    
    local tplJson = net.ReadString()
    
    EventMenu.Players = {}
    EventMenu.EventOpen = true
    EventMenu.EventActive = true
    EventMenu.StartPos = ply:GetPos()
    EventMenu.StartAng = ply:GetAngles()
    
    -- Обработка временного шаблона
    if tplJson and tplJson ~= "" then
        local tplData = util.JSONToTable(tplJson)
        if tplData then
            local tplId = SaveTemplateFromPlayer(ply, "Temp_" .. EventMenu.EventName)
            if tplId and EventMenu.Templates[tplId] then
                local tpl = EventMenu.Templates[tplId]
                tpl.isTemporary = true
                tpl.health = tonumber(tplData.health) or 100
                tpl.maxHealth = tonumber(tplData.maxHealth) or 100
                tpl.armor = tonumber(tplData.armor) or 0
                tpl.walkSpeed = tonumber(tplData.walkSpeed) or 200
                tpl.runSpeed = tonumber(tplData.runSpeed) or 400
                
                EventMenu.StartTemplateId = tplId
            end
        end
    end
    
    -- Сообщение в общий чат
    local name = EventMenu.EventName ~= "" and EventMenu.EventName or "Ивент"
    local limit = EventMenu.MaxPlayers
    for _, p in ipairs(player.GetAll()) do
        if IsValid(p) then
            p:ChatPrint("[EventMenu] ★ Начался ивент: " .. name .. " (лимит: " .. limit .. "). Войдите командой !join или /join")
        end
    end
    
    -- Вызов менюшки приглашения для всех
    net.Start("EventMenu_Invitation")
    net.WriteString(name)
    net.WriteUInt(limit, 16)
    net.Broadcast()
    
    SendPlayersUpdate()
    ply:ChatPrint("[EventMenu] Ивент начат! Ваша позиция — точка спавна для участников")
end)

-- Переключение статуса события (открыто/закрыто)
net.Receive("EventMenu_ToggleEvent", function(len, ply)
    if not HasEventMenuAccess(ply) then return end
    
    EventMenu.EventOpen = net.ReadBool()
    
    -- Уведомление всех игроков
    local status = EventMenu.EventOpen and "открыт" or "закрыт"
    for _, p in ipairs(player.GetAll()) do
        p:ChatPrint("[EventMenu] Вход в событие " .. status)
    end
end)

-- Завершение события (кнопка в меню)
net.Receive("EventMenu_EndEvent", function(len, ply)
    if not HasEventMenuAccess(ply) then return end
    EventMenu.StopEvent()
    ply:ChatPrint("[EventMenu] Событие завершено")
end)

-- Принудительная остановка (из консоли или при ошибке)
net.Receive("EventMenu_ForceStopEvent", function(len, ply)
    if not HasEventMenuAccess(ply) then return end
    EventMenu.StopEvent()
    ply:ChatPrint("[EventMenu] Событие принудительно остановлено")
end)

-- ============================================
-- ХУКИ
-- ============================================

-- Обновление списка при подключении/отключении игрока
hook.Add("PlayerConnect", "EventMenu_PlayerConnect", function(name, ip)
    timer.Simple(1, function()
        SendPlayersUpdate()
    end)
end)

hook.Add("PlayerDisconnected", "EventMenu_PlayerDisconnect", function(ply)
    if IsValid(ply) then
        local steamid = ply:SteamID()
        if EventMenu.Players[steamid] then
            EventMenu.Players[steamid] = nil
        end
    end
    SendPlayersUpdate()
end)

-- Команда !join /join — войти в ивент
local function JoinEvent(ply)
    if not IsValid(ply) then return end
    if not EventMenu.EventOpen then
        ply:ChatPrint("[EventMenu] Ивент не начат")
        return
    end
    
    local steamid = ply:SteamID()
    if EventMenu.Players[steamid] then
        ply:ChatPrint("[EventMenu] Вы уже в ивенте")
        return
    end
    
    local count = 0
    for _ in pairs(EventMenu.Players) do count = count + 1 end
    if count >= EventMenu.MaxPlayers then
        ply:ChatPrint("[EventMenu] Ивент заполнен (" .. EventMenu.MaxPlayers .. " игроков)")
        return
    end
    
    EventMenu.Players[steamid] = { team = "none" }
    local idx = 0
    for _ in pairs(EventMenu.Players) do idx = idx + 1 end
    if EventMenu.StartTemplateId and EventMenu.StartTemplateId ~= "" and EventMenu.Templates[EventMenu.StartTemplateId] then
        ApplyStartTemplateToPlayer(ply, idx)
    else
        ply:SetPos(EventMenu.StartPos)
        ply:SetAngles(EventMenu.StartAng)
    end
    ApplyEventToPlayer(ply)
    local cg = EventMenu.CollisionEnabled and COLLISION_GROUP_PLAYER or COLLISION_GROUP_PASSABLE_DOOR
    ply:SetCollisionGroup(cg)
    SendPlayersUpdate()
    ply:ChatPrint("[EventMenu] Вы вступили в ивент!")
end

hook.Add("PlayerSay", "EventMenu_JoinCommand", function(ply, text, team)
    local cmd = string.lower(string.Trim(text))
    if cmd == "!join" or cmd == "/join" then
        JoinEvent(ply)
        return "" -- скрыть из чата
    end
end)

-- !eventstart — быстро запустить ивент с текущей позицией админа
hook.Add("PlayerSay", "EventMenu_EventStartCommand", function(ply, text, team)
    if not HasEventMenuAccess(ply) then return end

    local t = string.Trim(string.lower(text))
    if t ~= "!eventstart" then return end

    if EventMenu.EventActive then
        ply:ChatPrint("[EventMenu] Ивент уже запущен")
        return ""
    end

    EventMenu.Players = {}
    EventMenu.EventOpen = true
    EventMenu.EventActive = true
    EventMenu.StartPos = ply:GetPos()
    EventMenu.StartAng = ply:GetAngles()

    local name = (EventMenu.EventName and EventMenu.EventName ~= "") and EventMenu.EventName or "Ивент"
    local limit = EventMenu.MaxPlayers or 100

    for _, p in ipairs(player.GetAll()) do
        if IsValid(p) then
            p:ChatPrint("[EventMenu] ★ Начался ивент: " .. name .. " (лимит: " .. limit .. "). Войдите командой !join или /join")
        end
    end

    net.Start("EventMenu_Invitation")
    net.WriteString(name)
    net.WriteUInt(limit, 16)
    net.Broadcast()

    ply:ChatPrint("[EventMenu] Ивент запущен командой !eventstart")
    SendPlayersUpdate()

    return "" -- скрыть из чата
end)

-- !eventmenu — открыть основное меню ивента (event_menu)
hook.Add("PlayerSay", "EventMenu_EventMenuCommand", function(ply, text, team)
    if not HasEventMenuAccess(ply) then return end

    local t = string.Trim(string.lower(text))
    if t ~= "!eventmenu" then return end

    net.Start("EventMenu_OpenEventMenu")
    net.Send(ply)
    return "" -- скрыть из чата
end)

-- Восстановление прессетов оружия и модели после спавна
hook.Add("PlayerSpawn", "EventMenu_RestorePresets", function(ply)
    if not IsValid(ply) or not EventMenu.EventActive then return end
    local steamid = ply:SteamID()
    if not EventMenu.Players[steamid] then return end
    
    timer.Simple(0.1, function()
        if not IsValid(ply) then return end
        -- Оружие
        if EventMenu.PlayerWeaponPreset[steamid] and #EventMenu.PlayerWeaponPreset[steamid] > 0 then
            ply:StripWeapons()
            for _, wc in ipairs(EventMenu.PlayerWeaponPreset[steamid]) do
                ply:Give(wc)
            end
        end
        -- Модель/скорость/размер
        if EventMenu.PlayerModelPreset[steamid] then
            local pr = EventMenu.PlayerModelPreset[steamid]
            if pr.model and util.IsValidModel(pr.model) then ply:SetModel(pr.model) end
            if pr.runspeed then ply:SetRunSpeed(pr.runspeed) end
            if pr.walkspeed then ply:SetWalkSpeed(pr.walkspeed) end
            
            -- Применение масштаба модели с пересчетом позиции камеры
            if pr.modelscale and ply.SetModelScale then 
                ply:SetModelScale(pr.modelscale, 0)
                -- Пересчет позиции камеры после изменения масштаба
                local currentPos = ply:GetPos()
                ply:SetPos(currentPos + Vector(0, 0, 0.01))
                timer.Simple(0.01, function()
                    if IsValid(ply) then
                        ply:SetPos(currentPos)
                    end
                end)
            end
            
            if pr.health then 
                ply:SetMaxHealth(pr.maxhealth or pr.health)
                ply:SetHealth(pr.health)
            end
            if pr.armor then ply:SetArmor(pr.armor) end
        end
    end)
end)

-- Выбывание: при смерти — телепорт на спавн ивента
hook.Add("PlayerDeath", "EventMenu_Elimination", function(victim, inflictor, attacker)
    if not EventMenu.EventOpen then return end
    if EventMenu.EventType ~= "elimination" then return end
    if not IsValid(victim) then return end
    
    local steamid = victim:SteamID()
    if not EventMenu.Players[steamid] then return end
    
    timer.Simple(0.5, function()
        if not IsValid(victim) then return end
        victim:Spawn()
        if EventMenu.StartTemplateId and EventMenu.StartTemplateId ~= "" and EventMenu.Templates[EventMenu.StartTemplateId] then
            ApplyStartTemplateToPlayer(victim, 1)
        else
            victim:SetPos(EventMenu.StartPos)
            victim:SetAngles(EventMenu.StartAng)
        end
        ApplyEventToPlayer(victim)
        victim:ChatPrint("[EventMenu] Выбывание — вы телепортированы на спавн")
    end)
end)

concommand.Add("eventmenu_refresh_avatars", function(ply)
    if ply and IsValid(ply) and not HasEventMenuAccess(ply) then return end
    table.Empty(avatarFetchQueue)
    for _, p in ipairs(player.GetAll()) do
        if IsValid(p) then
            local sid = p:SteamID()
            if sid and sid ~= "STEAM_ID_PENDING" and sid ~= "STEAM_ID_LAN" and GetSteamID64(sid) then
                if EventMenu.AvatarCache then EventMenu.AvatarCache[sid] = nil end
                avatarFetchQueue[sid] = true
            end
        end
    end
    FetchAvatars()
    if ply and IsValid(ply) then ply:ChatPrint("[EventMenu] Обновление аватарок...") end
end)

print("[EventMenu] Серверная часть загружена! API ключ: " .. (EventMenuConfig and EventMenuConfig.SteamAPIKey and EventMenuConfig.SteamAPIKey ~= "" and "есть" or "НЕТ"))
