-- Safe UI Destruction on Re-Execution
local CoreGui = game:GetService("CoreGui")
local gethui = gethui or function() return CoreGui end

local success, existingUI = pcall(function()
    return gethui():FindFirstChild("BloopsHubUI")
end)
if success and existingUI then
    existingUI:Destroy()
end

local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Config Folder Setup
local FolderName = "BloopsHub"
local ConfigFolder = FolderName .. "/Configs"

if makefolder and isfolder then
    if not isfolder(FolderName) then makefolder(FolderName) end
    if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
end

-- Global States
local GlobalTransparency = 0
local AutoExecuteEnabled = true -- Default enabled
local ScriptRawUrl = "https://raw.githubusercontent.com/BloopsHub/bloopshubv1/refs/heads/main/main.lua"
local CurrentThemeKey = "Default"
local DefaultConfigName = "TempConfig"
local LastConfigFile = ConfigFolder .. "/LastConfig.json"

local function HasPlaceholderScriptUrl(url)
    if type(url) ~= "string" then return true end
    local trimmed = string.gsub(url, "%s+", "")
    return trimmed == "" or string.lower(trimmed) == "your_script_raw_url_here"
    or string.find(string.lower(trimmed), "example.com/replace-with-your-script.lua") ~= nil
end

local function GetConfigState()
    return {
        Theme = CurrentThemeKey,
        Transparency = GlobalTransparency,
        AutoExecute = AutoExecuteEnabled,
        ConfigName = DefaultConfigName
    }
end

local function ApplyConfigState(data)
    if type(data) ~= "table" then return false end

    if data.Theme and Themes[data.Theme] then
        CurrentThemeKey = data.Theme
        ApplyTheme(CurrentThemeKey)
    else
        ApplyTheme("Default")
    end

    if data.Transparency ~= nil then
        GlobalTransparency = math.clamp(tonumber(data.Transparency) or 0, 0, 0.85)
        if FillTrackUI then FillTrackUI() end
        ApplyTheme("Current")
    end

    if data.AutoExecute ~= nil then
        AutoExecuteEnabled = data.AutoExecute == true
        if RegisterTeleportQueue then
            RegisterTeleportQueue(AutoExecuteEnabled)
        end
        if UpdateToggleUI then UpdateToggleUI() end
    end

    return true
end

local function SaveLastConfig(data)
    if writefile then
        writefile(LastConfigFile, HttpService:JSONEncode(data))
    end
end

local function PersistCurrentState()
    local state = GetConfigState()
    state.ConfigName = DefaultConfigName
    SaveLastConfig(state)
end

-- Helper Function for Queueing Teleport
local function RegisterTeleportQueue(enable)
    local queue_on_teleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
    if queue_on_teleport then
        if enable then
            if HasPlaceholderScriptUrl(ScriptRawUrl) then
                warn("BloopsHub: Auto-execute is enabled but ScriptRawUrl is still a placeholder. Replace it with your actual raw script URL to make server-hop re-execution work.")
                return
            end

            queue_on_teleport([[
                repeat task.wait() until game:IsLoaded()
                loadstring(game:HttpGet("]] .. ScriptRawUrl .. [["))()
            ]])
        else
            queue_on_teleport("") -- Clear queue
        end
    end
end

if AutoExecuteEnabled then
    RegisterTeleportQueue(true)
end

-- Theme Preset Definitions
local Themes = {
    Default = {
        MainBg = Color3.fromRGB(15, 20, 28),
        HeaderBg = Color3.fromRGB(22, 28, 38),
        SidebarBg = Color3.fromRGB(18, 24, 33),
        CardBg = Color3.fromRGB(22, 30, 42),
        ItemBg = Color3.fromRGB(24, 32, 45),
        Stroke = Color3.fromRGB(35, 45, 60),
        Accent = Color3.fromRGB(35, 85, 185),
        AccentGlow = Color3.fromRGB(60, 130, 246),
        TextPrimary = Color3.fromRGB(240, 245, 255),
        TextSecondary = Color3.fromRGB(130, 150, 175)
    },
    Dark = {
        MainBg = Color3.fromRGB(10, 10, 12),
        HeaderBg = Color3.fromRGB(18, 18, 22),
        SidebarBg = Color3.fromRGB(14, 14, 18),
        CardBg = Color3.fromRGB(20, 20, 26),
        ItemBg = Color3.fromRGB(26, 26, 34),
        Stroke = Color3.fromRGB(40, 40, 50),
        Accent = Color3.fromRGB(70, 70, 80),
        AccentGlow = Color3.fromRGB(100, 100, 120),
        TextPrimary = Color3.fromRGB(240, 240, 245),
        TextSecondary = Color3.fromRGB(140, 140, 155)
    },
    Purple = {
        MainBg = Color3.fromRGB(18, 14, 28),
        HeaderBg = Color3.fromRGB(26, 20, 38),
        SidebarBg = Color3.fromRGB(22, 16, 33),
        CardBg = Color3.fromRGB(30, 22, 44),
        ItemBg = Color3.fromRGB(38, 28, 55),
        Stroke = Color3.fromRGB(55, 38, 75),
        Accent = Color3.fromRGB(120, 45, 195),
        AccentGlow = Color3.fromRGB(160, 70, 240),
        TextPrimary = Color3.fromRGB(245, 235, 255),
        TextSecondary = Color3.fromRGB(160, 140, 185)
    },
    Midnight = {
        MainBg = Color3.fromRGB(8, 12, 20),
        HeaderBg = Color3.fromRGB(12, 18, 30),
        SidebarBg = Color3.fromRGB(10, 15, 25),
        CardBg = Color3.fromRGB(15, 23, 38),
        ItemBg = Color3.fromRGB(20, 30, 50),
        Stroke = Color3.fromRGB(25, 45, 75),
        Accent = Color3.fromRGB(0, 150, 220),
        AccentGlow = Color3.fromRGB(0, 190, 255),
        TextPrimary = Color3.fromRGB(230, 245, 255),
        TextSecondary = Color3.fromRGB(120, 160, 195)
    },
    Emerald = {
        MainBg = Color3.fromRGB(12, 22, 18),
        HeaderBg = Color3.fromRGB(18, 32, 26),
        SidebarBg = Color3.fromRGB(15, 26, 21),
        CardBg = Color3.fromRGB(22, 40, 32),
        ItemBg = Color3.fromRGB(28, 50, 40),
        Stroke = Color3.fromRGB(35, 70, 55),
        Accent = Color3.fromRGB(25, 145, 90),
        AccentGlow = Color3.fromRGB(40, 190, 120),
        TextPrimary = Color3.fromRGB(235, 255, 245),
        TextSecondary = Color3.fromRGB(130, 175, 150)
    }
}

