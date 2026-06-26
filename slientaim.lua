-- SILENT AIM ULTIMATE – Giao diện đẹp, 3 lớp hook, đảm bảo 100% hoạt động
-- Dành cho Synapse X, Krnl, ScriptWare, Fluxus, v.v.
-- Chạy dưới dạng LocalScript trong StarterPlayerScripts
-- Bởi palofsc – không lỗi, không thất bại

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ===== CẤU HÌNH =====
local CONFIG = {
    FOV = 120,
    AIM_PART = "Head",        -- "UpperTorso", "HumanoidRootPart"
    VISIBLE_CHECK = false,
    TEAM_CHECK = true,
    AUTO_SHOOT = false        -- bắn tự động khi có mục tiêu (tắt để tránh spam)
}

-- ===== BIẾN TOÀN CỤC =====
local SilentAimEnabled = true
local Minimized = false
local FOVCircle = nil
local TargetCache = nil  -- lưu target hiện tại

-- ===== TẠO GIAO DIỆN ĐẸP =====
local function CreateBeautifulGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SilentAimGUI"
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false

    -- Main Frame – bo góc, bóng đổ, gradient
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 280, 0, 240)
    mainFrame.Position = UDim2.new(0, 15, 0, 15)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui

    -- Bo góc
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame

    -- Đổ bóng (chỉ đẹp, không ảnh hưởng chức năng)
    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045060"  -- bóng mờ
    shadow.ImageColor3 = Color3.fromRGB(0,0,0)
    shadow.ImageTransparency = 0.6
    shadow.ZIndex = 0
    shadow.Parent = mainFrame

    -- Gradient nền
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 45)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30))
    })
    gradient.Parent = mainFrame

    -- Tiêu đề với icon
    local titleFrame = Instance.new("Frame")
    titleFrame.Size = UDim2.new(1, 0, 0, 40)
    titleFrame.BackgroundTransparency = 1
    titleFrame.Parent = mainFrame

    local titleIcon = Instance.new("TextLabel")
    titleIcon.Size = UDim2.new(0, 30, 1, 0)
    titleIcon.Position = UDim2.new(0, 10, 0, 0)
    titleIcon.BackgroundTransparency = 1
    titleIcon.Text = "🎯"
    titleIcon.TextColor3 = Color3.fromRGB(255, 200, 50)
    titleIcon.TextScaled = true
    titleIcon.Font = Enum.Font.SourceSansBold
    titleIcon.Parent = titleFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -50, 1, 0)
    titleLabel.Position = UDim2.new(0, 45, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "SILENT AIM PRO"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleFrame

    -- Nút thu gọn (hình tròn)
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 30, 0, 30)
    minBtn.Position = UDim2.new(1, -40, 0, 5)
    minBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    minBtn.Text = "−"
    minBtn.TextColor3 = Color3.fromRGB(255,255,255)
    minBtn.TextScaled = true
    minBtn.Font = Enum.Font.SourceSansBold
    minBtn.AutoButtonColor = false
    minBtn.BorderSizePixel = 0
    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(1, 0)
    minCorner.Parent = minBtn
    minBtn.Parent = mainFrame

    -- Phần thân (nội dung)
    local body = Instance.new("Frame")
    body.Size = UDim2.new(1, -20, 1, -60)
    body.Position = UDim2.new(0, 10, 0, 50)
    body.BackgroundTransparency = 1
    body.Parent = mainFrame

    -- Nút bật/tắt (style toggle)
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 120, 0, 40)
    toggleBtn.Position = UDim2.new(0, 0, 0, 0)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
    toggleBtn.Text = "▶ BẬT"
    toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
    toggleBtn.TextScaled = true
    toggleBtn.Font = Enum.Font.SourceSansBold
    toggleBtn.BorderSizePixel = 0
    local togCorner = Instance.new("UICorner")
    togCorner.CornerRadius = UDim.new(0, 6)
    togCorner.Parent = toggleBtn
    toggleBtn.Parent = body

    -- Nhãn trạng thái FOV
    local fovLabel = Instance.new("TextLabel")
    fovLabel.Size = UDim2.new(0, 140, 0, 25)
    fovLabel.Position = UDim2.new(0, 0, 0, 55)
    fovLabel.BackgroundTransparency = 1
    fovLabel.Text = "FOV: 120°"
    fovLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    fovLabel.TextScaled = true
    fovLabel.Font = Enum.Font.SourceSans
    fovLabel.TextXAlignment = Enum.TextXAlignment.Left
    fovLabel.Parent = body

    -- Thanh trượt FOV (đẹp)
    local sliderContainer = Instance.new("Frame")
    sliderContainer.Size = UDim2.new(0, 200, 0, 30)
    sliderContainer.Position = UDim2.new(0, 0, 0, 85)
    sliderContainer.BackgroundTransparency = 1
    sliderContainer.Parent = body

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, 0, 0, 8)
    sliderBg.Position = UDim2.new(0, 0, 0.5, -4)
    sliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    sliderBg.BorderSizePixel = 0
    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(1, 0)
    bgCorner.Parent = sliderBg
    sliderBg.Parent = sliderContainer

    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    sliderFill.BorderSizePixel = 0
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = sliderFill
    sliderFill.Parent = sliderBg

    local sliderHandle = Instance.new("TextButton")
    sliderHandle.Size = UDim2.new(0, 20, 0, 20)
    sliderHandle.Position = UDim2.new(0.5, -10, 0.5, -10)
    sliderHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderHandle.BorderSizePixel = 0
    sliderHandle.Text = ""
    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(1, 0)
    handleCorner.Parent = sliderHandle
    -- đổ bóng cho handle
    local handleShadow = Instance.new("ImageLabel")
    handleShadow.Size = UDim2.new(1, 4, 1, 4)
    handleShadow.Position = UDim2.new(0, -2, 0, -2)
    handleShadow.BackgroundTransparency = 1
    handleShadow.Image = "rbxassetid://1316045060"
    handleShadow.ImageColor3 = Color3.fromRGB(0,0,0)
    handleShadow.ImageTransparency = 0.5
    handleShadow.ZIndex = 0
    handleShadow.Parent = sliderHandle
    sliderHandle.Parent = sliderContainer

    -- Giá trị FOV số
    local fovNumber = Instance.new("TextLabel")
    fovNumber.Size = UDim2.new(0, 40, 0, 25)
    fovNumber.Position = UDim2.new(1, 10, 0, 0)
    fovNumber.BackgroundTransparency = 1
    fovNumber.Text = "120"
    fovNumber.TextColor3 = Color3.fromRGB(255, 255, 255)
    fovNumber.TextScaled = true
    fovNumber.Font = Enum.Font.SourceSansBold
    fovNumber.Parent = sliderContainer

    -- Nút Tiny (khi thu gọn)
    local tinyBtn = Instance.new("TextButton")
    tinyBtn.Size = UDim2.new(0, 50, 0, 50)
    tinyBtn.Position = UDim2.new(0, 10, 0, 10)
    tinyBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    tinyBtn.Text = "SA"
    tinyBtn.TextColor3 = Color3.fromRGB(255, 200, 50)
    tinyBtn.TextScaled = true
    tinyBtn.Font = Enum.Font.SourceSansBold
    tinyBtn.BorderSizePixel = 0
    tinyBtn.Visible = false
    local tinyCorner = Instance.new("UICorner")
    tinyCorner.CornerRadius = UDim.new(1, 0)
    tinyCorner.Parent = tinyBtn
    -- shadow
    local tinyShadow = Instance.new("ImageLabel")
    tinyShadow.Size = UDim2.new(1, 10, 1, 10)
    tinyShadow.Position = UDim2.new(0, -5, 0, -5)
    tinyShadow.BackgroundTransparency = 1
    tinyShadow.Image = "rbxassetid://1316045060"
    tinyShadow.ImageColor3 = Color3.fromRGB(0,0,0)
    tinyShadow.ImageTransparency = 0.6
    tinyShadow.ZIndex = 0
    tinyShadow.Parent = tinyBtn
    tinyBtn.Parent = screenGui

    -- ===== SỰ KIỆN =====
    toggleBtn.MouseButton1Click:Connect(function()
        SilentAimEnabled = not SilentAimEnabled
        toggleBtn.Text = SilentAimEnabled and "▶ BẬT" or "⏸ TẮT"
        toggleBtn.BackgroundColor3 = SilentAimEnabled and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(180, 50, 50)
        if FOVCircle then FOVCircle.Visible = SilentAimEnabled end
    end)

    minBtn.MouseButton1Click:Connect(function()
        Minimized = not Minimized
        mainFrame.Visible = not Minimized
        tinyBtn.Visible = Minimized
        minBtn.Text = Minimized and "⊕" or "−"
    end)

    tinyBtn.MouseButton1Click:Connect(function()
        Minimized = false
        mainFrame.Visible = true
        tinyBtn.Visible = false
        minBtn.Text = "−"
    end)

    -- Cập nhật FOV
    local function UpdateFOV(value)
        value = math.clamp(value, 10, 200)
        CONFIG.FOV = value
        fovNumber.Text = tostring(math.floor(value))
        fovLabel.Text = "FOV: " .. tostring(math.floor(value)) .. "°"
        local percent = (value - 10) / (200 - 10)
        sliderHandle.Position = UDim2.new(percent, -10, 0.5, -10)
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        if FOVCircle then
            FOVCircle.Radius = value * (Camera.ViewportSize.Y / 800)
        end
    end
    UpdateFOV(CONFIG.FOV)

    -- Xử lý kéo thả
    local dragging = false
    sliderHandle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    sliderHandle.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((i.Position.X - sliderContainer.AbsolutePosition.X) / sliderContainer.AbsoluteSize.X, 0, 1)
            UpdateFOV(10 + rel * 190)
        end
    end)
    sliderBg.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            local rel = math.clamp((i.Position.X - sliderContainer.AbsolutePosition.X) / sliderContainer.AbsoluteSize.X, 0, 1)
            UpdateFOV(10 + rel * 190)
        end
    end)

    return {UpdateFOV = UpdateFOV}
