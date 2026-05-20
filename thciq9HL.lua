local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LightingService = game:GetService("Lighting")
local camera = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer


local TARGET_PART = "Head"
local EXCLUDED_PLAYER_NAME = "!!!Here_Your_Nickname!!!"
local HEAD_SIZE = Vector3.new(10, 10, 10)
local HEAD_TRANSPARENCY = 0.6

local cfg = {
    esp = true,
    aim = true,
    hitbox = true,
    fullbright = false,
    fov = true,
    fovSize = 200,
}

-- ==============================

-- ==============================
local origAmbient = LightingService.Ambient
local origBrightness = LightingService.Brightness
local origOutdoor = LightingService.OutdoorAmbient
local fullbrightActive = false

local function setFullbright(on)
    if on == fullbrightActive then return end  -- не применять дважды
    fullbrightActive = on
    if on then
      
        origAmbient = LightingService.Ambient
        origBrightness = LightingService.Brightness
        origOutdoor = LightingService.OutdoorAmbient
        LightingService.Ambient = Color3.fromRGB(255,255,255)
        LightingService.Brightness = 2
        LightingService.OutdoorAmbient = Color3.fromRGB(255,255,255)
    else
        LightingService.Ambient = origAmbient
        LightingService.Brightness = origBrightness
        LightingService.OutdoorAmbient = origOutdoor
    end
end


--  HITBOX (FIXED)
-- ==============================
local function setupCharacter(player, character)
    if player.Name == EXCLUDED_PLAYER_NAME then return end
    local head = character:WaitForChild("Head", 5)
    if not head then return end

    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not character or not character.Parent then
            connection:Disconnect()
            return
        end
        if cfg.hitbox then
            if head.Size ~= HEAD_SIZE then
                head.Size = HEAD_SIZE
                head.Transparency = HEAD_TRANSPARENCY
                head.CanCollide = false
                head.Massless = true
            end
        else
            if head.Size ~= Vector3.new(1,1,1) then
                head.Size = Vector3.new(1,1,1)
                head.Transparency = 0
                head.CanCollide = true
                head.Massless = false
            end
        end
    end)
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(c) task.wait(0.1) setupCharacter(p,c) end)
end)
for _, p in pairs(Players:GetPlayers()) do
    if p.Character then setupCharacter(p, p.Character) end
    p.CharacterAdded:Connect(function(c) task.wait(0.1) setupCharacter(p,c) end)
end

-- ==============================
--  GUI
-- ==============================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CHEAT_GUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = localPlayer.PlayerGui

local espObjects = {}

-- FOV circle
local fovFrame = Instance.new("Frame")
fovFrame.Size = UDim2.new(0, cfg.fovSize*2, 0, cfg.fovSize*2)
fovFrame.BackgroundTransparency = 1
fovFrame.BorderSizePixel = 0
fovFrame.Parent = screenGui
Instance.new("UICorner", fovFrame).CornerRadius = UDim.new(1,0)
local fovStroke = Instance.new("UIStroke")
fovStroke.Color = Color3.fromRGB(255,255,255)
fovStroke.Thickness = 1.5
fovStroke.Parent = fovFrame

-- ==============================
--  MENU FRAME
-- ==============================
local MENU_W = 300
local MENU_H = 400
local menuOpen = true
local dragging, dragStart, startPos = false, nil, nil

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, MENU_W, 0, MENU_H)
mainFrame.Position = UDim2.new(0.5,-MENU_W/2, 0.5,-MENU_H/2)
mainFrame.BackgroundColor3 = Color3.fromRGB(10,10,15)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0,14)
local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(255,50,80)
mainStroke.Thickness = 1.5
mainStroke.Parent = mainFrame

local bgGrad = Instance.new("UIGradient")
bgGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(16,12,28)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(6,6,12))
})
bgGrad.Rotation = 135
bgGrad.Parent = mainFrame