-- Central Registry for Dynamic UI Updates
local ThemeRegistry = {}

local function RegisterUI(instance, property, themeKey, handlesTransparency)
    table.insert(ThemeRegistry, {
        Instance = instance, 
        Property = property, 
        Key = themeKey, 
        HandlesTransparency = handlesTransparency or false
    })
end

local ActiveTabButton = nil

local function ApplyTheme(themeName)
    if themeName and themeName ~= "Current" then
        CurrentThemeKey = themeName
    end
    local theme = Themes[CurrentThemeKey] or Themes.Default
    
    for _, item in ipairs(ThemeRegistry) do
        if item.Instance and item.Instance.Parent then
            if item.Key == "ActiveTab" then
                if item.Instance == ActiveTabButton then
                    item.Instance.BackgroundColor3 = theme.Accent
                else
                    item.Instance.BackgroundColor3 = theme.ItemBg
                end
                item.Instance.BackgroundTransparency = GlobalTransparency
            elseif theme[item.Key] then
                item.Instance[item.Property] = theme[item.Key]
                if item.HandlesTransparency then
                    item.Instance.BackgroundTransparency = GlobalTransparency
                end
            end
        end
    end
end

-- Screen Container
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BloopsHubUI"
ScreenGui.Parent = gethui()
ScreenGui.ResetOnSpawn = false

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 520, 0, 320)
MainFrame.Position = UDim2.new(0.5, -260, 0.4, -160)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui
RegisterUI(MainFrame, "BackgroundColor3", "MainBg", true)

-- Modern UserInputService Dragging Logic
local function EnableDragging(frame, handleFrame)
    local dragging, dragInput, dragStart, startPos
    handleFrame = handleFrame or frame

    handleFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handleFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

EnableDragging(MainFrame)

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame
RegisterUI(MainStroke, "Color", "Stroke")

-- Top Header Bar
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BorderSizePixel = 0
Header.Parent = MainFrame
RegisterUI(Header, "BackgroundColor3", "HeaderBg", true)

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = Header

local HeaderHide = Instance.new("Frame")
HeaderHide.Size = UDim2.new(1, 0, 0, 10)
HeaderHide.Position = UDim2.new(0, 0, 1, -10)
HeaderHide.BorderSizePixel = 0
HeaderHide.Parent = Header
RegisterUI(HeaderHide, "BackgroundColor3", "HeaderBg", true)

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(0.6, 0, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = " BloopsHub  |  v1.0"
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 14
TitleText.Parent = Header
RegisterUI(TitleText, "TextColor3", "TextPrimary")

-- Close Button
local BtnClose = Instance.new("TextButton")
BtnClose.Size = UDim2.new(0, 26, 0, 26)
BtnClose.Position = UDim2.new(1, -34, 0.5, -13)
BtnClose.Text = "✕"
BtnClose.Font = Enum.Font.GothamBold
BtnClose.TextSize = 12
BtnClose.Parent = Header
RegisterUI(BtnClose, "BackgroundColor3", "ItemBg", true)
RegisterUI(BtnClose, "TextColor3", "TextSecondary")

local BtnCloseCorner = Instance.new("UICorner")
BtnCloseCorner.CornerRadius = UDim.new(0, 6)
BtnCloseCorner.Parent = BtnClose

-- Minimize Button
local BtnMin = Instance.new("TextButton")
BtnMin.Size = UDim2.new(0, 26, 0, 26)
BtnMin.Position = UDim2.new(1, -66, 0.5, -13)
BtnMin.Text = "—"
BtnMin.Font = Enum.Font.GothamBold
BtnMin.TextSize = 12
BtnMin.Parent = Header
RegisterUI(BtnMin, "BackgroundColor3", "ItemBg", true)
RegisterUI(BtnMin, "TextColor3", "TextSecondary")

local BtnMinCorner = Instance.new("UICorner")
BtnMinCorner.CornerRadius = UDim.new(0, 6)
BtnMinCorner.Parent = BtnMin

-- Floating Re-Open Button
local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 130, 0, 36)
OpenButton.Position = UDim2.new(0.02, 0, 0.15, 0)
OpenButton.Text = " BloopsHub"
OpenButton.Font = Enum.Font.GothamBold
OpenButton.TextSize = 11
OpenButton.Visible = false
OpenButton.Active = true
OpenButton.Parent = ScreenGui
RegisterUI(OpenButton, "BackgroundColor3", "HeaderBg", true)
RegisterUI(OpenButton, "TextColor3", "TextPrimary")

EnableDragging(OpenButton)

local OBCorner = Instance.new("UICorner")
OBCorner.CornerRadius = UDim.new(0, 8)
OBCorner.Parent = OpenButton

local OBStroke = Instance.new("UIStroke")
OBStroke.Thickness = 1
OBStroke.Parent = OpenButton
RegisterUI(OBStroke, "Color", "AccentGlow")

-- Left Navigation Sidebar
local SideBar = Instance.new("Frame")
SideBar.Size = UDim2.new(0, 130, 1, -52)
SideBar.Position = UDim2.new(0, 10, 0, 47)
SideBar.BorderSizePixel = 0
SideBar.Parent = MainFrame
RegisterUI(SideBar, "BackgroundColor3", "SidebarBg", true)

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 8)
SideCorner.Parent = SideBar

local SideList = Instance.new("UIListLayout")
SideList.Padding = UDim.new(0, 6)
SideList.SortOrder = Enum.SortOrder.LayoutOrder
SideList.Parent = SideBar

local SidePadding = Instance.new("UIPadding")
SidePadding.PaddingTop = UDim.new(0, 8)
SidePadding.PaddingLeft = UDim.new(0, 6)
SidePadding.PaddingRight = UDim.new(0, 6)
SidePadding.Parent = SideBar

-- Right Content Container
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -160, 1, -52)
ContentFrame.Position = UDim2.new(0, 148, 0, 47)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Tab System Setup
local Tabs = {}

