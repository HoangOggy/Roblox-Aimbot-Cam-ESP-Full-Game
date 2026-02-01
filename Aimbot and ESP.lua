--[[ 
    Follow Player Camera Script
    FINAL FIXED VERSION
    ICON = BUILT-IN CROSSHAIR (EMOJI)
    Made by HoangOggy
]]

--------------------------------------------------
-- SERVICES
--------------------------------------------------
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer


--------------------------------------------------
-- STATES
--------------------------------------------------
local following = false
local holdingRight = false
local targetPlayer = nil
local safeList = {}
local hotkey = Enum.KeyCode.F
local waitingForKey = false

local minimized = false
local locked = false


--------------------------------------------------
-- GUI ROOT
--------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "FollowCameraUI"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")


--------------------------------------------------
-- MAIN FRAME
--------------------------------------------------
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 240, 0, 330)
main.Position = UDim2.new(0, 40, 0.5, -165)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)


--------------------------------------------------
-- TITLE
--------------------------------------------------
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,32)
title.BackgroundTransparency = 1
title.Text = "🎯 Aimbot Cam"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.new(1,1,1)


--------------------------------------------------
-- LOCK BUTTON
--------------------------------------------------
local lockBtn = Instance.new("TextButton", main)
lockBtn.Size = UDim2.new(0,28,0,28)
lockBtn.Position = UDim2.new(1,-64,0,2)
lockBtn.Text = "🔓"
lockBtn.Font = Enum.Font.Gotham
lockBtn.TextSize = 16
lockBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
lockBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", lockBtn).CornerRadius = UDim.new(1,0)


--------------------------------------------------
-- MINIMIZE BUTTON
--------------------------------------------------
local minimizeBtn = Instance.new("TextButton", main)
minimizeBtn.Size = UDim2.new(0,28,0,28)
minimizeBtn.Position = UDim2.new(1,-34,0,2)
minimizeBtn.Text = "-"
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 18
minimizeBtn.TextColor3 = Color3.new(1,1,1)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(1,0)


--------------------------------------------------
-- AIM ICON (EMOJI 🎯)
--------------------------------------------------
local aimIcon = Instance.new("TextButton", gui)
aimIcon.Size = UDim2.new(0,48,0,48)
aimIcon.Position = main.Position
aimIcon.Text = "🎯"
aimIcon.Font = Enum.Font.GothamBold
aimIcon.TextSize = 26
aimIcon.TextColor3 = Color3.new(1,1,1)
aimIcon.BackgroundColor3 = Color3.fromRGB(25,25,25)
aimIcon.Visible = false
aimIcon.Active = true
aimIcon.Draggable = true
Instance.new("UICorner", aimIcon).CornerRadius = UDim.new(1,0)


--------------------------------------------------
-- FOLLOW BUTTON
--------------------------------------------------
local followBtn = Instance.new("TextButton", main)
followBtn.Size = UDim2.new(1,-20,0,34)
followBtn.Position = UDim2.new(0,10,0,42)
followBtn.Text = "Follow: OFF"
followBtn.Font = Enum.Font.GothamBold
followBtn.TextSize = 14
followBtn.TextColor3 = Color3.new(1,1,1)
followBtn.BackgroundColor3 = Color3.fromRGB(200,60,60)
Instance.new("UICorner", followBtn).CornerRadius = UDim.new(0,10)


--------------------------------------------------
-- HOTKEY BUTTON
--------------------------------------------------
local hotkeyBtn = Instance.new("TextButton", main)
hotkeyBtn.Size = UDim2.new(1,-20,0,28)
hotkeyBtn.Position = UDim2.new(0,10,0,84)
hotkeyBtn.Text = "Hotkey: F"
hotkeyBtn.Font = Enum.Font.Gotham
hotkeyBtn.TextSize = 13
hotkeyBtn.TextColor3 = Color3.new(1,1,1)
hotkeyBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
Instance.new("UICorner", hotkeyBtn).CornerRadius = UDim.new(0,8)


--------------------------------------------------
-- SEARCH BOX
--------------------------------------------------
local searchBox = Instance.new("TextBox", main)
searchBox.Size = UDim2.new(1,-20,0,26)
searchBox.Position = UDim2.new(0,10,0,120)
searchBox.PlaceholderText = "Search player..."
searchBox.Text = ""
searchBox.ClearTextOnFocus = false
searchBox.TextColor3 = Color3.new(1,1,1)
searchBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0,8)


--------------------------------------------------
-- PLAYER LIST
--------------------------------------------------
local listFrame = Instance.new("ScrollingFrame", main)
listFrame.Size = UDim2.new(1,-20,0,160)
listFrame.Position = UDim2.new(0,10,0,155)
listFrame.ScrollBarThickness = 6
listFrame.CanvasSize = UDim2.new(0,0,0,0)
listFrame.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", listFrame)
layout.Padding = UDim.new(0,6)


