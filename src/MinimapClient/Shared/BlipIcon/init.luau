local BlipIcon = {}
local Data = require(script.Data)
local ImageEnum = require(script.Enum)

local Images = {
	["LucideSprite_0"] = "rbxassetid://75911337549926",
	["LucideSprite_1"] = "rbxassetid://81956881315956",
	["LucideSprite_2"] = "rbxassetid://125461128228937",
	["LucideSprite_3"] = "rbxassetid://107783241060672",
	["LucideSprite_4"] = "rbxassetid://79249490433027",
	["LucideSprite_5"] = "rbxassetid://104404934501829",
	["LucideSprite_6"] = "rbxassetid://131632961199594",
}

BlipIcon.Enum = ImageEnum

function BlipIcon.GetIcon(Icon, Type: "ImageButton" | "ImageLabel", Color: Color3?) : (ImageLabel | ImageButton)?
	if not ImageEnum[Icon] then
		return nil
	end
	if not (Type == "ImageButton") and not (Type == "ImageLabel") then
		return nil
	end
	local IconData: {Offset: Vector2, Size: Vector2, Image: string } = Data[Icon]
	local image = Instance.new(Type)
	image.ImageRectOffset = IconData.Offset
	image.ImageRectSize = IconData.Size
	image.Image = Images[IconData.Image]
	image.BackgroundTransparency = 1
	image.Name = Icon
	if Color then
		image.ImageColor3 = Color
	end

	return image
end

function BlipIcon.GetIconData(Icon): {ImageRectOffset: Vector2, ImageRectSize: Vector2, Image: string}?
	if not ImageEnum[Icon] then
		return nil
	end
	local IconData: {Offset: Vector2, Size: Vector2, Image: string } = Data[Icon]
	return {
		ImageRectOffset = IconData.Offset,
		ImageRectSize = IconData.Size,
		Image = Images[IconData.Image],
	}
end

function BlipIcon.DisplayIcons()
	if (game.Players.LocalPlayer == nil) then
		return warn("can be runed only on the client")
	end

	local Gui = Instance.new("ScreenGui", game.Players.LocalPlayer.PlayerGui)
	local List = Instance.new("ScrollingFrame", Gui)
	List.Size = UDim2.fromScale(1, 1)
	List.CanvasSize = UDim2.new()
	List.AutomaticCanvasSize = Enum.AutomaticSize.Y
	List.BackgroundTransparency = 1
	local Grid = Instance.new("UIGridLayout", List)
	Grid.CellSize = UDim2.new(0, 64, 0, 64)
	Grid.CellPadding = UDim2.new()

	for i in BlipIcon.Enum do
		local icon = BlipIcon.GetIcon(i, "ImageLabel", Color3.new())
		icon.Parent = List
	end
end

return BlipIcon