local function CreateTab(name, layoutOrder)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, 0, 0, 32)
    tabBtn.Text = name
    tabBtn.Font = Enum.Font.GothamSemibold
    tabBtn.TextSize = 12
    tabBtn.LayoutOrder = layoutOrder
    tabBtn.Parent = SideBar
    
    RegisterUI(tabBtn, "BackgroundColor3", "ActiveTab", true)
    RegisterUI(tabBtn, "TextColor3", "TextPrimary")

    if layoutOrder == 1 then
        ActiveTabButton = tabBtn
    end

    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 6)
    tabCorner.Parent = tabBtn

    local pageScroll = Instance.new("ScrollingFrame")
    pageScroll.Size = UDim2.new(1, 0, 1, 0)
    pageScroll.BackgroundTransparency = 1
    pageScroll.BorderSizePixel = 0
    pageScroll.ScrollBarThickness = 3
    pageScroll.Visible = (layoutOrder == 1)
    pageScroll.Parent = ContentFrame

    local pageList = Instance.new("UIListLayout")
    pageList.Padding = UDim.new(0, 8)
    pageList.SortOrder = Enum.SortOrder.LayoutOrder
    pageList.Parent = pageScroll

    pageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        pageScroll.CanvasSize = UDim2.new(0, 0, 0, pageList.AbsoluteContentSize.Y + 15)
    end)

    Tabs[name] = {Button = tabBtn, Page = pageScroll}

    tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do
            t.Page.Visible = false
        end
        ActiveTabButton = tabBtn
        pageScroll.Visible = true
        ApplyTheme("Current")
    end)

    return pageScroll
end

-- Create Tabs
local HomeTab = CreateTab("🏠 Home", 1)
local ServerHopTab = CreateTab("🌐 Server Hop", 2)
local ScriptsTab = CreateTab("📜 Scripts", 3)
local SettingsTab = CreateTab("⚙️ Settings", 4)

-- -------------------------------------------------------
-- 🏠 HOME TAB CONTENT
-- -------------------------------------------------------
local ProfileCard = Instance.new("Frame")
ProfileCard.Size = UDim2.new(1, -6, 0, 100)
ProfileCard.LayoutOrder = 1
ProfileCard.Parent = HomeTab
RegisterUI(ProfileCard, "BackgroundColor3", "CardBg", true)

local ProfileCorner = Instance.new("UICorner")
ProfileCorner.CornerRadius = UDim.new(0, 8)
ProfileCorner.Parent = ProfileCard

local AvatarImg = Instance.new("ImageLabel")
AvatarImg.Size = UDim2.new(0, 70, 0, 70)
AvatarImg.Position = UDim2.new(0, 15, 0.5, -35)
AvatarImg.Parent = ProfileCard
RegisterUI(AvatarImg, "BackgroundColor3", "MainBg", true)

local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(1, 0)
AvatarCorner.Parent = AvatarImg

task.spawn(function()
    local content, isLoaded = Players:GetUserThumbnailAsync(
        LocalPlayer.UserId,
        Enum.ThumbnailType.HeadShot,
        Enum.ThumbnailSize.Size150x150
    )
    if isLoaded then
        AvatarImg.Image = content
    end
end)

local DisplayNameLbl = Instance.new("TextLabel")
DisplayNameLbl.Size = UDim2.new(1, -105, 0, 22)
DisplayNameLbl.Position = UDim2.new(0, 95, 0, 16)
DisplayNameLbl.BackgroundTransparency = 1
DisplayNameLbl.Text = LocalPlayer.DisplayName
DisplayNameLbl.TextXAlignment = Enum.TextXAlignment.Left
DisplayNameLbl.Font = Enum.Font.GothamBold
DisplayNameLbl.TextSize = 15
DisplayNameLbl.Parent = ProfileCard
RegisterUI(DisplayNameLbl, "TextColor3", "TextPrimary")

local UsernameLbl = Instance.new("TextLabel")
UsernameLbl.Size = UDim2.new(1, -105, 0, 18)
UsernameLbl.Position = UDim2.new(0, 95, 0, 38)
UsernameLbl.BackgroundTransparency = 1
UsernameLbl.Text = "@" .. LocalPlayer.Name
UsernameLbl.TextXAlignment = Enum.TextXAlignment.Left
UsernameLbl.Font = Enum.Font.Gotham
UsernameLbl.TextSize = 12
UsernameLbl.Parent = ProfileCard
RegisterUI(UsernameLbl, "TextColor3", "TextSecondary")

local UserIdLbl = Instance.new("TextLabel")
UserIdLbl.Size = UDim2.new(1, -105, 0, 18)
UserIdLbl.Position = UDim2.new(0, 95, 0, 60)
UserIdLbl.BackgroundTransparency = 1
UserIdLbl.Text = "User ID: " .. tostring(LocalPlayer.UserId)
UserIdLbl.TextXAlignment = Enum.TextXAlignment.Left
UserIdLbl.Font = Enum.Font.GothamSemibold
UserIdLbl.TextSize = 11
UserIdLbl.Parent = ProfileCard
RegisterUI(UserIdLbl, "TextColor3", "AccentGlow")

local DetailsFrame = Instance.new("Frame")
DetailsFrame.Size = UDim2.new(1, -6, 0, 45)
DetailsFrame.LayoutOrder = 2
DetailsFrame.Parent = HomeTab
RegisterUI(DetailsFrame, "BackgroundColor3", "CardBg", true)

local DetailsCorner = Instance.new("UICorner")
DetailsCorner.CornerRadius = UDim.new(0, 8)
DetailsCorner.Parent = DetailsFrame

local DetailsList = Instance.new("UIListLayout")
DetailsList.Padding = UDim.new(0, 6)
DetailsList.SortOrder = Enum.SortOrder.LayoutOrder
DetailsList.Parent = DetailsFrame

local DetailsPad = Instance.new("UIPadding")
DetailsPad.PaddingTop = UDim.new(0, 12)
DetailsPad.PaddingLeft = UDim.new(0, 12)
DetailsPad.PaddingRight = UDim.new(0, 12)
DetailsPad.Parent = DetailsFrame

local function CreateDetailRow(label, value, order)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 20)
    row.BackgroundTransparency = 1
    row.LayoutOrder = order
    row.Parent = DetailsFrame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.4, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.Parent = row
    RegisterUI(lbl, "TextColor3", "TextSecondary")

    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(0.6, 0, 1, 0)
    val.Position = UDim2.new(0.4, 0, 0, 0)
    val.BackgroundTransparency = 1
    val.Text = value
    val.TextXAlignment = Enum.TextXAlignment.Right
    val.Font = Enum.Font.GothamSemibold
    val.TextSize = 11
    val.Parent = row
    RegisterUI(val, "TextColor3", "TextPrimary")
end

