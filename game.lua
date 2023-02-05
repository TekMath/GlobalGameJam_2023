Config = {
    Map = "math.main_map",
    Items = {
        "misteryou61.map_muspellheim",
        "divergonia.red_portal_1",
        "divergonia.hell_treasure",
        "divergonia.groot",

        "misteryou61.map_fairy_wall",
		"misteryou61.map_fairypart2",
		"misteryou61.map_fairy",
		"misteryou61.island_sakura_tree",
		"divergonia.feeric_treasure",
		"divergonia.feeric_tree_1",
		"divergonia.feeric_tree_2",
		"divergonia.feeric_tree_3",
		"divergonia.green_portal_1",

        "axelfradet.map_nidevellir",
        "divergonia.grey_portal_1",
        "divergonia.pickaxe",
        "misteryou61.minecraft_forge1",
        "misteryou61.character_knight",
        "misteryou61.character_swordman1",
        "divergonia.lantern",
        "divergonia.opened_treasure",

        "axelfradet.map_ground",
        "axelfradet.ice_build",
        "axelfradet.flower",
        "divergonia.blue_portal_1",
        "divergonia.ice_spike_1",
        "divergonia.ice_spike_2",
        "divergonia.key3d",

        "misteryou61.city_mapv1",
        "misteryou61.habited_house1",
        "misteryou61.habited_house2",
        "misteryou61.habited_house3",
        "misteryou61.habited_house4",
        "misteryou61.habited_house6",
        "misteryou61.populated_store1",
        "misteryou61.populated_store2",
        "misteryou61.populated_store3",
        "misteryou61.populated_cinema",
        "misteryou61.habited_park",
        "misteryou61.stop_sign",
        "misteryou61.autobus",
        "misteryou61.pink_car",
        "misteryou61.blue_car",
        "misteryou61.green_car",
        "misteryou61.black_car",
        "misteryou61.orange_car",
        "misteryou61.taxis_car",

        "divergonia.icon_yggdrasil"
    }
}

function rSpawnMap(item)
    local map = Shape(item)

    map.Scale = 5
    map.Pivot = Number3(0, 0, 0)
    map.Position = Number3(0, 0, 0)
    map.Physics = PhysicsMode.StaticPerBlock
    map.Friction = Map.Friction
    map.Bounciness = Map.Bounciness

    World:AddChild(map)
    map.CollisionGroups = 1

    return map
end

function rSpawnObject(x, y, z, item, scale, collision, rotation)
	local object = Shape(item)

    object.Pivot = Number3(object.Width / 2, 0, object.Depth / 2)
	object.Position = Number3(x, y, z)
    object.LocalScale = scale
    object.Physics = PhysicsMode.StaticPerBlock
    object.Rotation = rotation
    object.rItem = item
    object.Friction = Map.Friction
    object.Bounciness = Map.Bounciness

    World:AddChild(object)

	if collision then
		object.CollisionGroups = collision
	end

    return object
end

function rCollisionPortal(portal, actionFunction, ...)
    local collision = true

    if (Player.Position.X - portal.Position.X < (-6 * portal.LocalScale.X) or Player.Position.X - portal.Position.X > (6 * portal.LocalScale.X)) then
        collision = false
    end
    if (Player.Position.Y - portal.Position.Y < (-13 * portal.LocalScale.Y) or Player.Position.Y - portal.Position.Y > (13 * portal.LocalScale.Y)) then
        collision = false
    end
    if (Player.Position.Z - portal.Position.Z < (-4 * portal.LocalScale.Z) or Player.Position.Z - portal.Position.Z > (4 * portal.LocalScale.Z)) then
        collision = false
    end
    if (collision) then
        actionFunction(...)
    end
end

function rCollisionObject(object, actionFunction, ...)
    local collision = true

    if (Player.Position.X - object.Position.X < (-object.Width * object.LocalScale.X) or Player.Position.X - object.Position.X > (object.Width * object.LocalScale.X)) then
        collision = false
    end
    if (Player.Position.Y - object.Position.Y < (-object.Height * object.LocalScale.Y) or Player.Position.Y - object.Position.Y > (object.Height * object.LocalScale.Y)) then
        collision = false
    end
    if (Player.Position.Z - object.Position.Z < (-object.Depth * object.LocalScale.Z) or Player.Position.Z - object.Position.Z > (object.Depth * object.LocalScale.Z)) then
        collision = false
    end
    if (collision) then
        actionFunction(...)
    end
end

function rSpawnLightDirectional(light)
    local l = Light()

    l.On = true
    l.Type = LightType.Directional
    l.Color = light.Color
    l.Rotation = light.Rotation

    World:AddChild(l)
    table.insert(rWorld.Lights, l)
end

function rUpdateTime(time)
    local mark = time.Mark

    TimeCycle.On = time.Cycle
    Time.Current = time.Current

    mark.SkyColor = time.SkyColor
    mark.HorizonColor = time.HorizonColor
    mark.AbyssColor = time.AbyssColor
    mark.SkyLightColor = time.SkyLightColor
end

function rDialogue(text, time, NPC)
    dial = Text()

    dial.Text = text
    dial.Type = TextType.World
    dial.LocalScale = 2
    dial.IsUnlit = true
    dial.Tail = true
    dial.Rotation = Number3(0, (NPC == Player and 0 or -(math.pi)), 0)

    NPC:AddChild(dial)
    dial.LocalPosition = { 0, (NPC == Player and 34 or NPC.Height + 5), 0 }

    return dial
end

function rRefreshLabels()
    -- lives
    local str_heart = ""
    for i=1,rPlayer.Lifes do
        str_heart = str_heart .. "❤️"
    end
    rUi.livesLabel.Text = str_heart

    -- key
    if rPlayer.Keys == 1 then
        rUi.keyLabel.Text = "🔑"
    else 
        rUi.keyLabel.Text = ""
    end
end

function destroyObject()
    local obj = nil
    local hit = 0

    for i, tableItem in ipairs(rWorld.Items) do
        if tableItem.rItem == rItems.IceSpike1 or tableItem.rItem == rItems.IceSpike2 then
            local cast = Camera:CastRay(tableItem)
            if cast ~= nil then
                if cast.Distance < 75 then
                    obj = rWorld.Items[i]
                    obj.index = i
                    tableItem.Physics = PhysicsMode.Disabled
                    tableItem:SetParent(nil)
                    hit = i
                    break
                end
            end
        end
    end

    if obj ~= nil then
        if obj.rItem == rItems.IceSpike1 or obj.rItem == rItems.IceSpike2 then
            local posSave = obj.Position
            spikes_nb = spikes_nb - 1
            if spikes_nb == 0 then
                key = Shape(rItems.Key)
                key.Scale = 0.5
                key.Position = posSave
                key.CollisionGroupsMask = 1
                key.Physics = true
                key.Pivot.Y = 0
                key.OnCollisionBegin = keyCollision
                key:SetParent(World)
                Player:TextBubble("J'ai enfin la cle !")
                table.remove(rWorld.Items, obj.index)
            end
        end

    end
