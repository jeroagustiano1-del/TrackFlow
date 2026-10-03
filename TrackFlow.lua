local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Character
local Humanoid
local Root

local Tracks = {}
local SavedTracks = {}

local Recording = false
local Playing = false
local Paused = false
local Loop = false
local ESP = false
local CarryMode = false

local Speeds = {0.5, 1, 2, 4}
local SpeedIndex = 2

local PlayTime = 0
local TrackIndex = 1

local SampleRate = 1 / 30
local LastSample = 0
local RecordStart = 0


--------------------------------------------------
-- CHARACTER
--------------------------------------------------

local function SetupCharacter()
	Character = Player.Character or Player.CharacterAdded:Wait()

	Humanoid = Character:WaitForChild("Humanoid")
	Root = Character:WaitForChild("HumanoidRootPart")
end

SetupCharacter()

Player.CharacterAdded:Connect(function()
	task.wait(0.3)
	SetupCharacter()
end)


--------------------------------------------------
-- GUI
--------------------------------------------------

local Gui = Instance.new("ScreenGui")
Gui.Name = "TrackFlowGui"
Gui.ResetOnSpawn = false
Gui.Parent = PlayerGui


local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(300, 450)
Main.Position = UDim2.new(1, -315, 0.5, -225)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Main.Visible = false
Main.Parent = Gui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main


--------------------------------------------------
-- BUTTON
--------------------------------------------------

local function CreateButton(Name, Text, X, Y, Width, Parent)

	local Button = Instance.new("TextButton")

	Button.Name = Name
	Button.Text = Text

	Button.Position = UDim2.fromOffset(X, Y)
	Button.Size = UDim2.fromOffset(Width or 85, 35)

	Button.BackgroundColor3 = Color3.fromRGB(35, 35, 43)
	Button.TextColor3 = Color3.new(1, 1, 1)

	Button.BorderSizePixel = 0
	Button.Parent = Parent or Main

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 7)
	Corner.Parent = Button

	return Button
end


--------------------------------------------------
-- TITLE
--------------------------------------------------

local Title = CreateButton(
	"Title",
	"TRACKFLOW",
	10,
	10,
	280
)


--------------------------------------------------
-- BUTTONS
--------------------------------------------------

local RecordButton = CreateButton(
	"Record",
	"● REC",
	10,
	55
)

local PlayButton = CreateButton(
	"Play",
	"▶ PLAY",
	105,
	55
)

local PauseButton = CreateButton(
	"Pause",
	"Ⅱ PAUSE",
	200,
	55
)


local StopButton = CreateButton(
	"Stop",
	"■ STOP",
	10,
	100
)

local RewindButton = CreateButton(
	"Rewind",
	"↶ REWIND",
	105,
	100
)

local ESPButton = CreateButton(
	"ESP",
	"ESP OFF",
	200,
	100
)


local SpeedButton = CreateButton(
	"Speed",
	"1x",
	10,
	145
)

local LoopButton = CreateButton(
	"Loop",
	"LOOP OFF",
	105,
	145
)

local SaveButton = CreateButton(
	"Save",
	"SAVE",
	200,
	145
)


--------------------------------------------------
-- CARRY MODE
--------------------------------------------------

local CarryButton = CreateButton(
	"CarryMode",
	"CARRY OFF",
	10,
	190,
	275
)

CarryButton.BackgroundColor3 =
	Color3.fromRGB(45, 35, 50)


--------------------------------------------------
-- NAME BOX
--------------------------------------------------

local NameBox = Instance.new("TextBox")

NameBox.Name = "TrackName"
NameBox.PlaceholderText = "Nama track..."
NameBox.Text = ""

NameBox.Position = UDim2.fromOffset(10, 235)
NameBox.Size = UDim2.fromOffset(275, 35)

NameBox.BackgroundColor3 =
	Color3.fromRGB(30, 30, 37)

NameBox.TextColor3 =
	Color3.new(1, 1, 1)

NameBox.BorderSizePixel = 0
NameBox.Parent = Main

local NameCorner = Instance.new("UICorner")
NameCorner.CornerRadius = UDim.new(0, 7)
NameCorner.Parent = NameBox


--------------------------------------------------
-- TRACK LIST
--------------------------------------------------

local TrackList = Instance.new("ScrollingFrame")

TrackList.Name = "TrackList"

TrackList.Position = UDim2.fromOffset(10, 280)
TrackList.Size = UDim2.fromOffset(275, 120)

TrackList.BackgroundColor3 =
	Color3.fromRGB(27, 27, 33)

TrackList.BorderSizePixel = 0
TrackList.ScrollBarThickness = 4

TrackList.Parent = Main


local ListLayout = Instance.new("UIListLayout")

ListLayout.Padding = UDim.new(0, 4)
ListLayout.Parent = TrackList


--------------------------------------------------
-- TF BUTTON
--------------------------------------------------

local TFButton = CreateButton(
	"TF",
	"TF",
	0,
	0,
	50,
	Gui
)

