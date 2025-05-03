local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")

local Shared = script.Parent:WaitForChild("Shared")
local ReactLua = Shared:WaitForChild("ReactLua")

local LocalPlayer = Players.LocalPlayer
local Camera = game.Workspace.CurrentCamera
local React = require(ReactLua.React)
local ReactRoblox = require(ReactLua.ReactRoblox)
local Utils = require(Shared.Utils)
local BorderSnap = require(script.Parent.BorderSnap)
local Types = require(Shared.Types)
local BlipIcon = require(Shared.BlipIcon)

local Marker = {} :: Types.MarkerClass
Marker.__index = Marker

function Marker:UpdateSize()
	local MapData = self.MapData
	local Settings = self.Settings
	local Size = Settings.Size
	local NewSize = UDim2.fromOffset(0,0)
	local MarkerScale = MapData.Settings.Gui.MarkerScale

	if MapData.IsMinimap then
		NewSize = Utils.UDim2Times(Size, MarkerScale.Minimap)
	else
		NewSize = Utils.UDim2Times(Size, MarkerScale.BigMap)
	end

	self:SetSize(NewSize)
end

function Marker:UpdatePosition()
	local Settings = self.Settings
	local obj = self.obj
	local MapData = self.MapData
	local newpos = Vector3.zero
	local map = self.Gui.Parent
	local cmap = MapData.Settings.MapData[MapData.CurrentMap]
	local center = Vector3.new(cmap.Map.Center.X, 0, cmap.Map.Center.Y)
	if obj:IsA("Model") then
		if obj.PrimaryPart then 
			newpos = obj.PrimaryPart.Position
		else
			local cf = obj:GetBoundingBox()
			newpos = cf.Position
		end
	elseif obj:IsA("BasePart") then
		newpos = obj.Position
	elseif obj:IsA("Attachment") then
		newpos = obj.Position
	end

	if not MapData.IsMinimap then
		self.Gui.Parent = MapData.MapFrame.MapView.RotateFrame.MapImage
	else
		self.Gui.Parent = MapData.MapFrame.MarkerView
	end

	if MapData.NorthMarker and MapData.NorthMarker == self then
		newpos = Vector3.new(0, 0, 10000 * MapData.mapView.Scale)
	end

	newpos -= center

	local IsBlowMax = Utils.getDistanceFromPlayer(LocalPlayer,newpos) <= MapData.Settings.Gui.MaxMarkerDistance

	local GuiPos = UDim2.new()
	local Visible = true
	if MapData.IsMinimap and (IsBlowMax or MapData.NorthMarker and MapData.NorthMarker == self) and (Settings.VisibleType == "Minimap" or Settings.VisibleType == "Both") then
		local Pos = MapData.Convert:ToMap(newpos)
		local mapRotationRad = math.rad(self.MapData.Rotation)

		local mapX = newpos.X / cmap.Map.Size.X
		local mapY = newpos.Z / cmap.Map.Size.Y

		local cosR = math.cos(mapRotationRad)
		local sinR = math.sin(mapRotationRad)
		local rotatedX = mapX * cosR - mapY * sinR
		local rotatedY = mapX * sinR + mapY * cosR
		local rotatedWorldX = rotatedX * cmap.Map.Size.X + cmap.Map.Center.X
		local rotatedWorldZ = rotatedY * cmap.Map.Size.Y + cmap.Map.Center.Y

		local rotatedVector3
		if obj:IsA("BasePart") or obj:IsA("Attachment") then
			rotatedVector3 = Vector3.new(rotatedWorldX, newpos.Y, rotatedWorldZ)
		elseif obj:IsA("Model") and obj.PrimaryPart then
			rotatedVector3 = Vector3.new(rotatedWorldX, newpos.Y, rotatedWorldZ)
		end
		
		self.IDK.Position = Utils.Vector2ToUDim2Offset(MapData.Convert:ToMap2(newpos))
		if Settings.SnapToBorder == true and MapData.IsMinimap then
			Visible = true
			if MapData.NorthMarker and MapData.NorthMarker == self then
				Pos = MapData.Convert:ToMap(rotatedVector3)
				Pos = BorderSnap:ClampToBorder(Pos, MapData.MapFrame.MarkerView.AbsoluteSize, MapData.Settings.Gui.Minimap.CornerRadius)
			else
				Pos = BorderSnap:ClampToBorder(self.IDK.AbsolutePosition - MapData.MapFrame.MarkerView.AbsolutePosition, MapData.MapFrame.MarkerView.AbsoluteSize, MapData.Settings.Gui.Minimap.CornerRadius)
			end
		else
			local n = BorderSnap:ClampToBorder(MapData.Convert:ToMap2(newpos), MapData.MapFrame.MarkerView.AbsoluteSize, MapData.Settings.Gui.Minimap.CornerRadius)
			if n.X ~= Pos.X or n.Y ~= Pos.Y then
				Visible = false
			elseif self.Gui.Visible == false then
				Visible = true
			end
		end

		if obj == Players.LocalPlayer.Character and MapData.IsMinimap then
			GuiPos = UDim2.fromScale(.5, .5)
		else	
			GuiPos = Utils.Vector2ToUDim2Offset(Pos)
		end
	elseif not MapData.IsMinimap and MapData.NorthMarker and (Settings.VisibleType == "Bigmap" or Settings.VisibleType == "Both") then
		Visible = true
		GuiPos = Utils.Vector2ToUDim2Offset(MapData.Convert:ToMap2(newpos))
	else
		Visible = false
	end

	self:SetVisible(Visible)
	if Visible then
		self:SetPosition(GuiPos)
	end
