-- // ESP + Aimbot + Silent Aim + FOV (Menu dọc, Kéo rộng, Drip Box, Health Bar, Chống rối)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- ================== CONFIG ==================
local ESP = {
    Enabled = true,
    Box = true,
    Line = true,
    Name = true,
    HealthBar = true,
    TeamColor = true,
    DripStyle = true,
    DripHeight = 10,
    BoxRadius = 8,
    MaxDistance = 800
}
local Aimbot = {
    Enabled = false,
    Smoothness = 0.12,
    FOV = 120
}
local SilentAim = { Enabled = false }
local MenuVisible = true
local FOVCircle
local ESPConnections = {}

-- ================== GUI ==================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ESP_Menu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Nút tròn khi ẩn menu
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0, 20, 0.5, -25)
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ToggleButton.Text = "ESP"
ToggleButton.TextColor3 = Color3.new(1,1,1)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 14
ToggleButton.Visible = false
ToggleButton.ZIndex = 10
ToggleButton.Parent = ScreenGui
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(1,0)
local ToggleStroke = Instance.new("UIStroke", ToggleButton)
ToggleStroke.Color = Color3.fromRGB(0, 180, 255)
ToggleStroke.Thickness = 2

-- Kéo nút tròn
local btnDragging, btnDragInput, btnDragStart, btnStartPos
ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        btnDragging = true
        btnDragStart = input.Position
        btnStartPos = ToggleButton.Position
    end
end)
ToggleButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        btnDragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if btnDragging and input == btnDragInput then
        local delta = input.Position - btnDragStart
        ToggleButton.Position = UDim2.new(btnStartPos.X.Scale, btnStartPos.X.Offset + delta.X, btnStartPos.Y.Scale, btnStartPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        btnDragging = false
    end
end)

-- ================== MENU DỌC ==================
local MainMenuFrame = Instance.new("Frame")
MainMenuFrame.Size = UDim2.new(0, 250, 0, 400)
MainMenuFrame.Position = UDim2.new(0, 20, 0.5, -200)
MainMenuFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainMenuFrame.BorderSizePixel = 0
MainMenuFrame.Visible = true
MainMenuFrame.ZIndex = 5
MainMenuFrame.Parent = ScreenGui

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0, 14)
MenuCorner.Parent = MainMenuFrame

local MenuStroke = Instance.new("UIStroke")
MenuStroke.Thickness = 1.5
MenuStroke.Color = Color3.fromRGB(0, 180, 255)
MenuStroke.Transparency = 0.4
MenuStroke.Parent = MainMenuFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
TitleBar.Parent = MainMenuFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 14)
TitleCorner.Parent = TitleBar

local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 180, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 100, 200))
}
TitleGradient.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "🔥 ESP HUB"
TitleLabel.TextColor3 = Color3.new(1,1,1)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 18
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -36, 0, 8)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 55, 55)
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.new(1,1,1)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 16
CloseButton.ZIndex = 6
CloseButton.Parent = MainMenuFrame
Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(1,0)

-- Player Count
local PlayerCountLabel = Instance.new("TextLabel")
PlayerCountLabel.Size = UDim2.new(1, -20, 0, 22)
PlayerCountLabel.Position = UDim2.new(0, 10, 0, 48)
PlayerCountLabel.BackgroundTransparency = 1
PlayerCountLabel.Text = "👥 Players: 0"
PlayerCountLabel.TextColor3 = Color3.fromRGB(180, 220, 255)
PlayerCountLabel.Font = Enum.Font.Gotham
PlayerCountLabel.TextSize = 12
PlayerCountLabel.TextXAlignment = Enum.TextXAlignment.Left
PlayerCountLabel.Parent = MainMenuFrame

-- Scrolling Frame
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -10, 1, -80)
ScrollingFrame.Position = UDim2.new(0, 5, 0, 73)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.ScrollBarThickness = 4
ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 180, 255)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.Parent = MainMenuFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollingFrame

UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end)