end

function keyCollision(self, other)
    if other == Player then
    self.Physics = PhysicsMode.Disabled
        self:SetParent(nil)
    rPlayer.Keys = 1
    end
end

function rDebugPlayer(debug)
    debug = debug or Text()

    debug.Text = Player.Position.X.." "..Player.Position.Y.." "..Player.Position.Z
    debug.Type = TextType.Screen
    debug.IsUnlit = true
    debug.Tail = true

    Player:AddChild(debug)
    debug.LocalPosition = { 0, 34, 0 }
    return debug
end

Client.OnStart = function()
    explode = require("explode")
    particles = require("particles")
    spikes_nb = math.random(7, 20)

    soundData = {}

    rDefault = {
        Mark = TimeCycle.Marks.Noon,
        SkyColor = TimeCycle.Marks.Noon.SkyColor,
        HorizonColor = TimeCycle.Marks.Noon.HorizonColor,
        AbyssColor = TimeCycle.Marks.Noon.AbyssColor,
        SkyLightColor = TimeCycle.Marks.Noon.SkyLightColor,
        Camera = Camera.Far
    }
    -- Item
    rItems = {
        RedPortal = Items.divergonia.red_portal_1,
        GrayPortal = Items.divergonia.grey_portal_1,
        BluePortal = Items.divergonia.blue_portal_1,
        GreenProtal = Items.divergonia.green_portal_1,

        Sakura = Items.misteryou61.island_sakura_tree,
        FeeChest = Items.divergonia.feeric_treasure,
        FeeMapWall = Items.misteryou61.map_fairy_wall,
        FeeMap = Items.misteryou61.map_fairy,
        FeeMap2 = Items.misteryou61.map_fairypart2,

        Pickaxe = Items.divergonia.pickaxe,

        Chest = Items.divergonia.hell_treasure,
        Groot = Items.divergonia.groot,
        IceBuild = Items.axelfradet.ice_build,
        IceFlower = Items.axelfradet.flower,
        IceSpike1 = Items.divergonia.ice_spike_1,
        IceSpike2 = Items.divergonia.ice_spike_2,
        Key = Items.divergonia.key3d,

        ice_flower = Items.axelfradet.flower,
        house1 = Items.misteryou61.habited_house1,
        house2 = Items.misteryou61.habited_house2,
        house3 = Items.misteryou61.habited_house3,
        house4 = Items.misteryou61.habited_house4,
        house6 = Items.misteryou61.habited_house6,

        store1 = Items.misteryou61.populated_store1,
        store2 = Items.misteryou61.populated_store2,
        store3 = Items.misteryou61.populated_store3,

        cinema = Items.misteryou61.populated_cinema,

        park = Items.misteryou61.habited_park,

        stop_sign = Items.misteryou61.stop_sign,

        autobus = Items.misteryou61.autobus,
        pink_car = Items.misteryou61.pink_car,
        black_car = Items.misteryou61.black_car,
        orange_car = Items.misteryou61.orange_car,
        green_car = Items.misteryou61.green_car,
        blue_car = Items.misteryou61.blue_car,

        taxis_car = Items.misteryou61.taxis_car,
    }

    rProcess = {
        lava = 1
    }

    -- Level player
    rPlayer = {
        Lifes = 3,
        Keys = 0,
        Bonus = 0,
        Blocked = false,
        End = false
    }

    rUi = {
        livesLabel = UI.Label("", Anchor.Right, Anchor.Top),
        keyLabel = UI.Label("", Anchor.Right, Anchor.Top),
        missionLabel = UI.Label("", Anchor.Left, Anchor.Bottom),
        timerLabel = UI.Label("", Anchor.Left, Anchor.Top),
        timerDone = true,
        timerSec = 0,
        timerMin = 0
    }

    -- Level object
    rWorld = {
        Spawn = Number3(0, 0, 0),
        Portal = nil,
        Map = nil,
        Sound = nil,
        Dialogues = nil,
        NeedKey = nil,
        Mission = "",
        Lights = {},
        Items = {},
        Level = 0,
        Levels = {
            {
                Spawn = Number3(642.51, 100.0, 642.32),
                Portal = {
                    Item = rItems.RedPortal,
                    Pos = Number3(640.0, 75.0, 88.4),
                    Scale = 10,
                    Rotation = Number3(0, math.pi / 2, 0)
                },
                Rotation = Number3(0, 0, 0),
                Map = Items.misteryou61.map_muspellheim,
                Init = rMuspellheimInit,
                Mission = "Accede au portail. Attention a la lave",
                Lights = {
                    {
                        Type = LightType.Directional,
                        Color = Color(135, 0, 0),
                        Rotation = Number3(math.pi * 0.3, math.pi * 0.5, 0)
                    }
                },
                Time = {
                    Current = Time.Noon,
                    Mark = TimeCycle.Marks.Noon,
                    Cycle = false,
                    SkyColor = Color(220, 37, 37),
                    HorizonColor = Color(85, 18, 18),
                    AbyssColor = Color(51, 6, 6),
                    SkyLightColor = Color(220, 37, 37),
                },
                Items = {
                    {
                        Item = rItems.Chest,
                        Pos = Number3(1221.72, 75.0, 611.83),
                        Scale = 0.3,
                        Rotation = Number3(0, 0, 0),
                    },
                    {
                        Item = rItems.Groot,
                        Pos = Number3(662.43, 99.99, 662.59),
                        Scale = 0.3,
                        Rotation = Number3(0, -((math.pi / 2 ) + (math.pi / 4)), 0),
                    },
                },
                Dialogues = {
                    {
                        Player = false,
                        Text = "Hey, toi ! Tu dois fuir, vite ! Surt te cherche !",
                        Wait = 5.0,
                        Music = "1groot1_out.mp3"
                    },
                    {
                        Player = true,
                        Text = "Qui est Surt ? Et pourquoi me cherche-t-il ?",
                        Wait = 4.0,
                        Music = "1perso1_out.mp3"
                    },
                    {
                        Player = false,
                        Text = "Surt est un geant de feu qui regne sur Muspellheim.\nTu n'as rien a faire ici, c'est dangereux. Si Surt te trouve, il te tuera.",
                        Wait = 12.0,
                        Music = "1groot2_out.mp3"
                    },
                    {
                        Player = true,
                        Text = "Mais comment suis-je arrive ici ? Je ne me souviens de rien.",
                        Wait = 8.0,
                        Music = "1perso2_out.mp3"
                    },
                    {
                        Player = false,
                        Text = "Je ne sais pas. Peu importe comment tu es arrive ici, il est temps de fuir.\nJe vais rester ici pour te donner un peu plus de temps.\nPars vite, trouve un chemin de sortie et echappe a Surt !",
                        Wait = 18.0,
                        Music = "1groot3_out.mp3"
                    },
                    {
                        Player = true,
                        Text = "D'accord, merci Groot. Je n'oublierai pas ce que tu fais pour moi.",
                        Wait = 5.0,
                        Music = "1perso3_out.mp3"
                    },
                    {
                        Player = false,
                        Text = "Ce n'est rien. Vas-y maintenant ! Je vais tenir Surt a distance le plus longtemps possible.\nSois prudent !",
                        Wait = 8.0,
                        Music = "1groot4_out.mp3"
                    }
                }
            },
            {
                Spawn = Number3(-42, 35, 57),
                Portal = {
                    Item = rItems.GreenProtal,
                    Pos = Number3(264, 252, -231),
                    Scale = 3,
                    Rotation = Number3(0, -math.pi / 2, 0)
                },
                Rotation = Number3(0, 0, 0),
                Map = nil,
                Mission = "Accede au portail en realisant le parcours",
                Init = rAlfheimInit,
                Lights = {},
                Time = nil,
                Items = {
                    {
                        Item = rItems.FeeMapWall,
                        Pos = Number3(0, 0, 0),
                        Scale = 5,
                        Rotation = Number3(0, 0, 0),
                    },
                    {
                        Item = rItems.Sakura,
                        Pos = Number3(255, 100, -255),
                        Scale = 4,
                        Rotation = Number3(0, math.pi, 0),
                    },
                    {
                        Item = rItems.FeeChest,
                        Pos = Number3(130, 105, 477),
                        Scale = 0.3,
                        Rotation = Number3(0, 0, 0),
                    },
                    {
                        Item = rItems.FeeChest,
                        Pos = Number3(-100, 35, 173),
                        Scale = 0.3,
                        Rotation = Number3(0, -math.pi/2, 0),
                    },
                    {
                        Item = rItems.FeeMap,
                        Pos = Number3(-255, 0, 255),
                        Scale = 5,
                        Rotation = Number3(0, math.pi/2*3, 0),
                    },
                    {
                        Item = rItems.FeeMap2,
                        Pos = Number3(255, 0, 255),
                        Scale = 5,
                        Rotation = Number3(0, math.pi/2, 0),
                    }
                },
                Dialogues = {}
            },
            {
                Spawn = Number3(186, 20, -550),
                Portal = {
                    Item = rItems.GrayPortal,
                    Pos = Number3(-49.70, 5.0, -430.42),
                    Scale = 3,
                    Rotation = Number3(0, 0, 0)
                },
                Rotation = Number3(0, 0, 0),
                Map = nil,
                Init = rNidavellirInit,
                Mission = "Trouve la pioche perdue",
                Lights = {
                    {
                        Type = LightType.Directional,
                        Color = Color(160, 160, 160),
                        Rotation = Number3(math.pi * 0.3, math.pi * 0.5, 0)
                    }
                },
                Time = nil,
                Items = {
                    -- Set map to object (Sync position with Mappeurs)
                    {
                        Item = Items.axelfradet.map_nidevellir,
                        Pos = Number3(0, 0, 0),
                        Scale = 5,
                        Rotation = Number3(0, 0, 0),
                    },
                    {
                        Item = Items.divergonia.green_portal_1,
                        Pos = Number3(186, 5, -610),
                        Scale = 3,
                        Rotation = Number3(0, math.pi/2, 0),
                    },
                    {
                        Item = Items.misteryou61.minecraft_forge1,
                        Pos = Number3(-179, 5, -470),
                        Scale = 4,
                        Rotation = Number3(0, math.pi, 0),
                    },
                    {
                        Item = Items.misteryou61.minecraft_forge1,
                        Pos = Number3(131, 5, -198),
                        Scale = 3.5,
                        Rotation = Number3(0, 0, 0),
                    },
                    {
                        Item = Items.misteryou61.character_knight,
                        Pos = Number3(5, 95, -34),
                        Scale = 1.5,
                        Rotation = Number3(0, 50, 0),
                    },
                    {
                        Item = Items.misteryou61.character_knight,
                        Pos = Number3(336, 60, -26),
                        Scale = 1.5,
                        Rotation = Number3(0, math.pi, 0),
                    },
                    {
                        Item = Items.misteryou61.character_knight,
                        Pos = Number3(416, 110, -372),
                        Scale = 1.5,
                        Rotation = Number3(0, math.pi*1.7 + math.pi, 0),
                    },
                    {
                        Item = Items.misteryou61.character_knight,
                        Pos = Number3(-596, 424, 190),
                        Scale = 1.5,
                        Rotation = Number3(0, math.pi*1.7, 0),
                    },
                    {
                        Item = Items.misteryou61.character_knight,
                        Pos = Number3(520, 530, -358),
                        Scale = 1.5,
                        Rotation = Number3(0, -math.pi/4, 0),
                    },
                    {
                        Item = Items.misteryou61.character_knight,
                        Pos = Number3(456, 270, 151),
                        Scale = 1.5,
                        Rotation = Number3(0, math.pi/4, 0),
                    },
                    {
                        Item = Items.misteryou61.character_swordman1,
                        Pos = Number3(-329, 120, 383),
                        Scale = 1.5,
                        Rotation = Number3(0, 75, 0),
                    },
                    {
                        Item = Items.misteryou61.character_swordman1,
                        Pos = Number3(-336, 5, -304),
                        Scale = 1.5,
                        Rotation = Number3(0, 75, 0),
                    },
                    {
                        Item = Items.misteryou61.character_swordman1,
                        Pos = Number3(114, 5, -259),
                        Scale = 1.5,
                        Rotation = Number3(0, math.pi/6, 0),
                    },
                    {
                        Item = Items.misteryou61.character_swordman1,
                        Pos = Number3(-336, 130, -230),
                        Scale = 1.5,
                        Rotation = Number3(0, math.pi/6, 0),
                    },
                    {
                        Item = Items.misteryou61.character_swordman1,
                        Pos = Number3(-157, 375, 186),
                        Scale = 1.5,
                        Rotation = Number3(0, math.pi/6, 0),
                    },
                    {
                        Item = Items.divergonia.lantern,
                        Pos = Number3(70, 15, -425),
                        Scale = 0.3,
                        Rotation = Number3(0, math.pi/6, 0),
                    },
                    {
                        Item = Items.divergonia.lantern,
                        Pos = Number3(103, 100, -40),
                        Scale = 0.3,
                        Rotation = Number3(0, math.pi/2, 0),
                    },
                    {
                        Item = Items.divergonia.lantern,
                        Pos = Number3(259, 180, -380),
                        Scale = 0.3,
                        Rotation = Number3(0, math.pi/2, 0),
                    },
                    {
                        Item = Items.divergonia.lantern,
                        Pos = Number3(515, 535, -327),
                        Scale = 0.3,
                        Rotation = Number3(0, 3*math.pi/4, 0),
                    },
                    {
                        Item = Items.divergonia.opened_treasure,
                        Pos = Number3(138, 5, -408),
                        Scale = 0.3,
                        Rotation = Number3(0, 3*math.pi/4, 0),
                    },
                    {
                        Item = Items.divergonia.opened_treasure,
                        Pos = Number3(-502, 100, 409),
                        Scale = 0.3,
                        Rotation = Number3(0, math.pi/5, 0),
                    },
                    {
                        Item = Items.divergonia.opened_treasure,
                        Pos = Number3(480, 225, -611),
                        Scale = 0.3,
                        Rotation = Number3(0, math.pi/4, 0),
                    },
                },
                Dialogues = {},
                NeedKey = true
            },
            {
                Spawn = Number3(411.74, 112.49, 466.30),
                Portal = {
                    Item = rItems.BluePortal,
                    Pos = Number3(482.70, 90.0, 385.30),
                    Scale = 3,
                    Rotation = Number3(0, 0, 0)
                },
                Rotation = Number3(0, 0, 0),
                Map = Items.axelfradet.map_ground,
                Init = rNiflheimInit,
                Mission = "Trouve la cle pour t'enfuir",
                Lights = {
                    {
                        Type = LightType.Directional,
                        Color = Color(111, 144, 151),
                        Rotation = Number3(math.pi * 0.3, math.pi * 0.5, 0)
                    }
                },
                Time = {
                    Current = Time.Noon,
                    Mark = TimeCycle.Marks.Noon,
                    Cycle = false,
                    SkyColor = Color(27, 186, 218),
                    HorizonColor = Color(179, 225, 235),
                    AbyssColor = Color(250, 250, 250),
                    SkyLightColor = Color(82, 203, 228),
                },
                Items = {
                    {
                        Item = rItems.IceBuild,
                        Pos = Number3(331.90, 89.99, 386.44),
                        Scale = 2.5,
                        Rotation = Number3(0, 0, 0),
                    },
                    {
                        Item = rItems.IceSpike2,
                        Pos = Number3(590.6, 45.0, 52.72),
                        Scale = 2,
                        Rotation = Number3(0, 0, 0),
                        Type = "spike"
                    },
                    {
                        Item = rItems.IceSpike1,
                        Pos = Number3(490.49, 45.0, 62.7),
                        Scale = 2,
                        Rotation = Number3(0, -math.pi, 0),
                        Type = "spike"
                    },
                    {
                        Item = rItems.IceSpike2,
                        Pos = Number3(287.95, 75.0, 106.44),
                        Scale = 2,
                        Rotation = Number3(0, 0, 0),
                        Type = "spike"
                    },
                    {
                        Item = rItems.IceSpike1,
                        Pos = Number3(131.98, 65.0, 127.65),
                        Scale = 2,
                        Rotation = Number3(0, -math.pi / 2, 0),
                        Type = "spike"
                    },
                    {
                        Item = rItems.IceSpike1,
                        Pos = Number3(82.88, 65.0, 204.16),
                        Scale = 2,
                        Rotation = Number3(0, -math.pi, 0),
                        Type = "spike"
                    },
                    {
                        Item = rItems.IceSpike2,
                        Pos = Number3(90.17, 75.0, 321.88),
                        Scale = 2,
                        Rotation = Number3(0, 0, 0),
                        Type = "spike"
                    },
					{
                        Item = rItems.IceSpike1,
                        Pos = Number3(133.57, 75.0, 477.45),
                        Scale = 2,
                        Rotation = Number3(0, 30, 0),
                        Type = "spike"
                    },
					{
                        Item = rItems.IceSpike2,
                        Pos = Number3(339.91, 90, 503.67),
                        Scale = 3,
                        Rotation = Number3(0, 30, 0),
                        Type = "spike"
                    },
					{
                        Item = rItems.IceSpike1,
                        Pos = Number3(452.14, 80, 517.19999),
                        Scale = 3,
                        Rotation = Number3(0, 20, 0),
                        Type = "spike"
                    },
					{
                        Item = rItems.IceSpike2,
                        Pos = Number3(501.28, 75, 197.01),
                        Scale = 3,
                        Rotation = Number3(0, 80, 0),
                        Type = "spike"
                    },
					{
                        Item = rItems.IceSpike1,
                        Pos = Number3(365.71, 85, 236.23),
                        Scale = 5,
                        Rotation = Number3(0, 80, 0),
                        Type = "spike"
                    },
					{
                        Item = rItems.IceSpike2,
                        Pos = Number3(103.74, 70, 53.91),
                        Scale = 2,
                        Rotation = Number3(0, 120, 0),
                        Type = "spike"
                    },
					{
                        Item = rItems.IceSpike1,
                        Pos = Number3(211.05, 90, 355.56),
                        Scale = 2,
                        Rotation = Number3(0, 180, 0),
                        Type = "spike"
                    },
					{
                        Item = rItems.IceSpike2,
                        Pos = Number3(205.93, 75, 225.155),
                        Scale = 1.80,
                        Rotation = Number3(0, 180, 0),
                        Type = "spike"
                    },
					{
                        Item = rItems.IceSpike1,
                        Pos = Number3(121.71, 80, 395.51),
                        Scale = 3,
                        Rotation = Number3(0, 180, 0),
                        Type = "spike"
                    },
					{
                        Item = rItems.IceSpike1,
                        Pos = Number3(61.080, 60, 597.15),
                        Scale = 1.60,
                        Rotation = Number3(0, 180, 0),
                        Type = "spike"
                    },
					{
                        Item = rItems.IceSpike2,
                        Pos = Number3(278.11, 75, 612.83),
                        Scale = 1.60,
                        Rotation = Number3(0, 180, 0),
                        Type = "spike"
                    },
					{
                        Item = rItems.IceSpike1,
                        Pos = Number3(395.95, 65, 105.68),
                        Scale = 1.80,
                        Rotation = Number3(0, 180, 0),
                        Type = "spike"
                    },
					{
                        Item = rItems.IceSpike1,
                        Pos = Number3(241.61, 65, 32.4235),
                        Scale = 3.50,
                        Rotation = Number3(0, 56, 0),
                        Type = "spike"
                    },
					{
                        Item = rItems.IceSpike2,
                        Pos = Number3(343, 75, 148.96),
                        Scale = 2.60,
                        Rotation = Number3(0, 80, 0),
                        Type = "spike"
                    },
                },
                Dialogues = {},
                NeedKey = true
            },
            {
                Spawn = Number3(1166.44, 30, 1075),
                Portal = {
                    Item = rItems.GrayPortal,
                    Pos = Number3(-100, -100, -100),
                    Scale = 0.1,
                    Rotation = Number3(0, 0, 0)
                },
                Rotation = Number3(0, 0, 0),
                Map = Items.misteryou61.city_mapv1,
                Mission = "Rentre a la maison",
                Init = rCityInit,
                Lights = {},
                Time = nil,
                Items = {
                    {
                        Item = rItems.ice_flower,
                        Pos = Number3(640, 30, 568),
                        Scale = 2,
                        Rotation = Number3(0, 0, 0),
                    },
                    {
                        Item = rItems.house1,
                        Pos = Number3(770, 30, 460),
                        Scale = 1.40,
                        Rotation = Number3(0, 0, 0),
                    },
                    {
                        Item = rItems.house2,
                        Pos = Number3(550, 30, 460),
                        Scale = 1.40,
                        Rotation = Number3(0, 0, 0),
                    },
                    {
                        Item = rItems.house3,
                        Pos = Number3(330, 30, 460),
                        Scale = 1.40,
                        Rotation = Number3(0, 0, 0),
                    },
                    {
                        Item = rItems.store1,
                        Pos = Number3(230, 30, 1060),
                        Scale = 1.40,
                        Rotation = Number3(0, math.pi, 0),
                    },
                    {
                        Item = rItems.store2,
                        Pos = Number3(538, 30, 820),
                        Scale = 1,
                        Rotation = Number3(0, math.pi, 0),
                    },
                    {
                        Item = rItems.store3,
                        Pos = Number3(1115, 30, 500),
                        Scale = 1.40,
                        Rotation = Number3(0, math.pi / 2, 0),
                    },
                    {
                        Item = rItems.cinema,
                        Pos = Number3(460, 30, 110),
                        Scale = 2,
                        Rotation = Number3(0, math.pi / 2, 0),
                    },
                    {
                        Item = rItems.house2,
                        Pos = Number3(740, 30, 92),
                        Scale = 1.40,
                        Rotation = Number3(0, 0, 0),
                    },
                    {
                        Item = rItems.store1,
                        Pos = Number3(166, 30, 130),
                        Scale = 1.40,
                        Rotation = Number3(0, math.pi * 1.5, 0),
                    },
                    {
                        Item = rItems.house4,
                        Pos = Number3(286, 30, 840),
                        Scale = 1.40,
                        Rotation = Number3(0, 0, 0),
                    },
                    {
                        Item = rItems.house6,
                        Pos = Number3(760, 30, 880),
                        Scale = 1.50,
                        Rotation = Number3(0, 0, 0),
                    },
                    {
                        Item = rItems.park,
                        Pos = Number3(760, 30, 1100),
                        Scale = 1.50,
                        Rotation = Number3(0, math.pi * 1.5, 0),
                    },
                    {
                        Item = rItems.park,
                        Pos = Number3(580, 30, 1100),
                        Scale = 1.50,
                        Rotation = Number3(0, math.pi * 1.5, 0),
                    },
                    {
                        Item = rItems.house1,
                        Pos = Number3(1160, 30, 92),
                        Scale = 1.40,
                        Rotation = Number3(0, 0, 0),
                    },
                    {
                        Item = rItems.cinema,
                        Pos = Number3(1166, 30, 880),
                        Scale = 1.40,
                        Rotation = Number3(0, math.pi, 0),
                    },
                    {
                        Item = rItems.house4,
                        Pos = Number3(1145, 30, 690),
                        Scale = 1.40,
                        Rotation = Number3(0, 0, 0),
                    },
                    {
                        Item = rItems.stop_sign,
                        Pos = Number3(885, 30, 573),
                        Scale = 1.40,
                        Rotation = Number3(0, math.pi / 2, 0),
                    },
                    {
                        Item = rItems.stop_sign,
                        Pos = Number3(1027, 30, 345),
                        Scale = 1.40,
                        Rotation = Number3(0, math.pi * 1.50, 0),
                    },
                    {
                        Item = rItems.stop_sign,
                        Pos = Number3(14, 30, 347),
                        Scale = 1.40,
                        Rotation = Number3(0, math.pi * 3, 0),
                    },
                    {
                        Item = rItems.stop_sign,
                        Pos = Number3(154, 30, 715),
                        Scale = 1.40,
                        Rotation = Number3(0, math.pi * 1.5, 0),
                    },
                    {
                        Item = rItems.autobus,
                        Pos = Number3(770, 30, 310),
                        Scale = 1.40,
                        Rotation = Number3(0, math.pi * 1.5, 0),
                    },
                    {
                        Item = rItems.pink_car,
                        Pos = Number3(320, 30, 310),
                        Scale = 1.60,
                        Rotation = Number3(0, math.pi * 1.5, 0),
                    },
                    {
                        Item = rItems.blue_car,
                        Pos = Number3(520, 30, 310),
                        Scale = 1.60,
                        Rotation = Number3(0, math.pi * 1.5, 0),
                    },
                    {
                        Item = rItems.green_car,
                        Pos = Number3(624, 30, 240),
                        Scale = 1.60,
                        Rotation = Number3(0, math.pi / 2, 0),
                    },
                    {
                        Item = rItems.orange_car,
                        Pos = Number3(420, 30, 240),
                        Scale = 1.60,
                        Rotation = Number3(0, math.pi / 2, 0),
                    },
                    {
                        Item = rItems.orange_car,
                        Pos = Number3(908, 30, 240),
                        Scale = 1.60,
                        Rotation = Number3(0, math.pi / 2, 0),
                    },
                    {
                        Item = rItems.autobus,
                        Pos = Number3(986, 30, 803),
                        Scale = 1.40,
                        Rotation = Number3(0, 0, 0),
                    },
                    {
                        Item = rItems.pink_car,
                        Pos = Number3(1071, 30, 1110),
                        Scale = 1.60,
                        Rotation = Number3(0, math.pi * 1.5, 0),
                    },
                    {
                        Item = rItems.blue_car,
                        Pos = Number3(920, 30, 983),
                        Scale = 1.60,
                        Rotation = Number3(0, math.pi * 3, 0),
                    },
                    {
                        Item = rItems.orange_car,
                        Pos = Number3(920, 30, 615),
                        Scale = 1.60,
                        Rotation = Number3(0, math.pi * 3, 0),
                    },
                    {
                        Item = rItems.pink_car,
                        Pos = Number3(1068, 30, 310),
                        Scale = 1.60,
                        Rotation = Number3(0, math.pi * 1.5, 0),
                    },
                    {
                        Item = rItems.green_car,
                        Pos = Number3(986, 30, 448),
                        Scale = 1.60,
                        Rotation = Number3(0, 0, 0),
                    },
                    {
                        Item = rItems.green_car,
                        Pos = Number3(986, 30, 448),
                        Scale = 1.60,
                        Rotation = Number3(0, 0, 0),
                    },
                    {
                        Item = rItems.orange_car,
                        Pos = Number3(420, 30, 240),
                        Scale = 1.60,
                        Rotation = Number3(0, math.pi / 2, 0),
                    },
                    {
                        Item = rItems.blue_car,
                        Pos = Number3(133, 30, 240),
                        Scale = 1.60,
                        Rotation = Number3(0, math.pi / 2, 0),
                    },
                    {
                        Item = rItems.taxis_car,
                        Pos = Number3(120, 30, 426),
                        Scale = 1.60,
                        Rotation = Number3(0, 0, 0),
                    },
                    {
                        Item = rItems.autobus,
                        Pos = Number3(220, 30, 681),
                        Scale = 1.60,
                        Rotation = Number3(0, math.pi * 1.5, 0),
                    },
                    {
                        Item = rItems.orange_car,
                        Pos = Number3(51, 30, 385),
                        Scale = 1.60,
                        Rotation = Number3(0, math.pi, 0),
                    },
                    {
                        Item = rItems.taxis_car,
                        Pos = Number3(51, 30, 582),
                        Scale = 1.60,
                        Rotation = Number3(0, math.pi, 0),
                    },
                    {
                        Item = rItems.blue_car,
                        Pos = Number3(51, 30, 841),
                        Scale = 1.60,
                        Rotation = Number3(0, math.pi, 0),
                    },
                    {
                        Item = rItems.pink_car,
                        Pos = Number3(120, 30, 1013),
                        Scale = 1.60,
                        Rotation = Number3(0, 0, 0),
                    },
                    {
                        Item = rItems.green_car,
                        Pos = Number3(481, 30, 681),
                        Scale = 1.60,
                        Rotation = Number3(0, math.pi * 1.5, 0),
                    },
                    {
                        Item = rItems.taxis_car,
                        Pos = Number3(717, 30, 681),
                        Scale = 1.60,
                        Rotation = Number3(0, math.pi * 1.5, 0),
                    },
                    {
                        Item = rItems.blue_car,
                        Pos = Number3(268, 30, 610),
                        Scale = 1.60,
                        Rotation = Number3(0, math.pi / 2, 0),
                    },
                    {
                        Item = rItems.autobus,
                        Pos = Number3(526, 30, 610),
                        Scale = 1.60,
                        Rotation = Number3(0, math.pi / 2, 0),
                    },
                    {
                        Item = rItems.pink_car,
                        Pos = Number3(780, 30, 610),
                        Scale = 1.60,
                        Rotation = Number3(0, math.pi / 2, 0),
                    },
                },
                Dialogues = {},
                NeedKey = true
            },
        }
    }

    rWorld.SetLevel = function(index)
        local level = rWorld.Levels[index]

        -- Setup world variables
        rWorld.Spawn = level.Spawn
        rWorld.Level = index

        -- Setup portal
        if rWorld.Portal ~= nil then
            rWorld.Portal:RemoveFromParent()
        end
        rWorld.Portal = rSpawnObject(level.Portal.Pos.X, level.Portal.Pos.Y, level.Portal.Pos.Z, level.Portal.Item, level.Portal.Scale, 1, level.Portal.Rotation)

        -- Setup lights
        while #rWorld.Lights ~= 0 do
            rWorld.Lights[1]:RemoveFromParent()
            table.remove(rWorld.Lights, 1)
        end
        for _,light in pairs(level.Lights) do
            if light.Type == LightType.Directional then
                rSpawnLightDirectional(light)
            end
        end

        -- Setup time / atmosphere
        if level.Time ~= nil then
            rUpdateTime(level.Time)
        else
            local mark = rDefault.Mark

            mark.SkyColor = rDefault.SkyColor
            mark.HorizonColor = rDefault.HorizonColor
            mark.AbyssColor = rDefault.AbyssColor
            mark.SkyLightColor = rDefault.SkyLightColor
        end

        -- Setup items
        while #rWorld.Items ~= 0 do
            rWorld.Items[1]:RemoveFromParent()
            table.remove(rWorld.Items, 1)
        end
        for index, item in pairs(level.Items) do
            local object = rSpawnObject(item.Pos.X, item.Pos.Y, item.Pos.Z, item.Item, item.Scale, 1, item.Rotation)
            table.insert(rWorld.Items, object)
        end

        -- Setup map
        if rWorld.Map ~= nil then
            rWorld.Map:RemoveFromParent()
        end
        rWorld.Map = nil
        if level.Map ~= nil then
            rWorld.Map = rSpawnMap(level.Map)
        end

        -- rWorld.Sound:Stop()
        -- rWorld.Sound = sound
        -- sound.Sound = ""

        -- Init dialogues
        rWorld.Dialogues = level.Dialogues

        -- Init key
        rWorld.NeedKey = level.NeedKey

        -- Init mission
        rWorld.Mission = level.Mission
        rUi.missionLabel.Text = rWorld.Mission

        -- Init function
        level.Init()
    end

    dropPlayer = function()
        Player.Position = Number3(rWorld.Spawn.X, rWorld.Spawn.Y, rWorld.Spawn.Z)
        Player.Rotation = { 0, 0, 0 }
        Player.Velocity = { 0, 0, 0 }
    end

    -- Init player
    World:AddChild(Player)
    rWorld.SetLevel(1)
    dropPlayer()

    rUi.timerLabel.Text = "Time: " .. math.floor(rUi.timerMin) .. ":" .. math.floor(rUi.timerSec)

    -- Clouds
    Clouds.On = false
	Fog.On = false

    -- Init sound
    rAudioListener = AudioSource()

    -- TEST ZONE --

    Dev.DisplayColliders = false

    --debug = rDebugPlayer()

    -- END TEST ZONE --
