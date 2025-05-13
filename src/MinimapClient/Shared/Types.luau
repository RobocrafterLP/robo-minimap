export type MapClass = {
	Step: (self: MapClass) -> (),
	MarkerById: (self: MapClass, Id: string) -> MarkerClass,
	Update: (self: MapClass) -> (),
	UpdateMakers: (self: MapClass) -> nil,
	UpdateMakersList: (self: MapClass) -> nil,
	SetFocuseToMarker: (self: MapClass, Position: Vector3) -> nil,
	AddMarker: (self: MapClass, Settings: Tag, instance: instance) -> MarkerClass,
	AddMarkerTag: (self: MapClass, map: string, tag: string, tagsettings: Tag) -> nil,
	RemoveMarker: (self: MapClass, instance: instance) -> nil,
	RemoveMarkerTag: (self: MapClass, map: string, tag: string) -> nil,
	SwitchMap: (self: MapClass, NewMap: string) -> nil,
	Toggle: (self: MapClass) -> nil,
	Drag: (self: MapClass, input: InputObject) -> UDim2,
	init: (self: MapClass) -> nil,
	Zoom: (self: MapClass, num: number) -> nil,
	HandleEvent: (self: MapClass, Event: string, Callback: any?) -> (),
	Create: (self: MapClass) -> nil,
	Settings: Settings,
	Convert: ConvertPosition,
	Enabled: boolean,
	IsMinimap: boolean,
	Dragging: boolean,
	Rotation: number,
	MapDragedUDim: UDim2,
	Offset: Vector2,
	ToPlayer: boolean,
	mapView: {
		FocusX: number,
		FocusY: number,
		Scale: number,
	},
	Connections: { RBXScriptConnection? },
	Events: { [string]: () -> ()? },
	Markers: { [instance]: MarkerClass? },
	TagMarkers: { [string]: { [instance]: MarkerClass }? },
	UICorner: { UICorner? },
	StoredMarkers: { [string]: { [instance]: MarkerClass }? },
	CoreGui: { [Enum.CoreGuiType]: boolean? },
	inited: boolean,
	CurrentMap: string,
	Map: MapGui,
	MapFrame: MapFrame,
	RemoteEvent: RemoteEvent,
	RemoteFunction: RemoteFunction,
}

export type instance = Attachment | Model | BasePart

export type MapFrame = Frame & {
	UICorner: UICorner,
	UIAspectRatioConstraint: UIAspectRatioConstraint,
	UIStroke: UIStroke,
	MapView: CanvasGroup & {
		UICorner: UICorner,
		RotateFrame: Frame & {
			MapImage: ImageLabel & {
				UIAspectRatioConstraint: UIAspectRatioConstraint,
				UIScale: UIScale,
			},
		},
	},
	MarkerView: ViewportFrame & {
		UICorner: UICorner,
	},
	MarkerList: Frame & {
		Holder: Frame & {
			UIListLayout: UIListLayout,
			Sample: Frame & {
				UIListLayout: UIListLayout,
				Icon: ImageLabel & {
					UIAspectRatioConstraint: UIAspectRatioConstraint,
				},
				UIPadding: UIPadding,
				Label: TextLabel,
			},
		},
	},
}
export type MapGui = ScreenGui & {
	MapFrame: MapFrame,
}

export type MarkerClass = {
	UpdateSize: (self: MarkerClass) -> nil,
	UpdatePosition: (self: MarkerClass) -> nil,
	UpdateRotation: (self: MarkerClass) -> nil,
	SetPosition: (self: MarkerClass, Position: UDim2) -> nil,
	SetRotation: (self: MarkerClass, Rotation: number) -> nil,
	SetSize: (self: MarkerClass, Position: UDim2) -> nil,
	SetIcon: (self: MarkerClass, Id: number) -> nil,
	SetIconText: (self: MarkerClass, Text: string) -> nil,
	SetShape: (self: MarkerClass, Id: number) -> nil,
	SetIconColor: (self: MarkerClass, Color: Color3) -> nil,
	SetShapeColor: (self: MarkerClass, Color: Color3) -> nil,
	SetVisible: (self: MarkerClass, Visible: boolean) -> nil,
	GetPosition: (self: MarkerClass) -> Vector2,
	GetWorldPosition: (self: MarkerClass) -> Vector3,
	GetGui: (self: MarkerClass) -> Instance,
	GetInstance: (self: MarkerClass) -> instance,
	PlayerIcon: (self: MarkerClass, Name: string) -> string?,
	DisplayName: (self: MarkerClass, Name: string) -> string?,
	GUI: (self: MarkerClass) -> Instance,
	Destroy: (self: MarkerClass) -> nil,
	NorthMarker: MarkerClass?,
	MapData: MapClass,
	Settings: Tag,
	obj: instance,
	Type: string,
	Gui: Instance,
	Index: number,
	Tag: string,
	Map: string,
}

export type ConvertPosition = {
	ToWorld: (self: ConvertPosition, Position: Vector2) -> Vector3,
	ToMap: (self: ConvertPosition, Position: Vector3) -> Vector2,
	ToMap2: (self: ConvertPosition, Position: Vector3) -> Vector2,
	MapData: MapClass,
}

export type MapImage = {
	Size: Vector2,
	ImageId: number,
	Center: Vector2,
}

export type MapImages = {
	Size: Vector2,
	Center: Vector2,
	Images: {
		{
			ImageId: number,
			LayoutOrder: number,
		}
	}
}

export type Settings = {
	Fonts: {
		primaryFont: Enum.Font,
		secondaryFont: Enum.Font,
		boldFont: Enum.Font,
		lessboldFont: Enum.Font,
		italicFont: Enum.Font,
	},
	Gui: {
		OpenKey: Enum.KeyCode,
		Bigmap: {
			AspectRatio: number?,
			CornerRadius: UDim,
			AnchorPoint: Vector2,
			Position: UDim2,
			Size: UDim2,
			BackgroundColor: Color3,
			BorderColor: Color3,
			BorderSize: number,
			Parent: string?,
		},
		Minimap: {
			AspectRatio: number?,
			CornerRadius: UDim,
			AnchorPoint: Vector2,
			Position: UDim2,
			Size: UDim2,
			BackgroundColor: Color3,
			BorderColor: Color3,
			BorderSize: number,
			Parent: string?,
		},
		RotateWithCamera: boolean,
		MaxMarkerDistance: number,
		ZIndex: number,
		NorthMarker: boolean,
		Zoom: {
			Max: number,
			Min: number,
			Step: number,
			Minimap: number,
			BigMap: number,
		},
		MarkerScale: {
			BigMap: number,
			Minimap: number,
		},
		StartMap: string,
	},
	MapData: { [string]: MapData },
}

export type MapData = {
	Map: MapImage | MapImages,
	Tags: { Tag? },
}

export type Tag = {
	DisplayName: string,
	TagName: string,
	ToolTip: string,
	ToolTipColor: Color3,
	IconID: string | number,
	ShapeColor: Color3,
	ShapeID: number?,
	Color: Color3,
	Size: UDim2,
	SnapToBorder: boolean,
	Rotate: boolean,
	Index: number,
	VisibleType: "Both" | "Minimap" | "Bigmap",
	--Stack: boolean,
}

return {}
