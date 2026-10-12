local Solstices: any = (loadstring(game:HttpGet("https://raw.githubusercontent.com/13fffqdq/21kmfp21/refs/heads/main/uiiiiiiiiiii.lua")) :: any)()
local Window: any = Solstices:Window({Name = "Solstices.gg"})

Library = Solstices
Players = game:GetService("Players")
StarterGui = game:GetService("StarterGui")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
LocalPlayer = Players.LocalPlayer

do
    local env = (type(getgenv) == "function" and getgenv()) or _G
    if not env.SolsticesAntiAFKConnection then
        env.SolsticesAntiAFKConnection = LocalPlayer.Idled:Connect(function()
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            end)
        end)
    end
    if not env.SolsticesAdminDetectionInstalled then
        env.SolsticesAdminDetectionInstalled = true
        local names = {
            "D_Kappo", "P_act1vx", "la0g", "auditmywins",
            "GhostDontDev", "carvenrapter12", "luacoderboy",
            "ShinroStudios", "fakeflipsy", "drakeswag24",
            "50greedy", "MillieOrMillionz", "Klutzagon",
            "GetDescendantz", "mrstxrmz", "yanol"
        }
        local lookup = {}
        for _, name in ipairs(names) do
            lookup[string.lower(name)] = name
        end
        local kicked = false
        local function check(player)
            if kicked or not player or player == LocalPlayer then return end
            local matched = lookup[string.lower(player.Name)]
            if matched then
                kicked = true
                LocalPlayer:Kick("Listed admin joined: " .. matched)
            end
        end
        env.SolsticesAdminAddedConnection = Players.PlayerAdded:Connect(check)
        for _, player in ipairs(Players:GetPlayers()) do
            check(player)
        end
    end
end
ReplicatedStorage = game:GetService("ReplicatedStorage")
local function ResolveNet()
    local Modules = ReplicatedStorage:FindFirstChild("Modules")
    local Packages = Modules and Modules:FindFirstChild("Packages")
    local Index = Packages and Packages:FindFirstChild("_Index")
    local Package = Index and Index:FindFirstChild("sleitnick_net@0.2.0")
    return (Package and Package:FindFirstChild("net"))
        or ReplicatedStorage:FindFirstChild("net", true)
end

Net = ResolveNet()

function FindNet()
    Net = (Net and Net.Parent and Net) or ResolveNet()
    return Net
end

local FarmsPage: any = Window:Tab({Name = "Farms", Icon = "credit-card"})
local CardSwipeSubPage: any = FarmsPage:SubTab({Name = "Auto Farms", Icon = "credit-card"})

function Notify(Title, Text, Time)
    pcall(function()
        Solstices:Notification({Name = tostring(Title or "Solstices"), Description = tostring(Text or ""), Icon = "info", Duration = tonumber(Time) or 3})
    end)
end

function SetLiveLabel(LabelObject, NewText)
    if not LabelObject then return false end
    NewText = tostring(NewText or "")

    if type(ForceLabelText) == "function" and ForceLabelText(LabelObject, NewText) then
        return true
    end

    local Methods = {"Overwrite", "Set", "SetText", "Update", "Refresh", "ChangeText"}
    for _, MethodName in ipairs(Methods) do
        local Method
        pcall(function() Method = LabelObject[MethodName] end)
        if type(Method) == "function" then
            local OK
            if MethodName == "Overwrite" then
                OK = pcall(Method, LabelObject, {Name = NewText, Text = NewText, Value = NewText})
            else
                OK = pcall(Method, LabelObject, NewText)
            end
            if OK then return true end
        end
    end

    if typeof(LabelObject) == "Instance"
        and (LabelObject:IsA("TextLabel") or LabelObject:IsA("TextButton")) then
        LabelObject.Text = NewText
        return true
    end

    return false
end

pcall(function()
    Window:Watermark({Name = "Solstices.gg"})
end)

Notify("Solstices.gg", "Card Farm loaded.", 3)
local GunShopRemote = nil

TravelBusy = false
GoToSpotEnabled = false
CollisionState = {}

function ForceSolidPlatform()
    if SolidPlatform and SolidPlatform.Parent then
        SolidPlatform:Destroy()
    end
    SolidPlatform = nil
    return nil
end

function GetCharacter()
    local Character = LocalPlayer.Character
    if not Character or not Character.Parent then
        Character = LocalPlayer.CharacterAdded:Wait()
    end

    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local Root = Character:FindFirstChild("HumanoidRootPart")

    if not Humanoid or not Root then
        return nil
    end

    return Character, Humanoid, Root
end

function ZeroVelocity(Object)
    if not Object then return end

    if Object:IsA("BasePart") then
        Object.AssemblyLinearVelocity = Vector3.zero
        Object.AssemblyAngularVelocity = Vector3.zero
        return
    end

    for _, Part in ipairs(Object:GetDescendants()) do
        if Part:IsA("BasePart") then
            Part.AssemblyLinearVelocity = Vector3.zero
            Part.AssemblyAngularVelocity = Vector3.zero
        end
    end
end

function GetFloorY(Position, IgnoreObjects)
    local Params = RaycastParams.new()
    Params.FilterType = Enum.RaycastFilterType.Exclude
    Params.IgnoreWater = true

    local Ignore = {}
    for _, Object in ipairs(IgnoreObjects or {}) do
        if Object then
            table.insert(Ignore, Object)
        end
    end

    Params.FilterDescendantsInstances = Ignore

    local Result = workspace:Raycast(
        Position + Vector3.new(0, 60, 0),
        Vector3.new(0, -150, 0),
        Params
    )

    return Result and Result.Position.Y or Position.Y
end

function IsBike(Vehicle)
    if not Vehicle then return false end

    local Value = Vehicle:FindFirstChild("IsBike")
    if Value and Value:IsA("BoolValue") and Value.Value then
        return true
    end

    return Vehicle:GetAttribute("IsBike") == true
end

function GetBikeSeat(Vehicle)
    local Seat = Vehicle and Vehicle:FindFirstChild("DriverSeat", true)
    if Seat and (Seat:IsA("VehicleSeat") or Seat:IsA("Seat")) then
        return Seat
    end
end

function RememberBike(Vehicle, Seat)
    if Vehicle and Vehicle.Parent and Seat and Seat.Parent then
        CurrentBike = Vehicle
        CurrentSeat = Seat
    end
end

function GetRememberedBike()
    if CurrentBike and CurrentBike.Parent and CurrentSeat and CurrentSeat.Parent then
        return CurrentBike, CurrentSeat
    end

    CurrentBike = nil
    CurrentSeat = nil
end

function GetBikeLists()
    local Cars = workspace:FindFirstChild("Cars")
    if not Cars then return {}, {} end

    local Character, Humanoid, Root = GetCharacter()
    if not Character then return {}, {} end

    local Empty = {}
    local Occupied = {}

    for _, Vehicle in ipairs(Cars:GetChildren()) do
        if IsBike(Vehicle) then
            local Seat = GetBikeSeat(Vehicle)

            if Seat then
                local Distance = (Root.Position - Seat.Position).Magnitude
                local Entry = {
                    Vehicle = Vehicle,
                    Seat = Seat,
                    Distance = Distance
                }

                if not Seat.Occupant or Seat.Occupant == Humanoid then
                    table.insert(Empty, Entry)
                else
                    table.insert(Occupied, Entry)
                end
            end
        end
    end

    table.sort(Empty, function(A, B)
        return A.Distance < B.Distance
    end)

    table.sort(Occupied, function(A, B)
        return A.Distance < B.Distance
    end)

    return Empty, Occupied
end

function FindEmptyBike()
    local Empty = GetBikeLists()
    if #Empty > 0 then
        return Empty[1].Vehicle, Empty[1].Seat
    end
end

function TriggerPrompt(Prompt)
    if not Prompt or not Prompt.Parent or not Prompt.Enabled then
        return false
    end

    return pcall(function()
        if fireproximityprompt then
            fireproximityprompt(Prompt)
        else
            Prompt:InputHoldBegin()
            task.wait(math.max(Prompt.HoldDuration, 0.05))
            Prompt:InputHoldEnd()
        end
    end)
end

