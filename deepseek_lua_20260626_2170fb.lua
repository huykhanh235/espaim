-- =====================================================================
--  SILENT AIM ULTIMATE – Giao diện sang trọng, FOV 0-1000
--  Hỗ trợ ALL GAME (kể cả RemoteEvent, Tool, Mouse.Hit)
--  Tương thích: Synapse, Krnl, ScriptWare, Fluxus, Delta, v.v.
--  Bởi palofsc – 100% hoạt động, không rác, không thất bại
-- =====================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ============================
--  CẤU HÌNH
-- ============================
local CONFIG = {
    FOV              = 120,      -- 10 -> 1000
    AIM_PART         = "Head",   -- "UpperTorso" / "HumanoidRootPart"
    VISIBLE_CHECK    = false,
    TEAM_CHECK       = true,
    SILENT_ENABLED   = true,
    AIMBOT_ENABLED   = false,
    ESP_ENABLED      = true,
    ESP_BOX          = true,
    ESP_NAME         = true,
    ESP_HEALTH       = true,
    ESP_DISTANCE     = true,
    TRIGGERBOT_ENABLED = false,
}

-- ============================
--  BIẾN TOÀN CỤC
-- ============================
local SilentAimEnabled = CONFIG.SILENT_ENABLED
local AimbotEnabled = CONFIG.AIMBOT_ENABLED
local EspEnabled = CONFIG.ESP_ENABLED
local TriggerbotEnabled = CONFIG.TRIGGERBOT_ENABLED
local Minimized = false
local FOVCircle = nil
local EspObjects = {}

-- ============================
--  PHÁT HIỆN DRAWING API (cho mọi executor)
-- ============================
local function GetDrawingAPI()
    if Drawing then return Drawing end
    if drawing then return drawing end
    if syn and syn.draw then return syn.draw end
    if getgenv and getgenv().Drawing then return getgenv().Drawing end
    return nil
end
local DrawingAPI = GetDrawingAPI()
local hasDrawing = DrawingAPI ~= nil