--------------------------------------------------
-- FUNCTIONS
--------------------------------------------------
local function updateFollowUI()
    followBtn.Text = following and "Follow: ON" or "Follow: OFF"
    followBtn.BackgroundColor3 = following
        and Color3.fromRGB(60,200,100)
        or Color3.fromRGB(200,60,60)
end

local function toggleFollow()
    following = not following
    updateFollowUI()
end

local function setMinimized(state)
    minimized = state
    if minimized then
        main.Visible = false
        aimIcon.Position = main.Position
        aimIcon.Visible = true
    else
        main.Visible = true
        aimIcon.Visible = false
    end
end


--------------------------------------------------
-- BUTTON EVENTS
--------------------------------------------------
followBtn.MouseButton1Click:Connect(toggleFollow)

hotkeyBtn.MouseButton1Click:Connect(function()
    waitingForKey = true
    hotkeyBtn.Text = "Press a key..."
end)

minimizeBtn.MouseButton1Click:Connect(function()
    setMinimized(true)
end)

aimIcon.MouseButton1Click:Connect(function()
    setMinimized(false)
end)

lockBtn.MouseButton1Click:Connect(function()
    locked = not locked
    main.Draggable = not locked
    aimIcon.Draggable = not locked
    lockBtn.Text = locked and "🔒" or "🔓"
end)


--------------------------------------------------
-- INPUT
--------------------------------------------------
UIS.InputBegan:Connect(function(input, gp)
    if UIS:GetFocusedTextBox() then return end

    if input.KeyCode == hotkey then
        toggleFollow()
        return
    end

    if gp then return end

    if input.UserInputType == Enum.UserInputType.MouseButton2 and following then
        holdingRight = true
        local mousePos = UIS:GetMouseLocation()
        local closest, dist = nil, math.huge

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                if not safeList[plr.Name] then
                    local pos, visible = Camera:WorldToScreenPoint(plr.Character.Head.Position)
                    if visible then
                        local d = (Vector2.new(pos.X,pos.Y) - mousePos).Magnitude
                        if d < dist then
                            dist = d
                            closest = plr
                        end
                    end
                end
            end
        end
        targetPlayer = closest
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        holdingRight = false
        targetPlayer = nil
    end
end)


--------------------------------------------------
-- HOTKEY CHANGE
--------------------------------------------------
UIS.InputBegan:Connect(function(input)
    if waitingForKey and input.KeyCode ~= Enum.KeyCode.Unknown then
        hotkey = input.KeyCode
        hotkeyBtn.Text = "Hotkey: "..hotkey.Name
        waitingForKey = false
    end
end)


--------------------------------------------------
-- CAMERA FOLLOW
--------------------------------------------------
RunService.RenderStepped:Connect(function()
    if holdingRight and targetPlayer and targetPlayer.Character then
        local head = targetPlayer.Character:FindFirstChild("Head")
        if head then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
        end
    end
end)


--------------------------------------------------
-- PLAYER LIST
--------------------------------------------------
local function refreshList()
    for _, v in ipairs(listFrame:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if searchBox.Text == "" or plr.Name:lower():find(searchBox.Text:lower()) then
                local btn = Instance.new("TextButton", listFrame)
                btn.Size = UDim2.new(1,-6,0,28)
                btn.Text = plr.Name .. (safeList[plr.Name] and " [SAFE]" or "")
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 13
                btn.TextColor3 = Color3.new(1,1,1)
                btn.BackgroundColor3 = safeList[plr.Name]
                    and Color3.fromRGB(80,120,80)
                    or Color3.fromRGB(50,50,50)
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

                btn.MouseButton1Click:Connect(function()
                    safeList[plr.Name] = not safeList[plr.Name]
                    refreshList()
                end)
            end
        end
    end

    task.wait()
    listFrame.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 6)
end

searchBox:GetPropertyChangedSignal("Text"):Connect(refreshList)
Players.PlayerAdded:Connect(refreshList)
Players.PlayerRemoving:Connect(refreshList)

refreshList()
updateFollowUI()

-- ==================================================
-- ================= ESP SECTION ===================
-- ==================================================

-- settings
local settings = {
    defaultcolor = Color3.fromRGB(255,0,0),
    teamcheck = false,
    teamcolor = true,
    showName = true,
    showHealth = true
};

-- services
local runService = game:GetService("RunService");
local players = game:GetService("Players");

-- variables
local localPlayer = players.LocalPlayer;
local camera = workspace.CurrentCamera;

