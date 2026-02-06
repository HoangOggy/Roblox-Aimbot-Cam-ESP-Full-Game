--[[ 
    Follow Player Camera Script
    FINAL FIXED VERSION
    ICON = BUILT-IN CROSSHAIR (EMOJI)
    Made by HoangOggy
]]

--------------------------------------------------
-- GLOBAL MERGE FLAG
--------------------------------------------------
local INTRO_DONE = false
local pinnedPlayers = {}

--------------------------------------------------
-- SERVICES (INTRO + ESP)
--------------------------------------------------
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

--------------------------------------------------
-- INTRO GUI
--------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
-- 
local bg = Instance.new("Frame")
bg.Size = UDim2.fromScale(1, 1)
bg.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
bg.Parent = gui

-- GLASS SWEEP
local sweep = Instance.new("Frame")
sweep.Size = UDim2.fromScale(0.12, 1.7)
sweep.Position = UDim2.fromScale(-0.6, -0.35)
sweep.BackgroundTransparency = 1
sweep.Rotation = 28
sweep.ZIndex = 20
sweep.Parent = gui

local sweepGrad = Instance.new("UIGradient")
sweepGrad.Transparency = NumberSequence.new{
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.5, 0.25),
	NumberSequenceKeypoint.new(1, 1),
}
sweepGrad.Parent = sweep

-- TEXT
local text = Instance.new("TextLabel")
text.AnchorPoint = Vector2.new(0.5, 0.5)
text.Position = UDim2.fromScale(0.5, 0.5)
text.Size = UDim2.fromScale(0.2, 0.08)
text.BackgroundTransparency = 1
text.Text = "ST TEAM"
text.Font = Enum.Font.GothamBlack
text.TextScaled = true
text.TextStrokeTransparency = 0
text.TextStrokeColor3 = Color3.new(0,0,0)
text.Parent = bg

local textGrad = Instance.new("UIGradient")
textGrad.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
	ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255,255,0)),
	ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0,255,0)),
	ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0,255,255)),
	ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0,0,255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,255)),
}
textGrad.Parent = text

-- RAINBOW ROTATE
local rot = 0
local rainbowConn = RunService.RenderStepped:Connect(function(dt)
	rot += dt * 90
	textGrad.Rotation = rot
	sweepGrad.Rotation = -rot
end)

-- ZOOM TEXT
TweenService:Create(
	text,
	TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	{ Size = UDim2.fromScale(0.8, 0.3) }
):Play()

-- SWEEP LOOP
local SWEEP_COUNT = 2
local SWEEP_TIME = 1.5

task.delay(0.6, function()
	for i = 1, SWEEP_COUNT do
		sweep.Position = UDim2.fromScale(-0.6, -0.35)
		sweep.BackgroundTransparency = 0

		TweenService:Create(
			sweep,
			TweenInfo.new(SWEEP_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Position = UDim2.fromScale(1.2, -0.35) }
		):Play()

		task.wait(SWEEP_TIME * 0.85)
	end
end)