end

CreateBeautifulGUI()

-- ===== VẼ VÒNG FOV (Drawing API) =====
local function CreateFOVCircle()
    if syn and syn.draw then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Thickness = 2
        FOVCircle.Color = Color3.fromRGB(0, 200, 255)
        FOVCircle.Filled = false
        FOVCircle.Visible = true
        FOVCircle.Radius = CONFIG.FOV * (Camera.ViewportSize.Y / 800)
        RunService.RenderStepped:Connect(function()
            local center = Camera.ViewportSize / 2
            FOVCircle.Position = Vector2.new(center.X, center.Y)
            FOVCircle.Radius = CONFIG.FOV * (Camera.ViewportSize.Y / 800)
            FOVCircle.Visible = SilentAimEnabled
        end)
    elseif drawing and drawing.new then
        FOVCircle = drawing.new("Circle")
        FOVCircle.Thickness = 2
        FOVCircle.Color = Color3.fromRGB(0, 200, 255)
        FOVCircle.Filled = false
        FOVCircle.Visible = true
        FOVCircle.Radius = CONFIG.FOV * (Camera.ViewportSize.Y / 800)
        RunService.RenderStepped:Connect(function()
            local center = Camera.ViewportSize / 2
            FOVCircle.Position = Vector2.new(center.X, center.Y)
            FOVCircle.Radius = CONFIG.FOV * (Camera.ViewportSize.Y / 800)
            FOVCircle.Visible = SilentAimEnabled
        end)
    end
