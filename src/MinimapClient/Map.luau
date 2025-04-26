local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local StarterGui = game:GetService("StarterGui")
local TextService = game:GetService("TextService")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Shared = script.Parent:WaitForChild("Shared")
local ReactLua = Shared:WaitForChild("ReactLua")
local React = require(ReactLua.React)
local ReactRoblox = require(ReactLua.ReactRoblox)
local Utils = require(Shared.Utils)
local ConvertPosition = require(script.Parent.ConvertPosition)
local Marker = require(script.Parent.Marker)
local Types = require(Shared.Types)
local BlipIcon = require(Shared.BlipIcon)

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	Camera = workspace.CurrentCamera
end)

local Map
local LocalPlayerMarker
local MinimapSettings
local MapClass = {} :: Types.MapClass
MapClass.__index = MapClass

function GetMarkerByIndex(List: {Types.MarkerClass}, Index)
	for _, class in List do
		if class.Index == Index then
			return class
		end
	end

	return nil
end

function getTextSize(text: string, Max: Vector2?, FontSize: number, Font: Enum.Font)
	local size = TextService:GetTextSize(text, FontSize, Font, Max)
	return Vector2.new(math.ceil(size.X), math.ceil(size.Y)) + Vector2.one
end

function StringPathToArray(path)
	local path_array = {}
	if path ~= "" then
		for s in string.gmatch(path, "[^%.]+") do
			table.insert(path_array, s)
		end
	end
	return path_array
end

function GetParent(path: string | {string})
	if path == nil then return end
	local path_array = (type(path) == "string") and StringPathToArray(path) or path

	local Data = Player.PlayerGui
	for _, next in path_array do
		local succes, inst = pcall(function()
			return Data[next]
		end)

		if not inst then
			return nil
		end

		Data = inst
	end
	if Data ~= Player.PlayerGui then
		return Data
	end
end

function MapClass:Step()
	if self.Enabled then
		self:Update()
		self:UpdateMakers()
	end

	local MapScreen = self.Map
	MapScreen.Enabled = self.Enabled
	self.MapFrame.Visible = self.Enabled
end

function MapClass:MarkerById(Id)
	for marker,class in self.Markers do
		if marker:GetAttribute("Id") ~= nil and marker:GetAttribute("Id") == Id then
			return class
		end
	end
end