--------------------------------------------------
-- ESP (CẬP NHẬT LOGIC PIN)
--------------------------------------------------
local function startESP()

	local settings = {
		color = Color3.fromRGB(255,255,255),
		pinColor = Color3.fromRGB(255, 0, 0), -- Màu đỏ cho người bị Pin
		showName = true,
		showHealth = true
	}

	local localPlayer = Players.LocalPlayer
	local newVector2, newDrawing = Vector2.new, Drawing.new
	local tan, rad = math.tan, math.rad

	local function round(...)
		local t = {}
		for i,v in next, table.pack(...) do
			t[i] = math.round(v)
		end
		return unpack(t)
	end

	local function wtvp(pos)
		local v, onScreen = camera:WorldToViewportPoint(pos)
		return newVector2(v.X, v.Y), onScreen, v.Z
	end

	local espCache = {}

	local function createEsp(plr)
		local d = {}

		d.box = newDrawing("Square")
		d.box.Thickness = 1.5
		d.box.Filled = false
		d.box.Color = settings.color
		d.box.Visible = false

		-- Thay đổi outline dựa theo trạng thái Pin
		d.outline = newDrawing("Square")
		d.outline.Thickness = 3
		d.outline.Filled = false
		d.outline.Color = settings.color
		d.outline.Visible = false

		d.name = newDrawing("Text")
		d.name.Size = 13
		d.name.Center = true
		d.name.Outline = true
		d.name.Font = 2
		d.name.Color = settings.color
		d.name.Visible = false

		d.hpOutline = newDrawing("Square")
		d.hpOutline.Filled = false
		d.hpOutline.Thickness = 1
		d.hpOutline.Color = Color3.new(0,0,0)
		d.hpOutline.Visible = false

		d.hpBar = newDrawing("Square")
		d.hpBar.Filled = true
		d.hpBar.Visible = false

		espCache[plr] = d
	end

	local function removeEsp(plr)
		if espCache[plr] then
			for _,v in pairs(espCache[plr]) do
				v:Remove()
			end
			espCache[plr] = nil
		end
	end

	for _,plr in pairs(Players:GetPlayers()) do
		if plr ~= localPlayer then
			createEsp(plr)
		end
	end

	Players.PlayerAdded:Connect(createEsp)
	Players.PlayerRemoving:Connect(removeEsp)

	RunService:BindToRenderStep("ESP_RENDER", Enum.RenderPriority.Camera.Value, function()
		for plr,esp in pairs(espCache) do
			local char = plr.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local hrp = char and char:FindFirstChild("HumanoidRootPart")

			if not (char and hum and hrp) then
				for _,v in pairs(esp) do v.Visible = false end
				continue
			end

			local pos, onScreen, depth = wtvp(hrp.Position)
			if not onScreen then
				for _,v in pairs(esp) do v.Visible = false end
				continue
			end

			-- KIỂM TRA MÀU SẮC DỰA TRÊN PIN
			local isPinned = pinnedPlayers[plr.Name]
			local currentColor = isPinned and settings.pinColor or settings.color

			local scale = 1 / (depth * tan(rad(camera.FieldOfView / 2)) * 2) * 1000
			local w,h = round(4*scale, 5*scale)
			local x,y = round(pos.X, pos.Y)

			esp.box.Size = newVector2(w,h)
			esp.box.Position = newVector2(x-w/2, y-h/2)
			esp.box.Color = currentColor -- Box thành màu đỏ nếu pin
			esp.box.Visible = true

			esp.outline.Size = esp.box.Size
			esp.outline.Position = esp.box.Position
			esp.outline.Color = currentColor -- Outline cũng đổi màu theo pin
			esp.outline.Visible = true

			if settings.showName then
				esp.name.Text = (isPinned and "[PINNED] " or "") .. "@" .. plr.Name
				esp.name.Position = newVector2(x, y-h/2-14)
				esp.name.Color = currentColor
				esp.name.Visible = true
			else
				esp.name.Visible = false
			end

			if settings.showHealth then
				local hp = math.clamp(hum.Health/hum.MaxHealth,0,1)
				local bh = h*hp

				esp.hpOutline.Size = newVector2(4,h)
				esp.hpOutline.Position = newVector2(x-w/2-6, y-h/2)
				esp.hpOutline.Visible = true

				esp.hpBar.Size = newVector2(2,bh)
				esp.hpBar.Position = newVector2(x-w/2-5, y+h/2-bh)
				esp.hpBar.Color = Color3.fromRGB(255-(255*hp),255*hp,0)
				esp.hpBar.Visible = true
			else
				esp.hpBar.Visible = false
				esp.hpOutline.Visible = false
			end
		end
	end)
end

--------------------------------------------------
-- END INTRO ➜ START ESP
--------------------------------------------------
task.delay(0.6 + SWEEP_COUNT * SWEEP_TIME + 0.8, function()
	rainbowConn:Disconnect()

	local fade = TweenInfo.new(0.8)
	TweenService:Create(text, fade, {
		TextTransparency = 1,
		TextStrokeTransparency = 1
	}):Play()

	TweenService:Create(bg, fade, {
		BackgroundTransparency = 1
	}):Play()

	task.wait(0.9)
	gui:Destroy()

	startESP()
	INTRO_DONE = true
end)