CreateDetailRow("Executor:", (identifyexecutor and identifyexecutor()) or "Unknown Executor", 1)

-- -------------------------------------------------------
-- 🌐 SERVER HOP TAB CONTENT
-- -------------------------------------------------------
local function HopToLowestServer(badge)
    badge.Text = "Searching..."
    badge.BackgroundColor3 = Color3.fromRGB(200, 150, 30)

    task.spawn(function()
        local placeId = game.PlaceId
        local lowestServer = nil
        local lowestCount = math.huge
        local cursor = ""
        local attempts = 0

        repeat
            attempts = attempts + 1
            local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
            if cursor ~= "" then
                url = url .. "&cursor=" .. cursor
            end

            local success, result = pcall(function()
                return HttpService:JSONDecode(game:HttpGet(url))
            end)

            if success and result and result.data then
                for _, server in ipairs(result.data) do
                    if server.playing < lowestCount and server.playing > 0 and server.id ~= game.JobId then
                        lowestCount = server.playing
                        lowestServer = server.id
                    end
                end
                cursor = result.nextPageCursor or ""
            else
                break
            end
        until lowestServer or cursor == "" or attempts >= 3

        if lowestServer then
            badge.Text = "Teleporting..."
            badge.BackgroundColor3 = Color3.fromRGB(35, 185, 100)
            TeleportService:TeleportToPlaceInstance(placeId, lowestServer, LocalPlayer)
        else
            badge.Text = "Not Found"
            badge.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            task.wait(1.5)
            badge.Text = "Hop"
            ApplyTheme("Current")
        end
    end)
end

local HopBtn = Instance.new("TextButton")
HopBtn.Size = UDim2.new(1, -6, 0, 36)
HopBtn.Text = "   ⚡ Auto Low-Player Hop"
HopBtn.Font = Enum.Font.GothamSemibold
HopBtn.TextSize = 12
HopBtn.TextXAlignment = Enum.TextXAlignment.Left
HopBtn.LayoutOrder = 1
HopBtn.Parent = ServerHopTab
RegisterUI(HopBtn, "BackgroundColor3", "ItemBg", true)
RegisterUI(HopBtn, "TextColor3", "TextPrimary")

local HopCorner = Instance.new("UICorner")
HopCorner.CornerRadius = UDim.new(0, 6)
HopCorner.Parent = HopBtn

local HopBadge = Instance.new("TextLabel")
HopBadge.Size = UDim2.new(0, 75, 0, 20)
HopBadge.Position = UDim2.new(1, -83, 0.5, -10)
HopBadge.Text = "Hop"
HopBadge.TextColor3 = Color3.fromRGB(255, 255, 255)
HopBadge.Font = Enum.Font.GothamBold
HopBadge.TextSize = 10
HopBadge.Parent = HopBtn
RegisterUI(HopBadge, "BackgroundColor3", "Accent")

local HopBadgeCorner = Instance.new("UICorner")
HopBadgeCorner.CornerRadius = UDim.new(0, 4)
HopBadgeCorner.Parent = HopBadge

HopBtn.MouseButton1Click:Connect(function()
    HopToLowestServer(HopBadge)
end)

local HeaderContainer = Instance.new("Frame")
HeaderContainer.Size = UDim2.new(1, -6, 0, 26)
HeaderContainer.BackgroundTransparency = 1
HeaderContainer.LayoutOrder = 2
HeaderContainer.Parent = ServerHopTab

local PickHeader = Instance.new("TextLabel")
PickHeader.Size = UDim2.new(0.7, 0, 1, 0)
PickHeader.BackgroundTransparency = 1
PickHeader.Text = "SELECT 1-PLAYER SERVER"
PickHeader.TextXAlignment = Enum.TextXAlignment.Left
PickHeader.Font = Enum.Font.GothamBold
PickHeader.TextSize = 11
PickHeader.Parent = HeaderContainer
RegisterUI(PickHeader, "TextColor3", "AccentGlow")

local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.new(0, 75, 0, 22)
RefreshBtn.Position = UDim2.new(1, -75, 0, 0)
RefreshBtn.Text = "🔄 Refresh"
RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshBtn.Font = Enum.Font.GothamBold
RefreshBtn.TextSize = 10
RefreshBtn.Parent = HeaderContainer
RegisterUI(RefreshBtn, "BackgroundColor3", "Accent")

local RefreshCorner = Instance.new("UICorner")
RefreshCorner.CornerRadius = UDim.new(0, 4)
RefreshCorner.Parent = RefreshBtn

local ServerListFrame = Instance.new("Frame")
ServerListFrame.Size = UDim2.new(1, -6, 0, 260)
ServerListFrame.BorderSizePixel = 0
ServerListFrame.LayoutOrder = 3
ServerListFrame.Parent = ServerHopTab
RegisterUI(ServerListFrame, "BackgroundColor3", "SidebarBg", true)

local SLCorner = Instance.new("UICorner")
SLCorner.CornerRadius = UDim.new(0, 6)
SLCorner.Parent = ServerListFrame

local SLList = Instance.new("UIListLayout")
SLList.Padding = UDim.new(0, 4)
SLList.SortOrder = Enum.SortOrder.LayoutOrder
SLList.Parent = ServerListFrame

local SLPad = Instance.new("UIPadding")
SLPad.PaddingTop = UDim.new(0, 6)
SLPad.PaddingLeft = UDim.new(0, 6)
SLPad.PaddingRight = UDim.new(0, 6)
SLPad.Parent = ServerListFrame

local isFetching = false