function MapClass:Update()
	local Character = Player.Character or Player.CharacterAdded:Wait()
	if not Character or not Character.PrimaryPart then return end

	local MapDragedUDim = self.MapDragedUDim
	local Settings = self.Settings
	local MapSettings = Settings.MapData[self.CurrentMap]
	local GuiSettings = Settings.Gui
	local GuiMinimap = GuiSettings.Minimap
	local GuiBigmap = GuiSettings.Bigmap

	local MapScreen = self.Map
	local MapFrame = self.MapFrame
	if not MapFrame:IsDescendantOf(Player.PlayerGui) then return end
	local MapView = MapFrame.MapView
	local MarkerView = MapFrame.MarkerView
	local MapImage = MapView.RotateFrame.MapImage
	local UIScale = MapImage.UIScale
	local AspectRatio = MapScreen.AbsoluteSize.X/MapScreen.AbsoluteSize.Y

	if self.IsMinimap then
		local Center = Vector3.new(MapSettings.Map.Center.X, 0, MapSettings.Map.Center.Y)
		local Pos = Character.PrimaryPart.Position - Center	
		local Focus = self.Convert:ToMap2(Pos)
		self.mapView.FocusX = Focus.X
		self.mapView.FocusY = Focus.Y
		MapFrame.UIAspectRatioConstraint.AspectRatio = GuiMinimap.AspectRatio
		MapFrame.Size = GuiMinimap.Size
		MapFrame.Position = GuiMinimap.Position
		MapFrame.AnchorPoint = GuiMinimap.AnchorPoint
		MapFrame.BackgroundColor3 = GuiMinimap.BackgroundColor
		MapFrame.UIStroke.Color = GuiMinimap.BorderColor
		MapFrame.UIStroke.Thickness = GuiMinimap.BorderSize
		if self.NorthMarker then
			self.NorthMarker:SetVisible(true)
		end
		for i,v in self.UICorner do
			v.CornerRadius = GuiMinimap.CornerRadius
		end
		MapFrame.MarkerList.Visible = false
		MapFrame.Parent = GetParent(GuiMinimap.Parent) or MapScreen
	else
		self.mapView.FocusX = MapSettings.Map.Size.X / 2
		self.mapView.FocusY = MapSettings.Map.Size.Y / 2
		MapFrame.UIAspectRatioConstraint.AspectRatio = GuiBigmap.AspectRatio or AspectRatio
		MapFrame.Size = GuiBigmap.Size
		MapFrame.Position = GuiBigmap.Position
		MapFrame.AnchorPoint = GuiBigmap.AnchorPoint
		MapFrame.BackgroundColor3 = GuiBigmap.BackgroundColor
		MapFrame.UIStroke.Color = GuiBigmap.BorderColor
		MapFrame.UIStroke.Thickness = GuiBigmap.BorderSize
		if self.NorthMarker then
			self.NorthMarker:SetVisible(false)
		end
		for i,v in self.UICorner do
			v.CornerRadius = GuiBigmap.CornerRadius
		end
		MapFrame.MarkerList.Visible = true
		MapFrame.Parent = GetParent(GuiBigmap.Parent) or MapScreen
	end

	UIScale.Scale = self.mapView.Scale
	local relativeFocus = Vector2.new( self.mapView.FocusX / MapSettings.Map.Size.X, self.mapView.FocusY / MapSettings.Map.Size.Y )
	if self.IsMinimap then
		local rx, ry, rz = Camera.CFrame:ToOrientation()
		self.Rotation = GuiSettings.RotateWithCamera and math.deg(ry) or 0
		MapView.RotateFrame.Rotation = self.Rotation
		
		local Size = Vector2.new(
			(MapView.AbsoluteSize.X * 0.5 - MapImage.AbsoluteSize.X * (relativeFocus.X)) + MapImage.AbsoluteSize.X * MapImage.AnchorPoint.X,
			(MapView.AbsoluteSize.Y * 0.5 - MapImage.AbsoluteSize.Y * (relativeFocus.Y)) + MapImage.AbsoluteSize.Y * MapImage.AnchorPoint.Y
		)
		
		MapImage.Position = UDim2.new(
			0, Size.X,
			0, Size.Y
		)
		
	else
		local Size = Vector2.new(
			(MapView.AbsoluteSize.X * 0.5 - MapImage.AbsoluteSize.X * (relativeFocus.X)) + MapImage.AbsoluteSize.X * MapImage.AnchorPoint.X,
			(MapView.AbsoluteSize.Y * 0.5 - MapImage.AbsoluteSize.Y * (relativeFocus.Y)) + MapImage.AbsoluteSize.Y * MapImage.AnchorPoint.Y
		)
		
		MapImage.Position = MapDragedUDim ~= UDim2.new(0,0,0,0) and MapDragedUDim or 
			UDim2.new(
				0, Size.X,
				0, Size.Y
			)

		if self.ToPlayer then
			self.ToPlayer = false
			self:SetFocuseToMarker(Character.PrimaryPart.Position)
		end

		self.Rotation = 0
		MapView.RotateFrame.Rotation = self.Rotation
	end
end


function MapClass:UpdateMakers()
	for obj, class in self.Markers do
		class:UpdatePosition()
		class:UpdateRotation()
		class:UpdateSize()
	end
end

