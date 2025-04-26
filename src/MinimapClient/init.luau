local Shared = script:WaitForChild("Shared")
local MinimapSettingsModule = Shared:WaitForChild("MinimapSettings", 1)
local MapCreator = require(script.Map)
if not MinimapSettingsModule then return {} end
local Minimap = MapCreator(require(MinimapSettingsModule))

Minimap.RemoteFunction = script:WaitForChild("MinimapFunction")
Minimap.RemoteEvent = script:WaitForChild("MinimapEvent")

Minimap.RemoteEvent.OnClientEvent:Connect(function(name, ...)
    if Minimap.Events[name] then
        Minimap.Events[name](...)
    end
end)

require(script.DefaultEventHandlers)(Minimap)

return Minimap