local function FetchOnePlayerServers()
    if isFetching then return end
    isFetching = true

    for _, child in ipairs(ServerListFrame:GetChildren()) do
        if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
            child:Destroy()
        end
    end

    local StatusLbl = Instance.new("TextLabel")
    StatusLbl.Size = UDim2.new(1, 0, 0, 30)
    StatusLbl.BackgroundTransparency = 1
    StatusLbl.Text = "🔄 Searching for 1-Player Servers..."
    StatusLbl.Font = Enum.Font.Gotham
    StatusLbl.TextSize = 11
    StatusLbl.Parent = ServerListFrame
    RegisterUI(StatusLbl, "TextColor3", "TextSecondary")

    task.spawn(function()
        local placeId = game.PlaceId
        local foundServers = {}
        local cursor = ""
        local attempts = 0

        repeat
            attempts = attempts + 1
            local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
            if cursor ~= "" then
                url = url .. "&cursor=" .. cursor
            end

            local success, result = pcall(function()
                return HttpService:JSONDecode(game:HttpGet(url))
            end)

            if success and result and result.data then
                for _, server in ipairs(result.data) do
                    if server.playing == 1 and server.id ~= game.JobId then
                        table.insert(foundServers, server)
                        if #foundServers >= 7 then break end
                    end
                end
                cursor = result.nextPageCursor or ""
            else
                break
            end
        until #foundServers >= 7 or cursor == "" or attempts >= 4

        StatusLbl:Destroy()

        if #foundServers == 0 then
            local NoLbl = Instance.new("TextLabel")
            NoLbl.Size = UDim2.new(1, 0, 0, 30)
            NoLbl.BackgroundTransparency = 1
            NoLbl.Text = "❌ No 1-player servers found right now."
            NoLbl.TextColor3 = Color3.fromRGB(220, 80, 80)
            NoLbl.Font = Enum.Font.Gotham
            NoLbl.TextSize = 11
            NoLbl.Parent = ServerListFrame
            isFetching = false
            return
        end

        for i, serverData in ipairs(foundServers) do
            local item = Instance.new("TextButton")
            item.Size = UDim2.new(1, 0, 0, 32)
            item.Text = "   Server #" .. i .. "  (1 Player)"
            item.Font = Enum.Font.GothamSemibold
            item.TextSize = 11
            item.TextXAlignment = Enum.TextXAlignment.Left
            item.Parent = ServerListFrame
            RegisterUI(item, "BackgroundColor3", "ItemBg", true)
            RegisterUI(item, "TextColor3", "TextPrimary")

            local itemCorner = Instance.new("UICorner")
            itemCorner.CornerRadius = UDim.new(0, 4)
            itemCorner.Parent = item

            local joinBadge = Instance.new("TextLabel")
            joinBadge.Size = UDim2.new(0, 55, 0, 20)
            joinBadge.Position = UDim2.new(1, -61, 0.5, -10)
            joinBadge.BackgroundColor3 = Color3.fromRGB(35, 185, 100)
            joinBadge.Text = "Join"
            joinBadge.TextColor3 = Color3.fromRGB(255, 255, 255)
            joinBadge.Font = Enum.Font.GothamBold
            joinBadge.TextSize = 10
            joinBadge.Parent = item

            local jCorner = Instance.new("UICorner")
            jCorner.CornerRadius = UDim.new(0, 4)
            jCorner.Parent = joinBadge

            item.MouseButton1Click:Connect(function()
                joinBadge.Text = "Joining..."
                joinBadge.BackgroundColor3 = Color3.fromRGB(200, 150, 30)
                TeleportService:TeleportToPlaceInstance(placeId, serverData.id, LocalPlayer)
            end)
        end
        isFetching = false
    end)
end

RefreshBtn.MouseButton1Click:Connect(function()
    FetchOnePlayerServers()
end)

FetchOnePlayerServers()

-- -------------------------------------------------------
-- 📜 SCRIPTS TAB CONTENT
-- -------------------------------------------------------
local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(1, -6, 0, 30)
SearchBox.PlaceholderText = "🔍 Search scripts..."
SearchBox.PlaceholderColor3 = Color3.fromRGB(110, 130, 150)
SearchBox.Text = ""
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 12
SearchBox.ClearTextOnFocus = false
SearchBox.LayoutOrder = 1
SearchBox.Parent = ScriptsTab
RegisterUI(SearchBox, "BackgroundColor3", "CardBg", true)
RegisterUI(SearchBox, "TextColor3", "TextPrimary")

local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0, 6)
SearchCorner.Parent = SearchBox

local function AddSectionHeader(parent, text, color, layoutOrder)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -6, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.LayoutOrder = layoutOrder
    lbl.Parent = parent
end

local function AddScriptButton(parent, name, fetchUrl, layoutOrder)
    local btn = Instance.new("TextButton")
    btn.Name = name .. "Btn"
    btn.Size = UDim2.new(1, -6, 0, 36)
    btn.Text = "   " .. name
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.LayoutOrder = layoutOrder
    btn:SetAttribute("IsScriptButton", true)
    btn.Parent = parent
    RegisterUI(btn, "BackgroundColor3", "ItemBg", true)
    RegisterUI(btn, "TextColor3", "TextPrimary")

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    local badge = Instance.new("TextLabel")
    badge.Size = UDim2.new(0, 60, 0, 20)
    badge.Position = UDim2.new(1, -68, 0.5, -10)
    badge.Text = "Execute"
    badge.TextColor3 = Color3.fromRGB(255, 255, 255)
    badge.Font = Enum.Font.GothamBold
    badge.TextSize = 10
    badge.Parent = btn
    RegisterUI(badge, "BackgroundColor3", "Accent")

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 4)
    bCorner.Parent = badge

    btn.MouseButton1Click:Connect(function()
        badge.Text = "Running"
        badge.BackgroundColor3 = Color3.fromRGB(200, 150, 30)
        
        task.spawn(function()
            local success, err = pcall(function()
                loadstring(game:HttpGet(fetchUrl))()
            end)
            if success then
                badge.Text = "Loaded!"
                badge.BackgroundColor3 = Color3.fromRGB(35, 185, 100)
            else
                badge.Text = "Failed"
                badge.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
                warn("BloopsHub Error: ", err)
            end
            task.wait(1.5)
            badge.Text = "Execute"
            ApplyTheme("Current")
        end)
    end)
    return btn
end

-- 🟢 SECTION 1: NO KEY REQUIRED
AddSectionHeader(ScriptsTab, "🟢 NO KEY REQUIRED", Color3.fromRGB(75, 180, 125), 2)
AddScriptButton(ScriptsTab, "BlyxoHub", "https://flowauth.net/v1/loaders/69d3463240384f3a73fbe32c178093a2.lua", 3)
AddScriptButton(ScriptsTab, "Miranda", "https://raw.githubusercontent.com/miirandahub/loader/refs/heads/main/stealaeggs", 4)
AddScriptButton(ScriptsTab, "Lennon Hub", "https://raw.githubusercontent.com/lennonxscripts/lennonhub/main/stealaegg.lua", 5)

-- 🔴 SECTION 2: KEY REQUIRED
AddSectionHeader(ScriptsTab, "🔑 KEY REQUIRED", Color3.fromRGB(220, 85, 85), 6)
AddScriptButton(ScriptsTab, "Fyy Hub", "https://FyyCommunity.com", 7)
AddScriptButton(ScriptsTab, "OMG Hub", "https://raw.githubusercontent.com/Omgshit/Scripts/main/MainLoader.lua", 8)