end

Client.Tick = function(dt)
    -- Player in void
    if Player.Position.Y < -500 then
        dropPlayer()
        Player:TextBubble("shit")
    end

    -- Player contact with portal
    rCollisionPortal(rWorld.Portal, function(level)
        if rWorld.NeedKey == nil or rWorld.NeedKey == false or rPlayer.Keys == 1 then
            rPlayer.Keys = 0
            rWorld.SetLevel(level)
            dropPlayer()
        else
            if rWorld.Level == 3 then
                Player:TextBubble("Je n'ai pas trouve ma pioche.. Je devrais la chercher pour partir")
            end
            if rWorld.Level == 4 then
                Player:TextBubble("Je n'ai pas la cle... Je devrais la chercher pour partir")
            end
        end
    end, rWorld.Level + 1)

    -- Debug Player
    -- rDebugPlayer(debug)

    -- UI
    rRefreshLabels()
    if rUi.timerDone then
        rUi.timerSec = rUi.timerSec + dt
    end
    if rUi.timerSec >= 60 and rPlayer.End == false then
        rUi.timerMin = rUi.timerMin + 1
    end
    if rUi.timerSec < 10 then
        rUi.timerLabel.Text = "Temps : " .. math.floor(rUi.timerMin) .. ":0" .. math.floor(rUi.timerSec)
    else 
        rUi.timerLabel.Text = "Temps : " .. math.floor(rUi.timerMin) .. ":" .. math.floor(rUi.timerSec)
    end

    -- Levels Tick
    if rWorld.Level == 1 then
        rMuspellheimTick()
    end
    if rWorld.Level == 2 then
        rAlfheimTick()
    end
    if rWorld.Level == 3 then
        rNidavellirTick()
    end
