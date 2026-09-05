-- if you there to skid then go fuck yourself --

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local lp = Players.LocalPlayer
local Terrain = Workspace:FindFirstChildOfClass("Terrain")

local hiddenTrees = {}
local treesHidden = true

local function safeConnect(sig, fn)
    pcall(function() sig:Connect(fn) end)
end

local function processDescendantsChunked(parent, callback, chunkSize)
    chunkSize = chunkSize or 250
    task.spawn(function()
        local count = 0
        for _, v in ipairs(parent:GetDescendants()) do
            pcall(callback, v)
            count = count + 1
            if count % chunkSize == 0 then
                task.wait()
            end
        end
    end)
end

local function getTreeRoot(v)
    if not (v:IsA("Model") or v:IsA("BasePart")) then return nil end
    local name = v.Name:lower()
    if name:find("tree") or name:find("leaf") or name:find("foliage") then
        local ancestor = v
        while ancestor.Parent and ancestor.Parent ~= Workspace do
            local pName = ancestor.Parent.Name:lower()
            if pName:find("tree") or pName:find("leaf") or pName:find("foliage") then
                ancestor = ancestor.Parent
            else
                break
            end
        end
        return ancestor
    end
    return nil
end

local function processTree(v)
    local root = getTreeRoot(v)
    if root then
        if not hiddenTrees[root] then
            hiddenTrees[root] = root.Parent or Workspace
        end
        if treesHidden then
            task.defer(function()
                pcall(function() root.Parent = nil end)
            end)
        end
    end
end

local function restoreTrees()
    treesHidden = false
    for tree, origParent in pairs(hiddenTrees) do
        if tree then
            task.defer(function()
                pcall(function() tree.Parent = origParent or Workspace end)
            end)
        end
    end
end

local function removeTrees()
    treesHidden = true
    for tree, _ in pairs(hiddenTrees) do
        if tree then
            task.defer(function()
                pcall(function() tree.Parent = nil end)
            end)
        end
    end
end

local function onChat(msg)
    local clean = msg:lower()
    if clean:find("/e add tree") or clean:find("/e addtree") then
        restoreTrees()
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Optimizer",
                Text = "Trees restored!",
                Duration = 5
            })
        end)
    elseif clean:find("/e remove tree") or clean:find("/e removetree") then
        removeTrees()
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Optimizer",
                Text = "Trees removed!",
                Duration = 5
            })
        end)
    end
end

safeConnect(lp.Chatted, onChat)

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification",{
        Title="made by m7za",
        Text="my discord m7za1",
        Duration=5
    })
end)

local VM = {}
local order = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11}

VM[1] = function()
    local BLACK = Color3.fromRGB(0,0,0)

    local function apply(v)
        if v:IsA("Trail") then
            v.Color = ColorSequence.new(BLACK)
            v.Transparency = NumberSequence.new(1)
            v.Texture = ""
            v.LightEmission = 0
        elseif v:IsA("ParticleEmitter") then
            v.Color = ColorSequence.new(BLACK)
            v.Transparency = NumberSequence.new(1)
            v.LightEmission = 0
        end
    end

    local function hookChar(char)
        processDescendantsChunked(char, function(v)
            if v:IsA("Trail") or v:IsA("ParticleEmitter") then
                apply(v)
            end
        end)
        safeConnect(char.DescendantAdded, function(v)
            if v:IsA("Trail") or v:IsA("ParticleEmitter") then
                apply(v)
            end
        end)
    end

    if lp.Character then hookChar(lp.Character) end
    safeConnect(lp.CharacterAdded, hookChar)
end

VM[2] = function()
    local greySkyID = "rbxassetid://77236637068486"
    local customSky = nil

    local function applySky()
        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("Sky") and v ~= customSky then
                task.defer(function() pcall(function() v:Destroy() end) end)
            end
        end

        if not customSky or customSky.Parent ~= Lighting then
            if customSky then pcall(function() customSky:Destroy() end) end
            customSky = Instance.new("Sky")
            customSky.Name = "CustomGreySky"
            customSky.SkyboxBk = greySkyID
            customSky.SkyboxFt = greySkyID
            customSky.SkyboxLf = greySkyID
            customSky.SkyboxRt = greySkyID
            customSky.SkyboxUp = greySkyID
            customSky.SkyboxDn = greySkyID
            customSky.SunAngularSize = 0
            customSky.MoonAngularSize = 0
            customSky.Parent = Lighting
        end
    end

    applySky()

    safeConnect(Lighting.ChildAdded, function(v)
        if v:IsA("Sky") and v ~= customSky then
            task.wait()
            applySky()
        end
    end)

    safeConnect(lp.CharacterAdded, function()
        task.wait(0.2)
        applySky()
    end)
end

