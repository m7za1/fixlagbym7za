-- if you there to skid go fuck yourself --

local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local placeId = game.PlaceId

local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 4
        })
    end)
end

do
    local marker = CoreGui:FindFirstChild("M7ZA_LoaderRan")
    if marker then
        return
    end
    local ok = pcall(function()
        local flag = Instance.new("BoolValue")
        flag.Name = "M7ZA_LoaderRan"
        flag.Parent = CoreGui
    end)
    if not ok then
        if _G.M7ZA_LoaderRan then return end
        _G.M7ZA_LoaderRan = true
    end
end

local games = {
    [10449761463] = "https://raw.githubusercontent.com/m7za1/fixlagbym7za/refs/heads/main/lbg.lua",
    [15269951959] = "https://raw.githubusercontent.com/m7za1/fixlagbym7za/refs/heads/main/tsbg.lua"
}

local url = games[placeId]

if not url then
    notify("Script Is not Loaded", "Wrong game. PlaceId: " .. tostring(placeId))
    return
end

notify("Auto Loader", "Loading The Script...")

local fetchOk, fetchResultOrErr = pcall(function()
    return game:HttpGet(url)
end)

if not fetchOk then
    notify("ERROR", "Could not download the script: " .. tostring(fetchResultOrErr))
    return
end

local compiledFn, compileErr = loadstring(fetchResultOrErr)

if not compiledFn then
    notify("ERROR", "The script failed to compile: " .. tostring(compileErr))
    return
end

local runOk, runErr = pcall(compiledFn)

if not runOk then
    notify("ERROR", "The script errored while running: " .. tostring(runErr))
end