end

-- jump function, triggered with Action1
Client.Action1 = function()
    if Player.IsOnGround then
        Player.Velocity.Y = 100
    end
end

Client.Action2 = function()
    if rWorld.Level == 4 then
        Player:SwingRight()
        destroyObject()
    end
end

Client.AnalogPad = function(dx, dy)
    Player.LocalRotation.Y = Player.LocalRotation.Y + dx * 0.01
    Player.LocalRotation.X = Player.LocalRotation.X + -dy * 0.01

    if dpadX ~= nil and dpadY ~= nil then
        Player.Motion = (Player.Forward * dpadY + Player.Right * dpadX) * 50
    end
end

Client.DirectionalPad = function(x, y)
    if not rPlayer.Blocked then
        dpadX = x dpadY = y
        Player.Motion = (Player.Forward * y + Player.Right * x) * 50
    end
end

--
-- Levels code
--

function rMuspellheimInit()
    -- Camera render distance
    Camera.Far = Camera.Far * 2

    --rAnimeLava()
    rPlayer.Blocked = true
    rGroot(1)
end

function rMuspellheimTick()

    -- Objects collisions
    for index, item in pairs(rWorld.Items) do
        if item.rItem == rItems.Chest or item.rItem == rItems.FeeChest then
            rCollisionObject(item, function()
                if item.claim ~= true then
                    item.claim = true
                    rPlayer.Bonus = rPlayer.Bonus + 1
                end
            end)
        end
    end

    -- Dead
    local dir = Number3(0, -1, 0)
    local ray = Ray(Player.Position, dir)
    local impact = ray:Cast(Map.CollisionGroups)

    if impact.Block.Color == Color(255, 102, 0) and Player.Position.Y - impact.Block.Position.Y <= 5.0 then
        rPlayer.Lifes = rPlayer.Lifes - 1
        dropPlayer()
        Player:TextBubble("Aie !")
    end