VM[3] = function()
    Lighting.ClockTime=12
    Lighting.GlobalShadows=false
    Lighting.Brightness=0.8
    Lighting.ExposureCompensation=-0.2
    Lighting.FogStart,Lighting.FogEnd=9e9,9e9

    for _,v in ipairs(Lighting:GetChildren()) do
        if v:IsA("PostEffect") or v:IsA("SunRaysEffect") then
            v.Enabled=false
        end
    end
end

VM[4] = function()
    safeConnect(Workspace.DescendantAdded, function(v)
        task.defer(function()
            if not v or not v.Parent then return end
            if v:IsA("Smoke") then
                pcall(function() v:Destroy() end)
            elseif v:IsA("ParticleEmitter") then
                local m = v:FindFirstAncestorOfClass("Model")
                if not (m and m:FindFirstChild("Class") and m.Class.Value == "Hero Hunter") then
                    pcall(function() v:Destroy() end)
                end
            elseif getTreeRoot(v) then
                processTree(v)
            elseif v:IsA("Decal") or v:IsA("Texture") or v:IsA("SurfaceAppearance") then
                pcall(function() v:Destroy() end)
            end
        end)
    end)
end

VM[5] = function()
    if not Terrain then return end
    for _,v in ipairs(Terrain:GetChildren()) do
        if v:IsA("Clouds") then v.Enabled=false end
    end
    safeConnect(Terrain.ChildAdded,function(v)
        if v:IsA("Clouds") then v.Enabled=false end
    end)
end

VM[6] = function()
    local function killSun()
        local sky = Lighting:FindFirstChildOfClass("Sky")
        if sky and sky.Name ~= "CustomGreySky" then
            sky.SunAngularSize = 0
            sky.SunTextureId = ""
            sky.MoonAngularSize = 0
            sky.MoonTextureId = ""
        end
    end

    killSun()

    local at = Lighting:FindFirstChildOfClass("Atmosphere")
    if at then
        at.Density = 0
        at.Haze = 0
        at.Glare = 0
    end

    safeConnect(Lighting.ChildAdded,function(v)
        if v:IsA("Sky") then
            task.wait()
            killSun()
        elseif v:IsA("Atmosphere") then
            v.Density = 0
            v.Haze = 0
            v.Glare = 0
        end
    end)
end

VM[7] = function()
    processDescendantsChunked(Workspace, function(v)
        processTree(v)
    end)
end

VM[8] = function()
    processDescendantsChunked(Workspace, function(v)
        if v:IsA("Decal") or v:IsA("Texture") or v:IsA("SurfaceAppearance") then
            task.defer(function() pcall(function() v:Destroy() end) end)
        end
    end)
end

VM[9] = function()
    processDescendantsChunked(Workspace, function(v)
        if v:IsA("BasePart") then
            v.CastShadow = false
        end
    end)
end

VM[10] = function()
    local cam = Workspace.CurrentCamera
    if cam then
        safeConnect(cam:GetPropertyChangedSignal("FieldOfView"), function()
            if cam.FieldOfView > 80 or cam.FieldOfView < 60 then
                cam.FieldOfView = 70
            end
        end)
    end
end

VM[11] = function()
    local playerGui = lp:WaitForChild("PlayerGui")

    local oldGui = playerGui:FindFirstChild("FPSPingCounter")
    if oldGui then oldGui:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FPSPingCounter"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    local counterLabel = Instance.new("TextLabel")
    counterLabel.Size = UDim2.new(0, 300, 0, 30)
    counterLabel.Position = UDim2.new(0.5, 0, 0, 10)
    counterLabel.AnchorPoint = Vector2.new(0.5, 0)
    counterLabel.BackgroundTransparency = 1
    counterLabel.Text = "FPS: 0 | PING: 0 ms"
    counterLabel.Font = Enum.Font.Code
    counterLabel.TextSize = 16
    counterLabel.TextStrokeTransparency = 0.4
    counterLabel.TextXAlignment = Enum.TextXAlignment.Center
    counterLabel.Parent = screenGui

    local displayedFPS = 0
    local displayedPing = 0
    local lastTime = tick()

    RunService.RenderStepped:Connect(function()
        local currentTime = tick()
        local fps = 1 / math.max(currentTime - lastTime, 0.0001)
        lastTime = currentTime

        local ping = 0
        pcall(function()
            ping = lp:GetNetworkPing() * 1000
        end)

        displayedFPS = displayedFPS + (fps - displayedFPS) * 0.1
        displayedPing = displayedPing + (ping - displayedPing) * 0.1

        counterLabel.Text = string.format("FPS: %d | PING: %d ms", math.floor(displayedFPS), math.floor(displayedPing))

        local hue = (currentTime * 0.4) % 1
        counterLabel.TextColor3 = Color3.fromHSV(hue, 0.8, 1)
    end)
end

while #order > 0 do
    local i = math.random(#order)
    pcall(VM[order[i]])
    table.remove(order, i)
end

pcall(function()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
end) 
