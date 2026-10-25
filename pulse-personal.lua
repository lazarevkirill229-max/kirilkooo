-- Personal launcher: original PulseZax plus a separate custom menu.
-- This does not modify PulseZax internals, keys, licensing, or anti-cheat.
if not game:IsLoaded() then game.Loaded:Wait() end
if game.GameId ~= 66654135 then
    warn("Personal MM2 launcher: join Murder Mystery 2 first.")
    return
end

local function run(url, name)
    local ok, err = pcall(function()
        local source = game:HttpGet(url)
        local chunk, compileError = loadstring(source, "@" .. name)
        if not chunk then error(compileError) end
        chunk()
    end)
    if not ok then warn(name .. ": " .. tostring(err)) end
end

-- Both menus load independently; one error does not block the other.
task.spawn(function()
    run("https://raw.githubusercontent.com/lazarevkirill229-max/kirilkooo/78c3ac364888075681e8fb4418d47486694e2e03/mm2.lua", "Personal-MM2")
end)

-- Avoid starting a second instance on repeated execution in this session.
if not _G.PersonalPulseZaxStarted then
    _G.PersonalPulseZaxStarted = true
    task.spawn(function()
        local ok, err = pcall(function()
            local source = game:HttpGet("https://raw.githubusercontent.com/PulseZax/Loader/refs/heads/main/.lua")
            local chunk, compileError = loadstring(source, "@Original-PulseZax")
            if not chunk then error(compileError) end
            chunk()
        end)
        if not ok then
            _G.PersonalPulseZaxStarted = nil
            warn("PulseZax: " .. tostring(err))
        end
    end)
end
