-- // ESP Menu Drip Box - Đơn giản, Sạch, Không lỗi
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- ================== CONFIG ==================
local ESP = {
    Enabled = true,
    Box = true,
    DripBox = true,
    Line = true,
    Name = true,
    HealthBar = true,
    TeamColor = true,
    BoxRadius = 8,
    DripHeight = 10,
    MaxDistance = 800
}

-- ================== GUI ==================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ESP_Menu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main Frame
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 240, 0, 400)
Frame.Position = UDim2.new(0, 20, 0.5, -200)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Frame.BorderSizePixel = 0
Frame.Visible = true
Frame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 12)
FrameCorner.Parent = Frame

local FrameStroke = Instance.new("UIStroke")
FrameStroke.Thickness = 1.5
FrameStroke.Color = Color3.fromRGB(0, 180, 255)
FrameStroke.Transparency = 0.3
FrameStroke.Parent = Frame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
TitleBar.Parent = Frame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 180, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 100, 200))
}
TitleGradient.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "🔥 ESP Menu"
TitleLabel.TextColor3 = Color3.new(1, 1, 1)
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
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 16
CloseButton.ZIndex = 6
CloseButton.Parent = Frame
Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(1, 0)

-- Toggle Button (khi đóng menu)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0, 20, 0.5, -25)
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ToggleButton.Text = "ESP"
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 14
ToggleButton.Visible = false
ToggleButton.ZIndex = 10
ToggleButton.Parent = ScreenGui
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", ToggleButton).Color = Color3.fromRGB(0, 180, 255)

-- Player Count
local PlayerCountLabel = Instance.new("TextLabel")
PlayerCountLabel.Size = UDim2.new(1, -20, 0, 22)
PlayerCountLabel.Position = UDim2.new(0, 10, 0, 50)
PlayerCountLabel.BackgroundTransparency = 1
PlayerCountLabel.Text = "👥 Players: 0"
PlayerCountLabel.TextColor3 = Color3.fromRGB(180, 220, 255)
PlayerCountLabel.Font = Enum.Font.Gotham
PlayerCountLabel.TextSize = 12
PlayerCountLabel.TextXAlignment = Enum.TextXAlignment.Left
PlayerCountLabel.Parent = Frame

-- Scrolling Frame
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -10, 1, -80)
ScrollingFrame.Position = UDim2.new(0, 5, 0, 75)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.ScrollBarThickness = 4
ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 180, 255)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.Parent = Frame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollingFrame

UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end)

-- Toggle Switch Function
local function CreateToggle(text, default, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -10, 0, 36)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    ToggleFrame.Parent = ScrollingFrame
    Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 8)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.55, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.new(1, 1, 1)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame

    local SwitchBg = Instance.new("TextButton")
    SwitchBg.Size = UDim2.new(0, 40, 0, 22)
    SwitchBg.Position = UDim2.new(1, -48, 0.5, -11)
    SwitchBg.BackgroundColor3 = default and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(70, 70, 70)
    SwitchBg.Text = ""
    SwitchBg.Parent = ToggleFrame
    Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 18, 0, 18)
    Knob.Position = default and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    Knob.BackgroundColor3 = Color3.new(1, 1, 1)
    Knob.Parent = SwitchBg
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local enabled = default
    local function updateVisual()
        SwitchBg.BackgroundColor3 = enabled and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(70, 70, 70)
        Knob.Position = enabled and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    end

    SwitchBg.MouseButton1Click:Connect(function()
        enabled = not enabled
        updateVisual()
        callback(enabled)
    end)

    return ToggleFrame
end

-- Add Toggles
CreateToggle("ESP Master", true, function(v) ESP.Enabled = v end)
CreateToggle("Box", true, function(v) ESP.Box = v end)
CreateToggle("Drip Box", true, function(v) ESP.DripBox = v end)
CreateToggle("Line", true, function(v) ESP.Line = v end)
CreateToggle("Name", true, function(v) ESP.Name = v end)
CreateToggle("Health Bar", true, function(v) ESP.HealthBar = v end)
CreateToggle("Team Color", true, function(v) ESP.TeamColor = v end)
CreateToggle("Max Distance", true, function(v) ESP.MaxDistance = v and 800 or 99999 end)

-- Draggable Menu
local dragging, dragInput, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position
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
        Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

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