-- Top accent
local topAccent = Instance.new("Frame")
topAccent.Size = UDim2.new(1,0,0,2)
topAccent.BackgroundColor3 = Color3.fromRGB(255,50,80)
topAccent.BorderSizePixel = 0
topAccent.ZIndex = 5
topAccent.Parent = mainFrame
local ag = Instance.new("UIGradient")
ag.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255,50,80)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255,140,50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255,50,80))
})
ag.Parent = topAccent

-- Header / drag zone
local headerFrame = Instance.new("Frame")
headerFrame.Size = UDim2.new(1,0,0,58)
headerFrame.BackgroundTransparency = 1
headerFrame.ZIndex = 10
headerFrame.Parent = mainFrame

local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(1,-20,0,26)
titleLbl.Position = UDim2.new(0,15,0,10)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = " YUKI (Free)"
titleLbl.TextColor3 = Color3.fromRGB(255,255,255)
titleLbl.TextSize = 20
titleLbl.Font = Enum.Font.GothamBold
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.ZIndex = 10
titleLbl.Parent = headerFrame

local subLbl = Instance.new("TextLabel")
subLbl.Size = UDim2.new(1,-20,0,14)
subLbl.Position = UDim2.new(0,15,0,36)
subLbl.BackgroundTransparency = 1
subLbl.Text = "RightShift to toggle  •  drag to move"
subLbl.TextColor3 = Color3.fromRGB(80,80,100)
subLbl.TextSize = 10
subLbl.Font = Enum.Font.Gotham
subLbl.TextXAlignment = Enum.TextXAlignment.Left
subLbl.ZIndex = 10
subLbl.Parent = headerFrame

-- Drag
headerFrame.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true dragStart = i.Position startPos = mainFrame.Position
    end
end)
headerFrame.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
UserInputService.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
    end
end)

-- ==============================
-- TABS BAR
-- ==============================
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1,-20,0,32)
tabBar.Position = UDim2.new(0,10,0,58)
tabBar.BackgroundColor3 = Color3.fromRGB(14,12,22)
tabBar.BorderSizePixel = 0
tabBar.Parent = mainFrame
Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0,8)

local tabNames = {"COMBAT", "VISUALS"}
local tabColors = {Color3.fromRGB(255,80,80), Color3.fromRGB(80,180,255)}
local tabBtns = {}
local tabPages = {}
local activeTab = 1

-- Content area
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1,-20,1,-108)
contentFrame.Position = UDim2.new(0,10,0,98)
contentFrame.BackgroundTransparency = 1
contentFrame.ClipsDescendants = true
contentFrame.Parent = mainFrame

-- Create tab pages
for i = 1, #tabNames do
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1,0,1,0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = Color3.fromRGB(255,50,80)
    page.Visible = (i == 1)
    page.Parent = contentFrame

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0,6)
    layout.Parent = page

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0,4)
    padding.Parent = page

    tabPages[i] = page
end

