-- ============================================
-- MascatHub - Defense Tab (OrionUI Version)
-- ============================================

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera
local Player = Players.LocalPlayer
local RS = ReplicatedStorage
local R = RunService

-- ============================================
-- Window
-- ============================================
local Window = OrionLib:MakeWindow({
    Name = "MascatHub",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "MascatHub_Defense",
    IntroEnabled = true,
    IntroText = "MascatHub Defense Loaded"
})

-- ============================================
-- Main Tab
-- ============================================
local DefenseTab = Window:MakeTab({
    Name = "Defense",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- ============================================
-- Helper Functions
-- ============================================
local function notify(title, content, duration)
    OrionLib:MakeNotification({
        Name = title or "MascatHub",
        Content = content or "",
        Image = "rbxassetid://4483345998",
        Time = duration or 5
    })
end

local function FWC(Parent, Name, Time)
    return Parent:FindFirstChild(Name) or Parent:WaitForChild(Name, Time or 3)
end

local function getBlobman()
    local folder = Workspace:FindFirstChild(Player.Name .. "SpawnedInToys")
    if folder then
        return folder:FindFirstChild("CreatureBlobman")
    end
    return nil
end

local function spawnBlobman()
    local char = Player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    pcall(function()
        RS.MenuToys.SpawnToyRemoteFunction:InvokeServer(
            "CreatureBlobman",
            CFrame.new(0, 5000000, 0),
            Vector3.new(0, 60, 0)
        )
    end)
end

local function destroyBlobman()
    local folder = Workspace:FindFirstChild(Player.Name .. "SpawnedInToys")
    if folder and folder:FindFirstChild("CreatureBlobman") then
        local blob = folder.CreatureBlobman
        pcall(function()
            RS.MenuToys.DestroyToy:FireServer(blob)
        end)
        task.wait(0.1)
        if blob and blob.Parent then
            blob:Destroy()
        end
    end
end

-- ============================================
-- Section: Main Defense
-- ============================================
local MainSection = DefenseTab:AddSection({
    Name = "Main Defense"
})

-- Anti Grab Best
MainSection:AddToggle({
    Name = "Anti Grab Best (use solo)",
    Default = false,
    Callback = function(Value)
        _G.AntiGrab = Value
        if Value then
            task.spawn(function()
                local char = Player.Character or Player.CharacterAdded:Wait()
                local hrp = char:WaitForChild("HumanoidRootPart")
                local hum = char:WaitForChild("Humanoid")
                local head = char:WaitForChild("Head")
                local BeingHeld = Player:WaitForChild("IsHeld")
                local StruggleEvent = RS:WaitForChild("CharacterEvents"):WaitForChild("Struggle")
                local AntiGrabProc = false
                local AGWalk = false
                
                while _G.AntiGrab do
                    if head:FindFirstChild("PartOwner") or BeingHeld.Value then
                        if not AntiGrabProc then
                            AntiGrabProc = true
                            hum.Sit = false
                            StruggleEvent:FireServer(Player)
                            
                            task.spawn(function()
                                while (head:FindFirstChild("PartOwner") or BeingHeld.Value) and _G.AntiGrab do
                                    StruggleEvent:FireServer(Player)
                                    RS.CharacterEvents.RagdollRemote:FireServer(hrp, 0)
                                    task.wait()
                                end
                            end)
                            
                            hrp.Anchored = true
                            if not AGWalk then
                                AGWalk = true
                                while BeingHeld.Value and _G.AntiGrab do
                                    hrp.CFrame = hrp.CFrame + hum.MoveDirection * 0.43
                                    task.wait()
                                end
                            end
                            hrp.Anchored = false
                            AntiGrabProc = false
                            AGWalk = false
                        end
                    end
                    task.wait()
                end
            end)
        end
    end
})

-- Anti Grab V2
MainSection:AddToggle({
    Name = "Anti Grab V2 (anti perm die)",
    Default = false,
    Callback = function(Value)
        _G.AntiGrabV2 = Value
        if Value then
            task.spawn(function()
                local BeingHeld = Player:WaitForChild("IsHeld")
                local StruggleEvent = RS:WaitForChild("CharacterEvents"):WaitForChild("Struggle")
                
                while _G.AntiGrabV2 do
                    if BeingHeld.Value then
                        local char = Player.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        local hum = char and char:FindFirstChildOfClass("Humanoid")
                        
                        if hrp and hum then
                            hrp.Anchored = true
                            hum.Sit = false
                            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                            hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
                            
                            task.spawn(function()
                                while BeingHeld.Value and _G.AntiGrabV2 do
                                    pcall(function()
                                        StruggleEvent:FireServer()
                                        RS.CharacterEvents.RagdollRemote:FireServer(hrp, 0)
                                        RS.GameCorrectionEvents.StopAllVelocity:FireServer()
                                    end)
                                    task.wait()
                                end
                                if hrp then hrp.Anchored = false end
                            end)
                        end
                    end
                    task.wait()
                end
            end)
        end
    end
})

-- Anti Banana Sit
MainSection:AddToggle({
    Name = "Anti Banana Sit",
    Default = false,
    Callback = function(Value)
        _G.AntiBananaSit = Value
        task.spawn(function()
            while _G.AntiBananaSit do
                local char = Player.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hum and hrp and hum.Health > 0 then
                        hum.Sit = true
                        hum:ChangeState(Enum.HumanoidStateType.Running)
                        local Vec = Camera.CFrame.LookVector
                        hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(Vec.X, 0, Vec.Z))
                    end
                end
                task.wait()
            end
        end)
    end
})

-- Anti Ragdoll On Blob
MainSection:AddToggle({
    Name = "Anti Ragdoll On Blob",
    Default = false,
    Callback = function(Value)
        _G.AntiRagdoll = Value
        if Value then
            task.spawn(function()
                local char = Player.Character or Player.CharacterAdded:Wait()
                local hum = char:WaitForChild("Humanoid")
                local hrp = char:WaitForChild("HumanoidRootPart")
                local RagdolledSit = false
                
                hum:GetPropertyChangedSignal("SeatPart"):Connect(function()
                    if hum.SeatPart and hum.SeatPart.Parent and hum.SeatPart.Parent.Name == "CreatureBlobman" and not RagdolledSit then
                        RagdolledSit = true
                        local Seat = hum.SeatPart
                        while not hum.Sit do task.wait() end
                        RS.CharacterEvents.RagdollRemote:FireServer(hrp, 3)
                        task.wait(0.4)
                        hum.Sit = false
                        Seat:Sit(hum)
                        task.delay(0.25, function()
                            while hum and hum.SeatPart do
                                RS.CharacterEvents.RagdollRemote:FireServer(hrp, 1)
                                task.wait(0.05)
                            end
                            RagdolledSit = false
                        end)
                    end
                end)
            end)
        end
    end
})

-- Anti Snowball
MainSection:AddToggle({
    Name = "Anti Snowball",
    Default = false,
    Callback = function(Value)
        _G.LoopRagdoll = Value
        task.spawn(function()
            while _G.LoopRagdoll do
                pcall(function()
                    local char = Player.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        RS.CharacterEvents.RagdollRemote:FireServer(hrp, 0.5)
                    end
                end)
                task.wait(0.05)
            end
        end)
    end
})

-- ============================================
-- Section: Auto Reset / Leave
-- ============================================
local AutoSection = DefenseTab:AddSection({
    Name = "Auto Reset / Leave"
})

-- Auto Reset
AutoSection:AddToggle({
    Name = "Auto Reset",
    Default = false,
    Callback = function(Value)
        _G.AutoReset = Value
        if _G.AutoResetCon then _G.AutoResetCon:Disconnect() end
        
        if Value then
            _G.AutoResetCon = RS.GameCorrectionEvents.GameCorrectionsNotify.OnClientEvent:Connect(function(r)
                if r == "Flying" then
                    local char = Player.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        notify("MascatHub", "Resetting to prevent Ban", 4)
                        char:BreakJoints()
                        hum.Health = 0
                    end
                end
            end)
        end
    end
})

-- Auto Leave
AutoSection:AddToggle({
    Name = "Auto Leave",
    Default = false,
    Callback = function(Value)
        _G.AutoLeave = Value
        if _G.AutoLeaveCon then _G.AutoLeaveCon:Disconnect() end
        
        if Value then
            local warnTimestamps = {}
            _G.AutoLeaveCon = RS.GameCorrectionEvents.GameCorrectionsNotify.OnClientEvent:Connect(function(r)
                if r == "Flying" then
                    local currentTime = os.clock()
                    table.insert(warnTimestamps, currentTime)
                    for i = #warnTimestamps, 1, -1 do
                        if currentTime - warnTimestamps[i] > 1 then
                            table.remove(warnTimestamps, i)
                        end
                    end
                    if #warnTimestamps >= 3 then
                        Player:Kick("MascatHub Safety: Disconnected to prevent ban.")
                    end
                end
            end)
        end
    end
})

-- ============================================
-- Section: Anti Blob
-- ============================================
local BlobSection = DefenseTab:AddSection({
    Name = "Anti Blob"
})

-- Anti Blob
BlobSection:AddToggle({
    Name = "Anti Blob",
    Default = false,
    Callback = function(Value)
        _G.AntiBlob = Value
        task.spawn(function()
            while _G.AntiBlob do
                local char = Player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if char and hrp then
                    if not char:FindFirstChild("TruePositionPart") then
                        local truePosPart = Instance.new("Part")
                        truePosPart.Name = "TruePositionPart"
                        truePosPart.Anchored = true
                        truePosPart.Transparency = 0.8
                        truePosPart.CanCollide = false
                        truePosPart.Size = Vector3.new(0.1, 0.1, 0.1)
                        truePosPart.CFrame = CFrame.new(0, -10000000, 0)
                        truePosPart.Parent = char
                    end
                    
                    local truePosPart = char:FindFirstChild("TruePositionPart")
                    if truePosPart then
                        local rootAttachment = hrp:FindFirstChild("RootAttachment")
                        if rootAttachment then
                            rootAttachment.Parent = truePosPart
                        end
                        
                        local isGrabbed = false
                        for _, part in pairs(char:GetChildren()) do
                            if part:IsA("Part") and part.Massless then
                                part.Massless = false
                                isGrabbed = true
                            end
                        end
                        
                        if isGrabbed then
                            hrp.AssemblyLinearVelocity = Vector3.new(0, 15000000, 0)
                            
                            local function fireDrop(item)
                                local blobScript = item:FindFirstChild("BlobmanSeatAndOwnerScript")
                                local rightDetector = item:FindFirstChild("RightDetector")
                                local leftDetector = item:FindFirstChild("LeftDetector")
                                if blobScript and rightDetector and leftDetector then
                                    local dropEvent = blobScript:FindFirstChild("CreatureDrop")
                                    if dropEvent then
                                        pcall(function()
                                            dropEvent:FireServer(rightDetector:FindFirstChild("RightWeld"), hrp)
                                            dropEvent:FireServer(leftDetector:FindFirstChild("LeftWeld"), hrp)
                                        end)
                                    end
                                    local struggle = RS.CharacterEvents:FindFirstChild("Struggle")
                                    if struggle then struggle:FireServer(Player) end
                                end
                            end
                            
                            for _, plot in pairs(Workspace.PlotItems:GetChildren()) do
                                if plot.Name ~= "PlayersInPlots" then
                                    for _, item in pairs(plot:GetChildren()) do
                                        if item.Name == "CreatureBlobman" then fireDrop(item) end
                                    end
                                end
                            end
                            
                            for _, plr in pairs(Players:GetPlayers()) do
                                local toyFolder = Workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
                                if toyFolder then
                                    for _, item in pairs(toyFolder:GetChildren()) do
                                        if item.Name == "CreatureBlobman" then fireDrop(item) end
                                    end
                                end
                            end
                        end
                    end
                end
                task.wait()
            end
        end)
    end
})

-- Anti-Blobman Aura
BlobSection:AddToggle({
    Name = "Anti-Blobman Aura",
    Default = false,
    Callback = function(Value)
        _G.AntiBlobAura = Value
        if _G.AntiBlobAuraConn then _G.AntiBlobAuraConn:Disconnect() end
        
        if Value then
            _G.AntiBlobAuraConn = R.Heartbeat:Connect(function()
                local myChar = Player.Character
                local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                if not myRoot then return end
                
                for _, plr in pairs(Players:GetPlayers()) do
                    if plr ~= Player then
                        local pChar = plr.Character
                        local pRoot = pChar and pChar:FindFirstChild("HumanoidRootPart")
                        local pHum = pChar and pChar:FindFirstChildOfClass("Humanoid")
                        
                        if pRoot and pHum and pHum.SeatPart then
                            local seatParent = pHum.SeatPart.Parent
                            if seatParent and seatParent.Name == "CreatureBlobman" then
                                if (pRoot.Position - myRoot.Position).Magnitude <= 19 then
                                    pcall(function()
                                        RS.GrabEvents.SetNetworkOwner:FireServer(pRoot, pRoot.CFrame)
                                    end)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
})

-- Blobman Spawn Button
BlobSection:AddButton({
    Name = "Spawn Blobman",
    Callback = function()
        spawnBlobman()
        notify("MascatHub", "Blobman spawned", 3)
    end
})

-- Blobman Destroy Button
BlobSection:AddButton({
    Name = "Destroy Blobman",
    Callback = function()
        destroyBlobman()
        notify("MascatHub", "Blobman destroyed", 3)
    end
})

-- ============================================
-- Section: Extra Defense
-- ============================================
local ExtraSection = DefenseTab:AddSection({
    Name = "Extra Defense"
})

-- Anti Explosion
ExtraSection:AddToggle({
    Name = "Anti Explosion",
    Default = false,
    Callback = function(Value)
        _G.AntiExplosion = Value
        if Value then
            task.spawn(function()
                local char = Player.Character
                local hrp = char and char:WaitForChild("HumanoidRootPart")
                if not hrp then return end
                
                Workspace.ChildAdded:Connect(function(model)
                    if model.Name == "Part" and _G.AntiExplosion then
                        local mag = (model.Position - hrp.Position).Magnitude
                        if mag <= 20 then
                            hrp.Anchored = true
                            task.wait(0.01)
                            local arm = char:FindFirstChild("Right Arm")
                            if arm and arm:FindFirstChild("RagdollLimbPart") then
                                while arm.RagdollLimbPart.CanCollide do
                                    task.wait(0.001)
                                end
                            end
                            hrp.Anchored = false
                        end
                    end
                end)
            end)
        end
    end
})

-- Anti Burn
ExtraSection:AddToggle({
    Name = "Anti Burn",
    Default = false,
    Callback = function(Value)
        _G.AntiBurn = Value
        if Value then
            local char = Player.Character or Player.CharacterAdded:Wait()
            local hum = char:WaitForChild("Humanoid")
            local hrp = char:WaitForChild("HumanoidRootPart")
            
            hum.FireDebounce.Changed:Connect(function(isBurning)
                if isBurning and _G.AntiBurn then
                    local oldCF = hrp.CFrame
                    local plots = Workspace:FindFirstChild("Plots")
                    if plots and plots:FindFirstChild("Plot2") then
                        local barrier = plots.Plot2:FindFirstChild("Barrier")
                        local pb = barrier and barrier:FindFirstChild("PlotBarrier")
                        if pb and pb:IsA("BasePart") then
                            char:SetPrimaryPartCFrame(pb.CFrame * CFrame.new(0, 6, 0))
                            task.wait(0.3)
                            local firePart = char:FindFirstChild("FirePlayerPart", true)
                            if firePart then
                                for _, obj in ipairs(firePart:GetChildren()) do
                                    if obj:IsA("Sound") then obj:Stop() end
                                    if obj:IsA("Light") or obj:IsA("ParticleEmitter") then
                                        obj.Enabled = false
                                    end
                                end
                                if firePart:FindFirstChild("CanBurn") then
                                    firePart.CanBurn.Value = false
                                end
                            end
                            if hum:FindFirstChild("FireDebounce") then
                                hum.FireDebounce.Value = false
                            end
                            task.wait(0.6)
                            char:SetPrimaryPartCFrame(oldCF)
                        end
                    end
                end
            end)
        end
    end
})

-- Anti Sticky
ExtraSection:AddToggle({
    Name = "Anti Sticky",
    Default = false,
    Callback = function(Value)
        _G.AntiSticky = Value
        if Player.PlayerScripts:FindFirstChild("StickyPartsTouchDetection") then
            Player.PlayerScripts.StickyPartsTouchDetection.Disabled = Value
        end
    end
})

-- Anti Loop Kill
ExtraSection:AddToggle({
    Name = "Anti Loop Kill",
    Default = false,
    Callback = function(Value)
        _G.AntiLoopKill = Value
        if _G.AntiLoopKillCon then _G.AntiLoopKillCon:Disconnect() end
        
        if Value then
            _G.AntiLoopKillCon = Player.CharacterAdded:Connect(function(char)
                local hrp = char:WaitForChild("HumanoidRootPart", 5)
                if hrp then
                    R.RenderStepped:Wait()
                    local target = CFrame.new(524.703979, 93.7120056, -375.040985)
                    hrp.CFrame = target
                    for i = 1, 2 do
                        R.RenderStepped:Wait()
                        hrp.CFrame = target
                    end
                end
            end)
        end
    end
})

-- Anti Lag
ExtraSection:AddToggle({
    Name = "Anti Lag",
    Default = false,
    Callback = function(Value)
        _G.AntiLag = Value
        if Value then
            local grabFolder = RS:FindFirstChild("GrabEvents")
            if grabFolder then
                local createLine = grabFolder:FindFirstChild("CreateGrabLine")
                local extendLine = grabFolder:FindFirstChild("ExtendGrabLine")
                if createLine then createLine:Destroy() end
                if extendLine then extendLine:Destroy() end
            end
        end
    end
})

-- ============================================
-- Section: Anti Paint
-- ============================================
local PaintSection = DefenseTab:AddSection({
    Name = "Anti Paint"
})

-- Anti Paint
PaintSection:AddToggle({
    Name = "Anti Paint",
    Default = false,
    Callback = function(Value)
        _G.AntiPaint = Value
        if Value then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name == "PaintPlayerPart" then
                    obj:Destroy()
                end
            end
            
            if _G.PaintWatcher then _G.PaintWatcher:Disconnect() end
            _G.PaintWatcher = Workspace.DescendantAdded:Connect(function(obj)
                if obj:IsA("BasePart") and obj.Name == "PaintPlayerPart" and _G.AntiPaint then
                    obj:Destroy()
                end
            end)
            
            local char = Player.Character
            if char then
                for _, v in pairs(char:GetChildren()) do
                    if v:IsA("Part") or v:IsA("BasePart") then
                        v.CanTouch = false
                        v.CanQuery = false
                    end
                end
            end
        elseif _G.PaintWatcher then
            _G.PaintWatcher:Disconnect()
        end
    end
})

-- ============================================
-- Section: Platform TP
-- ============================================
local PlatformSection = DefenseTab:AddSection({
    Name = "Platform TP"
})

local platformPart = nil

PlatformSection:AddToggle({
    Name = "Enable Platform TP",
    Default = false,
    Callback = function(Value)
        _G.PlatformTPToggle = Value
        if Value then
            if not platformPart then
                platformPart = Instance.new("Part", Workspace)
                platformPart.Name = "SkyBase"
                platformPart.Anchored = true
                platformPart.Size = Vector3.new(1500, 2, 1500)
                platformPart.CFrame = CFrame.new(0, 1000000, 0)
                Workspace.FallenPartsDestroyHeight = -9999999
            end
        else
            _G.PlatformTPActive = false
        end
    end
})

PlatformSection:AddButton({
    Name = "Platform TP Execute (Press X)",
    Callback = function()
        if not _G.PlatformTPToggle then return end
        local char = Player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        _G.PlatformTPActive = not _G.PlatformTPActive
        if _G.PlatformTPActive then
            _G.OldPlatformPos = root.CFrame
            root.CFrame = platformPart.CFrame + Vector3.new(0, 5, 0)
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        elseif _G.OldPlatformPos then
            root.CFrame = _G.OldPlatformPos
        end
    end
})

-- ============================================
-- Section: Gucci
-- ============================================
local GucciSection = DefenseTab:AddSection({
    Name = "Gucci"
})

-- Gucci Binder
local gucciRunId = 0

local function toy_spawn_gucci(name, cframe, vector)
    local ToySpawn = RS.MenuToys.SpawnToyRemoteFunction
    local InPlot, InOwnerPlot, CanSpawn = Player.InPlot, Player.InOwnedPlot, Player.CanSpawnToy

    while InPlot.Value and not InOwnerPlot.Value and not CanSpawn.Value do
        task.wait(0.01)
    end

    task.spawn(function()
        ToySpawn:InvokeServer(name, cframe, vector or Vector3.new())
    end)
    
    local BackPack = Workspace:FindFirstChild(Player.Name .. 'SpawnedInToys')
    local SpawnedToy
    if BackPack then
        BackPack.ChildAdded:Once(function(toy)
            if toy.Name == name and toy:IsA("Model") then
                SpawnedToy = toy
            end
        end)
    end
    
    local time = tick()
    while not SpawnedToy do
        if tick()-time < 2 then
            task.wait(0.01)
        else
            return false
        end
    end
    return SpawnedToy
end

local function GucciAntiGrab()
    gucciRunId = gucciRunId + 1
    local MyId = gucciRunId
    
    local char = Player.Character or Player.CharacterAdded:Wait()
    local hum = FWC(char, "Humanoid")
    
    hum.Sit = true
    task.wait(0.02)
    hum.Sit = false
    task.wait(0.02)
    
    task.spawn(function()
        local time = tick()
        while tick()-time < 0.8 do
            for _,v in pairs(char:GetChildren()) do
                if v:IsA('BasePart') then
                    v.Velocity = Vector3.new()
                end
            end
            task.wait(0.01)
        end
    end)
    
    local autoGucciT, sitJumpT, Blob, BHead = true, false, nil, nil
    
    task.spawn(function()
        while not Blob and MyId == gucciRunId do
            task.wait(0.01)
        end
        if MyId ~= gucciRunId then return end
        
        BHead = FWC(Blob, "Head")
        local HitBox = FWC(Blob, "GrabbableHitbox")
        
        while MyId == gucciRunId and BHead and
        (not BHead:FindFirstChild("PartOwner") or BHead.PartOwner.Value ~= Player.Name) do
            pcall(function()
                RS.GrabEvents.SetNetworkOwner:FireServer(HitBox, HitBox.CFrame)
            end)
            task.wait(0.01)
        end
    end)
    
    local hrp = FWC(char, "HumanoidRootPart")
    Blob = toy_spawn_gucci(
        "CreatureBlobman",
        hrp.CFrame * CFrame.new(0, 0, -5),
        Vector3.new(0, -15.716, 0)
    )
    
    if not Blob then return end
    
    local Seat = FWC(Blob, "VehicleSeat")
    
    task.defer(function()
        if not(char or hum) then return end
        
        local startTime = tick()
        while autoGucciT and MyId == gucciRunId and tick()-startTime < 0.3 do
            if Blob and Blob.Parent then
                if Seat and Seat.Parent and Seat.Occupant ~= hum then
                    Seat:Sit(hum)
                end
            end
            task.wait(0.03)
            if char and hum and hum.Parent then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
            task.wait(0.03)
        end
        autoGucciT = false
        sitJumpT = false
    end)
    
    sitJumpT = true
    
    task.defer(function()
        while sitJumpT and MyId == gucciRunId do
            if char and hrp and hrp.Parent then
                RS.CharacterEvents.RagdollRemote:FireServer(hrp, 0.095)
            end
            task.wait(0.01)
        end
    end)
    
    task.wait(0.4)
    if MyId ~= gucciRunId then return end
    
    hum.Sit = false
    if Blob then
        Blob.Name = "Gucci"
    end
    
    local BackPack = Workspace:FindFirstChild(Player.Name .. 'SpawnedInToys')
    local index
    if BackPack then
        for i,v in pairs(BackPack:GetChildren()) do
            if v.Name == "Gucci" then
                index = i
                break
            end
        end
    end
    
    if Blob then
        for _,v in pairs(Blob:GetChildren()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
                v.CanTouch = false
                v.CanQuery = false
            end
        end
    end
    
    task.defer(function()
        while MyId == gucciRunId and Blob and BHead do
            BHead.CFrame = CFrame.new(BHead.Position.X, 1e5, BHead.Position.Z)
            task.wait(0.01)
        end
    end)
    
    notify("MascatHub", "Gucci Binder Activated", 3)
end

GucciSection:AddButton({
    Name = "Gucci Binder (Press J)",
    Callback = function()
        GucciAntiGrab()
    end
})

-- Anti Gucci Blobman
GucciSection:AddToggle({
    Name = "Anti Gucci Blobman",
    Default = false,
    Callback = function(Value)
        _G.AntiGucciBlob = Value
        
        local function stopAntiGucci()
            if _G.AntiGucciBlobCon then
                _G.AntiGucciBlobCon:Disconnect()
                _G.AntiGucciBlobCon = nil
            end
            local char = Player.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if hum then
                hum.Sit = false
                pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
            end
            destroyBlobman()
        end
        
        local function startAntiGucci()
            local char = Player.Character or Player.CharacterAdded:Wait()
            local hum = char:WaitForChild("Humanoid")
            local hrp = char:WaitForChild("HumanoidRootPart")
            local safePosition = hrp.Position
            local restoreFrames = 0
            
            spawnBlobman()
            
            local folder = Workspace:FindFirstChild(Player.Name .. "SpawnedInToys")
            local blob = folder and folder:FindFirstChild("CreatureBlobman")
            local seat = blob and blob:FindFirstChild("VehicleSeat")
            
            if seat and seat:IsA("VehicleSeat") then
                hrp.CFrame = seat.CFrame + Vector3.new(0, 2, 0)
                seat:Sit(hum)
            end
            
            hum:GetPropertyChangedSignal("Jump"):Connect(function()
                if hum.Jump and hum.Sit then
                    restoreFrames = 15
                    safePosition = hrp.Position
                end
            end)
            
            if _G.AntiGucciBlobCon then _G.AntiGucciBlobCon:Disconnect() end
            _G.AntiGucciBlobCon = R.Heartbeat:Connect(function()
                if not hrp or not hum then return end
                RS.CharacterEvents.RagdollRemote:FireServer(hrp, 0)
                if restoreFrames > 0 then
                    hrp.CFrame = CFrame.new(safePosition)
                    restoreFrames = restoreFrames - 1
                end
            end)
            
            task.spawn(function()
                while hum.Sit do task.wait(1) end
                task.wait(0.5)
                hrp.CFrame = CFrame.new(safePosition)
            end)
        end
        
        if Value then
            startAntiGucci()
            if _G.AntiGucciCharCon then _G.AntiGucciCharCon:Disconnect() end
            _G.AntiGucciCharCon = Player.CharacterAdded:Connect(function()
                if _G.AntiGucciBlob then
                    task.wait(0.5)
                    startAntiGucci()
                end
            end)
        else
            stopAntiGucci()
        end
    end
})

-- Gucci Invisible
GucciSection:AddToggle({
    Name = "Gucci Invisible",
    Default = false,
    Callback = function(Value)
        _G.GucciInvisible = Value
        
        if Value then
            task.spawn(function()
                local char = Player.Character
                local hrp = char:WaitForChild("HumanoidRootPart")
                local hum = char:WaitForChild("Humanoid")
                local savedGucciCF = hrp.CFrame
                
                pcall(function()
                    RS.MenuToys.SpawnToyRemoteFunction:InvokeServer(
                        "TractorGreen",
                        CFrame.new(0, 50000, 0),
                        Vector3.new()
                    )
                end)
                
                local inv = Workspace:WaitForChild(Player.Name .. "SpawnedInToys")
                local blobb = inv:WaitForChild("TractorGreen", 3)
                
                if blobb then
                    blobb.Name = "tractorgucci"
                    local seat = blobb:WaitForChild("VehicleSeat", 3)
                    
                    if seat then
                        seat.CFrame = CFrame.new(0, 50000, 0)
                        hrp.CFrame = seat.CFrame + Vector3.new(0, 2, 0)
                        task.wait(0.05)
                        seat:Sit(hum)
                        
                        for _ = 1, 10 do
                            RS.CharacterEvents.RagdollRemote:FireServer(hrp, 0)
                            task.wait()
                        end
                        
                        local t0 = tick()
                        while seat.Occupant ~= hum and tick() - t0 < 3 do
                            hrp.CFrame = seat.CFrame + Vector3.new(0, 2, 0)
                            seat:Sit(hum)
                            task.wait()
                        end
                        
                        hrp.CFrame = savedGucciCF
                        
                        if _G.gucciInvisConn then _G.gucciInvisConn:Disconnect() end
                        _G.gucciInvisConn = R.Heartbeat:Connect(function()
                            if not hrp or not hrp.Parent then return end
                            RS.CharacterEvents.RagdollRemote:FireServer(hrp, 0)
                            if seat and seat.Parent then
                                seat.CFrame = CFrame.new(0, 50000, 0)
                            end
                            if hum and hum.Sit then
                                hrp.CFrame = savedGucciCF
                            end
                        end)
                    end
                end
            end)
        else
            if _G.gucciInvisConn then
                _G.gucciInvisConn:Disconnect()
                _G.gucciInvisConn = nil
            end
            
            local inv = Workspace:FindFirstChild(Player.Name .. "SpawnedInToys")
            if inv then
                local toy = inv:FindFirstChild("tractorgucci") or inv:FindFirstChild("TractorGreen")
                if toy then
                    pcall(function()
                        RS.MenuToys.DestroyToy:FireServer(toy)
                    end)
                    task.wait(0.1)
                    if toy and toy.Parent then
                        pcall(function() toy:Destroy() end)
                    end
                end
            end
            
            local hum = Player.Character and Player.Character:FindFirstChild("Humanoid")
            if hum then
                hum.Sit = false
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end
    end
})

-- Auto Gucci Invisible
GucciSection:AddToggle({
    Name = "Auto Gucci Invisible",
    Default = false,
    Callback = function(Value)
        _G.AutoGucci = Value
        
        if _G.AutoGucciConn then _G.AutoGucciConn:Disconnect() end
        if _G.AutoGucciSpamTask then task.cancel(_G.AutoGucciSpamTask) end
        
        if Value then
            local function gucci()
                if not _G.AutoGucci then return end
                
                local char = Player.Character
                if not char then return end
                
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChild("Humanoid")
                local inv = Workspace:FindFirstChild(Player.Name .. "SpawnedInToys")
                
                if not (hrp and hum and inv) then return end
                
                for _, v in pairs(inv:GetChildren()) do
                    if v.Name == "AutoGucci" or v.Name == "TractorGreen" then
                        pcall(function() RS.MenuToys.DestroyToy:FireServer(v) end)
                    end
                end
                
                local ragdolled = hum:FindFirstChild("Ragdolled")
                while (ragdolled and ragdolled.Value) or (Player:FindFirstChild("IsHeld") and Player.IsHeld.Value) do
                    task.wait()
                end
                
                hum.Sit = false
                task.wait(0.1)
                
                local spawnCF = hrp.CFrame * CFrame.new(0, 14, 20)
                task.spawn(function()
                    pcall(function()
                        RS.MenuToys.SpawnToyRemoteFunction:InvokeServer("TractorGreen", spawnCF, Vector3.zero)
                    end)
                end)
                
                local GucciThing = inv:WaitForChild("TractorGreen", 3)
                if not GucciThing then return end
                GucciThing.Name = "AutoGucci"
                
                local seat = GucciThing:WaitForChild("VehicleSeat", 3)
                if not seat then return end
                
                _G.AutoGucciSpamTask = task.spawn(function()
                    local endTime = tick() + 0.5
                    while tick() < endTime do
                        pcall(function() RS.CharacterEvents.RagdollRemote:FireServer(hrp, 0) end)
                        task.wait()
                    end
                end)
                
                local lastSitAttempt = 0
                while not (hum.SeatPart or (Player:FindFirstChild("IsHeld") and Player.IsHeld.Value)) and _G.AutoGucci do
                    if tick() - lastSitAttempt > 0.1 then
                        seat:Sit(hum)
                        lastSitAttempt = tick()
                    end
                    task.wait()
                end
                
                hum.Sit = false
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                hrp.Anchored = true
                
                task.spawn(function()
                    repeat task.wait() until not seat:FindFirstChild("SeatWeld")
                    GucciThing:PivotTo(CFrame.new(0, 1e6, 0))
                end)
                
                hrp.Anchored = false
            end
            
            gucci()
            
            _G.AutoGucciConn = R.Heartbeat:Connect(function()
                if not _G.AutoGucci then
                    if _G.AutoGucciConn then _G.AutoGucciConn:Disconnect() end
                    return
                end
                
                local char = Player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChild("Humanoid")
                
                if not (hrp and hum) or hum.Health <= 0 then
                    local newChar = Player.CharacterAdded:Wait()
                    task.wait(0.5)
                    gucci()
                    return
                end
                
                local isNetworkOwner = true
                pcall(function() isNetworkOwner = isnetworkowner(hrp) end)
                
                if (not hrp.Anchored and not isNetworkOwner) or 
                   (Player:FindFirstChild("IsHeld") and Player.IsHeld.Value) or 
                   hum.Sit then
                    gucci()
                end
            end)
        else
            local inv = Workspace:FindFirstChild(Player.Name .. "SpawnedInToys")
            if inv then
                for _, v in pairs(inv:GetChildren()) do
                    if v.Name == "AutoGucci" or v.Name == "TractorGreen" then
                        pcall(function() RS.MenuToys.DestroyToy:FireServer(v) end)
                    end
                end
            end
        end
    end
})

-- Anti Gucci Train
GucciSection:AddToggle({
    Name = "Anti Gucci Train",
    Default = false,
    Callback = function(Value)
        _G.AntiGucciTrain = Value
        
        local function startAntiGucciTrain()
            local char = Player.Character or Player.CharacterAdded:Wait()
            local hum = char:WaitForChild("Humanoid")
            local hrp = char:WaitForChild("HumanoidRootPart")
            local safePositionTrain = hrp.Position
            local restoreFramesTrain = 0
            
            local folder = Workspace.Map.AlwaysHereTweenedObjects
            local train = folder and folder:FindFirstChild("Train")
            local seat
            
            if train then
                for _, d in ipairs(train:GetDescendants()) do
                    if d:IsA("Seat") then
                        seat = d
                        break
                    end
                end
            end
            
            if seat then
                hrp.CFrame = seat.CFrame + Vector3.new(0, 2, 0)
                seat:Sit(hum)
            end
            
            hum:GetPropertyChangedSignal("Jump"):Connect(function()
                if hum.Jump and hum.Sit then
                    restoreFramesTrain = 15
                    safePositionTrain = hrp.Position
                end
            end)
            
            if _G.AntiGucciTrainCon then _G.AntiGucciTrainCon:Disconnect() end
            _G.AntiGucciTrainCon = R.Heartbeat:Connect(function()
                if not hrp or not hum then return end
                RS.CharacterEvents.RagdollRemote:FireServer(hrp, 0)
                if restoreFramesTrain > 0 then
                    hrp.CFrame = CFrame.new(safePositionTrain)
                    restoreFramesTrain = restoreFramesTrain - 1
                end
            end)
            
            task.spawn(function()
                while hum.Sit do task.wait(1) end
                task.wait(0.5)
                hrp.CFrame = CFrame.new(safePositionTrain)
            end)
        end
        
        local function stopAntiGucciTrain()
            if _G.AntiGucciTrainCon then
                _G.AntiGucciTrainCon:Disconnect()
                _G.AntiGucciTrainCon = nil
            end
            local trainFolder = Workspace.Map.AlwaysHereTweenedObjects
            if trainFolder and trainFolder:FindFirstChild("Train") then
                Player:Kick()
            end
        end
        
        if Value then
            startAntiGucciTrain()
            notify("MascatHub", "Gucci Train active", 3)
            
            task.spawn(function()
                while _G.AntiGucciTrain do
                    local trainFolder = Workspace.Map.AlwaysHereTweenedObjects
                    local trainExists = trainFolder and trainFolder:FindFirstChild("Train")
                    if not trainExists then
                        stopAntiGucciTrain()
                        notify("MascatHub", "Train lost", 3)
                        local retries = 0
                        repeat
                            task.wait(0.2)
                            retries = retries + 1
                            trainFolder = Workspace.Map.AlwaysHereTweenedObjects
                        until (trainFolder and trainFolder:FindFirstChild("Train")) or retries > 25 or not _G.AntiGucciTrain
                        if _G.AntiGucciTrain and trainFolder and trainFolder:FindFirstChild("Train") then
                            startAntiGucciTrain()
                            notify("MascatHub", "Train restored", 3)
                        end
                    end
                    task.wait(0.5)
                end
            end)
        else
            _G.AntiGucciTrain = false
            stopAntiGucciTrain()
            notify("MascatHub", "Gucci Train disabled", 3)
        end
    end
})

-- ============================================
-- Section: Auto PCLD Break
-- ============================================
local PCLDSection = DefenseTab:AddSection({
    Name = "Auto PCLD Break"
})

PCLDSection:AddToggle({
    Name = "Auto PCLD Break",
    Default = false,
    Callback = function(Value)
        _G.AutoPCLD = Value
        task.spawn(function()
            local isFirstCycle = true
            
            while _G.AutoPCLD do
                local char = Player.Character or Player.CharacterAdded:Wait()
                local hrp = char:WaitForChild("HumanoidRootPart", 5)
                local hum = char:WaitForChild("Humanoid", 5)
                
                if not hrp or not hum then
                    task.wait(0.5)
                    continue
                end
                
                if hum.Health <= 0 then
                    char = Player.CharacterAdded:Wait()
                    hrp = char:WaitForChild("HumanoidRootPart", 5)
                    hum = char:WaitForChild("Humanoid", 5)
                end
                
                if not hrp or not hum then continue end
                
                if isFirstCycle then
                    local savedCFrame = hrp.CFrame
                    hrp.CFrame = CFrame.new(hrp.Position.X, 50000, hrp.Position.Z)
                    task.wait(0.05)
                    hum.Health = 0
                    
                    char = Player.CharacterAdded:Wait()
                    if not _G.AutoPCLD then break end
                    
                    hrp = char:WaitForChild("HumanoidRootPart", 5)
                    hum = char:WaitForChild("Humanoid", 5)
                    
                    if hrp and hum then
                        task.wait(0.1)
                        hrp.CFrame = savedCFrame
                        task.wait(0.05)
                        hum.Health = 0
                    end
                    isFirstCycle = false
                else
                    task.wait(0.1)
                    if hum then
                        hum.Health = 0
                        pcall(function() char:BreakJoints() end)
                    end
                end
                
                char = Player.CharacterAdded:Wait()
                if not _G.AutoPCLD then break end
                hum = char:WaitForChild("Humanoid", 5)
                if hum then
                    hum.Died:Wait()
                end
            end
        end)
    end
})

-- ============================================
-- Section: Auto Delete Legs
-- ============================================
local LegsSection = DefenseTab:AddSection({
    Name = "Auto Delete Legs"
})

LegsSection:AddToggle({
    Name = "Auto Delete Legs",
    Default = false,
    Callback = function(Value)
        _G.AutoDeleteLegs = Value
        
        local function performLegDeletion(char)
            task.wait(0.5)
            if not _G.AutoDeleteLegs then return end
            
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")
            local torso = char:FindFirstChild("Torso")
            local ll = char:FindFirstChild("Left Leg")
            local rl = char:FindFirstChild("Right Leg")
            
            if hrp and hum and torso and ll and rl then
                local void = Workspace.FallenPartsDestroyHeight
                local pos = torso.CFrame
                
                Workspace.FallenPartsDestroyHeight = -100
                RS.CharacterEvents.RagdollRemote:FireServer(hrp, 2)
                task.wait(0.5)
                
                rl.CFrame = CFrame.new(0, -10000, 0)
                ll.CFrame = CFrame.new(0, -10000, 0)
                task.wait(0.3)
                torso.CFrame = CFrame.new(0, -9970, 0)
                task.wait(0.5)
                torso.CFrame = pos
                task.wait(0.5)
                Workspace.FallenPartsDestroyHeight = void
                
                task.spawn(function()
                    while _G.AutoDeleteLegs and char.Parent and hum.Health > 0 and not char:FindFirstChild("Left Leg") and not char:FindFirstChild("Right Leg") do
                        pcall(function()
                            local controls = Player.PlayerGui:FindFirstChild("ControlsGui")
                            if controls and controls:FindFirstChild("PCFrame") and controls.PCFrame:FindFirstChild("Stand") then
                                hum.HipHeight = controls.PCFrame.Stand.Visible == false and 2 or 0
                            end
                        end)
                        task.wait()
                    end
                end)
            end
        end
        
        if Value then
            performLegDeletion(Player.Character)
            if _G.LegsConnection then _G.LegsConnection:Disconnect() end
            _G.LegsConnection = Player.CharacterAdded:Connect(function(newChar)
                if _G.AutoDeleteLegs then
                    task.spawn(function() performLegDeletion(newChar) end)
                end
            end)
        elseif _G.LegsConnection then
            _G.LegsConnection:Disconnect()
            _G.LegsConnection = nil
        end
    end
})

LegsSection:AddButton({
    Name = "Delete Legs Manual",
    Callback = function()
        local char = Player.Character
        if not char then return end
        local ll = char:FindFirstChild("Left Leg")
        local rl = char:FindFirstChild("Right Leg")
        if ll and rl then
            local void = Workspace.FallenPartsDestroyHeight
            local pos = char.Torso.CFrame
            Workspace.FallenPartsDestroyHeight = -100
            RS.CharacterEvents.RagdollRemote:FireServer(char.HumanoidRootPart, 2)
            task.wait(0.5)
            rl.CFrame = CFrame.new(0, -10000, 0)
            ll.CFrame = CFrame.new(0, -10000, 0)
            task.wait(0.3)
            char.Torso.CFrame = CFrame.new(0, -9970, 0)
            task.wait(0.5)
            char.Torso.CFrame = pos
            task.wait(0.5)
            Workspace.FallenPartsDestroyHeight = void
            notify("MascatHub", "Legs deleted", 3)
        end
    end
})

-- ============================================
-- Section: Anti Void
-- ============================================
local VoidSection = DefenseTab:AddSection({
    Name = "Anti Void"
})

VoidSection:AddToggle({
    Name = "Anti Void",
    Default = false,
    Callback = function(Value)
        _G.AntiVoid = Value
        Workspace.FallenPartsDestroyHeight = Value and 0/0 or -100
    end
})

-- ============================================
-- Section: Misc Defense
-- ============================================
local MiscDefSection = DefenseTab:AddSection({
    Name = "Misc Defense"
})

-- Loop TP
MiscDefSection:AddToggle({
    Name = "Loop TP",
    Default = false,
    Callback = function(Value)
        _G.LoopTP = Value
        local char = Player.Character or Player.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        
        if Value and hum then
            hum.PlatformStand = true
            task.spawn(function()
                while _G.LoopTP and hrp do
                    hrp.CFrame = CFrame.new(
                        math.random(-500, 500),
                        math.random(30, 480),
                        math.random(-500, 500)
                    )
                    task.wait(0.03)
                end
            end)
        elseif hum then
            hum.PlatformStand = false
        end
    end
})

-- Anti Input
MiscDefSection:AddToggle({
    Name = "Anti Input",
    Default = false,
    Callback = function(Value)
        _G.InstantLagActive = Value
        
        if Value then
            task.spawn(function()
                local SpawnRemote = RS.MenuToys:WaitForChild("SpawnToyRemoteFunction")
                local HoldDuration = 0.02
                local CycleSpeed = 0.02
                local SelectedToy = "FoodHamburger"
                
                while _G.InstantLagActive do
                    local char = Player.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    
                    if hrp then
                        local toysFolder = Workspace:FindFirstChild(Player.Name .. "SpawnedInToys")
                        local item = toysFolder and toysFolder:FindFirstChild(SelectedToy)
                        
                        for _, obj in pairs(Workspace:GetChildren()) do
                            if obj.Name == "Shuriken" and obj:IsA("Model") then
                                for _, part in pairs(obj:GetDescendants()) do
                                    if part:IsA("BasePart") then
                                        part.CanCollide = false
                                        part.Massless = true
                                    end
                                end
                            end
                        end
                        
                        if not item or not item.Parent then
                            task.spawn(function()
                                pcall(function()
                                    SpawnRemote:InvokeServer(SelectedToy, hrp.CFrame * CFrame.new(0, -12, 0), Vector3.zero)
                                end)
                            end)
                            task.wait(0.1)
                        else
                            local holdPart = item:FindFirstChild("HoldPart")
                            if holdPart then
                                for _, v in pairs(item:GetDescendants()) do
                                    if v:IsA("BasePart") then
                                        v.CanCollide = false
                                        v.Massless = true
                                    end
                                end
                                
                                task.spawn(function()
                                    pcall(function()
                                        holdPart.HoldItemRemoteFunction:InvokeServer(item, char)
                                    end)
                                end)
                                
                                task.wait(HoldDuration)
                                
                                task.spawn(function()
                                    pcall(function()
                                        holdPart.DropItemRemoteFunction:InvokeServer(
                                            item,
                                            CFrame.new(0, 5000, 0),
                                            Vector3.zero
                                        )
                                    end)
                                end)
                            end
                        end
                    end
                    task.wait(CycleSpeed)
                end
            end)
        end
    end
})

-- ============================================
-- OrionLib Init
-- ============================================
OrionLib:Init()