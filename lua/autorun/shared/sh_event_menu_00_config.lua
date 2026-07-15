-- ============================================
-- Event Menu Configuration
-- Конфигурация прав доступа
-- Загружается первой (00 в начале имени)
-- ============================================

EventMenuConfig = EventMenuConfig or {}

-- Steam Web API ключ для аватарок (получить бесплатно: https://steamcommunity.com/dev/apikey)
-- Если пусто — показывается первая буква ника
EventMenuConfig.SteamAPIKey = EventMenuConfig.SteamAPIKey or "" -- Вставьте сюда ваш Steam API ключ

-- Список Steam ID администраторов события
-- Добавьте свои Steam ID в этот список
EventMenuConfig.AdminSteamIDs = {
    "STEAM_0:1:628783118", -- Ваш Steam ID
    -- Добавьте другие Steam ID здесь:
    -- "STEAM_0:0:123456789",
    -- "STEAM_0:1:987654321",
}

-- Проверка прав доступа по Steam ID
function EventMenuConfig.HasAccess(ply)
    if not IsValid(ply) then return false end
    
    -- Проверка через стандартную систему супер админов (приоритет)
    if ply.IsSuperAdmin and ply:IsSuperAdmin() then return true end
    
    -- Проверка через стандартную систему админов
    if ply:IsAdmin() then return true end
    
    -- Проверка по Steam ID из конфига
    local steamid = ply:SteamID()
    for _, adminSteamID in ipairs(EventMenuConfig.AdminSteamIDs) do
        if steamid == adminSteamID then
            return true
        end
    end
    
    return false
end

-- Проверка на клиенте (синхронизируется с сервером)
if CLIENT then
    function EventMenuConfig.HasAccessClient()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        
        -- Проверка через стандартную систему супер админов (приоритет)
        if ply.IsSuperAdmin and ply:IsSuperAdmin() then return true end
        
        -- Проверка через стандартную систему админов
        if ply:IsAdmin() then return true end
        
        -- Проверка по Steam ID на клиенте
        local steamid = ply:SteamID()
        for _, adminSteamID in ipairs(EventMenuConfig.AdminSteamIDs) do
            if steamid == adminSteamID then
                return true
            end
        end
        
        return false
    end
end

print("[EventMenu] Конфигурация загружена. Админов: " .. #EventMenuConfig.AdminSteamIDs)