-- ================== TOGGLE SWITCH ĐẸP ==================
local function CreateToggleSwitch(name, default, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -10, 0, 38)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    ToggleFrame.Parent = ScrollingFrame
    Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 8)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.55, 0, 1, 0)
    Label.Position = UDim2.new(0, 8, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.new(1,1,1)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame

    local SwitchBg = Instance.new("TextButton")
    SwitchBg.Size = UDim2.new(0, 44, 0, 24)
    SwitchBg.Position = UDim2.new(1, -52, 0.5, -12)
    SwitchBg.BackgroundColor3 = default and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(70, 70, 70)
    SwitchBg.Text = ""
    SwitchBg.Parent = ToggleFrame
    Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 20, 0, 20)
    Knob.Position = default and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
    Knob.BackgroundColor3 = Color3.new(1,1,1)
    Knob.Parent = SwitchBg
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local enabled = default
    local function updateVisual()
        SwitchBg.BackgroundColor3 = enabled and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(70, 70, 70)
        Knob.Position = enabled and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
    end

    SwitchBg.MouseButton1Click:Connect(function()
        enabled = not enabled
        updateVisual()
        callback(enabled)
    end)

    return ToggleFrame
end

-- FOV Section
local FOVSection = Instance.new("Frame")
FOVSection.Size = UDim2.new(1, -10, 0, 38)
FOVSection.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
FOVSection.Parent = ScrollingFrame
Instance.new("UICorner", FOVSection).CornerRadius = UDim.new(0, 8)

local fovLabel = Instance.new("TextLabel")
fovLabel.Size = UDim2.new(0.35, 0, 1, 0)
fovLabel.Position = UDim2.new(0, 8, 0, 0)
fovLabel.BackgroundTransparency = 1
fovLabel.Text = "FOV: " .. Aimbot.FOV
fovLabel.TextColor3 = Color3.new(1,1,1)
fovLabel.Font = Enum.Font.Gotham
fovLabel.TextSize = 13
fovLabel.TextXAlignment = Enum.TextXAlignment.Left
fovLabel.Parent = FOVSection

local fovMinus = Instance.new("TextButton")
fovMinus.Size = UDim2.new(0, 26, 0, 26)
fovMinus.Position = UDim2.new(1, -78, 0.5, -13)
fovMinus.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
fovMinus.Text = "-"
fovMinus.TextColor3 = Color3.new(1,1,1)
fovMinus.Font = Enum.Font.GothamBold
fovMinus.TextSize = 16
fovMinus.Parent = FOVSection
Instance.new("UICorner", fovMinus).CornerRadius = UDim.new(0, 6)

local fovPlus = Instance.new("TextButton")
fovPlus.Size = UDim2.new(0, 26, 0, 26)
fovPlus.Position = UDim2.new(1, -32, 0.5, -13)
fovPlus.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
fovPlus.Text = "+"
fovPlus.TextColor3 = Color3.new(1,1,1)
fovPlus.Font = Enum.Font.GothamBold
fovPlus.TextSize = 16
fovPlus.Parent = FOVSection
Instance.new("UICorner", fovPlus).CornerRadius = UDim.new(0, 6)

local function adjustFOV(delta)
    Aimbot.FOV = math.clamp(Aimbot.FOV + delta, 30, 500)
    fovLabel.Text = "FOV: " .. Aimbot.FOV
end
fovMinus.MouseButton1Click:Connect(function() adjustFOV(-10) end)
fovPlus.MouseButton1Click:Connect(function() adjustFOV(10) end)

-- Thêm các toggle
CreateToggleSwitch("ESP Master", true, function(v) ESP.Enabled = v end)
CreateToggleSwitch("Box", true, function(v) ESP.Box = v end)
CreateToggleSwitch("Drip Box", true, function(v) ESP.DripStyle = v end)
CreateToggleSwitch("Line", true, function(v) ESP.Line = v end)
CreateToggleSwitch("Name", true, function(v) ESP.Name = v end)
CreateToggleSwitch("Health Bar", true, function(v) ESP.HealthBar = v end)
CreateToggleSwitch("Team Color", true, function(v) ESP.TeamColor = v end)
CreateToggleSwitch("Max Distance", true, function(v) ESP.MaxDistance = v and 800 or 99999 end)

-- Separator
local Separator = Instance.new("Frame")
Separator.Size = UDim2.new(1, -10, 0, 2)
Separator.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
Separator.BorderSizePixel = 0
Separator.Parent = ScrollingFrame

CreateToggleSwitch("🎯 Aimbot", false, function(v) Aimbot.Enabled = v end)
CreateToggleSwitch("🔫 Silent Aim", false, function(v) SilentAim.Enabled = v end)

-- ================== KÉO RỘNG MENU ==================
local ResizeHandle = Instance.new("Frame")
ResizeHandle.Size = UDim2.new(0, 16, 0, 16)
ResizeHandle.Position = UDim2.new(1, -8, 1, -8)
ResizeHandle.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
ResizeHandle.BorderSizePixel = 0
ResizeHandle.ZIndex = 10
ResizeHandle.Parent = MainMenuFrame
Instance.new("UICorner", ResizeHandle).CornerRadius = UDim.new(0, 4)