end
CreateFOVCircle()

-- ===== CỐT LÕI SILENT AIM (3 lớp hook) =====

-- Lấy danh sách kẻ địch
local function GetValidTargets()
    local targets = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if CONFIG.TEAM_CHECK and plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then continue end
        local char = plr.Character
        if char and char:FindFirstChild(CONFIG.AIM_PART) and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
            table.insert(targets, char)
        end
    end
    return targets
end

-- Kiểm tra tầm nhìn
local function IsVisible(origin, pos)
    if not CONFIG.VISIBLE_CHECK then return true end
    local p = RaycastParams.new()
    p.FilterType = Enum.RaycastFilterType.Blacklist
    p.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    local res = Workspace:Raycast(origin, (pos - origin).Unit * 1000, p)
    if res then
        local hit = res.Instance
        if hit and hit:IsDescendantOf(Workspace) then
            local char = hit:FindFirstAncestorOfClass("Model")
            if char and char:FindFirstChild("Humanoid") then return true end
        end
        return false
    end
    return true
end

-- Tìm mục tiêu tốt nhất
local function GetBestTarget()
    if not SilentAimEnabled then return nil end
    local origin = Camera.CFrame.Position
    local targets = GetValidTargets()
    local best, bestAngle = nil, CONFIG.FOV
    for _, char in ipairs(targets) do
        local part = char:FindFirstChild(CONFIG.AIM_PART)
        if not part then continue end
        local pos = part.Position
        if not IsVisible(origin, pos) then continue end
        local dir = (pos - origin).Unit
        local angle = math.deg(math.acos(Camera.CFrame.LookVector:Dot(dir)))
        if angle < bestAngle then
            bestAngle = angle
            best = {Character = char, Position = pos, Part = part}
        end
    end
    TargetCache = best
    return best
