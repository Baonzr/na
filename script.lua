repeat wait() until game:IsLoaded()
local plr = game.Players.LocalPlayer
local rs = game.ReplicatedStorage
local ws = game.Workspace
local vim = game:GetService("VirtualInputManager")
local zone = Vector3.new(57951, 5, -15543)
local tiki = CFrame.new(58467, 5, -15585)

-- Equip nearest Melee/Sword
local function equip()
    for _, v in pairs(plr.Backpack:GetChildren()) do
        local t = v.ToolTip
        if t == "Melee" or t == "Sword" then
            plr.Character.Humanoid:EquipTool(v)
            break
        end
    end
end

-- Cast skills
local function skills(tool)
    if not tool then return end
    local t = tool.ToolTip
    local function key(k)
        vim:SendKeyEvent(true, k, false, game)
        wait(0.2)
        vim:SendKeyEvent(false, k, false, game)
    end
    if t == "Melee" or t == "Sword" then
        key("Z"); wait(); key("X"); wait(); key("C")
    elseif t == "Blox Fruit" then
        key("X"); wait(); key("C")
    end
end

-- Shoot Leviathan Heart
local function shootHeart()
    local h = ws:FindFirstChild("LeviathanHeart")
    if h then
        plr.Character.HumanoidRootPart.CFrame = h.CFrame + Vector3.new(0,10,0)
        wait(1)
        pcall(function() rs.Remotes.CommF_:InvokeServer("ShootLeviHeart") end)
        wait(2)
        h:PivotTo(tiki)
    end
end

-- Boat logic
local function findBoat()
    for _, b in pairs(ws.Boats:GetChildren()) do
        if b.Name:lower():find("levi") then return b end
    end
end
local function sit(b)
    local s = b:FindFirstChildWhichIsA("VehicleSeat", true)
    if s then
        plr.Character.HumanoidRootPart.CFrame = s.CFrame + Vector3.new(0,5,0)
        wait(1); s:Sit(plr.Character.Humanoid)
    end
end
local function count(b)
    local c = 0
    for _, p in pairs(game.Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("Humanoid") then
            local s = p.Character.Humanoid.SeatPart
            if s and s:IsDescendantOf(b) then c += 1 end
        end
    end
    return c
end
local function waitFull(b)
    repeat wait(1) until count(b) >= 5
end

-- Status checks
local function isIDK()
    return rs.Remotes.CommF_:InvokeServer("GetUnlockSeaBeast", "Leviathan") == 0
end
local function seaMob()
    for _, v in pairs(ws.Enemies:GetChildren()) do
        local n = v.Name:lower()
        if n:find("sea") or n:find("pirate") then return v end
    end
end

-- Farm Sea until unlock Levi
local function farmSea()
    while isIDK() do
        local m = seaMob()
        if m then
            equip()
            repeat
                plr.Character.HumanoidRootPart.CFrame = m.HumanoidRootPart.CFrame + Vector3.new(0,20,0)
                mouse1click()
                skills(plr.Character:FindFirstChildOfClass("Tool"))
                wait()
            until not m.Parent or m.Humanoid.Health <= 0
        else wait(2) end
    end
end

-- Farm Leviathan
local function findBoss()
    for _, v in pairs(ws.Enemies:GetChildren()) do
        if v.Name:lower():find("leviathan") then return v end
    end
end
local function farmBoss()
    while not isIDK() do
        local b = findBoss()
        if b then
            equip()
            repeat
                plr.Character.HumanoidRootPart.CFrame = b.HumanoidRootPart.CFrame + Vector3.new(0,20,0)
                mouse1click()
                skills(plr.Character:FindFirstChildOfClass("Tool"))
                wait()
            until not b.Parent or b.Humanoid.Health <= 0
            wait(2); shootHeart(); break
        end
        wait(3)
    end
end

-- UI menu only (Rayfield UI)
spawn(function()
    local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()
    local Win = Rayfield:CreateWindow({
        Name = "🕵️ Conan Leviathan Hub",
        LoadingTitle = "Auto Leviathan by Gia Bảo",
        ConfigurationSaving = {Enabled = false},
        KeySystem = false,
        Background = "https://i.pinimg.com/736x/482e3b46c00c44fba03e5d3d4e2be6cd.jpg"
    })
    local Tab = Win:CreateTab("🌊 Leviathan AutoFarm")
    Tab:CreateParagraph({Title = "Chức năng đang chạy:", Content = [[
1️⃣ Tự farm Sea Event nếu IDK Leviathan
2️⃣ Tự mua/tìm thuyền Leviathan
3️⃣ Ngồi lên thuyền + bật haki
4️⃣ Chờ đủ 5 người rồi mới di chuyển
5️⃣ Đánh boss Leviathan + dùng kỹ năng
6️⃣ Bắn tim và kéo về đảo Tiki
7️⃣ (Bỏ reset) - Không còn reset nếu quá xa
8️⃣ Lặp lại toàn bộ vòng săn
]]})
end)

-- Main loop
spawn(function()
    while true do
        if isIDK() then
            farmSea()
        else
            local b = findBoat()
            if not b then
                rs.Remotes.CommF_:InvokeServer("BuyBoat", "Leviathan")
                wait(3); b = findBoat()
            end
            if b then
                sit(b)
                rs.Remotes.CommF_:InvokeServer("Ken", true)
                waitFull(b)
                b:PivotTo(CFrame.new(zone))
                wait(10)
                farmBoss()
            end
        end
        wait(5)
    end
end)