--------------------------------------------------
-- AIMBOT CAM + PIN LIST
--------------------------------------------------
task.spawn(function()
	repeat task.wait() until INTRO_DONE

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local following = false
local holdingRight = false
local targetPlayer = nil
local safeList = {}
local killAimTarget = nil
local hotkey = Enum.KeyCode.F
local waitingForKey = false
local minimized = false
local locked = false

local gui = Instance.new("ScreenGui")
gui.Name = "FollowCameraUI"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

--------------------------------------------------
-- MAIN FRAME (MỞ RỘNG SANG PHẢI)
--------------------------------------------------
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 540, 0, 340) -- Đã mở rộng thêm ngang và dọc
main.Position = UDim2.new(0, 40, 0.5, -170)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.Active = true
main.Draggable = true
main.Visible = false
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)

-- Đường kẻ chia đôi
local divider = Instance.new("Frame", main)
divider.Size = UDim2.new(0, 2, 0, 290)
divider.Position = UDim2.new(0.5, -1, 0, 40)
divider.BackgroundColor3 = Color3.fromRGB(50,50,50)
divider.BorderSizePixel = 0

--------------------------------------------------
-- TIÊU ĐỀ
--------------------------------------------------
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(0.5,0,0,32)
title.BackgroundTransparency = 1
title.Text = "🎯 Aimbot Cam"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.new(1,1,1)

local titlePin = Instance.new("TextLabel", main)
titlePin.Size = UDim2.new(0.5,0,0,32)
titlePin.Position = UDim2.new(0.5,0,0,0)
titlePin.BackgroundTransparency = 1
titlePin.Text = "📌 Pin ESP Player"
titlePin.Font = Enum.Font.GothamBold
titlePin.TextSize = 16
titlePin.TextColor3 = Color3.fromRGB(255,100,100)

--------------------------------------------------
-- CÁC NÚT ĐIỀU KHIỂN
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

local minimizeBtn = Instance.new("TextButton", main)
minimizeBtn.Size = UDim2.new(0,28,0,28)
minimizeBtn.Position = UDim2.new(1,-34,0,2)
minimizeBtn.Text = "-"
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 18
minimizeBtn.TextColor3 = Color3.new(1,1,1)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(1,0)

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
-- CÁC THÀNH PHẦN BÊN TRÁI (AIMBOT)
--------------------------------------------------
local followBtn = Instance.new("TextButton", main)
followBtn.Size = UDim2.new(0.5,-20,0,34)
followBtn.Position = UDim2.new(0,10,0,42)
followBtn.Text = "Follow: OFF"
followBtn.Font = Enum.Font.GothamBold
followBtn.TextSize = 14
followBtn.TextColor3 = Color3.new(1,1,1)
followBtn.BackgroundColor3 = Color3.fromRGB(200,60,60)
Instance.new("UICorner", followBtn).CornerRadius = UDim.new(0,10)

local hotkeyBtn = Instance.new("TextButton", main)
hotkeyBtn.Size = UDim2.new(0.5,-20,0,28)
hotkeyBtn.Position = UDim2.new(0,10,0,84)
hotkeyBtn.Text = "Hotkey: F"
hotkeyBtn.Font = Enum.Font.Gotham
hotkeyBtn.TextSize = 13
hotkeyBtn.TextColor3 = Color3.new(1,1,1)
hotkeyBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
Instance.new("UICorner", hotkeyBtn).CornerRadius = UDim.new(0,8)

local searchBox = Instance.new("TextBox", main)
searchBox.Size = UDim2.new(0.5,-20,0,26)
searchBox.Position = UDim2.new(0,10,0,120)
searchBox.PlaceholderText = "Search player..."
searchBox.Text = ""
searchBox.ClearTextOnFocus = false
searchBox.TextColor3 = Color3.new(1,1,1)
searchBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0,8)

local listFrame = Instance.new("ScrollingFrame", main)
listFrame.Size = UDim2.new(0.5,-20,0,180)
listFrame.Position = UDim2.new(0,10,0,155)
listFrame.ScrollBarThickness = 6
listFrame.BackgroundTransparency = 1
local layout = Instance.new("UIListLayout", listFrame)
layout.Padding = UDim.new(0,6)