function FindSurronSpawner()
    local purchases = workspace:FindFirstChild("Purchases")
    local surrons = purchases and purchases:FindFirstChild("Surrons")
    local _, _, root = GetCharacter()
    if not surrons or not root then return nil, nil end
    local bestPart, bestPrompt, bestDistance = nil, nil, math.huge
    for _, prompt in ipairs(surrons:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and prompt.Enabled then
            local main = prompt.Parent
            if not main:IsA("BasePart") then
                main = prompt:FindFirstAncestorWhichIsA("BasePart")
            end
            if main then
                local distance = (root.Position - main.Position).Magnitude
                if distance < bestDistance then
                    bestPart, bestPrompt, bestDistance = main, prompt, distance
                end
            end
        end
    end
    return bestPart, bestPrompt
end

function FindMyBike()
    local player = game:GetService("Players").LocalPlayer
    local cars = workspace:FindFirstChild("Cars")
    if not player or not cars then return nil, nil end
    
    local expected = player.Name .. "'s Bike"
    local bike = cars:FindFirstChild(expected)
    if not bike then
        for _, model in ipairs(cars:GetChildren()) do
            local owner = model:GetAttribute("Owner") or model:GetAttribute("OwnerName")
            if owner == player.Name or owner == player.UserId then
                if model:FindFirstChild("DriverSeat", true) then
                    bike = model
                    break
                end
            end
        end
    end
    local seat = bike and bike:FindFirstChild("DriverSeat", true)
    if seat and (seat:IsA("VehicleSeat") or seat:IsA("Seat")) then
        return bike, seat
    end
    return nil, nil
end

LastBikePurchaseAttempt = 0
BIKE_PURCHASE_COOLDOWN = 1.5

function GoToSurronShop()
    local main, prompt = FindSurronSpawner()
    if not main or not prompt then
        SetFarmStatus("BIKE | Surron purchase prompt not found")
        return false
    end
    local character, humanoid, root = GetCharacter()
    if not character or not root then return false end
    if humanoid and humanoid.Sit then return false end
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    character:PivotTo(main.CFrame * CFrame.new(0, main.Size.Y / 2 + 2.5, 0))
    task.wait(0.35)
    SetFarmStatus("BIKE | buying Surron")
    return TriggerPrompt(prompt)
end

function GetOrBuyBike()
    local bike, seat = FindMyBike()
    if bike and seat then return bike, seat end

    
    
    local tries = 0
    while MainFarmEnabled do
        bike, seat = FindMyBike()
        if bike and seat then return bike, seat end

        if os.clock() - LastBikePurchaseAttempt < BIKE_PURCHASE_COOLDOWN then
            task.wait(0.2)
        else
            LastBikePurchaseAttempt = os.clock()
            tries += 1
            SetFarmStatus("BIKE | purchase attempt " .. tries)
            GoToSurronShop()

            local deadline = os.clock() + 5
            while MainFarmEnabled and os.clock() < deadline do
                bike, seat = FindMyBike()
                if bike and seat then
                    SetFarmStatus("BIKE | purchased, getting on")
                    return bike, seat
                end
                task.wait(0.2)
            end
            task.wait(0.5)
        end
    end
    return nil, nil
end

function SitOnOwnedBike()
    local bike, seat = GetOrBuyBike()
    if not bike or not seat then
        SetFarmStatus("BIKE | waiting for owned bike")
        return nil, nil
    end
    local character, humanoid, root = GetCharacter()
    if not character or not humanoid or not root then return nil, nil end
    if seat.Occupant == humanoid then
        RememberBike(bike, seat)
        return bike, seat
    end
    if seat.Occupant and seat.Occupant ~= humanoid then
        SetFarmStatus("BIKE | seat occupied")
        return nil, nil
    end
    local prompt = seat:FindFirstChildOfClass("ProximityPrompt")
    local attempt = 0
    while MainFarmEnabled and seat.Parent and seat.Occupant ~= humanoid and not seat.Occupant do
        attempt += 1
        if attempt % 10 == 0 then SetFarmStatus("BIKE | seating retry " .. attempt) end
        if not MainFarmEnabled or not seat.Parent then break end
        if seat.Occupant == humanoid then break end
        if seat.Occupant and seat.Occupant ~= humanoid then break end

        humanoid.Sit = false
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        
        if character.PrimaryPart then
            character:SetPrimaryPartCFrame(seat.CFrame * CFrame.new(0, 3, 0))
        else
            character:MoveTo(seat.Position + Vector3.new(0, 4, 0))
        end
        task.wait(0.25)
        if prompt and prompt.Parent then
            pcall(function() TriggerPrompt(prompt) end)
        end
        pcall(function() seat:Sit(humanoid) end)
        local deadline = os.clock() + 0.8
        repeat
            if seat.Occupant == humanoid then break end
            task.wait(0.05)
        until os.clock() >= deadline
    end
    if seat.Occupant == humanoid then
        RememberBike(bike, seat)
        SetFarmStatus("BIKE | seated in " .. bike.Name)
        return bike, seat
    end
    SetFarmStatus("BIKE | DriverSeat did not accept sit")
    return nil, nil
end

local BikeTeleportBusy = false
function BikeTeleportTo(destination)
    if typeof(destination) ~= "Vector3" or BikeTeleportBusy then return false end
    local bike, seat = FindMyBike()
    local character, humanoid, root = GetCharacter()
    if not bike or not seat or not character or not humanoid or not root then return false end
    if seat.Occupant ~= humanoid then
        bike, seat = SitOnOwnedBike()
        if not bike or not seat or seat.Occupant ~= humanoid then return false end
    end
    if not bike:IsA("Model") then return false end
    BikeTeleportBusy = true
    local original = {}
    local collision = {}
    local targetPosition = destination + Vector3.new(0, 3.1, 0)
    local success = pcall(function()
        local pivot = bike:GetPivot()
        local seatOffset = pivot.Position - seat.Position
        local targetPivot = CFrame.new(targetPosition + seatOffset) * pivot.Rotation
        for _, part in ipairs(bike:GetDescendants()) do
            if part:IsA("BasePart") then
                original[part] = part.Anchored
                collision[part] = part.CanCollide
                part.AssemblyLinearVelocity = Vector3.zero
                part.AssemblyAngularVelocity = Vector3.zero
                part.Anchored = true
                part.CanCollide = false
            end
        end
        bike:PivotTo(targetPivot)
        task.wait(0.35)
        for part in pairs(original) do
            if part.Parent then
                part.AssemblyLinearVelocity = Vector3.zero
                part.AssemblyAngularVelocity = Vector3.zero
            end
        end
    end)
    for part, anchored in pairs(original) do
        if part.Parent then
            part.Anchored = anchored
            part.CanCollide = collision[part]
        end
    end
    BikeTeleportBusy = false
    if not success then return false end
    if seat.Occupant ~= humanoid then
        SetFarmStatus("BIKE | seat lost during teleport")
        return false
    end
    RememberBike(bike, seat)
    return (seat.Position - targetPosition).Magnitude < 12
end

function SitOnBike(Vehicle, Seat)
    if not Vehicle or not Seat then return false end
    local bike, actualSeat = SitOnOwnedBike()
    return bike == Vehicle and actualSeat == Seat
end

function SetNoClip(Vehicle, Character, Enabled)
    if Enabled then
        local function Disable(Part)
            if not Part:IsA("BasePart") then return end

            if CollisionState[Part] == nil then
                CollisionState[Part] = Part.CanCollide
            end

            Part.CanCollide = false
        end

        if Vehicle then
            if Vehicle:IsA("BasePart") then
                Disable(Vehicle)
            else
                for _, Part in ipairs(Vehicle:GetDescendants()) do
                    Disable(Part)
                end
            end
        end

        if Character then
            for _, Part in ipairs(Character:GetDescendants()) do
                Disable(Part)
            end
        end
    else
        for Part, Original in pairs(CollisionState) do
            if Part and Part.Parent then
                Part.CanCollide = Original
            end
        end

        table.clear(CollisionState)
    end
end

function GetVehicleCFrame(Vehicle, Seat)
    if Vehicle:IsA("Model") then
        return Vehicle:GetPivot()
    elseif Vehicle:IsA("BasePart") then
        return Vehicle.CFrame
    end

    return Seat.CFrame
end

function SetVehicleCFrame(Vehicle, Seat, CF)
    ZeroVelocity(Vehicle)

    local OK = pcall(function()
        if Vehicle:IsA("Model") then
            Vehicle:PivotTo(CF)
        elseif Vehicle:IsA("BasePart") then
            Vehicle.CFrame = CF
        else
            Seat.CFrame = CF
        end
    end)

    ZeroVelocity(Vehicle)
    return OK
end

function TweenBikeToSpot(Vehicle, Seat, Humanoid, Destination)
    return BikeTeleportTo(Destination)
end

function HoldBikeAtDestination(Vehicle, Seat, Humanoid, HoldSeconds)
    if not Vehicle or not Vehicle.Parent or not Seat or not Seat.Parent then
        return false
    end

    local Character = Humanoid and Humanoid.Parent
    if not Character or Seat.Occupant ~= Humanoid then
        return false
    end

    ForceSolidPlatform()

    local TargetPosition = Vector3.new(-1467, -22, -864)
    local CurrentCF = GetVehicleCFrame(Vehicle, Seat)
    local _, Yaw, _ = CurrentCF:ToOrientation()
    local TargetCF = CFrame.new(TargetPosition) * CFrame.Angles(0, Yaw, 0)

    local Started = os.clock()

    while GoToSpotEnabled and os.clock() - Started < (HoldSeconds or 4) do
        if not Vehicle.Parent or not Seat.Parent or Seat.Occupant ~= Humanoid then
            return false
        end

        ForceSolidPlatform()
        SetNoClip(Vehicle, Character, false)
        ZeroVelocity(Vehicle)
        SetVehicleCFrame(Vehicle, Seat, TargetCF)
        ZeroVelocity(Vehicle)

        task.wait(0.10)
    end

    ZeroVelocity(Vehicle)
    return Vehicle.Parent ~= nil and Seat.Parent ~= nil and Seat.Occupant == Humanoid
end

ReplicatedStorage = game:GetService("ReplicatedStorage")
Net = ReplicatedStorage.Modules.Packages._Index["sleitnick_net@0.2.0"].net

local function ResolveFarmRemote(Name)
    local CurrentNet = FindNet()
    if not CurrentNet then return nil end
    return CurrentNet:FindFirstChild(Name)
        or ReplicatedStorage:FindFirstChild(Name, true)
end

TechStore = ResolveFarmRemote("RE/TechStore")
Convenience = ResolveFarmRemote("RE/Convenience")
Leaked = ResolveFarmRemote("RE/Leaked")
Swiping = ResolveFarmRemote("RE/Swiping")

AutoCardEnabled = false
AutoCardBusy = false

NEAR_PLATFORM_DISTANCE = 140
NEAR_PLATFORM_TWEEN_SPEED = 12

function BuyLaptop()
    local remote = ResolveFarmRemote("RE/TechStore")
    if not remote or not remote:IsA("RemoteEvent") then
        SetFarmStatus("LAPTOP BUY ERROR | TechStore remote missing")
        return false
    end
    local ok = pcall(function()
        remote:FireServer("Purchase", {
            name = "Laptop",
            category = "Tools"
        })
    end)
    if ok then Notify("Purchase", "Laptop purchase requested", 2) end
    return ok
end

function BuyCardReader()
    local remote = ResolveFarmRemote("RE/Convenience")
    if not remote or not remote:IsA("RemoteEvent") then return false end
    local ok = pcall(function()
        remote:FireServer("PurchasePablo", {name = "Card Reader", category = "Items"})
    end)
    return ok
end

function BuyBlankCard()
    Convenience:FireServer("PurchasePablo", {
        name = "Blank Card",
        category = "Items"
    })
    Notify("Purchase", "Buying Blank Card", 2)
end

function FindExactTool(Name)
    local Character = LocalPlayer.Character
    local Backpack = LocalPlayer:FindFirstChild("Backpack")

    local function Search(Container)
        if not Container then return nil end

        for _, Object in ipairs(Container:GetChildren()) do
            if Object:IsA("Tool") and string.lower(Object.Name) == string.lower(Name) then
                return Object
            end
        end
    end

    return Search(Character) or Search(Backpack)
end

function HasUSB()
    local Character = LocalPlayer.Character
    local Backpack = LocalPlayer:FindFirstChild("Backpack")

    local function Search(Container)
        if not Container then return nil end

        for _, Object in ipairs(Container:GetChildren()) do
            if Object:IsA("Tool") and string.find(string.lower(Object.Name), "usb", 1, true) then
                return Object
            end
        end
    end

    return Search(Character) or Search(Backpack)
end

function FindCheapestUSBContact()
    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
    local Phone = PlayerGui and PlayerGui:FindFirstChild("Phone")
    local Mainframe = Phone and Phone:FindFirstChild("Mainframe")
    local Main = Mainframe and Mainframe:FindFirstChild("Main")
    local Phone2 = Main and Main:FindFirstChild("Phone")
    local Holder = Phone2 and Phone2:FindFirstChild("PhoneHolder")
    local LeakedFolder = Holder and Holder:FindFirstChild("Leaked")
    local Contacts = LeakedFolder and LeakedFolder:FindFirstChild("Contacts")

    if not Contacts then
        return nil
    end

    local Cheapest

    for _, Frame in ipairs(Contacts:GetChildren()) do
        if Frame:IsA("Frame") then
            local Number = tonumber(Frame.Name)

            if Number and Number >= 40 then
                if not Cheapest or Number < Cheapest.Number then
                    Cheapest = {
                        Number = Number,
                        Name = tostring(Frame.Name)
                    }
                end
            end
        end
    end

    return Cheapest
end

function NormalizeRiskText(Text)
    local S = string.lower(tostring(Text or ""))
    if string.find(S, "high", 1, true) then return "High" end
    if string.find(S, "medium", 1, true) then return "Medium" end
    if string.find(S, "low", 1, true) then return "Low" end
    return nil
end

function GetRiskFromObject(Object)
    if not Object then return nil end

    if Object:IsA("TextLabel") or Object:IsA("TextButton") then
        return NormalizeRiskText(Object.Text)
    end

    local Risk = Object:FindFirstChild("Risk", true)
    if Risk and (Risk:IsA("TextLabel") or Risk:IsA("TextButton")) then
        return NormalizeRiskText(Risk.Text)
    end

    for _, Desc in ipairs(Object:GetDescendants()) do
        if (Desc:IsA("TextLabel") or Desc:IsA("TextButton"))
            and string.lower(Desc.Name) == "risk" then
            local Found = NormalizeRiskText(Desc.Text)
            if Found then return Found end
        end
    end
end

function GetUSBContactRisk(Frame)

    local Direct = GetRiskFromObject(Frame)
    if Direct then return Direct end

    if getnilinstances then
        local Counts = {Low=0, Medium=0, High=0}
        pcall(function()
            for _, V in ipairs(getnilinstances()) do
                if V.ClassName == "TextLabel" and V.Name == "Risk" then
                    local R = NormalizeRiskText(V.Text)
                    if R then Counts[R] += 1 end
                end
            end
        end)

        local Only
        for Name, Count in pairs(Counts) do
            if Count > 0 then
                if Only then return nil end
                Only = Name
            end
        end
        return Only
    end
end

function RiskPriority(Target)
    Target = tostring(Target or "High")
    if Target == "High" then
        return {"High","Medium","Low"}
    elseif Target == "Medium" then
        return {"Medium","Low"}
    else
        return {"Low"}
    end
end

function GetUSBContactsCheapestFirst()
    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
    local Phone = PlayerGui and PlayerGui:FindFirstChild("Phone")
    local Mainframe = Phone and Phone:FindFirstChild("Mainframe")
    local Main = Mainframe and Mainframe:FindFirstChild("Main")
    local Phone2 = Main and Main:FindFirstChild("Phone")
    local Holder = Phone2 and Phone2:FindFirstChild("PhoneHolder")
    local LeakedFolder = Holder and Holder:FindFirstChild("Leaked")
    local Contacts = LeakedFolder and LeakedFolder:FindFirstChild("Contacts")

    if not Contacts then
        LastRiskStatus = "Contacts Missing"
        return {}
    end

    local All = {}

    for _, Frame in ipairs(Contacts:GetChildren()) do
        if Frame:IsA("Frame") then
            local Number = tonumber(Frame.Name)

            if Number and Number >= 40 then
                table.insert(All, {
                    Number = Number,
                    Name = tostring(Frame.Name),
                    Risk = GetUSBContactRisk(Frame)
                })
            end
        end
    end

    table.sort(All, function(A, B)
        return A.Number < B.Number
    end)

    if #All == 0 then
        LastRiskStatus = "No Contacts"
        return {}
    end

    for _, Wanted in ipairs(RiskPriority(USB_RISK_TARGET)) do
        local Matches = {}

        for _, Contact in ipairs(All) do
            if Contact.Risk == Wanted then
                table.insert(Matches, Contact)
            end
        end

        if #Matches > 0 then
            LastRiskStatus = Wanted
            return Matches
        end
    end

    LastRiskStatus = "Fallback"
    return All
end

function BuyCheapestUSB()

    if MainFarmEnabled then
        return true
    end

    if HasUSB() then
        Notify("USB", "USB already in inventory. Skipping purchase.", 2)
        return true
    end

    local Contact = FindCheapestUSBContact()

    if not Contact then
        Notify("USB", "No USB contact found.", 4)
        return false
    end

    local BuyRemote = Leaked or ResolveFarmRemote("RE/Leaked")
    if not BuyRemote or not BuyRemote:IsA("RemoteEvent") then
        Notify("USB", "USB purchase remote unavailable.", 4)
        return false
    end

    Leaked = BuyRemote
    BuyRemote:FireServer("Buy", Contact.Name)
    Notify("USB", "Buying cheapest USB: " .. Contact.Name, 3)
    return true
end

function FindOwnedHouse()
    local Apartments = workspace:FindFirstChild("Apartments")
    local Houses = Apartments and Apartments:FindFirstChild("Houses")

    if not Houses then
        return nil
    end

    for _, House in ipairs(Houses:GetChildren()) do
        if House:IsA("Model") then
            local Owner = House:GetAttribute("Owner")

            if Owner and tostring(Owner) == LocalPlayer.Name then
                return House
            end
        end
    end

    return nil
end

function FindHouseDeliveryPrompt()
    local House = FindOwnedHouse()
    if not House then return nil end

    local Delivery = House:FindFirstChild("DeliveryPrompt", true)
    if not Delivery then return nil end

    if Delivery:IsA("ProximityPrompt") then
        return Delivery
    end

    return Delivery:FindFirstChildWhichIsA("ProximityPrompt", true)
end

function MoveCharacterToPrompt(Prompt)
    if not Prompt or not Prompt.Parent then return false end

    local Character, Humanoid, Root = GetCharacter()
    if not Character then return false end

    local Parent = Prompt.Parent
    local CF

    if Parent:IsA("BasePart") then
        CF = Parent.CFrame
    elseif Parent:IsA("Attachment") and Parent.Parent and Parent.Parent:IsA("BasePart") then
        CF = Parent.Parent.CFrame
    elseif Parent:IsA("Model") then
        CF = Parent:GetPivot()
    end

    if not CF then return false end

    Root.AssemblyLinearVelocity = Vector3.zero
    Root.AssemblyAngularVelocity = Vector3.zero
    TweenRootCFrame(CF * CFrame.new(0, 3, 0))
    task.wait(0.35)

    return true
end

function CollectUSB()
    local Prompt = FindHouseDeliveryPrompt()

    if not Prompt then
        Notify("USB", "No owned-house delivery prompt found.", 4)
        return false
    end

    MoveCharacterToPrompt(Prompt)
    task.wait(0.25)

    local OK = TriggerPrompt(Prompt)

    if OK then
        Notify("USB", "Collecting USB from house.", 2)
    end

    return OK
end

function FindToolContaining(Text)
    Text = string.lower(Text)

    local Character = LocalPlayer.Character
    local Backpack = LocalPlayer:FindFirstChild("Backpack")

    local function Search(Container)
        if not Container then return nil end

        for _, Object in ipairs(Container:GetChildren()) do
            if Object:IsA("Tool") and string.find(string.lower(Object.Name), Text, 1, true) then
                return Object
            end
        end
    end

    return Search(Character) or Search(Backpack)
end

function EquipTool(Tool)
    if not Tool then return false end

    local Character, Humanoid = GetCharacter()
    if not Character then return false end

    Humanoid:UnequipTools()
    task.wait(0.1)
    Humanoid:EquipTool(Tool)
    task.wait(0.2)

    return Tool.Parent == Character
end

AutoMaskedEnabled = false
AutoMaskedBusy = false
AutoMaskedDone = false

function EnsureAutoMasked()
    if not AutoMaskedEnabled or AutoMaskedDone or AutoMaskedBusy then
        return true
    end

    if type(FindExactTool) == "function" and FindExactTool("Nike Pro Ski") then
        AutoMaskedDone = true
        Notify("Auto Masked", "Nike Pro Ski already owned; skipping purchase.", 3)
        return true
    end

    AutoMaskedBusy = true
    local Success = false

    local OK, Error = pcall(function()
        local Character, _, Root = GetCharacter()
        if not Character or not Root then
            Notify("Auto Masked", "Character unavailable.", 4)
            return
        end

        local ReturnCF = Root.CFrame
        if type(release) == "function" then
            pcall(release)
        end

        TweenRootCFrame(CFrame.new(-1070, 5, 160))
        Root.AssemblyLinearVelocity = Vector3.zero
        Root.AssemblyAngularVelocity = Vector3.zero

        local Prompt
        local Started = os.clock()
        repeat
            local Purchases = workspace:FindFirstChild("Purchases")
            local Masks = Purchases and Purchases:FindFirstChild("Masks")
            local Mask = Masks and Masks:FindFirstChild("Nike Pro Ski")
            local Handle = Mask and Mask:FindFirstChild("Handle")
            Prompt = Handle and Handle:FindFirstChild("ProximityPrompt")
            if not Prompt and Handle then
                Prompt = Handle:FindFirstChildWhichIsA("ProximityPrompt", true)
            end
            if Prompt then break end
            task.wait(0.2)
        until os.clock() - Started >= 5

        if not Prompt then
            TweenRootCFrame(ReturnCF)
            Notify("Auto Masked", "Nike Pro Ski prompt unavailable at shop.", 4)
            return
        end

        if not TriggerPrompt(Prompt) then
            TweenRootCFrame(ReturnCF)
            Notify("Auto Masked", "Could not trigger Nike Pro Ski prompt.", 4)
            return
        end

        Started = os.clock()
        local Tool
        repeat
            task.wait(0.2)
            Tool = FindExactTool("Nike Pro Ski")
        until Tool or os.clock() - Started >= 5

        if not Tool or not EquipTool(Tool) then
            TweenRootCFrame(ReturnCF)
            Notify("Auto Masked", "Nike Pro Ski tool was not equipped.", 4)
            return
        end

        local Camera = workspace.CurrentCamera
        local Viewport = Camera and Camera.ViewportSize or Vector2.new(400, 300)
        local VIM = game:GetService("VirtualInputManager")
        VIM:SendMouseButtonEvent(Viewport.X * 0.5, Viewport.Y * 0.5, 0, true, game, 0)
        VIM:SendMouseButtonEvent(Viewport.X * 0.5, Viewport.Y * 0.5, 0, false, game, 0)
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        if Humanoid then
            Humanoid:UnequipTools()
            task.wait(0.1)
        end
        TweenRootCFrame(ReturnCF)
        Root.AssemblyLinearVelocity = Vector3.zero
        Root.AssemblyAngularVelocity = Vector3.zero
        AutoMaskedDone = true
        Success = true
        Notify("Auto Masked", "Nike Pro Ski equipped.", 3)
    end)

    AutoMaskedBusy = false
    if not OK then
        Notify("Auto Masked", tostring(Error), 4)
    end
    return Success
end

function GetOwnedLaptopModel()
    local Placements = workspace:FindFirstChild("Placements")
    local Server = Placements and Placements:FindFirstChild("Server")

    if not Server then
        return nil
    end

    local DirectLaptop = Server:FindFirstChild("Laptop")

    if DirectLaptop and DirectLaptop:IsA("Model") then
        local Owner = DirectLaptop:GetAttribute("Owner")

        if not Owner or tostring(Owner) == LocalPlayer.Name then
            return DirectLaptop
        end
    end

    for _, Model in ipairs(Server:GetChildren()) do
        if Model:IsA("Model") and string.lower(Model.Name) == "laptop" then
            local Owner = Model:GetAttribute("Owner")

            if Owner and tostring(Owner) == LocalPlayer.Name then
                return Model
            end
        end
    end

    return nil
end

function CompleteOwnedLaptopSwipe()
    local Laptop = GetOwnedLaptopModel()

    if not Laptop then
        Notify("Auto Complete", "Owned laptop model not found.", 4)
        return false
    end

    local OK, Error = pcall(function()
        Swiping:FireServer("Completed", Laptop)
    end)

    if not OK then
        Notify("Auto Complete", tostring(Error), 4)
        return false
    end

    Notify("Auto Complete", "Completed owned laptop.", 3)
    return true
end

function GetOwnedLaptopPrompt()
    local Laptop = GetOwnedLaptopModel()

    if not Laptop then
        return nil
    end

    local Prompt = Laptop:FindFirstChildWhichIsA("ProximityPrompt", true)

    if Prompt then
        return Prompt, Laptop
    end

    local Handle = Laptop:FindFirstChild("Handle", true)

    if Handle then
        Prompt = Handle:FindFirstChildWhichIsA("ProximityPrompt", true)

        if Prompt then
            return Prompt, Laptop
        end
    end

    return nil, Laptop
end

function UseUSBOnLaptop()
    local USB = HasUSB()

    if not USB then
        Notify("USB", "No USB in inventory.", 4)
        return false
    end

    local Prompt, Laptop = GetOwnedLaptopPrompt()

    if not Prompt or not Laptop then
        Notify("Laptop", "Owned laptop prompt not found.", 4)
        return false
    end

    if not EquipTool(USB) then
        Notify("USB", "Could not equip USB.", 4)
        return false
    end

    MoveCharacterToPrompt(Prompt)
    task.wait(0.35)

    if USB.Parent ~= LocalPlayer.Character then
        if not EquipTool(USB) then
            return false
        end
    end

    local OK = TriggerPrompt(Prompt)

    if not OK then
        Notify("Laptop", "Laptop USB prompt failed.", 4)
        return false
    end

    Notify("Laptop", "USB used on owned laptop.", 3)
    task.wait(0.75)

    return true
end

function FindDump()
    return FindToolContaining("dump")
end

function CollectDump()
    local Prompt = GetOwnedLaptopPrompt()

    if not Prompt then
        return false
    end

    MoveCharacterToPrompt(Prompt)
    task.wait(0.25)
    TriggerPrompt(Prompt)
    task.wait(0.5)

    return FindDump() ~= nil
end

function WaitForLaptopReady(MaxWait)
    local Started = os.clock()
    MaxWait = MaxWait or 300

    Notify("Laptop", "Waiting for laptop timer...", 3)

    while AutoCardEnabled and os.clock() - Started < MaxWait do
        local Prompt = GetOwnedLaptopPrompt()

        if Prompt then
            local Action = string.lower(tostring(Prompt.ActionText or ""))
            local ObjectText = string.lower(tostring(Prompt.ObjectText or ""))

            if string.find(Action, "card", 1, true)
                or string.find(Action, "swipe", 1, true)
                or string.find(Action, "dump", 1, true)
                or string.find(Action, "ready", 1, true)
                or string.find(ObjectText, "card", 1, true)
                or string.find(ObjectText, "ready", 1, true)
                or string.find(ObjectText, "dump", 1, true) then
                return true
            end
        end

        task.wait(1)
    end

    return false
end

function UseBlankCardOnLaptop()
    local BlankCard = FindExactTool("Blank Card")

    if not BlankCard then
        Notify("Blank Card", "No Blank Card in inventory.", 4)
        return false
    end

    local Prompt, Laptop = GetOwnedLaptopPrompt()

    if not Prompt or not Laptop then
        Notify("Laptop", "Owned laptop prompt not found.", 4)
        return false
    end

    if not EquipTool(BlankCard) then
        Notify("Blank Card", "Could not equip Blank Card.", 4)
        return false
    end

    MoveCharacterToPrompt(Prompt)
    task.wait(0.35)

    if BlankCard.Parent ~= LocalPlayer.Character then
        if not EquipTool(BlankCard) then
            return false
        end
    end

    if not TriggerPrompt(Prompt) then
        Notify("Blank Card", "Laptop card prompt failed.", 4)
        return false
    end

    Notify("Blank Card", "Dumping laptop to Blank Card.", 3)
    task.wait(0.75)

    if not CompleteOwnedLaptopSwipe() then
        return false
    end

    task.wait(1)
    return true
end

function WaitForLoadedDump(MaxWait)
    local Started = os.clock()
    MaxWait = MaxWait or 120

    while AutoCardEnabled and os.clock() - Started < MaxWait do
        if FindDump() then
            return true
        end

        local Prompt = GetOwnedLaptopPrompt()

        if Prompt and Prompt.Enabled then
            local Action = string.lower(tostring(Prompt.ActionText or ""))

            if string.find(Action, "collect", 1, true)
                or string.find(Action, "take", 1, true)
                or string.find(Action, "dump", 1, true) then
                CollectDump()
                task.wait(0.5)

                if FindDump() then
                    return true
                end
            end
        end

        task.wait(1)
    end

    return FindDump() ~= nil
end

function FindNearestATM()
    local ATMS = workspace:FindFirstChild("ATMS")
    if not ATMS then return nil end

    local Character, _, Root = GetCharacter()
    if not Character or not Root then return nil end

    local BestPrompt = nil
    local BestDistance = math.huge

    for _, ATM in ipairs(ATMS:GetChildren()) do
        local Numpad = ATM:FindFirstChild("Numpad", true)
        local Prompt = Numpad and Numpad:FindFirstChild("DumpPrompt", true)

        if Prompt and Prompt:IsA("ProximityPrompt") then
            local Part

            if Prompt.Parent:IsA("BasePart") then
                Part = Prompt.Parent
            elseif Prompt.Parent:IsA("Attachment")
                and Prompt.Parent.Parent
                and Prompt.Parent.Parent:IsA("BasePart") then
                Part = Prompt.Parent.Parent
            end

            if Part then
                local Distance = (Root.Position - Part.Position).Magnitude

                if Distance < BestDistance then
                    BestDistance = Distance
                    BestPrompt = Prompt
                end
            end
        end
    end

    if not BestPrompt then
        for _, Prompt in ipairs(ATMS:GetDescendants()) do
            if Prompt:IsA("ProximityPrompt")
                and string.lower(tostring(Prompt.Name)) == "dumpprompt" then

                local Part

                if Prompt.Parent:IsA("BasePart") then
                    Part = Prompt.Parent
                elseif Prompt.Parent:IsA("Attachment")
                    and Prompt.Parent.Parent
                    and Prompt.Parent.Parent:IsA("BasePart") then
                    Part = Prompt.Parent.Parent
                end

                if Part then
                    local Distance = (Root.Position - Part.Position).Magnitude

                    if Distance < BestDistance then
                        BestDistance = Distance
                        BestPrompt = Prompt
                    end
                end
            end
        end
    end

    return BestPrompt
end

function SlowTweenToPrompt(Prompt, Speed)
    if not Prompt or not Prompt.Parent then
        return false
    end

    local Character, Humanoid, Root = GetCharacter()
    if not Character then
        return false
    end

    local Parent = Prompt.Parent
    local TargetCF

    if Parent:IsA("BasePart") then
        TargetCF = Parent.CFrame * CFrame.new(0, 3, 0)
    elseif Parent:IsA("Attachment") and Parent.Parent and Parent.Parent:IsA("BasePart") then
        TargetCF = Parent.Parent.CFrame * CFrame.new(0, 3, 0)
    elseif Parent:IsA("Model") then
        TargetCF = Parent:GetPivot() * CFrame.new(0, 3, 0)
    end

    if not TargetCF then
        return false
    end

    local Start = Root.Position
    local Target = TargetCF.Position
    local Distance = (Target - Start).Magnitude

    Speed = Speed or 12

    if Distance <= 2 then
        TweenRootCFrame(TargetCF)
        return true
    end

    local Duration = math.max(Distance / Speed, 0.1)
    local Steps = math.max(1, math.ceil(Duration / 0.05))

    for Step = 1, Steps do

        if MainFarmEnabled == false and AutoCardEnabled == false then

        end

        local Alpha = Step / Steps
        local Position = Start:Lerp(Target, Alpha)

        Root.AssemblyLinearVelocity = Vector3.zero
        Root.AssemblyAngularVelocity = Vector3.zero
        TweenRootCFrame(CFrame.new(Position))

        task.wait(0.05)
    end

    Root.AssemblyLinearVelocity = Vector3.zero
    Root.AssemblyAngularVelocity = Vector3.zero
    TweenRootCFrame(TargetCF)

    return true
end

function SellDump()
    local Dump = FindDump()

    if not Dump then
        Notify("ATM", "No loaded dump tool found.", 4)
        return false
    end

    local Prompt = FindNearestATM()

    if not Prompt then
        Notify("ATM", "No ATM dump prompt found.", 4)
        return false
    end

    Notify("ATM", "Tweening to ATM...", 3)

    if not SlowTweenToPrompt(Prompt, 12) then
        Notify("ATM", "Could not reach ATM.", 4)
        return false
    end

    if not EquipTool(Dump) then
        Notify("ATM", "Could not equip dump.", 4)
        return false
    end

    task.wait(0.35)

    if not TriggerPrompt(Prompt) then
        Notify("ATM", "ATM sell prompt failed.", 4)
        return false
    end

    Notify("ATM", "Selling loaded dump.", 3)
    task.wait(0.75)

    return true
end

TravelFloor = nil

GetTravelFloor = function()
    return nil
end

RemoveTravelFloor = function()
    if TravelFloor then
        pcall(function() TravelFloor:Destroy() end)
        TravelFloor = nil
    end
end

function SlowTweenCharacterToPlatform()
    local House = GetMyHouse and GetMyHouse() or FindOwnedHouse()
    if not House then return false end
    local Position = GetOwnedHouseTopPosition and GetOwnedHouseTopPosition(House) or ObjectPosition(GetHouseTop(House))
    if not Position then return false end
    return FarmMoveTo(Position, 26)
end

function GetMyOwnBikeOnly()
    local Character, Humanoid = GetCharacter()
    if not Character then return nil, nil end

    if RememberedBike and RememberedBike.Parent
        and RememberedBikeSeat and RememberedBikeSeat.Parent
        and RememberedBikeSeat.Occupant == Humanoid then
        return RememberedBike, RememberedBikeSeat
    end

    for _, Desc in ipairs(workspace:GetDescendants()) do
        if Desc:IsA("VehicleSeat") and Desc.Occupant == Humanoid then
            local Model = Desc:FindFirstAncestorOfClass("Model")
            if Model then
                return Model, Desc
            end
        end
    end

    return nil, nil
end

function GoToUndergroundSpot()
    ForceSolidPlatform()

    local Character, Humanoid, Root = GetCharacter()
    if not Character then return false end

    if Humanoid.Sit then
        if not (FindMyBike() and select(2, FindMyBike()) and select(2, FindMyBike()).Occupant == Humanoid) then
            Humanoid.Sit = false
        end
        task.wait(0.35)
    end

    return SlowTweenCharacterToPlatform()
end

function ReturnToUndergroundSpot()
    ForceSolidPlatform()

    local Character, _, Root = GetCharacter()
    if not Character then return false end

    Root.AssemblyLinearVelocity = Vector3.zero
    Root.AssemblyAngularVelocity = Vector3.zero
    local Spot = RefreshDynamicFarmSpot()
    if not Spot then return false end
    TweenRootCFrame(CFrame.new(Spot))

    return true
end

function AutoCardCycle()
    if AutoCardBusy then return end
    AutoCardBusy = true

    local function Stop()
        AutoCardBusy = false
    end

    local function StillOn()
        return AutoCardEnabled == true
    end

    Notify("Auto Card", "Starting cycle.", 2)

    if not GoToUndergroundSpot() or not StillOn() then
        Stop()
        return
    end

    task.wait(0.5)

    if not HasUSB() then
        if not BuyCheapestUSB() or not StillOn() then
            Stop()
            return
        end

        task.wait(2)

        if not CollectUSB() or not StillOn() then
            Stop()
            return
        end

        task.wait(0.75)
        ReturnToUndergroundSpot()
        task.wait(0.5)
    else
        Notify("USB", "Using USB already in inventory.", 2)
    end

    if not UseUSBOnLaptop() or not StillOn() then
        Stop()
        return
    end

    if not WaitForLaptopReady(300) or not StillOn() then
        Notify("Laptop", "Laptop timer did not finish.", 4)
        Stop()
        return
    end

    if not UseBlankCardOnLaptop() or not StillOn() then
        Stop()
        return
    end

    if not WaitForLoadedDump(120) or not StillOn() then
        Notify("Auto Card", "Loaded dump was not found.", 4)
        Stop()
        return
    end

    if not SellDump() then
        Notify("Auto Card", "Could not sell dump.", 4)
        Stop()
        return
    end

    Notify("Auto Card", "Cycle complete.", 3)
    Stop()
end

function GetAllDumpTools()
    local Results = {}
    local Seen = {}

    local function IsLoadedDumpTool(Tool)
        if not Tool or not Tool:IsA("Tool") then
            return false
        end

        local Name = string.lower(tostring(Tool.Name or ""))

        return string.find(Name, "dump", 1, true) ~= nil
            and string.find(Name, "loaded", 1, true) ~= nil
    end

    local function Scan(Container)
        if not Container then return end

        for _, Tool in ipairs(Container:GetChildren()) do
            if IsLoadedDumpTool(Tool) and not Seen[Tool] then
                Seen[Tool] = true
                table.insert(Results, Tool)
            end
        end
    end

    Scan(LocalPlayer.Character)
    Scan(LocalPlayer:FindFirstChild("Backpack"))

    return Results
end

TweenService = game:GetService("TweenService")

function FindDirtyCashConvertPrompt()
    local BestPrompt = nil
    local BestScore = -1
    local Character = LocalPlayer.Character
    local Root = Character and Character:FindFirstChild("HumanoidRootPart")

    for _, Object in ipairs(workspace:GetDescendants()) do
        if Object:IsA("ProximityPrompt") and Object.Enabled ~= false then
            local Name = string.lower(tostring(Object.Name or ""))
            local Action = string.lower(tostring(Object.ActionText or ""))
            local ObjectText = string.lower(tostring(Object.ObjectText or ""))
            local Combined = Name .. " " .. Action .. " " .. ObjectText
            local Score = 0

            if string.find(Combined, "dirty", 1, true) then Score += 8 end
            if string.find(Combined, "convert", 1, true) then Score += 10 end
            if string.find(Combined, "clean", 1, true) then Score += 9 end
            if string.find(Combined, "launder", 1, true) then Score += 10 end
            if string.find(Combined, "wash", 1, true) then Score += 5 end
            if string.find(Combined, "cash", 1, true) then Score += 4 end

            if Score > BestScore and Score >= 9 then
                BestScore = Score
                BestPrompt = Object
            elseif Score == BestScore and Score >= 9 and Root and BestPrompt then
                local A = Object.Parent
                local B = BestPrompt.Parent
                if A and A:IsA("BasePart") and B and B:IsA("BasePart") then
                    if (Root.Position - A.Position).Magnitude < (Root.Position - B.Position).Magnitude then
                        BestPrompt = Object
                    end
                end
            end
        end
    end

    return BestPrompt
end

function AutoConvertDirtyCashAfterSell()
    if DontCleanDirtyMoney then
        SetFarmStatus("DIRTY CASH: keeping dirty money")
        return true
    end

    local DirtyBefore = GetCurrentDirtyCash() or 0
    RefreshSwipeStats()

    if DirtyBefore <= 0 then
        SetFarmStatus("DIRTY CASH: $0 | nothing to convert")
        return true
    end

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Packages = ReplicatedStorage:FindFirstChild("Modules")
    Packages = Packages and Packages:FindFirstChild("Packages")
    local Index = Packages and Packages:FindFirstChild("_Index")
    local NetPackage = Index and Index:FindFirstChild("sleitnick_net@0.2.0")
    local Net = NetPackage and NetPackage:FindFirstChild("net")
    local Event = Net and Net:FindFirstChild("RE/SellDirtyCash")

    if not Event then
        SetFarmStatus("DIRTY CASH " .. FormatMoney(DirtyBefore) .. " | SELL REMOTE NOT FOUND")
        return false
    end

    SetFarmStatus("AUTO CONVERT DIRTY CASH | " .. FormatMoney(DirtyBefore))

    local Fired = pcall(function()
        Event:FireServer(DirtyBefore)
    end)

    if not Fired then
        SetFarmStatus("DIRTY CASH CONVERT FAILED | " .. FormatMoney(DirtyBefore))
        return false
    end

    local Started = os.clock()
    local DirtyAfter = DirtyBefore
    repeat
        task.wait(0.15)
        DirtyAfter = GetCurrentDirtyCash() or 0
        RefreshSwipeStats()
        if DirtyAfter < DirtyBefore then
            break
        end
    until os.clock() - Started >= 3

    if DirtyAfter < DirtyBefore then
        SetFarmStatus("CONVERT DONE | " .. FormatMoney(DirtyBefore - DirtyAfter) .. " CONVERTED | DIRTY LEFT " .. FormatMoney(DirtyAfter))
        return true
    end

    SetFarmStatus("CONVERT SENT | " .. FormatMoney(DirtyBefore) .. " | WAITING FOR DIRTY CASH UPDATE")
    return true
end

function SellAllLoadedDumps()
    local Dumps = GetAllDumpTools()

    if #Dumps == 0 then
        SetFarmStatus("No Loaded Dumps to sell")
        return true
    end

    local Character, Humanoid, Root = GetCharacter()
    if not Character or not Root then
        SetFarmStatus("SELL BLOCKED: character/root missing")
        return false
    end

    local ATMS = workspace:FindFirstChild("ATMS")

    if not ATMS then
        SetFarmStatus("SELL BLOCKED: ATMS folder missing")
        return false
    end

    local ATM = nil
    local Prompt = nil
    local BestDistance = math.huge

    for _, Candidate in ipairs(ATMS:GetChildren()) do
        local Numpad = Candidate:FindFirstChild("Numpad", true)
        local CandidatePrompt = Numpad
            and Numpad:FindFirstChild("DumpPrompt", true)

        if CandidatePrompt
            and CandidatePrompt:IsA("ProximityPrompt")
            and CandidatePrompt.Parent
            and CandidatePrompt.Parent:IsA("BasePart") then

            local Distance = (
                Root.Position - CandidatePrompt.Parent.Position
            ).Magnitude

            if Distance < BestDistance then
                BestDistance = Distance
                ATM = Candidate
                Prompt = CandidatePrompt
            end
        end
    end

    if not ATM or not Prompt then
        SetFarmStatus("SELL BLOCKED: no ATM DumpPrompt found")
        return false
    end

    local PromptPart = Prompt.Parent
    local PromptPosition = PromptPart.Position

    local Floor = nil
    local function Cleanup() end
    local function ReturnToHouseAfterSale()
        local House = GetMyHouse()
        local Pos = House and GetOwnedHouseTopPosition(House)
        if Pos then return BikeTeleportTo(Pos + Vector3.new(0, 3, 0)) end
        return true
    end
    SetFarmStatus("BIKE | going to ATM, staying seated")
    if not BikeTeleportTo(PromptPosition + Vector3.new(0, 2, 0)) then
        return false
    end
    task.wait(0.3)

    pcall(function()
        Prompt.MaxActivationDistance = 25
        Prompt.RequiresLineOfSight = false
        Prompt.HoldDuration = 0
    end)

    SetFarmStatus("UNDER CLOSEST ATM | SELLING LOADED DUMPS")

    while true do
        Dumps = GetAllDumpTools()
        if #Dumps == 0 then
            ReturnToHouseAfterSale()
            SetFarmStatus("ALL LOADED DUMPS SOLD | CHECKING DIRTY CASH")
            task.wait(0.35)
            if not DontCleanDirtyMoney then
                AutoConvertDirtyCashAfterSell()
            else
                SetFarmStatus("ALL LOADED DUMPS SOLD | DIRTY CASH KEPT")
            end
            return true
        end

        local Dump = Dumps[1]
        if not Dump or not Dump.Parent then
            task.wait(0.1)
            continue
        end

        if Dump.Parent ~= LocalPlayer.Character then
            Humanoid:UnequipTools()
            task.wait(0.1)
            if not EquipTool(Dump) then
                SetFarmStatus("CLOSEST ATM | waiting to equip Loaded Dump")
                task.wait(0.2)
                continue
            end
        end

        local Sold = false
        for Attempt = 1, 8 do
            if not Root.Parent then
                Cleanup()
                return false
            end

            Root.AssemblyLinearVelocity = Vector3.zero
            Root.AssemblyAngularVelocity = Vector3.zero
            if not BikeTeleportTo(PromptPosition + Vector3.new(0, 2, 0)) then
                SetFarmStatus("SELL | bike not seated")
                return false
            end

            pcall(function()
                Prompt.Enabled = true
                Prompt.MaxActivationDistance = 25
                Prompt.RequiresLineOfSight = false
                Prompt.HoldDuration = 0
            end)

            SetFarmStatus("CLOSEST ATM | SELL TRY " .. tostring(Attempt) .. "/8 | " .. tostring(#GetAllDumpTools()) .. " LEFT")

            local Fired = false

            if type(fireproximityprompt) == "function" then
                Fired = pcall(function()
                    fireproximityprompt(Prompt, 0)
                end)
            end

            if not Fired then
                TriggerPrompt(Prompt)
            end

            task.wait(0.25)

            local Backpack = LocalPlayer:FindFirstChild("Backpack")
            if not Dump.Parent or (Dump.Parent ~= LocalPlayer.Character and Dump.Parent ~= Backpack) then
                Sold = true
                break
            end

            if Dump.Parent ~= LocalPlayer.Character then
                EquipTool(Dump)
                task.wait(0.1)
            end
        end

        if not Sold then
            SetFarmStatus("CLOSEST ATM DID NOT ACCEPT LOADED DUMP")
            Cleanup()
            return false
        end

        SetFarmStatus("DUMP SOLD | " .. tostring(#GetAllDumpTools()) .. " LEFT")
        task.wait(0.15)
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    AutoCardEnabled = false
    AutoCardBusy = false
    GoToSpotEnabled = false
    TravelBusy = false
    SetNoClip(CurrentBike, nil, false)
    ForceSolidPlatform()
end)

pcall(function()
    if Library and type(Library.Watermark) == "function" then
        Watermark = nil
    end
end)

pcall(function()
    if Library and type(Library.KeybindList) == "function" then
        KeyList = Library:KeybindList()
    end
end)

pcall(function()
    if Library and type(Library.CreateSettingsPage) == "function" then
        Library.CreateSettingsPage(Library, Window, Watermark, KeyList)
    end
end)

Notify("Loaded", "Auto Card + purchase controls loaded.", 3)

MainFarmEnabled = false
LaptopBatchInProgress = false
MainFarmBusy = false
HOUSE_BUYING_DONE = false
getgenv().CosmosFarmSettings = getgenv().CosmosFarmSettings or {}
USB_AMOUNT = math.clamp(
    math.floor(tonumber(getgenv().CosmosFarmSettings.USB_AMOUNT) or 2),
    1,
    5
)
USB_TARGET_SETTING = USB_AMOUNT
BATCH_AMOUNT = tonumber(getgenv().CosmosFarmSettings.BATCH_AMOUNT) or 5
PREFERRED_HOUSE_POSITION = Vector3.new(-1563, 5, -793)
DynamicFarmSpot = nil
USBCarryLimitHit = false
USBNotifyConnection = nil

LAPTOP_AMOUNT = tonumber(getgenv().CosmosFarmSettings.LAPTOP_AMOUNT) or 1
USB_RISK_TARGET = tostring(getgenv().CosmosFarmSettings.USB_RISK_TARGET or "High")
USB_DELIVERY_TIME = 95
USBDeliveryReadyAt = nil
USBDeliveryPending = 0
USBPurchaseLock = false
USBLastBuyAt = 0
USB_LAST_BUY_GRACE = 4
USBPurchaseCycleTarget = nil
USBPurchaseCycleCount = 0

function GetUSBTargetAmount()
    local Target = tonumber(USB_AMOUNT)
    if Target == nil then
        Target = tonumber(getgenv().CosmosFarmSettings.USB_AMOUNT)
    end
    return math.clamp(math.floor(Target or 1), 1, 5)
end

USBPurchaseLog = {}
USBPurchaseSequence = 0

CardsSwiped = 0
MoneyMade = 0
MoneySpent = 0
StartingCash = nil
LastCash = nil
MoneyTrackingStartedAt = nil
CurrentStatus = "Idle"
CurrentLaptopCount = 0
StatusLabels = {
    Cards = nil,
    Made = nil,
    Spent = nil,
    Laptops = nil,
    Status = nil,
    Cash = nil,
    DirtyCash = nil,
    Risk = nil,
    Activity = nil,
    Time = nil
}
LastDisplayedCash = nil
LastRiskStatus = "Unknown"

function SetFarmStatus(Status)
    CurrentStatus = tostring(Status or "Idle")

    pcall(function()
        local Label = rawget(StatusLabels, "Status")
        SetLiveLabel(Label, "Current Status: " .. CurrentStatus)
    end)
end

function FarmNotify(a,b,c)
    pcall(function() Library:Notification(a,b,c or 3) end)
end

function GetCurrentCash()
    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
    local HUD = PlayerGui and PlayerGui:FindFirstChild("HUD")
    local Economy = HUD and HUD:FindFirstChild("Economy")
    local Cash = Economy and Economy:FindFirstChild("Cash")
    local Amount = Cash and Cash:FindFirstChild("Amount")

    if not Amount then
        return nil
    end

    local Raw

    pcall(function()
        if Amount:IsA("ValueBase") then
            Raw = Amount.Value
        else
            Raw = Amount.Text
        end
    end)

    if Raw == nil then
        pcall(function()
            Raw = Amount.Value
        end)
    end

    if Raw == nil then
        return nil
    end

    local Text = tostring(Raw):gsub(",", ""):gsub("%s+", "")
    local Number, Suffix = Text:match("([%-]?%d+%.?%d*)([kKmMbB]?)")
    Number = tonumber(Number)
    if not Number then return nil end

    local Multipliers = {k = 1000, m = 1000000, b = 1000000000}
    return Number * (Multipliers[string.lower(Suffix or "")] or 1)
end

function GetCurrentDirtyCash()
    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
    local HUD = PlayerGui and PlayerGui:FindFirstChild("HUD")
    local Status = HUD and HUD:FindFirstChild("Status")
    local DirtyCash = Status and Status:FindFirstChild("DirtyCash")
    local BG = DirtyCash and DirtyCash:FindFirstChild("BG")
    local Amount = BG and BG:FindFirstChild("Amount")

    if not Amount then
        return nil
    end

    local Raw
    pcall(function() Raw = Amount.Text end)
    if Raw == nil then
        pcall(function() Raw = Amount.Value end)
    end
    if Raw == nil then return nil end

    local Clean = tostring(Raw):gsub("[^%d%-%.]", "")
    return tonumber(Clean)
end

function FormatMoney(Value)
    Value = math.floor(tonumber(Value) or 0)

    local Sign = Value < 0 and "-" or ""
    local Digits = tostring(math.abs(Value))

    while true do
        local New, Count = Digits:gsub("^(%d+)(%d%d%d)", "%1,%2")
        Digits = New
        if Count == 0 then break end
    end

    return Sign .. "$" .. Digits
end

function UpdateMoneyTracking()
    local Cash = GetCurrentCash()
    if Cash == nil then return end

    if StartingCash == nil then
        StartingCash = Cash
        MoneyTrackingStartedAt = os.clock()
    end

    if LastCash ~= nil then
        local Change = Cash - LastCash

        if Change > 0 then
            MoneyMade += Change
        elseif Change < 0 then
            MoneySpent += math.abs(Change)
        end
    end

    LastCash = Cash
end

function FormatDuration(Seconds)
    Seconds = math.max(0, math.floor(tonumber(Seconds) or 0))
    local Hours = math.floor(Seconds / 3600)
    local Minutes = math.floor((Seconds % 3600) / 60)
    local RemainingSeconds = Seconds % 60
    if Hours > 0 then
        return string.format("%dh %02dm %02ds", Hours, Minutes, RemainingSeconds)
    end
    return string.format("%dm %02ds", Minutes, RemainingSeconds)
end

function GetMaskedUsername(Name)
    Name = tostring(Name or "Player")
    if #Name <= 2 then
        return "***"
    end
    if #Name <= 5 then
        return Name:sub(1, 1) .. "***"
    end
    return Name:sub(1, 2) .. "***" .. Name:sub(-1)
end

function GetRobloxAvatarUrl()
    return "https://www.roblox.com/headshot-thumbnail/image?userId=" ..
        tostring(LocalPlayer.UserId) .. "&width=420&height=420&format=png"
end

function SetLiveLabel(LabelObject, NewText)
    if not LabelObject then return false end
    NewText = tostring(NewText or "")

    if type(ForceLabelText) == "function" and ForceLabelText(LabelObject, NewText) then
        return true
    end

    local Methods = {"Set", "SetText", "Update", "Refresh", "ChangeText"}

    for _, MethodName in ipairs(Methods) do
        local Method
        pcall(function()
            Method = LabelObject[MethodName]
        end)

        if type(Method) == "function" then
            local OK = pcall(Method, LabelObject, NewText)
            if OK then
                return true
            end
        end
    end

    if typeof(LabelObject) == "Instance" then
        if LabelObject:IsA("TextLabel") or LabelObject:IsA("TextButton") then
            LabelObject.Text = NewText
            return true
        end
    end

    if type(LabelObject) == "table" then
        for _, Key in ipairs({"Text", "Name", "Value"}) do
            pcall(function()
                if typeof(LabelObject[Key]) == "string" then
                    LabelObject[Key] = NewText
                end
            end)
        end

        for _, Key in ipairs({
            "Label", "TextLabel", "Text", "Title", "Object",
            "Instance", "Holder", "Container", "LeftContent"
        }) do
            local Value
            pcall(function()
                Value = LabelObject[Key]
            end)

            if typeof(Value) == "Instance" then
                if Value:IsA("TextLabel") or Value:IsA("TextButton") then
                    Value.Text = NewText
                    return true
                end

                local TextObject = Value:FindFirstChildWhichIsA("TextLabel", true)
                    or Value:FindFirstChildWhichIsA("TextButton", true)

                if TextObject then
                    TextObject.Text = NewText
                    return true
                end
            elseif type(Value) == "table" and Value ~= LabelObject then
                if SetLiveLabel(Value, NewText) then
                    return true
                end
            end
        end

        for _, Value in pairs(LabelObject) do
            if typeof(Value) == "Instance" and Value:IsA("GuiObject") then
                local TextObject
                if Value:IsA("TextLabel") or Value:IsA("TextButton") then
                    TextObject = Value
                else
                    TextObject = Value:FindFirstChildWhichIsA("TextLabel", true)
                        or Value:FindFirstChildWhichIsA("TextButton", true)
                end
                if TextObject then
                    TextObject.Text = NewText
                    return true
                end
            end
        end
    end

    return false
end

function GetLiveLaptopSummary()
    local Placements = workspace:FindFirstChild("Placements")
    local Server = Placements and Placements:FindFirstChild("Server")

    if not Server then
        CurrentLaptopCount = 0
        return 0, 0, 0, 0
    end

    local Total, Idle, Extracting, Ready = 0, 0, 0, 0

    for _, Model in ipairs(Server:GetChildren()) do
        if Model:IsA("Model") and string.lower(Model.Name) == "laptop" then
            local Owner = Model:GetAttribute("Owner")

            if not Owner or tostring(Owner) == LocalPlayer.Name then
                local Prompt = Model:FindFirstChildWhichIsA("ProximityPrompt", true)

                if Prompt then
                    Total += 1

                    local Action = string.lower(tostring(Prompt.ActionText or ""))
                    Action = Action:gsub("^%s+", ""):gsub("%s+$", "")

                    if Action == "dump card" then
                        Ready += 1
                    elseif string.find(Action, "extracting", 1, true) then
                        Extracting += 1
                    else
                        Idle += 1
                    end
                end
            end
        end
    end

    CurrentLaptopCount = Total
    return Total, Idle, Extracting, Ready
end

function RefreshSwipeStats()
    UpdateMoneyTracking()
    local LiveTotal, LiveIdle, LiveExtracting, LiveReady = GetLiveLaptopSummary()

    pcall(function()
        local CardsLabel = rawget(StatusLabels, "Cards")
        local MadeLabel = rawget(StatusLabels, "Made")
        local SpentLabel = rawget(StatusLabels, "Spent")
        local LaptopsLabel = rawget(StatusLabels, "Laptops")
        local StatusLabel = rawget(StatusLabels, "Status")
        local CashLabel = rawget(StatusLabels, "Cash")
        local DirtyCashLabel = rawget(StatusLabels, "DirtyCash")
        local RiskLabel = rawget(StatusLabels, "Risk")
        local ActivityLabel = rawget(StatusLabels, "Activity")
        local TimeLabel = rawget(StatusLabels, "Time")
        local Elapsed = MoneyTrackingStartedAt and (os.clock() - MoneyTrackingStartedAt) or 0

        SetLiveLabel(CardsLabel, "Cards Swiped: " .. tostring(CardsSwiped))
        local LiveCash = GetCurrentCash()
        SetLiveLabel(
            MadeLabel,
            "Money Made: " .. FormatMoney(MoneyMade) ..
            " | Cash: " .. FormatMoney(LiveCash or 0)
        )
        SetLiveLabel(SpentLabel, "Money Spent: " .. FormatMoney(MoneySpent))
        SetLiveLabel(
            LaptopsLabel,
            "Current Laptops: " .. tostring(LiveTotal) ..
            "/" .. tostring(LAPTOP_AMOUNT) ..
            " | Idle: " .. tostring(LiveIdle) ..
            " | Extracting: " .. tostring(LiveExtracting) ..
            " | Ready: " .. tostring(LiveReady)
        )
        SetLiveLabel(
            StatusLabel,
            "Current Status: " .. tostring(CurrentStatus) ..
            " | USB Risk: " .. tostring(LastRiskStatus)
        )
        SetLiveLabel(
            CashLabel,
            "Current Cash: " .. FormatMoney(GetCurrentCash() or 0)
        )
        SetLiveLabel(
            DirtyCashLabel,
            "Dirty Cash: " .. FormatMoney(GetCurrentDirtyCash() or 0)
        )
        SetLiveLabel(
            RiskLabel,
            "USB Risk Target: " .. tostring(USB_RISK_TARGET) ..
            " | Buying: " .. tostring(LastRiskStatus)
        )
        SetLiveLabel(
            ActivityLabel,
            "Live Activity: " .. tostring(CurrentStatus)
        )
        SetLiveLabel(TimeLabel, "Time Running: " .. FormatDuration(Elapsed))
    end)
end

function GetHouses()
    local Apartments = workspace:FindFirstChild("Apartments")
    return Apartments and Apartments:FindFirstChild("Houses")
end

function GetMyHouse()
    local Houses = GetHouses()
    if not Houses then return nil end

    for _, House in ipairs(Houses:GetChildren()) do
        if House:IsA("Model") then
            local Owner = House:GetAttribute("Owner")

            if Owner and tostring(Owner) == LocalPlayer.Name then
                return House
            end
        end
    end

    return nil
end

function HouseAvailable(House)
    local Owner = House:GetAttribute("Owner")
    if Owner == nil then return true end

    local OwnerStr = string.lower(tostring(Owner))
    return OwnerStr == ""
        or OwnerStr == "none"
        or OwnerStr == "unowned"
        or OwnerStr == "available"
end

function ObjectPosition(Object)
    if not Object then return nil end

    if Object:IsA("BasePart") then
        return Object.Position
    end

    if Object:IsA("Attachment")
        and Object.Parent
        and Object.Parent:IsA("BasePart") then
        return Object.Parent.Position
    end

    if Object:IsA("Model") then
        return Object:GetPivot().Position
    end
end

local function TweenRootCFrame(TargetCF)
    if typeof(TargetCF) ~= "CFrame" then return false end
    local _, _, root = GetCharacter()
    if not root then return false end
    root.AssemblyLinearVelocity = Vector3.zero
    root.CFrame = TargetCF
    return true
end

function FarmMoveTo_TWEEN_OLD(Position, Speed)
    return BikeTeleportTo(Position)
end

function FarmMoveTo(Position, Speed)
    if not MainFarmEnabled then
        return false
    end

    if BikeTeleportTo(Position) then
        return true
    end
    SetFarmStatus("BIKE | cannot travel until seated")
    return false
end

function GetBuyPrompt(House)
    if not House then return nil, nil end

    local BuyPart = House:FindFirstChild("BuyPart")
        or House:FindFirstChild("BuyPart", true)

    if not BuyPart then
        for _, Desc in ipairs(House:GetDescendants()) do
            if Desc:IsA("ProximityPrompt") then
                local Action = string.lower(
                    tostring(Desc.ActionText or "")
                )

                if string.find(Action, "buy", 1, true)
                    or string.find(Action, "purchase", 1, true)
                    or string.find(Action, "rent", 1, true) then
                    BuyPart = Desc.Parent
                    break
                end
            end
        end
    end

    local Prompt = BuyPart
        and BuyPart:FindFirstChildWhichIsA(
            "ProximityPrompt",
            true
        )

    return BuyPart, Prompt
end

function BuyHouseForFarm()
    if HOUSE_BUYING_DONE then
        local ExistingLocked = GetMyHouse()
        if ExistingLocked then
            RefreshDynamicFarmSpot()
            return ExistingLocked
        end

        SetFarmStatus("HOUSE BUY LOCKED | already purchased once")
        return nil
    end

    local Existing = GetMyHouse()
    if Existing then
        HOUSE_BUYING_DONE = true
        RefreshDynamicFarmSpot()
        return Existing
    end

    local Apartments = workspace:FindFirstChild("Apartments")
    local Houses = Apartments and Apartments:FindFirstChild("Houses")

    if not Houses then
        SetFarmStatus("HOUSE ERROR | Apartments/Houses missing")
        return nil
    end

    local function Available(House)
        local Owner = House:GetAttribute("Owner")

        if Owner == nil then
            return true
        end

        local S = string.lower(tostring(Owner))

        return S == ""
            or S == "none"
            or S == "unowned"
            or S == "available"
    end

    local function HousePosition(House)
        local BuyPart = House:FindFirstChild("BuyPart")
            or House:FindFirstChild("BuyPart", true)

        if BuyPart and BuyPart:IsA("BasePart") then
            return BuyPart.Position
        end

        local TpPart = House:FindFirstChild("TpPart", true)
            or House:FindFirstChild("TopPart", true)

        if TpPart and TpPart:IsA("BasePart") then
            return TpPart.Position
        end

        if House.PrimaryPart then
            return House.PrimaryPart.Position
        end

        local OK, Pivot = pcall(function()
            return House:GetPivot()
        end)

        return OK and Pivot.Position or nil
    end

    local function ClosestAvailableHouse()
        local BestHouse = nil
        local BestDistance = math.huge

        for _, House in ipairs(Houses:GetChildren()) do
            if House:IsA("Model") and Available(House) then
                local P = HousePosition(House)

                if P then
                    local D = (P - PREFERRED_HOUSE_POSITION).Magnitude

                    if D < BestDistance then
                        BestDistance = D
                        BestHouse = House
                    end
                end
            end
        end

        return BestHouse, BestDistance
    end

    for Attempt = 1, 30 do
        if not MainFarmEnabled then
            return nil
        end

        local Owned = GetMyHouse()

        if Owned then
            RefreshDynamicFarmSpot()
            SetFarmStatus("HOUSE OWNED | " .. tostring(Owned.Name))
            return Owned
        end

        local House, Distance = ClosestAvailableHouse()

        if not House then
            SetFarmStatus("NO AVAILABLE HOUSE - retrying")
            task.wait(0.20)
            continue
        end

        local BuyPart, Prompt = GetBuyPrompt(House)

        if not BuyPart or not Prompt then
            SetFarmStatus("CLOSEST HOUSE HAS NO BUY PROMPT - rescanning")
            task.wait(0.12)
            continue
        end

        local BuyPosition = ObjectPosition(BuyPart)

        if not BuyPosition then
            SetFarmStatus("HOUSE BUY POSITION MISSING")
            task.wait(0.12)
            continue
        end

        SetFarmStatus(
            "BUYING CLOSEST HOUSE | " ..
            tostring(math.floor(Distance or 0)) ..
            " studs from preferred spot"
        )

        if not FarmMoveTo(BuyPosition, 30) then
            task.wait(0.15)
            continue
        end

        local OldDistance = Prompt.MaxActivationDistance
        local OldLOS = Prompt.RequiresLineOfSight
        local OldHold = Prompt.HoldDuration

        pcall(function()
            Prompt.MaxActivationDistance = 40
            Prompt.RequiresLineOfSight = false
            Prompt.HoldDuration = 0
        end)

        if MainFarmEnabled and Available(House) then
            TriggerPrompt(Prompt)
            task.wait(0.20)
        end

        pcall(function()
            Prompt.MaxActivationDistance = OldDistance
            Prompt.RequiresLineOfSight = OldLOS
            Prompt.HoldDuration = OldHold
        end)

        local CurrentOwner = House:GetAttribute("Owner")

        if CurrentOwner
            and tostring(CurrentOwner) == LocalPlayer.Name then

            HOUSE_BUYING_DONE = true
            DynamicFarmSpot = nil
            RefreshDynamicFarmSpot()
            ForceSolidPlatform()
            if not MoveToOwnedHouseForUSB(House) then
                SetFarmStatus("HOUSE BOUGHT | interior teleport pending")
            else
                SetFarmStatus("HOUSE BOUGHT | interior position reached")
            end
            return House
        end

        task.wait(0.12)
    end

    SetFarmStatus("FAILED TO BUY HOUSE AFTER RETRIES")
    return nil
end

function GetDeliveryPrompt(House)
    local Delivery = House and House:FindFirstChild("DeliveryPrompt", true)
    if not Delivery then return nil end

    if Delivery:IsA("ProximityPrompt") then return Delivery end
    return Delivery:FindFirstChildWhichIsA("ProximityPrompt", true)
end

function GetHouseTop(House)
    if not House then return nil end

    for _, Name in ipairs({"TopPart","Top","Roof"}) do
        local Found = House:FindFirstChild(Name,true)
        if Found and ObjectPosition(Found) then return Found end
    end

    local Highest
    local HighestY = -math.huge

    for _, Desc in ipairs(House:GetDescendants()) do
        if Desc:IsA("BasePart") and Desc.Position.Y > HighestY then
            Highest = Desc
            HighestY = Desc.Position.Y
        end
    end

    return Highest
end

function CountToolsContaining(Text)
    Text = string.lower(Text)
    local Count = 0

    local function Scan(Container)
        if not Container then return end

        for _, Tool in ipairs(Container:GetChildren()) do
            if Tool:IsA("Tool")
                and string.find(string.lower(Tool.Name), Text, 1, true) then
                Count += 1
            end
        end
    end

    Scan(LocalPlayer.Character)
    Scan(LocalPlayer:FindFirstChild("Backpack"))
    return Count
end

function GetToolContaining(Text)
    Text = string.lower(Text)

    local function Scan(Container)
        if not Container then return nil end

        for _, Tool in ipairs(Container:GetChildren()) do
            if Tool:IsA("Tool")
                and string.find(string.lower(Tool.Name), Text, 1, true) then
                return Tool
            end
        end
    end

    return Scan(LocalPlayer.Character)
        or Scan(LocalPlayer:FindFirstChild("Backpack"))
end

function GetDeliveryGUIFolders()
    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
    local Deliveries = PlayerGui and PlayerGui:FindFirstChild("Deliveries")
    local MainFrame = Deliveries and Deliveries:FindFirstChild("MainFrame")
    local Main = MainFrame and MainFrame:FindFirstChild("Main")
    local BG = Main and Main:FindFirstChild("BG")

    if not BG then
        return nil, nil
    end

    return BG:FindFirstChild("Orders"), BG:FindFirstChild("Delivered")
end

function IsDeliveryUUID(Name)
    Name = tostring(Name or "")

    return Name:match(
        "^[0-9a-fA-F]+%-[0-9a-fA-F]+%-[0-9a-fA-F]+%-[0-9a-fA-F]+%-[0-9a-fA-F]+$"
    ) ~= nil
end

function GetDeliveryEntries(Folder)
    local Entries = {}

    if not Folder then
        return Entries
    end

    for _, Child in ipairs(Folder:GetChildren()) do
        if IsDeliveryUUID(Child.Name) then
            table.insert(Entries, Child)
        end
    end

    return Entries
end

function CountDeliveryGUI()
    local Orders, Delivered = GetDeliveryGUIFolders()
    local ActiveEntries = GetDeliveryEntries(Orders)
    local ReadyEntries = GetDeliveryEntries(Delivered)

    return #ActiveEntries, #ReadyEntries
end

function HasDeliveredUSB()
    local _, Delivered = GetDeliveryGUIFolders()
    return #GetDeliveryEntries(Delivered) > 0
end

function GetUSBSupplyState()
    local Owned = CountToolsContaining("usb")
    local Active, Ready = CountDeliveryGUI()

    local VisiblePending = Active + Ready
    local LocalPending = math.max(
        0,
        tonumber(USBDeliveryPending) or 0,
        VisiblePending
    )

    if VisiblePending >= (tonumber(USBDeliveryPending) or 0) then
        USBDeliveryPending = VisiblePending
        LocalPending = VisiblePending
    end

    return Owned, Active, Ready, Owned + LocalPending
end

function GetOwnedHouseTopPosition(House)
    if not House then return nil end
    for _, name in ipairs({"InteriorSpawn", "InsideSpawn", "Interior", "Inside", "HouseSpawn", "SpawnPoint"}) do
        local marker = House:FindFirstChild(name, true)
        if marker and marker:IsA("BasePart") then return marker.Position end
        if marker and marker:IsA("Attachment") then return marker.WorldPosition end
    end
    local parts = {}
    for _, part in ipairs(House:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            local lower = string.lower(part.Name)
            if lower:find("floor") and not lower:find("roof") then
                parts[#parts + 1] = part
            end
        end
    end
    if #parts > 0 then
        table.sort(parts, function(a, b) return a.Size.X * a.Size.Z > b.Size.X * b.Size.Z end)
        return parts[1].Position + Vector3.new(0, parts[1].Size.Y * 0.5, 0)
    end
    local ok, cf, size = pcall(function() return House:GetBoundingBox() end)
    if ok and cf and size then
        return cf.Position - Vector3.new(0, size.Y * 0.25, 0)
    end
    return nil
end

local LastHouseMoveAt = 0
local LastHouseMovePosition = nil
local HouseMoveCooldown = 30

function MoveToOwnedHouseForUSB(House)
    if not House then return false end
    local position = GetOwnedHouseTopPosition(House)
    if not position then return false end
    local character, humanoid, root = GetCharacter()
    if not character or not humanoid or not root then return false end
    local target = position + Vector3.new(0, 2.5, 0)
    local bike, seat = FindMyBike()
    local reference = root.Position
    if bike and seat and seat.Occupant == humanoid then
        reference = seat.Position
    end
    if (reference - target).Magnitude <= 22 then return true end
    if LastHouseMovePosition and (LastHouseMovePosition - position).Magnitude < 5
        and os.clock() - LastHouseMoveAt < HouseMoveCooldown then
        return (reference - target).Magnitude <= 22
    end
    LastHouseMoveAt = os.clock()
    LastHouseMovePosition = position
    if bike and seat then
        if seat.Occupant ~= humanoid then
            bike, seat = SitOnOwnedBike()
        end
        if bike and seat and seat.Occupant == humanoid then
            local moved = BikeTeleportTo(position)
            if moved then
                LastHouseMoveAt = os.clock()
                LastHouseMovePosition = position
            end
            return moved
        end
    end
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    character:PivotTo(CFrame.new(target))
    LastHouseMoveAt = os.clock()
    LastHouseMovePosition = position
    return true
end

function HoldAtOwnedHouseTop(House)
    if not House or not MainFarmEnabled then return false end
    local position = GetOwnedHouseTopPosition(House)
    if not position then return false end
    local _, humanoid, root = GetCharacter()
    if not root then return false end
    local bike, seat = FindMyBike()
    local reference = root.Position
    if bike and seat and seat.Occupant == humanoid then
        reference = seat.Position
    end
    if (reference - position).Magnitude <= 30 then return true end
    return MoveToOwnedHouseForUSB(House)
end

function EnsureFiveUSBsCollected(House)
    if not House then return false end

    if not MoveToOwnedHouseForUSB(House) then
        return false
    end

    
    
    
    
    local TargetUSBs = GetUSBTargetAmount()
    USB_TARGET_SETTING = TargetUSBs

    local NoProgressSince = os.clock()

    while MainFarmEnabled do
        if #GetFarmLaptops() == 0 and GetPlacedCardReaderCount() == 0 then
            HoldAtOwnedHouseTop(House)
        end

        local Owned, Active, Ready, Total = GetUSBSupplyState()

        SetFarmStatus(
            "HOUSE USB | Have " .. tostring(Owned) ..
            "/" .. tostring(TargetUSBs) ..
            " | Active " .. tostring(Active) ..
            " | Ready " .. tostring(Ready)
        )

        
        
        if Owned >= TargetUSBs then
            USBDeliveryPending = 0
            USBLastBuyAt = 0
            USBDeliveryReadyAt = nil
            SetFarmStatus(
                tostring(TargetUSBs) .. "/" .. tostring(TargetUSBs) ..
                " USBs physically collected"
            )
            return true
        end

        
        
        local DeliveryPrompt = GetDeliveryPrompt(House)
        local PromptLooksReady = DeliveryPrompt
            and DeliveryPrompt.Parent
            and DeliveryPrompt.Enabled

        if Ready > 0 or HasDeliveredUSB() or PromptLooksReady then
            local Prompt = DeliveryPrompt

            if not Prompt then
                SetFarmStatus("Package ready - reacquiring delivery prompt")
                task.wait(0.15)
                continue
            end

            local OldDistance = Prompt.MaxActivationDistance
            local OldLOS = Prompt.RequiresLineOfSight

            pcall(function()
                Prompt.MaxActivationDistance = 100
                Prompt.RequiresLineOfSight = false
            end)

            local PromptPosition = ObjectPosition(Prompt.Parent)
            local Character, _, Root = GetCharacter()

            if Character and PromptPosition
                and (Root.Position - PromptPosition).Magnitude > 12 then
                SetFarmStatus("PACKAGE READY - moving to collect")
                FarmMoveTo(PromptPosition, 30)
                task.wait(0.2)
            end

            local BeforeOwned = CountToolsContaining("usb")
            local _, BeforeReady = CountDeliveryGUI()

            SetFarmStatus(
                "FORCE COLLECTING PACKAGE | Have " ..
                tostring(BeforeOwned) .. "/" .. tostring(TargetUSBs)
            )

            for Attempt = 1, 12 do
                if not MainFarmEnabled then break end

                if not Prompt.Parent then
                    Prompt = GetDeliveryPrompt(House)
                    if not Prompt then break end
                end

                TriggerPrompt(Prompt)
                task.wait(0.35)

                local NewOwned = CountToolsContaining("usb")
                local _, NewReady = CountDeliveryGUI()

                if NewOwned > BeforeOwned or NewReady < BeforeReady then
                    break
                end
            end

            pcall(function()
                Prompt.MaxActivationDistance = OldDistance
                Prompt.RequiresLineOfSight = OldLOS
            end)

            task.wait(0.15)
            continue
        end

        if Active > 0 then
            HoldAtOwnedHouseTop(House)
            SetFarmStatus(
                "WAITING INSIDE HOUSE | Have " ..
                tostring(Owned) .. "/" .. tostring(TargetUSBs) ..
                " | Active " .. tostring(Active)
            )
            task.wait(0.15)
            continue
        end

        if (tonumber(USBDeliveryPending) or 0) > 0 then
            local ReadyAt = tonumber(USBDeliveryReadyAt)
            if not ReadyAt then
                ReadyAt = (tonumber(USBLastBuyAt) or os.clock()) + USB_DELIVERY_TIME
                USBDeliveryReadyAt = ReadyAt
            end

            if os.clock() < ReadyAt then
                SetFarmStatus(
                    "WAITING FOR USB DELIVERY | pending " ..
                    tostring(USBDeliveryPending) ..
                    " | target " .. tostring(TargetUSBs)
                )
                task.wait(0.25)
                continue
            end

            local PendingActive, PendingReady = CountDeliveryGUI()
            if PendingActive > 0 or PendingReady > 0 then
                continue
            end

            if CountToolsContaining("usb") < TargetUSBs then
                USBDeliveryPending = 0
                USBDeliveryReadyAt = nil
                SetFarmStatus("USB DELIVERY NOT FOUND | RECHECKING OWNED USBs")
            else
                USBDeliveryPending = 0
                USBDeliveryReadyAt = nil
            end
        end

        
        
        if USBCarryLimitHit then
            local CurrentOwned = CountToolsContaining("usb")
            local CurrentActive, CurrentReady = CountDeliveryGUI()

            if CurrentOwned >= TargetUSBs then
                SetFarmStatus(
                    tostring(TargetUSBs) .. "/" .. tostring(TargetUSBs) ..
                    " USBs physically collected"
                )
                return true
            end

            local Prompt = GetDeliveryPrompt(House)

            if Prompt and (CurrentReady > 0 or HasDeliveredUSB()) then
                local OldDistance = Prompt.MaxActivationDistance
                local OldLOS = Prompt.RequiresLineOfSight

                pcall(function()
                    Prompt.MaxActivationDistance = 100
                    Prompt.RequiresLineOfSight = false
                end)

                SetFarmStatus(
                    "USB DELIVERY READY | Have " ..
                    tostring(CurrentOwned) .. "/" .. tostring(TargetUSBs) ..
                    " | collecting only"
                )

                TriggerPrompt(Prompt)
                task.wait(0.45)

                pcall(function()
                    Prompt.MaxActivationDistance = OldDistance
                    Prompt.RequiresLineOfSight = OldLOS
                end)

                continue
            end

            if CurrentActive > 0 then
                SetFarmStatus(
                    "USB DELIVERY ACTIVE | Have " ..
                    tostring(CurrentOwned) .. "/" .. tostring(TargetUSBs) ..
                    " | Active " .. tostring(CurrentActive)
                )
            else
                SetFarmStatus(
                    "USB CARRY LIMIT FLAG | waiting for delivery pickup"
                )
            end

            task.wait(0.25)
            continue
        end

        
        
        local ExactTarget = GetUSBTargetAmount()
        USB_TARGET_SETTING = ExactTarget

        Owned, Active, Ready, Total = GetUSBSupplyState()

        if Owned >= ExactTarget then
            continue
        end

        if Active > 0 or Ready > 0 then
            continue
        end

        local Missing = math.max(0, ExactTarget - Total)

        if Missing > 0 then
            SetFarmStatus(
                "BUYING EXACT USB TARGET | Have " ..
                tostring(Owned) .. "/" .. tostring(ExactTarget) ..
                " | Need " .. tostring(Missing)
            )

            
            
            local Bought = OrderUSBs(House, Missing)

            if Bought < 0 then
                return false
            end

            task.wait(0.5)
            continue
        end

        if os.clock() - NoProgressSince > 8 then
            SetFarmStatus(
                "WAITING FOR USB DELIVERY | Have " ..
                tostring(Owned) .. "/" .. tostring(ExactTarget)
            )
            NoProgressSince = os.clock()
        end

        task.wait(0.35)
    end

    return false
end

function SetupUSBCarryLimitListener()
    if USBNotifyConnection then
        return
    end

    local Packages = ReplicatedStorage:FindFirstChild("Modules")
    Packages = Packages and Packages:FindFirstChild("Packages")
    local Index = Packages and Packages:FindFirstChild("_Index")
    local NetPackage = Index and Index:FindFirstChild("sleitnick_net@0.2.0")
    local NetFolder = NetPackage and NetPackage:FindFirstChild("net")
    local NotifyEvent = NetFolder and NetFolder:FindFirstChild("RE/Notify")

    if not NotifyEvent or not NotifyEvent:IsA("RemoteEvent") then
        return
    end

    USBNotifyConnection = NotifyEvent.OnClientEvent:Connect(function(Message, ...)
        local Text = string.lower(tostring(Message or ""))

        if string.find(Text, "only carry 5", 1, true)
            or string.find(Text, "carry 5 at a time", 1, true) then

            USBCarryLimitHit = true
            local A, R = CountDeliveryGUI()
            USBDeliveryPending = A + R
            USBDeliveryReadyAt = nil
            SetFarmStatus("USB MAX - FORCE PICKUP MODE")
        end
    end)
end

SetupUSBCarryLimitListener()

OrderUSBs = function(House, RequestedAmount)
    if not House then
        SetFarmStatus("USB: no owned house")
        return -1
    end

    if USBPurchaseLock then
        SetFarmStatus("USB BUY LOCKED | waiting for current order")
        return 0
    end

    if not MoveToOwnedHouseForUSB(House) then
        SetFarmStatus("USB: failed to reach house")
        return -1
    end

    
    
    
    local Requested = math.clamp(
        math.floor(tonumber(RequestedAmount) or 1),
        0,
        5
    )

    if Requested <= 0 then
        return 0
    end

    local SelectedTarget = GetUSBTargetAmount()
    USB_TARGET_SETTING = SelectedTarget

    if USBPurchaseCycleTarget ~= SelectedTarget then
        USBPurchaseCycleTarget = SelectedTarget
        USBPurchaseCycleCount = 0
    end

    local Owned, Active, Ready, Total = GetUSBSupplyState()

    if USBPurchaseCycleCount >= SelectedTarget
        or Total >= SelectedTarget then
        SetFarmStatus(
            "USB TARGET REACHED | " ..
            tostring(Total) .. "/" .. tostring(SelectedTarget)
        )
        return 0
    end

    
    local RemainingToTarget = math.max(0, SelectedTarget - Total)
    local ToBuy = math.min(Requested, RemainingToTarget)

    if ToBuy <= 0 then
        SetFarmStatus(
            "USB TARGET ALREADY ACCOUNTED | " ..
            tostring(Total) .. "/" .. tostring(SelectedTarget)
        )
        return 0
    end

    
    if Active > 0 or Ready > 0 or (tonumber(USBDeliveryPending) or 0) > 0 then
        SetFarmStatus(
            "USB ORDER EXISTS | no additional purchase | target " ..
            tostring(SelectedTarget)
        )
        return 0
    end

    if USBCarryLimitHit then
        SetFarmStatus("USB MAX | collect current delivery first")
        return 0
    end

    local Contacts = GetUSBContactsCheapestFirst()
    if #Contacts == 0 then
        SetFarmStatus("USB: no valid contacts found")
        return -1
    end

    USBPurchaseLock = true

    local Bought = 0

    
    
    for Index = 1, ToBuy do
        if not MainFarmEnabled then
            break
        end

        HoldAtOwnedHouseTop(House)

        Owned, Active, Ready, Total = GetUSBSupplyState()
        SelectedTarget = GetUSBTargetAmount()
        USB_TARGET_SETTING = SelectedTarget

        local CurrentMissing = math.max(0, SelectedTarget - Total)
        if CurrentMissing <= 0 then
            break
        end

        Contacts = GetUSBContactsCheapestFirst()
        if #Contacts == 0 then
            SetFarmStatus("USB BUY STOPPED | no valid sale contact")
            break
        end

        
        
        
        local Contact = Contacts[((Bought) % #Contacts) + 1]

        SetFarmStatus(
            "BUYING USB " .. tostring(Total + 1) ..
            "/" .. tostring(SelectedTarget)
        )

        USBDeliveryPending = math.min(
            SelectedTarget,
            (tonumber(USBDeliveryPending) or 0) + 1
        )
        USBLastBuyAt = os.clock()

        local BuyRemote = Leaked or ResolveFarmRemote("RE/Leaked")

        if not BuyRemote or not BuyRemote:IsA("RemoteEvent") then
            USBPurchaseLock = false
            SetFarmStatus("USB BUY FAILED | RE/Leaked remote unavailable")
            return -1
        end

        Leaked = BuyRemote

        
        BuyRemote:FireServer("Buy", Contact.Name)

        Bought += 1
        USBPurchaseCycleCount += 1
        USBPurchaseSequence += 1

        table.insert(USBPurchaseLog, {
            Number = USBPurchaseSequence,
            Contact = Contact.Name,
            Target = SelectedTarget,
            Pending = USBDeliveryPending,
            Time = os.clock()
        })

        warn(
            "[Cosmos USB] purchase #" .. tostring(USBPurchaseSequence) ..
            " sent: " .. tostring(Contact.Name) ..
            " | exactTarget=" .. tostring(SelectedTarget) ..
            " | pending=" .. tostring(USBDeliveryPending)
        )

        if Index < ToBuy then
            task.wait(2)
        end

    end

    USBPurchaseLock = false

    if Bought > 0 then
        USBDeliveryPending = math.min(SelectedTarget, Bought)
        USBLastBuyAt = os.clock()
        USBDeliveryReadyAt = os.clock() + USB_DELIVERY_TIME
        SetFarmStatus(
            "USB BATCH SENT | BOUGHT " .. tostring(Bought) ..
            " | TARGET " .. tostring(SelectedTarget) ..
            " | DELIVERY WAIT " .. tostring(USB_DELIVERY_TIME) .. "s"
        )
    end

    return Bought
end

function WaitForUSBPackages(House, Ordered)
    if not House then return false end
    if not MoveToOwnedHouseForUSB(House) then return false end

    local Active, Ready = CountDeliveryGUI()
    local Expected = math.max(
        tonumber(Ordered) or 0,
        Active + Ready,
        USBDeliveryPending
    )

    if Active <= 0 and Ready <= 0 then
        USBDeliveryPending = 0
        USBDeliveryReadyAt = nil
        SetFarmStatus("No USB delivery found - checking purchase")
        return true
    end

    while MainFarmEnabled do
        HoldAtOwnedHouseTop(House)

        Active, Ready = CountDeliveryGUI()

        if Ready > 0 then
            break
        end

        if Active <= 0 then
            USBDeliveryPending = 0
            USBDeliveryReadyAt = nil
            SetFarmStatus("USB order disappeared - rechecking purchase")
            return true
        end

        SetFarmStatus(
            "At TopPart | USB order active: " .. tostring(Active)
        )

        task.wait(0.25)
    end

    if not MainFarmEnabled then
        return false
    end

    Active, Ready = CountDeliveryGUI()

    if Ready <= 0 then
        SetFarmStatus("No delivered USB to collect")
        return true
    end

    local Prompt = GetDeliveryPrompt(House)

    if not Prompt then
        SetFarmStatus("USB delivered but delivery prompt not found")
        return false
    end

    local OldDistance = Prompt.MaxActivationDistance
    local OldLOS = Prompt.RequiresLineOfSight

    pcall(function()
        Prompt.MaxActivationDistance = math.max(
            tonumber(OldDistance) or 10,
            100
        )
        Prompt.RequiresLineOfSight = false
    end)

    local Safety = 0

    while MainFarmEnabled do
        HoldAtOwnedHouseTop(House)

        Active, Ready = CountDeliveryGUI()

        if Ready <= 0 then
            break
        end

        Safety += 1
        if Safety > 15 then
            break
        end

        SetFarmStatus(
            "Inside house - collecting USB | Ready: " ..
            tostring(Ready)
        )

        TriggerPrompt(Prompt)
        task.wait(1)
    end

    pcall(function()
        Prompt.MaxActivationDistance = OldDistance
        Prompt.RequiresLineOfSight = OldLOS
    end)

    USBDeliveryPending = 0
    USBDeliveryReadyAt = nil

    SetFarmStatus(
        "USB pickup finished | Inventory: " ..
        tostring(CountToolsContaining("usb"))
    )

    return true
end

LAPTOP_BUY_POSITION = Vector3.new(190, 5, 1807)
LaptopAutoBuyBusy = false
ReaderAutoBuyBusy = false

function CountExactOwnedTool(ToolName)
    local Wanted = string.lower(tostring(ToolName or ""))
    local Count = 0

    local function Scan(Container)
        if not Container then return end
        for _, Item in ipairs(Container:GetChildren()) do
            if Item:IsA("Tool") and string.lower(tostring(Item.Name)) == Wanted then
                Count += 1
            end
        end
    end

    Scan(LocalPlayer.Character)
    Scan(LocalPlayer:FindFirstChild("Backpack"))
    return Count
end

function CountPlacedOwnedNamed(NameA, NameB)
    local Placements = workspace:FindFirstChild("Placements")
    local Server = Placements and Placements:FindFirstChild("Server")
    if not Server then return 0 end

    local A = string.lower(tostring(NameA or ""))
    local B = string.lower(tostring(NameB or ""))
    local Count = 0

    for _, Object in ipairs(Server:GetChildren()) do
        local N = string.lower(tostring(Object.Name or ""))
        local Match = N == A or (B ~= "" and N == B)
        if Match then
            local Owner = Object:GetAttribute("Owner")
            if not Owner or tostring(Owner) == LocalPlayer.Name then
                Count += 1
            end
        end
    end

    return Count
end

function GetLaptopSupplyCount()
    return CountExactOwnedTool("Laptop") + CountPlacedOwnedNamed("Laptop", "")
end

function GetReaderSupplyCount()
    return CountExactOwnedTool("Card Reader") + CountPlacedOwnedNamed("Card Reader", "CardReader")
end

function ReturnToOwnedHouseNow()
    local House = GetMyHouse()
    if not House then return false end
    local Position = GetOwnedHouseTopPosition(House)
    if not Position then return false end
    SetFarmStatus("RETURNING TO OWNED HOUSE")
    return MoveToOwnedHouseForUSB(House)
end

function TweenToLaptopShop()
    if typeof(LAPTOP_BUY_POSITION) ~= "Vector3" then return false end
    return FarmMoveTo(LAPTOP_BUY_POSITION, 26)
end

local SolsticesPurchaseAudit = {}
local function AuditPurchase(Item, Event, Owned, Target)
    SolsticesPurchaseAudit[#SolsticesPurchaseAudit + 1] = {
        item = Item,
        event = Event,
        owned = Owned,
        target = Target,
        at = os.clock()
    }
    if #SolsticesPurchaseAudit > 150 then
        table.remove(SolsticesPurchaseAudit, 1)
    end
end


function EnsureLaptopOwnedOrPlaced()
    local Target = math.clamp(math.floor(tonumber(LAPTOP_AMOUNT) or 1), 1, 5)
    local Have = GetLaptopSupplyCount()
    if Have >= Target then return true end
    if LaptopAutoBuyBusy then return false end
    LaptopAutoBuyBusy = true

    local Attempts = 0
    local ConsecutiveFailures = 0
    while MainFarmEnabled and GetLaptopSupplyCount() < Target do
        if ConsecutiveFailures >= 3 then
            SetFarmStatus("LAPTOP NOT RECEIVED | STAYING AT SHOP | CHECK CASH / STORE")
            break
        end
        local arrived = TweenToLaptopShop()
        if not arrived then
            SetFarmStatus("LAPTOP SHOP TRAVEL FAILED | NOT LEAVING")
            break
        end
        task.wait(0.5)
        local Before = GetLaptopSupplyCount()
        Attempts += 1
        SetFarmStatus("LAPTOP SHOP | BUYING " .. tostring(Before + 1) .. "/" .. tostring(Target))
        AuditPurchase("Laptop", "purchase_attempt", Before, Target)
        local requested = BuyLaptop()
        if not requested then
            SetFarmStatus("LAPTOP REMOTE FAILED | STAYING AT SHOP")
            break
        end
        local Deadline = os.clock() + 12
        local Received = false
        while MainFarmEnabled and os.clock() < Deadline do
            if GetLaptopSupplyCount() > Before then
                Received = true
                break
            end
            task.wait(0.25)
        end
        if Received then
            ConsecutiveFailures = 0
            AuditPurchase("Laptop", "received", GetLaptopSupplyCount(), Target)
            SetFarmStatus("LAPTOP RECEIVED " .. tostring(GetLaptopSupplyCount()) .. "/" .. tostring(Target))
            task.wait(0.5)
        else
            ConsecutiveFailures += 1
            AuditPurchase("Laptop", "unconfirmed", GetLaptopSupplyCount(), Target)
            SetFarmStatus("LAPTOP NOT RECEIVED | RETRY " .. tostring(ConsecutiveFailures) .. "/3")
            task.wait(2)
        end
    end

    Have = GetLaptopSupplyCount()
    LaptopAutoBuyBusy = false
    if Have < Target then
        SetFarmStatus("LAPTOP MISSING " .. tostring(Target - Have) .. " | CHECK STORE / CASH")
        return false
    end
    SetFarmStatus("LAPTOP PURCHASE CONFIRMED " .. tostring(Have) .. "/" .. tostring(Target))
    return true
end

function EnsureReaderOwnedOrPlaced()
    local target = math.clamp(math.floor(tonumber(LAPTOP_AMOUNT) or 1), 1, 5)
    if GetReaderSupplyCount() >= target then return true end
    if ReaderAutoBuyBusy then return false end
    ReaderAutoBuyBusy = true
    local failures = 0
    while MainFarmEnabled and GetReaderSupplyCount() < target and failures < 3 do
        local before = GetReaderSupplyCount()
        AuditPurchase("Card Reader", "purchase_attempt", before, target)
        local ok = BuyCardReader()
        if ok == false then
            failures += 1
        else
            local deadline = os.clock() + 9
            while MainFarmEnabled and os.clock() < deadline and GetReaderSupplyCount() <= before do
                task.wait(0.25)
            end
            if GetReaderSupplyCount() > before then
                failures = 0
                AuditPurchase("Card Reader", "received", GetReaderSupplyCount(), target)
            else
                failures += 1
                AuditPurchase("Card Reader", "not_confirmed", GetReaderSupplyCount(), target)
            end
        end
        task.wait(0.5)
    end
    ReaderAutoBuyBusy = false
    local owned = GetReaderSupplyCount()
    if owned < target then
        SetFarmStatus("CARD READERS MISSING " .. tostring(target - owned))
    end
    return owned >= target
end

function GetFarmLaptops()
    local Results = {}
    local Placements = workspace:FindFirstChild("Placements")
    local Server = Placements and Placements:FindFirstChild("Server")
    if not Server then return Results end

    for _, Model in ipairs(Server:GetChildren()) do
        if #Results >= LAPTOP_AMOUNT then break end

        if Model:IsA("Model") and string.lower(Model.Name) == "laptop" then
            local Owner = Model:GetAttribute("Owner")

            if not Owner or tostring(Owner) == LocalPlayer.Name then
                local Prompt = Model:FindFirstChildWhichIsA("ProximityPrompt",true)

                if Prompt then
                    table.insert(Results,{
                        Model = Model,
                        Prompt = Prompt
                    })
                end
            end
        end
    end

    CurrentLaptopCount = #Results
    return Results
end

function GetPlacedCardReaderCount()
    local Count = 0
    local Placements = workspace:FindFirstChild("Placements")
    local Server = Placements and Placements:FindFirstChild("Server")

    if not Server then
        return 0
    end

    for _, Object in ipairs(Server:GetChildren()) do
        local Name = string.lower(tostring(Object.Name or ""))

        if string.find(Name, "card reader", 1, true)
            or string.find(Name, "cardreader", 1, true) then

            local Owner = Object:GetAttribute("Owner")

            if not Owner or tostring(Owner) == LocalPlayer.Name then
                Count += 1
            end
        end
    end

    return Count
end

function GetReadyFarmLaptops()

    return GetFarmLaptops()
end

function WaitForRequiredLaptops()
    while MainFarmEnabled do
        local House = GetMyHouse()
        if not House then
            SetFarmStatus("SETUP CHECK | HOUSE MISSING")
            return nil
        end

        local PlacedLaptops = #GetFarmLaptops()
        local PlacedReaders = GetPlacedCardReaderCount()
        local LaptopTools = CountExactOwnedTool("Laptop")
        local ReaderTools = CountExactOwnedTool("Card Reader")

        SetFarmStatus(
            "SETUP LOG | Laptop placed " .. tostring(PlacedLaptops) ..
            " | on me " .. tostring(LaptopTools) ..
            " | Reader placed " .. tostring(PlacedReaders) ..
            " | on me " .. tostring(ReaderTools)
        )

        if PlacedLaptops + LaptopTools < LAPTOP_AMOUNT then
            if not EnsureLaptopOwnedOrPlaced() then
                SetFarmStatus("WAITING FOR LAPTOP PURCHASE | NOT LEAVING SHOP")
                task.wait(3)
                return nil
            end
            task.wait(0.25)
        end

        if PlacedReaders + ReaderTools < LAPTOP_AMOUNT then
            EnsureReaderOwnedOrPlaced()
            task.wait(0.25)
        end

        local Laptops = GetFarmLaptops()
        local Readers = GetPlacedCardReaderCount()
        CurrentLaptopCount = #Laptops
        RefreshSwipeStats()

        if #Laptops >= LAPTOP_AMOUNT and Readers >= LAPTOP_AMOUNT then
            SetFarmStatus(
                "SETUP READY | laptops/readers placed | USB AUTO NEXT"
            )
            return Laptops
        end

        SetFarmStatus(
            "PLACE ITEMS IN HOUSE | Laptop " .. tostring(#Laptops) .. "/" .. tostring(LAPTOP_AMOUNT) ..
            " | Reader " .. tostring(Readers) .. "/" .. tostring(LAPTOP_AMOUNT)
        )
        task.wait(0.6)
    end

    return nil
end

function GetLaptopAction(Entry)
    local Prompt = Entry and Entry.Prompt
    if not Prompt or not Prompt.Parent then
        return ""
    end

    local Action = string.lower(tostring(Prompt.ActionText or ""))
    local ObjectText = string.lower(tostring(Prompt.ObjectText or ""))
    if Action == "" then
        Action = ObjectText
    elseif ObjectText ~= "" then
        Action = Action .. " " .. ObjectText
    end
    Action = Action:gsub("^%s+", ""):gsub("%s+$", "")
    Action = Action:gsub("%s+", " "):gsub("%.+", "")
    return Action
end

function LaptopExtracting(Entry)
    local Action = GetLaptopAction(Entry)
    return string.find(Action, "extracting", 1, true) ~= nil
end

function LaptopReady(Entry)
    return string.find(GetLaptopAction(Entry), "dump card", 1, true) ~= nil
end

function LaptopNeedsUSB(Entry)
    local Action = GetLaptopAction(Entry)

    if Action == "" or LaptopExtracting(Entry) or LaptopReady(Entry) then
        return false
    end

    return true
end

USBUsedLaptop = setmetatable({}, {__mode = "k"})

function UseUSBOnFarmLaptop(Entry)
    if not Entry or not Entry.Model or not Entry.Prompt then
        return false
    end

    if USBUsedLaptop[Entry.Model] then
        return false
    end

    local Action = GetLaptopAction(Entry)

    if Action == "extracting.." or Action == "extracting"
        or Action == "dump card" then
        USBUsedLaptop[Entry.Model] = true
        return false
    end

    if not LaptopNeedsUSB(Entry) then
        return false
    end

    local USB = GetToolContaining("usb")
    if not USB then
        return false
    end

    local P = ObjectPosition(Entry.Prompt.Parent)
    if P then
        FarmMoveTo(P, 12)
    end

    Action = GetLaptopAction(Entry)

    if Action == "extracting.." or Action == "extracting"
        or Action == "dump card"
        or not LaptopNeedsUSB(Entry) then
        USBUsedLaptop[Entry.Model] = true
        return false
    end

    if not EquipTool(USB) then
        return false
    end

    task.wait(0.06)

    if not LaptopNeedsUSB(Entry) then
        USBUsedLaptop[Entry.Model] = true
        return false
    end

    SetFarmStatus("Using USB on laptop")

    if not TriggerPrompt(Entry.Prompt) then
        return false
    end

    USBUsedLaptop[Entry.Model] = true
    LaptopBatchInProgress = true

    local Started = os.clock()
    while os.clock() - Started < 3 do
        local Current = GetLaptopAction(Entry)
        if Current == "extracting.." or Current == "extracting"
            or Current == "dump card" then
            break
        end
        task.wait(0.15)
    end

    return true
end

function WaitAllLaptops(Active)
    FarmNotify("Laptop", "Watching all laptops for Dump Card.", 3)

    local Completed = {}
    local CompletedCount = 0

    while MainFarmEnabled and CompletedCount < #Active do
        for Index, Entry in ipairs(Active) do
            if not Completed[Index] and LaptopReady(Entry) then
                SetFarmStatus(
                    "Laptop " .. tostring(Index) ..
                    " says Dump Card"
                )

                local Card = GetToolContaining("blank card")

                if not Card then
                    SetFarmStatus("No Blank Card owned - buying one")

                    Convenience:FireServer(
                        "PurchasePablo",
                        {
                            name = "Blank Card",
                            category = "Items"
                        }
                    )

                    local Started = os.clock()

                    repeat
                        task.wait(0.2)
                        Card = GetToolContaining("blank card")
                    until Card
                        or not MainFarmEnabled
                        or os.clock() - Started >= 5

                    if not Card then
                        FarmNotify(
                            "Blank Card",
                            "Card purchase did not appear. Stopping retry spam.",
                            4
                        )
                        return false
                    end
                end

                if not MainFarmEnabled then return false end

                local P = ObjectPosition(Entry.Prompt.Parent)
                if P then
                    FarmMoveTo(P, 12)
                end

                if LaptopReady(Entry) then
                    if EquipTool(Card) then
                        task.wait(0.35)

                        SetFarmStatus(
                            "Using Blank Card on laptop " .. tostring(Index)
                        )

                        if TriggerPrompt(Entry.Prompt) then
                            task.wait(0.45)

                            Swiping:FireServer("Completed", Entry.Model)
                            task.wait(0.8)

                            SetFarmStatus(
                                "Collecting dump " .. tostring(Index)
                            )

                            CollectFarmDump(Entry)

                            Completed[Index] = true
                            CompletedCount += 1

                            FarmNotify(
                                "Laptop",
                                "Completed " ..
                                tostring(CompletedCount) .. "/" ..
                                tostring(#Active),
                                2
                            )
                        else

                            FarmNotify(
                                "Laptop",
                                "Prompt failed; retrying owned card.",
                                2
                            )
                        end
                    else
                        FarmNotify(
                            "Laptop",
                            "Could not equip owned Blank Card.",
                            3
                        )
                    end
                end
            end
        end

        if CompletedCount < #Active then
            SetFarmStatus(
                "Watching Dump Card " ..
                tostring(CompletedCount) .. "/" ..
                tostring(#Active)
            )
            task.wait(0.75)
        end
    end

    return CompletedCount == #Active
end

function BuyBlankCardsForBatch(Amount)
    local Existing = CountToolsContaining("blank card")
    local Needed = math.max(0, Amount - Existing)

    for Index = 1, Needed do
        Convenience:FireServer(
            "PurchasePablo",
            {name="Blank Card",category="Items"}
        )
        task.wait(0.4)
    end
end

function DumpFarmLaptop(Entry)

    if not LaptopReady(Entry) then
        return false
    end

    local Card = GetToolContaining("blank card")
    if not Card then
        return false
    end

    local P = ObjectPosition(Entry.Prompt.Parent)
    if P then FarmMoveTo(P,12) end

    if not EquipTool(Card) then
        return false
    end

    task.wait(0.35)

    if not TriggerPrompt(Entry.Prompt) then
        return false
    end

    task.wait(0.5)

    Swiping:FireServer("Completed", Entry.Model)
    task.wait(0.8)

    return true
end

CollectFarmDump = function(Entry)
    if not Entry or not Entry.Model or not Entry.Prompt then
        return false
    end

    local Before = CountToolsContaining("dump")

    if Before > 0 then return true end
    if not Entry.Model or not Entry.Model.Parent then return false end
    local now = os.clock()
    if Entry._LastCollectAttempt and now - Entry._LastCollectAttempt < 2.5 then
        return false
    end

    local Action = GetLaptopAction(Entry)

    if Action ~= "dump card" then
        SetFarmStatus("Laptop dump finished - not touching Insert USB prompt")
        return true
    end

    local P = ObjectPosition(Entry.Prompt.Parent)
    if P then
        FarmMoveTo(P, 12)
    end

    Action = GetLaptopAction(Entry)
    if Action ~= "dump card" then
        SetFarmStatus("Laptop already left Dump Card - collection complete")
        return true
    end

    Entry._LastCollectAttempt = os.clock()
    TriggerPrompt(Entry.Prompt)
    task.wait(0.75)

    if CountToolsContaining("dump") > Before then
        return true
    end

    if GetLaptopAction(Entry) ~= "dump card" then
        return true
    end

    SetFarmStatus("Dump collection pending - no prompt spam")
    return false
end

RecoverCharacterCamera = function()
    local Character, Humanoid, Root = GetCharacter()
    if not Character then return false end

    local Camera = workspace.CurrentCamera

    if Camera then
        Camera.CameraType = Enum.CameraType.Custom
        Camera.CameraSubject = Humanoid
    end

    Root.AssemblyLinearVelocity = Vector3.zero
    Root.AssemblyAngularVelocity = Vector3.zero
    return true
end

function SellExistingDumpsBeforeCycle()
    while MainFarmEnabled do
        local DumpCount = #GetAllDumpTools()

        if DumpCount <= 0 then
            SetFarmStatus("No loaded dumps - farm can continue")
            return true
        end

        SetFarmStatus(
            "DUMP TARGET READY " .. tostring(DumpCount) ..
            "/" .. tostring(BATCH_AMOUNT) .. " | SELLING ALL"
        )

        FarmNotify(
            "Main Farm",
            "Selling " .. tostring(DumpCount) ..
            " loaded dump(s) before anything else.",
            3
        )

        SellAllLoadedDumps()

        local Started = os.clock()

        while MainFarmEnabled and os.clock() - Started < 5 do
            if #GetAllDumpTools() <= 0 then
                SetFarmStatus("All loaded dumps sold")
                return true
            end
            task.wait(0.25)
        end

        if #GetAllDumpTools() > 0 then
            SetFarmStatus("Dump still present - retrying ATM sale")
            task.wait(1)
        end
    end

    return false
end

function HasUnfinishedLaptopWork()
    local Laptops = GetFarmLaptops()

    for _, Entry in ipairs(Laptops) do
        local Action = GetLaptopAction(Entry)
        if Action == "dump card" or LaptopExtracting(Entry) then
            return true
        end
    end

    return false
end

function ResumeUSBWaitAtHouseIfNeeded()
    local LiveActive, LiveReady = CountDeliveryGUI()
    if LiveActive <= 0 and LiveReady <= 0 and USBDeliveryPending <= 0 then
        return false, nil
    end

    USBDeliveryPending = math.max(USBDeliveryPending, LiveActive + LiveReady)

    local House = GetMyHouse()
    if not House then
        return false, nil
    end

    local Character, _, Root = GetCharacter()
    if not Character then
        return false, nil
    end

    local HousePart = House:FindFirstChild("TopPart", true)
        or House:FindFirstChild("DeliveryPrompt", true)

    local HousePosition = HousePart and ObjectPosition(HousePart)

    if not HousePosition then
        return false, nil
    end

    if (Root.Position - HousePosition).Magnitude <= 80 then
        SetFarmStatus(
            "Resuming USB wait at house: " ..
            tostring(USBDeliveryPending) .. " pending"
        )

        FarmNotify(
            "Main Farm",
            "USB delivery still pending - staying at house.",
            3
        )

        return true, House
    end

    return false, House
end

function GetBatchTarget()
    return GetUSBTargetAmount()
end

function CountBusyFarmLaptops()
    local Count = 0

    for _, Entry in ipairs(GetFarmLaptops()) do
        if LaptopExtracting(Entry) or LaptopReady(Entry) then
            Count += 1
        end
    end

    return Count
end

function USBWorkStillExists()

    if CountToolsContaining("usb") > 0 then
        return true
    end

    if USBDeliveryReadyAt and USBDeliveryPending > 0 then
        return true
    end

    return CountBusyFarmLaptops() > 0
end

function GetSelectedLaptopBatch()
    local All = GetFarmLaptops()
    local Selected = {}

    for Index = 1, math.min(#All, LAPTOP_AMOUNT) do
        table.insert(Selected, All[Index])
    end

    return Selected
end

function ReturnToFarmPlatformForBatch()
    local Spot = RefreshDynamicFarmSpot()
    if not Spot then return false end
    local Character, Humanoid, Root = GetCharacter()
    if not Character then return false end
    
    RemoveTravelFloor()
    Root.AssemblyLinearVelocity = Vector3.zero
    Root.AssemblyAngularVelocity = Vector3.zero
    TweenRootCFrame(CFrame.new(Spot))
    return true
end

function WaitUntilWholeLaptopBatchReady()

    while MainFarmEnabled do
        if not ReturnToFarmPlatformForBatch() then
            return nil
        end

        local Batch = GetSelectedLaptopBatch()

        if #Batch < LAPTOP_AMOUNT then
            SetFarmStatus(
                "Waiting for laptops: " ..
                tostring(#Batch) .. "/" .. tostring(LAPTOP_AMOUNT)
            )
            task.wait(1)
            continue
        end

        local ReadyCount = 0
        local ExtractingCount = 0

        for _, Entry in ipairs(Batch) do
            if LaptopReady(Entry) then
                ReadyCount += 1
            elseif LaptopExtracting(Entry) then
                ExtractingCount += 1
            end
        end

        if ReadyCount == #Batch and #Batch == LAPTOP_AMOUNT then
            SetFarmStatus(
                "ALL laptops ready: " ..
                tostring(ReadyCount) .. "/" .. tostring(LAPTOP_AMOUNT)
            )
            return Batch
        end

        SetFarmStatus(
            "Waiting at farm | Dump Card " ..
            tostring(ReadyCount) .. "/" .. tostring(LAPTOP_AMOUNT) ..
            " | Extracting " .. tostring(ExtractingCount)
        )

        task.wait(1)
    end

    return nil
end

BlankCardDumpedLaptop = setmetatable({}, {__mode = "k"})
BlankCardPromptSentLaptop = setmetatable({}, {__mode = "k"})

function DumpWholeLaptopBatchTogether(Batch)

    local Completed = 0

    for Index, Entry in ipairs(Batch) do
        if not MainFarmEnabled then return false end
        if not Entry or not Entry.Model or not Entry.Prompt then
            return false
        end

        if BlankCardDumpedLaptop[Entry.Model] then
            Completed += 1
            continue
        end

        if BlankCardPromptSentLaptop[Entry.Model] then
            SetFarmStatus(
                "Laptop " .. tostring(Index) ..
                " already swiped - waiting, no spam"
            )

            local Started = os.clock()
            while MainFarmEnabled
                and LaptopReady(Entry)
                and os.clock() - Started < 12 do
                task.wait(0.25)
            end

            if LaptopReady(Entry) then
                SetFarmStatus(
                    "Laptop " .. tostring(Index) ..
                    " still says Dump Card - NOT re-firing prompt"
                )
                return false
            end

            BlankCardDumpedLaptop[Entry.Model] = true
            Completed += 1
            continue
        end

        if not LaptopReady(Entry) then
            if LaptopExtracting(Entry) then
                SetFarmStatus(
                    "Laptop " .. tostring(Index) ..
                    " still extracting"
                )
                return false
            end

            BlankCardDumpedLaptop[Entry.Model] = true
            Completed += 1
            continue
        end

        local Card = GetToolContaining("blank card")

        if not Card then
            SetFarmStatus(
                "Buying one Blank Card for laptop " ..
                tostring(Index)
            )

            Convenience:FireServer(
                "PurchasePablo",
                {
                    name = "Blank Card",
                    category = "Items"
                }
            )

            local Started = os.clock()
            repeat
                task.wait(0.2)
                Card = GetToolContaining("blank card")
            until Card
                or not MainFarmEnabled
                or os.clock() - Started >= 5
        end

        if not Card then
            SetFarmStatus("Blank Card unavailable")
            return false
        end

        local P = ObjectPosition(Entry.Prompt.Parent)
        if P then
            FarmMoveTo(P, 12)
        end

        if not LaptopReady(Entry) then
            BlankCardDumpedLaptop[Entry.Model] = true
            Completed += 1
            continue
        end

        if not EquipTool(Card) then
            return false
        end

        task.wait(0.3)

        if not LaptopReady(Entry) then
            BlankCardDumpedLaptop[Entry.Model] = true
            Completed += 1
            continue
        end

        SetFarmStatus(
            "Swiping Blank Card ONCE on laptop " ..
            tostring(Index)
        )

        BlankCardPromptSentLaptop[Entry.Model] = true

        local Fired = TriggerPrompt(Entry.Prompt)

        if not Fired then

            BlankCardPromptSentLaptop[Entry.Model] = nil
            SetFarmStatus(
                "Blank Card prompt failed once - waiting before retry"
            )
            task.wait(1)
            return false
        end

        task.wait(0.4)

        Swiping:FireServer("Completed", Entry.Model)

        local Started = os.clock()
        while MainFarmEnabled
            and LaptopReady(Entry)
            and os.clock() - Started < 12 do
            SetFarmStatus(
                "Laptop " .. tostring(Index) ..
                " swipe sent - waiting for server"
            )
            task.wait(0.25)
        end

        BlankCardDumpedLaptop[Entry.Model] = true

        SetFarmStatus(
            "Finishing dump " ..
            tostring(Index) .. "/" .. tostring(#Batch)
        )

        if LaptopReady(Entry) then
            CollectFarmDump(Entry)
        end

        Completed += 1
        CardsSwiped += 1
        RefreshSwipeStats()
    end

    return Completed == #Batch
end

function HandleUrgentFarmWork()

    local ReadyNow = {}

    for _, Entry in ipairs(GetFarmLaptops()) do
        if LaptopReady(Entry) then
            table.insert(ReadyNow, Entry)
        end
    end

    if #ReadyNow > 0 then
        SetFarmStatus(
            "URGENT: Dumping ready laptop(s): " ..
            tostring(#ReadyNow)
        )

        local OK = DumpWholeLaptopBatchTogether(ReadyNow)

        SetFarmStatus("Ready batch handled - rescanning all laptops")
        return true, OK
    end

    local OwnedUSBNow = CountToolsContaining("usb")
    local WantedUSBNow = GetSelectedUSBTarget()
    local ActiveUSBNow, ReadyUSBNow = CountDeliveryGUI()

    if OwnedUSBNow < WantedUSBNow
        or ActiveUSBNow > 0
        or ReadyUSBNow > 0 then

        local House = GetMyHouse()

        if House then
            if #GetFarmLaptops() == 0 and GetPlacedCardReaderCount() == 0 then
                MoveToOwnedHouseForUSB(House)
                HoldAtOwnedHouseTop(House)
            end

            SetFarmStatus(
                "BUILDING FULL USB BATCH | Have " ..
                tostring(OwnedUSBNow) .. "/" ..
                tostring(WantedUSBNow) ..
                " | Active " .. tostring(ActiveUSBNow) ..
                " | Ready " .. tostring(ReadyUSBNow)
            )

            EnsureFiveUSBsCollected(House)
        end

        return true, true
    end

    if OwnedUSBNow >= WantedUSBNow then
        local IdleUSBTargets = {}

        for _, Entry in ipairs(GetFarmLaptops()) do
            if LaptopNeedsUSB(Entry) then
                table.insert(IdleUSBTargets, Entry)
            end
        end

        if #IdleUSBTargets > 0 then
            local WantedUSB = GetUSBTargetAmount()

            local ToUse = math.min(
                WantedUSBNow,
                OwnedUSBNow,
                #IdleUSBTargets
            )

            SetFarmStatus(
                "USB ON HAND - USING NOW | " ..
                tostring(ToUse) .. " laptop(s)"
            )

            local Used = 0

            for _, Entry in ipairs(IdleUSBTargets) do
                if not MainFarmEnabled or Used >= ToUse then
                    break
                end

                if CountToolsContaining("usb") <= 0 then
                    break
                end

                if Entry.Model and LaptopNeedsUSB(Entry) then
                    USBUsedLaptop[Entry.Model] = nil
                end

                local OK, Result = pcall(UseUSBOnFarmLaptop, Entry)

                if OK and Result == true then
                    Used += 1
                    LaptopBatchInProgress = true
                    SetFarmStatus(
                        "USING USB | " ..
                        tostring(Used) .. "/" .. tostring(ToUse)
                    )
                end

                task.wait(0.08)
            end

            return true, true
        end
    end

    local Active, Ready = CountDeliveryGUI()

    if Ready > 0 or HasDeliveredUSB() then
        local House = GetMyHouse()

        if not House then
            SetFarmStatus("USB ready but owned house not found")
            return true, false
        end

        SetFarmStatus("PACKAGE READY - FORCE COLLECTING NOW")

        if not EnsureFiveUSBsCollected(House) then
            return true, false
        end

        return true, true
    end

    if Active > 0 then
        local House = GetMyHouse()

        if not House then
            SetFarmStatus("USB active - owned house not found")
            return true, false
        end

        local TopPart = House:FindFirstChild("TopPart", true)
        local Character, _, Root = GetCharacter()

        if TopPart and TopPart:IsA("BasePart") and Character then
            local WaitPosition = TopPart.Position + Vector3.new(0, 3, 0)

            if (Root.Position - WaitPosition).Magnitude > 8 then
                SetFarmStatus("Going to house TopPart")
                FarmMoveTo(WaitPosition, 18)
                task.wait(0.25)
            end

            Root.AssemblyLinearVelocity = Vector3.zero
            Root.AssemblyAngularVelocity = Vector3.zero
        end

        SetFarmStatus("WAITING AT HOUSE - USB DELIVERY")
        task.wait(0.5)
        return true, true
    end

    return false, true
end

function ResetMainFarmForNextCycle()
    if type(USBUsedLaptop) == "table" then table.clear(USBUsedLaptop) end
    if type(BlankCardDumpedLaptop) == "table" then table.clear(BlankCardDumpedLaptop) end

    LaptopBatchInProgress = false
    USBDeliveryPending = 0
    USBDeliveryReadyAt = nil
    USBPurchaseCycleTarget = GetUSBTargetAmount()
    USBPurchaseCycleCount = 0

    if CountToolsContaining("usb") <= 0 then
        USBCarryLimitHit = false
    end

    SetFarmStatus("Batch complete - starting next cycle")
    task.wait(0.25)
end

GetSelectedUSBTarget = function()
    USB_AMOUNT = GetUSBTargetAmount()
    USB_TARGET_SETTING = USB_AMOUNT
    return USB_AMOUNT
end

function USBHousePhaseActive()
    local Owned, Active, Ready = GetUSBSupplyState()
    local Wanted = GetSelectedUSBTarget()

    if Active > 0 or Ready > 0 then
        return true, Owned, Active, Ready, Wanted
    end

    if Owned >= Wanted then
        return false, Owned, Active, Ready, Wanted
    end

    return false, Owned, Active, Ready, Wanted
end

RefreshDynamicFarmSpot = function()
    local House = GetMyHouse()
    if not House then
        DynamicFarmSpot = nil
        _G.CosmosOwnedHouseFarmSpot = nil
        return nil
    end

    local Position = GetOwnedHouseTopPosition(House)
    if Position then
        DynamicFarmSpot = Position + Vector3.new(0, 3, 0)
    else
        DynamicFarmSpot = nil
    end

    _G.CosmosOwnedHouseFarmSpot = DynamicFarmSpot
    return DynamicFarmSpot
end

function RunMainFarmCycle()

    if AutoMaskedEnabled and not AutoMaskedDone then
        EnsureAutoMasked()
    end

    local RequiredHouse = GetMyHouse()

    if not RequiredHouse then
        SetFarmStatus("NO HOUSE | buying closest house now")

        RequiredHouse = BuyHouseForFarm()

        if not RequiredHouse then
            SetFarmStatus("HOUSE BUY RETRY | staying in house-buy phase")
            task.wait(0.20)
            return false
        end
    end

    if #GetFarmLaptops() == 0 and GetPlacedCardReaderCount() == 0 then
        MoveToOwnedHouseForUSB(RequiredHouse)
    end

    local LaptopTarget = math.clamp(math.floor(tonumber(LAPTOP_AMOUNT) or 1), 1, 5)
    local LaptopOwned = GetLaptopSupplyCount()
    local ReaderOwned = GetReaderSupplyCount()
    if LaptopOwned < LaptopTarget or ReaderOwned < LaptopTarget then
        local now = os.clock()
        if now >= (NextEquipmentRestockAt or 0) then
            NextEquipmentRestockAt = now + 15
            local NeededLaptops = math.max(0, LaptopTarget - LaptopOwned)
            local NeededReaders = math.max(0, LaptopTarget - ReaderOwned)
            SetFarmStatus("RESTOCK | Laptop " .. tostring(NeededLaptops) .. " | Reader " .. tostring(NeededReaders))
            local laptopOK = NeededLaptops == 0 or EnsureLaptopOwnedOrPlaced()
            local readerOK = NeededReaders == 0 or EnsureReaderOwnedOrPlaced()
            if laptopOK and readerOK then
                NextEquipmentRestockAt = 0
                if MainFarmEnabled then
                    ReturnToOwnedHouseNow()
                end
            end
        end
        task.wait(0.5)
        return false
    end

    DynamicFarmSpot = nil
    RefreshDynamicFarmSpot()
    ForceSolidPlatform()

    local StayHouse, OwnedUSB, ActiveUSB, ReadyUSB, WantedUSB =
        USBHousePhaseActive()

    if StayHouse then
        local House = GetMyHouse()

        if House and (ActiveUSB > 0 or ReadyUSB > 0) and #GetFarmLaptops() == 0 then
            MoveToOwnedHouseForUSB(House)
        end

        SetFarmStatus(
            "STAYING AT HOUSE | Have " ..
            tostring(OwnedUSB) .. "/" .. tostring(WantedUSB) ..
            " | Active " .. tostring(ActiveUSB) ..
            " | Ready " .. tostring(ReadyUSB)
        )

        task.wait(0.10)
        return true
    end

    local ReadyBeforeSell = {}
    local AnyExtractingBeforeSell = false

    for _, Entry in ipairs(GetFarmLaptops()) do
        if LaptopReady(Entry) then
            table.insert(ReadyBeforeSell, Entry)
        elseif LaptopExtracting(Entry) then
            AnyExtractingBeforeSell = true
        end
    end

    if #ReadyBeforeSell > 0 then
        SetFarmStatus("DUMP PRIORITY | Ready laptops: " .. tostring(#ReadyBeforeSell))

        for _, Entry in ipairs(ReadyBeforeSell) do
            if Entry.Model then
                BlankCardPromptSentLaptop[Entry.Model] = nil
                BlankCardDumpedLaptop[Entry.Model] = nil
            end
        end

        if not DumpWholeLaptopBatchTogether(ReadyBeforeSell) then
            task.wait(0.25)
            return false
        end

        for _, Entry in ipairs(GetFarmLaptops()) do
            if LaptopReady(Entry) then
                task.wait(0.2)
                return true
            end
        end
    end

    if AnyExtractingBeforeSell then
        SetFarmStatus("WAITING FOR LAPTOPS TO REACH DUMP CARD")
        task.wait(0.35)
        return true
    end

    local ExistingDumps = GetAllDumpTools()

    if #ExistingDumps >= BATCH_AMOUNT then
        SetFarmStatus(
            "DUMP TARGET READY: " ..
            tostring(#ExistingDumps) .. "/" ..
            tostring(BATCH_AMOUNT) .. " | GOING TO ATM"
        )

        local SoldOK = SellAllLoadedDumps()

        if #GetAllDumpTools() > 0 then
            SetFarmStatus(
                "LOADED DUMPS STILL PRESENT | continuing ATM #5 sale"
            )
            task.wait(0.25)
            return false
        end

        SetFarmStatus("ALL LOADED DUMPS SOLD | CHECKING HOUSE/LAPTOP")

        if CountToolsContaining("dump") <= 0 then
            local ExistingPlaced = #GetFarmLaptops()
            SetFarmStatus("POST SELL CHECK | placed laptop(s): " .. tostring(ExistingPlaced))
            ResetMainFarmForNextCycle()
        end

        task.wait(0.2)
        return SoldOK ~= false
    end

    if type(USBUsedLaptop) == "table" then
        for _, Entry in ipairs(GetFarmLaptops()) do
            if LaptopNeedsUSB(Entry) and Entry.Model then
                USBUsedLaptop[Entry.Model] = nil
            end
        end
    end

    local HandledUrgent, UrgentOK = HandleUrgentFarmWork()

    if HandledUrgent then
        return UrgentOK
    end

    local CurrentBusyLaptop = false

    for _, ExistingEntry in ipairs(GetFarmLaptops()) do
        if LaptopExtracting(ExistingEntry) or LaptopReady(ExistingEntry) then
            CurrentBusyLaptop = true
            break
        end
    end

    LaptopBatchInProgress = CurrentBusyLaptop

    local ResumeHouseWait, ResumeHouse = ResumeUSBWaitAtHouseIfNeeded()
    local ResumedUSBDelivery = ResumeHouseWait

    if ResumeHouseWait then
        if not WaitForUSBPackages(
            ResumeHouse,
            USBDeliveryPending
        ) then
            return false
        end

        SetFarmStatus("USB collected - continuing farm")
    end

    if not SellExistingDumpsBeforeCycle() then
        FarmNotify(
            "Main Farm",
            "Loaded dumps still detected - not starting a new batch yet.",
            3
        )
        task.wait(2)
        return false
    end

    local ExistingLaptops = GetFarmLaptops()
    local ExistingWork = {}

    for _, Entry in ipairs(ExistingLaptops) do
        if LaptopReady(Entry) or LaptopExtracting(Entry) then
            table.insert(ExistingWork, Entry)
        end
    end

    if #ExistingWork > 0 then
        SetFarmStatus("Existing laptop batch active - returning to farm")

        if not ReturnToFarmPlatformForBatch() then
            return false
        end

        local WholeExistingBatch = WaitUntilWholeLaptopBatchReady()
        if not WholeExistingBatch then
            return false
        end

        if not DumpWholeLaptopBatchTogether(WholeExistingBatch) then
            SetFarmStatus("Whole batch dump incomplete - NOT selling")
            return false
        end

        local LoadedNow = CountToolsContaining("dump")

        if LoadedNow >= BATCH_AMOUNT then
            SetFarmStatus(
                "DUMP BATCH READY " .. tostring(LoadedNow) ..
                "/" .. tostring(BATCH_AMOUNT) .. " - selling all"
            )
            SellAllLoadedDumps()
            task.wait(0.2)
        else
            SetFarmStatus(
                "BUILDING DUMP BATCH " .. tostring(LoadedNow) ..
                "/" .. tostring(BATCH_AMOUNT)
            )

            LaptopBatchInProgress = false
            USBUsedLaptop = setmetatable({}, {__mode = "k"})
            BlankCardDumpedLaptop = setmetatable({}, {__mode = "k"})
            BlankCardPromptSentLaptop = setmetatable({}, {__mode = "k"})
            USBCarryLimitHit = false
            USBDeliveryPending = 0
            USBDeliveryReadyAt = nil
            return true
        end

        local StillBusyAfterSale = false
        for _, CheckEntry in ipairs(GetFarmLaptops()) do
            if LaptopExtracting(CheckEntry) or LaptopReady(CheckEntry) then
                StillBusyAfterSale = true
                break
            end
        end

        if not StillBusyAfterSale and CountToolsContaining("dump") <= 0 then
            LaptopBatchInProgress = false
            USBUsedLaptop = setmetatable({}, {__mode = "k"})
            BlankCardDumpedLaptop = setmetatable({}, {__mode = "k"})
            BlankCardPromptSentLaptop = setmetatable({}, {__mode = "k"})
            USBDeliveryPending = 0
            USBDeliveryReadyAt = nil
        end

        return false
    end

    SetFarmStatus("Instant teleport inside house")
    ForceSolidPlatform()

    local Character, Humanoid, Root = GetCharacter()
    if not Character then
        return false
    end

    if Humanoid.Sit then
        if not (FindMyBike() and select(2, FindMyBike()) and select(2, FindMyBike()).Occupant == Humanoid) then
            Humanoid.Sit = false
        end
        task.wait(0.35)
    end

    if (Root.Position - RefreshDynamicFarmSpot()).Magnitude > 5 then
        if not SlowTweenCharacterToPlatform() then
            FarmNotify("Main Farm", "Could not teleport inside house.", 4)
            return false
        end
    end

    RecoverCharacterCamera()

    SetFarmStatus(
        "Place " .. tostring(LAPTOP_AMOUNT) ..
        " laptop(s) with Card Readers"
    )

    local Laptops = WaitForRequiredLaptops()

    if not Laptops or not MainFarmEnabled then
        return false
    end

    local ExistingLaptops = GetFarmLaptops()
    local ExistingReady = {}
    local ExistingExtracting = {}

    for _, Entry in ipairs(ExistingLaptops) do
        if LaptopReady(Entry) then
            table.insert(ExistingReady, Entry)
        elseif LaptopExtracting(Entry) then
            table.insert(ExistingExtracting, Entry)
        end
    end

    if #ExistingReady > 0 then
        SetFarmStatus(
            "PRIORITY: Dump Card laptops " ..
            tostring(#ExistingReady)
        )

        if not DumpWholeLaptopBatchTogether(ExistingReady) then
            return false
        end

        local LoadedAfterDump = CountToolsContaining("dump")

        if LoadedAfterDump >= BATCH_AMOUNT then
            SetFarmStatus(
                "DUMP TARGET READY " .. tostring(LoadedAfterDump) ..
                "/" .. tostring(BATCH_AMOUNT) .. " | SELLING ALL"
            )
            while MainFarmEnabled
                and CountToolsContaining("dump") >= BATCH_AMOUNT do
                SellAllLoadedDumps()
                task.wait(1)
            end
        else
            SetFarmStatus(
                "KEEPING DUMPS " .. tostring(LoadedAfterDump) ..
                "/" .. tostring(BATCH_AMOUNT) ..
                " | GOING BACK FOR " ..
                tostring(GetSelectedUSBTarget()) .. " MORE USB(s)"
            )

            LaptopBatchInProgress = false
            USBUsedLaptop = setmetatable({}, {__mode = "k"})
            BlankCardDumpedLaptop = setmetatable({}, {__mode = "k"})
            BlankCardPromptSentLaptop = setmetatable({}, {__mode = "k"})
            USBCarryLimitHit = false
            USBDeliveryPending = 0
            USBLastBuyAt = 0
            USBDeliveryReadyAt = nil
        end

        return true
    end

    if #ExistingExtracting > 0 then
        SetFarmStatus(
            "PRIORITY: Waiting for " ..
            tostring(#ExistingExtracting) ..
            " laptop(s) to reach Dump Card"
        )

        while MainFarmEnabled do
            local AnyExtracting = false
            local ReadyNow = {}

            for _, Entry in ipairs(GetFarmLaptops()) do
                if LaptopReady(Entry) then
                    table.insert(ReadyNow, Entry)
                elseif LaptopExtracting(Entry) then
                    AnyExtracting = true
                end
            end

            if #ReadyNow > 0 then
                if not DumpWholeLaptopBatchTogether(ReadyNow) then
                    return false
                end
                return true
            end

            if not AnyExtracting then
                break
            end

            task.wait(0.4)
        end
    end

    SetFarmStatus("Checking house")

    local House = GetMyHouse()

    if House then
        SetFarmStatus("House found - continuing to USB")
    else
        House = BuyHouseForFarm()
    end

    if not House or not MainFarmEnabled then
        return false
    end

    SetFarmStatus("House ready - checking USBs")

    SetFarmStatus(
        "SETUP READY | BUYING " ..
        tostring(GetSelectedUSBTarget()) ..
        " USB(s)"
    )

    SetFarmStatus(
        "Building USB batch at house | Target " ..
        tostring(GetUSBTargetAmount())
    )

    if not EnsureFiveUSBsCollected(House) then
        return false
    end

    if not MainFarmEnabled then
        return false
    end

    local FinalOwnedUSB, FinalActiveUSB, FinalReadyUSB = GetUSBSupplyState()
    local WantedUSB = GetSelectedUSBTarget()

    if FinalOwnedUSB < WantedUSB
        or FinalActiveUSB > 0
        or FinalReadyUSB > 0 then

        SetFarmStatus(
            "WAITING FOR FULL BATCH | Have " ..
            tostring(FinalOwnedUSB) .. "/" ..
            tostring(WantedUSB) ..
            " | Active " .. tostring(FinalActiveUSB) ..
            " | Ready " .. tostring(FinalReadyUSB)
        )

        HoldAtOwnedHouseTop(House)
        return false
    end

    SetFarmStatus(
        "FULL USB BATCH READY " .. tostring(FinalOwnedUSB) ..
        "/" .. tostring(WantedUSB) ..
        " - using on laptops now"
    )

    local Selected = GetSelectedLaptopBatch()
    local USBsUsedThisBatch = 0

    for _, Entry in ipairs(Selected) do
        if not MainFarmEnabled then return false end

        if CountToolsContaining("dump") > 0 then
            SetFarmStatus("Loaded dump detected - stopping USB use")
            break
        end

        if LaptopNeedsUSB(Entry) then
            if CountToolsContaining("usb") <= 0 then
                SetFarmStatus("Waiting for remaining USBs")
                return false
            end

            local USBWorked = false

            if type(UseUSBOnFarmLaptop) == "function" then
                local OK, Result = pcall(UseUSBOnFarmLaptop, Entry)

                if OK then
                    USBWorked = Result == true
                else
                    SetFarmStatus(
                        "USB laptop error recovered: " ..
                        tostring(Result)
                    )
                end
            else
                SetFarmStatus("USB function missing - skipping safely")
            end

            if USBWorked then
                LaptopBatchInProgress = true

                task.wait(0.15)

                local USBCount = 0
                local Character = LocalPlayer.Character
                local Backpack = LocalPlayer:FindFirstChild("Backpack")

                local function CountUSBs(Container)
                    if not Container then return end

                    for _, Item in ipairs(Container:GetChildren()) do
                        if Item:IsA("Tool")
                            and string.find(
                                string.lower(tostring(Item.Name)),
                                "usb",
                                1,
                                true
                            ) then
                            USBCount += 1
                        end
                    end
                end

                CountUSBs(Character)
                CountUSBs(Backpack)

                if USBCount < 5 then
                    USBCarryLimitHit = false
                end
            end

            task.wait(0.5)
        end
    end

    if not ReturnToFarmPlatformForBatch() then
        return false
    end

    if not ReturnToFarmPlatformForBatch() then
        return false
    end

    local WholeBatch = WaitUntilWholeLaptopBatchReady()
    if not WholeBatch then
        return false
    end

    SetFarmStatus(
        "All " .. tostring(#WholeBatch) ..
        " laptops ready - dumping whole batch"
    )

    if not DumpWholeLaptopBatchTogether(WholeBatch) then

        SetFarmStatus("Batch dump incomplete - NOT selling")
        ReturnToFarmPlatformForBatch()
        return false
    end

    for _, Entry in ipairs(GetSelectedLaptopBatch()) do
        if LaptopExtracting(Entry) or LaptopReady(Entry) then
            SetFarmStatus("Laptop work remains - NOT selling")
            ReturnToFarmPlatformForBatch()
            return false
        end
    end

    local LoadedForBatch = CountToolsContaining("dump")

    if LoadedForBatch >= BATCH_AMOUNT then
        SetFarmStatus(
            "DUMP TARGET READY " .. tostring(LoadedForBatch) ..
            "/" .. tostring(BATCH_AMOUNT) .. " | SELLING ALL"
        )

        while MainFarmEnabled and CountToolsContaining("dump") > 0 do
            SellAllLoadedDumps()
            task.wait(1)
        end
    else
        SetFarmStatus(
            "KEEPING DUMPS " .. tostring(LoadedForBatch) ..
            "/" .. tostring(BATCH_AMOUNT) ..
            " | NEXT USB BATCH: " ..
            tostring(GetSelectedUSBTarget())
        )

        LaptopBatchInProgress = false
        BlankCardDumpedLaptop = setmetatable({}, {__mode = "k"})
        BlankCardPromptSentLaptop = setmetatable({}, {__mode = "k"})
        USBUsedLaptop = setmetatable({}, {__mode = "k"})
        USBCarryLimitHit = false
        USBDeliveryPending = 0
        USBLastBuyAt = 0
        USBDeliveryReadyAt = nil
        return true
    end

    if CountToolsContaining("dump") <= 0 then
        LaptopBatchInProgress = false
        BlankCardDumpedLaptop = setmetatable({}, {__mode = "k"})
            BlankCardPromptSentLaptop = setmetatable({}, {__mode = "k"})
        USBDeliveryPending = 0
        USBDeliveryReadyAt = nil
        USBUsedLaptop = setmetatable({}, {__mode = "k"})
    end

    local RemainingDumps = CountToolsContaining("dump")

    if RemainingDumps > 0 then
        SetFarmStatus(
            "Waiting to sell remaining dumps: " ..
            tostring(RemainingDumps)
        )
        return false
    end

    SetFarmStatus("Cycle complete - all dumps sold")
    return true
end

function SmoothSurfaceFromUnderground()
    local Character, Humanoid, Root = GetCharacter()
    if not Character then return false end

    RemoveTravelFloor()

    if Humanoid.Sit then
        if not (FindMyBike() and select(2, FindMyBike()) and select(2, FindMyBike()).Occupant == Humanoid) then
            Humanoid.Sit = false
        end
        task.wait(0.2)
    end

    local Start = Root.Position
    local Target = Vector3.new(Start.X, FARM_SURFACE_Y + 3, Start.Z)
    local Distance = (Target - Start).Magnitude

    if Distance <= 1 then
        return true
    end

    local Duration = math.clamp(Distance / 18, 0.5, 4)
    local Started = os.clock()

    while os.clock() - Started < Duration do
        local Alpha = math.clamp((os.clock() - Started) / Duration, 0, 1)
        local Smooth = Alpha * Alpha * (3 - 2 * Alpha)
        local Position = Start:Lerp(Target, Smooth)

        Root.AssemblyLinearVelocity = Vector3.zero
        Root.AssemblyAngularVelocity = Vector3.zero
        TweenRootCFrame(CFrame.new(Position))
        task.wait()
    end

    Root.AssemblyLinearVelocity = Vector3.zero
    Root.AssemblyAngularVelocity = Vector3.zero
    TweenRootCFrame(CFrame.new(Target))
    RecoverCharacterCamera()
    return true
end

function StopFarmPositionRecovery()
    local Character, Humanoid, Root = GetCharacter()
    if not Character then return end

    RemoveTravelFloor()

    local FarmSpot = RefreshDynamicFarmSpot()
        or _G.CosmosOwnedHouseFarmSpot

    local DistanceToFarm = math.huge

    if Root and FarmSpot then
        DistanceToFarm = (Root.Position - FarmSpot).Magnitude
    end

    if DistanceToFarm <= 12 then
        SetFarmStatus("Stopped inside house")
        RecoverCharacterCamera()
        return
    end

    SetFarmStatus("Stopped")
    RecoverCharacterCamera()
end


local function CheckFarmPurchaseTargets()
    local wantedUSB = GetSelectedUSBTarget()
    local ownedUSB, activeUSB, readyUSB, totalUSB = GetUSBSupplyState()
    AuditPurchase("USB", totalUSB >= wantedUSB and "already_sufficient" or "missing", ownedUSB, wantedUSB)
    local wantedLaptop = math.clamp(math.floor(tonumber(LAPTOP_AMOUNT) or 1), 1, 5)
    local ownedLaptop = GetLaptopSupplyCount()
    AuditPurchase("Laptop", ownedLaptop >= wantedLaptop and "already_sufficient" or "missing", ownedLaptop, wantedLaptop)
    local ownedReader = GetReaderSupplyCount()
    AuditPurchase("Card Reader", ownedReader >= wantedLaptop and "already_sufficient" or "missing", ownedReader, wantedLaptop)
    return totalUSB >= wantedUSB, ownedLaptop >= wantedLaptop, ownedReader >= wantedLaptop
end

function MainFarmLoop()
    if MainFarmEnabled then
        SetFarmStatus("BIKE | getting or buying bike first")
        SitOnOwnedBike()
    end
    if MainFarmBusy then return end
    MainFarmBusy = true

    while MainFarmEnabled do
        local OK, Error = pcall(function()
            CheckFarmPurchaseTargets()
            RunMainFarmCycle()
        end)

        if not OK then
            warn("[Main Farm]",Error)
            FarmNotify("Main Farm Error",tostring(Error),5)
        end

        if MainFarmEnabled then

            task.wait(0.25)
        end
    end

    MainFarmBusy = false
end

local MainFarmSection: any = CardSwipeSubPage:Section({Name = "Card Farm", Side = 1})
local InfoSection: any = CardSwipeSubPage:Section({Name = "Info", Side = 2})

local InfoLabels = {
    "Must Own A Bike",
    "Once you do start Farm",
    "Everything is auto,",
    "Bike can Sometimes Break"
}
for _, Message in ipairs(InfoLabels) do
    InfoSection:Label({Name = Message})
end

local function AddCardControl(Kind, Options)
    local Method = MainFarmSection[Kind]
    if type(Method) ~= "function" then
        warn("Solstices UI missing control: " .. Kind)
        return
    end
    local Success, Error = pcall(function()
        Method(MainFarmSection, Options)
    end)
    if not Success then
        warn("Solstices Card Farm " .. Kind .. ": " .. tostring(Error))
    end
end

AddCardControl("Toggle", {
    Name = "Main Farm",
    Flag = "main_farm",
    Default = false,
    Callback = function(Value)
        MainFarmEnabled = Value
        AutoCardEnabled = Value
        GoToSpotEnabled = Value
        if Value then
            local activeOrders, readyOrders = CountDeliveryGUI()
            if activeOrders == 0 and readyOrders == 0 then
                USBDeliveryPending = 0
                USBDeliveryReadyAt = nil
            end
            CheckFarmPurchaseTargets()
            SetFarmStatus("Starting")
            if not MainFarmBusy then task.spawn(MainFarmLoop) end
        else
            MainFarmEnabled = false
            PendingFarmRespawnReturn = false
            AutoCardEnabled = false
            GoToSpotEnabled = false
            SetFarmStatus("Stopped")
            FarmNotify("Main Farm", "Stopped.", 2)
        end
    end
})

AddCardControl("Slider", {
    Name = "USB Amount",
    Flag = "usb_amount",
    Min = 1,
    Max = 5,
    Default = 2,
    Callback = function(Value)
        USB_AMOUNT = math.clamp(math.floor(tonumber(Value) or 2), 1, 5)
        USB_TARGET_SETTING = USB_AMOUNT
        USBPurchaseCycleTarget = USB_AMOUNT
        getgenv().CosmosFarmSettings = getgenv().CosmosFarmSettings or {}
        getgenv().CosmosFarmSettings.USB_AMOUNT = USB_AMOUNT
        USBDeliveryPending = math.min(USB_AMOUNT, math.max(0, tonumber(USBDeliveryPending) or 0))
        USBLastBuyAt = 0
    end
})

AddCardControl("Slider", {
    Name = "Batch Amount",
    Flag = "batch_amount",
    Min = 1,
    Max = 50,
    Default = 5,
    Callback = function(Value)
        BATCH_AMOUNT = math.clamp(math.floor(tonumber(Value) or 5), 1, 50)
        getgenv().CosmosFarmSettings = getgenv().CosmosFarmSettings or {}
        getgenv().CosmosFarmSettings.BATCH_AMOUNT = BATCH_AMOUNT
    end
})

AddCardControl("Slider", {
    Name = "Laptop",
    Flag = "laptop_amount",
    Min = 1,
    Max = 5,
    Default = 1,
    Callback = function(Value)
        LAPTOP_AMOUNT = math.clamp(math.floor(tonumber(Value) or 1), 1, 5)
        getgenv().CosmosFarmSettings = getgenv().CosmosFarmSettings or {}
        getgenv().CosmosFarmSettings.LAPTOP_AMOUNT = LAPTOP_AMOUNT
        NextEquipmentRestockAt = 0
    end
})