TFButton.Position =
	UDim2.new(1, -60, 0.5, -25)


--------------------------------------------------
-- CLOSE
--------------------------------------------------

local CloseButton = CreateButton(
	"Close",
	"×",
	260,
	10,
	30
)


--------------------------------------------------
-- PATH
--------------------------------------------------

local PathFolder =
	workspace:FindFirstChild("TrackFlowPath")

if not PathFolder then

	PathFolder = Instance.new("Folder")

	PathFolder.Name =
		"TrackFlowPath"

	PathFolder.Parent =
		workspace
end


--------------------------------------------------
-- STATUS
--------------------------------------------------

local function SetStatus(Text)
	Title.Text = Text
end


--------------------------------------------------
-- CLEAR PATH
--------------------------------------------------

local function ClearPath()

	for _, Object in ipairs(
		PathFolder:GetChildren()
	) do

		Object:Destroy()
	end
end


--------------------------------------------------
-- DRAW PATH
--------------------------------------------------

local function DrawPath()

	ClearPath()

	if not ESP then
		return
	end

	if #Tracks < 2 then
		return
	end


	for Index = 1, #Tracks - 1 do

		local A =
			Tracks[Index].CFrame

		local B =
			Tracks[Index + 1].CFrame


		local Distance =
			(A.Position - B.Position).Magnitude


		if Distance > 0.05 then

			local Part =
				Instance.new("Part")

			Part.Anchored = true
			Part.CanCollide = false
			Part.CanTouch = false
			Part.CanQuery = false

			Part.Material =
				Enum.Material.Neon

			Part.Size =
				Vector3.new(
					0.1,
					0.1,
					Distance
				)


			Part.CFrame =
				CFrame.lookAt(
					(A.Position + B.Position) / 2,
					B.Position
				)


			Part.Parent =
				PathFolder
		end
	end
end


--------------------------------------------------
-- MOVE CHARACTER
--------------------------------------------------

local function MoveCharacter(TargetCFrame)

	if not Character then
		return
	end

	if not Character.Parent then
		return
	end

	Character:PivotTo(TargetCFrame)
end


--------------------------------------------------
-- CARRY MODE
--------------------------------------------------

CarryButton.MouseButton1Click:Connect(function()

	CarryMode =
		not CarryMode


	if CarryMode then

		CarryButton.Text =
			"CARRY ON"

		CarryButton.BackgroundColor3 =
			Color3.fromRGB(70, 45, 80)

		SetStatus(
			"CARRY MODE"
		)

	else

		CarryButton.Text =
			"CARRY OFF"

		CarryButton.BackgroundColor3 =
			Color3.fromRGB(45, 35, 50)

		SetStatus(
			"NORMAL MODE"
		)
	end
end)


--------------------------------------------------
-- RECORD
--------------------------------------------------

RecordButton.MouseButton1Click:Connect(function()

	if Recording then

		Recording = false

		SetStatus(
			"REC DONE"
		)

		return
	end


	Tracks = {}

	Recording = true
	Playing = false
	Paused = false

	PlayTime = 0
	TrackIndex = 1

	RecordStart =
		os.clock()

	LastSample = 0


	if CarryMode then

		SetStatus(
			"REC • CARRY"
		)

	else

		SetStatus(
			"RECORDING"
		)
	end
end)


--------------------------------------------------
-- PLAY
--------------------------------------------------

PlayButton.MouseButton1Click:Connect(function()

	if #Tracks < 2 then

		SetStatus(
			"NO TRACK"
		)

		return
	end


	Recording = false
	Playing = true
	Paused = false

	PlayTime = 0
	TrackIndex = 1


	MoveCharacter(
		Tracks[1].CFrame
	)


	if CarryMode then

		SetStatus(
			"PLAY • CARRY"
		)

	else

		SetStatus(
			"PLAYING"
		)
	end
end)


--------------------------------------------------
-- PAUSE
--------------------------------------------------

PauseButton.MouseButton1Click:Connect(function()

	if not Playing then
		return
	end


	Paused =
		not Paused


	if Paused then

		SetStatus(
			"PAUSED"
		)

	else

		if CarryMode then

			SetStatus(
				"PLAY • CARRY"
			)

		else

			SetStatus(
				"PLAYING"
			)
		end
	end
end)


--------------------------------------------------
-- STOP
--------------------------------------------------

StopButton.MouseButton1Click:Connect(function()

	Recording = false
	Playing = false
	Paused = false

	SetStatus(
		"STOP"
	)
end)


--------------------------------------------------
-- REWIND
--------------------------------------------------