end

function Marker:UpdateRotation()
	local MapData = self.MapData
	local Settings = self.Settings
	local Rotation = 0
	local mapRotation = MapData.Rotation

	local direction = Camera.CFrame.lookVector
	local heading = math.atan2(direction.x,direction.z)
	heading = math.deg(heading)

	if self.Type == "LocalPlayer" then
		local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:wait()

		local rootpart = char:FindFirstChild("HumanoidRootPart")
		if rootpart then
			local orientation = rootpart.Orientation.Y

			if char:WaitForChild("Humanoid"):GetState() == Enum.HumanoidStateType.Swimming then
				orientation = heading - 180
			end

			Rotation = -(orientation - mapRotation)
		else
			Rotation = 0
		end
	elseif self.Type == "Player" then
		local char = self.obj.Character or self.obj.CharacterAdded:wait()

		local rootpart = char:FindFirstChild("HumanoidRootPart")
		if rootpart then
			local orientation = rootpart.Orientation.Y

			if char:WaitForChild("Humanoid"):GetState() == Enum.HumanoidStateType.Swimming then
				orientation = heading - 180
			end

			Rotation = -(orientation - mapRotation)
		else
			Rotation = 0
		end
	else
		if Settings.Rotate then
			Rotation = -((heading - self.obj.Orientation.Y + 180) - mapRotation)
		else
			Rotation = 0
		end
	end
	
	self:SetRotation(Rotation)
end

function Marker:SetPosition(Position)
	self.Gui.Position = Position
end

function Marker:SetRotation(Rotation)
	self.Gui.Rotation = Rotation
	if self.Type == "LocalPlayer" or self.Type == "Player" then
		self.Gui.RotFix.Rotation = -Rotation
	end
end

function Marker:SetSize(Size: UDim2)
	self.Gui.Size = Size
end

function Marker:SetIcon(Id)
	self.Gui.Icon.Image = `rbxassetId://{Id}`
	self.Gui.Icon.Visible = true
	self.Gui.Label.Visible = false
end

function Marker:SetIconText(Text)
	self.Gui.Icon.Visible = false
	self.Gui.Label.Visible = true
	self.Gui.Label.Text = Text
end

function Marker:SetShape(Id)
	self.Gui.Image = `rbxassetId://{Id}`
end

function Marker:SetIconColor(Color)
	self.Gui.Icon.ImageColor3 = Color
end

function Marker:SetShapeColor(Color)
	self.Gui.ImageColor3 = Color
end

function Marker:SetVisible(Visible)
	self.Gui.Visible = Visible
end

function Marker:GetPosition()
	return self.Gui.AbsolutePosition
end

function Marker:GetWorldPosition() : Vector3
	local obj = self.obj
	local newpos

	if obj:IsA("Model") then
		if obj.PrimaryPart then 
			newpos = obj.PrimaryPart.Position
		else
			local cf = obj:GetBoundingBox()
			newpos = cf.Position
		end
	elseif obj:IsA("BasePart") then
		newpos = obj.Position
	elseif obj:IsA("Attachment") then
		newpos = obj.Position
	end

	return newpos
end

function Marker:GetGui()
	return self.Gui
end

function Marker:GetInstance()
	return self.obj
end

function Marker:PlayerIcon(Name)
	Name = Name:gsub("MinimapMarker","")
	local Player = Players:FindFirstChild(Name)
	if Player then
		local succ, icon = pcall(function()
			return Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
		end)

		if succ then
			return icon
		end
	end

	return nil
end

function Marker:DisplayName(Name)
	Name = Name:gsub("MinimapMarker","")
	local Player = Players:FindFirstChild(Name)
	if Player then
		return Player.DisplayName
	end

	return nil
end