-- Search Filtering
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local query = string.lower(SearchBox.Text)
    for _, child in ipairs(ScriptsTab:GetChildren()) do
        if child:IsA("TextButton") and child:GetAttribute("IsScriptButton") then
            child.Visible = (query == "" or string.find(string.lower(child.Text), query) ~= nil)
        end
    end
end)

-- -------------------------------------------------------
-- ⚙️ SETTINGS TAB CONTENT
-- -------------------------------------------------------

local UpdateToggleUI
local FillTrackUI

-- 💾 1. CONFIG MANAGEMENT SECTION
local ConfigHeader = Instance.new("TextLabel")
ConfigHeader.Size = UDim2.new(1, -6, 0, 20)
ConfigHeader.BackgroundTransparency = 1
ConfigHeader.Text = "💾 CONFIG MANAGEMENT"
ConfigHeader.TextXAlignment = Enum.TextXAlignment.Left
ConfigHeader.Font = Enum.Font.GothamBold
ConfigHeader.TextSize = 11
ConfigHeader.LayoutOrder = 1
ConfigHeader.Parent = SettingsTab
RegisterUI(ConfigHeader, "TextColor3", "AccentGlow")

local ConfigCard = Instance.new("Frame")
ConfigCard.Size = UDim2.new(1, -6, 0, 115)
ConfigCard.LayoutOrder = 2
ConfigCard.Parent = SettingsTab
RegisterUI(ConfigCard, "BackgroundColor3", "CardBg", true)

local ConfigCorner = Instance.new("UICorner")
ConfigCorner.CornerRadius = UDim.new(0, 8)
ConfigCorner.Parent = ConfigCard

-- Config Name Input Box
local ConfigInput = Instance.new("TextBox")
ConfigInput.Size = UDim2.new(1, -20, 0, 28)
ConfigInput.Position = UDim2.new(0, 10, 0, 10)
ConfigInput.PlaceholderText = "Type config name..."
ConfigInput.PlaceholderColor3 = Color3.fromRGB(110, 130, 150)
ConfigInput.Text = DefaultConfigName
ConfigInput.Font = Enum.Font.Gotham
ConfigInput.TextSize = 11
ConfigInput.ClearTextOnFocus = false
ConfigInput.Parent = ConfigCard
RegisterUI(ConfigInput, "BackgroundColor3", "ItemBg", true)
RegisterUI(ConfigInput, "TextColor3", "TextPrimary")

local CInputCorner = Instance.new("UICorner")
CInputCorner.CornerRadius = UDim.new(0, 6)
CInputCorner.Parent = ConfigInput

-- Config Action Buttons Row
local BtnSaveConfig = Instance.new("TextButton")
BtnSaveConfig.Size = UDim2.new(0.31, 0, 0, 26)
BtnSaveConfig.Position = UDim2.new(0, 10, 0, 46)
BtnSaveConfig.Text = "💾 Save"
BtnSaveConfig.Font = Enum.Font.GothamBold
BtnSaveConfig.TextSize = 10
BtnSaveConfig.Parent = ConfigCard
RegisterUI(BtnSaveConfig, "BackgroundColor3", "Accent")
RegisterUI(BtnSaveConfig, "TextColor3", "TextPrimary")

local BSCorner = Instance.new("UICorner")
BSCorner.CornerRadius = UDim.new(0, 6)
BSCorner.Parent = BtnSaveConfig

local BtnLoadConfig = Instance.new("TextButton")
BtnLoadConfig.Size = UDim2.new(0.31, 0, 0, 26)
BtnLoadConfig.Position = UDim2.new(0.345, 0, 0, 46)
BtnLoadConfig.Text = "📂 Load"
BtnLoadConfig.Font = Enum.Font.GothamBold
BtnLoadConfig.TextSize = 10
BtnLoadConfig.Parent = ConfigCard
RegisterUI(BtnLoadConfig, "BackgroundColor3", "ItemBg", true)
RegisterUI(BtnLoadConfig, "TextColor3", "TextPrimary")

local BLCorner = Instance.new("UICorner")
BLCorner.CornerRadius = UDim.new(0, 6)
BLCorner.Parent = BtnLoadConfig

local BtnDeleteConfig = Instance.new("TextButton")
BtnDeleteConfig.Size = UDim2.new(0.31, 0, 0, 26)
BtnDeleteConfig.Position = UDim2.new(0.69, 0, 0, 46)
BtnDeleteConfig.Text = "🗑️ Delete"
BtnDeleteConfig.Font = Enum.Font.GothamBold
BtnDeleteConfig.TextSize = 10
BtnDeleteConfig.Parent = ConfigCard
RegisterUI(BtnDeleteConfig, "BackgroundColor3", "ItemBg", true)
RegisterUI(BtnDeleteConfig, "TextColor3", "TextPrimary")

local BDCorner = Instance.new("UICorner")
BDCorner.CornerRadius = UDim.new(0, 6)
BDCorner.Parent = BtnDeleteConfig

-- Status Label
local ConfigStatusLbl = Instance.new("TextLabel")
ConfigStatusLbl.Size = UDim2.new(1, -20, 0, 20)
ConfigStatusLbl.Position = UDim2.new(0, 10, 0, 82)
ConfigStatusLbl.BackgroundTransparency = 1
ConfigStatusLbl.Text = "Status: Ready"
ConfigStatusLbl.TextXAlignment = Enum.TextXAlignment.Left
ConfigStatusLbl.Font = Enum.Font.Gotham
ConfigStatusLbl.TextSize = 10
ConfigStatusLbl.Parent = ConfigCard
RegisterUI(ConfigStatusLbl, "TextColor3", "TextSecondary")

-- Config Logic
local function SaveConfigData(configName)
    local targetName = configName and configName ~= "" and configName or DefaultConfigName
    local data = GetConfigState()
    data.ConfigName = targetName

    local filePath = ConfigFolder .. "/" .. targetName .. ".json"
    if writefile then
        writefile(filePath, HttpService:JSONEncode(data))
        DefaultConfigName = targetName
        ConfigInput.Text = targetName
        AutoExecEnabled = data.AutoExecute == true
        RegisterTeleportQueue(AutoExecEnabled)
        if UpdateToggleUI then UpdateToggleUI() end
        PersistCurrentState()
        ConfigStatusLbl.Text = "✅ Saved: " .. targetName
        ConfigStatusLbl.TextColor3 = Color3.fromRGB(80, 200, 120)
    else
        ConfigStatusLbl.Text = "❌ Executor does not support writefile."
        ConfigStatusLbl.TextColor3 = Color3.fromRGB(220, 80, 80)
    end
