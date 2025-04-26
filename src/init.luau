local Players = game:GetService("Players")

local Minimap do
	Minimap = setmetatable({
		ReplicatedRoot = nil;
		RemoteFunction = nil;
		RemoteEvent = nil;
	}, {
		__index = Minimap
	})
	
	function Minimap:send(Player, Event, ...)
		self.RemoteEvent:FireClient(Player, Event, ...)
	end
	
	require(script.Initialize)(Minimap)
end

function CharacterAdded(Char: Model?)
	if not Char then return end
	--Char.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
	Char:AddTag("Player")
end

Players.PlayerAdded:Connect(function(Player)
	Player.CharacterAdded:Connect(CharacterAdded)
	CharacterAdded(Player.Character)
end)

return Minimap