end

function rGroot(index)
    local groot = rWorld.Items[2]
    if groot == nil then return end
    local dialogue = rWorld.Dialogues[index]
    if dialogue == nil then return end
    local dial = nil

    dial = rDialogue(dialogue.Text, dialogue.Wait, (dialogue.Player and Player or groot))
    for _, music in ipairs(soundData) do
        if music ~= nil and music.name == dialogue.Music and music.music ~= nil then
            rAudioListener.Sound = music.music
            rAudioListener:SetParent(World)
            rAudioListener.Spatialized = false
            rAudioListener:Play()
        end
    end
    Timer(dialogue.Wait, function()
        dial:RemoveFromParent()
        if rWorld.Dialogues[index + 1] ~= nil then
            rGroot(index + 1)
        else
            rPlayer.Blocked = false
            for _, music in ipairs(soundData) do
                if music ~= nil and music.name == "Yggdrasil_feu_V1.mp3" then
                    rAudioListener.Sound = music.music
                    rAudioListener.Volume = 0.9
                    rAudioListener.Spatialized = false
                    rAudioListener:Play()
                end
            end
        end
    end)
end

-- function rAnimeLava()
--     local map = MutableShape(rWorld.Map)
--     local lava = MutableShape()
--     local process = 1

--     for x = rProcess.lava, map.Width do
--         for y = 1, map.Height do
--             for z = 1, map.Depth do
--                 local block = map:GetBlock(x, y, z)
--                 if block ~= nil and block.Color == Color(255, 102, 0) then
--                     lava:AddBlock(block.Color, block.Position)
--                     block:Remove()
--                 end
--             end
--         end
--         rProcess.lava = x + 1
--         process = process + 1
--         if process >= 10 then
--             Timer(0.5, function()
--                 print("Restart load")
--                 rAnimeLava()
--             end)
--             break 
--         end
--     end
--     if ()
--     rWorld.Map:RemoveFromParent()
--     rWorld.Map = rSpawnMap(map)
--     lava.IsUnlit = true