end

local function LoadConfigData(configName)
    local targetName = configName and configName ~= "" and configName or DefaultConfigName
    local filePath = ConfigFolder .. "/" .. targetName .. ".json"
    if isfile and isfile(filePath) and readfile then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(filePath))
        end)

        if success and result then
            ApplyConfigState(result)
            DefaultConfigName = targetName
            ConfigInput.Text = targetName
            AutoExecEnabled = result.AutoExecute == true
            RegisterTeleportQueue(AutoExecEnabled)
            if UpdateToggleUI then UpdateToggleUI() end
            SaveLastConfig(result)

            ConfigStatusLbl.Text = "✅ Loaded: " .. targetName
            ConfigStatusLbl.TextColor3 = Color3.fromRGB(80, 200, 120)
        else
            ConfigStatusLbl.Text = "❌ Corrupted config file."
            ConfigStatusLbl.TextColor3 = Color3.fromRGB(220, 80, 80)
        end
    else
        ConfigStatusLbl.Text = "❌ Config '" .. targetName .. "' not found."
        ConfigStatusLbl.TextColor3 = Color3.fromRGB(220, 80, 80)
    end
end

local function DeleteConfigData(configName)
    local targetName = configName and configName ~= "" and configName or DefaultConfigName
    local filePath = ConfigFolder .. "/" .. targetName .. ".json"
    if isfile and isfile(filePath) and delfile then
        delfile(filePath)
        if isfile and isfile(LastConfigFile) then
            delfile(LastConfigFile)
        end
        ConfigStatusLbl.Text = "🗑️ Deleted: " .. targetName
        ConfigStatusLbl.TextColor3 = Color3.fromRGB(220, 80, 80)
        ConfigInput.Text = DefaultConfigName
    else
        ConfigStatusLbl.Text = "❌ Could not delete or file missing."
        ConfigStatusLbl.TextColor3 = Color3.fromRGB(220, 80, 80)
    end
end

BtnSaveConfig.MouseButton1Click:Connect(function() SaveConfigData(ConfigInput.Text) end)
BtnLoadConfig.MouseButton1Click:Connect(function() LoadConfigData(ConfigInput.Text) end)
BtnDeleteConfig.MouseButton1Click:Connect(function() DeleteConfigData(ConfigInput.Text) end)

local function AutoLoadLastSavedConfig()
    if not (isfile and readfile and isfile(LastConfigFile)) then return end

    local success, result = pcall(function()
        return HttpService:JSONDecode(readfile(LastConfigFile))
    end)

    if success and result then
        DefaultConfigName = result.ConfigName or DefaultConfigName
        ConfigInput.Text = DefaultConfigName
        ApplyConfigState(result)
        if result.AutoExecute ~= nil then
            AutoExecEnabled = result.AutoExecute == true
            RegisterTeleportQueue(AutoExecEnabled)
            if UpdateToggleUI then UpdateToggleUI() end
        end
        PersistCurrentState()
    end
end

-- 🔄 2. AUTO-EXECUTE TOGGLE SECTION
local AutoExecHeader = Instance.new("TextLabel")
AutoExecHeader.Size = UDim2.new(1, -6, 0, 20)
AutoExecHeader.BackgroundTransparency = 1
AutoExecHeader.Text = "🔄 TELEPORT PERSISTENCE"
AutoExecHeader.TextXAlignment = Enum.TextXAlignment.Left
AutoExecHeader.Font = Enum.Font.GothamBold
AutoExecHeader.TextSize = 11
AutoExecHeader.LayoutOrder = 3
AutoExecHeader.Parent = SettingsTab
RegisterUI(AutoExecHeader, "TextColor3", "AccentGlow")

local AutoExecFrame = Instance.new("Frame")
AutoExecFrame.Size = UDim2.new(1, -6, 0, 45)
AutoExecFrame.LayoutOrder = 4
AutoExecFrame.Parent = SettingsTab
RegisterUI(AutoExecFrame, "BackgroundColor3", "CardBg", true)

local AECorner = Instance.new("UICorner")
AECorner.CornerRadius = UDim.new(0, 8)
AECorner.Parent = AutoExecFrame

local AutoExecLabel = Instance.new("TextLabel")
AutoExecLabel.Size = UDim2.new(0.7, 0, 1, 0)
AutoExecLabel.Position = UDim2.new(0, 12, 0, 0)
AutoExecLabel.BackgroundTransparency = 1
AutoExecLabel.Text = "Auto Re-Execute on Teleport"
AutoExecLabel.TextXAlignment = Enum.TextXAlignment.Left
AutoExecLabel.Font = Enum.Font.GothamSemibold
AutoExecLabel.TextSize = 11
AutoExecLabel.Parent = AutoExecFrame
RegisterUI(AutoExecLabel, "TextColor3", "TextPrimary")

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 44, 0, 22)
ToggleBtn.Position = UDim2.new(1, -56, 0.5, -11)
ToggleBtn.Text = ""
ToggleBtn.Parent = AutoExecFrame
RegisterUI(ToggleBtn, "BackgroundColor3", AutoExecEnabled and "Accent" or "ItemBg", true)

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleBtn

local ToggleCircle = Instance.new("Frame")
ToggleCircle.Size = UDim2.new(0, 16, 0, 16)
ToggleCircle.Position = AutoExecEnabled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ToggleCircle.Parent = ToggleBtn

local CircleCorner = Instance.new("UICorner")
CircleCorner.CornerRadius = UDim.new(1, 0)
CircleCorner.Parent = ToggleCircle

UpdateToggleUI = function()
    ToggleCircle.Position = AutoExecEnabled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    local theme = Themes[CurrentThemeKey] or Themes.Default
    ToggleBtn.BackgroundColor3 = AutoExecEnabled and theme.Accent or theme.ItemBg
end

ToggleBtn.MouseButton1Click:Connect(function()
    AutoExecEnabled = not AutoExecEnabled
    RegisterTeleportQueue(AutoExecEnabled)
    UpdateToggleUI()
    PersistCurrentState()
end)