RewindButton.MouseButton1Click:Connect(function()

	if #Tracks < 2 then
		return
	end


	PlayTime =
		math.max(
			0,
			PlayTime - 1
		)

	TrackIndex = 1


	while
		TrackIndex < #Tracks
		and
		Tracks[TrackIndex + 1].Time
			<= PlayTime
	do

		TrackIndex += 1
	end


	if TrackIndex < #Tracks then

		local A =
			Tracks[TrackIndex]

		local B =
			Tracks[TrackIndex + 1]


		local Difference =
			math.max(
				B.Time - A.Time,
				0.001
			)


		local Alpha =
			math.clamp(
				(PlayTime - A.Time)
				/ Difference,
				0,
				1
			)


		MoveCharacter(
			A.CFrame:Lerp(
				B.CFrame,
				Alpha
			)
		)

	else

		MoveCharacter(
			Tracks[#Tracks].CFrame
		)
	end
end)


--------------------------------------------------
-- SPEED
--------------------------------------------------

SpeedButton.MouseButton1Click:Connect(function()

	SpeedIndex =
		SpeedIndex % #Speeds + 1

	SpeedButton.Text =
		Speeds[SpeedIndex] .. "x"
end)


--------------------------------------------------
-- LOOP
--------------------------------------------------

LoopButton.MouseButton1Click:Connect(function()

	Loop =
		not Loop


	if Loop then

		LoopButton.Text =
			"LOOP ON"

	else

		LoopButton.Text =
			"LOOP OFF"
	end
end)


--------------------------------------------------
-- ESP
--------------------------------------------------

ESPButton.MouseButton1Click:Connect(function()

	ESP =
		not ESP


	if ESP then

		ESPButton.Text =
			"ESP ON"

	else

		ESPButton.Text =
			"ESP OFF"
	end


	DrawPath()
end)


--------------------------------------------------
-- SAVE
--------------------------------------------------

SaveButton.MouseButton1Click:Connect(function()

	if #Tracks < 2 then

		SetStatus(
			"NO TRACK"
		)

		return
	end


	local TrackName

	if NameBox.Text ~= "" then

		TrackName =
			NameBox.Text

	else

		TrackName =
			"Track " ..
			(#SavedTracks + 1)
	end


	SavedTracks[TrackName] = {}


	for Index, Data in ipairs(Tracks) do

		SavedTracks[TrackName][Index] = {

			Time =
				Data.Time,

			CFrame =
				Data.CFrame
		}
	end


	local TrackButton =
		CreateButton(
			TrackName,
			TrackName,
			0,
			0,
			255,
			TrackList
		)


	TrackButton.MouseButton1Click:Connect(function()

		Tracks = {}


		for Index, Data in ipairs(
			SavedTracks[TrackName]
		) do

			Tracks[Index] = {

				Time =
					Data.Time,

				CFrame =
					Data.CFrame
			}
		end


		PlayTime = 0
		TrackIndex = 1


		DrawPath()


		SetStatus(
			"LOADED " ..
			TrackName
		)
	end)
end)


--------------------------------------------------
-- CLOSE
--------------------------------------------------

CloseButton.MouseButton1Click:Connect(function()

	Main.Visible = false
	TFButton.Visible = true
end)


--------------------------------------------------
-- OPEN
--------------------------------------------------

TFButton.MouseButton1Click:Connect(function()

	Main.Visible = true
	TFButton.Visible = false
end)


--------------------------------------------------
-- RECORD LOOP
--------------------------------------------------

RunService.Heartbeat:Connect(function()

	if not Recording then
		return
	end

	if not Root or not Root.Parent then
		return
	end


	local CurrentTime =
		os.clock() -
		RecordStart


	if CurrentTime - LastSample
		>= SampleRate then

		LastSample =
			CurrentTime


		Tracks[#Tracks + 1] = {

			Time =
				CurrentTime,

			CFrame =
				Root.CFrame
		}
	end
end)


--------------------------------------------------
-- PLAY LOOP
--------------------------------------------------

RunService.Heartbeat:Connect(function(DeltaTime)

	if not Playing then
		return
	end

	if Paused then
		return
	end

	if #Tracks < 2 then
		return
	end


	if not Character
		or not Character.Parent then

		SetupCharacter()

		return
	end


	PlayTime +=
		DeltaTime *
		Speeds[SpeedIndex]


	while
		TrackIndex < #Tracks
		and
		Tracks[TrackIndex + 1].Time
			<= PlayTime
	do

		TrackIndex += 1
	end


	if TrackIndex >= #Tracks then

		if Loop then

			PlayTime = 0
			TrackIndex = 1

			MoveCharacter(
				Tracks[1].CFrame
			)

		else

			Playing = false

			SetStatus(
				"PLAY DONE"
			)

			MoveCharacter(
				Tracks[#Tracks].CFrame
			)
		end

		return
	end


	local A =
		Tracks[TrackIndex]

	local B =
		Tracks[TrackIndex + 1]


	local Difference =
		math.max(
			B.Time - A.Time,
			0.001
		)


	local Alpha =
		math.clamp(
			(PlayTime - A.Time)
			/ Difference,
			0,
			1
		)


	local NewCFrame =
		A.CFrame:Lerp(
			B.CFrame,
			Alpha
		)


	MoveCharacter(
		NewCFrame
	)
end)