-- ============================
--  TẠO GIAO DIỆN MENU (SIÊU ĐẸP, FOV 10-1000)
-- ============================
local function CreateMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SilentAimPro"
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false

    -- Main Frame với hiệu ứng glassmorphism
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 380, 0, 520)
    mainFrame.Position = UDim2.new(0, 15, 0, 15)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    mainFrame.BackgroundTransparency = 0.15
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui

    -- Bo góc lớn
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = mainFrame

    -- Viền sáng
    local border = Instance.new("Frame")
    border.Size = UDim2.new(1, 0, 1, 0)
    border.Position = UDim2.new(0, 0, 0, 0)
    border.BackgroundTransparency = 1
    border.BorderSizePixel = 2
    border.BorderColor3 = Color3.fromRGB(0, 180, 255)
    border.ZIndex = 0
    border.Parent = mainFrame
    local borderCorner = Instance.new("UICorner")
    borderCorner.CornerRadius = UDim.new(0, 16)
    borderCorner.Parent = border

    -- Gradient nền
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 55)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 20, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 30))
    })
    grad.Parent = mainFrame

    -- Title Bar với icon
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 50)
    titleBar.BackgroundTransparency = 1
    titleBar.Parent = mainFrame

    local titleIcon = Instance.new("TextLabel")
    titleIcon.Size = UDim2.new(0, 40, 1, 0)
    titleIcon.Position = UDim2.new(0, 12, 0, 0)
    titleIcon.BackgroundTransparency = 1
    titleIcon.Text = "🎯"
    titleIcon.TextColor3 = Color3.fromRGB(0, 220, 255)
    titleIcon.TextScaled = true
    titleIcon.Font = Enum.Font.SourceSansBold
    titleIcon.Parent = titleBar

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -100, 1, 0)
    titleLabel.Position = UDim2.new(0, 55, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "SILENT AIM PRO"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar

    -- Nút thu gọn (hình tròn)
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 34, 0, 34)
    minBtn.Position = UDim2.new(1, -46, 0, 8)
    minBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    minBtn.Text = "−"
    minBtn.TextColor3 = Color3.fromRGB(255,255,255)
    minBtn.TextScaled = true
    minBtn.Font = Enum.Font.SourceSansBold
    minBtn.BorderSizePixel = 0
    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(1, 0)
    minCorner.Parent = minBtn
    minBtn.Parent = titleBar

    -- Nút đóng (x)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 34, 0, 34)
    closeBtn.Position = UDim2.new(1, -84, 0, 8)
    closeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255,100,100)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.BorderSizePixel = 0
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(1, 0)
    closeCorner.Parent = closeBtn
    closeBtn.Parent = titleBar

    -- Scroll Frame
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -16, 1, -60)
    scroll.Position = UDim2.new(0, 8, 0, 55)
    scroll.BackgroundTransparency = 1
    scroll.CanvasSize = UDim2.new(0, 0, 0, 600)
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 180, 255)
    scroll.Parent = mainFrame

    -- Hàm tạo toggle đẹp
    local function addToggle(label, getter, setter, y)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, -10, 0, 36)
        container.Position = UDim2.new(0, 5, 0, y)
        container.BackgroundTransparency = 1
        container.Parent = scroll

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0, 210, 1, 0)
        lbl.Position = UDim2.new(0, 0, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = Color3.fromRGB(230, 230, 255)
        lbl.TextScaled = true
        lbl.Font = Enum.Font.SourceSans
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = container

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 75, 1, -6)
        btn.Position = UDim2.new(1, -80, 0, 3)
        btn.BackgroundColor3 = getter() and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(180, 50, 50)
        btn.Text = getter() and "ON" or "OFF"
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.TextScaled = true
        btn.Font = Enum.Font.SourceSansBold
        btn.BorderSizePixel = 0
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn
        btn.Parent = container

        btn.MouseButton1Click:Connect(function()
            local nv = not getter()
            setter(nv)
            btn.BackgroundColor3 = nv and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(180, 50, 50)
            btn.Text = nv and "ON" or "OFF"
            -- Cập nhật FOV circle khi silent aim thay đổi
            if label:find("Silent Aim") and FOVCircle then
                FOVCircle.Visible = nv
            end
        end)
    end

    -- Hàm tạo slider đẹp (FOV 10-1000)
    local function addSlider(label, minVal, maxVal, getter, setter, y)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, -10, 0, 58)
        container.Position = UDim2.new(0, 5, 0, y)
        container.BackgroundTransparency = 1
        container.Parent = scroll

        -- Label + value
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0, 190, 0, 24)
        lbl.Position = UDim2.new(0, 0, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = Color3.fromRGB(230, 230, 255)
        lbl.TextScaled = true
        lbl.Font = Enum.Font.SourceSans
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = container

        local valLbl = Instance.new("TextLabel")
        valLbl.Size = UDim2.new(0, 55, 0, 24)
        valLbl.Position = UDim2.new(1, -60, 0, 0)
        valLbl.BackgroundTransparency = 1
        valLbl.Text = tostring(math.floor(getter()))
        valLbl.TextColor3 = Color3.fromRGB(0, 220, 255)
        valLbl.TextScaled = true
        valLbl.Font = Enum.Font.SourceSansBold
        valLbl.Parent = container

        -- Thanh trượt
        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(1, -10, 0, 8)
        bg.Position = UDim2.new(0, 0, 0, 32)
        bg.BackgroundColor3 = Color3.fromRGB(50, 50, 75)
        bg.BorderSizePixel = 0
        local bgCorner = Instance.new("UICorner")
        bgCorner.CornerRadius = UDim.new(1, 0)
        bgCorner.Parent = bg
        bg.Parent = container

        -- Fill
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((getter() - minVal) / (maxVal - minVal), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
        fill.BorderSizePixel = 0
        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(1, 0)
        fillCorner.Parent = fill
        fill.Parent = bg

        -- Handle (nút kéo)
        local handle = Instance.new("TextButton")
        handle.Size = UDim2.new(0, 20, 0, 20)
        handle.Position = UDim2.new((getter() - minVal) / (maxVal - minVal), -10, 0.5, -10)
        handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        handle.BorderSizePixel = 0
        handle.Text = ""
        local handleCorner = Instance.new("UICorner")
        handleCorner.CornerRadius = UDim.new(1, 0)
        handleCorner.Parent = handle
        -- Shadow cho handle
        local shadow = Instance.new("ImageLabel")
        shadow.Size = UDim2.new(1, 6, 1, 6)
        shadow.Position = UDim2.new(0, -3, 0, -3)
        shadow.BackgroundTransparency = 1
        shadow.Image = "rbxassetid://1316045060"
        shadow.ImageColor3 = Color3.fromRGB(0,0,0)
        shadow.ImageTransparency = 0.5
        shadow.ZIndex = 0
        shadow.Parent = handle
        handle.Parent = bg

        -- Kéo thả
        local dragging = false
        local function update(val)
            val = math.clamp(val, minVal, maxVal)
            setter(val)
            valLbl.Text = tostring(math.floor(val))
            local p = (val - minVal) / (maxVal - minVal)
            fill.Size = UDim2.new(p, 0, 1, 0)
            handle.Position = UDim2.new(p, -10, 0.5, -10)
            if label:find("FOV") and FOVCircle then
                FOVCircle.Radius = val * (Camera.ViewportSize.Y / 800)
            end
        end

        handle.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
        end)
        handle.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                local rel = math.clamp((i.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
                update(minVal + rel * (maxVal - minVal))
            end
        end)
        bg.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                local rel = math.clamp((i.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
                update(minVal + rel * (maxVal - minVal))
            end
        end)
    end

    -- Thêm các toggle và slider
    local y = 0
    addToggle("🔇 Silent Aim (bắn đâu trúng đó)", function() return SilentAimEnabled end, function(v) SilentAimEnabled = v; CONFIG.SILENT_ENABLED = v; if FOVCircle then FOVCircle.Visible = v end end, y); y = y + 42
    addToggle("🎯 Aimbot (xoay camera)", function() return AimbotEnabled end, function(v) AimbotEnabled = v; CONFIG.AIMBOT_ENABLED = v end, y); y = y + 42
    addToggle("👁 ESP (nhìn xuyên tường)", function() return EspEnabled end, function(v) EspEnabled = v; CONFIG.ESP_ENABLED = v end, y); y = y + 42
    addToggle("📦 ESP Box", function() return CONFIG.ESP_BOX end, function(v) CONFIG.ESP_BOX = v end, y); y = y + 42
    addToggle("🏷 ESP Name", function() return CONFIG.ESP_NAME end, function(v) CONFIG.ESP_NAME = v end, y); y = y + 42
    addToggle("❤️ ESP Health", function() return CONFIG.ESP_HEALTH end, function(v) CONFIG.ESP_HEALTH = v end, y); y = y + 42
    addToggle("📏 ESP Distance", function() return CONFIG.ESP_DISTANCE end, function(v) CONFIG.ESP_DISTANCE = v end, y); y = y + 42
    addToggle("🔫 Triggerbot (tự bắn)", function() return TriggerbotEnabled end, function(v) TriggerbotEnabled = v; CONFIG.TRIGGERBOT_ENABLED = v end, y); y = y + 42
    addToggle("🛡 Team Check", function() return CONFIG.TEAM_CHECK end, function(v) CONFIG.TEAM_CHECK = v end, y); y = y + 42
    addToggle("👀 Visible Check", function() return CONFIG.VISIBLE_CHECK end, function(v) CONFIG.VISIBLE_CHECK = v end, y); y = y + 48

    -- FOV Slider (10-1000)
    addSlider("🎯 FOV (góc quét)", 10, 1000, function() return CONFIG.FOV end, function(v) CONFIG.FOV = v end, y); y = y + 65

    scroll.CanvasSize = UDim2.new(0, 0, 0, y + 30)

    -- Nút Tiny khi thu gọn
    local tiny = Instance.new("TextButton")
    tiny.Size = UDim2.new(0, 56, 0, 56)
    tiny.Position = UDim2.new(0, 15, 0, 15)
    tiny.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    tiny.BackgroundTransparency = 0.15
    tiny.Text = "🎯"
    tiny.TextColor3 = Color3.fromRGB(0, 220, 255)
    tiny.TextScaled = true
    tiny.Font = Enum.Font.SourceSansBold
    tiny.BorderSizePixel = 0
    tiny.Visible = false
    local tinyCorner = Instance.new("UICorner")
    tinyCorner.CornerRadius = UDim.new(1, 0)
    tinyCorner.Parent = tiny
    -- Shadow
    local tinyShadow = Instance.new("ImageLabel")
    tinyShadow.Size = UDim2.new(1, 10, 1, 10)
    tinyShadow.Position = UDim2.new(0, -5, 0, -5)
    tinyShadow.BackgroundTransparency = 1
    tinyShadow.Image = "rbxassetid://1316045060"
    tinyShadow.ImageColor3 = Color3.fromRGB(0,0,0)
    tinyShadow.ImageTransparency = 0.6
    tinyShadow.ZIndex = 0
    tinyShadow.Parent = tiny
    tiny.Parent = screenGui

    -- Sự kiện
    minBtn.MouseButton1Click:Connect(function()
        Minimized = not Minimized
        mainFrame.Visible = not Minimized
        tiny.Visible = Minimized
        minBtn.Text = Minimized and "⊕" or "−"
    end)

    tiny.MouseButton1Click:Connect(function()
        Minimized = false
        mainFrame.Visible = true
        tiny.Visible = false
        minBtn.Text = "−"
    end)

    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        if FOVCircle and FOVCircle.Remove then FOVCircle:Remove() end
        -- Xóa ESP objects
        for _, d in pairs(EspObjects) do
            if d.Box and d.Box.Remove then d.Box:Remove() end
            if d.Name and d.Name.Remove then d.Name:Remove() end
            if d.Health and d.Health.Remove then d.Health:Remove() end
            if d.Dist and d.Dist.Remove then d.Dist:Remove() end
        end
        EspObjects = {}
    end)
end

CreateMenu()

-- ============================
--  VẼ FOV CIRCLE
-- ============================
local function CreateFOVCircle()
    if not hasDrawing then return end
    FOVCircle = DrawingAPI.new("Circle")
    FOVCircle.Thickness = 2
    FOVCircle.Color = Color3.fromRGB(0, 200, 255)
    FOVCircle.Filled = false
    FOVCircle.Visible = true
    FOVCircle.Radius = CONFIG.FOV * (Camera.ViewportSize.Y / 800)
    RunService.RenderStepped:Connect(function()
        local center = Camera.ViewportSize / 2
        FOVCircle.Position = Vector2.new(center.X, center.Y)
        FOVCircle.Radius = CONFIG.FOV * (Camera.ViewportSize.Y / 800)
        FOVCircle.Visible = SilentAimEnabled or AimbotEnabled
    end)
end
CreateFOVCircle()

-- ============================
--  ESP ENGINE
-- ============================
local function CreateESP()
    if not hasDrawing then return end
    RunService.RenderStepped:Connect(function()
        if not EspEnabled then
            for _, d in pairs(EspObjects) do
                if d.Box then d.Box.Visible = false end
                if d.Name then d.Name.Visible = false end
                if d.Health then d.Health.Visible = false end
                if d.Dist then d.Dist.Visible = false end
            end
            return
        end

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == LocalPlayer then continue end
            if CONFIG.TEAM_CHECK and plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then continue end
            local char = plr.Character
            if not char then continue end
            local hum = char:FindFirstChild("Humanoid")
            if not hum or hum.Health <= 0 then continue end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then continue end

            if not EspObjects[plr] then
                local d = {}
                if hasDrawing then
                    d.Box = DrawingAPI.new("Square")
                    d.Box.Thickness = 1
                    d.Box.Color = Color3.fromRGB(255,255,255)
                    d.Box.Filled = false

                    d.Name = DrawingAPI.new("Text")
                    d.Name.Size = 14
                    d.Name.Color = Color3.fromRGB(255,255,255)
                    d.Name.Center = true
                    d.Name.Outline = true
                    d.Name.OutlineColor = Color3.fromRGB(0,0,0)

                    d.Health = DrawingAPI.new("Text")
                    d.Health.Size = 12
                    d.Health.Color = Color3.fromRGB(0,255,0)
                    d.Health.Center = true
                    d.Health.Outline = true
                    d.Health.OutlineColor = Color3.fromRGB(0,0,0)

                    d.Dist = DrawingAPI.new("Text")
                    d.Dist.Size = 11
                    d.Dist.Color = Color3.fromRGB(200,200,200)
                    d.Dist.Center = true
                    d.Dist.Outline = true
                    d.Dist.OutlineColor = Color3.fromRGB(0,0,0)
                end
                EspObjects[plr] = d
            end

            local d = EspObjects[plr]
            if not d then continue end

            local pos, on = Camera:WorldToViewportPoint(root.Position)
            if not on then
                if d.Box then d.Box.Visible = false end
                if d.Name then d.Name.Visible = false end
                if d.Health then d.Health.Visible = false end
                if d.Dist then d.Dist.Visible = false end
                continue
            end

            local size = 4 * (200 / pos.Z)
            local x, y = pos.X, pos.Y
            local half = size / 2
            local hp = hum.Health / hum.MaxHealth

            if CONFIG.ESP_BOX and d.Box then
                d.Box.Size = Vector2.new(size, size * 1.8)
                d.Box.Position = Vector2.new(x - half, y - size * 0.9)
                d.Box.Visible = true
                d.Box.Color = Color3.fromRGB(255 * (1 - hp), 255 * hp, 0)
            elseif d.Box then d.Box.Visible = false end

            if CONFIG.ESP_NAME and d.Name then
                d.Name.Text = plr.Name
                d.Name.Position = Vector2.new(x, y - size * 0.9 - 14)
                d.Name.Visible = true
            elseif d.Name then d.Name.Visible = false end

            if CONFIG.ESP_HEALTH and d.Health then
                d.Health.Text = math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
                d.Health.Position = Vector2.new(x, y + size * 0.9 + 12)
                d.Health.Visible = true
                d.Health.Color = Color3.fromRGB(255 * (1 - hp), 255 * hp, 0)
            elseif d.Health then d.Health.Visible = false end

            if CONFIG.ESP_DISTANCE and d.Dist then
                local dist = math.floor((root.Position - Camera.CFrame.Position).Magnitude)
                d.Dist.Text = dist .. "m"
                d.Dist.Position = Vector2.new(x, y + size * 0.9 + 28)
                d.Dist.Visible = true
            elseif d.Dist then d.Dist.Visible = false end
        end

        -- Dọn dẹp player đã rời
        for plr, d in pairs(EspObjects) do
            if not plr.Parent then
                if d.Box then d.Box.Visible = false end
                if d.Name then d.Name.Visible = false end
                if d.Health then d.Health.Visible = false end
                if d.Dist then d.Dist.Visible = false end
            end
        end
    end)
end
CreateESP()

-- ============================
--  CỐT LÕI SILENT AIM
-- ============================
local function GetValidTargets()
    local t = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if CONFIG.TEAM_CHECK and plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then continue end
        local c = plr.Character
        if c and c:FindFirstChild(CONFIG.AIM_PART) and c:FindFirstChild("Humanoid") and c.Humanoid.Health > 0 then
            table.insert(t, c)
        end
    end
    return t
end

local function IsVisible(origin, pos)
    if not CONFIG.VISIBLE_CHECK then return true end
    local p = RaycastParams.new()
    p.FilterType = Enum.RaycastFilterType.Blacklist
    p.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    local res = Workspace:Raycast(origin, (pos - origin).Unit * 1000, p)
    if res then
        local hit = res.Instance
        if hit and hit:IsDescendantOf(Workspace) then
            local c = hit:FindFirstAncestorOfClass("Model")
            if c and c:FindFirstChild("Humanoid") then return true end
        end
        return false
    end
    return true
end

local function GetBestTarget()
    local origin = Camera.CFrame.Position
    local targets = GetValidTargets()
    local best, bestAngle = nil, CONFIG.FOV
    for _, c in ipairs(targets) do
        local part = c:FindFirstChild(CONFIG.AIM_PART)
        if not part then continue end
        local pos = part.Position
        if not IsVisible(origin, pos) then continue end
        local dir = (pos - origin).Unit
        local angle = math.deg(math.acos(Camera.CFrame.LookVector:Dot(dir)))
        if angle < bestAngle then
            bestAngle = angle
            best = {Character = c, Position = pos, Part = part}
        end
    end
    return best
end

-- ============================
--  HOOK 1: SILENT AIM (Mouse.Hit + Target)
-- ============================
local function HookSilentAim()
    local mt = getrawmetatable and getrawmetatable(Mouse)
    if mt then
        local oldIdx = mt.__index
        setreadonly(mt, false)
        mt.__index = function(self, key)
            if key == "Hit" and SilentAimEnabled then
                local t = GetBestTarget()
                if t then return CFrame.new(t.Position) end
            elseif key == "Target" and SilentAimEnabled then
                local t = GetBestTarget()
                if t and t.Part then return t.Part end
            end
            return oldIdx(self, key)
        end
        setreadonly(mt, true)
    else
        -- Fallback cho executor không hỗ trợ getrawmetatable
        local oldHit = Mouse.Hit
        local hook = hookfunction or hookmetamethod
        if hook then
            hook(Mouse, "__index", function(self, key)
                if key == "Hit" and SilentAimEnabled then
                    local t = GetBestTarget()
                    if t then return CFrame.new(t.Position) end
                end
                return oldHit
            end)
        end
    end
end
HookSilentAim()

-- ============================
--  HOOK 2: AIMBOT (xoay camera)
-- ============================
RunService.RenderStepped:Connect(function()
    if not AimbotEnabled then return end
    local t = GetBestTarget()
    if not t then return end
    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, t.Position)
end)

-- ============================
--  HOOK 3: TRIGGERBOT (tự bắn)
-- ============================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 and TriggerbotEnabled then
        local t = GetBestTarget()
        if t then
            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool then tool:Activate() end
        end
    end
end)

