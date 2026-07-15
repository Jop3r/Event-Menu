if SERVER then return end

local InviteFrame = nil

local function GetInviteHTML(name)
    return [=[<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg-panel: rgba(28,28,31,0.92);
            --bg-secondary: rgba(39,39,42,0.6);
            --accent: #6366f1;
            --accent-glow: rgba(99,102,241,0.3);
            --success: #10b981;
            --danger: #ef4444;
            --text-main: #fff;
            --text-muted: #a1a1aa;
            --border: rgba(255,255,255,0.06);
            --radius: 16px;
        }
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Inter', sans-serif; user-select: none; }
        body { background: transparent; overflow: hidden; display: flex; justify-content: center; padding-top: 20px; }
        .invite-box {
            width: 380px;
            background: var(--bg-panel);
            backdrop-filter: blur(10px);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 24px;
            text-align: center;
            position: relative;
            overflow: hidden;
            animation: slideIn 0.6s cubic-bezier(0.22, 1, 0.36, 1);
        }
        @keyframes slideIn {
            from { transform: translateY(-180px) scale(0.9); opacity: 0; }
            to { transform: translateY(0) scale(1); opacity: 1; }
        }
        .progress-bar {
            position: absolute;
            bottom: 0;
            left: 0;
            height: 3px;
            background: var(--accent);
            width: 100%;
            animation: progress 20s linear forwards;
        }
        @keyframes progress {
            from { width: 100%; }
            to { width: 0%; }
        }
        .title { color: var(--accent); font-size: 11px; font-weight: 800; text-transform: uppercase; letter-spacing: 0.15em; margin-bottom: 12px; opacity: 0.9; }
        .name { color: var(--text-main); font-size: 18px; font-weight: 700; margin-bottom: 6px; letter-spacing: -0.01em; }
        .desc { color: var(--text-muted); font-size: 14px; margin-bottom: 24px; font-weight: 500; }
        .btns { display: flex; gap: 12px; justify-content: center; }
        .btn {
            padding: 14px 24px;
            border-radius: 10px;
            border: none;
            font-size: 14px;
            font-weight: 700;
            cursor: pointer;
            transition: 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            flex: 1;
        }
        .btn-yes { background: linear-gradient(135deg, #10b981, #059669); color: #fff; }
        .btn-yes:hover { transform: translateY(-2px); }
        .btn-no { background: rgba(255, 255, 255, 0.05); color: var(--text-muted); border: 1px solid var(--border); }
        .btn-no:hover { color: #fff; background: rgba(255, 255, 255, 0.1); transform: translateY(-1px); }
        .btn:active { transform: scale(0.97); }
    </style>
</head>
<body>
    <div class="invite-box">
        <div class="title">Приглашение</div>
        <div class="name">]=] .. name .. [=[</div>
        <div class="desc">Хотите принять участие?</div>
        <div class="btns">
            <button class="btn btn-yes" onclick="if(window.gmod)window.gmod.Join()">Принять</button>
            <button class="btn btn-no" onclick="if(window.gmod)window.gmod.Close()">Отклонить</button>
        </div>
        <div class="progress-bar"></div>
    </div>
</body>
</html>]=]
end

net.Receive("EventMenu_Invitation", function()
    local name = net.ReadString()
    local limit = net.ReadUInt(16)

    if IsValid(InviteFrame) then InviteFrame:Remove() end

    InviteFrame = vgui.Create("DFrame")
    InviteFrame:SetSize(420, 240)
    InviteFrame:SetPos((ScrW() - 420) / 2, 10)
    InviteFrame:SetTitle("")
    InviteFrame:ShowCloseButton(false)
    InviteFrame:SetDraggable(false)
    InviteFrame:SetMouseInputEnabled(true)
    InviteFrame:SetKeyboardInputEnabled(false)
    InviteFrame.Paint = function() end
    
    local html = vgui.Create("DHTML", InviteFrame)
    html:Dock(FILL)
    html:SetAllowLua(true)
    
    html:AddFunction("gmod", "Join", function()
        LocalPlayer():ConCommand("say !join")
        if IsValid(InviteFrame) then InviteFrame:Remove() end
    end)
    
    html:AddFunction("gmod", "Close", function()
        if IsValid(InviteFrame) then InviteFrame:Remove() end
    end)
    
    html:SetHTML(GetInviteHTML(name))

    -- Авто-закрытие через 20 секунд
    timer.Simple(20, function()
        if IsValid(InviteFrame) then InviteFrame:Remove() end
    end)
end)
