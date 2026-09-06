-- if you there to skid then go fuck yourself --

local Players         = game:GetService("Players")
local Lighting        = game:GetService("Lighting")
local Workspace       = game:GetService("Workspace")
local RunService      = game:GetService("RunService")
local StarterGui      = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")

local lp      = Players.LocalPlayer
local Terrain = Workspace:FindFirstChildOfClass("Terrain")

do
    local env = (typeof(getgenv) == "function" and getgenv()) or _G
    if env.TSBG_Loaded then
        return
    end
    env.TSBG_Loaded = true
end

local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 5,
        })
    end)
end

local function safeConnect(sig, fn)
    local ok, conn = pcall(function() return sig:Connect(fn) end)
    if ok then return conn end
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

local hiddenTrees  = {}
local treesHidden  = true

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
    for tree in pairs(hiddenTrees) do
        if tree then
            task.defer(function()
                pcall(function() tree.Parent = nil end)
            end)
        end
    end
end

local function onChat(msg)
    if typeof(msg) ~= "string" then return end
    local clean = msg:lower()
    if clean:find("/e add tree") or clean:find("/e addtree") then
        restoreTrees()
        notify("Optimizer", "Trees restored!")
    elseif clean:find("/e remove tree") or clean:find("/e removetree") then
        removeTrees()
        notify("Optimizer", "Trees removed!")
    end
end

safeConnect(lp.Chatted, onChat)

pcall(function()
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        safeConnect(TextChatService.MessageReceived, function(textChatMessage)
            if textChatMessage.TextSource and textChatMessage.TextSource.UserId == lp.UserId then
                onChat(textChatMessage.Text)
            end
        end)
    end
end)

notify("made by m7za", "my discord m7za1")

local VM = {}
local order = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11}

VM[1] = function()
    local BLACK = Color3.fromRGB(0, 0, 0)

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
    local GREY_SKY_ID = "rbxassetid://77236637068486"
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
            customSky.SkyboxBk = GREY_SKY_ID
            customSky.SkyboxFt = GREY_SKY_ID
            customSky.SkyboxLf = GREY_SKY_ID
            customSky.SkyboxRt = GREY_SKY_ID
            customSky.SkyboxUp = GREY_SKY_ID
            customSky.SkyboxDn = GREY_SKY_ID
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
    Lighting.ClockTime = 12
    Lighting.GlobalShadows = false
    Lighting.Brightness = 0.8
    Lighting.ExposureCompensation = -0.2
    Lighting.FogStart, Lighting.FogEnd = 9e9, 9e9

    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("PostEffect") or v:IsA("SunRaysEffect") then
            v.Enabled = false
        end
    end
end

VM[4] = function()
    safeConnect(Workspace.DescendantAdded, function(v)
        task.defer(function()
            pcall(function()
                if not v or not v.Parent then return end
                if v:IsA("Smoke") then
                    v:Destroy()
                elseif v:IsA("ParticleEmitter") then
                    local m = v:FindFirstAncestorOfClass("Model")
                    local classObj = m and m:FindFirstChild("Class")
                    local isHeroHunter = classObj and classObj:IsA("ValueBase") and classObj.Value == "Hero Hunter"
                    if not isHeroHunter then
                        v:Destroy()
                    end
                elseif getTreeRoot(v) then
                    processTree(v)
                elseif v:IsA("Decal") or v:IsA("Texture") or v:IsA("SurfaceAppearance") then
                    v:Destroy()
                end
            end)
        end)
    end)
end

VM[5] = function()
    if not Terrain then return end
    for _, v in ipairs(Terrain:GetChildren()) do
        if v:IsA("Clouds") then v.Enabled = false end
    end
    safeConnect(Terrain.ChildAdded, function(v)
        if v:IsA("Clouds") then v.Enabled = false end
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

    safeConnect(Lighting.ChildAdded, function(v)
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
    local MIN_FOV, MAX_FOV, DEFAULT_FOV = 60, 80, 70
    local camConn = nil

    local function clampFOV(cam)
        if cam.FieldOfView > MAX_FOV or cam.FieldOfView < MIN_FOV then
            cam.FieldOfView = DEFAULT_FOV
        end
    end

    local function watch(cam)
        if camConn then camConn:Disconnect() end
        if not cam then return end
        clampFOV(cam)
        camConn = safeConnect(cam:GetPropertyChangedSignal("FieldOfView"), function()
            clampFOV(cam)
        end)
    end

    watch(Workspace.CurrentCamera)
    safeConnect(Workspace:GetPropertyChangedSignal("CurrentCamera"), function()
        watch(Workspace.CurrentCamera)
    end)
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

    safeConnect(RunService.RenderStepped, function()
        local currentTime = tick()
        local fps = 1 / math.max(currentTime - lastTime, 0.0001)
        lastTime = currentTime

        local ping = 0
        pcall(function()
            ping = lp:GetNetworkPing() * 1000
        end)

        displayedFPS = displayedFPS + (fps - displayedFPS) * 0.1
        displayedPing = displayedPing + (ping - displayedPing) * 0.1

        counterLabel.Text = string.format(
            "FPS: %d | PING: %d ms",
            math.floor(displayedFPS),
            math.floor(displayedPing)
        )

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