--     local sLava = Shape(lava)

--     sLava.Scale = rWorld.Map.Scale
--     sLava.Physics = PhysicsMode.StaticPerBlock
--     sLava.Friction = rWorld.Map.Friction
--     sLava.Bounciness = rWorld.Map.Bounciness

--     rWorld.Map:AddChild(sLava)
--     sLava.Pivot = rWorld.Map.Pivot
--     sLava.LocalPosition = rWorld.Map.Position
--     sLava.CollisionGroups = 1

--     table.insert(rWorld.Items, sLava)
-- end

function rAlfheimInit()
    -- Camera render distance
    Camera.Far = rDefault.Camera * 2

    TimeCycle.On = false

    for i = 0, 6 do	
		local tree = rSpawnObject(math.random(-500, 500), math.random(50, 500), math.random(-500, 500), Items.divergonia.feeric_tree_1, 3, 1, {0, 0, 0})
        table.insert(rWorld.Items, tree)
	end
	for i = 0, 6 do	
		local tree = rSpawnObject(math.random(-500, 500), math.random(50, 500), math.random(-500, 500), Items.divergonia.feeric_tree_2, 3, 1, {0, 0, 0})
        table.insert(rWorld.Items, tree)
	end
    for i = 0, 6 do	
		local tree = rSpawnObject(math.random(-500, 500), math.random(50, 500), math.random(-500, 500), Items.divergonia.feeric_tree_3, 3, 1, {0, 0, 0})
        table.insert(rWorld.Items, tree)
	end
    for _, music in ipairs(soundData) do
        if music ~= nil and music.name == "Yggdrasil_elfe_v1.mp3" then
            rAudioListener.Sound = music.music
            rAudioListener.Volume = 0.9
            rAudioListener.Spatialized = false
            rAudioListener:Play()
        end
    end
