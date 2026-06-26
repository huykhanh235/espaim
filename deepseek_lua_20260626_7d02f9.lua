-- // ESP + Aimbot + Silent Aim + FOV (Menu ngang, Drip Box, Health Bar)
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
    TeamColor = true,
    HealthBar = true,          -- Hiển thị thanh máu
    DripStyle = true,          -- Box giọt nước
    DripHeight = 12,           -- Độ nhô giọt nước
    BoxRadius = 10,
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

-- ================== GUI ==================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ESP_Menu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Nút tròn khi menu ẩn
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0, 20, 0.5, -25)
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ToggleButton.Text = "ESP"
ToggleButton.TextColor3 = Color3.new(1,1,1)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 14
ToggleButton.Visible = false
ToggleButton.Parent = ScreenGui
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(1,0)
Instance.new("UIStroke", ToggleButton).Color = Color3.fromRGB(0, 180, 255)

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

-- ================== MENU NGANG ==================
local MainMenuFrame = Instance.new("Frame")
MainMenuFrame.Size = UDim2.new(0, 680, 0, 50)
MainMenuFrame.Position = UDim2.new(0, 20, 0.5, -25)
MainMenuFrame.AnchorPoint = Vector2.new(0, 0.5)
MainMenuFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainMenuFrame.BorderSizePixel = 0
MainMenuFrame.ClipsDescendants = true
MainMenuFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainMenuFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 1.5
UIStroke.Color = Color3.fromRGB(0, 180, 255)
UIStroke.Transparency = 0.3
UIStroke.Parent = MainMenuFrame

local MenuContent = Instance.new("Frame")
MenuContent.Size = UDim2.new(1, 0, 1, 0)
MenuContent.BackgroundTransparency = 1
MenuContent.Parent = MainMenuFrame

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(0, 8, 0.5, -15)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.new(1,1,1)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 16
CloseButton.Parent = MenuContent
Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(1,0)

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -50, 1, 0)
ScrollingFrame.Position = UDim2.new(0, 45, 0, 0)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.ScrollBarThickness = 3
ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 180, 255)
ScrollingFrame.ScrollingDirection = Enum.ScrollingDirection.X
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.Parent = MenuContent

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.FillDirection = Enum.FillDirection.Horizontal
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollingFrame

UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollingFrame.CanvasSize = UDim2.new(0, UIListLayout.AbsoluteContentSize.X + 10, 0, 0)
end)