--------------------------------------------------
-- CÁC THÀNH PHẦN BÊN PHẢI (PIN LIST)
--------------------------------------------------
local pinSearchBox = Instance.new("TextBox", main)
pinSearchBox.Size = UDim2.new(0.5,-20,0,26)
pinSearchBox.Position = UDim2.new(0.5,10,0,42)
pinSearchBox.PlaceholderText = "Search for pin ESP..."
pinSearchBox.Text = ""
pinSearchBox.ClearTextOnFocus = false
pinSearchBox.TextColor3 = Color3.new(1,1,1)
pinSearchBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
Instance.new("UICorner", pinSearchBox).CornerRadius = UDim.new(0,8)

local pinListFrame = Instance.new("ScrollingFrame", main)
pinListFrame.Size = UDim2.new(0.5,-20,0,234)
pinListFrame.Position = UDim2.new(0.5,10,0,76)
pinListFrame.ScrollBarThickness = 6
pinListFrame.BackgroundTransparency = 1
local pinLayout = Instance.new("UIListLayout", pinListFrame)
pinLayout.Padding = UDim.new(0,6)

--------------------------------------------------
-- LOGIC FUNCTIONS
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
-- REFRESH LISTS (CẬP NHẬT CẢ 2 BÊN)
--------------------------------------------------
local function refreshList()
	-- Xóa list trái
	for _, v in ipairs(listFrame:GetChildren()) do
		if v:IsA("Frame") or v:IsA("TextButton") then v:Destroy() end
	end
	-- Xóa list phải
	for _, v in ipairs(pinListFrame:GetChildren()) do
		if v:IsA("TextButton") then v:Destroy() end
	end

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			-- Bên Trái: Aimbot/SafeList
			if searchBox.Text == "" or plr.Name:lower():find(searchBox.Text:lower()) then
				-- Tạo 1 frame cho mỗi player bao quanh tên + 2 nút
				local row = Instance.new("Frame")
				row.Parent = listFrame
				row.Size = UDim2.new(1,-6,0,28)
				row.BackgroundTransparency = 1
				local namelabel = Instance.new("TextLabel")
				namelabel.Parent = row
				namelabel.Text = plr.Name
				namelabel.Size = UDim2.new(0, 130, 1, 0) -- Rộng hơn để tên dài không bị che
				namelabel.Position = UDim2.new(0, 0, 0, 0)
				namelabel.BackgroundTransparency = 1
				namelabel.TextColor3 = Color3.new(1,1,1)
				namelabel.Font = Enum.Font.Gotham
				namelabel.TextXAlignment = Enum.TextXAlignment.Left
				namelabel.TextSize = 13

				-- Nút SAFE
				local safeBtn = Instance.new("TextButton")
				safeBtn.Parent = row
				safeBtn.Text = "SAFE"
				safeBtn.Size = UDim2.new(0,56,1,0)
				safeBtn.Position = UDim2.new(0, 120, 0, 0) -- Dịch sang trái gần tên hơn (từ 140 về 120)
				safeBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
				safeBtn.TextColor3 = Color3.new(1,1,1)
				safeBtn.Font = Enum.Font.GothamBold
				safeBtn.TextSize = 13
				Instance.new("UICorner", safeBtn).CornerRadius = UDim.new(0,6)
				if safeList[plr.Name] then
					safeBtn.BackgroundColor3 = Color3.fromRGB(80,220,80)
					safeBtn.Text = "SAFE ✔"
				end

				-- Nút KILL
				local killBtn = Instance.new("TextButton")
				killBtn.Parent = row
				killBtn.Text = "KILL"
				killBtn.Size = UDim2.new(0,56,1,0)
				killBtn.Position = UDim2.new(0, 182, 0, 0) -- Dịch sang trái gần tên hơn (từ 202 về 182)
				killBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
				killBtn.TextColor3 = Color3.new(1,1,1)
				killBtn.Font = Enum.Font.GothamBold
				killBtn.TextSize = 13
				Instance.new("UICorner", killBtn).CornerRadius = UDim.new(0,6)
				if killAimTarget and killAimTarget == plr.Name then
					killBtn.BackgroundColor3 = Color3.fromRGB(255,30,30)
					killBtn.Text = "KILL ✔"
				end

				-- Chức năng nút SAFE: loại bỏ aim người này
				safeBtn.MouseButton1Click:Connect(function()
					safeList[plr.Name] = not safeList[plr.Name]
					if safeList[plr.Name] and killAimTarget == plr.Name then
						killAimTarget = nil -- Loại trường hợp kill và safe trùng lúc
					end
					refreshList()
				end)

				-- Chức năng nút KILL: aim duy nhất người này
				killBtn.MouseButton1Click:Connect(function()
					if killAimTarget == plr.Name then
						killAimTarget = nil -- Tắt mode kill
					else
						killAimTarget = plr.Name
						safeList[plr.Name] = false
					end
					refreshList()
				end)
			end

			-- Bên Phải: Pin ESP (thêm filter theo pinSearchBox)
			if pinSearchBox.Text == "" or plr.Name:lower():find(pinSearchBox.Text:lower()) then
				local pinBtn = Instance.new("TextButton", pinListFrame)
				pinBtn.Size = UDim2.new(1,-6,0,28)
				pinBtn.Text = (pinnedPlayers[plr.Name] and "📌 " or "") .. plr.Name
				pinBtn.Font = Enum.Font.Gotham
				pinBtn.TextSize = 13
				pinBtn.TextColor3 = Color3.new(1,1,1)
				pinBtn.BackgroundColor3 = pinnedPlayers[plr.Name]
					and Color3.fromRGB(150,50,50)
					or Color3.fromRGB(40,40,40)
				Instance.new("UICorner", pinBtn).CornerRadius = UDim.new(0,6)

				pinBtn.MouseButton1Click:Connect(function()
					pinnedPlayers[plr.Name] = not pinnedPlayers[plr.Name]
					refreshList()
				end)
			end
		end
	end

	task.wait()
	listFrame.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 6)
	pinListFrame.CanvasSize = UDim2.new(0,0,0,pinLayout.AbsoluteContentSize.Y + 6)
