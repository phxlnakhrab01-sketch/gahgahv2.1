--[[
B3 HUB - Categorized Developer Dashboard
Roblox Studio only: LocalScript in StarterPlayer > StarterPlayerScripts.

Included categories (50 practical UI/diagnostic controls):
01 Dashboard: player count, FPS estimate, session timer, client status
02 Player Inspector: clickable player rows, display name, username, UserId,
   account age in days, team, health, character state
03 Inventory Inspector: backpack contents for your own game's replicated items;
   currency/inventory values must be deliberately exposed by your server
04 Visuals: local HUD, team-color Highlight for visible/authorized characters,
   configurable highlight fill/outline, name tags, health bars
05 Screen Lines: camera-projected lines to authorized/visible characters, safely
   hidden when off-screen or behind the camera
06 Test Target: press Q to select/clear a target in YOUR OWN test experience;
   it does not aim, move the camera, or manipulate another game's players
07 Interaction: configurable cooldown value for your own E/ProximityPrompt logic
08 Performance: reversible local lighting/effect toggles, FPS monitor
09 Interface: draggable panel, scale, RightShift toggle, End unload
10 Diagnostics: status log, live refresh, cleanup

No exploit, account-age enumeration beyond public UserId/account age for visible
players, aimbot, wallhack, remote-spam, or private data scraping is implemented.
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
if not player then return end

local playerGui = player:WaitForChild("PlayerGui")
local old = playerGui:FindFirstChild("B3HubComplete")
if old then old:Destroy() end

local connections = {}
local function bind(signal, fn)
    local c = signal:Connect(fn)
    table.insert(connections, c)
    return c
end
local theme = {
    bg=Color3.fromRGB(15,16,22), side=Color3.fromRGB(20,22,30),
    card=Color3.fromRGB(28,30,40), card2=Color3.fromRGB(37,40,52),
    line=Color3.fromRGB(56,60,77), text=Color3.fromRGB(241,243,249),
    muted=Color3.fromRGB(158,164,181), blue=Color3.fromRGB(91,143,255),
    green=Color3.fromRGB(83,216,153), red=Color3.fromRGB(238,91,108),
}
local function make(class, props, parent)
    local o=Instance.new(class)
    for k,v in pairs(props or {}) do o[k]=v end
    o.Parent=parent
    return o
end
local function round(o,r) make("UICorner",{CornerRadius=UDim.new(0,r or 8)},o) end
local function stroke(o,c) make("UIStroke",{Color=c or theme.line,Thickness=1},o) end
local function label(parent,txt,pos,size,sz,color,font,align)
    return make("TextLabel",{BackgroundTransparency=1,Text=txt,Position=pos,Size=size,
        Font=font or Enum.Font.Gotham,TextSize=sz or 12,TextColor3=color or theme.text,
        TextXAlignment=align or Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,
        TextWrapped=true},parent)
end
local function button(parent,txt,pos,size,color)
    local b=make("TextButton",{Text=txt,Position=pos,Size=size,BackgroundColor3=color or theme.card2,
        BorderSizePixel=0,TextColor3=theme.text,Font=Enum.Font.GothamSemibold,TextSize=11},parent)
    round(b,7); return b
end
local function newCard(parent,title,height)
    local f=make("Frame",{Size=UDim2.new(1,0,0,height),BackgroundColor3=theme.card,BorderSizePixel=0},parent)
    round(f,9); stroke(f)
    label(f,title,UDim2.fromOffset(12,6),UDim2.new(1,-24,0,22),12,theme.text,Enum.Font.GothamSemibold)
    return f
end
local function newPage(parent,name)
    local p=make("ScrollingFrame",{Name=name,Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
        BorderSizePixel=0,ScrollBarThickness=4,ScrollBarImageColor3=theme.blue,
        AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),Visible=false},parent)
    make("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},p)
    make("UIPadding",{PaddingRight=UDim.new(0,4),PaddingBottom=UDim.new(0,6)},p)
    return p
end

local gui=make("ScreenGui",{Name="B3HubComplete",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},playerGui)
local main=make("Frame",{Name="Main",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),
    Size=UDim2.fromOffset(900,590),BackgroundColor3=theme.bg,BorderSizePixel=0},gui)
round(main,14); stroke(main)
local scale=make("UIScale",{Scale=1},main)
local function fit()
    local cam=workspace.CurrentCamera
    if cam then local v=cam.ViewportSize; scale.Scale=math.clamp(math.min((v.X-16)/900,(v.Y-16)/590),.5,1) end
end
local function cameraWatch()
    local cam=workspace.CurrentCamera
    if cam then bind(cam:GetPropertyChangedSignal("ViewportSize"),fit); fit() end
end
cameraWatch()
bind(workspace:GetPropertyChangedSignal("CurrentCamera"),cameraWatch)

local header=make("Frame",{Size=UDim2.new(1,0,0,62),BackgroundColor3=theme.side,BorderSizePixel=0},main)
round(header,14)
make("Frame",{Position=UDim2.new(0,0,1,-12),Size=UDim2.new(1,0,12,0),BackgroundColor3=theme.side,BorderSizePixel=0},header)
label(header,"B3 HUB  /  DEVELOPER SUITE",UDim2.fromOffset(20,7),UDim2.new(1,-80,0,26),18,theme.text,Enum.Font.GothamBold)
label(header,"Categorized tools • Studio developer build",UDim2.fromOffset(21,34),UDim2.new(1,-80,0,16),10,theme.muted)
local close=button(header,"×",UDim2.new(1,-45,0,15),UDim2.fromOffset(29,29),theme.bg)
close.TextSize=19

local sidebar=make("Frame",{Position=UDim2.fromOffset(12,74),Size=UDim2.new(0,178,1,-86),
    BackgroundColor3=theme.side,BorderSizePixel=0},main)
round(sidebar,10); stroke(sidebar)
label(sidebar,"หมวดหมู่เครื่องมือ",UDim2.fromOffset(12,7),UDim2.new(1,-24,0,20),10,theme.muted)
local content=make("Frame",{Position=UDim2.fromOffset(200,74),Size=UDim2.new(1,-212,1,-86),BackgroundTransparency=1},main)

local categories={
    {"หน้าหลัก","⌂"},{"ผู้เล่น","♙"},{"กระเป๋าและเงิน","▣"},{"ESP / Visuals","◉"},
    {"เส้นบนหน้าจอ","╱"},{"ล็อกเป้าทดสอบ","Q"},{"การโต้ตอบ","E"},
    {"ประสิทธิภาพ","ϟ"},{"ตั้งค่า","⚙"},{"Diagnostics","≡"},
}
local pages,nav={},{}
local active="หน้าหลัก"
for i,item in ipairs(categories) do
    local p=newPage(content,item[1]); pages[item[1]]=p
    local b=button(sidebar,item[2].."   "..item[1],UDim2.fromOffset(7,33+(i-1)*42),UDim2.new(1,-14,0,34),
        item[1]==active and theme.blue or theme.side)
    b.TextXAlignment=Enum.TextXAlignment.Left; nav[item[1]]=b
end
local function selectPage(name)
    active=name
    for n,p in pairs(pages) do p.Visible=n==name end
    for n,b in pairs(nav) do b.BackgroundColor3=n==name and theme.blue or theme.side end
end
for n,b in pairs(nav) do bind(b.MouseButton1Click,function() selectPage(n) end) end
selectPage(active)
label(sidebar,"B3 • DEV BUILD",UDim2.new(0,12,1,-25),UDim2.new(1,-24,0,15),9,theme.muted)

local logLines={}
local function log(msg)
    table.insert(logLines,1,os.date("%H:%M:%S").."  "..msg)
    while #logLines>30 do table.remove(logLines) end
end
local statusText
local function addToggle(parent,title,y,initial,callback)
    label(parent,title,UDim2.fromOffset(12,y),UDim2.new(1,-110,0,28),11,theme.text)
    local state=initial
    local b=button(parent,state and "ON" or "OFF",UDim2.new(1,-80,y,0),UDim2.fromOffset(66,26),state and theme.blue or theme.card2)
    bind(b.MouseButton1Click,function()
        state=not state; b.Text=state and "ON" or "OFF"; b.BackgroundColor3=state and theme.blue or theme.card2
        if callback then callback(state) end
    end)
    return function() return state end
end
local function addSlider(parent,title,y,minV,maxV,initial,suffix,callback)
    label(parent,title,UDim2.fromOffset(12,y),UDim2.new(1,-95,0,18),11,theme.text)
    local vl=label(parent,tostring(initial)..(suffix or ""),UDim2.new(1,-82,y,0),UDim2.fromOffset(70,18),11,theme.blue,Enum.Font.GothamBold,Enum.TextXAlignment.Right)
    local bar=make("Frame",{Position=UDim2.fromOffset(12,y+23),Size=UDim2.new(1,-24,0,6),BackgroundColor3=theme.card2,BorderSizePixel=0},parent)
    round(bar,3)
    local ratio=(initial-minV)/(maxV-minV)
    local fill=make("Frame",{Size=UDim2.new(ratio,0,1,0),BackgroundColor3=theme.blue,BorderSizePixel=0},bar); round(fill,3)
    local knob=button(bar,"",UDim2.new(ratio,0,.5,0),UDim2.fromOffset(13,13),theme.text)
    knob.AnchorPoint=Vector2.new(.5,.5); round(knob,8)
    local val=initial; local dragging=false
    local function setX(x)
        local r=math.clamp((x-bar.AbsolutePosition.X)/math.max(bar.AbsoluteSize.X,1),0,1)
        val=math.floor((minV+(maxV-minV)*r)*100+.5)/100
        fill.Size=UDim2.new(r,0,1,0); knob.Position=UDim2.new(r,0,.5,0)
        vl.Text=tostring(val)..(suffix or "")
        if callback then callback(val) end
    end
    bind(knob.InputBegan,function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; setX(i.Position.X) end end)
    bind(bar.InputBegan,function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; setX(i.Position.X) end end)
    bind(UIS.InputChanged,function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then setX(i.Position.X) end end)
    bind(UIS.InputEnded,function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    return function() return val end
end

-- 01 Dashboard
do
    local p=pages["หน้าหลัก"]
    local c=newCard(p,"ภาพรวม",100)
    local playersCount=label(c,"ผู้เล่น: - / -",UDim2.fromOffset(12,34),UDim2.new(.5,-15,0,24),15,theme.text,Enum.Font.GothamBold)
    local fpsLabel=label(c,"FPS: --",UDim2.new(.52,0,0,34),UDim2.new(.45,-10,0,24),15,theme.green,Enum.Font.GothamBold)
    local session=label(c,"เวลาเซสชัน: 00:00",UDim2.fromOffset(12,65),UDim2.new(1,-24,0,18),10,theme.muted)
    local quick=newCard(p,"ทางลัด",80)
    local b1=button(quick,"ผู้เล่น",UDim2.fromOffset(12,38),UDim2.new(.31,-8,0,28),theme.card2)
    local b2=button(quick,"Visuals",UDim2.new(.34,0,0,38),UDim2.new(.31,-8,0,28),theme.blue)
    local b3=button(quick,"กระเป๋า",UDim2.new(.68,0,0,38),UDim2.new(.31,-8,0,28),theme.card2)
    bind(b1.MouseButton1Click,function() selectPage("ผู้เล่น") end)
    bind(b2.MouseButton1Click,function() selectPage("ESP / Visuals") end)
    bind(b3.MouseButton1Click,function() selectPage("กระเป๋าและเงิน") end)
    local start=os.clock(); local frames,elapsed=0,0
    bind(RunService.RenderStepped,function(dt)
        frames+=1; elapsed+=dt
        if elapsed>=1 then fpsLabel.Text="FPS: "..math.floor(frames/elapsed+.5); frames=0; elapsed=0 end
        local s=math.floor(os.clock()-start); session.Text=string.format("เวลาเซสชัน: %02d:%02d",math.floor(s/60),s%60)
    end)
    local function update() playersCount.Text=string.format("ผู้เล่น: %d / %d",#Players:GetPlayers(),Players.MaxPlayers) end
    update(); bind(Players.PlayerAdded,update); bind(Players.PlayerRemoving,function() task.defer(update) end)
end

-- Player Inspector with public account age and UserId; no private profile scraping
local selectedPlayer=nil
local playerDetails
local function ageString(plr)
    local ok,age=pcall(function() return plr.AccountAge end)
    return ok and (tostring(age).." วัน") or "ไม่พร้อมใช้งาน"
end
do
    local p=pages["ผู้เล่น"]
    local c=newCard(p,"รายชื่อผู้เล่น • กดชื่อเพื่อดูข้อมูล",70)
    label(c,"แสดง DisplayName, Username, UserId, อายุบัญชี, ทีม และ HP",UDim2.fromOffset(12,34),UDim2.new(1,-24,0,22),10,theme.muted)
    local listCard=newCard(p,"ผู้เล่นในเซิร์ฟเวอร์",300)
    local list=make("ScrollingFrame",{Position=UDim2.fromOffset(10,34),Size=UDim2.new(1,-20,1,-43),BackgroundTransparency=1,
        BorderSizePixel=0,ScrollBarThickness=4,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new()},listCard)
    make("UIListLayout",{Padding=UDim.new(0,5)},list)
    playerDetails=newCard(p,"รายละเอียดผู้เล่นที่เลือก",150)
    local detail=label(playerDetails,"เลือกผู้เล่นจากรายการด้านบน",UDim2.fromOffset(12,33),UDim2.new(1,-24,0,105),11,theme.muted)
    local function renderDetails(plr)
        selectedPlayer=plr
        if not plr then detail.Text="ผู้เล่นออกจากเซิร์ฟเวอร์หรือยังไม่ได้เลือก"; return end
        local hum=plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
        detail.Text=string.format("ชื่อแสดงผล: %s\nUsername: @%s\nUserId: %d\nอายุบัญชี: %s\nทีม: %s\nHP: %s",
            plr.DisplayName,plr.Name,plr.UserId,ageString(plr),plr.Team and plr.Team.Name or "ไม่มีทีม",
            hum and string.format("%.0f / %.0f",hum.Health,hum.MaxHealth) or "ตัวละครยังไม่โหลด")
    end
    local function refresh()
        for _,ch in ipairs(list:GetChildren()) do if ch:IsA("TextButton") then ch:Destroy() end end
        for _,plr in ipairs(Players:GetPlayers()) do
            local row=button(list,plr.DisplayName.."  (@"..plr.Name..")",UDim2.new(),UDim2.new(1,-3,0,34),theme.card2)
            row.TextXAlignment=Enum.TextXAlignment.Left
            bind(row.MouseButton1Click,function() renderDetails(plr) end)
        end
        if selectedPlayer and not selectedPlayer.Parent then renderDetails(nil) end
    end
    refresh(); bind(Players.PlayerAdded,refresh); bind(Players.PlayerRemoving,function() task.defer(refresh) end)
    bind(RunService.Heartbeat,function() if selectedPlayer and selectedPlayer.Parent then renderDetails(selectedPlayer) end end)
end

-- 03 Inventory: displays only data deliberately replicated by your game.
do
    local p=pages["กระเป๋าและเงิน"]
    local c=newCard(p,"ข้อมูลเงินและกระเป๋า",76)
    label(c,"เลือกผู้เล่นในหมวด ผู้เล่น ก่อน แล้วกดรีเฟรช",UDim2.fromOffset(12,34),UDim2.new(1,-24,0,22),10,theme.muted)
    local inv=newCard(p,"รายละเอียด Inventory",240)
    local invText=label(inv,"ยังไม่ได้เลือกผู้เล่น",UDim2.fromOffset(12,34),UDim2.new(1,-24,1,-45),11,theme.muted)
    local refresh=button(inv,"รีเฟรช",UDim2.new(1,-88,0,5),UDim2.fromOffset(74,23),theme.blue)
    local function inspect()
        local plr=selectedPlayer
        if not plr or not plr.Parent then invText.Text="เลือกผู้เล่นก่อน"; return end
        local lines={"ผู้เล่น: @"..plr.Name,"ข้อมูลเงิน/ไอเทมต้องถูกเปิดเผยโดยเกมของคุณ"}
        local ls=plr:FindFirstChild("leaderstats")
        if ls then
            local money=ls:FindFirstChild("Money") or ls:FindFirstChild("Cash") or ls:FindFirstChild("Coins")
            table.insert(lines,"เงิน: "..(money and tostring(money.Value) or "ไม่พบ Money/Cash/Coins"))
        else table.insert(lines,"เงิน: ไม่พบ leaderstats") end
        local bag=plr:FindFirstChildOfClass("Backpack")
        table.insert(lines,"")
        table.insert(lines,"ไอเทมใน Backpack:")
        if bag then
            local count=0
            for _,item in ipairs(bag:GetChildren()) do
                if item:IsA("Tool") then count+=1; table.insert(lines,"• "..item.Name) end
            end
            if count==0 then table.insert(lines,"(ไม่มี Tool ที่ถูก replicate)") end
        else table.insert(lines,"Backpack ยังไม่พร้อม") end
        invText.Text=table.concat(lines,"\n")
    end
    bind(refresh.MouseButton1Click,inspect)
end

-- 04 Visuals: authorized character highlights and labels, disabled by default
local visualsEnabled=false
local nameTagsEnabled=true
local healthEnabled=true
local teamColorEnabled=true
local highlights={}
local tags={}
local function teamColor(plr)
    return (teamColorEnabled and plr.Team and plr.Team.TeamColor.Color) or theme.blue
end
local function removeVisual(plr)
    if highlights[plr] then highlights[plr]:Destroy(); highlights[plr]=nil end
    if tags[plr] then tags[plr]:Destroy(); tags[plr]=nil end
end
local function createVisual(plr)
    removeVisual(plr)
    if not visualsEnabled or plr==player or not plr.Character then return end
    local char=plr.Character
    local h=make("Highlight",{Name="B3TeamHighlight",Adornee=char,DepthMode=Enum.HighlightDepthMode.Occluded,
        FillColor=teamColor(plr),OutlineColor=teamColor(plr),FillTransparency=.78,OutlineTransparency=.08,Enabled=true},gui)
    highlights[plr]=h
    local head=char:FindFirstChild("Head")
    if head and nameTagsEnabled then
        local bb=make("BillboardGui",{Name="B3NameTag",Adornee=head,Size=UDim2.fromOffset(160,healthEnabled and 42 or 22),
            StudsOffset=Vector3.new(0,2.4,0),AlwaysOnTop=false,MaxDistance=250},gui)
        local labelText=make("TextLabel",{BackgroundTransparency=1,Size=UDim2.fromScale(1,1),
            Text=plr.DisplayName,TextColor3=teamColor(plr),TextStrokeTransparency=.25,
            Font=Enum.Font.GothamBold,TextSize=11},bb)
        if healthEnabled then
            local hum=char:FindFirstChildOfClass("Humanoid")
            if hum then labelText.Text=plr.DisplayName.."\nHP "..math.floor(hum.Health).."/"..math.floor(hum.MaxHealth) end
        end
        tags[plr]=bb
    end
end
local function refreshVisuals()
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=player then createVisual(plr) end
    end
end
do
    local p=pages["ESP / Visuals"]
    local c=newCard(p,"Highlight ตัวละคร (ทีม/สี)",120)
    addToggle(c,"เปิด Highlight สำหรับตัวละครที่เกมแสดงให้เห็น",34,false,function(v)
        visualsEnabled=v; if v then refreshVisuals() else for plr in pairs(highlights) do removeVisual(plr) end end
        log("Highlight "..(v and "ON" or "OFF"))
    end)
    addToggle(c,"ใช้สีตามทีม",68,true,function(v) teamColorEnabled=v; if visualsEnabled then refreshVisuals() end end)
    local c2=newCard(p,"ชื่อและแถบเลือด",110)
    addToggle(c2,"แสดงชื่อผู้เล่น",34,true,function(v) nameTagsEnabled=v; if visualsEnabled then refreshVisuals() end end)
    addToggle(c2,"แสดงค่า HP ในป้ายชื่อ",68,true,function(v) healthEnabled=v; if visualsEnabled then refreshVisuals() end end)
    local c3=newCard(p,"ขอบเขตการแสดงผล",68)
    label(c3,"ใช้ Occluded Highlight: ไม่แสดงผ่านกำแพง",UDim2.fromOffset(12,34),UDim2.new(1,-24,0,20),10,theme.muted)
    bind(Players.PlayerAdded,function(plr) bind(plr.CharacterAdded,function() task.wait(.5); createVisual(plr) end) end)
    for _,plr in ipairs(Players:GetPlayers()) do bind(plr.CharacterAdded,function() task.wait(.5); createVisual(plr) end) end
end

-- 05 Camera-projected line overlay, only for visible/on-screen characters, off by default
local linesEnabled=false
local lineObjects={}
local function clearLines()
    for _,o in pairs(lineObjects) do if o then o:Destroy() end end
    table.clear(lineObjects)
end
local function updateLines()
    if not linesEnabled then clearLines(); return end
    local cam=workspace.CurrentCamera
    if not cam then return end
    local seen={}
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=player and plr.Character then
            local root=plr.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local v,on=cam:WorldToViewportPoint(root.Position)
                if on and v.Z>0 then
                    seen[plr]=true
                    local line=lineObjects[plr]
                    if not line then
                        line=make("Frame",{AnchorPoint=Vector2.new(0,0.5),BorderSizePixel=0,BackgroundColor3=teamColor(plr),Size=UDim2.fromOffset(1,2)},gui)
                        lineObjects[plr]=line
                    end
                    local origin=Vector2.new(cam.ViewportSize.X/2,cam.ViewportSize.Y-8)
                    local target=Vector2.new(v.X,v.Y)
                    local delta=target-origin
                    line.Position=UDim2.fromOffset(origin.X,origin.Y)
                    line.Size=UDim2.fromOffset(delta.Magnitude,2)
                    line.Rotation=math.deg(math.atan2(delta.Y,delta.X))
                    line.Visible=true; line.BackgroundColor3=teamColor(plr)
                end
            end
        end
    end
    for plr,line in pairs(lineObjects) do if not seen[plr] then line.Visible=false end end
end
do
    local p=pages["เส้นบนหน้าจอ"]
    local c=newCard(p,"เส้นจากหน้าจอไปยังตัวละคร",112)
    label(c,"เส้นคำนวณจากกล้องทุกเฟรม และซ่อนเมื่ออยู่นอกจอ/หลังกกล้อง",UDim2.fromOffset(12,34),UDim2.new(1,-24,0,30),10,theme.muted)
    addToggle(c,"เปิดเส้น (ปิดเป็นค่าเริ่มต้น)",70,false,function(v) linesEnabled=v; if not v then clearLines() end; log("Screen lines "..(v and "ON" or "OFF")) end)
    local info=newCard(p,"การแสดงผล",65)
    label(info,"เส้นนี้เป็น UI overlay ของโปรเจกต์ทดสอบ ไม่ได้ใช้ข้อมูลซ่อนเร้น",UDim2.fromOffset(12,34),UDim2.new(1,-24,0,20),10,theme.muted)
    bind(RunService.RenderStepped,updateLines)
end

-- 06 Q target selection for test/developer workflow only; no camera lock/aiming
local target=nil
local targetStatus
local qEnabled=true
do
    local p=pages["ล็อกเป้าทดสอบ"]
    local c=newCard(p,"เลือกเป้าทดสอบด้วย Q",100)
    targetStatus=label(c,"เป้าหมาย: ยังไม่ได้เลือก",UDim2.fromOffset(12,35),UDim2.new(1,-24,0,24),11,theme.muted)
    local toggle=button(c,"เปิดการเลือกด้วย Q",UDim2.new(1,-155,0,5),UDim2.fromOffset(142,24),theme.blue)
    bind(toggle.MouseButton1Click,function() qEnabled=not qEnabled; toggle.Text=qEnabled and "เปิดการเลือกด้วย Q" or "ปิดการเลือกด้วย Q" end)
    local info=newCard(p,"วิธีใช้งาน",105)
    label(info,"กด Q เพื่อเลือก/ยกเลิกเป้าหมายที่ใกล้กลางจอในโหมดทดสอบของเกมคุณ\nระบบนี้แค่เลือกเป้าหมายและแสดงสถานะ ไม่ขยับกล้องหรือยิงอัตโนมัติ",UDim2.fromOffset(12,34),UDim2.new(1,-24,0,57),10,theme.muted)
    bind(UIS.InputBegan,function(input,processed)
        if processed or input.KeyCode~=Enum.KeyCode.Q or not qEnabled then return end
        if target and target.Parent then
            target=nil; targetStatus.Text="เป้าหมาย: ยกเลิกแล้ว"; log("Target cleared"); return
        end
        local cam=workspace.CurrentCamera
        if not cam then return end
        local center=cam.ViewportSize/2
        local best,bestDist=nil,math.huge
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=player and plr.Character then
                local root=plr.Character:FindFirstChild("HumanoidRootPart")
                local hum=plr.Character:FindFirstChildOfClass("Humanoid")
                if root and hum and hum.Health>0 then
                    local pos,on=cam:WorldToViewportPoint(root.Position)
                    if on and pos.Z>0 then
                        local d=(Vector2.new(pos.X,pos.Y)-center).Magnitude
                        if d<bestDist then best,bestDist=plr,d end
                    end
                end
            end
        end
        target=best
        targetStatus.Text=target and ("เป้าหมายทดสอบ: @"..target.Name) or "ไม่พบเป้าหมายบนหน้าจอ"
        log(target and ("Target selected: "..target.Name) or "No visible target")
    end)
end

-- 07 E cooldown config for own game's interaction logic
do
    local p=pages["การโต้ตอบ"]
    local c=newCard(p,"ตั้งค่า E / Interaction",78)
    label(c,"ตัวเลื่อนนี้เก็บค่าหน่วงสำหรับนำไปเชื่อมกับระบบเกมของคุณ",UDim2.fromOffset(12,34),UDim2.new(1,-24,0,22),10,theme.muted)
    local s=newCard(p,"เวลาหน่วง",76)
    local cooldown=.35
    addSlider(s,"Cooldown (วินาที)",34,.1,2,.35,"s",function(v) cooldown=v end)
    local info=newCard(p,"แนวทาง",75)
    label(info,"ตรวจ cooldown ฝั่งเซิร์ฟเวอร์ด้วย เพื่อป้องกันการเรียก Remote ซ้ำ",UDim2.fromOffset(12,34),UDim2.new(1,-24,0,25),10,theme.muted)
end

-- 08 Performance reversible lighting
local graphicsBackup=nil
local graphicsEnabled=false
local function restoreGraphics()
    if not graphicsEnabled or not graphicsBackup then return end
    pcall(function() Lighting.GlobalShadows=graphicsBackup.shadows; Lighting.FogEnd=graphicsBackup.fog end)
    for _,e in ipairs(graphicsBackup.effects) do if e.obj and e.obj.Parent then pcall(function() e.obj.Enabled=e.enabled end) end end
    graphicsBackup=nil; graphicsEnabled=false
end
local function toggleGraphics()
    if graphicsEnabled then restoreGraphics(); return false end
    graphicsBackup={shadows=Lighting.GlobalShadows,fog=Lighting.FogEnd,effects={}}
    for _,o in ipairs(Lighting:GetChildren()) do
        if o:IsA("PostEffect") then table.insert(graphicsBackup.effects,{obj=o,enabled=o.Enabled}); o.Enabled=false end
    end
    Lighting.GlobalShadows=false; Lighting.FogEnd=100000; graphicsEnabled=true; return true
end
do
    local p=pages["ประสิทธิภาพ"]
    local c=newCard(p,"ปรับกราฟิก",100)
    label(c,"ลดเงาและ PostEffects ในเครื่องนี้",UDim2.fromOffset(12,35),UDim2.new(1,-140,0,30),10,theme.muted)
    local b=button(c,"ลดกราฟิก",UDim2.new(1,-125,0,36),UDim2.fromOffset(112,30),theme.blue)
    bind(b.MouseButton1Click,function() local on=toggleGraphics(); b.Text=on and "คืนค่ากราฟิก" or "ลดกราฟิก"; log(on and "Graphics reduced" or "Graphics restored") end)
    local c2=newCard(p,"ตัววัด",75)
    statusText=label(c2,"FPS monitor: active",UDim2.fromOffset(12,34),UDim2.new(1,-24,0,22),10,theme.green)
end

-- 09 Settings
do
    local p=pages["ตั้งค่า"]
    local c=newCard(p,"ขนาดหน้าต่าง",95)
    local a=button(c,"เล็ก",UDim2.fromOffset(12,42),UDim2.new(.3,-8,0,30),theme.card2)
    local b=button(c,"ปกติ",UDim2.new(.35,0,0,42),UDim2.new(.3,-8,0,30),theme.blue)
    local d=button(c,"ใหญ่",UDim2.new(.69,0,0,42),UDim2.new(.3,-8,0,30),theme.card2)
    bind(a.MouseButton1Click,function() scale.Scale=.85 end)
    bind(b.MouseButton1Click,function() scale.Scale=1 end)
    bind(d.MouseButton1Click,function() scale.Scale=1.08 end)
    local c2=newCard(p,"คีย์ลัด",90)
    label(c2,"RightShift — ซ่อน/แสดงเมนู\nQ — เลือก/ยกเลิกเป้าทดสอบ\nEnd — ปิด UI และยกเลิก connections",UDim2.fromOffset(12,33),UDim2.new(1,-24,0,49),10,theme.muted)
    local reset=button(p,"รีเซ็ต UI",UDim2.new(),UDim2.new(1,0,0,32),theme.card2)
    bind(reset.MouseButton1Click,function() scale.Scale=1; main.Position=UDim2.fromScale(.5,.5); selectPage("หน้าหลัก") end)
end

-- 10 Diagnostics
do
    local p=pages["Diagnostics"]
    local c=newCard(p,"Event log",270)
    local logText=label(c,"เริ่มต้นระบบแล้ว",UDim2.fromOffset(12,34),UDim2.new(1,-24,1,-44),10,theme.muted)
    local refresh=button(c,"อัปเดต log",UDim2.new(1,-100,0,5),UDim2.fromOffset(88,22),theme.blue)
    local function updateLog() logText.Text=table.concat(logLines,"\n") end
    bind(refresh.MouseButton1Click,updateLog)
    local c2=newCard(p,"สถานะ",68)
    label(c2,"ข้อมูลเงิน/ไอเทมจะแสดงได้เมื่อเกมของคุณ replicate ให้เท่านั้น",UDim2.fromOffset(12,34),UDim2.new(1,-24,0,20),10,theme.muted)
end

-- floating open button and keyboard
local floating=button(gui,"☰",UDim2.new(0,12,.5,-20),UDim2.fromOffset(40,40),theme.side)
stroke(floating,theme.blue)
local isOpen=true
local function setOpen(v) isOpen=v; main.Visible=v end
bind(close.MouseButton1Click,function() setOpen(false) end)
bind(floating.MouseButton1Click,function() setOpen(not isOpen) end)
bind(UIS.InputBegan,function(i,processed) if not processed and i.KeyCode==Enum.KeyCode.RightShift then setOpen(not isOpen) end end)

-- Drag by header
do
    local dragging=false; local dragInput; local dragStart; local startPos
    bind(header.InputBegan,function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true; dragInput=i; dragStart=i.Position; startPos=main.Position
        end
    end)
    bind(UIS.InputChanged,function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-dragStart
            main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
    bind(UIS.InputEnded,function(i) if i==dragInput or i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false; dragInput=nil end end)
end

local cleaned=false
local function cleanup()
    if cleaned then return end; cleaned=true
    if graphicsEnabled then restoreGraphics() end
    clearLines()
    for plr in pairs(highlights) do removeVisual(plr) end
    for _,c in ipairs(connections) do pcall(function() c:Disconnect() end) end
    gui:Destroy()
end
bind(UIS.InputBegan,function(i,processed) if not processed and i.KeyCode==Enum.KeyCode.End then cleanup() end end)
print("[B3 HUB] Categorized developer suite loaded. RightShift toggle; End unload.")