function MapClass:UpdateMakersList()
	local MapScreen = self.Map
	local MapFrame = self.MapFrame
	local MarkerList = MapFrame.MarkerList
	local ToDisplay = {}

	for i,v in MarkerList.Holder:GetChildren() do
		if v:IsA("Frame") and v.Name ~= "Sample" then
			v:Destroy()
		end
	end

	for _, class in self.Markers do
		if self.NorthMarker and class ~= self.NorthMarker then
			if not ToDisplay[class.Tag] then ToDisplay[class.Tag] = {} end
			table.insert(ToDisplay[class.Tag], class)
		elseif not self.NorthMarker then
			if not ToDisplay[class.Tag] then ToDisplay[class.Tag] = {} end
			table.insert(ToDisplay[class.Tag], class)
		end
	end

	for tag, markers in ToDisplay do
		local MarkerOne = GetMarkerByIndex(markers, 1)
		local MarkerSettings = MarkerOne.Settings
		local IconID = MarkerSettings.IconID
		local instance = MarkerOne.obj
		local BlipIcon = typeof(IconID) == "string" and BlipIcon.GetIconData(IconID) or nil
		local ImageId = BlipIcon and BlipIcon.Image or IconID == "PlayerHead" and MarkerOne:PlayerIcon(instance.Name) or tonumber(IconID) and "rbxassetid://"..IconID or nil
		local ImageOffset = BlipIcon and BlipIcon.ImageRectOffset or Vector2.new()
		local ImageSize = BlipIcon and BlipIcon.ImageRectSize or Vector2.new()
		local NewMarkerList: typeof(MarkerList.Holder.Sample) = MarkerList.Holder.Sample:Clone()
		NewMarkerList.Parent = MarkerList.Holder
		NewMarkerList.Visible = true
		NewMarkerList.Label.Text = MarkerSettings.DisplayName
		NewMarkerList.Icon.Image = ImageId
		NewMarkerList.Icon.ImageRectSize = ImageSize
		NewMarkerList.Icon.ImageRectOffset = ImageOffset
		NewMarkerList.Name = MarkerSettings.DisplayName
		local Size = getTextSize(
			MarkerSettings.DisplayName, 
			Vector2.new(math.huge, MapScreen.AbsoluteSize.Y * (MarkerList.Holder.Sample.Size.Y.Scale * 0.6) ), 
			MapScreen.AbsoluteSize.Y * (MarkerList.Holder.Sample.Size.Y.Scale * 0.6),
			NewMarkerList.Label.Font
		)
		NewMarkerList.Label.Size += UDim2.fromOffset(Size.X, 0)
	end
end

function MapClass:SetFocuseToMarker(Position)
	local MapScreen = self.Map
	local Settings = self.Settings
	local MapFrame = self.MapFrame
	local MapView = MapFrame.MapView
	local MapImage = MapView.RotateFrame.MapImage
	local MapSettings = Settings.MapData[self.CurrentMap]
	local Center = Vector3.new(MapSettings.Map.Center.X, 0, MapSettings.Map.Center.Y)
	local Pos = Position - Center
	local FocusX = Pos.X + MapSettings.Map.Size.X / 2
	local FocusY = Pos.Z + MapSettings.Map.Size.Y / 2
	local r = Vector2.new( FocusX / MapSettings.Map.Size.X, FocusY / MapSettings.Map.Size.Y )
	self.MapDragedUDim = Utils.Vector2ToUDim2Offset(MapView.AbsoluteSize * 0.5 - MapImage.AbsoluteSize * r)
end

function MapClass:AddMarker(Settings, instance)
	local GuiMarker = Marker(self, Settings, instance, instance.Name:gsub("MinimapMarker","") == Player.Name and "LocalPlayer" or Players:FindFirstChild(instance.Name:gsub("MinimapMarker","")) and "Player" or "Object")
	GuiMarker:UpdatePosition()
	GuiMarker:UpdateRotation()

	self.Markers[instance] = GuiMarker

	if instance.Name:gsub("MinimapMarker","") == Player.Name then
		LocalPlayerMarker = GuiMarker
	end

	return GuiMarker
end

function MapClass:RemoveMarker(instance)
	if self.Markers[instance] then
		self.Markers[instance]:Destroy()
		self.Markers[instance] = nil
	end
	self:UpdateMakersList()
end