function Marker:GUI()
	local Settings = self.Settings
	local instance = self.obj
	local MapData = self.MapData
	local MapScreen = MapData.Map
	local MapFrame = MapData.MapFrame
	local MapView = MapFrame.MapView
	local MarkerView = MapFrame.MarkerView
	local MapImage = MapView.RotateFrame.MapImage

	local Shape = Settings.ShapeID
	local ShapeColor = Settings.ShapeColor
	local Size = Settings.Size
	local IconID = Settings.IconID
	local ToolTip = Settings.ToolTip
	local ToolTipColor = Settings.ToolTipColor
	local Color = Settings.Color
	local Id = HttpService:GenerateGUID(false)

	local BlipIcon = typeof(IconID) == "string" and BlipIcon.GetIconData(IconID) or nil
	local ImageId = BlipIcon and BlipIcon.Image or IconID == "PlayerHead" and self:PlayerIcon(instance.Name) or tonumber(IconID) and "rbxassetid://"..IconID or nil
	local ImageOffset = BlipIcon and BlipIcon.ImageRectOffset or Vector2.new()
	local ImageSize = BlipIcon and BlipIcon.ImageRectSize or Vector2.new()

	local function Render(props)
		local Label = React.useRef(nil)

		return ReactRoblox.createPortal(React.createElement("ImageLabel", {
			Name = instance.Name:gsub("MinimapMarker",""),
			Active = true,
			Image = `rbxassetid://{Shape}`,
			ImageColor3 = ShapeColor,
			Size = Size,
			AnchorPoint = Vector2.new(.5,.5),
			BackgroundTransparency = 1,
			Rotation = MapData.Rotation,
			ZIndex = Settings.Index,
			[React.Tag] = Id,
			[React.Event.InputBegan] = function(rbx, input)
				if Utils.IsMainInputMove(input) then
					if (MapData.IsMinimap or IconID == "PlayerHead") and Label.current then
						Label.current.Visible = true
					end
				end
			end,
			[React.Event.InputEnded] = function(rbx, input)
				if Utils.IsMainInputMove(input) and Label.current then
					Label.current.Visible = false
				end
			end,
		},{
			UIAspectRatioConstraint = React.createElement("UIAspectRatioConstraint"),
			Arrow = React.createElement("Frame", {
				Size = UDim2.fromScale(.5, .5),
				Rotation = 45,
				Position = UDim2.fromScale(.5, .17),
				BackgroundColor3 = ShapeColor,
				BorderSizePixel = 0,
				AnchorPoint = Vector2.new(.5, .5),
				Name = "Arrow",
				Visible = self.Type == "LocalPlayer" or self.Type == "Player",
				ZIndex = Settings.Index,
			}),
			RotFix = React.createElement("ImageLabel", {
				Size = UDim2.fromScale(1,1),
				AnchorPoint = Vector2.new(.5,.5),
				Position = UDim2.new(0.5,0,0.5,0),
				Image = "",
				BackgroundTransparency = 1,
				ImageColor3 = Color,
				Name = "RotFix",
				ZIndex = Settings.Index + 1,
			}, {
				TooltipLabel = React.createElement("TextLabel", {
					Text = ToolTip == "Name" and instance.Name:gsub("MinimapMarker","") or ToolTip == "DisplayName" and self:DisplayName( instance.Name:gsub("MinimapMarker","")) or ToolTip,
					TextColor3 = ToolTipColor,
					BackgroundTransparency = 1,
					AnchorPoint = Vector2.new(0.5,0),
					Position = UDim2.new(0.5,0,1,0),
					Size = UDim2.new(3,0,1,0),
					Visible = false,
					Font = MapData.Settings.Fonts.primaryFont,
					TextScaled = true,
					Name = "TooltipLabel",
					ZIndex = Settings.Index + 1,
					ref = Label
				}),
				Label = React.createElement("TextLabel", { 
					Size = UDim2.fromScale(0.75,0.75),
					AnchorPoint = Vector2.new(.5,.5),
					Position = UDim2.new(0.5,0,0.5,0),
					BackgroundTransparency = 1,
					Text = IconID,
					TextColor3 = Color,
					Font = MapData.Settings.Fonts.primaryFont,
					TextScaled = true,
					Name = "Label",
					ZIndex = Settings.Index + 1,
					Visible = (ImageId == nil),
				}),
				Icon = React.createElement("ImageLabel", {
					Size = UDim2.fromScale(0.75,0.75),
					AnchorPoint = Vector2.new(.5,.5),
					Position = UDim2.new(0.5,0,0.5,0),
					Image = ImageId,
					ImageRectOffset = ImageOffset ,
					ImageRectSize = ImageSize,
					BackgroundTransparency = 1,
					ImageColor3 = Color,
					Name = "Icon",
					ZIndex = Settings.Index + 1,
					Visible = (ImageId ~= nil),
				}, {
					IconID == "PlayerHead" and React.createElement("UICorner", {
						CornerRadius = UDim.new(1,0)
					}) or nil,
				})
			})
		}), MapImage)
	end

	local root = ReactRoblox.createRoot(Instance.new("Folder"))
	root:render(React.createElement(Render))

	repeat task.wait() until #CollectionService:GetTagged(Id) == 1
	self.IDK.Parent = MapImage
	return CollectionService:GetTagged(Id)[1]
end

function Marker:Destroy()
	self.Gui:Destroy()
end

return function(MapData: Types.MapClass, Settings: Types.Tag, instacne: Types.instance, Type: string)
	local self = setmetatable({}, Marker)
	self.MapData = MapData
	self.Settings = Settings
	self.obj = instacne
	self.Type = Type
	local IDK = Instance.new("Frame")
	IDK.BackgroundTransparency = 1
	IDK.Size = UDim2.fromScale(0,0)
	self.IDK = IDK
	self.Gui = self:GUI()
	return self
end