-- Tab buttons
for i, name in ipairs(tabNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1/#tabNames, -4, 1, -6)
    btn.Position = UDim2.new((i-1)/#tabNames, 2, 0, 3)
    btn.BackgroundColor3 = i==1 and tabColors[i] or Color3.fromRGB(20,18,32)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.Parent = tabBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
    tabBtns[i] = btn

    btn.MouseButton1Click:Connect(function()
        activeTab = i
        for j, tb in ipairs(tabBtns) do
            TweenService:Create(tb, TweenInfo.new(0.15), {
                BackgroundColor3 = j==i and tabColors[j] or Color3.fromRGB(20,18,32)
            }):Play()
        end
        for j, pg in ipairs(tabPages) do
            pg.Visible = (j == i)
        end
    end)
end

-- ==============================
-- COMPONENT BUILDERS
-- ==============================
local function makeToggle(parent, icon, label, key, color, order)
    local btn = Instance.new("Frame")
    btn.Size = UDim2.new(1,0,0,50)
    btn.BackgroundColor3 = Color3.fromRGB(18,16,28)
    btn.BorderSizePixel = 0
    btn.LayoutOrder = order or 0
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(30,28,45)
    stroke.Thickness = 1
    stroke.Parent = btn

    local iconBg = Instance.new("Frame")
    iconBg.Size = UDim2.new(0,32,0,32)
    iconBg.Position = UDim2.new(0,9,0.5,-16)
    iconBg.BackgroundColor3 = color
    iconBg.BackgroundTransparency = 0.8
    iconBg.BorderSizePixel = 0
    iconBg.Parent = btn
    Instance.new("UICorner", iconBg).CornerRadius = UDim.new(0,7)
    local iconL = Instance.new("TextLabel")
    iconL.Size = UDim2.new(1,0,1,0)
    iconL.BackgroundTransparency = 1
    iconL.Text = icon
    iconL.TextSize = 16
    iconL.Font = Enum.Font.GothamBold
    iconL.TextColor3 = color
    iconL.Parent = iconBg

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1,-105,0,17)
    nameLbl.Position = UDim2.new(0,50,0,8)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = label
    nameLbl.TextColor3 = Color3.fromRGB(220,220,235)
    nameLbl.TextSize = 13
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.Parent = btn

    local statLbl = Instance.new("TextLabel")
    statLbl.Size = UDim2.new(1,-105,0,13)
    statLbl.Position = UDim2.new(0,50,0,27)
    statLbl.BackgroundTransparency = 1
    statLbl.Text = cfg[key] and "ON" or "OFF"
    statLbl.TextColor3 = cfg[key] and Color3.fromRGB(80,220,120) or Color3.fromRGB(100,100,120)
    statLbl.TextSize = 10
    statLbl.Font = Enum.Font.Gotham
    statLbl.TextXAlignment = Enum.TextXAlignment.Left
    statLbl.Parent = btn

    local swBg = Instance.new("Frame")
    swBg.Size = UDim2.new(0,40,0,21)
    swBg.Position = UDim2.new(1,-49,0.5,-10)
    swBg.BackgroundColor3 = cfg[key] and Color3.fromRGB(80,220,120) or Color3.fromRGB(50,48,68)
    swBg.BorderSizePixel = 0
    swBg.Parent = btn
    Instance.new("UICorner", swBg).CornerRadius = UDim.new(1,0)
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0,15,0,15)
    dot.Position = cfg[key] and UDim2.new(1,-18,0.5,-7) or UDim2.new(0,3,0.5,-7)
    dot.BackgroundColor3 = Color3.fromRGB(255,255,255)
    dot.BorderSizePixel = 0
    dot.Parent = swBg
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)

    local click = Instance.new("TextButton")
    click.Size = UDim2.new(1,0,1,0)
    click.BackgroundTransparency = 1
    click.Text = ""
    click.Parent = btn

    local function refresh(anim)
        local d = anim and 0.18 or 0
        local on = cfg[key]
        TweenService:Create(swBg, TweenInfo.new(d), {BackgroundColor3 = on and Color3.fromRGB(80,220,120) or Color3.fromRGB(50,48,68)}):Play()
        TweenService:Create(dot, TweenInfo.new(d), {Position = on and UDim2.new(1,-18,0.5,-7) or UDim2.new(0,3,0.5,-7)}):Play()
        statLbl.Text = on and "ON" or "OFF"
        statLbl.TextColor3 = on and Color3.fromRGB(80,220,120) or Color3.fromRGB(100,100,120)
        if key == "fullbright" then setFullbright(on) end
    end

    click.MouseButton1Click:Connect(function()
        cfg[key] = not cfg[key]
        refresh(true)
        TweenService:Create(btn, TweenInfo.new(0.08), {BackgroundColor3 = Color3.fromRGB(26,22,40)}):Play()
        task.wait(0.12)
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(18,16,28)}):Play()
    end)