-- Đóng/Mở Menu
CloseButton.MouseButton1Click:Connect(function()
    Frame.Visible = false
    ToggleButton.Visible = true
end)
ToggleButton.MouseButton1Click:Connect(function()
    Frame.Visible = true
    ToggleButton.Visible = false
end)

-- ================== DRAWING - ESP BOX ==================
-- Tạo bộ line cho 1 box
local function CreateBoxLines()
    local lines = {}
    for i = 1, 60 do
        local line = Drawing.new("Line")
        line.Thickness = 2
        line.Transparency = 1
        line.Visible = false
        table.insert(lines, line)
    end
    return lines
end

-- Drip Box Path
local function GetDripPath(tl, tr, br, bl, radius, dripH)
    local pts = {}
    local innerTL = tl + Vector2.new(radius, radius)
    local innerTR = tr + Vector2.new(-radius, radius)
    local innerBR = br + Vector2.new(-radius, -radius)
    local innerBL = bl + Vector2.new(radius, -radius)
    local dripTL = tl + Vector2.new(0, -dripH)
    local dripTR = tr + Vector2.new(0, -dripH)
    local seg = 8

    -- dripTL -> innerTL
    local cp1 = dripTL + Vector2.new(0, radius * 0.6)
    for i = 0, seg do
        local t = i / seg
        local x = (1-t)^2 * dripTL.X + 2*(1-t)*t * cp1.X + t^2 * innerTL.X
        local y = (1-t)^2 * dripTL.Y + 2*(1-t)*t * cp1.Y + t^2 * innerTL.Y
        table.insert(pts, Vector2.new(x, y))
    end
    -- innerTL -> innerTR
    table.insert(pts, innerTR)
    -- innerTR -> dripTR
    local cp2 = dripTR + Vector2.new(0, radius * 0.6)
    for i = 1, seg do
        local t = i / seg
        local x = (1-t)^2 * innerTR.X + 2*(1-t)*t * cp2.X + t^2 * dripTR.X
        local y = (1-t)^2 * innerTR.Y + 2*(1-t)*t * cp2.Y + t^2 * dripTR.Y
        table.insert(pts, Vector2.new(x, y))
    end
    -- dripTR -> innerBR
    local cp3 = innerTR + Vector2.new(radius * 1.2, 0)
    for i = 1, seg do
        local t = i / seg
        local x = (1-t)^2 * dripTR.X + 2*(1-t)*t * cp3.X + t^2 * innerBR.X
        local y = (1-t)^2 * dripTR.Y + 2*(1-t)*t * cp3.Y + t^2 * innerBR.Y
        table.insert(pts, Vector2.new(x, y))
    end
    -- innerBR -> innerBL (cung dưới)
    for i = 1, seg do
        local angle = math.pi * (i / seg)
        local x = innerBR.X + radius + math.cos(angle) * radius
        local y = innerBR.Y + math.sin(angle) * radius
        table.insert(pts, Vector2.new(x, y))
    end
    -- innerBL -> dripTL
    local cp4 = innerBL + Vector2.new(-radius * 0.5, -radius * 0.3)
    for i = 1, seg do
        local t = i / seg
        local x = (1-t)^2 * innerBL.X + 2*(1-t)*t * cp4.X + t^2 * dripTL.X
        local y = (1-t)^2 * innerBL.Y + 2*(1-t)*t * cp4.Y + t^2 * dripTL.Y
        table.insert(pts, Vector2.new(x, y))
    end
    return pts
end

-- Rounded Box Path
local function GetRoundedPath(tl, tr, br, bl, radius)
    local pts = {}
    local innerTL = tl + Vector2.new(radius, radius)
    local innerTR = tr + Vector2.new(-radius, radius)
    local innerBR = br + Vector2.new(-radius, -radius)
    local innerBL = bl + Vector2.new(radius, -radius)
    local seg = 8

    table.insert(pts, innerTL)
    table.insert(pts, innerTR)
    for i = 1, seg do
        local angle = -math.pi/2 * (i / seg)
        local x = innerTR.X + math.cos(angle) * radius
        local y = innerTR.Y + math.sin(angle) * radius
        table.insert(pts, Vector2.new(x, y))
    end
    table.insert(pts, innerBR)
    for i = 1, seg do
        local angle = math.pi/2 * (i / seg)
        local x = innerBR.X + math.cos(angle) * radius
        local y = innerBR.Y + math.sin(angle) * radius
        table.insert(pts, Vector2.new(x, y))
    end
    table.insert(pts, innerBL)
    for i = 1, seg do
        local angle = math.pi + math.pi/2 * (i / seg)
        local x = innerBL.X + math.cos(angle) * radius
        local y = innerBL.Y + math.sin(angle) * radius
        table.insert(pts, Vector2.new(x, y))
    end
    return pts
