local Types = require(script.Parent.Types)
local BlipIcon = require(script.Parent.BlipIcon).Enum

local Settings: Types.Settings = {
	Fonts = {
		primaryFont = Enum.Font.SourceSans,
		secondaryFont = Enum.Font.SourceSansLight,
		boldFont = Enum.Font.SourceSansBold,
		lessboldFont = Enum.Font.SourceSansSemibold,
		italicFont = Enum.Font.SourceSansItalic,
	},
	Gui = {
		OpenKey = Enum.KeyCode.M,
		Bigmap = {
			AspectRatio = nil,
			CornerRadius = UDim.new(),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(.5, .5),
			Size = UDim2.fromScale(1, 1),
			BackgroundColor = Color3.fromHex("#111827"),
			BorderColor = Color3.fromHex("#fbbf24"),
			BorderSize = 2,
		},
		Minimap = {
			AspectRatio = 1,
			CornerRadius = UDim.new(0.1, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(.85, .15),
			Size = UDim2.fromScale(.2, .2),
			BackgroundColor = Color3.fromHex("#111827"),
			BorderColor = Color3.fromHex("#fbbf24"),
			BorderSize = 2,
		},
		RotateWithCamera = true,
		MaxMarkerDistance = 10000, --In Studs
		ZIndex = 99999999,
		NorthMarker = true,
		Zoom = {
			Max = 1.5, -- max zoom out
			Min = 0.12, -- min zoom in
			Step = 0.05, -- zoom step
			Minimap = 0.18, -- Zoom For Minimap
			BigMap = (0.269 * 1.5), -- Zoom For Big Map
		},
		MarkerScale = {
			BigMap = .2,--.72,
			Minimap = 1.5,
		},
		StartMap = "sample"
	},
	MapData = {
		sample = {
			Map = {
				Size = Vector2.new(12000, 12000), --In Studs
				ImageId = 17001033462,
				Center = Vector2.new(-0,0)
			},
			Tags = {
				{
					DisplayName = "Dealership", --MarkerList DisplayName
					TagName = "MiniMap Dealership",
					ToolTip = "Dealership", --"Name" for Object Name or custom name
					ToolTipColor = Color3.fromRGB(255, 255, 255),
					IconID = 16639425421, --iconid or for player = "PlayerHead" or "BlipIcon.Name" from provide Icons
					ShapeColor = Color3.fromRGB(0, 0, 0),
					Color = Color3.fromRGB(255, 255, 255),
					Size = UDim2.new(0.077, 0, 0.077, 0),
					SnapToBorder = true,
					Rotate = false,
					Index = 2,
					VisibleType = "Both",
				},
				{
					DisplayName = "Dirt Track", --MarkerList DisplayName
					TagName = "MiniMap Dirt Track",
					ToolTip = "Dirt Track", --"Name" for Object Name or custom name
					ToolTipColor = Color3.fromRGB(255, 255, 255),
					IconID = 16639425351, --iconid or for player = "PlayerHead" or "BlipIcon.Name" from provide Icons
					ShapeColor = Color3.fromRGB(0, 0, 0),
					Color = Color3.fromRGB(255, 255, 255),
					Size = UDim2.new(0.077, 0, 0.077, 0),
					SnapToBorder = true,
					Rotate = false,
					Index = 2,
					VisibleType = "Both",
				},
				{
					DisplayName = "Garage", --MarkerList DisplayName
					TagName = "MiniMap Garage",
					ToolTip = "Garage", --"Name" for Object Name or custom name
					ToolTipColor = Color3.fromRGB(255, 255, 255),
					IconID = 17355348325, --iconid or for player = "PlayerHead" or "BlipIcon.Name" from provide Icons 17355348325
					ShapeColor = Color3.fromRGB(0, 0, 0),
					Color = Color3.fromRGB(255, 255, 255),
					Size = UDim2.new(0.077, 0, 0.077, 0),
					SnapToBorder = true,
					Rotate = false,
					Index = 2,
					VisibleType = "Both",
				},
				{
					DisplayName = "Misguided", --MarkerList DisplayName
					TagName = "MiniMap Misguided",
					ToolTip = "Misguided", --"Name" for Object Name or custom name
					ToolTipColor = Color3.fromRGB(255, 255, 255),
					IconID = 16639425239, --iconid or for player = "PlayerHead" or "BlipIcon.Name" from provide Icons
					ShapeColor = Color3.fromRGB(0, 0, 0),
					Color = Color3.fromRGB(255, 255, 255),
					Size = UDim2.new(0.077, 0, 0.077, 0),
					SnapToBorder = true,
					Rotate = false,
					Index = 2,
					VisibleType = "Both",
				},
				{
					DisplayName = "Plaza wwwwwww", --MarkerList DisplayName
					TagName = "MiniMap Spawn",
					ToolTip = "Plaza", --"Name" for Object Name or custom name
					ToolTipColor = Color3.fromRGB(255, 255, 255),
					IconID = 16639424673, --iconid or for player = "PlayerHead" or "BlipIcon.Name" from provide Icons
					ShapeColor = Color3.fromRGB(0, 0, 0),
					Color = Color3.fromRGB(255, 255, 255),
					Size = UDim2.new(0.077, 0, 0.077, 0),
					SnapToBorder = true,
					Rotate = false,
					Index = 2,
					VisibleType = "Both",
				},
				{
					DisplayName = "Prison", --MarkerList DisplayName
					TagName = "MiniMap Prison",
					ToolTip = "Prison", --"Name" for Object Name or custom name
					ToolTipColor = Color3.fromRGB(255, 255, 255),
					IconID = 16639425057, --iconid or for player = "PlayerHead" or "BlipIcon.Name" from provide Icons
					ShapeColor = Color3.fromRGB(0, 0, 0),
					Color = Color3.fromRGB(255, 255, 255),
					Size = UDim2.new(0.077, 0, 0.077, 0),
					SnapToBorder = true,
					Rotate = false,
					Index = 2,
					VisibleType = "Minimap",
				},
				{
					DisplayName = "Race Track", --MarkerList DisplayName
					TagName = "MiniMap Race Track",
					ToolTip = "Race Track", --"Name" for Object Name or custom name
					ToolTipColor = Color3.fromRGB(255, 255, 255),
					IconID = 16639424942, --iconid or for player = "PlayerHead" or "BlipIcon.Name" from provide Icons
					ShapeColor = Color3.fromRGB(0, 0, 0),
					Color = Color3.fromRGB(255, 255, 255),
					Size = UDim2.new(0.077, 0, 0.077, 0),
					SnapToBorder = true,
					Rotate = false,
					Index = 2,
					VisibleType = "Both",
				},
				{
					DisplayName = "Stunt Park", --MarkerList DisplayName
					TagName = "MiniMap Stunt Park",
					ToolTip = "Stunt Park", --"Name" for Object Name or custom name
					ToolTipColor = Color3.fromRGB(255, 255, 255),
					IconID = 16639424765, --iconid or for player = "PlayerHead" or "BlipIcon.Name" from provide Icons
					ShapeColor = Color3.fromRGB(0, 0, 0),
					Color = Color3.fromRGB(255, 255, 255),
					Size = UDim2.new(0.077, 0, 0.077, 0),
					SnapToBorder = true,
					Rotate = false,
					Index = 2,
					VisibleType = "Both",
				},
				{
					DisplayName = "Player", --MarkerList DisplayName
					TagName = "Player",
					ToolTip = "Name", --"Name" for Object Name or custom name
					ToolTipColor = Color3.fromRGB(255, 255, 255),
					IconID = "PlayerHead", --iconid or for player = "PlayerHead" or "BlipIcon.Name" from provide Icons
					ShapeColor = Color3.fromRGB(0, 0, 0),
					ShapeID = 16041176746,
					Color = Color3.fromRGB(255, 255, 255),
					Size = UDim2.new(0.077, 0, 0.077, 0),
					SnapToBorder = true,
					Rotate = false,
					Index = 2,
					VisibleType = "Both",
				},
			}
		}
	}
}

return Settings