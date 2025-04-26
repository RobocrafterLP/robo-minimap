local ReplicatedStorage = game:GetService("ReplicatedStorage")

return function(Minimap)
    local ReplicatedRoot, RemoteFunction, RemoteEvent

    local function Create(class, name, parent)
        local object = Instance.new(class)
        object.Name = name
        object.Parent = parent or ReplicatedRoot

        return object
    end

    ReplicatedRoot = script.Parent.MinimapClient
    ReplicatedRoot.Parent = ReplicatedStorage

    RemoteFunction = Create("RemoteFunction", "MinimapFunction")
    RemoteEvent = Create("RemoteEvent", "MinimapEvent")

    Minimap.ReplicatedRoot = ReplicatedRoot
    Minimap.RemoteFunction = RemoteFunction
    Minimap.RemoteEvent = RemoteEvent
end
