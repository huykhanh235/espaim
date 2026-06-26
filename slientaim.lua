-- Silent Aim với Menu Bật/Tắt, Thu Gọn và Thanh trượt FOV (Roblox)
-- Hỗ trợ Synapse X, Krnl, ScriptWare, v.v.
-- Chạy dưới dạng LocalScript trong StarterPlayerScripts hoặc dùng loadstring.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ===== CẤU HÌNH MẶC ĐỊNH =====
local CONFIG = {
    FOV = 120,              -- Góc quét, có thể điều chỉnh
    AIM_PART = "Head",
    VISIBLE_CHECK = false,
    TEAM_CHECK = true
}

-- ===== BIẾN TOÀN CỤC =====
local SilentAimEnabled = true
local MenuVisible = true
local Minimized = false

-- ===== TẠO GUI VỚI THANH TRƯỢT FOV =====
local function CreateGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SilentAimGUI"
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Main Frame (kích thước mở rộng)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 240, 0, 200)
    mainFrame.Position = UDim2.new(0, 10, 0, 10)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 1
    mainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
    mainFrame.Parent = screenGui
    
    -- Tiêu đề
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 25)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Silent Aim Control"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = mainFrame
    
    -- Nút bật/tắt
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "ToggleBtn"
    toggleBtn.Size = UDim2.new(0, 100, 0, 30)
    toggleBtn.Position = UDim2.new(0, 10, 0, 35)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    toggleBtn.Text = "BẬT"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextScaled = true
    toggleBtn.Font = Enum.Font.SourceSansBold
    toggleBtn.Parent = mainFrame
    
    -- Nút thu gọn
    local minBtn = Instance.new("TextButton")
    minBtn.Name = "MinBtn"
    minBtn.Size = UDim2.new(0, 80, 0, 30)
    minBtn.Position = UDim2.new(0, 120, 0, 35)
    minBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    minBtn.Text = "Thu gọn"
    minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minBtn.TextScaled = true
    minBtn.Font = Enum.Font.SourceSansBold
    minBtn.Parent = mainFrame
    
    -- Nhãn trạng thái (hiển thị FOV hiện tại)
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, -20, 0, 25)
    statusLabel.Position = UDim2.new(0, 10, 0, 75)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "FOV: 120°"
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.SourceSans
    statusLabel.Parent = mainFrame
    
    -- ===== THANH TRƯỢT FOV =====
    local sliderContainer = Instance.new("Frame")
    sliderContainer.Name = "SliderContainer"
    sliderContainer.Size = UDim2.new(0, 200, 0, 20)
    sliderContainer.Position = UDim2.new(0, 20, 0, 110)
    sliderContainer.BackgroundTransparency = 1
    sliderContainer.Parent = mainFrame
    
    -- Đường nền của thanh trượt
    local sliderBg = Instance.new("Frame")
    sliderBg.Name = "SliderBg"
    sliderBg.Size = UDim2.new(1, 0, 0, 6)
    sliderBg.Position = UDim2.new(0, 0, 0.5, -3)
    sliderBg.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = sliderContainer
    
    -- Phần đã tô màu (thể hiện giá trị)
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "SliderFill"
    sliderFill.Size = UDim2.new(0.5, 0, 1, 0)  -- tạm thời 50%
    sliderFill.Position = UDim2.new(0, 0, 0, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBg
    
    -- Nút trượt (handle)
    local sliderHandle = Instance.new("TextButton")
    sliderHandle.Name = "SliderHandle"
    sliderHandle.Size = UDim2.new(0, 16, 0, 16)
    sliderHandle.Position = UDim2.new(0.5, -8, 0.5, -8)
    sliderHandle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    sliderHandle.BorderSizePixel = 0
    sliderHandle.Text = ""
    sliderHandle.Parent = sliderContainer
    
    -- Nhãn hiển thị giá trị FOV bên cạnh (tuỳ chọn)
    local fovValueLabel = Instance.new("TextLabel")
    fovValueLabel.Size = UDim2.new(0, 40, 0, 20)
    fovValueLabel.Position = UDim2.new(1, 5, 0, 0)
    fovValueLabel.BackgroundTransparency = 1
    fovValueLabel.Text = "120"
    fovValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    fovValueLabel.TextScaled = true
    fovValueLabel.Font = Enum.Font.SourceSans
    fovValueLabel.Parent = sliderContainer
    
    -- Nút nhỏ khi thu gọn
    local tinyBtn = Instance.new("TextButton")
    tinyBtn.Name = "TinyBtn"
    tinyBtn.Size = UDim2.new(0, 40, 0, 40)
    tinyBtn.Position = UDim2.new(0, 10, 0, 10)
    tinyBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    tinyBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
    tinyBtn.Text = "SA"
    tinyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    tinyBtn.TextScaled = true
    tinyBtn.Font = Enum.Font.SourceSansBold
    tinyBtn.Visible = false
    tinyBtn.Parent = screenGui
    
    -- ===== XỬ LÝ SỰ KIỆN CHO NÚT =====
    toggleBtn.MouseButton1Click:Connect(function()
        SilentAimEnabled = not SilentAimEnabled
        toggleBtn.Text = SilentAimEnabled and "BẬT" or "TẮT"
        toggleBtn.BackgroundColor3 = SilentAimEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
    end)
    
    minBtn.MouseButton1Click:Connect(function()
        Minimized = not Minimized
        mainFrame.Visible = not Minimized
        tinyBtn.Visible = Minimized
        minBtn.Text = Minimized and "Mở rộng" or "Thu gọn"
    end)
    
    tinyBtn.MouseButton1Click:Connect(function()
        Minimized = false
        mainFrame.Visible = true
        tinyBtn.Visible = false
        minBtn.Text = "Thu gọn"
    end)
    
    -- ===== XỬ LÝ THANH TRƯỢT FOV =====
    local function UpdateFOV(value)
        value = math.clamp(value, 30, 200)  -- Giới hạn từ 30 đến 200
        CONFIG.FOV = value
        fovValueLabel.Text = tostring(math.floor(value))
        statusLabel.Text = "FOV: " .. tostring(math.floor(value)) .. "°"
        -- Cập nhật vị trí handle và fill
        local percent = (value - 30) / (200 - 30)
        sliderHandle.Position = UDim2.new(percent, -8, 0.5, -8)
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
    end
    
    -- Khởi tạo giá trị ban đầu
    UpdateFOV(CONFIG.FOV)
    
    -- Sự kiện kéo thả
    local dragging = false
    sliderHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    sliderHandle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local containerAbsPos = sliderContainer.AbsolutePosition
            local containerSize = sliderContainer.AbsoluteSize
            local mouseX = input.Position.X
            local relativeX = math.clamp((mouseX - containerAbsPos.X) / containerSize.X, 0, 1)
            local newValue = 30 + relativeX * (200 - 30)
            UpdateFOV(newValue)
        end
    end)
    
    -- Cho phép click trực tiếp lên nền để nhảy giá trị
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local containerAbsPos = sliderContainer.AbsolutePosition
            local containerSize = sliderContainer.AbsoluteSize
            local mouseX = input.Position.X
            local relativeX = math.clamp((mouseX - containerAbsPos.X) / containerSize.X, 0, 1)
            local newValue = 30 + relativeX * (200 - 30)
            UpdateFOV(newValue)
        end
    end)
    
    return {
        MainFrame = mainFrame,
        ToggleBtn = toggleBtn,
        StatusLabel = statusLabel,
        TinyBtn = tinyBtn,
        UpdateFOV = UpdateFOV
    }
