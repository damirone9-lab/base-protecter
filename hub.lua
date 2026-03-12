local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
local selectedTarget = nil 
local NetRemote = nil

-- Find Remote
task.spawn(function()
    while not NetRemote do
        for _, obj in pairs(game:GetDescendants()) do
            if obj:IsA("RemoteEvent") and obj.Name:lower():find("352aad5") then
                NetRemote = obj
                break
            end
        end
        task.wait(1)
    end
end)

-- State
local state = {
    baseProtect = false,
    antiTP = false,
    minimized = false,
    fullHeight = 135 -- Base height before player list
}

local theme = {
    bg = Color3.fromRGB(20, 20, 25),
    accent = Color3.fromRGB(150, 100, 255),
    topBar = Color3.fromRGB(30, 30, 35),
    buttonOff = Color3.fromRGB(40, 40, 45),
    buttonOn = Color3.fromRGB(150, 100, 255),
    spamFlash = Color3.fromRGB(220, 180, 0), -- Yellow flash for spamming
    pingText = Color3.fromRGB(0, 255, 150)
}

-- [ UI Setup ] --
local screenGui = Instance.new("ScreenGui", localPlayer:WaitForChild("PlayerGui"))
screenGui.ResetOnSpawn = false

local main = Instance.new("Frame", screenGui)
main.Size = UDim2.new(0, 220, 0, state.fullHeight)
main.Position = UDim2.new(0.5, -110, 0.5, -140)
main.BackgroundColor3 = theme.bg
main.BorderSizePixel = 0
main.ClipsDescendants = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", main).Color = theme.accent

-- Header
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 30)
header.BackgroundColor3 = theme.topBar
header.BorderSizePixel = 0

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(0.6, 0, 1, 0)
title.Position = UDim2.new(0, 8, 0, 0)
title.Text = "MAGICAL HUB"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 11
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left

local pingLabel = Instance.new("TextLabel", header)
pingLabel.Size = UDim2.new(0, 50, 1, 0)
pingLabel.Position = UDim2.new(1, -75, 0, 0)
pingLabel.Text = "0ms"
pingLabel.TextColor3 = theme.pingText
pingLabel.Font = Enum.Font.Code
pingLabel.TextSize = 10
pingLabel.BackgroundTransparency = 1

task.spawn(function()
    while task.wait(1) do
        pingLabel.Text = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) .. "ms"
    end
end)

-- [ Main Container ] --
local container = Instance.new("Frame", main)
container.Size = UDim2.new(1, -14, 1, -35)
container.Position = UDim2.new(0, 7, 0, 35)
container.BackgroundTransparency = 1

local mainLayout = Instance.new("UIListLayout", container)
mainLayout.Padding = UDim.new(0, 5)
mainLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- [ Buttons ] --
local function createBtn(name, order, callback)
    local btn = Instance.new("TextButton", container)
    btn.Size = UDim2.new(1, 0, 0, 26)
    btn.BackgroundColor3 = theme.buttonOff
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextSize = 11
    btn.LayoutOrder = order
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    btn.MouseButton1Click:Connect(function() callback(btn) end)
    return btn
end

createBtn("Base Protector", 1, function(b)
    state.baseProtect = not state.baseProtect
    TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = state.baseProtect and theme.buttonOn or theme.buttonOff}):Play()
end)

createBtn("Anti-TP Scam", 2, function(b)
    state.antiTP = not state.antiTP
    TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = state.antiTP and Color3.fromRGB(200, 50, 50) or theme.buttonOff}):Play()
end)