end

--------------------------------------------------
-- EVENTS
--------------------------------------------------
followBtn.MouseButton1Click:Connect(toggleFollow)
hotkeyBtn.MouseButton1Click:Connect(function()
	waitingForKey = true
	hotkeyBtn.Text = "Press a key..."
end)
minimizeBtn.MouseButton1Click:Connect(function() setMinimized(true) end)
aimIcon.MouseButton1Click:Connect(function() setMinimized(false) end)
lockBtn.MouseButton1Click:Connect(function()
	locked = not locked
	main.Draggable = not locked
	aimIcon.Draggable = not locked
	lockBtn.Text = locked and "🔒" or "🔓"
end)

UIS.InputBegan:Connect(function(input, gp)
	if UIS:GetFocusedTextBox() then return end
	if input.KeyCode == hotkey then toggleFollow() return end
	if gp then return end
	if input.UserInputType == Enum.UserInputType.MouseButton2 and following then
		holdingRight = true
		local mousePos = UIS:GetMouseLocation()
		local closest, dist = nil, math.huge
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
				local isSafe = safeList[plr.Name]
				if killAimTarget then
					if plr.Name ~= killAimTarget then
						isSafe = true
					end
				end
				if not isSafe then
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

UIS.InputBegan:Connect(function(input)
	if waitingForKey and input.KeyCode ~= Enum.KeyCode.Unknown then
		hotkey = input.KeyCode
		hotkeyBtn.Text = "Hotkey: " .. hotkey.Name
		waitingForKey = false
	end
end)

RunService.RenderStepped:Connect(function()
	if holdingRight and targetPlayer and targetPlayer.Character then
		local head = targetPlayer.Character:FindFirstChild("Head")
		if head then
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
		end
	end
end)

searchBox:GetPropertyChangedSignal("Text"):Connect(refreshList)
pinSearchBox:GetPropertyChangedSignal("Text"):Connect(refreshList)
Players.PlayerAdded:Connect(refreshList)
Players.PlayerRemoving:Connect(function(p)
	pinnedPlayers[p.Name] = nil -- Xóa khỏi pin nếu out
	if killAimTarget == p.Name then
		killAimTarget = nil
	end
	safeList[p.Name] = nil
	refreshList()
end)

refreshList()
updateFollowUI()

task.delay(3, function()
	main.Visible = true
end)

end)
