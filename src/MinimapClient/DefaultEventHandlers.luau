local Shared = script.Parent:WaitForChild("Shared")
local Types = require(Shared.Types)

return function(Map: Types.MapClass)
	Map:HandleEvent("AddTag", function(Tag, Insts: {Instance})
		for i,v in Insts do
			v:AddTag(Tag)
		end
	end)
	
	Map:HandleEvent("RemoveTag", function(Tag, Insts: {Instance})
		for i,v in Insts do
			v:RemoveTag(Tag)
		end
	end)
end