-- 🎨 3. THEMES SECTION
local ThemeHeader = Instance.new("TextLabel")
ThemeHeader.Size = UDim2.new(1, -6, 0, 20)
ThemeHeader.BackgroundTransparency = 1
ThemeHeader.Text = "🎨 SELECT UI THEME"
ThemeHeader.TextXAlignment = Enum.TextXAlignment.Left
ThemeHeader.Font = Enum.Font.GothamBold
ThemeHeader.TextSize = 11
ThemeHeader.LayoutOrder = 5
ThemeHeader.Parent = SettingsTab
RegisterUI(ThemeHeader, "TextColor3", "AccentGlow")

local ColorContainer = Instance.new("Frame")
ColorContainer.Size = UDim2.new(1, -6, 0, 50)
ColorContainer.LayoutOrder = 6
ColorContainer.Parent = SettingsTab
RegisterUI(ColorContainer, "BackgroundColor3", "CardBg", true)

local CCCorner = Instance.new("UICorner")
CCCorner.CornerRadius = UDim.new(0, 8)
CCCorner.Parent = ColorContainer

local CCList = Instance.new("UIListLayout")
CCList.FillDirection = Enum.FillDirection.Horizontal
CCList.HorizontalAlignment = Enum.HorizontalAlignment.Left
CCList.VerticalAlignment = Enum.VerticalAlignment.Center
CCList.Padding = UDim.new(0, 12)
CCList.Parent = ColorContainer

local CCPad = Instance.new("UIPadding")
CCPad.PaddingLeft = UDim.new(0, 12)
CCPad.Parent = ColorContainer

local CircleButtons = {}

local function AddCircleColorButton(themeKey, displayColor)
    local circleBtn = Instance.new("TextButton")
    circleBtn.Size = UDim2.new(0, 32, 0, 32)
    circleBtn.BackgroundColor3 = displayColor
    circleBtn.Text = ""
    circleBtn.AutoButtonColor = false
    circleBtn.Parent = ColorContainer

    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = circleBtn

    local circleStroke = Instance.new("UIStroke")
    circleStroke.Thickness = 2
    circleStroke.Color = CurrentThemeKey == themeKey and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0)
    circleStroke.Transparency = CurrentThemeKey == themeKey and 0 or 0.6
    circleStroke.Parent = circleBtn

    CircleButtons[themeKey] = circleStroke

    circleBtn.MouseButton1Click:Connect(function()
        for key, stroke in pairs(CircleButtons) do
            if key == themeKey then
                stroke.Color = Color3.fromRGB(255, 255, 255)
                stroke.Transparency = 0
            else
                stroke.Color = Color3.fromRGB(0, 0, 0)
                stroke.Transparency = 0.6
            end
        end
        ApplyTheme(themeKey)
        UpdateToggleUI()
    end)
end

AddCircleColorButton("Default", Themes.Default.Accent)
AddCircleColorButton("Dark", Themes.Dark.Accent)
AddCircleColorButton("Purple", Themes.Purple.Accent)
AddCircleColorButton("Midnight", Themes.Midnight.Accent)
AddCircleColorButton("Emerald", Themes.Emerald.Accent)

-- ✨ 4. BACKGROUND TRANSPARENCY SLIDER SECTION
local TransHeader = Instance.new("TextLabel")
TransHeader.Size = UDim2.new(1, -6, 0, 20)
TransHeader.BackgroundTransparency = 1
TransHeader.Text = "✨ BACKGROUND TRANSPARENCY"
TransHeader.TextXAlignment = Enum.TextXAlignment.Left
TransHeader.Font = Enum.Font.GothamBold
TransHeader.TextSize = 11
TransHeader.LayoutOrder = 7
TransHeader.Parent = SettingsTab
RegisterUI(TransHeader, "TextColor3", "AccentGlow")

local SliderFrame = Instance.new("Frame")
SliderFrame.Size = UDim2.new(1, -6, 0, 50)
SliderFrame.LayoutOrder = 8
SliderFrame.Parent = SettingsTab
RegisterUI(SliderFrame, "BackgroundColor3", "CardBg", true)

local SliderCorner = Instance.new("UICorner")
SliderCorner.CornerRadius = UDim.new(0, 8)
SliderCorner.Parent = SliderFrame

local SliderValLbl = Instance.new("TextLabel")
SliderValLbl.Size = UDim2.new(1, -20, 0, 18)
SliderValLbl.Position = UDim2.new(0, 10, 0, 6)
SliderValLbl.BackgroundTransparency = 1
SliderValLbl.Text = "Transparency: 0%"
SliderValLbl.TextXAlignment = Enum.TextXAlignment.Left
SliderValLbl.Font = Enum.Font.GothamSemibold
SliderValLbl.TextSize = 11
SliderValLbl.Parent = SliderFrame
RegisterUI(SliderValLbl, "TextColor3", "TextPrimary")

local Track = Instance.new("Frame")
Track.Size = UDim2.new(1, -20, 0, 6)
Track.Position = UDim2.new(0, 10, 0, 30)
Track.Parent = SliderFrame
RegisterUI(Track, "BackgroundColor3", "ItemBg")

local TrackCorner = Instance.new("UICorner")
TrackCorner.CornerRadius = UDim.new(1, 0)
TrackCorner.Parent = Track

local Fill = Instance.new("Frame")
Fill.Size = UDim2.new(0, 0, 1, 0)
Fill.Parent = Track
RegisterUI(Fill, "BackgroundColor3", "Accent")

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(1, 0)
FillCorner.Parent = Fill

local SliderBtn = Instance.new("TextButton")
SliderBtn.Size = UDim2.new(1, 0, 1, 0)
SliderBtn.BackgroundTransparency = 1
SliderBtn.Text = ""
SliderBtn.Parent = Track

local isSliding = false

FillTrackUI = function()
    local ratio = GlobalTransparency / 0.85
    Fill.Size = UDim2.new(math.clamp(ratio, 0, 1), 0, 1, 0)
    SliderValLbl.Text = "Transparency: " .. math.floor(ratio * 100) .. "%"
end

local function UpdateSlider(input)
    local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
    GlobalTransparency = pos * 0.85
    FillTrackUI()
    ApplyTheme("Current")
end

SliderBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isSliding = true
        UpdateSlider(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isSliding = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        UpdateSlider(input)
    end
end)

-- Window Toggle Controls
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
        OpenButton.Visible = not MainFrame.Visible
    end
end)

BtnMin.MouseButton1Click:Connect(function() MainFrame.Visible = false OpenButton.Visible = true end)
OpenButton.MouseButton1Click:Connect(function() OpenButton.Visible = false MainFrame.Visible = true end)
BtnClose.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Apply default theme on script startup
ApplyTheme("Default")
AutoLoadLastSavedConfig()