function MapClass:AddMarkerTag(map, tag, tagsettings)
	if self.Connections[`{map}_{tag}_AddedSignal`] then return end
	if not self.TagMarkers[`{map}_{tag}`] then self.TagMarkers[`{map}_{tag}`] = {} end

	self.Connections[`{map}_{tag}_AddedSignal`] = CollectionService:GetInstanceAddedSignal(tag):Connect(function(obj)
		local marker = self:AddMarker(tagsettings, obj)
		marker.Index = #CollectionService:GetTagged(tag)
		marker.Tag = tag
		marker.Map = map
		self.TagMarkers[`{map}_{tag}`][obj] = marker
		self:UpdateMakersList()

		self.Connections[obj] = obj.Destroying:Connect(function()
			self:RemoveMarker(obj)
			self.TagMarkers[`{map}_{tag}`][obj] = nil
			self.Connections[obj]:Disconnect()
			self.Connections[obj] = nil
		end)
	end)

	self.Connections[`{map}_{tag}_GetInstanceRemovedSignal`] = CollectionService:GetInstanceRemovedSignal(tag):Connect(function(obj)
		self:RemoveMarker(obj)
		self.TagMarkers[`{map}_{tag}`][obj] = nil
	end)

	for i,obj in CollectionService:GetTagged(tag) do
		local marker = self:AddMarker(tagsettings, obj)
		marker.Index = i
		marker.Tag = tag
		marker.Map = map
		self.TagMarkers[`{map}_{tag}`][obj] = marker

		self.Connections[obj] = obj.Destroying:Connect(function()
			self:RemoveMarker(obj)
			self.TagMarkers[`{map}_{tag}`][obj] = nil
			self.Connections[obj]:Disconnect()
			self.Connections[obj] = nil
		end)
	end
	self:UpdateMakersList()
end

function MapClass:RemoveMarkerTag(map: string, tag: string)
	if self.Connections[`{map}_{tag}_AddedSignal`] == nil then return end

	self.Connections[`{map}_{tag}_AddedSignal`]:Disconnect()
	self.Connections[`{map}_{tag}_AddedSignal`] = nil

	self.Connections[`{map}_{tag}_GetInstanceRemovedSignal`]:Disconnect()
	self.Connections[`{map}_{tag}_GetInstanceRemovedSignal`] = nil

	for _,obj in CollectionService:GetTagged(tag) do
		self:RemoveMarker(obj)
	end
	self.TagMarkers[`{map}_{tag}`] = nil
end

function MapClass:SwitchMap(NewMap)
	local Settings = self.Settings
	local MapScreen = self.Map
	local MapFrame = self.MapFrame
	local MapView = MapFrame.MapView
	if not self.StoredMarkers[self.CurrentMap] then
		self.StoredMarkers[self.CurrentMap] = {}
	end

	for i,v in self.Markers do
		if self.NorthMarker and v ~= self.NorthMarker then
			v:SetVisible(false)
			self.StoredMarkers[self.CurrentMap][i] = v
			self.Markers[i] = nil
		elseif not self.NorthMarker then
			v:SetVisible(false)
			self.StoredMarkers[self.CurrentMap][i] = v
			self.Markers[i] = nil
		end
	end
	if self.StoredMarkers[NewMap] then
		for i, v in self.StoredMarkers[NewMap] do
			v:SetVisible(true)
			self.StoredMarkers[NewMap][i] = nil
			self.Markers[i] = v
		end
	else
		self.StoredMarkers[NewMap] = {}
		for i, tagdata in Settings.MapData[self.CurrentMap].Tags do
			self:AddMarkerTag(NewMap, tagdata.TagName, tagdata)
		end
	end
	self.CurrentMap = NewMap
	local MapSetting = Settings.MapData[self.CurrentMap].Map
	MapView.RotateFrame.MapImage.Size = Utils.Vector2ToUDim2Offset(Vector2.new(MapSetting.Size.X, MapSetting.Size.Y))
	MapView.RotateFrame.MapImage.Image = `rbxassetid://{MapSetting.ImageId}`
	self:UpdateMakersList()
end

function MapClass:Toggle()
	self.IsMinimap = not self.IsMinimap
	self.MapDragedUDim = UDim2.new(0, 0, 0, 0)
	self.mapView.Scale = self.IsMinimap and self.Settings.Gui.Zoom.Minimap or self.Settings.Gui.Zoom.BigMap
	self.ToPlayer = not self.IsMinimap
	if not self.IsMinimap then
		for _, v in Enum.CoreGuiType:GetEnumItems() do
			if v == Enum.CoreGuiType.All then continue end
			self.CoreGui[v] = StarterGui:GetCoreGuiEnabled(v)
		end
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
	else
		for v, state in self.CoreGui do
			StarterGui:SetCoreGuiEnabled(v, state)
		end
	end
end

