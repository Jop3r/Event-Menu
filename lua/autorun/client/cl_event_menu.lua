if SERVER then return end -- Этот скрипт только для клиента

-- ============================================
-- Event Menu Client Side
-- Интерфейс управления событиями
-- ============================================

local EventFrame = nil
local htmlPanel = nil
local EventMenuModalOpen = false


local function GetEventMenuHTML()
    return [=[<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Event Manager Pro + Teams</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
:root{--bg-body:#121214;--bg-panel:#1c1c1f;--bg-secondary:#27272a;--bg-hover:#3f3f46;--accent:#6366f1;--accent-hover:#4f46e5;--danger:#ef4444;--text-main:#fff;--text-muted:#a1a1aa;--border:#323236;--radius:12px;--radius-sm:8px;--team-red:#f87171;--team-blue:#60a5fa;--team-green:#4ade80;--team-yellow:#facc15;--team-purple:#c084fc;--team-none:#52525b}
*{margin:0;padding:0;box-sizing:border-box;font-family:'Inter',sans-serif;user-select:none}
input::-webkit-outer-spin-button,input::-webkit-inner-spin-button{-webkit-appearance:none;margin:0}
input[type=number]{-moz-appearance:textfield}
body{background-color:transparent;height:100vh;margin:0;color:var(--text-main)}
.panel{width:1200px;height:800px;min-width:800px;min-height:500px;position:fixed;left:50%;top:50%;transform:translate(-50%,-50%);background:var(--bg-panel);border-radius:var(--radius);border:1px solid var(--border);display:flex;flex-direction:column;overflow:hidden}
.resize-handle{position:absolute;right:0;bottom:0;width:24px;height:24px;cursor:nwse-resize;z-index:100}
.resize-handle::after{content:'';position:absolute;right:6px;bottom:6px;width:10px;height:10px;border-right:2px solid var(--text-muted);border-bottom:2px solid var(--text-muted);opacity:0.6}
.resize-handle:hover::after{opacity:1}
.panel-header{padding:16px 24px;border-bottom:1px solid var(--border);display:flex;justify-content:space-between;align-items:center;background:rgba(28,28,31,0.98);cursor:move;user-select:none}
.title-group h2{font-size:18px;font-weight:600;display:flex;align-items:center;gap:10px}
.badge{background:var(--accent);font-size:11px;padding:2px 8px;border-radius:10px;font-weight:700;text-transform:uppercase}
.header-controls{display:flex;gap:20px;align-items:center}
.player-counter{display:flex;align-items:center;background:var(--bg-secondary);padding:4px 12px;border-radius:var(--radius-sm);border:1px solid var(--border);font-size:13px;color:var(--text-muted);font-weight:600}
.player-counter span{color:#fff;margin-right:2px}
.limit-control{display:flex;align-items:center;gap:10px;background:var(--bg-secondary);padding:4px 12px;border-radius:var(--radius-sm);border:1px solid var(--border)}
.limit-control span{font-size:13px;color:var(--text-muted)}
.limit-control input{background:transparent;border:none;color:#fff;width:40px;text-align:right;font-weight:600;outline:none}
.close-btn{background:none;border:none;color:var(--text-muted);font-size:24px;cursor:pointer;transition:0.2s;line-height:1;outline:none}
.close-btn:hover{color:var(--danger);transform:rotate(90deg)}
.panel-body{display:flex;flex:1;overflow:hidden}
.actions-column{width:320px;min-width:220px;max-width:520px;border-right:1px solid var(--border);display:flex;flex-direction:column;background:var(--bg-panel);transition:width 0.1s ease-out}
.sidebar-resize{width:6px;cursor:col-resize;background:transparent;position:relative;flex-shrink:0}
.sidebar-resize::before{content:'';position:absolute;top:16px;bottom:16px;left:50%;width:2px;border-radius:999px;background:rgba(63,63,70,0.7);transform:translateX(-50%);opacity:0.6;transition:opacity 0.15s,background 0.15s}
.sidebar-resize:hover::before{opacity:1;background:rgba(99,102,241,0.9)}
.scroll-area{padding:20px;overflow-y:auto;flex:1}
.scroll-area::-webkit-scrollbar{width:5px}
.scroll-area::-webkit-scrollbar-thumb{background:#3f3f46;border-radius:4px}
.category-title{font-size:11px;text-transform:uppercase;color:var(--text-muted);margin-bottom:10px;font-weight:700;letter-spacing:0.5px;margin-top:20px}
.category-title:first-child{margin-top:0}
.actions-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(125px,1fr));gap:8px}
.action-card{background:var(--bg-secondary);border:1px solid var(--border);border-radius:var(--radius-sm);padding:12px;cursor:pointer;transition:all 0.2s;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:8px;text-align:center;height:80px;outline:none}
.action-card:hover{background:var(--bg-hover);transform:translateY(-2px);border-color:#52525b}
.action-card.active{background:rgba(99,102,241,0.15);border-color:var(--accent);color:var(--accent)}
.action-icon{width:24px;height:24px;fill:currentColor}
.action-name{font-size:12px;font-weight:500}
.team-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(125px,1fr));gap:8px}
.team-btn{display:flex;align-items:center;gap:8px;padding:10px;background:var(--bg-secondary);border:1px solid var(--border);border-radius:var(--radius-sm);cursor:pointer;transition:0.2s;color:#fff;font-size:12px;font-weight:500;outline:none}
.team-btn:hover{background:var(--bg-hover);transform:translateY(-1px)}
.team-dot{width:10px;height:10px;border-radius:50%}
.team-btn[data-team="red"]:hover{border-color:var(--team-red);background:rgba(248,113,113,0.1)}
.team-btn[data-team="blue"]:hover{border-color:var(--team-blue);background:rgba(96,165,250,0.1)}
.team-btn[data-team="green"]:hover{border-color:var(--team-green);background:rgba(74,222,128,0.1)}
.team-btn[data-team="yellow"]:hover{border-color:var(--team-yellow);background:rgba(250,204,21,0.1)}
.team-btn[data-team="purple"]:hover{border-color:var(--team-purple);background:rgba(192,132,252,0.1)}
.team-btn[data-team="none"]:hover{border-color:var(--team-none)}
.targets-column{flex:1;display:flex;flex-direction:column;background:#18181b;position:relative;min-height:0}
.search-bar{padding:12px 16px;border-bottom:1px solid var(--border);display:flex;gap:10px;position:relative}
.search-input{width:100%;background:var(--bg-secondary);border:1px solid var(--border);padding:10px 12px;border-radius:var(--radius-sm);color:#fff;font-size:13px;outline:none;flex:1}
.search-input:focus{border-color:var(--accent)}
.select-all-btn{background:var(--bg-secondary);border:1px solid var(--border);color:var(--text-muted);padding:0 12px;border-radius:var(--radius-sm);cursor:pointer;font-size:12px;font-weight:500;white-space:nowrap;transition:0.2s;outline:none}
.select-all-btn:hover{background:var(--bg-hover);color:#fff}
.dropdown{position:relative}
.select-btn{height:100%;padding:0 16px;background:var(--bg-secondary);border:1px solid var(--border);color:#fff;border-radius:var(--radius-sm);cursor:pointer;font-size:13px;font-weight:500;display:flex;align-items:center;gap:8px;transition:0.2s;outline:none}
.select-btn:hover{background:var(--bg-hover)}
.dropdown-menu{position:absolute;top:110%;right:0;width:200px;background:#27272a;border:1px solid var(--border);border-radius:var(--radius-sm);padding:6px;z-index:10;display:none}
.dropdown-menu.show{display:block}
.dropdown-item{padding:8px 12px;font-size:13px;color:#e4e4e7;cursor:pointer;border-radius:4px;display:flex;align-items:center;gap:8px;transition:0.15s}
.dropdown-item:hover{background:#3f3f46}
.players-list{flex:1;overflow-y:auto;padding:16px;display:grid;grid-template-columns:repeat(5,1fr);grid-auto-rows:max-content;gap:10px;align-content:start}
.players-list::-webkit-scrollbar{width:6px}
.players-list::-webkit-scrollbar-thumb{background:#3f3f46;border-radius:10px}
.player-item{background:var(--bg-secondary);border:1px solid transparent;border-radius:var(--radius-sm);cursor:pointer;transition:all 0.2s;display:flex;flex-direction:column;align-items:center;justify-content:center;padding:16px 8px;position:relative;border-bottom:3px solid var(--team-none);outline:none}
.player-item:hover{background:var(--bg-hover);transform:translateY(-3px)}
.player-item.selected{background:rgba(99,102,241,0.1);border-color:var(--accent);border-bottom:3px solid var(--accent);box-shadow:0 0 0 1px var(--accent)}
.player-item[data-team="red"]{border-bottom-color:var(--team-red)}
.player-item[data-team="blue"]{border-bottom-color:var(--team-blue)}
.player-item[data-team="green"]{border-bottom-color:var(--team-green)}
.player-item[data-team="yellow"]{border-bottom-color:var(--team-yellow)}
.player-item[data-team="purple"]{border-bottom-color:var(--team-purple)}
.player-avatar{width:40px;height:40px;border-radius:50%;background:#333;display:flex;align-items:center;justify-content:center;font-size:16px;font-weight:700;color:#fff;margin-bottom:10px;border:2px solid transparent;transition:0.3s;overflow:hidden}
.player-avatar img{width:100%;height:100%;object-fit:cover}
.player-item[data-team="red"] .player-avatar{border-color:var(--team-red);color:var(--team-red);background:rgba(248,113,113,0.1)}
.player-item[data-team="blue"] .player-avatar{border-color:var(--team-blue);color:var(--team-blue);background:rgba(96,165,250,0.1)}
.player-item[data-team="green"] .player-avatar{border-color:var(--team-green);color:var(--team-green);background:rgba(74,222,128,0.1)}
.player-item[data-team="yellow"] .player-avatar{border-color:var(--team-yellow);color:var(--team-yellow);background:rgba(250,204,21,0.1)}
.player-item[data-team="purple"] .player-avatar{border-color:var(--team-purple);color:var(--team-purple);background:rgba(192,132,252,0.1)}
.player-name{font-size:12px;font-weight:600;color:#f4f4f5;text-align:center;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:100%}
.player-id{font-size:10px;color:var(--text-muted);margin-top:2px}
.check-icon{position:absolute;top:6px;right:6px;width:18px;height:18px;background:var(--accent);border-radius:4px;display:flex;align-items:center;justify-content:center;opacity:0;transform:scale(0.5);transition:0.2s}
.player-item.selected .check-icon{opacity:1;transform:scale(1)}
.context-menu{position:fixed;background:var(--bg-panel);border:1px solid var(--border);border-radius:var(--radius-sm);padding:6px;z-index:1000;min-width:180px;opacity:0;visibility:hidden;transform:scale(0.95);transition:opacity 0.15s,transform 0.15s,visibility 0.15s}
.context-menu.show{opacity:1;visibility:visible;transform:scale(1)}
.context-menu-item{padding:10px 12px;font-size:13px;color:#e4e4e7;cursor:pointer;border-radius:4px;display:flex;align-items:center;gap:10px;transition:0.15s;user-select:none;outline:none}
.context-menu-item:hover{background:var(--bg-hover);color:#fff}
.context-menu-item.danger{color:var(--danger)}
.context-menu-item.danger:hover{background:rgba(239,68,68,0.15)}
.context-menu-item svg{width:16px;height:16px;fill:currentColor}
.panel-footer{padding:16px 24px;border-top:1px solid var(--border);background:var(--bg-panel);display:flex;justify-content:space-between;align-items:center}
.footer-left{display:flex;align-items:center;gap:20px}
.toggle-switch{display:flex;align-items:center;gap:8px;cursor:pointer;outline:none}
.toggle-track{width:36px;height:20px;background:var(--bg-secondary);border-radius:20px;position:relative;transition:0.3s;border:1px solid var(--border)}
.toggle-knob{width:14px;height:14px;background:#9ca3af;border-radius:50%;position:absolute;top:2px;left:2px;transition:0.3s}
.toggle-switch input{display:none}
.toggle-switch input:checked+.toggle-track{background:rgba(16,185,129,0.2);border-color:#10b981}
.toggle-switch input:checked+.toggle-track .toggle-knob{transform:translateX(16px);background:#10b981}
.toggle-label{font-size:13px;color:var(--text-muted);font-weight:500}
.btns-group{display:flex;gap:10px}
.btn{padding:8px 20px;border-radius:var(--radius-sm);border:none;font-size:13px;font-weight:600;cursor:pointer;transition:0.2s;outline:none}
.btn:active{transform:scale(0.96)}
.btn-primary{background:var(--accent);color:#fff}
.btn-primary:hover{background:var(--accent-hover)}
.btn-ghost{background:transparent;color:var(--text-muted)}
.btn-ghost:hover{color:#fff}
.btn-danger{color:var(--danger);background:rgba(239,68,68,0.1)}
.btn-danger:hover{background:rgba(239,68,68,0.2)}
.btn-success{color:#10b981;background:rgba(16,185,129,0.15)}
.btn-success:hover{background:rgba(16,185,129,0.25)}
.btn:disabled,.btn.disabled{opacity:0.6;cursor:not-allowed;pointer-events:none}
.btn-sm{padding:6px 12px;font-size:11px}
.template-actions{margin-bottom:12px}
.templates-list{display:flex;flex-direction:column;gap:6px;max-height:140px;overflow-y:auto;margin-bottom:8px}
.template-item{display:flex;align-items:center;justify-content:space-between;padding:8px 10px;background:var(--bg-secondary);border:1px solid var(--border);border-radius:var(--radius-sm);font-size:12px}
.template-item .template-name{font-weight:600;flex:1;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.template-item .template-info{font-size:10px;color:var(--text-muted);margin-left:6px}
.template-item .template-btns{display:flex;gap:4px}
.template-item .template-btn{padding:4px 8px;font-size:10px;border-radius:4px;border:none;cursor:pointer;background:var(--accent);color:#fff}
.template-item .template-btn:hover{background:var(--accent-hover)}
.template-item .template-btn.delete{background:rgba(239,68,68,0.3);color:#fff}
.template-item .template-btn.delete:hover{background:var(--danger)}
.modal-overlay{position:absolute;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,0.7);z-index:9999;display:flex;align-items:center;justify-content:center;opacity:0;visibility:hidden;transition:0.2s;pointer-events:none}
.modal-overlay.show{opacity:1;visibility:visible;pointer-events:auto}
#valueModal, #colorModal, #scaleModal{z-index:10001}
.scale-slider-wrap{margin-bottom:16px}
.scale-slider-wrap label{display:block;font-size:13px;color:var(--text-muted);margin-bottom:8px}
.scale-slider{width:100%;height:8px;border-radius:4px;background:var(--bg-secondary);outline:none;-webkit-appearance:none;appearance:none}
.scale-slider::-webkit-slider-thumb{-webkit-appearance:none;width:20px;height:20px;border-radius:50%;background:var(--accent);cursor:pointer}
.scale-slider::-moz-range-thumb{width:20px;height:20px;border-radius:50%;background:var(--accent);cursor:pointer;border:none}
.scale-value{font-size:18px;font-weight:600;color:var(--accent);text-align:center;margin-top:8px}
.modal-box{background:var(--bg-panel);border:1px solid var(--border);border-radius:var(--radius);padding:24px;min-width:320px;transform:translate(-50%,-50%) scale(0.9);position:absolute;top:50%;left:50%;transition:0.2s}
.modal-overlay.show .modal-box{transform:translate(-50%,-50%) scale(1)}
.modal-title{font-size:16px;font-weight:600;margin-bottom:16px}
.modal-input{width:100%;background:var(--bg-secondary);border:1px solid var(--border);padding:12px;border-radius:var(--radius-sm);color:#fff;font-size:14px;outline:none;margin-bottom:16px}
.modal-input:focus{border-color:var(--accent)}
.modal-btns{display:flex;gap:10px;justify-content:flex-end}
.color-select-wrap{position:relative;margin-bottom:16px}
.color-select-btn{width:100%;position:relative;background:var(--bg-secondary);border:1px solid var(--border);padding:12px 40px 12px 12px;border-radius:var(--radius-sm);color:#fff;font-size:14px;cursor:pointer;display:flex;align-items:center;gap:10px;transition:0.2s;text-align:left}
.color-select-btn:hover{border-color:var(--accent);background:var(--bg-hover)}
.color-select-btn::after{content:'';position:absolute;right:12px;top:50%;transform:translateY(-50%);width:0;height:0;border-left:5px solid transparent;border-right:5px solid transparent;border-top:6px solid var(--text-muted);transition:transform 0.2s}
.color-select-btn.open::after{transform:translateY(-50%) rotate(180deg)}
.color-select-dropdown{position:absolute;top:100%;left:0;right:0;margin-top:4px;background:var(--bg-panel);border:1px solid var(--border);border-radius:var(--radius-sm);max-height:200px;overflow-y:auto;z-index:100;display:none}
.color-select-dropdown.show{display:block}
.color-select-item{padding:10px 12px;display:flex;align-items:center;gap:10px;cursor:pointer;font-size:13px;color:#e4e4e7;transition:0.15s;border-bottom:1px solid var(--border)}
.color-select-item:last-child{border-bottom:none}
.color-select-item:hover{background:var(--bg-hover)}
.color-select-swatch{width:24px;height:24px;border-radius:4px;border:1px solid rgba(255,255,255,0.2);flex-shrink:0}
.model-modal{align-items:flex-start;padding-top:14px}
.model-modal .modal-box{position:relative;top:auto;left:auto;transform:none !important;width:min(920px,95%);max-height:calc(100% - 28px);padding:16px;display:flex;flex-direction:column}
.model-modal.show .modal-box{transform:none !important}
.model-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(120px,1fr));gap:12px;overflow-y:auto;flex:1;min-height:0;padding:4px}
.model-card{background:var(--bg-secondary);border:1px solid var(--border);border-radius:var(--radius-sm);overflow:hidden;cursor:pointer;transition:0.2s;display:flex;flex-direction:column}
.model-card:hover{border-color:var(--accent);transform:translateY(-2px)}
.model-card-thumb{width:100%;aspect-ratio:1;background:linear-gradient(135deg,#3b3b5c 0%,#6366f1 100%);display:flex;align-items:center;justify-content:center}
.model-card-thumb img{width:100%;height:100%;object-fit:contain;background:#4f46e5}
.model-card-thumb span{display:none;width:100%;height:100%;align-items:center;justify-content:center}
.model-card-thumb span svg{width:50%;height:50%;opacity:0.8;fill:#fff;display:block}
.model-card-name{font-size:11px;font-weight:600;padding:6px 8px;color:#e4e4e7;text-align:center;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.model-card-path{font-size:9px;color:var(--text-muted);padding:0 8px 6px;text-align:center;overflow:hidden;text-overflow:ellipsis}
.weapon-modal{align-items:flex-start;padding-top:14px}
.weapon-modal .modal-box{position:relative;top:auto;left:auto;transform:none !important;width:min(960px,97%);max-height:calc(100% - 28px);padding:16px;display:flex;flex-direction:column}
.weapon-modal.show .modal-box{transform:none !important}
.weapon-card-class{font-size:10px;color:var(--text-muted);overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.weapon-card-cat{font-size:9px;color:var(--accent);text-transform:uppercase;font-weight:600}
.weapon-tabs{display:flex;gap:6px;margin-bottom:12px;overflow-x:auto;padding-bottom:8px;scrollbar-width:none;flex-shrink:0}
.weapon-tabs::-webkit-scrollbar{display:none}
.weapon-tab{padding:8px 16px;background:var(--bg-secondary);border:1px solid var(--border);border-radius:var(--radius-sm);font-size:13px;color:#e4e4e7;cursor:pointer;white-space:nowrap;transition:0.15s;text-align:center;min-width:80px}
.weapon-tab:hover{background:var(--bg-hover);border-color:var(--accent)}
.weapon-tab.active{background:var(--accent);border-color:var(--accent);color:#fff;font-weight:600}
.weapon-search{width:100%;background:var(--bg-secondary);border:1px solid var(--border);padding:12px 14px;border-radius:var(--radius-sm);color:#fff;font-size:14px;outline:none;margin-bottom:12px;box-sizing:border-box;flex-shrink:0}
.weapon-search:focus{border-color:var(--accent)}
.weapon-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(160px,1fr));gap:8px;overflow-y:auto;flex:1;min-height:0;padding:4px}
.weapon-card{background:var(--bg-secondary);border:2px solid var(--border);border-radius:var(--radius-sm);padding:10px 12px;cursor:pointer;transition:0.15s;display:flex;flex-direction:column;gap:4px;position:relative}
.weapon-card:hover{border-color:var(--accent);background:var(--bg-hover)}
.weapon-card.selected{border-color:#10b981;background:rgba(16,185,129,0.1)}
.weapon-modal .modal-close{position:absolute;top:10px;right:12px;width:24px;height:24px;border-radius:999px;border:none;background:transparent;color:var(--text-muted);cursor:pointer;font-size:18px;line-height:1;display:flex;align-items:center;justify-content:center;transition:0.15s}
.weapon-modal .modal-close:hover{background:rgba(39,39,42,0.9);color:#fff}
.weapon-card-check{position:absolute;top:6px;right:6px;width:16px;height:16px;border-radius:50%;background:#10b981;display:none;align-items:center;justify-content:center;font-size:10px;color:#fff;font-weight:bold}
.weapon-card.selected .weapon-card-check{display:flex}
.weapon-card-name{font-size:12px;font-weight:600;color:#e4e4e7;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.weapon-card-class{font-size:10px;color:var(--text-muted);overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.weapon-card-cat{font-size:9px;color:var(--accent);text-transform:uppercase;font-weight:600}
.weapon-tabs{display:flex;gap:4px;margin-bottom:12px;overflow-x:auto;padding-bottom:4px;scrollbar-width:none}
.weapon-tabs::-webkit-scrollbar{display:none}
.weapon-tab{padding:6px 12px;background:var(--bg-secondary);border:1px solid var(--border);border-radius:var(--radius-sm);font-size:12px;color:var(--text-muted);cursor:pointer;white-space:nowrap;transition:0.15s}
.weapon-tab:hover{background:var(--bg-hover);color:#fff}
.weapon-tab.active{background:var(--accent);border-color:var(--accent);color:#fff}
.player-name-row{display:flex;align-items:center;gap:8px;justify-content:center;width:100%}
.player-status-icons{display:flex;gap:6px;align-items:center}
.status-icon{width:18px;height:18px;fill:currentColor;opacity:0.8;transition:opacity 0.2s}
.status-icon.muted{color:#ef4444}
.status-icon.gagged{color:#f59e0b}
.status-icon.godmode{color:#8b5cf6}
.status-icon.no-collision{color:#3b82f6}
.status-icon:hover{opacity:1}
@keyframes fadeIn{from{opacity:0;transform:translateY(-5px)}to{opacity:1;transform:translateY(0)}}
    </style>
</head>
<body>
<div class="panel">
<header class="panel-header">
<div class="title-group"><h2>Event Manager <span class="badge">Teams</span></h2></div>
            <div class="header-controls">
<div class="player-counter" id="playerCounter" title="Игроков / Лимит"><span>0</span>/0</div>
<div class="limit-control"><span>👥</span><input type="number" value="110" id="maxPlayersInput" onchange="if(window.gmod&&window.gmod.SetMaxPlayers)window.gmod.SetMaxPlayers(parseInt(this.value));updatePlayerCounter()"></div>
<button class="close-btn" title="Закрыть" onclick="if(window.gmod&&window.gmod.CloseMenu)window.gmod.CloseMenu()">×</button>
            </div>
        </header>
<div class="panel-body">
<div class="actions-column" id="actionsColumn"><div class="scroll-area">
<div class="category-title">Шаблоны</div>
<div class="template-actions">
<button class="btn btn-primary btn-sm" onclick="showCustomTemplateModal()" style="width:100%">✚ Создать новый шаблон</button>
</div>
<div class="templates-list" id="templatesList"></div>
<div class="category-title">Выдать команду</div>
<div class="team-grid">
<div class="team-btn" onclick="assignTeam('red')" data-team="red"><div class="team-dot" style="background:var(--team-red)"></div>Красные</div>
<div class="team-btn" onclick="assignTeam('blue')" data-team="blue"><div class="team-dot" style="background:var(--team-blue)"></div>Синие</div>
<div class="team-btn" onclick="assignTeam('green')" data-team="green"><div class="team-dot" style="background:var(--team-green)"></div>Зеленые</div>
<div class="team-btn" onclick="assignTeam('yellow')" data-team="yellow"><div class="team-dot" style="background:var(--team-yellow)"></div>Желтые</div>
<div class="team-btn" onclick="assignTeam('purple')" data-team="purple"><div class="team-dot" style="background:var(--team-purple)"></div>Фиол.</div>
<div class="team-btn" onclick="assignTeam('none')" data-team="none"><div class="team-dot" style="background:var(--team-none)"></div>Сброс</div>
</div>
<div class="category-title">Спавн</div>
<div class="actions-grid">
<div class="action-card bulk" onclick="bulkAction('set_spawn_all')" data-action="set_spawn_all"><svg class="action-icon" viewBox="0 0 24 24"><path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/></svg><span class="action-name">Спавн для всех</span></div>
<div class="action-card" onclick="showSpawnTeamModal()"><svg class="action-icon" viewBox="0 0 24 24"><path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/></svg><span class="action-name">Спавн для команды</span></div>
</div>
<div class="category-title">Телепорт</div>
<div class="actions-grid">
<div class="action-card bulk" onclick="bulkAction('teleport_all')"><svg class="action-icon" viewBox="0 0 24 24"><path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/></svg><span class="action-name">Всех к себе</span></div>
<div class="action-card" onclick="triggerAction(this)" data-action="teleport"><svg class="action-icon" viewBox="0 0 24 24"><path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/></svg><span class="action-name">Телепортировать к себе</span></div>
<div class="action-card" onclick="triggerAction(this)" data-action="respawn_team"><svg class="action-icon" viewBox="0 0 24 24"><path d="M17.65 6.35C16.2 4.9 14.21 4 12 4c-4.42 0-7.99 3.58-7.99 8s3.57 8 7.99 8c3.73 0 6.84-2.55 7.73-6h-2.08c-.82 2.33-3.04 4-5.65 4-3.31 0-6-2.69-6-6s2.69-6 6-6c1.66 0 3.14.69 4.22 1.78L13 11h7V4l-2.35 2.35z"/></svg><span class="action-name">Переспавн команды</span></div>
<div class="action-card" onclick="triggerAction(this)" data-action="respawn"><svg class="action-icon" viewBox="0 0 24 24"><path d="M17.65 6.35C16.2 4.9 14.21 4 12 4c-4.42 0-7.99 3.58-7.99 8s3.57 8 7.99 8c3.73 0 6.84-2.55 7.73-6h-2.08c-.82 2.33-3.04 4-5.65 4-3.31 0-6-2.69-6-6s2.69-6 6-6c1.66 0 3.14.69 4.22 1.78L13 11h7V4l-2.35 2.35z"/></svg><span class="action-name">Перереспавн</span></div>
<div class="action-card" onclick="triggerAction(this)" data-action="kill" style="border-color:var(--danger)"><svg class="action-icon" viewBox="0 0 24 24" style="fill:var(--danger)"><path d="M12 2C6.47 2 2 6.47 2 12s4.47 10 10 10 10-4.47 10-10S17.53 2 12 2zm5 13.59L15.59 17 12 13.41 8.41 17 7 15.59 10.59 12 7 8.41 8.41 7 12 10.59 15.59 7 17 8.41 13.41 12 17 15.59z"/></svg><span class="action-name" style="color:var(--danger)">Убить</span></div>
<div class="action-card" onclick="triggerAction(this)" data-action="kick_from_event" style="border-color:var(--danger)"><svg class="action-icon" viewBox="0 0 24 24" style="fill:var(--danger)"><path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/></svg><span class="action-name" style="color:var(--danger)">Выгнать с ивента</span></div>
</div>
<div class="category-title">Перемещение</div>
<div class="actions-grid">
<div class="action-card" onclick="triggerAction(this)" data-action="run_speed"><svg class="action-icon" viewBox="0 0 24 24"><path d="M13.5 5.5c1.1 0 2-.9 2-2s-.9-2-2-2-2 .9-2 2 .9 2 2 2zM9.8 8.9L7 23h2.1l1.8-8 2.1 2v6h2v-7.5l-2.1-2 .6-3C14.8 12 16.8 13 19 13v-2c-1.9 0-3.5-1-4.3-2.4l-1-1.6c-.4-.6-1-1-1.7-1-.3 0-.5.1-.8.1L6 8.3V13h2V9.6l1.8-.7"/></svg><span class="action-name">Скорость бега</span></div>
<div class="action-card" onclick="triggerAction(this)" data-action="walk_speed"><svg class="action-icon" viewBox="0 0 24 24"><path d="M13.5 5.5c1.1 0 2-.9 2-2s-.9-2-2-2-2 .9-2 2 .9 2 2 2zM9.8 8.9L7 23h2.1l1.8-8 2.1 2v6h2v-7.5l-2.1-2 .6-3C14.8 12 16.8 13 19 13v-2c-1.9 0-3.5-1-4.3-2.4l-1-1.6c-.4-.6-1-1-1.7-1-.3 0-.5.1-.8.1L6 8.3V13h2V9.6l1.8-.7"/></svg><span class="action-name">Скорость ходьбы</span></div>
<div class="action-card" onclick="triggerAction(this)" data-action="jump_height"><svg class="action-icon" viewBox="0 0 24 24"><path d="M12 5V2L8 6l4 4V7c3.31 0 6 2.69 6 6 0 2.97-2.17 5.43-5 5.91V21c4.42-.49 8-4.24 8-8.85 0-4.69-3.81-8.5-8.5-8.5zM10 13c0-1.1-.9-2-2-2s-2 .9-2 2 .9 2 2 2 2-.9 2-2z"/></svg><span class="action-name">Высота прыжка</span></div>
</div>
<div class="category-title">ХП/Броня/Голод</div>
<div class="actions-grid">
<div class="action-card" onclick="triggerAction(this)" data-action="give_health"><svg class="action-icon" viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 14h-2v-4H6v-2h4V7h2v4h4v2h-4v4z"/></svg><span class="action-name">Здоровье</span></div>
<div class="action-card" onclick="triggerAction(this)" data-action="give_armor"><svg class="action-icon" viewBox="0 0 24 24"><path d="M12 1L3 5v6c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V5l-9-4z"/></svg><span class="action-name">Броня</span></div>
<div class="action-card" onclick="triggerAction(this)" data-action="give_hunger"><svg class="action-icon" viewBox="0 0 24 24"><path d="M11 9H9V2H7v7H5V2H3v7c0 2.12 1.66 3.84 3.75 3.97V22h2.5v-9.03C11.34 12.84 13 11.12 13 9V2h-2v7zm5-3v8h2.5v8H21V2c-2.76 0-5 2.24-5 4z"/></svg><span class="action-name">Голод</span></div>
<div class="action-card" onclick="triggerAction(this)" data-action="godmode"><svg class="action-icon" viewBox="0 0 24 24"><path d="M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z"/></svg><span class="action-name">Godmode</span></div>
</div>
<div class="category-title">Изменить Модель</div>
<div class="actions-grid">
<div class="action-card" onclick="showModelModal()"><svg class="action-icon" viewBox="0 0 24 24"><path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/></svg><span class="action-name">Изменить Модель</span></div>
<div class="action-card" onclick="triggerAction(this)" data-action="model_scale"><svg class="action-icon" viewBox="0 0 24 24"><path d="M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/></svg><span class="action-name">Размер модели</span></div>
<div class="action-card" onclick="triggerAction(this)" data-action="model_color"><svg class="action-icon" viewBox="0 0 24 24"><path d="M12 3c-4.97 0-9 4.03-9 9s4.03 9 9 9c.83 0 1.5-.67 1.5-1.5 0-.39-.15-.74-.39-1.01-.23-.26-.38-.61-.38-.99 0-.83.67-1.5 1.5-1.5H16c2.76 0 5-2.24 5-5 0-4.42-4.03-8-9-8zm-5.5 9c-.83 0-1.5-.67-1.5-1.5S5.67 9 6.5 9 8 9.67 8 10.5 7.33 12 6.5 12zm3-4C8.67 8 8 7.33 8 6.5S8.67 5 9.5 5s1.5.67 1.5 1.5S10.33 8 9.5 8zm5 0c-.83 0-1.5-.67-1.5-1.5S13.67 5 14.5 5s1.5.67 1.5 1.5S15.33 8 14.5 8zm3 4c-.83 0-1.5-.67-1.5-1.5S16.67 9 17.5 9s1.5.67 1.5 1.5-.67 1.5-1.5 1.5z"/></svg><span class="action-name">Цвет</span></div>
</div>
<div class="category-title">Арсенал</div>
<div class="actions-grid">
<div class="action-card" onclick="showGiveWeaponModal()"><svg class="action-icon" viewBox="0 0 24 24"><path d="M20 6h-4V4c0-1.11-.89-2-2-2h-4c-1.11 0-2 .89-2 2v2H4c-1.11 0-1.99.89-1.99 2L2 19c0 1.11.89 2 2 2h18c1.11 0 2-.89 2-2V8c0-1.11-.89-2-2-2z"/></svg><span class="action-name">Выдать оружие</span></div>
<div class="action-card" onclick="doStripWeapons()"><svg class="action-icon" viewBox="0 0 24 24"><path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/></svg><span class="action-name">Отобрать оружие</span></div>
</div>
<div class="category-title">Прочее</div>
<div class="actions-grid">
<div class="action-card bulk" onclick="bulkAction('toggle_collision')"><svg class="action-icon" viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/></svg><span class="action-name">Столкновение вкл/выкл</span></div>
<div class="action-card" onclick="triggerAction(this)" data-action="toggle_nick_visibility"><svg class="action-icon" viewBox="0 0 24 24"><path d="M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5zM12 17c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5zm0-8c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3z"/></svg><span class="action-name">Скрыть/Показать ник</span></div>
</div>
<div class="category-title">Наказания</div>
<div class="actions-grid">
<div class="action-card" onclick="triggerAction(this)" data-action="mute"><svg class="action-icon" viewBox="0 0 24 24"><path d="M4 4h16v12H7l-3 3V4zm4 4h8v2H8V8zm0 4h6v2H8v-2z"/></svg><span class="action-name">Мут</span></div>
<div class="action-card" onclick="triggerAction(this)" data-action="gag"><svg class="action-icon" viewBox="0 0 24 24"><path d="M12 14a3 3 0 0 0 3-3V5a3 3 0 0 0-6 0v6a3 3 0 0 0 3 3zm5-3a5 5 0 0 1-10 0H5a7 7 0 0 0 6 6.92V20h2v-2.08A7 7 0 0 0 19 11h-2z"/><path d="M4 4l16 16" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round"/></svg><span class="action-name">Гаг</span></div>
<div class="action-card" onclick="triggerAction(this)" data-action="punch" style="border-color:var(--danger)"><svg class="action-icon" viewBox="0 0 24 24" style="fill:var(--danger)"><path d="M7 5h3l4 7 6 2v4H4v-5l3-8z"/><path d="M4 20h16v2H4z"/></svg><span class="action-name" style="color:var(--danger)">Пинок</span></div>
<div class="action-card" onclick="triggerAction(this)" data-action="ignite" style="border-color:var(--danger)"><svg class="action-icon" viewBox="0 0 24 24" style="fill:var(--danger)"><path d="M13.5.67s.74 2.65.74 4.8c0 2.06-1.35 3.73-3.41 3.73-2.07 0-3.63-1.67-3.63-3.73l.03-.36C5.21 7.51 4 10.62 4 14c0 4.42 3.58 8 8 8s8-3.58 8-8C20 8.61 17.41 3.36 13.5.67zM11.71 19c-1.78 0-3.22-1.4-3.22-3.12 0-1.72 1.44-3.12 3.22-3.12 1.78 0 3.22 1.4 3.22 3.12 0 1.72-1.44 3.12-3.22 3.12z"/></svg><span class="action-name" style="color:var(--danger)">Поджог</span></div>
</div>
</div>
</div>
<div class="sidebar-resize" id="sidebarResize"></div>
<div class="targets-column">
<div class="search-bar">
<input type="text" class="search-input" placeholder="Поиск по нику или SteamID..." id="playerSearch">
<button class="select-all-btn" id="selectAllBtn">Выбрать всех</button>
<div class="dropdown">
<button class="select-btn" onclick="toggleDropdown()"><span>Выбрать...</span><svg width="12" height="12" viewBox="0 0 24 24" fill="currentColor"><path d="M7 10l5 5 5-5z"/></svg></button>
<div class="dropdown-menu" id="selectDropdown">
<div class="dropdown-item" onclick="selectByFilter('all')">Всех</div>
<div class="dropdown-item" onclick="selectByFilter('none')">Никого (Очистить)</div>
<div style="height:1px;background:#3f3f46;margin:4px 0"></div>
<div class="dropdown-item" onclick="selectByFilter('red')"><div class="team-dot" style="background:var(--team-red)"></div>Красных</div>
<div class="dropdown-item" onclick="selectByFilter('blue')"><div class="team-dot" style="background:var(--team-blue)"></div>Синих</div>
<div class="dropdown-item" onclick="selectByFilter('green')"><div class="team-dot" style="background:var(--team-green)"></div>Зеленых</div>
<div class="dropdown-item" onclick="selectByFilter('yellow')"><div class="team-dot" style="background:var(--team-yellow)"></div>Желтых</div>
<div class="dropdown-item" onclick="selectByFilter('purple')"><div class="team-dot" style="background:var(--team-purple)"></div>Фиол.</div>
</div>
</div>
                    </div>
<div class="players-list" id="playersList"></div>
<div class="modal-overlay" id="customTemplateModal">
<div class="modal-box" style="min-width:420px">
<div class="modal-title">Создание шаблона</div>
<div class="section"><span class="label">Название шаблона</span><input type="text" class="modal-input" id="ctTplName" placeholder="Название..." style="margin-bottom:12px"></div>
<div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-bottom:16px">
    <div class="section"><span class="label">Здоровье</span><input type="number" class="modal-input" id="ctTplHealth" placeholder="100" style="margin:0"></div>
    <div class="section"><span class="label">Броня</span><input type="number" class="modal-input" id="ctTplArmor" placeholder="0" style="margin:0"></div>
    <div class="section"><span class="label">Ходьба</span><input type="number" class="modal-input" id="ctTplWalkSpeed" placeholder="200" style="margin:0"></div>
    <div class="section"><span class="label">Бег</span><input type="number" class="modal-input" id="ctTplRunSpeed" placeholder="400" style="margin:0"></div>
</div>
<div style="display:flex;gap:10px;margin-bottom:16px">
    <button class="btn btn-ghost btn-sm" style="flex:1;border:1px solid var(--border)" onclick="showModelModal(selectModelForCustomTemplate)">👤 Выбрать модель</button>
    <button class="btn btn-ghost btn-sm" style="flex:1;border:1px solid var(--border)" onclick="showTemplateWeaponModal()">🔫 Выбрать оружие</button>
</div>
<div id="ctTplSelectionStatus" style="font-size:11px;color:var(--text-muted);margin-bottom:16px;background:rgba(255,255,255,0.05);padding:8px;border-radius:4px">
    Модель: <span id="ctTplModelName">По умолчанию</span><br>
    Оружие: <span id="ctTplWeaponCount">0</span> выбрано
</div>
<div class="modal-btns">
    <button class="btn btn-ghost" onclick="closeCustomTemplateModal()">Отмена</button>
    <button class="btn btn-primary" onclick="confirmCustomTemplate()">Сохранить</button>
</div>
</div>
</div>
<div class="modal-overlay" id="valueModal">
<div class="modal-box">
<div class="modal-title" id="valueModalTitle">Введите значение</div>
<input type="text" class="modal-input" id="valueModalInput" placeholder="">
<div class="modal-btns">
<button class="btn btn-ghost" onclick="closeValueModal()">Отмена</button>
<button class="btn btn-primary" onclick="confirmValueModal()">OK</button>
                </div>
            </div>
                </div>
<div class="modal-overlay" id="scaleModal">
<div class="modal-box">
<div class="modal-title">Размер модели</div>
<div class="scale-slider-wrap">
<label>Масштаб: <span class="scale-value" id="scaleValue">1.0</span></label>
<input type="range" class="scale-slider" id="scaleSlider" min="0.1" max="5" step="0.1" value="1">
</div>
<div class="modal-btns">
<button class="btn btn-ghost" onclick="closeScaleModal()">Отмена</button>
<button class="btn btn-primary" onclick="confirmScaleModal()">OK</button>
</div>
</div>
</div>
<div class="modal-overlay" id="spawnTeamModal">
<div class="modal-box">
<div class="modal-title">Выберите команду для спавна</div>
<div class="team-grid" style="margin-bottom:16px">
<div class="team-btn" onclick="setSpawnForTeam('red')" data-team="red"><div class="team-dot" style="background:var(--team-red)"></div>Красные</div>
<div class="team-btn" onclick="setSpawnForTeam('blue')" data-team="blue"><div class="team-dot" style="background:var(--team-blue)"></div>Синие</div>
<div class="team-btn" onclick="setSpawnForTeam('green')" data-team="green"><div class="team-dot" style="background:var(--team-green)"></div>Зеленые</div>
<div class="team-btn" onclick="setSpawnForTeam('yellow')" data-team="yellow"><div class="team-dot" style="background:var(--team-yellow)"></div>Желтые</div>
<div class="team-btn" onclick="setSpawnForTeam('purple')" data-team="purple"><div class="team-dot" style="background:var(--team-purple)"></div>Фиол.</div>
</div>
<button class="btn btn-ghost" onclick="closeSpawnTeamModal()" style="width:100%">Отмена</button>
</div>
</div>
<div class="modal-overlay model-modal" id="modelModal">
<div class="modal-box">
<div class="modal-title">Выберите модель игрока</div>
<div class="model-grid" id="modelGrid"></div>
<div class="modal-btns" style="margin-top:12px">
<button class="btn btn-primary" onclick="showCustomModelPathInput()">Свой путь</button>
<button class="btn btn-ghost" onclick="closeModelModal()">Отмена</button>
</div>
</div>
</div>


<div class="modal-overlay weapon-modal" id="tplWeaponModal">
<div class="modal-box">
<button class="modal-close" onclick="closeTemplateWeaponModal()">×</button>
<div class="modal-title">Выбор оружия <span id="tplWepCount" style="font-size:13px;color:var(--accent);font-weight:400"></span></div>
<div class="weapon-tabs" id="weaponTabs"></div>
<input type="text" class="weapon-search" id="tplWeaponSearch" placeholder="Поиск оружия...">
<div class="weapon-grid" id="weaponGrid"></div>
<div class="modal-btns" style="margin-top:12px">
<button class="btn btn-ghost" onclick="ctSelectedWeapons=[];renderWeaponGrid();">Сброс</button>
<button class="btn btn-primary" onclick="closeTemplateWeaponModal()">Готово</button>
</div>
</div>
</div>

<div class="modal-overlay" id="colorModal">
<div class="modal-box">
<div class="modal-title">Цвет модели</div>
<div class="color-select-wrap" id="colorSelectWrap">
<button type="button" class="color-select-btn" id="colorSelectBtn" onclick="toggleColorDropdown()">
<span class="color-select-swatch" id="colorSelectSwatch" style="background:rgb(255,255,255)"></span>
<span id="colorSelectLabel">Белый</span>
</button>
<div class="color-select-dropdown" id="colorSelectDropdown">
<div class="color-select-item" data-rgb="255,255,255" data-name="Белый" onclick="selectColorItem(this)"><span class="color-select-swatch" style="background:rgb(255,255,255)"></span>Белый</div>
<div class="color-select-item" data-rgb="0,0,0" data-name="Чёрный" onclick="selectColorItem(this)"><span class="color-select-swatch" style="background:rgb(0,0,0)"></span>Чёрный</div>
<div class="color-select-item" data-rgb="255,0,0" data-name="Красный" onclick="selectColorItem(this)"><span class="color-select-swatch" style="background:rgb(255,0,0)"></span>Красный</div>
<div class="color-select-item" data-rgb="0,0,255" data-name="Синий" onclick="selectColorItem(this)"><span class="color-select-swatch" style="background:rgb(0,0,255)"></span>Синий</div>
<div class="color-select-item" data-rgb="0,255,0" data-name="Зелёный" onclick="selectColorItem(this)"><span class="color-select-swatch" style="background:rgb(0,255,0)"></span>Зелёный</div>
<div class="color-select-item" data-rgb="255,255,0" data-name="Жёлтый" onclick="selectColorItem(this)"><span class="color-select-swatch" style="background:rgb(255,255,0)"></span>Жёлтый</div>
<div class="color-select-item" data-rgb="255,165,0" data-name="Оранжевый" onclick="selectColorItem(this)"><span class="color-select-swatch" style="background:rgb(255,165,0)"></span>Оранжевый</div>
<div class="color-select-item" data-rgb="128,0,128" data-name="Фиолетовый" onclick="selectColorItem(this)"><span class="color-select-swatch" style="background:rgb(128,0,128)"></span>Фиолетовый</div>
<div class="color-select-item" data-rgb="255,192,203" data-name="Розовый" onclick="selectColorItem(this)"><span class="color-select-swatch" style="background:rgb(255,192,203)"></span>Розовый</div>
<div class="color-select-item" data-rgb="0,191,255" data-name="Голубой" onclick="selectColorItem(this)"><span class="color-select-swatch" style="background:rgb(0,191,255)"></span>Голубой</div>
<div class="color-select-item" data-rgb="128,128,128" data-name="Серый" onclick="selectColorItem(this)"><span class="color-select-swatch" style="background:rgb(128,128,128)"></span>Серый</div>
<div class="color-select-item" data-rgb="139,69,19" data-name="Коричневый" onclick="selectColorItem(this)"><span class="color-select-swatch" style="background:rgb(139,69,19)"></span>Коричневый</div>
</div>
</div>
<div class="modal-btns">
<button class="btn btn-ghost" onclick="closeColorModal()">Отмена</button>
<button class="btn btn-primary" onclick="confirmColorModal()">OK</button>
</div>
</div>
</div>
</div>
</div>
<footer class="panel-footer">
<div class="footer-left">
<label class="toggle-switch"><input type="checkbox" checked id="eventToggle" onchange="if(window.gmod&&window.gmod.ToggleEvent)window.gmod.ToggleEvent(this.checked)"><div class="toggle-track"><div class="toggle-knob"></div></div><span class="toggle-label">Вход открыт</span></label>
<button class="btn btn-success" id="btnStartEvent" onclick="if(!this.disabled&&window.gmod&&window.gmod.StartEvent)window.gmod.StartEvent()">Начать событие</button>
<button class="btn btn-danger" id="btnEndEvent" onclick="if(!this.disabled)confirmEndEvent()">Завершить событие</button>
            </div>
<div class="btns-group">
<button class="btn btn-ghost" onclick="clearSelection()">Сброс</button>
            </div>
        </footer>
<div class="resize-handle" id="resizeHandle" title="Изменить размер"></div>
</div>
<div class="context-menu" id="contextMenu">
<div class="context-menu-item" onclick="copySteamId()"><svg viewBox="0 0 24 24"><path d="M16 1H4c-1.1 0-2 .9-2 2v14h2V3h12V1zm3 4H8c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h11c1.1 0 2-.9 2-2V7c0-1.1-.9-2-2-2zm0 16H8V7h11v14z"/></svg><span>Копировать ник + Steam ID</span></div>
<div class="context-menu-item danger" onclick="kickPlayer()"><svg viewBox="0 0 24 24"><path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/></svg><span>Кикнуть с ивента</span></div>
    </div>
    <script>
let players=[];let selectedContextPlayer=null;let templates=[];let valueModalCallback=null;let colorModalCallback=null;let scaleModalCallback=null;let selectedColorRgb='255,255,255';let selectedPlayerIds=new Set();let playerStatuses={};
function updatePlayerCounter(){const el=document.getElementById('playerCounter'),lim=document.getElementById('maxPlayersInput');if(!el||!lim)return;el.innerHTML='<span>'+players.length+'</span>/'+lim.value}
function showValueModal(title,defaultVal,cb){valueModalCallback=cb;document.getElementById('valueModal').classList.add('show');if(window.gmod&&window.gmod.SetModalOpen)window.gmod.SetModalOpen(true);document.getElementById('valueModalTitle').textContent=title;const inp=document.getElementById('valueModalInput');inp.value=defaultVal||'';inp.placeholder=title;inp.focus();inp.select()}
function closeValueModal(){document.getElementById('valueModal').classList.remove('show');valueModalCallback=null;if(window.gmod&&window.gmod.SetModalOpen)window.gmod.SetModalOpen(false)}
function confirmValueModal(){const v=document.getElementById('valueModalInput').value;const cb=valueModalCallback;closeValueModal();if(cb)cb(v)}
function showModelScaleModal(cb){scaleModalCallback=cb;const sl=document.getElementById('scaleSlider'),val=document.getElementById('scaleValue');if(sl){sl.value='1';if(val)val.textContent='1.0'}document.getElementById('scaleModal').classList.add('show');if(window.gmod&&window.gmod.SetModalOpen)window.gmod.SetModalOpen(true)}
function closeScaleModal(){document.getElementById('scaleModal').classList.remove('show');scaleModalCallback=null;if(window.gmod&&window.gmod.SetModalOpen)window.gmod.SetModalOpen(false)}
function confirmScaleModal(){const sl=document.getElementById('scaleSlider');const v=sl?parseFloat(sl.value)||1:1;const cb=scaleModalCallback;closeScaleModal();if(cb)cb(v)}
function toggleColorDropdown(){const btn=document.getElementById('colorSelectBtn'),dd=document.getElementById('colorSelectDropdown');btn.classList.toggle('open');dd.classList.toggle('show')}
function selectColorItem(el){const rgb=el.dataset.rgb,name=el.dataset.name;selectedColorRgb=rgb;document.getElementById('colorSelectSwatch').style.background='rgb('+rgb+')';document.getElementById('colorSelectLabel').textContent=name;document.getElementById('colorSelectBtn').classList.remove('open');document.getElementById('colorSelectDropdown').classList.remove('show')}
function showColorModal(cb){colorModalCallback=cb;selectedColorRgb='255,255,255';document.getElementById('colorSelectSwatch').style.background='rgb(255,255,255)';document.getElementById('colorSelectLabel').textContent='Белый';document.getElementById('colorSelectBtn').classList.remove('open');document.getElementById('colorSelectDropdown').classList.remove('show');document.getElementById('colorModal').classList.add('show');if(window.gmod&&window.gmod.SetModalOpen)window.gmod.SetModalOpen(true)}
function closeColorModal(){document.getElementById('colorModal').classList.remove('show');colorModalCallback=null;if(window.gmod&&window.gmod.SetModalOpen)window.gmod.SetModalOpen(false)}
function showSpawnTeamModal(){document.getElementById('spawnTeamModal').classList.add('show');if(window.gmod&&window.gmod.SetModalOpen)window.gmod.SetModalOpen(true)}
const MODEL_LIST=[{path:'models/player/alyx.mdl',name:'Alyx'},{path:'models/player/barney.mdl',name:'Barney'},{path:'models/player/breen.mdl',name:'Breen'},{path:'models/player/p2_chell.mdl',name:'Chell'},{path:'models/player/eli.mdl',name:'Eli'},{path:'models/player/gman_high.mdl',name:'G-Man'},{path:'models/player/kleiner.mdl',name:'Kleiner'},{path:'models/player/monk.mdl',name:'Monk'},{path:'models/player/mossman.mdl',name:'Mossman'},{path:'models/player/mossman_arctic.mdl',name:'Mossman Arctic'},{path:'models/player/odessa.mdl',name:'Odessa'},{path:'models/player/magnusson.mdl',name:'Magnusson'},{path:'models/player/police.mdl',name:'Police',img:'models_player_police.jpg'},{path:'models/player/police_fem.mdl',name:'Police Female',img:'models_player_police_fem.jpg'},{path:'models/player/combine_soldier.mdl',name:'Combine Soldier',img:'models_player_combine_soldier.jpg'},{path:'models/player/combine_super_soldier.mdl',name:'Combine Super Soldier',img:'models_player_combine_super_soldier.jpg'},{path:'models/player/combine_soldier_prisonguard.mdl',name:'Combine Prison Guard'},{path:'models/player/soldier_stripped.mdl',name:'Soldier Stripped'},{path:'models/player/Group01/male_01.mdl',name:'Male 01'},{path:'models/player/Group01/male_02.mdl',name:'Male 02'},{path:'models/player/Group01/male_03.mdl',name:'Male 03'},{path:'models/player/Group01/male_04.mdl',name:'Male 04'},{path:'models/player/Group01/male_05.mdl',name:'Male 05'},{path:'models/player/Group01/male_06.mdl',name:'Male 06'},{path:'models/player/Group01/male_07.mdl',name:'Male 07'},{path:'models/player/Group01/male_08.mdl',name:'Male 08'},{path:'models/player/Group01/male_09.mdl',name:'Male 09'},{path:'models/player/Group01/female_01.mdl',name:'Female 01'},{path:'models/player/Group01/female_02.mdl',name:'Female 02'},{path:'models/player/Group01/female_03.mdl',name:'Female 03'},{path:'models/player/Group01/female_04.mdl',name:'Female 04'},{path:'models/player/Group01/female_05.mdl',name:'Female 05',img:'models_player_group01_female_05.jpg'},{path:'models/player/Group01/female_06.mdl',name:'Female 06',img:'models_player_group01_female_06.jpg'},{path:'models/player/Group02/male_02.mdl',name:'Male 02 (G2)'},{path:'models/player/Group02/male_04.mdl',name:'Male 04 (G2)'},{path:'models/player/Group02/male_06.mdl',name:'Male 06 (G2)'},{path:'models/player/Group02/male_08.mdl',name:'Male 08 (G2)'},{path:'models/player/Group03/male_01.mdl',name:'Male 01 (G3)'},{path:'models/player/Group03/male_02.mdl',name:'Male 02 (G3)'},{path:'models/player/Group03/male_03.mdl',name:'Male 03 (G3)'},{path:'models/player/Group03/male_04.mdl',name:'Male 04 (G3)'},{path:'models/player/Group03/male_05.mdl',name:'Male 05 (G3)'},{path:'models/player/Group03/male_06.mdl',name:'Male 06 (G3)'},{path:'models/player/Group03/male_07.mdl',name:'Male 07 (G3)'},{path:'models/player/Group03/male_08.mdl',name:'Male 08 (G3)'},{path:'models/player/Group03/male_09.mdl',name:'Male 09 (G3)'},{path:'models/player/Group03/female_01.mdl',name:'Female 01 (G3)',img:'models_player_group03_female_01.jpg'},{path:'models/player/Group03/female_02.mdl',name:'Female 02 (G3)',img:'models_player_group03_female_02.jpg'},{path:'models/player/Group03/female_03.mdl',name:'Female 03 (G3)'},{path:'models/player/Group03/female_04.mdl',name:'Female 04 (G3)'},{path:'models/player/Group03/female_05.mdl',name:'Female 05 (G3)'},{path:'models/player/Group03/female_06.mdl',name:'Female 06 (G3)'},{path:'models/player/Group03m/male_01.mdl',name:'Male 01 (G3m)'},{path:'models/player/Group03m/male_02.mdl',name:'Male 02 (G3m)'},{path:'models/player/Group03m/male_03.mdl',name:'Male 03 (G3m)'},{path:'models/player/Group03m/male_04.mdl',name:'Male 04 (G3m)'},{path:'models/player/Group03m/male_05.mdl',name:'Male 05 (G3m)'},{path:'models/player/Group03m/male_06.mdl',name:'Male 06 (G3m)'},{path:'models/player/Group03m/male_07.mdl',name:'Male 07 (G3m)'},{path:'models/player/Group03m/male_08.mdl',name:'Male 08 (G3m)'},{path:'models/player/Group03m/male_09.mdl',name:'Male 09 (G3m)'},{path:'models/player/Group03m/female_01.mdl',name:'Female 01 (G3m)'},{path:'models/player/Group03m/female_02.mdl',name:'Female 02 (G3m)'},{path:'models/player/Group03m/female_03.mdl',name:'Female 03 (G3m)'},{path:'models/player/Group03m/female_04.mdl',name:'Female 04 (G3m)'},{path:'models/player/Group03m/female_05.mdl',name:'Female 05 (G3m)'},{path:'models/player/Group03m/female_06.mdl',name:'Female 06 (G3m)'},{path:'models/player/hostage/hostage_01.mdl',name:'Hostage 01'},{path:'models/player/hostage/hostage_02.mdl',name:'Hostage 02'},{path:'models/player/hostage/hostage_03.mdl',name:'Hostage 03'},{path:'models/player/hostage/hostage_04.mdl',name:'Hostage 04'},{path:'models/player/arctic.mdl',name:'Arctic'},{path:'models/player/gasmask.mdl',name:'Gasmask'},{path:'models/player/guerilla.mdl',name:'Guerilla'},{path:'models/player/leet.mdl',name:'Leet'},{path:'models/player/phoenix.mdl',name:'Phoenix'},{path:'models/player/riot.mdl',name:'Riot'},{path:'models/player/swat.mdl',name:'SWAT'},{path:'models/player/urban.mdl',name:'Urban'},{path:'models/player/dod_american.mdl',name:'DoD American'},{path:'models/player/dod_german.mdl',name:'DoD German'},{path:'models/player/zombie_classic.mdl',name:'Zombie Classic'},{path:'models/player/zombie_fast.mdl',name:'Zombie Fast'},{path:'models/player/zombie_soldier.mdl',name:'Zombie Soldier'},{path:'models/player/skeleton.mdl',name:'Skeleton'},{path:'models/player/charple.mdl',name:'Charple'},{path:'models/player/corpse1.mdl',name:'Corpse'}];
const PERSON_ICON='<svg viewBox="0 0 24 24"><path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/></svg>';
const MODEL_IMAGE_FILE_MAP={
'models/player/police.mdl':'models_player_police.jpg',
'models/player/police_fem.mdl':'models_player_police_fem.jpg',
'models/player/combine_soldier.mdl':'models_player_combine_soldier.jpg',
'models/player/combine_super_soldier.mdl':'models_player_combine_super_soldier.jpg',
'models/player/group01/female_05.mdl':'models_player_group01_female_05.jpg',
'models/player/group01/female_06.mdl':'models_player_group01_female_06.jpg',
'models/player/group03/female_01.mdl':'models_player_group03_female_01.jpg',
'models/player/group03/female_02.mdl':'models_player_group03_female_02.jpg'
};
function getModelImageCandidates(modelPath){
    const raw=String(modelPath||'').replace(/\\/g,'/');
    const key=raw.toLowerCase();
    const p=raw.replace(/\.(mdl|jpg|jpeg|png|webp)$/i,'');
    const parts=p.split('/');
    const rawParts=raw.split('/');
    const base=(parts[parts.length-1]||'').toLowerCase();
    const full=p.replace(/\//g,'_');
    const stems=[];
    const add=s=>{if(s&&stems.indexOf(s)===-1)stems.push(s)};
    const exts=['.jpg','.jpeg','.png','.webp'];
    const roots=['asset://garrysmod/materials/event_menu_pers/','asset://garrysmod/materials/event_menu/','asset://garrysmod/data/event_menu/','asset://garrysmod/data/'];
    const out=[];
    if(MODEL_IMAGE_FILE_MAP[key])roots.forEach(root=>out.push(root+MODEL_IMAGE_FILE_MAP[key]));
    add(p);add(full);add(full.toLowerCase());
    add('models_player_'+base);add(base);
    if(base==='police_fem')add('models_player_police_fem');
    if(base==='police_female')add('models_player_police_female');
    if(rawParts.length>=3&&/^group\d+m?$/i.test(rawParts[2])){
        add('models_player_'+rawParts[2].toLowerCase()+'_'+base);add('models_player_'+base)
    }
    roots.forEach(root=>stems.forEach(st=>exts.forEach(ext=>out.push(root+st+ext))));
    return out
}
let modelModalCallback=null;
function showModelModal(cb){
    if(typeof cb==='function')modelModalCallback=cb;
    else{
        const s=document.querySelectorAll('.player-item.selected');
        if(s.length===0){showNotification('Выберите игроков!','error');return}
        modelModalCallback=null;
    }
    const g=document.getElementById('modelGrid');
    if(!g)return;
    g.innerHTML='';
    MODEL_LIST.forEach(m=>{
        const card=document.createElement('div');
        card.className='model-card';
        card.onclick=()=>selectModel(m.path);
        const thumb=document.createElement('div');
        thumb.className='model-card-thumb';
        const img=document.createElement('img');
        img.alt=String(m.name||'');
        const fallback=document.createElement('span');
        fallback.innerHTML=PERSON_ICON;
        const candidates=[...getModelImageCandidates(m.path)];
        if(m.img)candidates.unshift(...getModelImageCandidates(m.img));
        let i=0;
        const tryNext=()=>{if(i>=candidates.length){img.style.display='none';fallback.style.display='flex';return}img.src=candidates[i++]};
        img.onerror=tryNext;
        tryNext();
        thumb.appendChild(img);
        thumb.appendChild(fallback);
        const name=document.createElement('div');
        name.className='model-card-name';
        name.textContent=String(m.name||'');
        const path=document.createElement('div');
        path.className='model-card-path';
        path.textContent=String(m.path||'');
        card.appendChild(thumb);
        card.appendChild(name);
        card.appendChild(path);
        g.appendChild(card);
    });
    document.getElementById('modelModal').classList.add('show');
    if(window.gmod&&window.gmod.SetModalOpen)window.gmod.SetModalOpen(true);
}
function selectModel(path){
    if(modelModalCallback)modelModalCallback(path);
    else if(window.gmod&&window.gmod.ExecuteAction){
        const s=document.querySelectorAll('.player-item.selected');
        const ids=Array.from(s).map(e=>parseInt(e.dataset.id));
        window.gmod.ExecuteAction('set_model',JSON.stringify(ids),0,path);
        showNotification('Модель изменена','success');
    }
    closeModelModal();
}
function closeModelModal(){document.getElementById('modelModal').classList.remove('show');modelModalCallback=null;if(window.gmod&&window.gmod.SetModalOpen)window.gmod.SetModalOpen(false)}
function showCustomModelPathInput(){showValueModal('Введите путь до модели:','',path=>{if(path&&path.trim())selectModel(path.trim())})}

let ctSelectedModel='';
let ctSelectedWeapons=[];
function showCustomTemplateModal(){
    document.getElementById('customTemplateModal').classList.add('show');
    if(window.gmod&&window.gmod.SetModalOpen)window.gmod.SetModalOpen(true);
}
function closeCustomTemplateModal(){
    document.getElementById('customTemplateModal').classList.remove('show');
    if(window.gmod&&window.gmod.SetModalOpen)window.gmod.SetModalOpen(false);
}
function selectModelForCustomTemplate(path){
    ctSelectedModel=path;
    document.getElementById('ctTplModelName').textContent=path.split('/').pop();
}
const HIDDEN_WEAPON_CLASSES=new Set([
    'fishing_rod',
    'weapon_zaklad',
    'weapon_zakladprem',
    'kabanizator_pig',
    'pass_rus',
    'pocket',
    'weapon_runner',
    'zwf_shoptablet',
    'weapon_rp_handcuffed',
    'blanket_fee',
    'wos_fornite_dancer',
    'weapon_rp_base',
    'tfa_scoped_base',
    'tfa_nade_base',
    'tfa_melee_base',
    'tfa_knife_base',
    'tfa_gun_base',
    'tfa_cssnade_base',
    'tfa_bow_base',
    'tfa_bash_base',
    'tfa_akimbo_base',
    'tfa_3dscoped_base',
    'tfa_3dbash_base',
    'swm_choping_axe',
    'swb_base',
    'cw_base',
    'csgo_baseknife',
    'csgo_baseknife_legacy',
    'csgo_bayonet_tiger',
    'csgo_karambit_tiger',
    'csgo_huntsman_tiger',
    'csgo_butterfly_crimsonwebs',
    'csgo_butterfly_damascus',
    'csgo_m9_damascus',
    'csgo_huntsman_damascus',
    'csgo_huntsman_slaughter',
    'baseflashbang',
    'tfa_sword_advanced_base',
    'sandbox_knuckle',
    'weapon_nav_editor',
    'pill_wep_morphgun',
    'zwf_joint',
    'weapon_hl2hook',
    'pill_wep_holstered',
    'cwb_crowbar',
    'coordinat',
    'cityworker_config',
    'weapon_crossbow',
    'chess_admin_tool',
    'weapon_hl2brokenbottle',
    'pill_wep_annabelle',
    'pill_web_alyxgun',
    'deployable_shield'
].map(s=>s.toLowerCase()));
let WEAPON_LIST=[];
let activeWeaponTab='Все';
function renderWeaponGrid(filter){
    const q=(filter||document.getElementById('tplWeaponSearch').value||'').toLowerCase();
    const g=document.getElementById('weaponGrid');
    if(!g)return;
    g.innerHTML='';
    
    // Tabs container
    const tabContainer=document.getElementById('weaponTabs');
    if(tabContainer && tabContainer.innerHTML===''){
        const cats=['Все',...new Set(WEAPON_LIST.map(w=>w.cat))];
        cats.forEach(cat=>{
            const tab=document.createElement('div');
            tab.className='weapon-tab'+(activeWeaponTab===cat?' active':'');
            tab.textContent=cat;
            tab.onclick=()=>{
                activeWeaponTab=cat;
                document.querySelectorAll('.weapon-tab').forEach(t=>t.classList.remove('active'));
                tab.classList.add('active');
                renderWeaponGrid();
            };
            tabContainer.appendChild(tab);
        });
    }

    const shown = WEAPON_LIST.filter(w=>{
        const cls=(w.cls||'').toLowerCase();
        if(HIDDEN_WEAPON_CLASSES.has(cls))return false;
        const cat=(w.cat||'').toLowerCase();
        const matchesQuery = (w.name||'').toLowerCase().includes(q)||cls.includes(q)||cat.includes(q);
        const matchesTab = activeWeaponTab === 'Все' || w.cat === activeWeaponTab;
        return matchesQuery && matchesTab;
    });

    shown.forEach(w=>{
        const card=document.createElement('div');
        card.className='weapon-card'+(ctSelectedWeapons.includes(w.cls)?' selected':'');
        card.innerHTML='<div class="weapon-card-check">✓</div><div class="weapon-card-cat">'+w.cat+'</div><div class="weapon-card-name">'+w.name+'</div><div class="weapon-card-class">'+w.cls+'</div>';
        card.onclick=()=>{
            if(ctSelectedWeapons.includes(w.cls))ctSelectedWeapons=ctSelectedWeapons.filter(c=>c!==w.cls);
            else ctSelectedWeapons.push(w.cls);
            card.classList.toggle('selected',ctSelectedWeapons.includes(w.cls));
            card.querySelector('.weapon-card-check').style.display=ctSelectedWeapons.includes(w.cls)?'flex':'none';
            if(document.getElementById('ctTplWeaponCount'))document.getElementById('ctTplWeaponCount').textContent=ctSelectedWeapons.length;
            document.getElementById('tplWepCount').textContent=ctSelectedWeapons.length?'('+ctSelectedWeapons.length+' выбрано)':'';
        };
        g.appendChild(card);
    });

    document.getElementById('tplWepCount').textContent=ctSelectedWeapons.length?'('+ctSelectedWeapons.length+' выбрано)':'';
}
function showTemplateWeaponModal(){
    activeWeaponTab='Все';
    const tabContainer=document.getElementById('weaponTabs');
    if(tabContainer)tabContainer.innerHTML='';
    document.getElementById('tplWeaponSearch').value='';
    renderWeaponGrid('');
    document.getElementById('tplWeaponModal').classList.add('show');
    if(window.gmod&&window.gmod.SetModalOpen)window.gmod.SetModalOpen(true);
    document.getElementById('tplWeaponSearch').focus();
}
function closeTemplateWeaponModal(){document.getElementById('tplWeaponModal').classList.remove('show');if(window.gmod&&window.gmod.SetModalOpen)window.gmod.SetModalOpen(false)}
function confirmCustomTemplate(){
    const name=document.getElementById('ctTplName').value.trim();
    if(!name){showNotification('Введите название!','error');return}
    const getV=(id,def)=>parseInt(document.getElementById(id).value)||(parseInt(document.getElementById(id).placeholder)||def);
    const data={
        name:name,
        model:ctSelectedModel,
        weapons:ctSelectedWeapons,
        health:getV('ctTplHealth',100),
        armor:getV('ctTplArmor',0),
        walkSpeed:getV('ctTplWalkSpeed',200),
        runSpeed:getV('ctTplRunSpeed',400)
    };
    if(window.gmod&&window.gmod.SaveCustomTemplate)window.gmod.SaveCustomTemplate(JSON.stringify(data));
    showNotification('Шаблон сохранён','success');
    closeCustomTemplateModal();
    ctSelectedModel='';ctSelectedWeapons=[];
    document.getElementById('ctTplName').value='';
    document.getElementById('ctTplModelName').textContent='По умолчанию';
    document.getElementById('ctTplWeaponCount').textContent='0';
}
function closeSpawnTeamModal(){document.getElementById('spawnTeamModal').classList.remove('show');if(window.gmod&&window.gmod.SetModalOpen)window.gmod.SetModalOpen(false)}
function setSpawnForTeam(team){if(window.gmod&&window.gmod.BulkAction)window.gmod.BulkAction('set_spawn_team',team);closeSpawnTeamModal();showNotification('Спавн для команды установлен','success')}
function confirmColorModal(){const cb=colorModalCallback;closeColorModal();if(cb)cb(selectedColorRgb)}
document.getElementById('valueModalInput').addEventListener('keydown',e=>{if(e.key==='Enter')confirmValueModal();if(e.key==='Escape')closeValueModal()});
document.getElementById('valueModal').addEventListener('click',e=>{if(e.target.id==='valueModal')closeValueModal()});
const scaleSl=document.getElementById('scaleSlider');const scaleValEl=document.getElementById('scaleValue');if(scaleSl&&scaleValEl)scaleSl.addEventListener('input',()=>{scaleValEl.textContent=scaleSl.value});
document.getElementById('scaleModal').addEventListener('click',e=>{if(e.target.id==='scaleModal')closeScaleModal()});
const weaponTabsEl=document.getElementById('weaponTabs');if(weaponTabsEl)weaponTabsEl.addEventListener('wheel',e=>{if(Math.abs(e.deltaY)>0&&weaponTabsEl.scrollWidth>weaponTabsEl.clientWidth){e.preventDefault();weaponTabsEl.scrollLeft+=e.deltaY}});
document.getElementById('colorModal').addEventListener('click',e=>{if(e.target.id==='colorModal')closeColorModal()});
document.addEventListener('click',e=>{if(!e.target.closest('#colorSelectWrap')&&document.getElementById('colorSelectDropdown').classList.contains('show')){document.getElementById('colorSelectBtn').classList.remove('open');document.getElementById('colorSelectDropdown').classList.remove('show')}});
document.getElementById('spawnTeamModal').addEventListener('click',e=>{if(e.target.id==='spawnTeamModal')closeSpawnTeamModal()});
document.getElementById('modelModal').addEventListener('click',e=>{if(e.target.id==='modelModal')closeModelModal()});
document.getElementById('tplWeaponModal').addEventListener('click',e=>{if(e.target.id==='tplWeaponModal')closeTemplateWeaponModal()});
document.getElementById('tplWeaponSearch').addEventListener('input',e=>renderWeaponGrid(e.target.value));
document.addEventListener('keydown',e=>{if(e.key==='Escape'&&document.getElementById('colorModal').classList.contains('show'))closeColorModal();if(e.key==='Escape'&&document.getElementById('spawnTeamModal').classList.contains('show'))closeSpawnTeamModal();if(e.key==='Escape'&&document.getElementById('modelModal').classList.contains('show'))closeModelModal();if(e.key==='Escape'&&document.getElementById('scaleModal').classList.contains('show'))closeScaleModal()});
function updatePlayersList(p){if(Array.isArray(p)){players=p;playerStatuses={};players.forEach(pl=>{if(pl.id){playerStatuses[pl.id]={};if(pl.muted)playerStatuses[pl.id].muted=pl.muted;if(pl.gagged)playerStatuses[pl.id].gagged=pl.gagged;if(pl.godmode)playerStatuses[pl.id].godmode=pl.godmode}});renderPlayers(document.getElementById('playerSearch').value)}}
function updateWeaponList(list){if(Array.isArray(list)){WEAPON_LIST=list;const tabContainer=document.getElementById('weaponTabs');if(tabContainer)tabContainer.innerHTML='';renderWeaponGrid()}}
function updateEventState(open,active){var sb=document.getElementById('btnStartEvent'),eb=document.getElementById('btnEndEvent'),tg=document.getElementById('eventToggle');var act=active!==undefined?!!active:!!open;if(sb&&eb){sb.disabled=act;eb.disabled=!act}if(tg){tg.checked=!!open;tg.disabled=!act}}
function updateEventData(d){if(d){if(Array.isArray(d.players))updatePlayersList(d.players);else if(Array.isArray(d))updatePlayersList(d);if(typeof d.maxPlayers==='number'){const inp=document.getElementById('maxPlayersInput');if(inp)inp.value=d.maxPlayers}updateEventState(typeof d.eventOpen==='boolean'?d.eventOpen:true,typeof d.eventActive==='boolean'?d.eventActive:false);updatePlayerCounter()}}
function updatePlayerAvatar(steamid,avatar){if(!steamid||!avatar)return;const p=players.find(x=>(x.steamId||'').toUpperCase()===(steamid||'').toUpperCase());if(p){p.avatar=avatar;var e=document.getElementById('playerSearch');renderPlayers(e?e.value:'')}}
function updateTemplatesList(data){
    const t=Array.isArray(data)?data:(data&&data.list)?data.list:[];
    templates=t;
    const el=document.getElementById('templatesList');
    if(el){
        el.innerHTML='';
        t.forEach(tpl=>{
            const div=document.createElement('div');
            div.className='template-item';
            const escId = String(tpl.id||'').replace(/'/g,"\\'");
            div.innerHTML='<span class="template-name">'+String(tpl.name||'').replace(/</g,'&lt;')+'</span><span class="template-info">'+(tpl.weaponsCount||0)+' оруж.</span><div class="template-btns"><button class="template-btn" onclick="applyTemplate(\''+escId+'\')">Применить</button><button class="template-btn delete" onclick="deleteTemplate(\''+escId+'\')">×</button></div>';
            el.appendChild(div);
        });
    }
}
function saveTemplateFromMe(){showValueModal('Название шаблона:','',n=>{if(n&&n.trim()&&window.gmod&&window.gmod.SaveTemplate)window.gmod.SaveTemplate(n.trim());showNotification('Шаблон сохранён','success')})}
function applyTemplate(id){const s=document.querySelectorAll('.player-item.selected');if(s.length===0){showNotification('Выберите игроков!','error');return}const ids=Array.from(s).map(el=>parseInt(el.dataset.id));if(window.gmod&&window.gmod.ApplyTemplate)window.gmod.ApplyTemplate(id,JSON.stringify(ids));showNotification('Шаблон применён','success')}
function deleteTemplate(id){
    showValueModal('Удалить этот шаблон? Введите "да":', '', txt => {
        if(txt && txt.toLowerCase().trim() === 'да'){
            if(window.gmod && window.gmod.DeleteTemplate){
                window.gmod.DeleteTemplate(id);
                showNotification('Запрос на удаление отправлен','success');
            } else {
                showNotification('Ошибка: функция не найдена','error');
            }
        }
    });
}
function confirmEndEvent(){showValueModal('Завершить событие? Введите "да" для подтверждения:','',txt=>{if(txt&&txt.toLowerCase().trim()==='да'&&window.gmod&&window.gmod.EndEvent){window.gmod.EndEvent();if(window.gmod&&window.gmod.CloseMenu)window.gmod.CloseMenu()}})}
const listEl=document.getElementById('playersList'),dropdownEl=document.getElementById('selectDropdown'),selectAllBtn=document.getElementById('selectAllBtn'),contextMenu=document.getElementById('contextMenu');
function renderPlayers(t=''){listEl.innerHTML='';const f=players.filter(p=>p.name.toLowerCase().includes((t||'').toLowerCase())||(p.steamId||'').toLowerCase().includes((t||'').toLowerCase())||p.id.toString().includes(t||''));if(f.length===0){listEl.innerHTML='<div style="grid-column:1/-1;text-align:center;color:#555;margin-top:20px">Не найдено</div>';updateSelectAllText();return}f.forEach(p=>{const el=document.createElement('div');el.className='player-item';if(selectedPlayerIds.has(p.id))el.classList.add('selected');el.setAttribute('data-team',p.team);el.dataset.id=p.id;el.onclick=()=>toggleSelect(el);el.oncontextmenu=e=>{e.preventDefault();showContextMenu(e,p)};const avHtml=p.avatar?'<img src="'+String(p.avatar).replace(/"/g,'&quot;')+'" alt="">':'<span>'+String(p.name||'').charAt(0)+'</span>';const nameEsc=String(p.name||'').replace(/</g,'&lt;').replace(/>/g,'&gt;');const status=playerStatuses[p.id]||{};let sI='<div class="player-status-icons">';if(status.gagged)sI+='<svg class="status-icon gagged" viewBox="0 0 24 24" fill="#f59e0b" title="Гаг (голос)"><path d="M12 14c1.66 0 3-1.34 3-3V5c0-1.66-1.34-3-3-3S9 3.34 9 5v6c0 1.66 1.34 3 3 3z"/><path d="M17 11c0 2.76-2.24 5-5 5s-5-2.24-5-5H5c0 3.53 2.61 6.43 6 6.92V21h2v-3.08c3.39-.49 6-3.39 6-6.92h-2z"/><line x1="2" y1="2" x2="22" y2="22" stroke="#fff" stroke-width="2.5"/></svg>';if(status.muted)sI+='<svg class="status-icon muted" viewBox="0 0 24 24" fill="#ef4444" title="Мут (чат)"><path d="M20 2H4c-1.1 0-2 .9-2 2v18l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2z"/><line x1="2" y1="2" x2="22" y2="22" stroke="#fff" stroke-width="2.5"/></svg>';if(status.godmode)sI+='<svg class="status-icon godmode" viewBox="0 0 24 24" fill="#8b5cf6" title="Godmode"><path d="M12 1L3 5v6c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V5l-9-4z"/></svg>';if(status.noCollision)sI+='<svg class="status-icon no-collision" viewBox="0 0 24 24" fill="#aaa" title="Коллизия"><path d="M12 2L4.5 20.29l.71.71L12 18l6.79 3 .71-.71z"/></svg>';sI+='</div>';el.innerHTML='<div class="check-icon"><svg viewBox="0 0 24 24" fill="currentColor"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg></div><div class="player-avatar">'+avHtml+'</div><div style="width:100%;text-align:center"><div class="player-name-row"><div class="player-name">'+nameEsc+'</div>'+sI+'</div><div class="player-id">'+(p.steamId||('ID: '+p.id))+'</div></div>';listEl.appendChild(el)});updateSelectAllText()}function toggleSelect(el){const id=parseInt(el.dataset.id);el.classList.toggle('selected');if(el.classList.contains('selected'))selectedPlayerIds.add(id);else selectedPlayerIds.delete(id);updateSelectAllText()}
function assignTeam(c){const s=document.querySelectorAll('.player-item.selected');if(s.length===0){showNotification('Выберите игроков!','error');return}const ids=[];s.forEach(el=>{ids.push(parseInt(el.dataset.id));el.setAttribute('data-team',c);const p=players.find(x=>x.id===parseInt(el.dataset.id));if(p)p.team=c;el.style.transform='scale(1.05)';setTimeout(()=>el.style.transform='',200)});if(window.gmod&&window.gmod.AssignTeam)window.gmod.AssignTeam(c,JSON.stringify(ids))}
function toggleDropdown(){dropdownEl.classList.toggle('show')}
window.onclick=e=>{if(!e.target.closest('.dropdown'))dropdownEl.classList.remove('show')}
function selectByFilter(c){selectedPlayerIds.clear();document.querySelectorAll('.player-item').forEach(el=>{const t=el.getAttribute('data-team');let sel=false;if(c==='all')sel=true;else if(c!=='none')sel=t===c;if(sel){el.classList.add('selected');selectedPlayerIds.add(parseInt(el.dataset.id))}else el.classList.remove('selected')});dropdownEl.classList.remove('show');updateSelectAllText();updatePlayerCounter()}
function updateSelectAllText(){const a=document.querySelectorAll('.player-item');if(a.length===0){if(selectAllBtn)selectAllBtn.textContent='Выбрать всех';updatePlayerCounter();return}const all=a.length&&Array.from(a).every(i=>i.classList.contains('selected'));if(selectAllBtn)selectAllBtn.textContent=all?'Снять выделение':'Выбрать всех';updatePlayerCounter()}
if(selectAllBtn)selectAllBtn.addEventListener('click',()=>{const a=document.querySelectorAll('.player-item');if(a.length===0)return;const all=Array.from(a).every(i=>i.classList.contains('selected'));a.forEach(i=>{const id=parseInt(i.dataset.id);if(all){i.classList.remove('selected');selectedPlayerIds.delete(id)}else{i.classList.add('selected');selectedPlayerIds.add(id)}});updateSelectAllText()})
function clearSelection(){selectedPlayerIds.clear();document.querySelectorAll('.player-item').forEach(i=>i.classList.remove('selected'));updateSelectAllText()}
function updatePlayerStatus(playerId,action,enabled){if(!playerStatuses[playerId])playerStatuses[playerId]={};if(action==='mute')playerStatuses[playerId].muted=enabled;else if(action==='gag')playerStatuses[playerId].gagged=enabled;else if(action==='godmode')playerStatuses[playerId].godmode=enabled;else if(action==='toggle_collision')playerStatuses[playerId].noCollision=enabled;renderPlayers(document.getElementById('playerSearch').value)}
function triggerAction(el){const act=el&&el.getAttribute('data-action');if(!act)return;const s=document.querySelectorAll('.player-item.selected');const ids=Array.from(s).map(e=>parseInt(e.dataset.id));function doExec(v,w){if(window.gmod&&window.gmod.ExecuteAction)window.gmod.ExecuteAction(act,JSON.stringify(ids),v||0,w||'');showNotification('Выполнено','success');if(act==='mute'||act==='gag'||act==='godmode'||act==='toggle_collision')ids.forEach(id=>{const cur=playerStatuses[id]||{};if(act==='mute')updatePlayerStatus(id,'mute',!cur.muted);else if(act==='gag')updatePlayerStatus(id,'gag',!cur.gagged);else if(act==='godmode')updatePlayerStatus(id,'godmode',!cur.godmode);else if(act==='toggle_collision')updatePlayerStatus(id,'toggle_collision',!cur.noCollision)})}if(s.length===0){showNotification('Выберите игроков!','error');return}if(act==='walk_speed'||act==='run_speed')showValueModal('Скорость (юниты):',act==='walk_speed'?'200':'400',val=>doExec(parseFloat(val)||0,''));else if(act==='jump_height')showValueModal('Высота прыжка:','200',val=>doExec(parseFloat(val)||0,''));else if(act==='give_health')showValueModal('Здоровье:','100',val=>doExec(parseFloat(val)||100,''));else if(act==='give_armor')showValueModal('Броня:','100',val=>doExec(parseFloat(val)||100,''));else if(act==='give_hunger')showValueModal('Голод (0-100):','100',val=>doExec(parseFloat(val)||100,''));else if(act==='model_scale')showModelScaleModal(val=>doExec(parseFloat(val)||1,''));else if(act==='model_color')showColorModal(val=>doExec(0,val||'255,255,255'));else doExec(0,'')}
function showGiveWeaponModal(){
    const s=document.querySelectorAll('.player-item.selected');
    if(s.length===0){showNotification('Выберите игроков!','error');return}
    const ids=Array.from(s).map(e=>parseInt(e.dataset.id));
    const prevSelected=[...ctSelectedWeapons];
    ctSelectedWeapons=[];
    document.getElementById('tplWeaponSearch').value='';
    renderWeaponGrid('');
    const doneBtn=document.querySelector('#tplWeaponModal .btn-primary');
    if(doneBtn){
        doneBtn.textContent='Выдать';
        doneBtn.onclick=()=>{
            if(ctSelectedWeapons.length===0){showNotification('Выберите хотя бы одно оружие!','error');return}
            ctSelectedWeapons.forEach(w=>{if(window.gmod&&window.gmod.ExecuteAction)window.gmod.ExecuteAction('give_weapon',JSON.stringify(ids),0,w)});
            showNotification('Оружие выдано','success');
            ctSelectedWeapons=[...prevSelected];
            doneBtn.textContent='Готово';
            doneBtn.onclick=()=>closeTemplateWeaponModal();
            closeTemplateWeaponModal();
        };
    }
    document.getElementById('tplWeaponModal').classList.add('show');
    if(window.gmod&&window.gmod.SetModalOpen)window.gmod.SetModalOpen(true);
    document.getElementById('tplWeaponSearch').focus();
}
function doStripWeapons(){
    const s=document.querySelectorAll('.player-item.selected');
    if(s.length===0){showNotification('Выберите игроков!','error');return}
    const ids=Array.from(s).map(e=>parseInt(e.dataset.id));
    if(window.gmod&&window.gmod.ExecuteAction)window.gmod.ExecuteAction('strip_weapon',JSON.stringify(ids),0,'');
    showNotification('Оружие отобрано','success');
}
function bulkAction(act){if(window.gmod&&window.gmod.BulkAction)window.gmod.BulkAction(act,'');showNotification('Выполнено','success')}
function showContextMenu(e,p){selectedContextPlayer=p;contextMenu.style.left=e.pageX+'px';contextMenu.style.top=e.pageY+'px';contextMenu.classList.add('show');setTimeout(()=>{const r=contextMenu.getBoundingClientRect();if(r.right>window.innerWidth)contextMenu.style.left=(e.pageX-r.width)+'px';if(r.bottom>window.innerHeight)contextMenu.style.top=(e.pageY-r.height)+'px'},0)}
function hideContextMenu(){contextMenu.classList.remove('show');selectedContextPlayer=null}
document.addEventListener('click',e=>{if(!contextMenu.contains(e.target))hideContextMenu()})
function copySteamId(){if(!selectedContextPlayer)return;const sid=selectedContextPlayer.steamId||'STEAM_0:0:'+selectedContextPlayer.id;const t=selectedContextPlayer.name+' — '+sid;(navigator.clipboard&&navigator.clipboard.writeText?navigator.clipboard.writeText(t):Promise.reject()).then(()=>showNotification('Скопировано')).catch(()=>{const ta=document.createElement('textarea');ta.value=t;ta.style.opacity='0';document.body.appendChild(ta);ta.select();try{document.execCommand('copy');showNotification('Скопировано')}catch(e){showNotification('Ошибка','error')}document.body.removeChild(ta)});hideContextMenu()}
function kickPlayer(){if(!selectedContextPlayer)return;showValueModal('Кикнуть "'+selectedContextPlayer.name+'"? Введите "да":','',txt=>{if(txt&&txt.toLowerCase().trim()==='да'){if(window.gmod&&window.gmod.KickFromEvent)window.gmod.KickFromEvent(selectedContextPlayer.id);players=players.filter(p=>p.id!==selectedContextPlayer.id);renderPlayers(document.getElementById('playerSearch').value);showNotification('Игрок кикнут','success')}hideContextMenu()})}
function showNotification(m,t){const n=document.createElement('div');n.style.cssText='position:fixed;top:20px;right:20px;z-index:10000;background:'+(t==='error'?'var(--danger)':t==='success'?'#10b981':'var(--accent)')+';color:#fff;padding:12px 20px;border-radius:8px;box-shadow:0 10px 30px rgba(0,0,0,0.5);font-size:13px';n.textContent=m;document.body.appendChild(n);setTimeout(()=>{n.style.opacity='0';n.style.transition='opacity 0.3s';setTimeout(()=>n.remove(),300)},3000)}
document.getElementById('playerSearch').addEventListener('input',e=>renderPlayers(e.target.value));
window.addEventListener('load',function(){if(window.gmod&&window.gmod.RequestPlayers)window.gmod.RequestPlayers();else renderPlayers();if(window.gmod&&window.gmod.RequestTemplates)window.gmod.RequestTemplates();if(window.gmod&&window.gmod.RequestWeaponList)window.gmod.RequestWeaponList()});
if(document.readyState==='complete')renderPlayers();
(function(){
    const panel=document.querySelector('.panel'),
          header=document.querySelector('.panel-header'),
          resizeHandle=document.getElementById('resizeHandle'),
          sidebarResize=document.getElementById('sidebarResize'),
          actionsColumn=document.getElementById('actionsColumn');
    if(!panel||!header)return;
    let dX=0,dY=0,isDrag=false,isResize=false,isSidebarResize=false,startW=0,startH=0,startX=0,startY=0,startSidebarW=0;
    const minW=800,minH=500,minSidebarW=220,maxSidebarW=520;
    const clamp=(v,min,max)=>Math.max(min,Math.min(v,max));
    const saveWindowState=()=>{
        const r=panel.getBoundingClientRect();
        const state={
            width:panel.offsetWidth,
            height:panel.offsetHeight,
            sidebarWidth:actionsColumn?actionsColumn.offsetWidth:null,
            left:r.left,
            top:r.top
        };
        try{localStorage.setItem('EventMenuSize',JSON.stringify(state))}catch(e){}
    };
    const restoreWindowState=()=>{
        try{
            const saved=localStorage.getItem('EventMenuSize');
            if(!saved)return;
            const state=JSON.parse(saved);
            let w=Math.max(minW,Math.min(state.width,window.innerWidth-100));
            let h=Math.max(minH,Math.min(state.height,window.innerHeight-100));
            panel.style.width=w+'px';
            panel.style.height=h+'px';
            if(actionsColumn&&state.sidebarWidth){
                const maxAllowed=Math.min(maxSidebarW,w-400);
                const sw=Math.max(minSidebarW,Math.min(state.sidebarWidth,maxAllowed));
                actionsColumn.style.width=sw+'px';
            }
            if(typeof state.left==='number' && typeof state.top==='number'){
                const maxLeft=Math.max(0,window.innerWidth-w);
                const maxTop=Math.max(0,window.innerHeight-h);
                const left=clamp(state.left,0,maxLeft);
                const top=clamp(state.top,0,maxTop);
                panel.style.left=left+'px';
                panel.style.top=top+'px';
                panel.style.transform='none';
            }
        }catch(e){}
    };
    restoreWindowState();
    header.addEventListener('mousedown',e=>{if(e.target.closest('.close-btn')||e.target.closest('.limit-control')||e.target.closest('input'))return;isDrag=true;const r=panel.getBoundingClientRect();dX=e.clientX-r.left;dY=e.clientY-r.top;panel.style.left=r.left+'px';panel.style.top=r.top+'px';panel.style.transform='none'});
    if(resizeHandle)resizeHandle.addEventListener('mousedown',e=>{e.preventDefault();e.stopPropagation();isResize=true;startW=panel.offsetWidth;startH=panel.offsetHeight;startX=e.clientX;startY=e.clientY;const r=panel.getBoundingClientRect();panel.style.left=r.left+'px';panel.style.top=r.top+'px';panel.style.transform='none'});
    if(sidebarResize&&actionsColumn)sidebarResize.addEventListener('mousedown',e=>{e.preventDefault();e.stopPropagation();isSidebarResize=true;startSidebarW=actionsColumn.offsetWidth;startX=e.clientX;const r=panel.getBoundingClientRect();panel.style.left=r.left+'px';panel.style.top=r.top+'px';panel.style.transform='none'});
    document.addEventListener('mousemove',e=>{if(isDrag){let x=e.clientX-dX,y=e.clientY-dY;x=Math.max(0,Math.min(x,window.innerWidth-panel.offsetWidth));y=Math.max(0,Math.min(y,window.innerHeight-panel.offsetHeight));panel.style.left=x+'px';panel.style.top=y+'px'}else if(isResize){let w=Math.max(minW,startW+e.clientX-startX),h=Math.max(minH,startH+e.clientY-startY);panel.style.width=w+'px';panel.style.height=h+'px'}else if(isSidebarResize&&actionsColumn){const panelWidth=panel.offsetWidth||minW;let sw=startSidebarW+e.clientX-startX;const maxAllowed=Math.min(maxSidebarW,panelWidth-400);sw=Math.max(minSidebarW,Math.min(sw,maxAllowed));actionsColumn.style.width=sw+'px';}});
    document.addEventListener('mouseup',()=>{if(isDrag||isResize||isSidebarResize)saveWindowState();isDrag=false;isResize=false;isSidebarResize=false});
})();
    </script>
</body>
</html>]=]
end

-- Функция открытия меню (вынесена отдельно для переиспользования)
local function OpenEventMenu()
    -- Если меню уже открыто, закрываем его
    if IsValid(EventFrame) then
        EventFrame:Remove()
        return
    end
    
    EventMenuModalOpen = false

    -- Создаем основное окно
    EventFrame = vgui.Create("DFrame")
    EventFrame:SetSize(ScrW(), ScrH())
    EventFrame:Center()
    EventFrame:SetTitle("")
    EventFrame:ShowCloseButton(false)
    EventFrame:SetDraggable(false)
    EventFrame:MakePopup()
    
    -- Закрытие по ESC (если модальное окно закрыто)
    EventFrame.m_bEscPressed = false
    EventFrame.Think = function(s)
        if not IsValid(s) then return end
        if EventMenuModalOpen then return end
        if input.IsKeyDown(KEY_ESCAPE) then
            if not s.m_bEscPressed then
                s.m_bEscPressed = true
                s:Remove()
            end
        else
            s.m_bEscPressed = false
        end
    end
    
    -- Затемнение фона
    EventFrame.Paint = function(s, w, h)
        surface.SetDrawColor(0, 0, 0, 200)
        surface.DrawRect(0, 0, w, h)
    end

    -- Создаем HTML панель
    htmlPanel = vgui.Create("DHTML", EventFrame)
    htmlPanel:Dock(FILL)
    if htmlPanel.AddAllowedURL then
        htmlPanel:AddAllowedURL("https://avatars.steamstatic.com")
        htmlPanel:AddAllowedURL("https://avatars.akamai.steamstatic.com")
    end
    
    -- Загружаем HTML (встроен в Lua — работает без файла)
    local htmlContent = GetEventMenuHTML()
    htmlPanel:SetHTML(htmlContent)
    
    -- ============================================
    -- СВЯЗЬ JS -> LUA
    -- ============================================
    
    -- Закрытие меню
    htmlPanel:AddFunction("gmod", "CloseMenu", function()
        if IsValid(EventFrame) then
            EventFrame:Remove()
        end
    end)
    
    htmlPanel:AddFunction("gmod", "RequestWeaponList", function()
        net.Start("EventMenu_RequestWeaponList")
        net.SendToServer()
    end)

    htmlPanel:AddFunction("gmod", "SetModalOpen", function(isOpen)
        EventMenuModalOpen = (isOpen == true or isOpen == "true")
    end)
    
    -- Запрос списка игроков
    htmlPanel:AddFunction("gmod", "RequestPlayers", function()
        net.Start("EventMenu_RequestPlayers")
        net.SendToServer()
    end)
    
    
    -- Присвоение команды
    htmlPanel:AddFunction("gmod", "AssignTeam", function(team, playerIdsJson)
        local playerIds = util.JSONToTable(playerIdsJson)
        if not playerIds then return end
        
        net.Start("EventMenu_AssignTeam")
        net.WriteString(team)
        net.WriteTable(playerIds)
        net.SendToServer()
    end)
    
    -- Массовые действия
    htmlPanel:AddFunction("gmod", "BulkAction", function(action, team)
        net.Start("EventMenu_BulkAction")
        net.WriteString(action or "")
        net.WriteString(team or "")
        net.SendToServer()
    end)
    
    -- Создать прессет оружия
    
    -- Выполнение действия
    htmlPanel:AddFunction("gmod", "ExecuteAction", function(action, playerIdsJson, value, weaponClass)
        local playerIds = util.JSONToTable(playerIdsJson)
        if not playerIds then return end
        
        net.Start("EventMenu_ExecuteAction")
        net.WriteString(action)
        net.WriteTable(playerIds)
        net.WriteFloat(value or 0)
        
        if (action == "give_weapon" or action == "model_color" or action == "set_model" or action == "apply_weapon_preset") and weaponClass and weaponClass ~= "" then
            net.WriteString(weaponClass)
        end
        
        net.SendToServer()
    end)
    
    -- Установка лимита игроков
    htmlPanel:AddFunction("gmod", "SetMaxPlayers", function(maxPlayers)
        net.Start("EventMenu_SetMaxPlayers")
        net.WriteUInt(math.Clamp(maxPlayers, 1, 65535), 16)
        net.SendToServer()
    end)
    
    -- Переключение статуса события
    htmlPanel:AddFunction("gmod", "ToggleEvent", function(isOpen)
        net.Start("EventMenu_ToggleEvent")
        net.WriteBool(isOpen)
        net.SendToServer()
    end)
    
    -- Начать событие
    htmlPanel:AddFunction("gmod", "StartEvent", function(tplJson)
        net.Start("EventMenu_StartEvent")
        net.WriteString(tostring(tplJson or ""))
        net.SendToServer()
        htmlPanel:RunJavascript("var t=document.getElementById('eventToggle');if(t)t.checked=true;if(window.updateEventState)updateEventState(true,true);")
    end)
    
    -- Сохранить кастомный шаблон
    htmlPanel:AddFunction("gmod", "SaveCustomTemplate", function(json)
        local data = util.JSONToTable(json)
        if data then
            net.Start("EventMenu_SaveCustomTemplate")
            net.WriteTable(data)
            net.SendToServer()
        end
    end)
    
    -- Получить оружие текущего игрока
    htmlPanel:AddFunction("gmod", "GetMyWeapons", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return "[]" end
        local weps = {}
        for _, w in ipairs(ply:GetWeapons()) do
            if IsValid(w) and w:IsWeapon() then
                table.insert(weps, { name = (w:GetPrintName() or w:GetClass()), class = w:GetClass() })
            end
        end
        return util.TableToJSON(weps)
    end)
    
    -- Завершение события (подтверждение в JS перед вызовом)
    htmlPanel:AddFunction("gmod", "EndEvent", function()
        net.Start("EventMenu_EndEvent")
        net.SendToServer()
        
        if IsValid(EventFrame) then
            EventFrame:Remove()
        end
    end)
    
    -- Шаблоны
    htmlPanel:AddFunction("gmod", "SaveTemplate", function(name)
        net.Start("EventMenu_SaveTemplate")
        net.WriteString(name or "")
        net.SendToServer()
    end)
    
    htmlPanel:AddFunction("gmod", "ApplyTemplate", function(templateId, playerIdsJson)
        local playerIds = util.JSONToTable(playerIdsJson)
        if not playerIds then return end
        
        net.Start("EventMenu_ApplyTemplate")
        net.WriteString(templateId or "")
        net.WriteTable(playerIds)
        net.SendToServer()
    end)
    
    htmlPanel:AddFunction("gmod", "RequestTemplates", function()
        net.Start("EventMenu_RequestTemplates")
        net.SendToServer()
    end)
    
    htmlPanel:AddFunction("gmod", "DeleteTemplate", function(templateId)
        net.Start("EventMenu_DeleteTemplate")
        net.WriteString(templateId or "")
        net.SendToServer()
    end)
    
    htmlPanel:AddFunction("gmod", "SetStartTemplate", function(templateId)
        net.Start("EventMenu_SetStartTemplate")
        net.WriteString(templateId or "")
        net.SendToServer()
    end)
    
    -- Кик игрока с события
    htmlPanel:AddFunction("gmod", "KickFromEvent", function(playerId)
        net.Start("EventMenu_ExecuteAction")
        net.WriteString("kick_from_event")
        net.WriteTable({playerId})
        net.WriteFloat(0)
        net.SendToServer()
    end)
    
    -- Получение текущего действия
    htmlPanel:AddFunction("gmod", "GetSelectedAction", function()
        -- Возвращаем текущее выбранное действие (если нужно)
        return ""
    end)
    
    -- Запрос списка игроков, шаблонов и прессетов при открытии меню
    timer.Simple(0.5, function()
        if IsValid(htmlPanel) then
            htmlPanel:RunJavascript("if(window.gmod&&window.gmod.RequestPlayers)gmod.RequestPlayers();if(window.gmod&&window.gmod.RequestTemplates)gmod.RequestTemplates();")
        end
    end)
end

-- Сетевые сообщения (регистрируются один раз)
net.Receive("EventMenu_SendTemplates", function()
    local templatesData = net.ReadTable()
    if IsValid(htmlPanel) then
        local jsonData = util.TableToJSON(templatesData)
        htmlPanel:RunJavascript("if(window.updateTemplatesList) updateTemplatesList(" .. jsonData .. ");")
    end
end)


net.Receive("EventMenu_UpdatePlayers", function()
    local data = net.ReadTable()
    if IsValid(htmlPanel) then
        local jsonData = util.TableToJSON(data)
        htmlPanel:RunJavascript("if(window.updateEventData) updateEventData(" .. jsonData .. ");")
    end
end)

net.Receive("EventMenu_AvatarUpdate", function()
    local steamid = net.ReadString()
    local avatarData = net.ReadString()
    if IsValid(htmlPanel) and steamid and avatarData and avatarData ~= "" then
        local data = util.TableToJSON({steamid = steamid, avatar = avatarData})
        htmlPanel:RunJavascript("if(window.updatePlayerAvatar){var d=" .. data .. ";updatePlayerAvatar(d.steamid,d.avatar)}")
    end
end)

net.Receive("EventMenu_SendWeaponList", function()
    local list = net.ReadTable()
    if IsValid(htmlPanel) and list then
        local data = util.TableToJSON(list)
        htmlPanel:RunJavascript("if(window.updateWeaponList){updateWeaponList(" .. data .. ")}")
    end
end)

-- Регистрация сетевого сообщения для проверки прав
if CLIENT then
    net.Receive("EventMenu_CheckAccess", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        
        local hasAccess = net.ReadBool()
        
        if not hasAccess then
            chat.AddText(Color(255, 0, 0), "[EventMenu] ", Color(255, 255, 255), "У вас нет прав доступа!")
            chat.AddText(Color(255, 200, 0), "[EventMenu] ", Color(255, 255, 255), "Ваш Steam ID: " .. ply:SteamID())
            chat.AddText(Color(255, 200, 0), "[EventMenu] ", Color(255, 255, 255), "UserGroup: " .. (ply:GetUserGroup() or "unknown"))
            return
        end
        
        -- Если доступ есть, открываем меню
        OpenEventMenu()
    end)
end

-- Открыть меню события
concommand.Add("event_menu", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    
    -- Быстрая проверка на клиенте (для мгновенной обратной связи)
    local quickCheck = false
    
    -- Проверка через стандартную систему супер админов
    if ply.IsSuperAdmin and ply:IsSuperAdmin() then
        quickCheck = true
    end
    
    -- Проверка через стандартную систему админов
    if not quickCheck and ply:IsAdmin() then
        quickCheck = true
    end
    
    -- Проверка через конфигурацию (Steam ID)
    if not quickCheck and EventMenuConfig and EventMenuConfig.HasAccessClient then
        quickCheck = EventMenuConfig.HasAccessClient()
    end
    
    -- Если быстрая проверка не прошла, запрашиваем у сервера
    if not quickCheck then
        -- Запрос проверки прав у сервера
        net.Start("EventMenu_CheckAccess")
        net.SendToServer()
        return
    end
    
    -- Если быстрая проверка прошла, открываем меню сразу
    OpenEventMenu()
end)

print("[EventMenu] Клиентская часть загружена! Используйте команду: event_menu")