end

-- ================== ESP LOGIC ==================
local ESPData = {}

local function RemoveESP(plr)
    if ESPData[plr] then
        for _, d in ipairs(ESPData[plr].Drawings) do
            d:Remove()
        end
        ESPData[plr].Connection:Disconnect()
        ESPData[plr] = nil
    end
end

local function AddESP(plr)
    if plr == LocalPlayer then return end
    RemoveESP(plr)

    local drawings = {}
    local boxLines = CreateBoxLines()
    for _, l in ipairs(boxLines) do table.insert(drawings, l) end

    local lineDraw = Drawing.new("Line")
    lineDraw.Thickness = 2
    lineDraw.Transparency = 1
    lineDraw.Visible = false
    table.insert(drawings, lineDraw)

    local nameDraw = Drawing.new("Text")
    nameDraw.Size = 15
    nameDraw.Center = true
    nameDraw.Outline = true
    nameDraw.Transparency = 1
    nameDraw.Visible = false
    table.insert(drawings, nameDraw)

    local hpBg = Drawing.new("Line")
    hpBg.Thickness = 3
    hpBg.Transparency = 1
    hpBg.Visible = false
    table.insert(drawings, hpBg)

    local hpFill = Drawing.new("Line")
    hpFill.Thickness = 3
    hpFill.Transparency = 1
    hpFill.Visible = false
    table.insert(drawings, hpFill)

    local function Update()
        local char = plr.Character
        if not ESP.Enabled or not char or not char:FindFirstChild("HumanoidRootPart") then
            for _, d in ipairs(drawings) do d.Visible = false end
            return
        end

        local root = char.HumanoidRootPart
        local head = char:FindFirstChild("Head")
        local humanoid = char:FindFirstChild("Humanoid")
        if not head or not humanoid then
            for _, d in ipairs(drawings) do d.Visible = false end
            return
        end

        local dist = (Camera.CFrame.Position - root.Position).Magnitude
        if dist > ESP.MaxDistance then
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

        local boxH = math.abs(headPos.Y - legPos.Y) * 1.4
        local boxW = boxH / 2

        local tl = Vector2.new(rootPos.X - boxW/2, headPos.Y - boxH/2)
        local tr = Vector2.new(rootPos.X + boxW/2, headPos.Y - boxH/2)
        local br = Vector2.new(rootPos.X + boxW/2, legPos.Y + boxH/4)
        local bl = Vector2.new(rootPos.X - boxW/2, legPos.Y + boxH/4)

        local color = ESP.TeamColor and (plr.Team and plr.Team.TeamColor.Color or Color3.fromRGB(255, 0, 0)) or Color3.fromRGB(255, 0, 0)

        -- Box
        if ESP.Box then
            local pts
            if ESP.DripBox then
                pts = GetDripPath(tl, tr, br, bl, ESP.BoxRadius, ESP.DripHeight)
            else
                pts = GetRoundedPath(tl, tr, br, bl, ESP.BoxRadius)
            end
            for i = 1, #pts - 1 do
                if boxLines[i] then
                    boxLines[i].From = pts[i]
                    boxLines[i].To = pts[i + 1]
                    boxLines[i].Color = color
                    boxLines[i].Visible = true
                end
            end
            for i = #pts, #boxLines do
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
    ESPData[plr] = { Drawings = drawings, Connection = conn }
end

-- ================== INIT ==================
for _, plr in ipairs(Players:GetPlayers()) do
    AddESP(plr)
end
Players.PlayerAdded:Connect(AddESP)
Players.PlayerRemoving:Connect(RemoveESP)

-- Player Count
RunService.RenderStepped:Connect(function()
    local count = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            count = count + 1
        end
    end
    PlayerCountLabel.Text = "👥 Players: " .. count
end)

print("✅ ESP Menu loaded! Menu dọc, Drip Box, Health Bar, Line, Name - Sạch không lỗi")