function MapClass:Drag(input)
	if self.dragStart then
		local delta = input.Position - self.dragStart
		local newPosition = self.startPos + Utils.Vector3ToUDim2Offset(delta)

		self.Offset = Vector2.new(delta.X, delta.Y)
		return newPosition
	else
		return UDim2.new(0,0,0,0)
	end
end

function MapClass:init()
	if self.inited then return end
	if not RunService:IsRunning() then return end
	local Settings = self.Settings

	self:Create()
	self.Map = Player.PlayerGui:WaitForChild("RoRenderMinimap")
	self.MapFrame = self.Map.MapFrame

	if Settings.Gui.NorthMarker then
		local NorthAtt = Instance.new("Attachment", workspace.Terrain)
		NorthAtt.WorldPosition = Vector3.new(0, 0, 1000000)
		NorthAtt.Name = "North"

		self.NorthMarker = self:AddMarker({
			TagName = "_Always_",
			ToolTip = "",
			ToolTipColor = Color3.fromRGB(255, 255, 255),
			IconID = "N",
			ShapeID = 16041176746,
			ShapeColor = Color3.fromRGB(0, 0, 0),
			Color = Color3.fromRGB(255, 255, 255),
			Size = UDim2.new(0.125, 0, 0.125, 0),
			SnapToBorder = true,
			Rotate = false,
			Index = 99,
			VisibleType = "Minimap",
		},NorthAtt)
	end

	self.RunStepped = RunService.RenderStepped:Connect(function(dt)
		self:Step(dt)
	end)

	self.InputBegan = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent then return end
		if input.KeyCode == self.Settings.Gui.OpenKey then
			self:Toggle()
		end
	end)

	for i, tagdata in Settings.MapData[self.CurrentMap].Tags do
		self:AddMarkerTag(self.CurrentMap, tagdata.TagName, tagdata)
	end

	local MapView = self.MapFrame.MapView
	local MarkerList = self.MapFrame.MarkerList.Holder
	MarkerList.NextSelectionUp = MapView
	MarkerList.NextSelectionLeft = MapView
	MarkerList.NextSelectionRight = MapView
	MarkerList.NextSelectionDown = MapView

	self.inited = true
end

function MapClass:Zoom(input)
	local MapFrame = self.MapFrame
	local MapView = MapFrame.MapView
	local MapImage = MapView.RotateFrame.MapImage
	local UIScale = MapImage.UIScale
	local SettingsGui = self.Settings.Gui
	local oldScale = math.round(UIScale.Scale * 1000) / 1000
	local zoomFactor = SettingsGui.Zoom.Step
	local maxScale = SettingsGui.Zoom.Min
	local minScale = SettingsGui.Zoom.Max
	local num = input.Position.Z
	local newScale = math.clamp(oldScale + (zoomFactor * num), maxScale, minScale)
	local scaleChange = newScale - oldScale

	local focus = UDim2.fromOffset(  -- point before zoom
		input.Position.X - MapImage.AbsolutePosition.X,
		input.Position.Y - MapImage.AbsolutePosition.Y
	)

	local translate = UDim2.fromOffset(
		-(focus.X.Offset * scaleChange) / (newScale - scaleChange),
		-(focus.Y.Offset * scaleChange) / (newScale - scaleChange)
	)
	self.mapView.Scale = newScale
	self.MapDragedUDim = (self.MapDragedUDim ~= UDim2.new(0,0,0,0) and self.MapDragedUDim or MapView.Position) + translate
end

function MapClass:HandleEvent(Event, Callback)
	self.Events[Event] = Callback
end