end

local function makeSlider(parent, label, key, minVal, maxVal, order)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1,0,0,62)
    container.BackgroundColor3 = Color3.fromRGB(18,16,28)
    container.BorderSizePixel = 0
    container.LayoutOrder = order or 0
    container.Parent = parent
    Instance.new("UICorner", container).CornerRadius = UDim.new(0,10)
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(30,28,45)
    stroke.Thickness = 1
    stroke.Parent = container

    local labelLbl = Instance.new("TextLabel")
    labelLbl.Size = UDim2.new(1,-20,0,16)
    labelLbl.Position = UDim2.new(0,10,0,8)
    labelLbl.BackgroundTransparency = 1
    labelLbl.Text = label
    labelLbl.TextColor3 = Color3.fromRGB(200,200,220)
    labelLbl.TextSize = 12
    labelLbl.Font = Enum.Font.GothamBold
    labelLbl.TextXAlignment = Enum.TextXAlignment.Left
    labelLbl.Parent = container

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0,50,0,16)
    valLbl.Position = UDim2.new(1,-58,0,8)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(cfg[key])
    valLbl.TextColor3 = Color3.fromRGB(255,80,80)
    valLbl.TextSize = 12
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = container

    -- Track
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1,-20,0,6)
    track.Position = UDim2.new(0,10,0,38)
    track.BackgroundColor3 = Color3.fromRGB(35,32,52)
    track.BorderSizePixel = 0
    track.Parent = container
    Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((cfg[key]-minVal)/(maxVal-minVal),0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(255,80,80)
    fill.BorderSizePixel = 0
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)

    local handle = Instance.new("Frame")
    handle.Size = UDim2.new(0,14,0,14)
    handle.AnchorPoint = Vector2.new(0.5,0.5)
    handle.Position = UDim2.new((cfg[key]-minVal)/(maxVal-minVal),0,0.5,0)
    handle.BackgroundColor3 = Color3.fromRGB(255,255,255)
    handle.BorderSizePixel = 0
    handle.ZIndex = 3
    handle.Parent = track
    Instance.new("UICorner", handle).CornerRadius = UDim.new(1,0)

    local draggingSlider = false
    local function updateSlider(inputX)
        local trackAbsPos = track.AbsolutePosition.X
        local trackAbsSize = track.AbsoluteSize.X
        local rel = math.clamp((inputX - trackAbsPos) / trackAbsSize, 0, 1)
        local val = math.floor(minVal + rel*(maxVal-minVal))
        cfg[key] = val
        fill.Size = UDim2.new(rel,0,1,0)
        handle.Position = UDim2.new(rel,0,0.5,0)
        valLbl.Text = tostring(val)
    end

    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSlider = true
            updateSlider(i.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if draggingSlider and i.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(i.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSlider = false
        end
    end)
end

local function makeSectionLabel(parent, text, order)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,0,18)
    lbl.BackgroundTransparency = 1
    lbl.Text = "  " .. text
    lbl.TextColor3 = Color3.fromRGB(120,120,150)
    lbl.TextSize = 10
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = order or 0
    lbl.Parent = parent
end

-- ==============================
-- BUILD COMBAT TAB
-- ==============================
local combat = tabPages[1]
makeSectionLabel(combat, "AIMBOT", 1)
makeToggle(combat, "🎯", "Aim Assist",     "aim",    Color3.fromRGB(255,90,90),  2)
makeToggle(combat, "🔘", "FOV Circle",     "fov",    Color3.fromRGB(200,200,255),3)
makeSlider(combat,        "FOV Size",       "fovSize", 50, 400,                   4)
makeSectionLabel(combat, "HITBOX", 5)
makeToggle(combat, "💀", "Hitbox Expand",  "hitbox", Color3.fromRGB(255,180,50), 6)