-- The AP Spam Action Logic
local function getClosest()
    local closest, dist = nil, math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= localPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local d = (localPlayer.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then dist = d closest = plr end
        end
    end
    return closest
end

local function fireSpam()
    if not NetRemote then return end
    local target = selectedTarget or getClosest()
    if not target or not target.Character then return end
    
    for _, tool in pairs({"rocket","morph","jumpscare","tiny","inverse","ragdoll"}) do
        NetRemote:FireServer("78a772b6-9e1c-4827-ab8b-04a07838f298", target, tool)
    end
end

-- AP Spam Button & Visual Trigger
local apSpamBtn = createBtn("FIRE AP SPAM (Q)", 3, function() end) -- Empty callback, logic handled below

local function triggerSpamVisuals()
    fireSpam()
    
    -- Visual update on UI
    apSpamBtn.Text = " [ SPAMMING ] "
    TweenService:Create(apSpamBtn, TweenInfo.new(0.05), {BackgroundColor3 = theme.spamFlash}):Play()
    
    task.wait(0.2)
    
    -- Revert
    apSpamBtn.Text = "FIRE AP SPAM (Q)"
    TweenService:Create(apSpamBtn, TweenInfo.new(0.2), {BackgroundColor3 = theme.buttonOff}):Play()
end

apSpamBtn.MouseButton1Click:Connect(triggerSpamVisuals)

-- [ Player List & Auto-Sizing ] --
local scroll = Instance.new("ScrollingFrame", container)
scroll.BackgroundTransparency = 0.5
scroll.BackgroundColor3 = Color3.fromRGB(10,10,15)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 2
scroll.LayoutOrder = 4
local listLayout = Instance.new("UIListLayout", scroll)
listLayout.Padding = UDim.new(0, 3)

local function resizeUI()
    if state.minimized then return end
    local listHeight = listLayout.AbsoluteContentSize.Y
    -- Cap list height at 120 so it doesn't get massive with 30 players
    if listHeight > 120 then listHeight = 120 end 
    
    scroll.Size = UDim2.new(1, 0, 0, listHeight)
    
    -- Base Height (135) + List Height + Small bottom padding (5)
    state.fullHeight = 135 + listHeight + 5 
    TweenService:Create(main, TweenInfo.new(0.2), {Size = UDim2.new(0, 220, 0, state.fullHeight)}):Play()
end

listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resizeUI)

local function updateList()
    for _, v in pairs(scroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= localPlayer then
            local b = Instance.new("TextButton", scroll)
            b.Size = UDim2.new(1, -4, 0, 22)
            b.BackgroundColor3 = (selectedTarget == plr) and theme.accent or theme.buttonOff
            b.Text = plr.Name
            b.TextColor3 = Color3.new(1,1,1)
            b.Font = Enum.Font.Gotham
            b.TextSize = 10
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
            
            b.MouseButton1Click:Connect(function()
                selectedTarget = (selectedTarget == plr) and nil or plr
                updateList()
                title.Text = selectedTarget and "LOCKED: " .. string.sub(plr.Name:upper(), 1, 10) or "MAGICAL HUB"
            end)
        end
    end
end

updateList()
Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)

-- Keybind for Q
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.Q then 
        triggerSpamVisuals() -- Calls the spam AND flashes the UI
    end
end)

-- Loops for Protections
task.spawn(function()
    while task.wait(0.5) do
        if state.baseProtect then
            local plot = Workspace:FindFirstChild(localPlayer.Name.."_Plot")
            if plot then
                for _, obj in pairs(plot:GetChildren()) do
                    if obj:IsA("BasePart") then obj.Anchored = true end
                end
            end
        end
        if state.antiTP and localPlayer.Character then
            local hrp = localPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = hrp.CFrame + Vector3.new(0,0.1,0) end
        end
    end
end)

-- Minimize
local minBtn = Instance.new("TextButton", header)
minBtn.Size = UDim2.new(0, 20, 0, 20)
minBtn.Position = UDim2.new(1, -25, 0.5, -10)
minBtn.Text = "-"
minBtn.BackgroundColor3 = theme.buttonOff
minBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 4)

minBtn.MouseButton1Click:Connect(function()
    state.minimized = not state.minimized
    TweenService:Create(main, TweenInfo.new(0.3), {Size = UDim2.new(0, 220, 0, state.minimized and 30 or state.fullHeight)}):Play()
    container.Visible = not state.minimized
    minBtn.Text = state.minimized and "+" or "-"
end)

-- Dragging
local drag, dStart, sPos
header.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true dStart = i.Position sPos = main.Position end end)
UserInputService.InputChanged:Connect(function(i) if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
    local delta = i.Position - dStart
    main.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + delta.X, sPos.Y.Scale, sPos.Y.Offset + delta.Y)
end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)