-- Toggle Switch
local function CreateToggleSwitch(name, default, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(0, 90, 0, 40)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = ScrollingFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 40, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.new(1,1,1)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame

    local SwitchBg = Instance.new("TextButton")
    SwitchBg.Size = UDim2.new(0, 40, 0, 20)
    SwitchBg.Position = UDim2.new(0, 45, 0.5, -10)
    SwitchBg.BackgroundColor3 = default and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(80, 80, 80)
    SwitchBg.Text = ""
    SwitchBg.Parent = ToggleFrame
    Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    Knob.BackgroundColor3 = Color3.new(1,1,1)
    Knob.Parent = SwitchBg
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local enabled = default
    local function updateVisual()
        SwitchBg.BackgroundColor3 = enabled and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(80, 80, 80)
        Knob.Position = enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    end

    SwitchBg.MouseButton1Click:Connect(function()
        enabled = not enabled
        updateVisual()
        callback(enabled)
    end)
    return ToggleFrame
end

-- FOV điều chỉnh
local FOVFrame = Instance.new("Frame")
FOVFrame.Size = UDim2.new(0, 110, 0, 40)
FOVFrame.BackgroundTransparency = 1
FOVFrame.Parent = ScrollingFrame

local fovLabel = Instance.new("TextLabel")
fovLabel.Size = UDim2.new(0, 40, 1, 0)
fovLabel.BackgroundTransparency = 1
fovLabel.Text = "FOV: " .. Aimbot.FOV
fovLabel.TextColor3 = Color3.new(1,1,1)
fovLabel.Font = Enum.Font.Gotham
fovLabel.TextSize = 11
fovLabel.Parent = FOVFrame

local fovMinus = Instance.new("TextButton")
fovMinus.Size = UDim2.new(0, 22, 0, 22)
fovMinus.Position = UDim2.new(0, 45, 0.5, -11)
fovMinus.BackgroundColor3 = Color3.fromRGB(60,60,60)
fovMinus.Text = "-"
fovMinus.TextColor3 = Color3.new(1,1,1)
fovMinus.Font = Enum.Font.GothamBold
fovMinus.TextSize = 14
fovMinus.Parent = FOVFrame
Instance.new("UICorner", fovMinus).CornerRadius = UDim.new(0, 5)

local fovPlus = Instance.new("TextButton")
fovPlus.Size = UDim2.new(0, 22, 0, 22)
fovPlus.Position = UDim2.new(0, 72, 0.5, -11)
fovPlus.BackgroundColor3 = Color3.fromRGB(60,60,60)
fovPlus.Text = "+"
fovPlus.TextColor3 = Color3.new(1,1,1)
fovPlus.Font = Enum.Font.GothamBold
fovPlus.TextSize = 14
fovPlus.Parent = FOVFrame
Instance.new("UICorner", fovPlus).CornerRadius = UDim.new(0, 5)

local function adjustFOV(delta)
    Aimbot.FOV = math.clamp(Aimbot.FOV + delta, 30, 500)
    fovLabel.Text = "FOV: " .. Aimbot.FOV
end
fovMinus.MouseButton1Click:Connect(function() adjustFOV(-10) end)
fovPlus.MouseButton1Click:Connect(function() adjustFOV(10) end)

-- Player Count
local PlayerCountLabel = Instance.new("TextLabel")
PlayerCountLabel.Size = UDim2.new(0, 70, 0, 40)
PlayerCountLabel.BackgroundTransparency = 1
PlayerCountLabel.Text = "Players: 0"
PlayerCountLabel.TextColor3 = Color3.fromRGB(180, 220, 255)
PlayerCountLabel.Font = Enum.Font.Gotham
PlayerCountLabel.TextSize = 11
PlayerCountLabel.Parent = ScrollingFrame

-- Thêm toggles
CreateToggleSwitch("ESP", true, function(v) ESP.Enabled = v end)
CreateToggleSwitch("Box", true, function(v) ESP.Box = v end)
CreateToggleSwitch("Line", true, function(v) ESP.Line = v end)
CreateToggleSwitch("Name", true, function(v) ESP.Name = v end)
CreateToggleSwitch("Team", true, function(v) ESP.TeamColor = v end)
CreateToggleSwitch("Aimbot", false, function(v) Aimbot.Enabled = v end)
CreateToggleSwitch("Silent", false, function(v) SilentAim.Enabled = v end)
CreateToggleSwitch("Dist", true, function(v) ESP.MaxDistance = v and 800 or 99999 end)
CreateToggleSwitch("Drip", true, function(v) ESP.DripStyle = v end)
CreateToggleSwitch("HPBar", true, function(v) ESP.HealthBar = v end)

-- ================== HIỆU ỨNG TWEEN ==================
local tweenOpen, tweenClose
local function setupTweens()
    local openSize = UDim2.new(0, 680, 0, 50)
    local closeSize = UDim2.new(0, 0, 0, 50)
    local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    tweenOpen = TweenService:Create(MainMenuFrame, tweenInfo, {Size = openSize})
    tweenClose = TweenService:Create(MainMenuFrame, tweenInfo, {Size = closeSize})
end
setupTweens()

local function openMenu()
    MenuVisible = true
    ToggleButton.Visible = false
    MainMenuFrame.Visible = true
    tweenOpen:Play()
end

local function closeMenu()
    MenuVisible = false
    tweenClose:Play()
    tweenClose.Completed:Wait()
    MainMenuFrame.Visible = false
    ToggleButton.Visible = true
end

CloseButton.MouseButton1Click:Connect(function() if MenuVisible then closeMenu() end end)
ToggleButton.MouseButton1Click:Connect(function() if not MenuVisible then openMenu() end end)

MainMenuFrame.Size = UDim2.new(0, 680, 0, 50)
MainMenuFrame.Visible = true

-- Kéo menu
local draggingMenu, dragInputMenu, dragStartMenu, startPosMenu
MainMenuFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingMenu = true
        dragStartMenu = input.Position
        startPosMenu = MainMenuFrame.Position
    end
end)
MainMenuFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInputMenu = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingMenu and input == dragInputMenu then
        local delta = input.Position - dragStartMenu
        MainMenuFrame.Position = UDim2.new(startPosMenu.X.Scale, startPosMenu.X.Offset + delta.X, startPosMenu.Y.Scale, startPosMenu.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingMenu = false
    end
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

-- Tạo Drip Box (sử dụng nhiều Line để vẽ đường viền cong)
local function CreateDripBox()
    local lines = {}
    -- Số lượng Line đủ để vẽ đường viền mượt (khoảng 120)
    for i = 1, 120 do
        local line = Drawing.new("Line")
        line.Thickness = 2
        line.Transparency = 1
        table.insert(lines, line)
    end
    return lines
end

-- Tính toán các điểm trên đường viền Drip Box
local function GetDripPath(tl, tr, br, bl, radius, dripH)
    local points = {}

    -- Các điểm điều khiển
    local innerTL = tl + Vector2.new(radius, radius)
    local innerTR = tr + Vector2.new(-radius, radius)
    local innerBR = br + Vector2.new(-radius, -radius)
    local innerBL = bl + Vector2.new(radius, -radius)

    local dripTL = tl + Vector2.new(0, -dripH)   -- đỉnh giọt trái
    local dripTR = tr + Vector2.new(0, -dripH)   -- đỉnh giọt phải

    -- 1. Từ dripTL -> innerTL: cong Bezier
    local cp1 = dripTL + Vector2.new(0, radius * 0.8)
    for i = 0, 12 do
        local t = i / 12
        local x = (1-t)^2 * dripTL.X + 2*(1-t)*t * cp1.X + t^2 * innerTL.X
        local y = (1-t)^2 * dripTL.Y + 2*(1-t)*t * cp1.Y + t^2 * innerTL.Y
        table.insert(points, Vector2.new(x, y))
    end

    -- 2. Cạnh trên thẳng: innerTL -> innerTR
    table.insert(points, innerTR)

    -- 3. Từ innerTR -> dripTR: cong lên
    local cp2 = dripTR + Vector2.new(0, radius * 0.8)
    for i = 1, 12 do  -- bắt đầu từ 1 để tránh trùng innerTR
        local t = i / 12
        local x = (1-t)^2 * innerTR.X + 2*(1-t)*t * cp2.X + t^2 * dripTR.X
        local y = (1-t)^2 * innerTR.Y + 2*(1-t)*t * cp2.Y + t^2 * dripTR.Y
        table.insert(points, Vector2.new(x, y))
    end

    -- 4. Từ dripTR -> innerBR: cong xuống bên phải
    local cp3 = innerTR + Vector2.new(radius * 1.2, 0)
    for i = 1, 12 do
        local t = i / 12
        local x = (1-t)^2 * dripTR.X + 2*(1-t)*t * cp3.X + t^2 * innerBR.X
        local y = (1-t)^2 * dripTR.Y + 2*(1-t)*t * cp3.Y + t^2 * innerBR.Y
        table.insert(points, Vector2.new(x, y))
    end

    -- 5. Cung tròn dưới phải: innerBR -> innerBL (tâm innerBR, bán kính radius)
    for i = 1, 12 do
        local angle = math.pi/2 * (i / 12)
        local x = innerBR.X + math.cos(angle) * radius
        local y = innerBR.Y + math.sin(angle) * radius
        table.insert(points, Vector2.new(x, y))
    end

    -- 6. Cạnh dưới thẳng: innerBL -> innerTL? Thực ra innerBL là điểm sau bo góc, ta cần nối lên dripTL qua cung tròn trái và đường cong.
    -- Thay vào đó, từ innerBL bo tròn dưới trái đến innerTL (cũ) rồi cong lên dripTL.
    -- Cung tròn dưới trái: innerBL -> innerTL (tâm innerBL? Không, tâm là innerBL? innerBL là điểm sau khi trừ radius, nên cung tròn sẽ có tâm (bl.X + radius, bl.Y + radius)... Tốt hơn: dùng tâm innerTL cho góc trên trái? Rắc rối.
    -- Tôi sẽ dùng đường cong Bezier từ innerBL lên dripTL trực tiếp.
    local cp4 = innerBL + Vector2.new(-radius * 0.8, -radius * 0.5)
    for i = 1, 12 do
        local t = i / 12
        local x = (1-t)^2 * innerBL.X + 2*(1-t)*t * cp4.X + t^2 * dripTL.X
        local y = (1-t)^2 * innerBL.Y + 2*(1-t)*t * cp4.Y + t^2 * dripTL.Y
        table.insert(points, Vector2.new(x, y))
    end

    return points
end

local function UpdateDripBox(lines, tl, tr, br, bl, radius, dripH, color)
    local points = GetDripPath(tl, tr, br, bl, radius, dripH)
    -- Gán các điểm cho các Line (nối tiếp)
    for i = 1, #points - 1 do
        if lines[i] then
            lines[i].From = points[i]
            lines[i].To = points[i+1]
            lines[i].Color = color
            lines[i].Visible = true
        end
    end
    -- Ẩn các line dư
    for i = #points, #lines do
        if lines[i] then
            lines[i].Visible = false
        end
    end
end

-- Nếu DripStyle tắt, dùng box bo tròn thường (đã có hàm cũ). Tôi sẽ dùng chung một hàm UpdateBox linh hoạt.
local function CreateRoundedBox()
    local lines = {}
    for i = 1, 60 do
        local line = Drawing.new("Line")
        line.Thickness = 2
        line.Transparency = 1
        table.insert(lines, line)
    end
    return lines
end

local function UpdateRoundedBox(lines, tl, tr, br, bl, radius, color)
    local innerTL = tl + Vector2.new(radius, radius)
    local innerTR = tr + Vector2.new(-radius, radius)
    local innerBR = br + Vector2.new(-radius, -radius)
    local innerBL = bl + Vector2.new(radius, -radius)

    local points = {}
    -- Cạnh trên
    table.insert(points, innerTL)
    table.insert(points, innerTR)
    -- Góc phải trên
    for i = 1, 8 do
        local angle = -math.pi/2 * (i / 8)
        local x = innerTR.X + math.cos(angle) * radius
        local y = innerTR.Y + math.sin(angle) * radius
        table.insert(points, Vector2.new(x, y))
    end
    -- Cạnh phải
    table.insert(points, innerBR)
    -- Góc phải dưới
    for i = 1, 8 do
        local angle = math.pi/2 * (i / 8)
        local x = innerBR.X + math.cos(angle) * radius
        local y = innerBR.Y + math.sin(angle) * radius
        table.insert(points, Vector2.new(x, y))
    end
    -- Cạnh dưới
    table.insert(points, innerBL)
    -- Góc trái dưới
    for i = 1, 8 do
        local angle = math.pi + math.pi/2 * (i / 8)
        local x = innerBL.X + math.cos(angle) * radius
        local y = innerBL.Y + math.sin(angle) * radius
        table.insert(points, Vector2.new(x, y))
    end
    -- Cạnh trái
    table.insert(points, innerTL)

    for i = 1, #points - 1 do
        if lines[i] then
            lines[i].From = points[i]
            lines[i].To = points[i+1]
            lines[i].Color = color
            lines[i].Visible = true
        end
    end
    for i = #points, #lines do
        if lines[i] then lines[i].Visible = false end
    end
end

-- ================== ESP & AIMBOT LOGIC ==================
local Connections = {}

local function GetClosestPlayer()
    local closest, dist = nil, Aimbot.FOV
    local mousePos = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            local headPos, onScreen = Camera:WorldToViewportPoint(plr.Character.Head.Position)
            if onScreen then
                local screenPos = Vector2.new(headPos.X, headPos.Y)
                local magnitude = (screenPos - mousePos).Magnitude
                if magnitude < dist then
                    dist = magnitude
                    closest = plr
                end
            end
        end
    end
    return closest
end

local function AddESP(plr)
    if plr == LocalPlayer then return end

    local BoxLines
    if ESP.DripStyle then
        BoxLines = CreateDripBox()
    else
        BoxLines = CreateRoundedBox()
    end

    local Line = Drawing.new("Line")
    Line.Thickness = 2
    Line.Transparency = 1

    local Name = Drawing.new("Text")
    Name.Size = 16
    Name.Center = true
    Name.Outline = true
    Name.Transparency = 1

    -- Health Bar (2 line: nền và máu)
    local HealthBarBg = Drawing.new("Line")
    HealthBarBg.Thickness = 3
    HealthBarBg.Transparency = 1
    local HealthBarFill = Drawing.new("Line")
    HealthBarFill.Thickness = 3
    HealthBarFill.Transparency = 1

    local function Update()
        local character = plr.Character
        if not ESP.Enabled or not character or not character:FindFirstChild("HumanoidRootPart") then
            for _, l in ipairs(BoxLines) do l.Visible = false end
            Line.Visible = false
            Name.Visible = false
            HealthBarBg.Visible = false
            HealthBarFill.Visible = false
            return
        end

        local Root = character.HumanoidRootPart
        local Head = character:FindFirstChild("Head")
        local Humanoid = character:FindFirstChild("Humanoid")
        if not Head or not Humanoid then return end

        local distance = (Camera.CFrame.Position - Root.Position).Magnitude
        if distance > ESP.MaxDistance then
            for _, l in ipairs(BoxLines) do l.Visible = false end
            Line.Visible = false
            Name.Visible = false
            HealthBarBg.Visible = false
            HealthBarFill.Visible = false
            return
        end

        local Vector, OnScreen = Camera:WorldToViewportPoint(Root.Position)
        if not OnScreen then
            for _, l in ipairs(BoxLines) do l.Visible = false end
            Line.Visible = false
            Name.Visible = false
            HealthBarBg.Visible = false
            HealthBarFill.Visible = false
            return
        end

        local HeadPos = Camera:WorldToViewportPoint(Head.Position)
        local LegPos = Camera:WorldToViewportPoint(Root.Position - Vector3.new(0,3,0))

        local BoxHeight = (HeadPos.Y - LegPos.Y) * 1.3
        local BoxWidth = BoxHeight / 2

        local tl = Vector2.new(Vector.X - BoxWidth/2, HeadPos.Y - BoxHeight/2)
        local tr = Vector2.new(Vector.X + BoxWidth/2, HeadPos.Y - BoxHeight/2)
        local br = Vector2.new(Vector.X + BoxWidth/2, HeadPos.Y + BoxHeight/2)
        local bl = Vector2.new(Vector.X - BoxWidth/2, HeadPos.Y + BoxHeight/2)

        local Color = ESP.TeamColor and (plr.Team and plr.Team.TeamColor.Color or Color3.fromRGB(255,0,0)) or Color3.fromRGB(255,0,0)

        if ESP.Box then
            if ESP.DripStyle then
                UpdateDripBox(BoxLines, tl, tr, br, bl, ESP.BoxRadius, ESP.DripHeight, Color)
            else
                UpdateRoundedBox(BoxLines, tl, tr, br, bl, ESP.BoxRadius, Color)
            end
        else
            for _, l in ipairs(BoxLines) do l.Visible = false end
        end

        if ESP.Line then
            Line.Visible = true
            Line.Color = Color
            Line.From = Vector2.new(Camera.ViewportSize.X/2, 0)
            Line.To = Vector2.new(Vector.X, Vector.Y)
        else
            Line.Visible = false
        end

        if ESP.Name then
            Name.Visible = true
            Name.Text = plr.Name .. " [" .. math.floor(Humanoid.Health) .. "]"
            Name.Position = Vector2.new(Vector.X, HeadPos.Y - 30)
            Name.Color = Color
        else
            Name.Visible = false
        end

        -- Health Bar
        if ESP.HealthBar then
            local barX = tl.X - 8
            local barTop = tl.Y
            local barBottom = bl.Y
            local healthPercent = math.clamp(Humanoid.Health / Humanoid.MaxHealth, 0, 1)
            local fillHeight = (barBottom - barTop) * healthPercent

            HealthBarBg.Visible = true
            HealthBarBg.From = Vector2.new(barX, barTop)
            HealthBarBg.To = Vector2.new(barX, barBottom)
            HealthBarBg.Color = Color3.fromRGB(40, 40, 40)

            HealthBarFill.Visible = true
            HealthBarFill.From = Vector2.new(barX, barBottom - fillHeight)
            HealthBarFill.To = Vector2.new(barX, barBottom)
            HealthBarFill.Color = healthPercent > 0.5 and Color3.fromRGB(0, 255, 100) or (healthPercent > 0.25 and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(255, 50, 50))
        else
            HealthBarBg.Visible = false
            HealthBarFill.Visible = false
        end

        -- Aimbot (tự động aim vào đầu)
        if Aimbot.Enabled then
            local target = GetClosestPlayer()
            if target and target.Character and target.Character:FindFirstChild("Head") then
                local targetPos = Camera:WorldToViewportPoint(target.Character.Head.Position)
                local mousePos = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                local direction = (Vector2.new(targetPos.X, targetPos.Y) - mousePos) * Aimbot.Smoothness
                mousemoverel(direction.X, direction.Y)
            end
        end
    end

    table.insert(Connections, RunService.RenderStepped:Connect(Update))
end

-- Thêm ESP cho tất cả người chơi
for _, plr in ipairs(Players:GetPlayers()) do
    AddESP(plr)
end
Players.PlayerAdded:Connect(AddESP)

-- Cập nhật số lượng người chơi
RunService.RenderStepped:Connect(function()
    local count = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            count = count + 1
        end
    end
    PlayerCountLabel.Text = "Players: " .. count
end)

-- Silent Aim (đạn bay vào đầu khi bắn)
local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldNamecall = mt.__namecall
mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if method == "FireServer" and SilentAim.Enabled then
        local nameLower = self.Name:lower()
        if nameLower:find("bullet") or nameLower:find("shoot") then
            local target = GetClosestPlayer()
            if target and target.Character and target.Character:FindFirstChild("Head") then
                -- Kiểm tra xem có đang cầm súng không (tuỳ chọn)
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool") then
                    args[1] = target.Character.Head.Position + Vector3.new(0,0.1,0)
                end
            end
        end
    end
    return oldNamecall(self, unpack(args))
end)
setreadonly(mt, true)

-- FOV Circle Update
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FOVCircle.Radius = Aimbot.FOV
    FOVCircle.Visible = true
end)

print("✅ ESP + Aimbot + Silent Aim + Drip Box + Health Bar đã sẵn sàng!")