function MapClass:Create()
	local MinimapSettings = self.Settings
	local GuiSettings = MinimapSettings.Gui
	local MapData = MinimapSettings.MapData[self.CurrentMap]

	local function Render(props)
		local UIScale = React.useRef(nil)
		local MapImage = React.useRef(nil)
		local UICorner = React.useRef(nil)
		local UICorner2 = React.useRef(nil)
		local UICorner3 = React.useRef(nil)

		React.useEffect(function()
			local uiCorner = UICorner:getValue()
			local uiCorner2 = UICorner2:getValue()
			local uiCorner3 = UICorner3:getValue()
			if uiCorner then
				table.insert(self.UICorner, uiCorner)
			end
			if uiCorner2 then
				table.insert(self.UICorner, uiCorner2)
			end
			if uiCorner3 then
				table.insert(self.UICorner, uiCorner3)
			end
		end)

		return ReactRoblox.createPortal(React.createElement("ScreenGui", {
			Name = "RoRenderMinimap",
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			ResetOnSpawn = false,
			DisplayOrder = GuiSettings.ZIndex,
			IgnoreGuiInset = true,
			ScreenInsets = Enum.ScreenInsets.None
		}, {
			MapFrame = React.createElement("Frame", {
				Size = GuiSettings.Size,
				Position = GuiSettings.Position,
				AnchorPoint = GuiSettings.AnchorPoint,
				BackgroundColor3 = GuiSettings.BackgroundColor,
			}, {
				UICorner = React.createElement("UICorner", {
					CornerRadius = self.Settings.Gui.CornerRadius,
					ref = UICorner3
				}),	
				UIAspectRatioConstraint = React.createElement("UIAspectRatioConstraint", {
					AspectRatio = GuiSettings.AspectRatio
				}),
				UIStroke = React.createElement("UIStroke", {
					Thickness = 1,
					Color = GuiSettings.BorderColor,
				}),
				MarkerList = React.createElement("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(.3, .85),
					Position = UDim2.fromScale(.975, .075),
					AnchorPoint = Vector2.new(1, 0),
					Visible = false,
					ClipsDescendants = true,
				}, {
					Holder = React.createElement("ScrollingFrame", {
						Size = UDim2.fromScale(.2, 1),
						Position = UDim2.fromScale(1, 0),
						AnchorPoint = Vector2.new(1, 0),
						BackgroundTransparency = 1,
						ClipsDescendants = false,
						CanvasSize = UDim2.new(),
						ScrollingDirection = Enum.ScrollingDirection.Y
					}, {
						UIListLayout = React.createElement("UIListLayout",{
							Padding = UDim.new(0, 5),
							SortOrder = Enum.SortOrder.LayoutOrder,
							HorizontalAlignment = Enum.HorizontalAlignment.Right,
							VerticalAlignment = Enum.VerticalAlignment.Top,
						}),
						Sample = React.createElement("Frame", {
							BackgroundTransparency = .5,
							BorderSizePixel = 0,
							BackgroundColor3 = Color3.new(),
							Size = UDim2.fromScale(.019, .05),
							AutomaticSize = Enum.AutomaticSize.X,
							Visible = false,
						}, {
							UIListLayout = React.createElement("UIListLayout",{
								Padding = UDim.new(0, 10),
								SortOrder = Enum.SortOrder.LayoutOrder,
								FillDirection = Enum.FillDirection.Horizontal,
								HorizontalAlignment = Enum.HorizontalAlignment.Right,
								VerticalAlignment = Enum.VerticalAlignment.Center
							}),
							Icon = React.createElement("ImageLabel", {
								BackgroundTransparency = 1,
								Size = UDim2.fromScale(.9, .9),
								LayoutOrder = 5,
							},{
								UIAspectRatioConstraint = React.createElement("UIAspectRatioConstraint")
							}),
							UIPadding = React.createElement("UIPadding", {
								PaddingLeft = UDim.new(0, 10),
							}),
							Label = React.createElement("TextLabel", {
								LayoutOrder = 4,
								BackgroundTransparency = 1,
								Size = UDim2.fromScale(0, .7),
								AutomaticSize = Enum.AutomaticSize.X,
								TextScaled = true,
								TextXAlignment = Enum.TextXAlignment.Right,
								Font = MinimapSettings.Fonts.secondaryFont,
								TextColor3 = Color3.fromRGB(255, 255, 255),
								TextStrokeColor3 = Color3.fromRGB(255, 255, 255),
								TextStrokeTransparency = 0,
							})
						})
					})
				}),
				MapView = React.createElement("CanvasGroup", {
					Size = UDim2.fromScale(1, 1),
					Position = UDim2.fromScale(.5, .5),
					AnchorPoint = Vector2.new(.5, .5),
					BackgroundTransparency = 1,
					Active = true,
					Selectable = true,
					[React.Event.InputBegan] = function(rbx, input: InputObject)
						if Utils.IsMainInputPressed(input) and self.IsMinimap then
							self:Toggle()
						end

						if Utils.IsMainInputPressed(input) and not self.IsMinimap and MapImage.current then
							self.Dragging = true
							self.dragStart = input.Position
							self.startPos = MapImage.current.Position
						end
					end,
					[React.Event.InputChanged] = function(rbx, input: InputObject)
						if (input.UserInputType == Enum.UserInputType.MouseWheel or input.KeyCode == Enum.KeyCode.ButtonR2 or input.KeyCode == Enum.KeyCode.ButtonL2) and UIScale.current and MapImage.current then
							if input.KeyCode == Enum.KeyCode.ButtonR2 then
								input.Position += Vector3.new(0, 0, -1)
								self:Zoom(input)
							elseif input.KeyCode == Enum.KeyCode.ButtonL2 then
								input.Position += Vector3.new(0, 0, 1)
								self:Zoom(input)
							else
								self:Zoom(input)
							end
						end

						if Utils.IsMainInputMove(input) and not self.IsMinimap and MapImage.current then
							if self.Dragging then
								local newUDim = self:Drag(input)
								self.MapDragedUDim = newUDim

								local relativePostion = Vector2.new(newUDim.X.Offset, newUDim.Y.Offset)
								local Max = rbx.AbsoluteSize * Vector2.new(0.5,0.5)
								local Min = Max - MapImage.current.AbsoluteSize
								local clampedX = math.clamp(relativePostion.X, Min.X, Max.X)
								local clampedY = math.clamp(relativePostion.Y, Min.Y, Max.Y)
								self.MapDragedUDim = UDim2.fromOffset(clampedX, clampedY)
							end
						end
					end,
					[React.Event.InputEnded] = function(rbx, input: InputObject)
						if Utils.IsMainInputPressed(input) and not self.IsMinimap then
							self.Dragging = false
						end
					end,
				}, {
					UICorner = React.createElement("UICorner", {
						CornerRadius = self.Settings.Gui.CornerRadius,
						ref = UICorner2
					}),
					RotateFrame = React.createElement("Frame", {
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(1, 1),
					}, {
						MapImage = React.createElement("ImageLabel", {
							BackgroundTransparency = 1,
							Size = UDim2.fromOffset(MapData.Map.Size.X, MapData.Map.Size.Y),
							Image = `rbxassetid://{MapData.Map.ImageId}`,
							ref = MapImage,
						}, {
							UIAspectRatioConstraint = React.createElement("UIAspectRatioConstraint"),
							UIScale = React.createElement("UIScale", {
								Scale = GuiSettings.Zoom.Minimap,
								ref = UIScale
							}),
						}),
					})
				}),
				MarkerView = React.createElement("ViewportFrame", {
					Size = UDim2.fromScale(1, 1),
					Position = UDim2.fromScale(.5, .5),
					AnchorPoint = Vector2.new(.5, .5),
					BackgroundTransparency = 1,
					ZIndex = 2
				},{
					UICorner = React.createElement("UICorner", {
						CornerRadius = self.Settings.Gui.CornerRadius,
						ref = UICorner3
					}),	
				}),
			}),
		}), Player:WaitForChild("PlayerGui"))
	end
	--ref

	local root = ReactRoblox.createRoot(Instance.new("Folder"))
	root:render(React.createElement(Render))
	return nil
end

return function(Settings: Types.Settings): Types.MapClass
	if Map then
		return Map
	end

	local self = setmetatable({}, MapClass)
	self.Settings = Settings
	self.Convert = ConvertPosition(self)
	self.Enabled = true
	self.IsMinimap = true
	self.Dragging = false
	self.Rotation = 0
	self.MapDragedUDim = UDim2.new(0, 0, 0, 0)
	self.Offset = Vector2.new(0, 0)
	self.ToPlayer = false
	self.mapView = {
		FocusX = 0,
		FocusY = 0,
		Scale = self.Settings.Gui.Zoom.Minimap
	}
	self.Connections = {}
	self.Events = {}
	self.Markers = {}
	self.TagMarkers = {}
	self.UICorner = {}
	self.StoredMarkers = {}
	self.CoreGui = {}
	self.inited = false
	self.CurrentMap = Settings.Gui.StartMap

	self:init()
	Map = self
	return self
end