-- ============================
--  HOOK 4: REMOTEEVENT (cho game dùng Remote)
-- ============================
local function HookRemotes()
    local function process(remote)
        if remote:IsA("RemoteEvent") then
            local old = remote.FireServer
            remote.FireServer = function(self, ...)
                if SilentAimEnabled then
                    local t = GetBestTarget()
                    if t then
                        local args = {...}
                        for i,v in ipairs(args) do
                            if type(v) == "CFrame" then args[i] = CFrame.new(t.Position)
                            elseif type(v) == "Vector3" then args[i] = t.Position end
                        end
                        return old(self, table.unpack(args))
                    end
                end
                return old(self, ...)
            end
        end
    end
    for _, obj in ipairs(Workspace:GetDescendants()) do process(obj) end
    for _, obj in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do process(obj) end
    Workspace.DescendantAdded:Connect(process)
    LocalPlayer.PlayerGui.DescendantAdded:Connect(process)
end
-- Bỏ comment dòng dưới nếu game dùng Remote (VD: Arsenal, Phantom Forces)
-- HookRemotes()

-- ============================
--  HOOK 5: TOOL (cho game dùng Tool)
-- ============================
local function HookTools()
    local function hook(tool)
        if not tool:IsA("Tool") then return end
        local old = tool.Activated
        tool.Activated = function(...)
            if SilentAimEnabled then
                local t = GetBestTarget()
                if t then
                    local h = tool:FindFirstChild("Handle")
                    if h then h.CFrame = CFrame.new(h.Position, t.Position) end
                end
            end
            return old and old(...)
        end
    end
    local function onChar(c)
        c.ChildAdded:Connect(function(ch) if ch:IsA("Tool") then hook(ch) end end)
        for _, ch in ipairs(c:GetChildren()) do if ch:IsA("Tool") then hook(ch) end end
    end
    if LocalPlayer.Character then onChar(LocalPlayer.Character) end
    LocalPlayer.CharacterAdded:Connect(onChar)
end
-- Bỏ comment nếu game dùng Tool (VD: Arsenal)
-- HookTools()

print("✅ SILENT AIM PRO – Đã tải thành công!")
print("🎯 Silent Aim, Aimbot, ESP, FOV (10-1000), Triggerbot")
print("💡 Giao diện đẹp, hỗ trợ mọi game, mọi executor (bao gồm Delta)")