local resizing = false
ResizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizing = true
        input.UserInputState = Enum.UserInputState.Began
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
        local newWidth = math.clamp(MainMenuFrame.AbsoluteSize.X + input.Delta.X, 220, 500)
        local newHeight = math.clamp(MainMenuFrame.AbsoluteSize.Y + input.Delta.Y, 300, 700)
        MainMenuFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizing = false
    end
end)

-- Kéo menu
local dragging, dragInput, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainMenuFrame.Position
    end
end)
TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        MainMenuFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ================== HIỆU ỨNG ĐÓNG/MỞ ==================
CloseButton.MouseButton1Click:Connect(function()
    MenuVisible = false
    MainMenuFrame.Visible = false
    ToggleButton.Visible = true
end)
ToggleButton.MouseButton1Click:Connect(function()
    MenuVisible = true
    MainMenuFrame.Visible = true
    ToggleButton.Visible = false
end)

-- ================== DRAWING ==================
FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 64
FOVCircle.Radius = Aimbot.FOV
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Transparency = 0.7
FOVCircle.Filled = false
FOVCircle.Visible = true

-- ================== ESP BOX FUNCTIONS ==================
local function CreateBoxLines(count)
    local lines = {}
    for i = 1, count do
        local line = Drawing.new("Line")
        line.Thickness = 2
        line.Transparency = 1
        table.insert(lines, line)
    end
    return lines
end

-- Drip Box Path
local function GetDripPath(tl, tr, br, bl, radius, dripH)
    local points = {}
    local innerTL = tl + Vector2.new(radius, radius)
    local innerTR = tr + Vector2.new(-radius, radius)
    local innerBR = br + Vector2.new(-radius, -radius)
    local innerBL = bl + Vector2.new(radius, -radius)

    local dripTL = tl + Vector2.new(0, -dripH)
    local dripTR = tr + Vector2.new(0, -dripH)

    -- dripTL -> innerTL (Bezier)
    local cp1 = dripTL + Vector2.new(0, radius * 0.7)
    for i = 0, 10 do
        local t = i / 10
        local x = (1-t)^2 * dripTL.X + 2*(1-t)*t * cp1.X + t^2 * innerTL.X
        local y = (1-t)^2 * dripTL.Y + 2*(1-t)*t * cp1.Y + t^2 * innerTL.Y
        table.insert(points, Vector2.new(x, y))
    end

    -- innerTL -> innerTR (straight)
    table.insert(points, innerTR)

    -- innerTR -> dripTR (Bezier)
    local cp2 = dripTR + Vector2.new(0, radius * 0.7)
    for i = 1, 10 do
        local t = i / 10
        local x = (1-t)^2 * innerTR.X + 2*(1-t)*t * cp2.X + t^2 * dripTR.X
        local y = (1-t)^2 * innerTR.Y + 2*(1-t)*t * cp2.Y + t^2 * dripTR.Y
        table.insert(points, Vector2.new(x, y))
    end

    -- dripTR -> innerBR (Bezier)
    local cp3 = innerTR + Vector2.new(radius * 1.2, 0)
    for i = 1, 10 do
        local t = i / 10
        local x = (1-t)^2 * dripTR.X + 2*(1-t)*t * cp3.X + t^2 * innerBR.X
        local y = (1-t)^2 * dripTR.Y + 2*(1-t)*t * cp3.Y + t^2 * innerBR.Y
        table.insert(points, Vector2.new(x, y))
    end

    -- innerBR -> innerBL (cung dưới)
    for i = 1, 10 do
        local angle = math.pi * (i / 10)
        local x = innerBR.X + radius + math.cos(angle) * radius
        local y = innerBR.Y + math.sin(angle) * radius
        table.insert(points, Vector2.new(x, y))
    end

    -- innerBL -> dripTL (Bezier)
    local cp4 = innerBL + Vector2.new(-radius * 0.5, -radius * 0.3)
    for i = 1, 10 do
        local t = i / 10
        local x = (1-t)^2 * innerBL.X + 2*(1-t)*t * cp4.X + t^2 * dripTL.X
        local y = (1-t)^2 * innerBL.Y + 2*(1-t)*t * cp4.Y + t^2 * dripTL.Y
        table.insert(points, Vector2.new(x, y))
    end

    return points
end