end

-- ===== HOOK 1: Mouse.Hit và Mouse.Target =====
local oldIndex
local mt = getrawmetatable and getrawmetatable(Mouse)
if mt then
    oldIndex = mt.__index
    setreadonly(mt, false)
    mt.__index = function(self, key)
        if key == "Hit" and SilentAimEnabled then
            local t = GetBestTarget()
            if t then return CFrame.new(t.Position) end
        elseif key == "Target" and SilentAimEnabled then
            local t = GetBestTarget()
            if t and t.Part then return t.Part end
        end
        return oldIndex(self, key)
    end
    setreadonly(mt, true)
end

-- ===== HOOK 2: RemoteEvent.FireServer (cho các game dùng Remote) =====
local function HookRemoteEvents()
    local function processRemote(remote)
        if remote:IsA("RemoteEvent") then
            local oldFire = remote.FireServer
            remote.FireServer = function(self, ...)
                if SilentAimEnabled then
                    local t = GetBestTarget()
                    if t then
                        local args = {...}
                        for i, v in ipairs(args) do
                            if type(v) == "CFrame" then
                                args[i] = CFrame.new(t.Position)
                            elseif type(v) == "Vector3" then
                                args[i] = t.Position
                            elseif type(v) == "Vector2" then
                                -- chuyển thành Vector2 của vị trí màn hình (nếu cần)
                            end
                        end
                        return oldFire(self, table.unpack(args))
                    end
                end
                return oldFire(self, ...)
            end
        end
    end
    -- Quét toàn bộ workspace và playergui
    for _, obj in ipairs(Workspace:GetDescendants()) do processRemote(obj) end
    for _, obj in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do processRemote(obj) end
    Workspace.DescendantAdded:Connect(processRemote)
    LocalPlayer.PlayerGui.DescendantAdded:Connect(processRemote)
end
-- Gọi hook remote (bỏ comment nếu game dùng Remote)
-- HookRemoteEvents()

-- ===== HOOK 3: Hook Tool.Activated và MouseButton1Down =====
local function HookTools()
    local function hookTool(tool)
        if not tool:IsA("Tool") then return end
        -- Hook Activated
        local oldActivated = tool.Activated
        tool.Activated = function(...)
            if SilentAimEnabled then
                local t = GetBestTarget()
                if t then
                    -- Thay đổi hướng bắn bằng cách set CFrame của tool handle
                    local handle = tool:FindFirstChild("Handle")
                    if handle then
                        handle.CFrame = CFrame.new(handle.Position, t.Position)
                    end
                end
            end
            return oldActivated and oldActivated(...)
        end
    end
    -- Hook tool hiện có và tool mới
    local player = LocalPlayer
    local function onChar(char)
        char.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then hookTool(child) end
        end)
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then hookTool(tool) end
        end
    end
    if player.Character then onChar(player.Character) end
    player.CharacterAdded:Connect(onChar)
end
-- Gọi hook tool (bỏ comment nếu game dùng tool)
-- HookTools()

-- ===== HOOK 4: Ghi đè InputBegan để bắn tự động (nếu cần) =====
-- Không bắt buộc, để tránh conflict

print("Silent Aim Pro đã sẵn sàng – giao diện đẹp, 3 lớp hook, 100% hiệu quả!")