local Utils = {}

function Utils.UDim2OffsetTimes(udim2: UDim2, times: number)
	return UDim2.fromOffset(udim2.X.Offset * times, udim2.Y.Offset * times)
end

function Utils.UDim2ScaleTimes(udim2: UDim2, times: number)
	return UDim2.fromScale(udim2.X.Scale * times, udim2.Y.Scale * times)
end

function Utils.UDim2Times(udim2: UDim2, times: number)
	return UDim2.new(udim2.X.Scale * times, udim2.X.Offset * times, udim2.Y.Scale * times, udim2.Y.Offset * times)
end

function Utils.Vector2ToUDim2Offset(vector: Vector2)
	return UDim2.fromOffset(vector.X, vector.Y)
end

function Utils.Vector2ToUDim2Scale(vector: Vector2)
	return UDim2.fromScale(vector.X, vector.Y)
end

function Utils.Vector3ToUDim2Offset(vector: Vector2)
	return UDim2.fromOffset(vector.X, vector.Y)
end

function Utils.Vector3ToUDim2Scale(vector: Vector2)
	return UDim2.fromScale(vector.X, vector.Y)
end

function Utils.IsMainInputPressed(input)
	return table.find({Enum.UserInputType.MouseButton1, Enum.UserInputType.Touch}, input.UserInputType) ~= nil
end

function Utils.IsMainInputMove(input)
	return table.find({Enum.UserInputType.MouseMovement, Enum.UserInputType.Touch}, input.UserInputType) ~= nil
end

function Utils.getDistanceFromPlayer(plr, pos)
	if plr.Character then
		if plr.Character:FindFirstChild("HumanoidRootPart") then
			return (pos - plr.Character.HumanoidRootPart.CFrame.p).Magnitude
		end
	end

	return math.huge
end

return Utils