-- Rounded Box Path
local function GetRoundedPath(tl, tr, br, bl, radius)
    local points = {}
    local innerTL = tl + Vector2.new(radius, radius)
    local innerTR = tr + Vector2.new(-radius, radius)
    local innerBR = br + Vector2.new(-radius, -radius)
    local innerBL = bl + Vector2.new(radius, -radius)

    table.insert(points, innerTL)
    table.insert(points, innerTR)

    for i = 1, 8 do
        local angle = -math.pi/2 * (i / 8)
        local x = innerTR.X + math.cos(angle) * radius
        local y = innerTR.Y + math.sin(angle) * radius
        table.insert(points, Vector2.new(x, y))
    end

    table.insert(points, innerBR)

    for i = 1, 8 do
        local angle = math.pi/2 * (i / 8)
        local x = innerBR.X + math.cos(angle) * radius
        local y = innerBR.Y + math.sin(angle) * radius
        table.insert(points, Vector2.new(x, y))
    end

    table.insert(points, innerBL)

    for i = 1, 8 do
        local angle = math.pi + math.pi/2 * (i / 8)
        local x = innerBL.X + math.cos(angle) * radius
        local y = innerBL.Y + math.sin(angle) * radius
        table.insert(points, Vector2.new(x, y))
    end

    return points
end

-- ================== ESP FUNCTIONS ==================
local function ClearESP(plr)
    if ESPConnections[plr] then
        for _, conn in ipairs(ESPConnections[plr].Connections) do
            conn:Disconnect()
        end
        for _, drawing in ipairs(ESPConnections[plr].Drawings) do
            drawing:Remove()
        end
        ESPConnections[plr] = nil
    end
end

local function AddESP(plr)
    if plr == LocalPlayer then return end
    ClearESP(plr)

    local drawings = {}
    local connections = {}

    -- Box lines (max 80)
    local boxLines = CreateBoxLines(80)
    for _, l in ipairs(boxLines) do table.insert(drawings, l) end

    -- Line
    local lineDraw = Drawing.new("Line")
    lineDraw.Thickness = 2
    lineDraw.Transparency = 1
    table.insert(drawings, lineDraw)

    -- Name
    local nameDraw = Drawing.new("Text")
    nameDraw.Size = 15
    nameDraw.Center = true
    nameDraw.Outline = true
    nameDraw.Transparency = 1
    table.insert(drawings, nameDraw)

    -- Health Bar
    local hpBg = Drawing.new("Line")
    hpBg.Thickness = 3
    hpBg.Transparency = 1
    table.insert(drawings, hpBg)

    local hpFill = Drawing.new("Line")
    hpFill.Thickness = 3
    hpFill.Transparency = 1
    table.insert(drawings, hpFill)

    local function Update()
        local character = plr.Character
        if not ESP.Enabled or not character or not character:FindFirstChild("HumanoidRootPart") then
            for _, d in ipairs(drawings) do d.Visible = false end
            return
        end

        local root = character.HumanoidRootPart
        local head = character:FindFirstChild("Head")
        local humanoid = character:FindFirstChild("Humanoid")
        if not head or not humanoid then
            for _, d in ipairs(drawings) do d.Visible = false end
            return
        end

        local distance = (Camera.CFrame.Position - root.Position).Magnitude
        if distance > ESP.MaxDistance then
            for _, d in ipairs(drawings) do d.Visible = false end
            return
        end

        local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then
            for _, d in ipairs(drawings) do d.Visible = false end
            return
        end

        local headPos = Camera:WorldToViewportPoint(head.Position)
        local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))

        local boxHeight = math.abs(headPos.Y - legPos.Y) * 1.4
        local boxWidth = boxHeight / 2

        local tl = Vector2.new(rootPos.X - boxWidth/2, headPos.Y - boxHeight/2)
        local tr = Vector2.new(rootPos.X + boxWidth/2, headPos.Y - boxHeight/2)
        local br = Vector2.new(rootPos.X + boxWidth/2, legPos.Y + boxHeight/4)
        local bl = Vector2.new(rootPos.X - boxWidth/2, legPos.Y + boxHeight/4)

        local color = ESP.TeamColor and (plr.Team and plr.Team.TeamColor.Color or Color3.fromRGB(255, 0, 0)) or Color3.fromRGB(255, 0, 0)

        -- Box
        if ESP.Box then
            local points
            if ESP.DripStyle then
                points = GetDripPath(tl, tr, br, bl, ESP.BoxRadius, ESP.DripHeight)
            else
                points = GetRoundedPath(tl, tr, br, bl, ESP.BoxRadius)
            end

            for i = 1, #points - 1 do
                if boxLines[i] then
                    boxLines[i].From = points[i]
                    boxLines[i].To = points[i + 1]
                    boxLines[i].Color = color
                    boxLines[i].Visible = true
                end
            end
            for i = #points, #boxLines do
                if boxLines[i] then boxLines[i].Visible = false end
            end
        else
            for _, l in ipairs(boxLines) do l.Visible = false end
        end

        -- Line
        if ESP.Line then
            lineDraw.Visible = true
            lineDraw.Color = color
            lineDraw.From = Vector2.new(Camera.ViewportSize.X / 2, 0)
            lineDraw.To = Vector2.new(rootPos.X, rootPos.Y)
        else
            lineDraw.Visible = false
        end

        -- Name
        if ESP.Name then
            nameDraw.Visible = true
            nameDraw.Text = plr.Name .. " [" .. math.floor(humanoid.Health) .. "]"
            nameDraw.Position = Vector2.new(rootPos.X, headPos.Y - 25)
            nameDraw.Color = color
        else
            nameDraw.Visible = false
        end

        -- Health Bar
        if ESP.HealthBar then
            local barX = tl.X - 7
            local barTop = tl.Y
            local barBottom = bl.Y
            local hpPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)

            hpBg.Visible = true
            hpBg.From = Vector2.new(barX, barTop)
            hpBg.To = Vector2.new(barX, barBottom)
            hpBg.Color = Color3.fromRGB(30, 30, 30)

            hpFill.Visible = true
            hpFill.From = Vector2.new(barX, barBottom - (barBottom - barTop) * hpPercent)
            hpFill.To = Vector2.new(barX, barBottom)
            if hpPercent > 0.6 then
                hpFill.Color = Color3.fromRGB(0, 255, 100)
            elseif hpPercent > 0.3 then
                hpFill.Color = Color3.fromRGB(255, 200, 0)
            else
                hpFill.Color = Color3.fromRGB(255, 50, 50)
            end
        else
            hpBg.Visible = false
            hpFill.Visible = false
        end
    end

    local conn = RunService.RenderStepped:Connect(Update)
    table.insert(connections, conn)

    ESPConnections[plr] = {
        Drawings = drawings,
        Connections = connections
    }