-- ==============================
-- BUILD VISUALS TAB
-- ==============================
local visuals = tabPages[2]
makeSectionLabel(visuals, "PLAYERS", 1)
makeToggle(visuals, "👁",  "Wallhack ESP",  "esp",        Color3.fromRGB(100,180,255),2)
makeSectionLabel(visuals, "WORLD", 3)
makeToggle(visuals, "☀️", "Fullbright",    "fullbright", Color3.fromRGB(255,230,80), 4)

-- Footer
local footerLbl = Instance.new("TextLabel")
footerLbl.Size = UDim2.new(1,-20,0,16)
footerLbl.Position = UDim2.new(0,10,1,-20)
footerLbl.BackgroundTransparency = 1
footerLbl.Text = "by " .. EXCLUDED_PLAYER_NAME .. "  •  v2.0"
footerLbl.TextColor3 = Color3.fromRGB(45,45,65)
footerLbl.TextSize = 10
footerLbl.Font = Enum.Font.Gotham
footerLbl.TextXAlignment = Enum.TextXAlignment.Center
footerLbl.Parent = mainFrame

-- Open/close
local savedPos = nil
UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.RightShift then
        menuOpen = not menuOpen
        if menuOpen then
            mainFrame.Visible = true
            mainFrame.Position = savedPos or mainFrame.Position
            TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(0,MENU_W,0,MENU_H)
            }):Play()
        else
            savedPos = mainFrame.Position
            TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                Size = UDim2.new(0,MENU_W,0,0)
            }):Play()
            task.delay(0.26, function() mainFrame.Visible = false end)
        end
    end
end)

-- ==============================
-- ESP LOGIC
-- ==============================
local function isVisible(player)
    local character = player.Character
    if not character then return false end
    local head = character:FindFirstChild("Head")
    if not head then return false end
    local rp = RaycastParams.new()
    rp.FilterDescendantsInstances = {localPlayer.Character}
    rp.FilterType = Enum.RaycastFilterType.Exclude
    local origin = camera.CFrame.Position
    local result = workspace:Raycast(origin, head.Position - origin, rp)
    if result and result.Instance then
        return result.Instance:IsDescendantOf(character)
    end
    return false
end

local function createESP(player)
    if espObjects[player] then return end
    local holder = Instance.new("Frame")
    holder.BackgroundTransparency = 1
    holder.BorderSizePixel = 0
    holder.Size = UDim2.new(0,100,0,150)
    holder.Parent = screenGui
    local box = Instance.new("Frame")
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    box.Size = UDim2.new(1,0,1,0)
    box.Parent = holder
    local boxStroke = Instance.new("UIStroke")
    boxStroke.Color = Color3.fromRGB(255,0,0)
    boxStroke.Thickness = 2
    boxStroke.Parent = box
    local nameTag = Instance.new("TextLabel")
    nameTag.BackgroundTransparency = 1
    nameTag.Size = UDim2.new(1,0,0,16)
    nameTag.Position = UDim2.new(0,0,0,-18)
    nameTag.TextColor3 = Color3.fromRGB(255,255,255)
    nameTag.TextStrokeTransparency = 0
    nameTag.TextSize = 13
    nameTag.Font = Enum.Font.GothamBold
    nameTag.Text = player.Name
    nameTag.Parent = holder
    local hpBg = Instance.new("Frame")
    hpBg.BackgroundColor3 = Color3.fromRGB(50,50,50)
    hpBg.BorderSizePixel = 0
    hpBg.Size = UDim2.new(0,4,1,0)
    hpBg.Position = UDim2.new(0,-7,0,0)
    hpBg.Parent = holder
    local hpBar = Instance.new("Frame")
    hpBar.BackgroundColor3 = Color3.fromRGB(0,255,0)
    hpBar.BorderSizePixel = 0
    hpBar.Size = UDim2.new(1,0,1,0)
    hpBar.AnchorPoint = Vector2.new(0,1)
    hpBar.Position = UDim2.new(0,0,1,0)
    hpBar.Parent = hpBg
    local visLabel = Instance.new("TextLabel")
    visLabel.BackgroundTransparency = 1
    visLabel.Size = UDim2.new(1,20,0,14)
    visLabel.Position = UDim2.new(0,0,1,3)
    visLabel.TextColor3 = Color3.fromRGB(0,255,0)
    visLabel.TextStrokeTransparency = 0
    visLabel.TextSize = 12
    visLabel.Font = Enum.Font.GothamBold
    visLabel.Text = "VISIBLE"
    visLabel.Parent = holder
    espObjects[player] = {holder=holder, box=box, boxStroke=boxStroke, nameTag=nameTag, hpBar=hpBar, visLabel=visLabel}
