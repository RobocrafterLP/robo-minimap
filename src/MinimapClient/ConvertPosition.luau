local Shared = script.Parent:WaitForChild("Shared")
local Types = require(Shared.Types)

local ConvertPosition = {} :: Types.ConvertPosition
ConvertPosition.__index = ConvertPosition

function ConvertPosition:ToWorld(Position)
	local MapData = self.MapData
	print(MapData)
	local MapView = MapData.MapView
	local MapImage = MapView.RotateFrame.MapImage

	local mapSize = MapImage.AbsoluteSize
	local mapPos = MapImage.Position

	local MapSettings = MapData.Settings.MapData[MapData.CurrentMap]
	
	local X = Position.X
	local Z = Position.Y
	local X2 = (X / mapSize.X)
	local Z2 = (Z / mapSize.Y)

	local x,z = 0,0
	if X2 > 0.5 then
		x = (MapSettings.Map.Size.X/2) * (math.floor(X2*10000)/10000*2)
	elseif X2 < 0.5 then
		x = (MapSettings.Map.Size.X/2) * -(math.floor(X2*10000)/10000*2)
	else
		x = 0
	end
	
	if Z2 > 0.5 then
		z = (MapSettings.Map.Size.Y/2) * -(math.floor(Z2*10000)/10000*2)
	elseif Z2 < 0.5 then
		z = (MapSettings.Map.Size.Y/2) * (math.floor(Z2*10000)/10000*2)
	else
		z = 0
	end
	
	if x < 0 then
		x *= -1
	end

	if z < 0  then
		z *= -1
	end
	
	return -Vector3.new(MapSettings.Map.Size.X/2 - (x),0,MapSettings.Map.Size.Y/2 - (z))
end

function ConvertPosition:ToMap(Position)
	local MapData = self.MapData
	local MapFrame = MapData.MapFrame
	
	local MapView = MapFrame.MapView
	local MapImage = MapView.RotateFrame.MapImage

	local mapSize = MapImage.AbsoluteSize
	local mapPosition = MapImage.Position
	local mapAnchor = MapImage.AnchorPoint

	local MapSettings = MapData.Settings.MapData[MapData.CurrentMap]
	local mapSettingsSize = MapSettings.Map.Size

	local x = ((Position.X + mapSettingsSize.X / 2) / mapSettingsSize.X * mapSize.X + mapPosition.X.Offset) - mapSize.X * mapAnchor.X
	local y = ((Position.Z + mapSettingsSize.Y / 2) / mapSettingsSize.Y * mapSize.Y + mapPosition.Y.Offset) - mapSize.Y * mapAnchor.Y

	return Vector2.new(x, y)
end

function ConvertPosition:ToMap2(Position)
	local MapData = self.MapData
	local MapFrame = MapData.MapFrame
	local MapView = MapFrame.MapView
	local MapImage = MapView.RotateFrame.MapImage

	local MapSettings = MapData.Settings.MapData[MapData.CurrentMap]
	local mapSize = MapImage.AbsoluteSize
	local realSize = MapSettings.Map.Size/2

	local x = Position.X + realSize.X
	local y = Position.Z + realSize.Y

	return Vector2.new(x, y)
end

return function(mapData)
	local self = setmetatable({}, ConvertPosition)
	self.MapData = mapData
	
	return self
end