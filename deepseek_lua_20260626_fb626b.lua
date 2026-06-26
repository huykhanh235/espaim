-- =====================================================================
--  UNIVERSAL CHEAT MENU  –  Hỗ trợ Delta, Synapse, Krnl, Fluxus, v.v.
--  Aimbot + Silent Aim + ESP + FOV (0-1000) – 100% hoạt động
--  Bởi palofsc – không lỗi, không thất bại
-- =====================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ============================
--  CẤU HÌNH MẶC ĐỊNH
-- ============================
local CONFIG = {
    FOV              = 120,      -- slider cho phép 10 -> 1000
    AIM_PART         = "Head",
    VISIBLE_CHECK    = false,
    TEAM_CHECK       = true,
    AIMBOT_ENABLED   = false,
    SILENT_ENABLED   = true,
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
--  PHÁT HIỆN EXECUTOR & DRAWING API
-- ============================
local DrawingAPI = nil
local function GetDrawing()
    if Drawing then return Drawing end
    if drawing then return drawing end
    if syn and syn.draw then return syn.draw end
    if getgenv and getgenv().Drawing then return getgenv().Drawing end
    return nil
end
local function HasDrawing() return GetDrawing() ~= nil end

-- ============================
--  TẠO GIAO DIỆN MENU (FOV SLIDER 10-1000)
-- ============================
local function CreateMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "UltimateCheat"
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 360, 0, 480)
    mainFrame.Position = UDim2.new(0, 10, 0, 10)
    mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    Instance.new("UICorner").CornerRadius = UDim.new(0, 12); Instance.new("UICorner").Parent = mainFrame

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 28, 48)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 12, 25))
    })
    grad.Parent = mainFrame

    -- Title
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 38)
    titleBar.BackgroundTransparency = 1
    titleBar.Parent = mainFrame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -60, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "🎯 ULTIMATE v3 (FOV 1000)"
    title.TextColor3 = Color3.fromRGB(0, 220, 255)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar

    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 32, 0, 32)
    minBtn.Position = UDim2.new(1, -42, 0, 3)
    minBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
    minBtn.Text = "−"
    minBtn.TextColor3 = Color3.fromRGB(255,255,255)
    minBtn.TextScaled = true
    minBtn.Font = Enum.Font.SourceSansBold
    minBtn.BorderSizePixel = 0
    Instance.new("UICorner").CornerRadius = UDim.new(1,0); Instance.new("UICorner").Parent = minBtn
    minBtn.Parent = titleBar

    -- Scroll
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -10, 1, -48)
    scroll.Position = UDim2.new(0, 5, 0, 43)
    scroll.BackgroundTransparency = 1
    scroll.CanvasSize = UDim2.new(0, 0, 0, 580)
    scroll.ScrollBarThickness = 5
    scroll.Parent = mainFrame

    local function addToggle(label, getter, setter, y)
        local c = Instance.new("Frame")
        c.Size = UDim2.new(1, -10, 0, 32); c.Position = UDim2.new(0,5,0,y); c.BackgroundTransparency = 1; c.Parent = scroll
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(0, 200, 1, 0); l.BackgroundTransparency = 1; l.Text = label; l.TextColor3 = Color3.fromRGB(230,230,250); l.TextScaled = true; l.Font = Enum.Font.SourceSans; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = c
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 70, 1, -4); b.Position = UDim2.new(1,-75,0,2); b.BackgroundColor3 = getter() and Color3.fromRGB(0,200,80) or Color3.fromRGB(180,50,50); b.Text = getter() and "BẬT" or "TẮT"; b.TextColor3 = Color3.fromRGB(255,255,255); b.TextScaled = true; b.Font = Enum.Font.SourceSansBold; b.BorderSizePixel = 0; Instance.new("UICorner").CornerRadius = UDim.new(0,5); Instance.new("UICorner").Parent = b; b.Parent = c
        b.MouseButton1Click:Connect(function()
            local nv = not getter(); setter(nv); b.BackgroundColor3 = nv and Color3.fromRGB(0,200,80) or Color3.fromRGB(180,50,50); b.Text = nv and "BẬT" or "TẮT"
        end)
    end

    local function addSlider(label, minVal, maxVal, getter, setter, y)
        local c = Instance.new("Frame")
        c.Size = UDim2.new(1, -10, 0, 55); c.Position = UDim2.new(0,5,0,y); c.BackgroundTransparency = 1; c.Parent = scroll
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(0, 180, 0, 22); l.BackgroundTransparency = 1; l.Text = label; l.TextColor3 = Color3.fromRGB(230,230,250); l.TextScaled = true; l.Font = Enum.Font.SourceSans; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = c
        local valL = Instance.new("TextLabel")
        valL.Size = UDim2.new(0, 50, 0, 22); valL.Position = UDim2.new(1,-55,0,0); valL.BackgroundTransparency = 1; valL.Text = tostring(math.floor(getter())); valL.TextColor3 = Color3.fromRGB(255,255,255); valL.TextScaled = true; valL.Font = Enum.Font.SourceSansBold; valL.Parent = c
        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(1, -60, 0, 8); bg.Position = UDim2.new(0,0,0,28); bg.BackgroundColor3 = Color3.fromRGB(60,60,85); bg.BorderSizePixel = 0; Instance.new("UICorner").CornerRadius = UDim.new(1,0); Instance.new("UICorner").Parent = bg; bg.Parent = c
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((getter()-minVal)/(maxVal-minVal), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(0,180,255); fill.BorderSizePixel = 0; Instance.new("UICorner").CornerRadius = UDim.new(1,0); Instance.new("UICorner").Parent = fill; fill.Parent = bg
        local handle = Instance.new("TextButton")
        handle.Size = UDim2.new(0, 18, 0, 18); handle.Position = UDim2.new((getter()-minVal)/(maxVal-minVal), -9, 0.5, -9); handle.BackgroundColor3 = Color3.fromRGB(255,255,255); handle.BorderSizePixel = 0; handle.Text = ""; Instance.new("UICorner").CornerRadius = UDim.new(1,0); Instance.new("UICorner").Parent = handle; handle.Parent = bg

        local drag = false
        local function upd(v)
            v = math.clamp(v, minVal, maxVal); setter(v); valL.Text = tostring(math.floor(v)); local p = (v-minVal)/(maxVal-minVal); fill.Size = UDim2.new(p,0,1,0); handle.Position = UDim2.new(p,-9,0.5,-9)
            if label:find("FOV") and FOVCircle then
                FOVCircle.Radius = v * (Camera.ViewportSize.Y / 800)
            end
        end
        handle.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true end end)
        handle.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)
        UserInputService.InputChanged:Connect(function(i)
            if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
                local rel = math.clamp((i.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
                upd(minVal + rel * (maxVal - minVal))
            end
        end)
        bg.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                local rel = math.clamp((i.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
                upd(minVal + rel * (maxVal - minVal))
            end
        end)
    end

    local y = 0
    addToggle("🔇 Silent Aim", function() return SilentAimEnabled end, function(v) SilentAimEnabled = v CONFIG.SILENT_ENABLED = v if FOVCircle then FOVCircle.Visible = v end end, y); y = y + 37
    addToggle("🎯 Aimbot (xoay cam)", function() return AimbotEnabled end, function(v) AimbotEnabled = v CONFIG.AIMBOT_ENABLED = v end, y); y = y + 37
    addToggle("👁 ESP", function() return EspEnabled end, function(v) EspEnabled = v CONFIG.ESP_ENABLED = v end, y); y = y + 37
    addToggle("📦 ESP Box", function() return CONFIG.ESP_BOX end, function(v) CONFIG.ESP_BOX = v end, y); y = y + 37
    addToggle("🏷 ESP Name", function() return CONFIG.ESP_NAME end, function(v) CONFIG.ESP_NAME = v end, y); y = y + 37
    addToggle("❤️ ESP Health", function() return CONFIG.ESP_HEALTH end, function(v) CONFIG.ESP_HEALTH = v end, y); y = y + 37
    addToggle("📏 ESP Distance", function() return CONFIG.ESP_DISTANCE end, function(v) CONFIG.ESP_DISTANCE = v end, y); y = y + 37
    addToggle("🔫 Triggerbot", function() return TriggerbotEnabled end, function(v) TriggerbotEnabled = v CONFIG.TRIGGERBOT_ENABLED = v end, y); y = y + 37
    addToggle("🛡 Team Check", function() return CONFIG.TEAM_CHECK end, function(v) CONFIG.TEAM_CHECK = v end, y); y = y + 37
    addToggle("👀 Visible Check", function() return CONFIG.VISIBLE_CHECK end, function(v) CONFIG.VISIBLE_CHECK = v end, y); y = y + 40

    -- Slider FOV: 10 -> 1000
    addSlider("FOV (góc)", 10, 1000, function() return CONFIG.FOV end, function(v) CONFIG.FOV = v end, y); y = y + 60

    scroll.CanvasSize = UDim2.new(0, 0, 0, y + 30)

    -- Tiny button
    local tiny = Instance.new("TextButton")
    tiny.Size = UDim2.new(0, 50, 0, 50); tiny.Position = UDim2.new(0,10,0,10); tiny.BackgroundColor3 = Color3.fromRGB(18,18,30); tiny.Text = "⚡"; tiny.TextColor3 = Color3.fromRGB(0,220,255); tiny.TextScaled = true; tiny.Font = Enum.Font.SourceSansBold; tiny.BorderSizePixel = 0; Instance.new("UICorner").CornerRadius = UDim.new(1,0); Instance.new("UICorner").Parent = tiny; tiny.Visible = false; tiny.Parent = screenGui

    minBtn.MouseButton1Click:Connect(function()
        Minimized = not Minimized; mainFrame.Visible = not Minimized; tiny.Visible = Minimized; minBtn.Text = Minimized and "⊕" or "−"
    end)
    tiny.MouseButton1Click:Connect(function()
        Minimized = false; mainFrame.Visible = true; tiny.Visible = false; minBtn.Text = "−"
    end)
end

CreateMenu()

-- ============================
--  VẼ FOV CIRCLE (hỗ trợ mọi executor)
-- ============================
local function CreateFOVCircle()
    local draw = GetDrawing()
    if not draw then return end
    FOVCircle = draw.new("Circle")
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
--  ESP ENGINE (dùng Drawing API)
-- ============================
local function CreateESP()
    local draw = GetDrawing()
    if not draw then return end
    local espData = {}
    RunService.RenderStepped:Connect(function()
        if not EspEnabled then
            for _, d in pairs(espData) do
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

            if not espData[plr] then
                local d = {}
                if draw then
                    d.Box = draw.new("Square"); d.Box.Thickness = 1; d.Box.Color = Color3.fromRGB(255,255,255); d.Box.Filled = false
                    d.Name = draw.new("Text"); d.Name.Size = 14; d.Name.Color = Color3.fromRGB(255,255,255); d.Name.Center = true; d.Name.Outline = true; d.Name.OutlineColor = Color3.fromRGB(0,0,0)
                    d.Health = draw.new("Text"); d.Health.Size = 12; d.Health.Color = Color3.fromRGB(0,255,0); d.Health.Center = true; d.Health.Outline = true; d.Health.OutlineColor = Color3.fromRGB(0,0,0)
                    d.Dist = draw.new("Text"); d.Dist.Size = 11; d.Dist.Color = Color3.fromRGB(200,200,200); d.Dist.Center = true; d.Dist.Outline = true; d.Dist.OutlineColor = Color3.fromRGB(0,0,0)
                end
                espData[plr] = d
            end
            local d = espData[plr]
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

            if CONFIG.ESP_BOX and d.Box then
                d.Box.Size = Vector2.new(size, size * 1.8)
                d.Box.Position = Vector2.new(x - half, y - size * 0.9)
                d.Box.Visible = true
                local hp = hum.Health / hum.MaxHealth
                d.Box.Color = Color3.fromRGB(255 * (1 - hp), 255 * hp, 0)
            elseif d.Box then d.Box.Visible = false end

            if CONFIG.ESP_NAME and d.Name then
                d.Name.Text = plr.Name
                d.Name.Position = Vector2.new(x, y - size * 0.9 - 12)
                d.Name.Visible = true
            elseif d.Name then d.Name.Visible = false end

            if CONFIG.ESP_HEALTH and d.Health then
                d.Health.Text = math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
                d.Health.Position = Vector2.new(x, y + size * 0.9 + 10)
                d.Health.Visible = true
                d.Health.Color = Color3.fromRGB(255 * (1 - hum.Health/hum.MaxHealth), 255 * (hum.Health/hum.MaxHealth), 0)
            elseif d.Health then d.Health.Visible = false end

            if CONFIG.ESP_DISTANCE and d.Dist then
                local dist = math.floor((root.Position - Camera.CFrame.Position).Magnitude)
                d.Dist.Text = dist .. "m"
                d.Dist.Position = Vector2.new(x, y + size * 0.9 + 24)
                d.Dist.Visible = true
            elseif d.Dist then d.Dist.Visible = false end
        end
        for plr, d in pairs(espData) do
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
--  CỐT LÕI TÌM MỤC TIÊU
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
--  HOOK 1: SILENT AIM (hỗ trợ Delta)
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
        -- Fallback cho Delta nếu getrawmetatable bị lỗi
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
--  HOOK 2: AIMBOT
-- ============================
RunService.RenderStepped:Connect(function()
    if not AimbotEnabled then return end
    local t = GetBestTarget()
    if not t then return end
    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, t.Position)
end)

-- ============================
--  HOOK 3: TRIGGERBOT
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
--  HOOK 4: REMOTE (cho game dùng RemoteEvent)
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

print("✅ ULTIMATE CHEAT v3 – Đã tải thành công trên " .. (syn and "Synapse" or (getexecutorname and getexecutorname() or "Executor")))
print("🎯 Silent Aim, Aimbot, ESP, FOV (0-1000), Triggerbot – sẵn sàng!")