end

-- ================== AIMBOT FUNCTIONS ==================
local function GetClosestPlayer()
    local closest, dist = nil, Aimbot.FOV
    local mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            local headPos, onScreen = Camera:WorldToViewportPoint(plr.Character.Head.Position)
            if onScreen then
                local screenPos = Vector2.new(headPos.X, headPos.Y)
                local mag = (screenPos - mousePos).Magnitude
                if mag < dist then
                    dist = mag
                    closest = plr
                end
            end
        end
    end
    return closest
end

-- ================== INIT ==================
for _, plr in ipairs(Players:GetPlayers()) do
    AddESP(plr)
end
Players.PlayerAdded:Connect(AddESP)
Players.PlayerRemoving:Connect(ClearESP)

-- Player Count Update
RunService.RenderStepped:Connect(function()
    local count = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            count = count + 1
        end
    end
    PlayerCountLabel.Text = "👥 Players: " .. count
end)

-- Aimbot Loop
RunService.RenderStepped:Connect(function()
    if Aimbot.Enabled then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local targetPos = Camera:WorldToViewportPoint(target.Character.Head.Position)
            local mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            local direction = (Vector2.new(targetPos.X, targetPos.Y) - mousePos) * Aimbot.Smoothness
            mousemoverel(direction.X, direction.Y)
        end
    end
end)

-- Silent Aim Hook
local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldNamecall = mt.__namecall
mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if method == "FireServer" and SilentAim.Enabled then
        local nameLower = self.Name:lower()
        if nameLower:find("bullet") or nameLower:find("shoot") or nameLower:find("fire") then
            local target = GetClosestPlayer()
            if target and target.Character and target.Character:FindFirstChild("Head") then
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool") then
                    args[1] = target.Character.Head.Position + Vector3.new(0, 0.1, 0)
                end
            end
        end
    end
    return oldNamecall(self, unpack(args))
end)
setreadonly(mt, true)

-- FOV Circle
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Radius = Aimbot.FOV
    FOVCircle.Visible = true
end)

print("✅ ESP Hub loaded! Menu dọc, kéo rộng, Drip Box, Health Bar, Aimbot, Silent Aim")