end

local GUI = CreateGUI()

-- ===== CỐT LÕI SILENT AIM =====

local function GetValidTargets()
    local targets = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if CONFIG.TEAM_CHECK and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
                continue
            end
            local char = player.Character
            if char and char:FindFirstChild(CONFIG.AIM_PART) and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                table.insert(targets, char)
            end
        end
    end
    return targets
end

local function IsVisible(origin, targetPos)
    if not CONFIG.VISIBLE_CHECK then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    local result = Workspace:Raycast(origin, (targetPos - origin).Unit * 1000, params)
    if result then
        local hit = result.Instance
        if hit and hit:IsDescendantOf(Workspace) then
            local char = hit:FindFirstAncestorOfClass("Model")
            if char and char:FindFirstChild("Humanoid") then
                return true
            end
        end
        return false
    end
    return true
end

local function GetBestTarget()
    if not SilentAimEnabled then return nil end
    local origin = Camera.CFrame.Position
    local targets = GetValidTargets()
    local best = nil
    local bestAngle = CONFIG.FOV

    for _, char in ipairs(targets) do
        local part = char:FindFirstChild(CONFIG.AIM_PART)
        if not part then continue end
        local targetPos = part.Position
        if not IsVisible(origin, targetPos) then continue end

        local direction = (targetPos - origin).Unit
        local lookVec = Camera.CFrame.LookVector
        local angle = math.deg(math.acos(lookVec:Dot(direction)))

        if angle < bestAngle then
            bestAngle = angle
            best = {
                Character = char,
                Position = targetPos,
                Part = part
            }
        end
    end
    return best
end

-- ===== HOOK MOUSE.HIT =====
local function HookMouseHit()
    local mt = getrawmetatable and getrawmetatable(Mouse) or nil
    if not mt then return end
    local oldIndex = mt.__index
    setreadonly(mt, false)
    mt.__index = function(self, key)
        if key == "Hit" and SilentAimEnabled then
            local target = GetBestTarget()
            if target then
                return CFrame.new(target.Position)
            end
        end
        return oldIndex(self, key)
    end
    setreadonly(mt, true)
end
HookMouseHit()

-- ===== HOOK REMOTE (tùy chọn, bỏ comment để dùng) =====
--[[
local function HookToolRemote()
    -- tương tự như trước, nhưng giữ nguyên
end
--]]

print("Silent Aim với Menu FOV đã tải thành công!")