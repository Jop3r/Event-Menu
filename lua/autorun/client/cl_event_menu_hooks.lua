if SERVER then return end

hook.Add("HUDDrawTargetID", "EventMenu_HideNicks", function()
    local tr = util.GetPlayerTrace(LocalPlayer())
    local trace = util.TraceLine(tr)
    if not trace.Hit then return end
    if not trace.Entity:IsPlayer() then return end

    if trace.Entity:GetNWBool("PlayerNickHidden", false) then
        return false -- Не рисовать стандартный TargetID (ник + хп)
    end
end)