end

function rAlfheimTick()
    -- Dead
    local dir = Number3(0, -1, 0)
    local ray = Ray(Player.Position, dir)
    local impact = ray:Cast(Map.CollisionGroups)

    if impact.Block.Color == Color(255, 102, 102, 212) and Player.Position.Y - impact.Block.Position.Y <= 5.0 then
        rPlayer.Lifes = rPlayer.Lifes - 1
        dropPlayer()
        Player:TextBubble("Aïe !")
    end
end

function rNidavellirInit()
    -- Camera render distance
    Camera.Far = rDefault.Camera * 2

    TimeCycle.On = false

    local spawn_pick = {
        Number3(187, 5, -633),
        Number3(-364.74, 5.0, -612.87),
        Number3(-335.63, 130.0, -234.82),
        Number3(78.99, 110.0, 161.24),
        Number3(-208.91, 165.0, 396.40),
        Number3(-491.06, 100.0, 413.90),
        Number3(-536.82, 99.99, -207.71),
    }
    local pos = math.random(1, #spawn_pick)
    local pick = rSpawnObject(spawn_pick[pos].X, spawn_pick[pos].Y + 0.7, spawn_pick[pos].Z, rItems.Pickaxe, 1.3, 1, {0, 0, math.pi / 2})
    table.insert(rWorld.Items, pick)
    for _, music in ipairs(soundData) do
        if music ~= nil and music.name == "AMB_GROTTE_ET_THEME_out.mp3" then
            rAudioListener.Sound = music.music
            rAudioListener.Volume = 0.9
            rAudioListener.Spatialized = false
            rAudioListener:Play()
        end
    end
end

function rNidavellirTick()
    for index, item in pairs(rWorld.Items) do
        if item.rItem == rItems.Pickaxe then
            rCollisionObject(item, function()
                Player:TextBubble("Enfin ! Retournons au portail")
                rWorld.NeedKey = false
                item:RemoveFromParent()
                table.remove(rWorld.Items, index)
            end)
        end
    end
end

function rNiflheimInit()
    -- Camera render distance
    Camera.Far = rDefault.Camera * 2

    weapon = Shape(rItems.Pickaxe)
    weapon.Scale = 0.69
    Player:EquipRightHand(weapon)
    for _, music in ipairs(soundData) do
        if music ~= nil and music.name == "Yggdrasil_glace_V1_2.mp3" then
            rAudioListener.Sound = music.music
            rAudioListener.Volume = 0.9
            rAudioListener.Spatialized = false
            rAudioListener:Play()
        end
    end
end

function rCityInit()
    Camera.Far = rDefault.Camera * 2
end

function rCityTickt()
    if rPlayer.End == false then
        local collision = true
        local pos = Number3(0, 0, 0)

        if (Player.Position.X - pos.X < -5 or Player.Position.X - pos.X < 5) then
            collision = false
        end
        if (Player.Position.Y - pos.Y < -5 or Player.Position.Z - pos.Z < 5) then
            collision = false
        end
        if (Player.Position.Z - pos.Z < -5 or Player.Position.Z - pos.Z < 5) then
            collision = false
        end
        if (collision) then
            rPlayer.End = true
        end
    end
end

Client.DidReceiveEvent = function(e)
    table.insert(soundData, {name = e.name, music = e.sound})
end

Server.OnStart = function()
	soundData = {
        {
            name = "1groot1_out.mp3",
            music = nil
        },
        {
            name = "1perso1_out.mp3",
            music = nil
        },
        {
            name = "1groot2_out.mp3",
            music = nil
        },
        {
            name = "1groot2b_out.mp3",
            music = nil
        },
        {
            name = "1perso2_out.mp3",
            music = nil
        },
        {
            name = "1groot3_out.mp3",
            music = nil
        },
        {
            name = "1perso3_out.mp3",
            music = nil
        },
        {
            name = "1groot4_out.mp3",
            music = nil
        },
        {
            name = "Yggdrasil_feu_V1.mp3",
            music = nil
        },
        {
            name = "2perso1_out.mp3",
            music = nil
        },
        {
            name = "2perso2_out.mp3",
            music = nil
        },
        {
            name = "2perso3_out.mp3",
            music = nil
        },
        {
            name = "Yggdrasil_elfe_v1.mp3",
            music = nil
        },
        {
            name = "3voixmysterieuse_out.mp3",
            music = nil
        },
        {
            name = "AMB_GROTTE_ET_THEME_out.mp3",
            music = nil
        },
        {
            name = "Yggdrasil_glace_V1_2.mp3",
            music = nil
        },
    }

    for k, sound in ipairs(soundData) do
        HTTP:Get("https://api.voxdream.art/music/"..sound.name, function(res)
            if res.StatusCode ~= 200 then
                return
            end
            soundData[k].music = res.Body
            for _, p in pairs(Players) do
                local e = Event()
                e.sound = soundData[k].music
                e.name = soundData[k].name
                e:SendTo(p)
            end
        end)
    end
end

Server.OnPlayerJoin = function(p)
    if soundData ~= nil then
        for _, sound in ipairs(soundData) do
            if sound.music ~= nil then
                local e = Event()
                e.sound = sound.music
                e.name = sound.name
                e:SendTo(p)
            end
        end
    end
end