end

local function removeESP(player)
    if espObjects[player] then
        espObjects[player].holder:Destroy()
        espObjects[player] = nil
    end
end

Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= localPlayer then createESP(p) end
end

local function getClosestTarget()
    local closest, closestDist = nil, cfg.fovSize
    local sc = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
    for _, player in ipairs(Players:GetPlayers()) do
        if player == localPlayer then continue end
        local character = player.Character
        if not character then continue end
        local part = character:FindFirstChild(TARGET_PART)
        if not part then continue end
        local sp, onScreen = camera:WorldToViewportPoint(part.Position)
        if onScreen then
            local dist = (Vector2.new(sp.X,sp.Y) - sc).Magnitude
            if dist < closestDist then
                closestDist = dist
                closest = player
            end
        end
    end
    return closest
end

-- Main loop
RunService.RenderStepped:Connect(function()
    local sc = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)

    fovFrame.Visible = cfg.fov
    local s = cfg.fovSize * 2
    fovFrame.Size = UDim2.new(0,s,0,s)
    fovFrame.Position = UDim2.new(0, sc.X - cfg.fovSize, 0, sc.Y - cfg.fovSize)

    local closestTarget = getClosestTarget()

    for _, player in ipairs(Players:GetPlayers()) do
        if player == localPlayer then continue end
        local esp = espObjects[player]
        if not esp then continue end
        local character = player.Character
        if not character then esp.holder.Visible = false continue end
        local humanoid = character:FindFirstChild("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local head = character:FindFirstChild("Head")
        if not rootPart or not head or not humanoid then esp.holder.Visible = false continue end

        if not cfg.esp then esp.holder.Visible = false continue end

        local rootSc, rootOn = camera:WorldToViewportPoint(rootPart.Position)
        local headSc, headOn = camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.5,0))

        if rootOn and headOn then
            esp.holder.Visible = true
            local height = math.abs(headSc.Y - rootSc.Y)
            local width = height * 0.6
            esp.holder.Size = UDim2.new(0,width,0,height)
            esp.holder.Position = UDim2.new(0, rootSc.X - width/2, 0, headSc.Y)
            local isTarget = (closestTarget == player)
            esp.boxStroke.Color = isTarget and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
            esp.nameTag.Text = player.Name .. (isTarget and " ◄" or "")
            esp.nameTag.TextColor3 = isTarget and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,255,255)
            local hpR = humanoid.Health / humanoid.MaxHealth
            esp.hpBar.Size = UDim2.new(1,0,hpR,0)
            esp.hpBar.BackgroundColor3 = Color3.fromRGB(255*(1-hpR), 255*hpR, 0)
            local vis = isVisible(player)
            esp.visLabel.Text = vis and "VISIBLE" or "NOT VISIBLE"
            esp.visLabel.TextColor3 = vis and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
            if cfg.aim and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) and isTarget then
                local tp = character:FindFirstChild(TARGET_PART)
                if tp then camera.CFrame = CFrame.lookAt(camera.CFrame.Position, tp.Position) end
            end
        else
            esp.holder.Visible = false
        end
    end
end)