-- functions
local newVector2, newColor3, newDrawing = Vector2.new, Color3.new, Drawing.new;
local tan, rad = math.tan, math.rad;
local round = function(...) 
    local a = {}; 
    for i,v in next, table.pack(...) do 
        a[i] = math.round(v); 
    end 
    return unpack(a); 
end;

local wtvp = function(...)
    local a, b = camera:WorldToViewportPoint(...)
    return newVector2(a.X, a.Y), b, a.Z
end;

local espCache = {};

-- create esp
local function createEsp(player)
    local drawings = {};

    -- BOX
    drawings.box = newDrawing("Square");
    drawings.box.Thickness = 1;
    drawings.box.Filled = false;
    drawings.box.Color = settings.defaultcolor;
    drawings.box.Visible = false;
    drawings.box.ZIndex = 2;

    drawings.boxoutline = newDrawing("Square");
    drawings.boxoutline.Thickness = 3;
    drawings.boxoutline.Filled = false;
    drawings.boxoutline.Color = Color3.new(0,0,0);
    drawings.boxoutline.Visible = false;
    drawings.boxoutline.ZIndex = 1;

    -- NAME
    drawings.name = newDrawing("Text");
    drawings.name.Size = 13;
    drawings.name.Center = true;
    drawings.name.Outline = true;
    drawings.name.Font = 2;
    drawings.name.Visible = false;

    -- HEALTH BAR
    drawings.healthOutline = newDrawing("Square");
    drawings.healthOutline.Filled = false;
    drawings.healthOutline.Thickness = 1;
    drawings.healthOutline.Color = Color3.new(0,0,0);
    drawings.healthOutline.Visible = false;

    drawings.healthBar = newDrawing("Square");
    drawings.healthBar.Filled = true;
    drawings.healthBar.Color = Color3.fromRGB(0,255,0);
    drawings.healthBar.Visible = false;

    espCache[player] = drawings;
end

local function removeEsp(player)
    if espCache[player] then
        for _, drawing in pairs(espCache[player]) do
            drawing:Remove();
        end
        espCache[player] = nil;
    end
end

-- update esp
local function updateEsp(player, esp)
    local character = player.Character;
    local humanoid = character and character:FindFirstChildOfClass("Humanoid");
    local hrp = character and character:FindFirstChild("HumanoidRootPart");

    if not (character and humanoid and hrp) then
        for _,v in pairs(esp) do v.Visible = false end
        return;
    end

    local pos, visible, depth = wtvp(hrp.Position);
    if not visible then
        for _,v in pairs(esp) do v.Visible = false end
        return;
    end

    local scaleFactor = 1 / (depth * tan(rad(camera.FieldOfView / 2)) * 2) * 1000;
    local width, height = round(4 * scaleFactor, 5 * scaleFactor);
    local x, y = round(pos.X, pos.Y);

    -- BOX
    esp.box.Size = newVector2(width, height);
    esp.box.Position = newVector2(x - width/2, y - height/2);
    esp.box.Color = settings.teamcolor and player.TeamColor.Color or settings.defaultcolor;
    esp.box.Visible = true;

    esp.boxoutline.Size = esp.box.Size;
    esp.boxoutline.Position = esp.box.Position;
    esp.boxoutline.Visible = true;

    -- NAME
    if settings.showName then
        esp.name.Text = "@" .. player.Name
        esp.name.Position = newVector2(x, y - height/2 - 14)
        esp.name.Color = esp.box.Color
        esp.name.Visible = true
    else
        esp.name.Visible = false
    end

    -- HEALTH
    if settings.showHealth then
        local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1);
        local barHeight = height * healthPercent;

        esp.healthOutline.Size = newVector2(4, height);
        esp.healthOutline.Position = newVector2(x - width/2 - 6, y - height/2);
        esp.healthOutline.Visible = true;

        esp.healthBar.Size = newVector2(2, barHeight);
        esp.healthBar.Position = newVector2(
            x - width/2 - 5,
            y + height/2 - barHeight
        );

        esp.healthBar.Color = Color3.fromRGB(
            255 - (255 * healthPercent),
            255 * healthPercent,
            0
        );

        esp.healthBar.Visible = true
    else
        esp.healthBar.Visible = false
        esp.healthOutline.Visible = false
    end
end

-- init
for _, player in pairs(players:GetPlayers()) do
    if player ~= localPlayer then
        createEsp(player);
    end
end

players.PlayerAdded:Connect(createEsp);
players.PlayerRemoving:Connect(removeEsp);

runService:BindToRenderStep("esp", Enum.RenderPriority.Camera.Value, function()
    for player, drawings in pairs(espCache) do
        if settings.teamcheck and player.Team == localPlayer.Team then
            for _,v in pairs(drawings) do v.Visible = false end
            continue;
        end

        if player ~= localPlayer then
            updateEsp(player, drawings);
        end
    end
end)
