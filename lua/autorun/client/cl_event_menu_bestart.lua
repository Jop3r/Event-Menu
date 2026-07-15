if SERVER then return end

-- ============================================
-- Event Start Menu — настройка ивента (!eventstart)
-- ============================================

local BestartFrame = nil
local BestartHtmlPanel = nil

local function GetBestartMenuHTML()
    return [=[<!DOCTYPE html>
<html lang="ru">
<head>
<meta charset="UTF-8">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<style>
:root{--bg-panel:rgba(28,28,31,0.95);--bg-secondary:rgba(39,39,42,0.6);--bg-hover:rgba(63,63,70,0.8);--accent:#6366f1;--accent-glow:rgba(99,102,241,0.3);--danger:#ef4444;--success:#10b981;--text-main:#fff;--text-muted:#a1a1aa;--border:rgba(255,255,255,0.06);--radius:16px;--radius-sm:10px}
*{margin:0;padding:0;box-sizing:border-box;font-family:'Inter',sans-serif;user-select:none}
body{background:transparent;color:var(--text-main);padding:24px;display:flex;justify-content:center;overflow:hidden}
.panel{width:420px;background:var(--bg-panel);backdrop-filter:blur(12px);border-radius:var(--radius);border:1px solid var(--border);overflow:hidden;display:flex;flex-direction:column;animation:popIn 0.4s cubic-bezier(0.19,1,0.22,1)}
@keyframes popIn{from{transform:scale(0.95);opacity:0}to{transform:scale(1);opacity:1}}
.header{padding:20px 24px;border-bottom:1px solid var(--border);display:flex;justify-content:space-between;align-items:center;background:rgba(255,255,255,0.02)}
.header h2{font-size:19px;font-weight:700;letter-spacing:-0.02em}
.close{background:none;border:none;color:var(--text-muted);font-size:24px;cursor:pointer;transition:0.3s cubic-bezier(0.4,0,0.2,1);outline:none;width:32px;height:32px;display:flex;align-items:center;justify-content:center;border-radius:50%}
.close:hover{color:#fff;background:rgba(239,68,68,0.2);transform:rotate(90deg)}
.body{padding:24px;overflow-y:auto;flex:1}
.body::-webkit-scrollbar{width:4px}
.body::-webkit-scrollbar-thumb{background:rgba(255,255,255,0.1);border-radius:10px}
.section{margin-bottom:26px}
.section:last-child{margin-bottom:0}
.label{font-size:11px;text-transform:uppercase;color:var(--text-muted);margin-bottom:12px;font-weight:700;letter-spacing:0.08em;display:block;opacity:0.8}
.select-wrapper{position:relative}
.select-input{width:100%;padding:14px 18px;background:var(--bg-secondary);border:1px solid var(--border);border-radius:var(--radius-sm);color:#fff;font-size:14px;outline:none;cursor:pointer;appearance:none;transition:0.3s ease}
.select-wrapper::after{content:'';position:absolute;right:18px;top:50%;transform:translateY(-50%);width:12px;height:12px;background-image:url('data:image/svg+xml;charset=US-ASCII,<svg%20xmlns%3D"http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg"%20viewBox%3D"0%200%2024%2024"%20fill%3D"none"%20stroke%3D"rgba(255,255,255,0.5)"%20stroke-width%3D"3"%20stroke-linecap%3D"round"%20stroke-linejoin%3D"round"><polyline%20points%3D"6%209%2012%2015%2018%209"><%2Fpolyline><%2Fsvg>');background-repeat:no-repeat;background-size:contain;pointer-events:none;transition:0.3s}
.select-input:focus{border-color:var(--accent)}
.select-input:hover{background:var(--bg-hover)}
.select-input option{background:#1c1c1f;color:#fff;padding:12px}
.check-row{display:flex;align-items:center;gap:14px;padding:16px;background:var(--bg-secondary);border:1px solid var(--border);border-radius:var(--radius-sm);cursor:pointer;transition:0.3s ease}
.check-row:hover{background:var(--bg-hover);transform:translateY(-1px);border-color:rgba(255,255,255,0.12)}
.check-row input{width:20px;height:20px;cursor:pointer;accent-color:var(--accent);border-radius:6px}
.check-row span{font-size:14px;font-weight:600;letter-spacing:-0.01em}
.num-input{width:100%;padding:14px 18px;background:var(--bg-secondary);border:1px solid var(--border);border-radius:var(--radius-sm);color:#fff;font-size:14px;outline:none;transition:0.3s ease}
.num-input:focus{border-color:var(--accent)}
.btns{margin-top:8px;display:flex;flex-direction:column;gap:12px}
.btn{padding:16px 20px;border:none;border-radius:var(--radius-sm);font-size:14px;font-weight:700;cursor:pointer;transition:0.3s cubic-bezier(0.4,0,0.2,1);outline:none}
.btn:active{transform:scale(0.97)}
.btn-success{background:linear-gradient(135deg,#10b981,#059669);color:#fff}
.btn-success:hover{transform:translateY(-2px)}
.btn-ghost{background:rgba(255,255,255,0.03);color:var(--text-muted);border:1px solid var(--border)}
.btn-ghost:hover{color:#fff;background:rgba(255,255,255,0.08);transform:translateY(-1px)}
</style>
</head>
<body>
<div class="panel">
<header class="header">
<h2>Настройка ивента</h2>
<button class="close" onclick="if(window.gmod&&window.gmod.CloseBestart)window.gmod.CloseBestart()">×</button>
</header>
<div class="body">
<div class="section">
<span class="label">Тип события</span>
<div class="select-wrapper">
<select id="eventType" class="select-input">
<option value="standard">Стандартный (участие)</option>
<option value="elimination">Выбывание (хардкор)</option>
<option value="creative">Творчество (билдинг)</option>
</select>
</div>
</div>
<div class="section">
<label class="check-row">
<input type="checkbox" id="stripWeapons">
<span>Очистить инвентарь при входе</span>
</label>
</div>
<div class="section">
<span class="label">Название события</span>
<input type="text" class="num-input" id="eventName" placeholder="Напр. Битва за базу..." maxlength="64">
</div>
<div class="section">
<span class="label">Макс. участников (0–110)</span>
<input type="number" class="num-input" id="maxPlayers" value="32" min="0" max="110">
</div>
<div class="section btns">
<button class="btn btn-success" onclick="startEvent(true)">Опубликовать приглашение</button>
<button class="btn btn-ghost" onclick="startEvent(false)">Запустить в тихом режиме</button>
</div>
</div>
</div>
<script>
function startEvent(withNotif){var e=document.getElementById('eventType').value,s=!!document.getElementById('stripWeapons').checked,n=parseInt(document.getElementById('maxPlayers').value)||50,name=(document.getElementById('eventName')&&document.getElementById('eventName').value||'').trim()||'Ивент';n=Math.max(0,Math.min(110,n));if(window.gmod&&window.gmod.BestartStart)window.gmod.BestartStart(e,s,n,withNotif,name)}
</script>
</body>
</html>]=]
end

local function OpenBestartMenu()
    if IsValid(BestartFrame) then
        BestartFrame:Remove()
    end
    
    BestartFrame = vgui.Create("DFrame")
    BestartFrame:SetSize(500, 800)
    BestartFrame:Center()
    BestartFrame:SetTitle("")
    BestartFrame:ShowCloseButton(false)
    BestartFrame:SetDraggable(true)
    BestartFrame:MakePopup()
    
    -- Закрытие по ESC
    BestartFrame.m_bEscPressed = false
    BestartFrame.Think = function(s)
        if not IsValid(s) then return end
        if input.IsKeyDown(KEY_ESCAPE) then
            if not s.m_bEscPressed then
                s.m_bEscPressed = true
                s:Remove()
            end
        else
            s.m_bEscPressed = false
        end
    end
    
    BestartFrame.Paint = function() end -- без затемнения, только меню
    
    BestartHtmlPanel = vgui.Create("DHTML", BestartFrame)
    BestartHtmlPanel:Dock(FILL)
    
    BestartHtmlPanel:AddFunction("gmod", "CloseBestart", function()
        if IsValid(BestartFrame) then BestartFrame:Remove() end
    end)
    
    BestartHtmlPanel:AddFunction("gmod", "BestartStart", function(etype, strip, maxPlayers, withNotification, eventName)
        net.Start("EventMenu_BestartStart")
        net.WriteString(tostring(etype or "standard"))
        net.WriteBool(strip == true or strip == "true")
        net.WriteUInt(math.Clamp(tonumber(maxPlayers) or 50, 0, 110), 16)
        net.WriteBool(withNotification == true or withNotification == "true")
        net.WriteString(tostring(eventName or ""):sub(1, 64))
        net.SendToServer()
        
        if IsValid(BestartFrame) then BestartFrame:Remove() end
    end)
    
    BestartHtmlPanel:SetHTML(GetBestartMenuHTML())
end

net.Receive("EventMenu_OpenBestart", function()
    OpenBestartMenu()
end)

net.Receive("EventMenu_OpenEventMenu", function()
    -- Открыть event_menu (используем concommand для вызова существующей логики)
    RunConsoleCommand("event_menu")
end)
