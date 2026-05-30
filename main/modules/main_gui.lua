-- ══════════════════════════════════════════════════════════════
-- 🏠 main_gui.lua — Interface principal, tabs, main()
-- Depende de: todos os módulos anteriores
-- ══════════════════════════════════════════════════════════════

local TMI              = _G.TMI
local player           = TMI.player
local TweenService     = TMI.TweenService
local HttpService      = TMI.HttpService
local ICONS            = TMI.ICONS
local RGB_COLORS       = TMI.RGB_COLORS
local _cache           = TMI._cache

local makeIcon            = TMI.makeIcon
local makeFloatingPanel   = TMI.makeFloatingPanel
local makePanelHeader     = TMI.makePanelHeader
local animRGB             = TMI.animRGB
local spinIcon            = TMI.spinIcon
local makeSwitch          = TMI.makeSwitch

local createSplashScreen      = TMI.createSplashScreen
local loadFullCache           = TMI.loadFullCache
local viewMusicList           = TMI.viewMusicList
local updateLeaderboard       = TMI.updateLeaderboard
local createProfileView       = TMI.createProfileView
local showKeySystem           = TMI.showKeySystem
local createFilterPanel       = TMI.createFilterPanel
local renderFilteredList      = TMI.renderFilteredList
local createFloatingButton    = TMI.createFloatingButton

-- funções auxiliares da aba publicar (definidas em music_list.lua)
local createTitle           = TMI.createTitle
local createInputField      = TMI.createInputField
local createCategoryDropdown = TMI.createCategoryDropdown
local createUserPreview     = TMI.createUserPreview
local createFeedback        = TMI.createFeedback
local createStyledButton    = TMI.createStyledButton
local publishMusic          = TMI.publishMusic

local function createMainGUI()
	local gui = Instance.new("ScreenGui")
	gui.Name = "EnhancedMusicPublisher_v3_PageSys"
	gui.Parent = player:WaitForChild("PlayerGui")
	gui.ResetOnSpawn = false
	
	local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.Size = UDim2.new(0.9, 0, 0.85, 0)
    mainFrame.Position = UDim2.new(0.5, 0, 0.45, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = gui
    mainFrame.ClipsDescendants = true 

    local uiAspectRatio = Instance.new("UIAspectRatioConstraint")
    uiAspectRatio.AspectRatio = 0.8
    uiAspectRatio.AspectType = Enum.AspectType.ScaleWithParentSize
    uiAspectRatio.Parent = mainFrame
	
	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 20)
	mainCorner.Parent = mainFrame
	
	local borderFrame = Instance.new("UIStroke")
borderFrame.Name = "BorderFrame"
borderFrame.Color = RGB_COLORS[1]
borderFrame.Thickness = 3
borderFrame.Transparency = 0
borderFrame.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
borderFrame.Parent = mainFrame

local tipLabel = Instance.new("TextLabel")
    tipLabel.Name = "TipLabel"
    tipLabel.Size = UDim2.new(1, -8, 0, 14)
    tipLabel.Position = UDim2.new(0, 4, 0, 44)
    tipLabel.BackgroundTransparency = 1
    tipLabel.Text = "💡 Clique na foto do player para acessar o perfil!"
    tipLabel.TextColor3 = Color3.fromRGB(160, 160, 190)
    tipLabel.TextSize = 10
    tipLabel.Font = Enum.Font.Gotham
    tipLabel.TextXAlignment = Enum.TextXAlignment.Center
    tipLabel.TextTruncate = Enum.TextTruncate.AtEnd
    tipLabel.Parent = mainFrame
	
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0, 30, 0, 30)
	closeButton.Position = UDim2.new(0.98, -35, 0.02, 0)
	closeButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
	closeButton.BorderSizePixel = 0
	closeButton.Text = ""
	closeButton.TextSize = 35
	closeButton.Font = Enum.Font.GothamBold
	closeButton.ZIndex = 10
	closeButton.Parent = mainFrame
	Instance.new("UICorner", closeButton).CornerRadius = UDim.new(1, 0)
	makeIcon(closeButton, ICONS.CLOSE, UDim2.new(0, 18, 0, 18), UDim2.new(0.5, -9, 0.5, -9), 11)

    local pagesContainer = Instance.new("Frame")
    pagesContainer.Name = "PagesContainer"
    pagesContainer.Size = UDim2.new(1, 0, 1, -60)
    pagesContainer.Position = UDim2.new(0, 0, 0, 60)
    pagesContainer.BackgroundTransparency = 1
    pagesContainer.Parent = mainFrame

	-- PÁGINA 1: HOME
	local homeScroll = Instance.new("ScrollingFrame")
	homeScroll.Name = "HomeScroll"
	homeScroll.Size = UDim2.new(1, -10, 1, -10)
	homeScroll.Position = UDim2.new(0, 5, 0, 5)
	homeScroll.BackgroundTransparency = 1
	homeScroll.BorderSizePixel = 0
	homeScroll.ScrollBarThickness = 6
	homeScroll.ScrollBarImageColor3 = RGB_COLORS[1]
	homeScroll.CanvasSize = UDim2.new(0, 0, 0, 650)
	homeScroll.Visible = true
	homeScroll.Parent = pagesContainer

    -- PÁGINA 2: LEADERBOARD
    local leaderboardScroll = Instance.new("ScrollingFrame")
	leaderboardScroll.Name = "LeaderboardScroll"
	leaderboardScroll.Size = UDim2.new(1, -10, 1, -10)
	leaderboardScroll.Position = UDim2.new(0, 5, 0, 5)
	leaderboardScroll.BackgroundTransparency = 1
	leaderboardScroll.BorderSizePixel = 0
	leaderboardScroll.ScrollBarThickness = 6
	leaderboardScroll.ScrollBarImageColor3 = RGB_COLORS[1]
	leaderboardScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	leaderboardScroll.Visible = false
	leaderboardScroll.Parent = pagesContainer
	
	-- PÁGINA 3: PUBLICAR (nova página para o formulário)
local publishScroll = Instance.new("ScrollingFrame")
publishScroll.Name = "PublishScroll"
publishScroll.Size = UDim2.new(1, -10, 1, -10)
publishScroll.Position = UDim2.new(0, 5, 0, 5)
publishScroll.BackgroundTransparency = 1
publishScroll.BorderSizePixel = 0
publishScroll.ScrollBarThickness = 6
publishScroll.ScrollBarImageColor3 = RGB_COLORS[1]
publishScroll.CanvasSize = UDim2.new(0, 0, 0, 650)
publishScroll.Visible = false
publishScroll.Parent = pagesContainer

spawn(function()
	local colorIndex = 1
	while mainFrame.Parent do
		colorIndex = colorIndex % #RGB_COLORS + 1
        local targetColor = RGB_COLORS[colorIndex]
		TweenService:Create(homeScroll, TweenInfo.new(2, Enum.EasingStyle.Sine), {ScrollBarImageColor3 = targetColor}):Play()
        TweenService:Create(leaderboardScroll, TweenInfo.new(2, Enum.EasingStyle.Sine), {ScrollBarImageColor3 = targetColor}):Play()
        TweenService:Create(publishScroll, TweenInfo.new(2, Enum.EasingStyle.Sine), {ScrollBarImageColor3 = targetColor}):Play()
		wait(2)
	end
end)

local musicListFrame -- declaração antecipada para os handlers das abas

-- ══════════════════════════════════════════════════════
-- SISTEMA DE ABAS - SCROLL COM FADE REAL NOS BOTÕES
-- ══════════════════════════════════════════════════════

local TAB_W = 85
local NUM_TABS = 4
local FADE_WIDTH = 40
local FADE_START = 30 -- distância para começar o fade

--━━━━━━━━━━━━━━━━┃╋┃
-- 📦 CONTAINER SCROLL
--━━━━━━━━━━━━━━━━┃╋┃

local tabFrame = Instance.new("ScrollingFrame")
tabFrame.Name = "TabFrame"
tabFrame.Size = UDim2.new(0.75, 0, 0, 40)
tabFrame.Position = UDim2.new(0.135, 0, 0.02, 0)
tabFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
tabFrame.BackgroundTransparency = 1
tabFrame.ClipsDescendants = true
tabFrame.ScrollBarThickness = 0
tabFrame.ScrollingDirection = Enum.ScrollingDirection.X
tabFrame.ElasticBehavior = Enum.ElasticBehavior.Always
tabFrame.CanvasSize = UDim2.new(0, TAB_W * NUM_TABS, 0, 0)
tabFrame.ZIndex = 3
tabFrame.Parent = mainFrame

Instance.new("UICorner", tabFrame).CornerRadius = UDim.new(0, 20)

local tabBg = Instance.new("UIGradient", tabFrame)
tabBg.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(35,35,50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(22,22,32))
})
tabBg.Rotation = 90

--━━━━━━━━━━━━━━━━┃╋┃
-- 🌫️ OVERLAY (ACABAMENTO)
--━━━━━━━━━━━━━━━━┃╋┃

local function createFade(isLeft)
    local fade = Instance.new("Frame")
    fade.Size = UDim2.new(0, FADE_WIDTH, 0, 40)
    fade.BackgroundTransparency = 1
    fade.BorderSizePixel = 0
    fade.ZIndex = 8
    fade.Parent = mainFrame

    if isLeft then
        fade.Position = UDim2.new(0.135, 0, 0.02, 0)
    else
        fade.Position = UDim2.new(0.135 + 0.75, -FADE_WIDTH, 0.02, 0)
    end

    local grad = Instance.new("UIGradient", fade)
    local baseColor = Color3.fromRGB(28, 28, 38)

    grad.Color = ColorSequence.new(baseColor, baseColor)

    if isLeft then
        grad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1)
        })
    else
        grad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0)
        })
    end

    return fade
end

local fadeLeft = createFade(true)
local fadeRight = createFade(false)

--━━━━━━━━━━━━━━━━┃╋┃
-- 🎯 INDICADOR
--━━━━━━━━━━━━━━━━┃╋┃

local tabIndicator = Instance.new("Frame")
tabIndicator.Name = "TabIndicator"
tabIndicator.Size = UDim2.new(0, TAB_W - 6, 1, -6)
tabIndicator.Position = UDim2.new(0, 3, 0, 3)
tabIndicator.BackgroundColor3 = RGB_COLORS[1]
tabIndicator.ZIndex = 2
tabIndicator.Parent = tabFrame

Instance.new("UICorner", tabIndicator).CornerRadius = UDim.new(0, 17)

local tabIndGrad = Instance.new("UIGradient", tabIndicator)
tabIndGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(200,200,200))
})
tabIndGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.15),
    NumberSequenceKeypoint.new(1, 0.05)
})
tabIndGrad.Rotation = 90

local tabIndShadow = Instance.new("UIStroke", tabIndicator)
tabIndShadow.Thickness = 1
tabIndShadow.Transparency = 0.5
tabIndShadow.Color = Color3.fromRGB(255,255,255)

--━━━━━━━━━━━━━━━━┃╋┃
-- 🔄 FADE REAL NOS BOTÕES
--━━━━━━━━━━━━━━━━┃╋┃

local function updateTabFade()
    local frameLeft = tabFrame.AbsolutePosition.X
    local frameRight = frameLeft + tabFrame.AbsoluteSize.X

    local maxFade = 0.65 -- nunca some totalmente
    local fadeStart = 18 -- começa BEM perto da borda

    for _, obj in ipairs(tabFrame:GetChildren()) do
        if obj:IsA("TextButton") then
            
            local left = obj.AbsolutePosition.X
            local right = left + obj.AbsoluteSize.X

            local leftDist = left - frameLeft
            local rightDist = frameRight - right

            local transparency = 0

            if leftDist < fadeStart then
                transparency = (1 - (leftDist / fadeStart)) * maxFade
            elseif rightDist < fadeStart then
                transparency = (1 - (rightDist / fadeStart)) * maxFade
            end

            transparency = math.clamp(transparency, 0, maxFade)

            -- 🔹 TEXTO
            obj.TextTransparency = transparency

            -- 🔹 ÍCONE (se tiver)
            for _, child in ipairs(obj:GetChildren()) do
                if child:IsA("ImageLabel") then
                    child.ImageTransparency = transparency
                end
            end
        end
    end

    --━━━━━━━━━━━━━━━━┃╋┃
    -- 🎯 INDICADOR (fade também)
    --━━━━━━━━━━━━━━━━┃╋┃

    local indLeft = tabIndicator.AbsolutePosition.X
    local indRight = indLeft + tabIndicator.AbsoluteSize.X

    local leftDist = indLeft - frameLeft
    local rightDist = frameRight - indRight

    local indTransparency = 0

    if leftDist < fadeStart then
        indTransparency = (1 - (leftDist / fadeStart)) * 0.8
    elseif rightDist < fadeStart then
        indTransparency = (1 - (rightDist / fadeStart)) * 0.8
    end

    indTransparency = math.clamp(indTransparency, 0, 0.8)

    tabIndicator.BackgroundTransparency = indTransparency
end

--━━━━━━━━━━━━━━━━┃╋┃
-- 🔄 VISIBILIDADE DO OVERLAY
--━━━━━━━━━━━━━━━━┃╋┃

local function updateFadeOverlay()
    local maxScroll = tabFrame.CanvasSize.X.Offset - tabFrame.AbsoluteSize.X
    local scroll = tabFrame.CanvasPosition.X

    fadeLeft.Visible = scroll > 2
    fadeRight.Visible = scroll < maxScroll - 2
end

-- Eventos
tabFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
    updateFadeOverlay()
    updateTabFade()
end)

tabFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
    updateFadeOverlay()
    updateTabFade()
end)

task.defer(function()
    updateFadeOverlay()
    updateTabFade()
end)

--━━━━━━━━━━━━━━━━┃╋┃
-- 📑 DEFINIÇÃO DAS ABAS
--━━━━━━━━━━━━━━━━┃╋┃

local tabDefs = {
    {key = "btnHome",     icon = ICONS.TAB_HOME,     text = "Início"},
    {key = "btnPublicar", icon = ICONS.TAB_PUBLICAR,  text = "Publicar"},
    {key = "btnMusicas",  icon = ICONS.TAB_MUSICAS,   text = "Músicas"},
    {key = "btnRank",     icon = ICONS.TAB_TOP10,     text = "Top 10"},
}

local tabButtonRefs = {}

for i, def in ipairs(tabDefs) do
    local btn = Instance.new("TextButton")
    btn.Name = def.key == "btnMusicas" and "BtnMusicas" or def.key
    btn.Size = UDim2.new(0, TAB_W, 1, 0)
    btn.Position = UDim2.new(0, (i-1) * TAB_W, 0, 0)
    btn.BackgroundTransparency = 1
    btn.Text = "  " .. def.text   -- espaço reservado para o ícone
    -- Ícone da aba (ImageLabel à esquerda do texto)
    local tabIcon = Instance.new("ImageLabel", btn)
    tabIcon.Size = UDim2.new(0, 16, 0, 16)
    tabIcon.Position = UDim2.new(0, 4, 0.5, -8)
    tabIcon.BackgroundTransparency = 1
    tabIcon.Image = def.icon
    tabIcon.ScaleType = Enum.ScaleType.Fit
    tabIcon.ZIndex = 5
    btn.TextColor3 = i == 1 and Color3.fromRGB(255,255,255) or Color3.fromRGB(170,170,195)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = i == 1 and 13 or 12
    btn.ZIndex = 4
    btn.AutoButtonColor = false
    btn.Parent = tabFrame

    -- Hover glow sutil
    btn.MouseEnter:Connect(function()
        if btn.TextColor3 ~= Color3.fromRGB(255,255,255) then
            TweenService:Create(btn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(220,220,240)}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if btn.TextColor3 ~= Color3.fromRGB(255,255,255) then
            TweenService:Create(btn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(170,170,195)}):Play()
        end
    end)

    tabButtonRefs[i] = btn
end

local btnHome     = tabButtonRefs[1]
local btnPublicar = tabButtonRefs[2]
local btnMusicas  = tabButtonRefs[3]
local btnRank     = tabButtonRefs[4]

-- Atualiza os fades conforme a posição do scroll
local function updateTabFades()
    local pos = tabFrame.CanvasPosition.X
    local maxScroll = math.max(0, TAB_W * NUM_TABS - tabFrame.AbsoluteSize.X)
    fadeLeft.Visible  = pos > 2
    fadeRight.Visible = pos < maxScroll - 2
end
tabFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(updateTabFades)
-- Aguarda layout para checar
task.delay(0.1, updateTabFades)

-- Função central de mudança de aba com animações
local function switchTab(index)
    -- 1. Desliza o indicador
    TweenService:Create(tabIndicator, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, (index-1)*TAB_W + 3, 0, 3)
    }):Play()
    -- 2. Auto-scroll para mostrar o botão ativo
    local targetX = math.clamp((index-1)*TAB_W - 20, 0, math.max(0, TAB_W*NUM_TABS - tabFrame.AbsoluteSize.X))
    TweenService:Create(tabFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
        CanvasPosition = Vector2.new(targetX, 0)
    }):Play()
    -- 3. Animação de texto/escala dos botões
    for i, btn in ipairs(tabButtonRefs) do
        local isActive = (i == index)
        TweenService:Create(btn, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            TextColor3 = isActive and Color3.fromRGB(255,255,255) or Color3.fromRGB(170,170,195),
            TextSize   = isActive and 13 or 12
        }):Play()
    end
    task.delay(0.1, updateTabFades)
end

-- Lógica de cada aba
btnHome.MouseButton1Click:Connect(function()
    switchTab(1)
    local mlf = pagesContainer:FindFirstChild("MusicListFrame")
    if mlf then mlf.Visible = false end
    pagesContainer.Visible = true
    publishScroll.Visible = false
    leaderboardScroll.Visible = false
    homeScroll.Visible = true
    homeScroll.Position = UDim2.new(-1, 0, 0, 5)
    TweenService:Create(homeScroll, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 5, 0, 5)
    }):Play()
end)

btnPublicar.MouseButton1Click:Connect(function()
    switchTab(2)
    local mlf = pagesContainer:FindFirstChild("MusicListFrame")
    if mlf then mlf.Visible = false end
    pagesContainer.Visible = true
    homeScroll.Visible = false
    leaderboardScroll.Visible = false
    publishScroll.Visible = true
    publishScroll.Position = UDim2.new(1, 0, 0, 5)
    TweenService:Create(publishScroll, TweenInfo.new(0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 5, 0, 5)
    }):Play()
end)

btnRank.MouseButton1Click:Connect(function()
    switchTab(4)
    local mlf = pagesContainer:FindFirstChild("MusicListFrame")
    if mlf then mlf.Visible = false end
    pagesContainer.Visible = true
    homeScroll.Visible = false
    publishScroll.Visible = false
    leaderboardScroll.Visible = true
    leaderboardScroll.Position = UDim2.new(1, 0, 0, 5)
    TweenService:Create(leaderboardScroll, TweenInfo.new(0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 5, 0, 5)
    }):Play()
    if getfenv().updateLeaderboard then
        getfenv().updateLeaderboard(leaderboardScroll, mainFrame)
    end
end)

local function resetTabVisuals()
    switchTab(1)
    local mlf = pagesContainer:FindFirstChild("MusicListFrame")
    if mlf then mlf.Visible = false end
    pagesContainer.Visible = true
    publishScroll.Visible = false
    leaderboardScroll.Visible = false
    homeScroll.Visible = true
end
	
	-- Frame para lista de músicas
	local musicListFrame = Instance.new("Frame")
	musicListFrame.Name = "MusicListFrame"
	musicListFrame.Size = UDim2.new(1, -10, 1, -10)
	musicListFrame.Position = UDim2.new(0, 5, 0, 5)
	musicListFrame.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
	musicListFrame.BorderSizePixel = 0
	musicListFrame.Visible = false
	musicListFrame.ZIndex = 20
	musicListFrame.BackgroundTransparency = 1
	musicListFrame.Parent = pagesContainer
	
	local musicListScroll = Instance.new("ScrollingFrame")
	musicListScroll.Name = "MusicListScroll"
	musicListScroll.Position = UDim2.new(0, 5, 0.22, 0)
    musicListScroll.Size = UDim2.new(1, -10, 0.75, 0)
	musicListScroll.BackgroundTransparency = 1
	musicListScroll.BorderSizePixel = 0
	musicListScroll.ScrollBarThickness = 8
	musicListScroll.ScrollBarImageColor3 = RGB_COLORS[1]
	musicListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	musicListScroll.ZIndex = 20
	musicListScroll.Parent = musicListFrame
	
	local musicListTitle = Instance.new("TextLabel")
	musicListTitle.Size = UDim2.new(1, -80, 0, 60); musicListTitle.Position = UDim2.new(0, 20, 0, -15); musicListTitle.BackgroundTransparency = 1; musicListTitle.Text = "🎵 MÚSICAS PUBLICADAS"; musicListTitle.TextColor3 = Color3.fromRGB(255, 255, 255);
	musicListTitle.TextSize = 21; musicListTitle.Font = Enum.Font.GothamBold; musicListTitle.TextXAlignment = Enum.TextXAlignment.Left; musicListTitle.ZIndex = 20;
	musicListTitle.Parent = musicListFrame
	
    local searchFrame = Instance.new("Frame"); searchFrame.Name = "SearchFrame"; searchFrame.Size = UDim2.new(0.95, 0, 0.08, 0);
	searchFrame.Position = UDim2.new(0.025, 0, 0, 32); searchFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40); searchFrame.ZIndex = 20;
	searchFrame.Parent = musicListFrame
    Instance.new("UICorner", searchFrame).CornerRadius = UDim.new(0, 8)

    local searchInput = Instance.new("TextBox");
	searchInput.Name = "SearchInput"; searchInput.Size = UDim2.new(1, -50, 1, 0); searchInput.Position = UDim2.new(0, 10, 0, 0); searchInput.BackgroundTransparency = 1;
	searchInput.PlaceholderText = "Pesquisar por nome..."; searchInput.Text = ""; searchInput.TextColor3 = Color3.fromRGB(255, 255, 255); searchInput.Font = Enum.Font.Gotham; searchInput.TextXAlignment = Enum.TextXAlignment.Left;
	searchInput.TextSize = 18; searchInput.ZIndex = 20; searchInput.Parent = searchFrame

    -- Botão de tipo de pesquisa: ícone puro, abre painel de escolha
    local filterTypeBtn = Instance.new("TextButton"); filterTypeBtn.Name = "FilterType";
	filterTypeBtn.Size = UDim2.new(0, 30, 0, 30); filterTypeBtn.Position = UDim2.new(1, -36, 0.5, -15);
    filterTypeBtn.BackgroundTransparency = 1; filterTypeBtn.Text = ""; filterTypeBtn.ZIndex = 20;
    filterTypeBtn.Parent = searchFrame
    makeIcon(filterTypeBtn, ICONS.SEARCH_TYPE, UDim2.new(0, 22, 0, 22), UDim2.new(0.5, -11, 0.5, -11), 21)

    -- Botão de filtro: acima da barra de pesquisa, no canto direito do musicListFrame
    local filterOpenBtn = Instance.new("TextButton")
    filterOpenBtn.Name   = "FilterOpenBtn"
    filterOpenBtn.Size   = UDim2.new(0, 28, 0, 28)
    filterOpenBtn.Position = UDim2.new(1, -36, 0, 0)
    filterOpenBtn.BackgroundTransparency = 1
    filterOpenBtn.BorderSizePixel = 0
    filterOpenBtn.Text   = ""
    filterOpenBtn.ZIndex = 21
    filterOpenBtn.Parent = musicListFrame
    makeIcon(filterOpenBtn, ICONS.FILTER, UDim2.new(0, 22, 0, 22), UDim2.new(0.5, -11, 0.5, -11), 22)

    -- Ponto vermelho no canto inferior esquerdo do ícone (filtro ativo)
    local filterDot = Instance.new("Frame", filterOpenBtn)
    filterDot.Name   = "FilterDot"
    filterDot.Size   = UDim2.new(0, 7, 0, 7)
    filterDot.Position = UDim2.new(0, 1, 1, -8)
    filterDot.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    filterDot.BorderSizePixel  = 0
    filterDot.ZIndex  = 23
    filterDot.Visible = false
    Instance.new("UICorner", filterDot).CornerRadius = UDim.new(1, 0)

    musicListScroll.Position = UDim2.new(0, 10, 0, 68);
	musicListScroll.Size = UDim2.new(1, -20, 1, -75)
	
	-- Retornamos resetTabVisuals para ser usado na função main
	return gui, mainFrame, borderFrame, homeScroll, leaderboardScroll, publishScroll, closeButton, musicListFrame, musicListScroll, resetTabVisuals, btnMusicas, btnPublicar, tipLabel
end

local function animateRGBBorder(borderFrame, tabIndicator, extraBorders)
	local colorIndex = 1
	spawn(function()
		while borderFrame.Parent do
			colorIndex = colorIndex % #RGB_COLORS + 1
			local c = RGB_COLORS[colorIndex]
			TweenService:Create(borderFrame, TweenInfo.new(1, Enum.EasingStyle.Sine), {Color = c}):Play()
			if tabIndicator and tabIndicator.Parent then
				TweenService:Create(tabIndicator, TweenInfo.new(1, Enum.EasingStyle.Sine), {BackgroundColor3 = c}):Play()
			end
			if extraBorders then
				for _, eb in ipairs(extraBorders) do
					if eb and eb.Parent then
						TweenService:Create(eb, TweenInfo.new(1, Enum.EasingStyle.Sine), {Color = c}):Play()
					end
				end
			end
			wait(1)
		end
	end)
end

local function createTitle(parent)
    local titleFrame = Instance.new("Frame")
    titleFrame.Size = UDim2.new(1, -40, 0, 90)
    titleFrame.Position = UDim2.new(0, 20, 0, 20)
    titleFrame.BackgroundTransparency = 1
    titleFrame.Parent = parent

    local titleImage = Instance.new("ImageLabel")
    titleImage.Size = UDim2.new(1, 0, 0, 145)
    titleImage.Position = UDim2.new(0, 0, 0, -40)
    titleImage.BackgroundTransparency = 1
    titleImage.Image = ICONS.TITLE_IMG
    titleImage.ScaleType = Enum.ScaleType.Fit
    titleImage.ImageTransparency = 0
    -- Remove o fundo quadriculado (branco/cinza) aplicando transparência no fundo
    titleImage.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    titleImage.BorderSizePixel = 0
    titleImage.Parent = titleFrame

    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.Size = UDim2.new(1, 0, 0, 20)
    subtitleLabel.Position = UDim2.new(0, 0, 1, -20)
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.Text = "Compartilhe seus IDs favoritos do Roblox"
    subtitleLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    subtitleLabel.TextSize = 14
    subtitleLabel.Font = Enum.Font.Gotham
    subtitleLabel.Parent = titleFrame
    return titleFrame
end

local function createInputField(parent, placeholder, posY, maxLength)
	local inputFrame = Instance.new("Frame")
	inputFrame.Size = UDim2.new(1, -40, 0, 50)
	inputFrame.Position = UDim2.new(0, 20, 0, posY)
	inputFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	inputFrame.BorderSizePixel = 0
	inputFrame.Parent = parent
	Instance.new("UICorner", inputFrame).CornerRadius = UDim.new(0, 10)
	
	local inputBox = Instance.new("TextBox")
	inputBox.Size = UDim2.new(1, -20, 1, -10)
	inputBox.Position = UDim2.new(0, 10, 0, 5)
	inputBox.BackgroundTransparency = 1
	inputBox.PlaceholderText = placeholder
	inputBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
	inputBox.Text = ""
	inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	inputBox.TextSize = 16
	inputBox.Font = Enum.Font.Gotham
	inputBox.TextXAlignment = Enum.TextXAlignment.Left
	inputBox.Parent = inputFrame
	
	local charCounter = Instance.new("TextLabel")
	charCounter.Size = UDim2.new(0, 60, 0, 20)
	charCounter.Position = UDim2.new(1, -70, 1, -65)
	charCounter.BackgroundTransparency = 1
	charCounter.Text = "0/"..maxLength
	charCounter.TextColor3 = Color3.fromRGB(120, 120, 120)
	charCounter.TextSize = 12
	charCounter.Font = Enum.Font.Gotham
	charCounter.Parent = inputFrame
	
	inputBox.Focused:Connect(function()
		TweenService:Create(inputFrame, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
	end)
	
	inputBox.FocusLost:Connect(function()
		TweenService:Create(inputFrame, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}):Play()
	end)
	
	inputBox:GetPropertyChangedSignal("Text"):Connect(function()
		local currentLength = #inputBox.Text
		charCounter.Text = currentLength.."/"..maxLength
		if currentLength > maxLength then inputBox.Text = string.sub(inputBox.Text, 1, maxLength) end
	end)
	return inputBox
end

local function createCategoryDropdown(parent, posY)
    local categories = CATEGORIES_LIST  -- mesma lista de CATEGORIES_LIST (editar + publicar em sincronia)
    local selectedCategory = ""
    local isOpen = false

    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Size = UDim2.new(1, -40, 0, 50)
    dropdownFrame.Position = UDim2.new(0, 20, 0, posY)
    dropdownFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    dropdownFrame.ZIndex = 10
    dropdownFrame.Parent = parent
    Instance.new("UICorner", dropdownFrame).CornerRadius = UDim.new(0, 10)
    
    local uiStroke = Instance.new("UIStroke", dropdownFrame)
    uiStroke.Color = Color3.fromRGB(60, 60, 70)
    uiStroke.Thickness = 1.2

    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Size = UDim2.new(1, 0, 1, 0)
    dropdownButton.BackgroundTransparency = 1
    dropdownButton.Text = "Selecionar Categoria"
    dropdownButton.TextColor3 = Color3.fromRGB(180, 180, 180)
    dropdownButton.TextSize = 15
    dropdownButton.Font = Enum.Font.GothamMedium
    dropdownButton.TextXAlignment = Enum.TextXAlignment.Left
    dropdownButton.AutoButtonColor = false
    dropdownButton.ZIndex = 10
    dropdownButton.Parent = dropdownFrame
    local padding = Instance.new("UIPadding", dropdownButton); padding.PaddingLeft = UDim.new(0, 15)

    local arrowIcon = Instance.new("TextLabel")
    arrowIcon.Size = UDim2.new(0, 40, 1, 0)
    arrowIcon.Position = UDim2.new(1, -40, 0, 0)
    arrowIcon.BackgroundTransparency = 1
    arrowIcon.Text = "▶"
    arrowIcon.TextColor3 = Color3.fromRGB(200, 200, 200)
    arrowIcon.TextSize = 14
    arrowIcon.Font = Enum.Font.GothamBold
    arrowIcon.ZIndex = 10
    arrowIcon.Parent = dropdownFrame

    local optionsList = Instance.new("CanvasGroup")
    optionsList.Size = UDim2.new(1, 0, 0, 0)
    optionsList.Position = UDim2.new(0, 0, 1, 5)
    optionsList.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    optionsList.GroupTransparency = 1
    optionsList.Visible = false
    optionsList.ZIndex = 20
    optionsList.Parent = dropdownFrame
    Instance.new("UICorner", optionsList).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", optionsList).Color = Color3.fromRGB(50, 50, 60)

    local layout = Instance.new("UIListLayout", optionsList)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    for i, category in ipairs(categories) do
        local opt = Instance.new("TextButton")
        opt.Size = UDim2.new(1, 0, 0, 38)
        opt.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        opt.BackgroundTransparency = 1
        opt.BorderSizePixel = 0
        opt.Text = category
        opt.TextColor3 = Color3.fromRGB(200, 200, 200)
        opt.TextSize = 14
        opt.Font = Enum.Font.Gotham
        opt.ZIndex = 21
        opt.AutoButtonColor = false
        opt.Parent = optionsList

        local accent = Instance.new("Frame", opt)
        accent.Size = UDim2.new(0, 3, 0.6, 0)
        accent.Position = UDim2.new(0, 5, 0.2, 0)
        accent.BackgroundColor3 = RGB_COLORS[1]
        accent.BorderSizePixel = 0
        accent.BackgroundTransparency = 1

        opt.MouseEnter:Connect(function()
            TweenService:Create(opt, TweenInfo.new(0.2), {BackgroundTransparency = 0.8, BackgroundColor3 = Color3.fromRGB(60, 60, 80)}):Play()
            TweenService:Create(accent, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
        end)
        
        opt.MouseLeave:Connect(function()
            TweenService:Create(opt, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            TweenService:Create(accent, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        end)

        opt.MouseButton1Click:Connect(function()
            selectedCategory = category
            dropdownButton.Text = category
            dropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            uiStroke.Color = RGB_COLORS[1]
            isOpen = false
            TweenService:Create(optionsList, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 0), GroupTransparency = 1}):Play()
            TweenService:Create(arrowIcon, TweenInfo.new(0.3), {Rotation = 0}):Play()
            task.wait(0.3)
            optionsList.Visible = false
        end)
    end

    dropdownButton.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            optionsList.Visible = true
            TweenService:Create(optionsList, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = UDim2.new(1, 0, 0, #categories * 38), GroupTransparency = 0}):Play()
            TweenService:Create(arrowIcon, TweenInfo.new(0.3), {Rotation = 180}):Play()
        else
            TweenService:Create(optionsList, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 0), GroupTransparency = 1}):Play()
            TweenService:Create(arrowIcon, TweenInfo.new(0.3), {Rotation = 0}):Play()
            task.wait(0.3)
            if not isOpen then optionsList.Visible = false end
        end
    end)

    local function getValue() return selectedCategory end
    local function resetDropdown()
        selectedCategory = ""
        dropdownButton.Text = "Selecionar Categoria"
        dropdownButton.TextColor3 = Color3.fromRGB(180, 180, 180)
        uiStroke.Color = Color3.fromRGB(60, 60, 70)
        isOpen = false
        optionsList.Size = UDim2.new(1, 0, 0, 0)
        optionsList.Visible = false
        arrowIcon.Rotation = 0
    end

    return getValue, resetDropdown
end

-- 👤 PREVIEW DO USUÁRIO
local function createUserPreview(parent, posY, mainFrame, feedbackLabel, fetchDataFunc)
	local previewFrame = Instance.new("Frame")
	previewFrame.Name = "UserPreview"
	previewFrame.Size = UDim2.new(1, -40, 0, 80)
	previewFrame.Position = UDim2.new(0, 20, 0, posY)
	previewFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	previewFrame.BorderSizePixel = 0
	previewFrame.Parent = parent
	Instance.new("UICorner", previewFrame).CornerRadius = UDim.new(0, 10)
	
	local avatarFrame = Instance.new("Frame")
	avatarFrame.Name = "AvatarFrame"
	avatarFrame.Size = UDim2.new(0, 60, 0, 60)
	avatarFrame.Position = UDim2.new(0, 10, 0, 10)
	avatarFrame.BackgroundColor3 = RGB_COLORS[1]
	avatarFrame.BorderSizePixel = 0
	avatarFrame.Parent = previewFrame
	Instance.new("UICorner", avatarFrame).CornerRadius = UDim.new(1, 0)
	
	spawn(function()
		local colorIndex = 1
		while avatarFrame.Parent do
			colorIndex = colorIndex % #RGB_COLORS + 1
			TweenService:Create(avatarFrame, TweenInfo.new(3, Enum.EasingStyle.Sine), {BackgroundColor3 = RGB_COLORS[colorIndex]}):Play()
			wait(3)
		end
	end)
	
	local avatarImage = Instance.new("ImageLabel")
	avatarImage.Name = "AvatarImage"
	avatarImage.Size = UDim2.new(1, -4, 1, -4)
	avatarImage.Position = UDim2.new(0, 2, 0, 2)
	avatarImage.BackgroundTransparency = 1
	avatarImage.Image = normalizeImageUrl(nil, player.UserId)
	avatarImage.Parent = avatarFrame
	Instance.new("UICorner", avatarImage).CornerRadius = UDim.new(1, 0)
	
	local playerNameLabel = Instance.new("TextLabel")
	playerNameLabel.Size = UDim2.new(1, -80, 0, 25)
	playerNameLabel.Position = UDim2.new(0, 80, 0, 15)
	playerNameLabel.BackgroundTransparency = 1
	playerNameLabel.Text = player.DisplayName
	playerNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	playerNameLabel.TextSize = 16
	playerNameLabel.Font = Enum.Font.GothamBold
	playerNameLabel.TextXAlignment = Enum.TextXAlignment.Left
	playerNameLabel.Parent = previewFrame
	
	local usernameLabel = Instance.new("TextLabel")
	usernameLabel.Size = UDim2.new(1, -80, 0, 20)
	usernameLabel.Position = UDim2.new(0, 80, 0, 45)
	usernameLabel.BackgroundTransparency = 1
	usernameLabel.Text = "@"..player.Name
	usernameLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
	usernameLabel.TextSize = 14
	usernameLabel.Font = Enum.Font.Gotham
	usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
	usernameLabel.Parent = previewFrame
	
	local selfProfileBtn = Instance.new("TextButton")
	selfProfileBtn.Name = "SelfProfileHitbox"
	selfProfileBtn.Size = UDim2.new(1, 0, 1, 0)
	selfProfileBtn.BackgroundTransparency = 1
	selfProfileBtn.Text = ""
	selfProfileBtn.ZIndex = 10
	selfProfileBtn.Parent = previewFrame
	
	selfProfileBtn.MouseButton1Click:Connect(function()
	    -- Se não tiver dados, carrega automaticamente
	    if #allMusicData == 0 then
	        local _fbIco, _fbSpin
	        if feedbackLabel then
	            feedbackLabel.Text = "Baixando dados para abrir perfil..."
	            feedbackLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
	            _fbIco = makeIcon(feedbackLabel, ICONS.LOADING, UDim2.new(0, 16, 0, 16), UDim2.new(0, 6, 0.5, -8), 12)
	            _fbSpin = spinIcon(_fbIco)
	        end
	        
	        if fetchDataFunc then fetchDataFunc() end
	        
	        local timeout = 0
	        while isFetching and timeout < 15 do
	            wait(0.2)
	            timeout = timeout + 0.2
	        end
	        if _fbSpin then _fbSpin:Disconnect() end
	        if _fbIco then _fbIco:Destroy() end
	 
	        if #allMusicData == 0 then
	            if feedbackLabel then
	                feedbackLabel.Text = "❌ Falha ao carregar. Tente novamente."
	                feedbackLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
	            end
	            return
	        end
	    end
	    
	    createProfileView(mainFrame, {
	        UserId = player.UserId,
	        DisplayName = player.DisplayName,
	        PlayerName = player.Name,
	        Foto = "https://www.roblox.com/headshot-thumbnail/image?userId="..player.UserId.."&width=150&height=150&format=png"
	    })
	end)
	
	return previewFrame
end

local function createFeedback(parent, posY)
	local feedbackLabel = Instance.new("TextLabel")
	feedbackLabel.Name = "FeedbackLabel"
	feedbackLabel.Size = UDim2.new(1, -40, 0, 30)
	feedbackLabel.Position = UDim2.new(0, 20, 0, posY)
	feedbackLabel.BackgroundTransparency = 1
	feedbackLabel.Text = ""
	feedbackLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	feedbackLabel.TextSize = 14
	feedbackLabel.Font = Enum.Font.Gotham
	feedbackLabel.TextWrapped = true
	feedbackLabel.Parent = parent
	return feedbackLabel
end

local function createStyledButton(parent, text, posY, color, callback)
	local buttonFrame = Instance.new("Frame")
	buttonFrame.Name = text.."Frame"
	buttonFrame.Size = UDim2.new(1, -40, 0, 50)
	buttonFrame.Position = UDim2.new(0, 20, 0, posY)
	buttonFrame.BackgroundColor3 = color
	buttonFrame.BorderSizePixel = 0
	buttonFrame.Parent = parent
	Instance.new("UICorner", buttonFrame).CornerRadius = UDim.new(0, 10)
	
	local button = Instance.new("TextButton")
	button.Name = text.."Button"
	button.Size = UDim2.new(1, 0, 1, 0)
	button.BackgroundTransparency = 1
	button.Text = text
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextSize = 18
	button.Font = Enum.Font.GothamBold
	button.Parent = buttonFrame
	
	button.MouseEnter:Connect(function()
		TweenService:Create(buttonFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, -35, 0, 55)}):Play()
	end)
	button.MouseLeave:Connect(function()
		TweenService:Create(buttonFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, -40, 0, 50)}):Play()
	end)
	button.MouseButton1Click:Connect(function()
	    TweenService:Create(buttonFrame, TweenInfo.new(0.1), {Size = UDim2.new(1, -45, 0, 45)}):Play()
	    wait(0.1)
	    TweenService:Create(buttonFrame, TweenInfo.new(0.1), {Size = UDim2.new(1, -40, 0, 50)}):Play()
		if callback then callback() end
	end)
	
	spawn(function()
		while buttonFrame.Parent do
			local pulseTween = TweenService:Create(buttonFrame, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.new(color.R * 1.2, color.G * 1.2, color.B * 1.2)})
			pulseTween:Play(); pulseTween.Completed:Wait()
			local returnTween = TweenService:Create(buttonFrame, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundColor3 = color})
			returnTween:Play(); returnTween.Completed:Wait()
		end
	end)
	return button
end

local function createOverlay(targetFrame)
    targetFrame.ClipsDescendants = true
    local overlay = Instance.new("TextButton")
    overlay.Name = "ModalOverlay"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.Position = UDim2.new(0, 0, 0, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 1 
    overlay.AutoButtonColor = false
    overlay.Text = ""
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 40 
    overlay.Parent = targetFrame
    TweenService:Create(overlay, TweenInfo.new(0.4), {BackgroundTransparency = 0.6}):Play()
    return overlay
end

local function createTitle(parent)
    local titleFrame = Instance.new("Frame")
    titleFrame.Size = UDim2.new(1, -40, 0, 90)
    titleFrame.Position = UDim2.new(0, 20, 0, 20)
    titleFrame.BackgroundTransparency = 1
    titleFrame.Parent = parent

    local titleImage = Instance.new("ImageLabel")
    titleImage.Size = UDim2.new(1, 0, 0, 145)
    titleImage.Position = UDim2.new(0, 0, 0, -40)
    titleImage.BackgroundTransparency = 1
    titleImage.Image = ICONS.TITLE_IMG
    titleImage.ScaleType = Enum.ScaleType.Fit
    titleImage.ImageTransparency = 0
    -- Remove o fundo quadriculado (branco/cinza) aplicando transparência no fundo
    titleImage.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    titleImage.BorderSizePixel = 0
    titleImage.Parent = titleFrame

    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.Size = UDim2.new(1, 0, 0, 20)
    subtitleLabel.Position = UDim2.new(0, 0, 1, -20)
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.Text = "Compartilhe seus IDs favoritos do Roblox"
    subtitleLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    subtitleLabel.TextSize = 14
    subtitleLabel.Font = Enum.Font.Gotham
    subtitleLabel.Parent = titleFrame
    return titleFrame
end

local function createInputField(parent, placeholder, posY, maxLength)
	local inputFrame = Instance.new("Frame")
	inputFrame.Size = UDim2.new(1, -40, 0, 50)
	inputFrame.Position = UDim2.new(0, 20, 0, posY)
	inputFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	inputFrame.BorderSizePixel = 0
	inputFrame.Parent = parent
	Instance.new("UICorner", inputFrame).CornerRadius = UDim.new(0, 10)
	
	local inputBox = Instance.new("TextBox")
	inputBox.Size = UDim2.new(1, -20, 1, -10)
	inputBox.Position = UDim2.new(0, 10, 0, 5)
	inputBox.BackgroundTransparency = 1
	inputBox.PlaceholderText = placeholder
	inputBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
	inputBox.Text = ""
	inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	inputBox.TextSize = 16
	inputBox.Font = Enum.Font.Gotham
	inputBox.TextXAlignment = Enum.TextXAlignment.Left
	inputBox.Parent = inputFrame
	
	local charCounter = Instance.new("TextLabel")
	charCounter.Size = UDim2.new(0, 60, 0, 20)
	charCounter.Position = UDim2.new(1, -70, 1, -65)
	charCounter.BackgroundTransparency = 1
	charCounter.Text = "0/"..maxLength
	charCounter.TextColor3 = Color3.fromRGB(120, 120, 120)
	charCounter.TextSize = 12
	charCounter.Font = Enum.Font.Gotham
	charCounter.Parent = inputFrame
	
	inputBox.Focused:Connect(function()
		TweenService:Create(inputFrame, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
	end)
	
	inputBox.FocusLost:Connect(function()
		TweenService:Create(inputFrame, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}):Play()
	end)
	
	inputBox:GetPropertyChangedSignal("Text"):Connect(function()
		local currentLength = #inputBox.Text
		charCounter.Text = currentLength.."/"..maxLength
		if currentLength > maxLength then inputBox.Text = string.sub(inputBox.Text, 1, maxLength) end
	end)
	return inputBox
end

local function createCategoryDropdown(parent, posY)
    local categories = CATEGORIES_LIST  -- mesma lista de CATEGORIES_LIST (editar + publicar em sincronia)
    local selectedCategory = ""
    local isOpen = false

    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Size = UDim2.new(1, -40, 0, 50)
    dropdownFrame.Position = UDim2.new(0, 20, 0, posY)
    dropdownFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    dropdownFrame.ZIndex = 10
    dropdownFrame.Parent = parent
    Instance.new("UICorner", dropdownFrame).CornerRadius = UDim.new(0, 10)
    
    local uiStroke = Instance.new("UIStroke", dropdownFrame)
    uiStroke.Color = Color3.fromRGB(60, 60, 70)
    uiStroke.Thickness = 1.2

    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Size = UDim2.new(1, 0, 1, 0)
    dropdownButton.BackgroundTransparency = 1
    dropdownButton.Text = "Selecionar Categoria"
    dropdownButton.TextColor3 = Color3.fromRGB(180, 180, 180)
    dropdownButton.TextSize = 15
    dropdownButton.Font = Enum.Font.GothamMedium
    dropdownButton.TextXAlignment = Enum.TextXAlignment.Left
    dropdownButton.AutoButtonColor = false
    dropdownButton.ZIndex = 10
    dropdownButton.Parent = dropdownFrame
    local padding = Instance.new("UIPadding", dropdownButton); padding.PaddingLeft = UDim.new(0, 15)

    local arrowIcon = Instance.new("TextLabel")
    arrowIcon.Size = UDim2.new(0, 40, 1, 0)
    arrowIcon.Position = UDim2.new(1, -40, 0, 0)
    arrowIcon.BackgroundTransparency = 1
    arrowIcon.Text = "▶"
    arrowIcon.TextColor3 = Color3.fromRGB(200, 200, 200)
    arrowIcon.TextSize = 14
    arrowIcon.Font = Enum.Font.GothamBold
    arrowIcon.ZIndex = 10
    arrowIcon.Parent = dropdownFrame

    local optionsList = Instance.new("CanvasGroup")
    optionsList.Size = UDim2.new(1, 0, 0, 0)
    optionsList.Position = UDim2.new(0, 0, 1, 5)
    optionsList.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    optionsList.GroupTransparency = 1
    optionsList.Visible = false
    optionsList.ZIndex = 20
    optionsList.Parent = dropdownFrame
    Instance.new("UICorner", optionsList).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", optionsList).Color = Color3.fromRGB(50, 50, 60)

    local layout = Instance.new("UIListLayout", optionsList)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    for i, category in ipairs(categories) do
        local opt = Instance.new("TextButton")
        opt.Size = UDim2.new(1, 0, 0, 38)
        opt.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        opt.BackgroundTransparency = 1
        opt.BorderSizePixel = 0
        opt.Text = category
        opt.TextColor3 = Color3.fromRGB(200, 200, 200)
        opt.TextSize = 14
        opt.Font = Enum.Font.Gotham
        opt.ZIndex = 21
        opt.AutoButtonColor = false
        opt.Parent = optionsList

        local accent = Instance.new("Frame", opt)
        accent.Size = UDim2.new(0, 3, 0.6, 0)
        accent.Position = UDim2.new(0, 5, 0.2, 0)
        accent.BackgroundColor3 = RGB_COLORS[1]
        accent.BorderSizePixel = 0
        accent.BackgroundTransparency = 1

        opt.MouseEnter:Connect(function()
            TweenService:Create(opt, TweenInfo.new(0.2), {BackgroundTransparency = 0.8, BackgroundColor3 = Color3.fromRGB(60, 60, 80)}):Play()
            TweenService:Create(accent, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
        end)
        
        opt.MouseLeave:Connect(function()
            TweenService:Create(opt, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            TweenService:Create(accent, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        end)

        opt.MouseButton1Click:Connect(function()
            selectedCategory = category
            dropdownButton.Text = category
            dropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            uiStroke.Color = RGB_COLORS[1]
            isOpen = false
            TweenService:Create(optionsList, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 0), GroupTransparency = 1}):Play()
            TweenService:Create(arrowIcon, TweenInfo.new(0.3), {Rotation = 0}):Play()
            task.wait(0.3)
            optionsList.Visible = false
        end)
    end

    dropdownButton.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            optionsList.Visible = true
            TweenService:Create(optionsList, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = UDim2.new(1, 0, 0, #categories * 38), GroupTransparency = 0}):Play()
            TweenService:Create(arrowIcon, TweenInfo.new(0.3), {Rotation = 180}):Play()
        else
            TweenService:Create(optionsList, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 0), GroupTransparency = 1}):Play()
            TweenService:Create(arrowIcon, TweenInfo.new(0.3), {Rotation = 0}):Play()
            task.wait(0.3)
            if not isOpen then optionsList.Visible = false end
        end
    end)

    local function getValue() return selectedCategory end
    local function resetDropdown()
        selectedCategory = ""
        dropdownButton.Text = "Selecionar Categoria"
        dropdownButton.TextColor3 = Color3.fromRGB(180, 180, 180)
        uiStroke.Color = Color3.fromRGB(60, 60, 70)
        isOpen = false
        optionsList.Size = UDim2.new(1, 0, 0, 0)
        optionsList.Visible = false
        arrowIcon.Rotation = 0
    end

    return getValue, resetDropdown
end

-- 👤 PREVIEW DO USUÁRIO
local function createUserPreview(parent, posY, mainFrame, feedbackLabel, fetchDataFunc)
	local previewFrame = Instance.new("Frame")
	previewFrame.Name = "UserPreview"
	previewFrame.Size = UDim2.new(1, -40, 0, 80)
	previewFrame.Position = UDim2.new(0, 20, 0, posY)
	previewFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	previewFrame.BorderSizePixel = 0
	previewFrame.Parent = parent
	Instance.new("UICorner", previewFrame).CornerRadius = UDim.new(0, 10)
	
	local avatarFrame = Instance.new("Frame")
	avatarFrame.Name = "AvatarFrame"
	avatarFrame.Size = UDim2.new(0, 60, 0, 60)
	avatarFrame.Position = UDim2.new(0, 10, 0, 10)
	avatarFrame.BackgroundColor3 = RGB_COLORS[1]
	avatarFrame.BorderSizePixel = 0
	avatarFrame.Parent = previewFrame
	Instance.new("UICorner", avatarFrame).CornerRadius = UDim.new(1, 0)
	
	spawn(function()
		local colorIndex = 1
		while avatarFrame.Parent do
			colorIndex = colorIndex % #RGB_COLORS + 1
			TweenService:Create(avatarFrame, TweenInfo.new(3, Enum.EasingStyle.Sine), {BackgroundColor3 = RGB_COLORS[colorIndex]}):Play()
			wait(3)
		end
	end)
	
	local avatarImage = Instance.new("ImageLabel")
	avatarImage.Name = "AvatarImage"
	avatarImage.Size = UDim2.new(1, -4, 1, -4)
	avatarImage.Position = UDim2.new(0, 2, 0, 2)
	avatarImage.BackgroundTransparency = 1
	avatarImage.Image = normalizeImageUrl(nil, player.UserId)
	avatarImage.Parent = avatarFrame
	Instance.new("UICorner", avatarImage).CornerRadius = UDim.new(1, 0)
	
	local playerNameLabel = Instance.new("TextLabel")
	playerNameLabel.Size = UDim2.new(1, -80, 0, 25)
	playerNameLabel.Position = UDim2.new(0, 80, 0, 15)
	playerNameLabel.BackgroundTransparency = 1
	playerNameLabel.Text = player.DisplayName
	playerNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	playerNameLabel.TextSize = 16
	playerNameLabel.Font = Enum.Font.GothamBold
	playerNameLabel.TextXAlignment = Enum.TextXAlignment.Left
	playerNameLabel.Parent = previewFrame
	
	local usernameLabel = Instance.new("TextLabel")
	usernameLabel.Size = UDim2.new(1, -80, 0, 20)
	usernameLabel.Position = UDim2.new(0, 80, 0, 45)
	usernameLabel.BackgroundTransparency = 1
	usernameLabel.Text = "@"..player.Name
	usernameLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
	usernameLabel.TextSize = 14
	usernameLabel.Font = Enum.Font.Gotham
	usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
	usernameLabel.Parent = previewFrame
	
	local selfProfileBtn = Instance.new("TextButton")
	selfProfileBtn.Name = "SelfProfileHitbox"
	selfProfileBtn.Size = UDim2.new(1, 0, 1, 0)
	selfProfileBtn.BackgroundTransparency = 1
	selfProfileBtn.Text = ""
	selfProfileBtn.ZIndex = 10
	selfProfileBtn.Parent = previewFrame
	
	selfProfileBtn.MouseButton1Click:Connect(function()
	    -- Se não tiver dados, carrega automaticamente
	    if #allMusicData == 0 then
	        local _fbIco, _fbSpin
	        if feedbackLabel then
	            feedbackLabel.Text = "Baixando dados para abrir perfil..."
	            feedbackLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
	            _fbIco = makeIcon(feedbackLabel, ICONS.LOADING, UDim2.new(0, 16, 0, 16), UDim2.new(0, 6, 0.5, -8), 12)
	            _fbSpin = spinIcon(_fbIco)
	        end
	        
	        if fetchDataFunc then fetchDataFunc() end
	        
	        local timeout = 0
	        while isFetching and timeout < 15 do
	            wait(0.2)
	            timeout = timeout + 0.2
	        end
	        if _fbSpin then _fbSpin:Disconnect() end
	        if _fbIco then _fbIco:Destroy() end
	 
	        if #allMusicData == 0 then
	            if feedbackLabel then
	                feedbackLabel.Text = "❌ Falha ao carregar. Tente novamente."
	                feedbackLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
	            end
	            return
	        end
	    end
	    
	    createProfileView(mainFrame, {
	        UserId = player.UserId,
	        DisplayName = player.DisplayName,
	        PlayerName = player.Name,
	        Foto = "https://www.roblox.com/headshot-thumbnail/image?userId="..player.UserId.."&width=150&height=150&format=png"
	    })
	end)
	
	return previewFrame
end

local function createFeedback(parent, posY)
	local feedbackLabel = Instance.new("TextLabel")
	feedbackLabel.Name = "FeedbackLabel"
	feedbackLabel.Size = UDim2.new(1, -40, 0, 30)
	feedbackLabel.Position = UDim2.new(0, 20, 0, posY)
	feedbackLabel.BackgroundTransparency = 1
	feedbackLabel.Text = ""
	feedbackLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	feedbackLabel.TextSize = 14
	feedbackLabel.Font = Enum.Font.Gotham
	feedbackLabel.TextWrapped = true
	feedbackLabel.Parent = parent
	return feedbackLabel
end

local function createStyledButton(parent, text, posY, color, callback)
	local buttonFrame = Instance.new("Frame")
	buttonFrame.Name = text.."Frame"
	buttonFrame.Size = UDim2.new(1, -40, 0, 50)
	buttonFrame.Position = UDim2.new(0, 20, 0, posY)
	buttonFrame.BackgroundColor3 = color
	buttonFrame.BorderSizePixel = 0
	buttonFrame.Parent = parent
	Instance.new("UICorner", buttonFrame).CornerRadius = UDim.new(0, 10)
	
	local button = Instance.new("TextButton")
	button.Name = text.."Button"
	button.Size = UDim2.new(1, 0, 1, 0)
	button.BackgroundTransparency = 1
	button.Text = text
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextSize = 18
	button.Font = Enum.Font.GothamBold
	button.Parent = buttonFrame
	
	button.MouseEnter:Connect(function()
		TweenService:Create(buttonFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, -35, 0, 55)}):Play()
	end)
	button.MouseLeave:Connect(function()
		TweenService:Create(buttonFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, -40, 0, 50)}):Play()
	end)
	button.MouseButton1Click:Connect(function()
	    TweenService:Create(buttonFrame, TweenInfo.new(0.1), {Size = UDim2.new(1, -45, 0, 45)}):Play()
	    wait(0.1)
	    TweenService:Create(buttonFrame, TweenInfo.new(0.1), {Size = UDim2.new(1, -40, 0, 50)}):Play()
		if callback then callback() end
	end)
	
	spawn(function()
		while buttonFrame.Parent do
			local pulseTween = TweenService:Create(buttonFrame, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.new(color.R * 1.2, color.G * 1.2, color.B * 1.2)})
			pulseTween:Play(); pulseTween.Completed:Wait()
			local returnTween = TweenService:Create(buttonFrame, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundColor3 = color})
			returnTween:Play(); returnTween.Completed:Wait()
		end
	end)
local function main()
	-- 🎬 Criar e mostrar splash screen primeiro
	local splashGui, updateProgressFunc = createSplashScreen(function()
		print("🎉 Enhanced Music ID Publisher v3.3 (Auto-Load + BugFixes) carregado!")
	end)
	
	wait(0.3)
	
	-- Criar a GUI principal (mas manter invisível inicialmente)
	local gui, mainFrame, borderFrame, scrollFrame, leaderboardScroll, publishScroll, closeButton, musicListFrame, musicListScroll, resetTabFunc, btnMusicas, btnPublicar, tipLabel = createMainGUI()
	mainFrame.Visible = false
	
	createFilterPanel(musicListFrame, musicListScroll, mainFrame)
	
	local floatingGui, floatingButton, floatingBorder = createFloatingButton()
	floatingGui.Enabled = false
	local tabIndicator = mainFrame:FindFirstChild("TabFrame") and mainFrame:FindFirstChild("TabFrame"):FindFirstChild("TabIndicator")
    local headerLogo = mainFrame:FindFirstChild("LogoWidget")
    local headerLogoBorder = headerLogo and headerLogo:FindFirstChildOfClass("UIStroke")
    animateRGBBorder(borderFrame, tabIndicator, {headerLogoBorder, floatingBorder})

	-- ══════════════════════════════════════════════════════
	-- 🏠 PÁGINA HOME — Apresentação & Créditos
	-- ══════════════════════════════════════════════════════
	-- Logo grande animado
	local homeLogoFrame, homeLogoBorder = createLogoWidget(
		scrollFrame, 90, UDim2.new(0.5, -45, 0, 18), 5
	)
	spawn(function()
		local idx = 1
		while homeLogoFrame.Parent do
			TweenService:Create(homeLogoFrame, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				Size = UDim2.new(0, 100, 0, 100),
				Position = UDim2.new(0.5, -50, 0, 13)
			}):Play()
			wait(1.2)
			TweenService:Create(homeLogoFrame, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				Size = UDim2.new(0, 90, 0, 90),
				Position = UDim2.new(0.5, -45, 0, 18)
			}):Play()
			wait(1.2)
		end
	end)
	spawn(function()
		local idx = 1
		while homeLogoFrame.Parent do
			idx = idx % #RGB_COLORS + 1
			TweenService:Create(homeLogoBorder, TweenInfo.new(1.2, Enum.EasingStyle.Sine), {Color = RGB_COLORS[idx]}):Play()
			wait(1.2)
		end
	end)

	-- Título principal
	local homeTitleLbl = Instance.new("TextLabel")
	homeTitleLbl.Size = UDim2.new(1, -20, 0, 42)
	homeTitleLbl.Position = UDim2.new(0, 10, 0, 118)
	homeTitleLbl.BackgroundTransparency = 1
	homeTitleLbl.Text = "🎵 MUSIC ID PUBLISHER"
	homeTitleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	homeTitleLbl.Font = Enum.Font.GothamBold
	homeTitleLbl.TextSize = 22
	homeTitleLbl.Parent = scrollFrame
	local htStroke = Instance.new("UIStroke", homeTitleLbl)
	htStroke.Thickness = 1.5; htStroke.Color = RGB_COLORS[1]
	spawn(function()
		local idx = 1
		while homeTitleLbl.Parent do
			idx = idx % #RGB_COLORS + 1
			TweenService:Create(htStroke, TweenInfo.new(1.2, Enum.EasingStyle.Sine), {Color = RGB_COLORS[idx]}):Play()
			wait(1.2)
		end
	end)

	-- Badge de versão
	local vBadge = Instance.new("Frame")
	vBadge.Size = UDim2.new(0, 168, 0, 26)
	vBadge.Position = UDim2.new(0.5, -84, 0, 165)
	vBadge.BackgroundColor3 = Color3.fromRGB(38, 38, 52)
	vBadge.BorderSizePixel = 0; vBadge.Parent = scrollFrame
	Instance.new("UICorner", vBadge).CornerRadius = UDim.new(0, 13)
	local vBStroke = Instance.new("UIStroke", vBadge)
	vBStroke.Color = RGB_COLORS[2]; vBStroke.Thickness = 1.4
	local vBText = Instance.new("TextLabel", vBadge)
	vBText.Size = UDim2.new(1,0,1,0); vBText.BackgroundTransparency = 1
	vBText.Text = "Versão 3.3  —  Enhanced Edition"
	vBText.TextColor3 = RGB_COLORS[2]; vBText.Font = Enum.Font.GothamBold; vBText.TextSize = 12

	-- Card descrição
	local descCard = Instance.new("Frame")
	descCard.Size = UDim2.new(1, -20, 0, 68)
	descCard.Position = UDim2.new(0, 10, 0, 202)
	descCard.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
	descCard.BorderSizePixel = 0; descCard.Parent = scrollFrame
	Instance.new("UICorner", descCard).CornerRadius = UDim.new(0, 12)
	local dStroke = Instance.new("UIStroke", descCard)
	dStroke.Color = Color3.fromRGB(50,50,72); dStroke.Thickness = 1
	local dText = Instance.new("TextLabel", descCard)
	dText.Size = UDim2.new(1,-20,1,-10); dText.Position = UDim2.new(0,10,0,5)
	dText.BackgroundTransparency = 1
	dText.Text = "Compartilhe e descubra os melhores IDs de músicas do Roblox! Publique suas favoritas, veja o ranking Top 10 e gerencie suas playlists."
	dText.TextColor3 = Color3.fromRGB(190,190,210); dText.Font = Enum.Font.Gotham
	dText.TextSize = 13; dText.TextWrapped = true; dText.TextXAlignment = Enum.TextXAlignment.Left

	--━━━━━━━━━━━━━━━━┃╋┃
-- 👑 CRÉDITOS
--━━━━━━━━━━━━━━━━┃╋┃

local credTitle = Instance.new("TextLabel")
credTitle.Size = UDim2.new(1,-20,0,28)
credTitle.Position = UDim2.new(0,10,0,281)
credTitle.BackgroundTransparency = 1
credTitle.Text = "┃╋┃  CRÉDITOS  ┃╋┃"
credTitle.TextColor3 = Color3.fromRGB(255, 210, 60)
credTitle.Font = Enum.Font.GothamBold
credTitle.TextSize = 13
credTitle.Parent = scrollFrame

-- Base Y
local yPosCred = 313

--━━━━━━━━━━━━━━━━┃╋┃
-- 💻 DEV CARD
--━━━━━━━━━━━━━━━━┃╋┃

local devCard = Instance.new("Frame")
devCard.Size = UDim2.new(1, -20, 0, 85)
devCard.Position = UDim2.new(0, 10, 0, yPosCred)
devCard.BackgroundColor3 = Color3.fromRGB(22, 18, 30)
devCard.BorderSizePixel = 0
devCard.Parent = scrollFrame
Instance.new("UICorner", devCard).CornerRadius = UDim.new(0, 12)

local devStroke = Instance.new("UIStroke", devCard)
devStroke.Color = RGB_COLORS[1]
devStroke.Thickness = 1.5

-- RGB animado
task.spawn(function()
    local i = 1
    while devCard.Parent do
        i = i % #RGB_COLORS + 1
        TweenService:Create(devStroke, TweenInfo.new(2), {
            Color = RGB_COLORS[i]
        }):Play()
        task.wait(2)
    end
end)

-- Avatar Frame
local devAvatarFrame = Instance.new("Frame", devCard)
devAvatarFrame.Size = UDim2.new(0, 60, 0, 60)
devAvatarFrame.Position = UDim2.new(0, 12, 0.5, -30)
devAvatarFrame.BackgroundColor3 = RGB_COLORS[1]
Instance.new("UICorner", devAvatarFrame).CornerRadius = UDim.new(1, 0)

-- Gradiente animado
local grad = Instance.new("UIGradient", devAvatarFrame)
grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, RGB_COLORS[1]),
    ColorSequenceKeypoint.new(1, RGB_COLORS[3])
})

task.spawn(function()
    while grad.Parent do
        TweenService:Create(grad, TweenInfo.new(3, Enum.EasingStyle.Linear), {
            Rotation = 360
        }):Play()
        task.wait(3)
    end
end)

-- Avatar
local devAvatar = Instance.new("ImageLabel", devAvatarFrame)
devAvatar.Size = UDim2.new(1, -4, 1, -4)
devAvatar.Position = UDim2.new(0, 2, 0, 2)
devAvatar.BackgroundTransparency = 1
devAvatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=2596486665&width=150&height=150&format=png"
Instance.new("UICorner", devAvatar).CornerRadius = UDim.new(1, 0)

-- Textos
local devTitle = Instance.new("TextLabel", devCard)
devTitle.Size = UDim2.new(0, 140, 0, 15)
devTitle.Position = UDim2.new(0, 85, 0, 12)
devTitle.BackgroundTransparency = 1
devTitle.Text = "Desenvolvedor Principal"
devTitle.TextColor3 = Color3.fromRGB(180,150,255)
devTitle.Font = Enum.Font.Gotham
devTitle.TextSize = 11
devTitle.TextXAlignment = Enum.TextXAlignment.Left

local devName = Instance.new("TextLabel", devCard)
devName.Size = UDim2.new(1, -95, 0, 22)
devName.Position = UDim2.new(0, 85, 0, 30)
devName.BackgroundTransparency = 1
devName.Text = "Carregando..."
devName.TextColor3 = Color3.fromRGB(255,255,255)
devName.Font = Enum.Font.GothamBold
devName.TextSize = 18
devName.TextXAlignment = Enum.TextXAlignment.Left

local devUser = Instance.new("TextLabel", devCard)
devUser.Size = UDim2.new(1, -95, 0, 15)
devUser.Position = UDim2.new(0, 85, 0, 54)
devUser.BackgroundTransparency = 1
devUser.Text = "@..."
devUser.TextColor3 = Color3.fromRGB(120,120,140)
devUser.Font = Enum.Font.Gotham
devUser.TextSize = 13
devUser.TextXAlignment = Enum.TextXAlignment.Left

--━━━━━━━━━━━━━━━━┃╋┃
-- ✨ PARTÍCULAS OTIMIZADAS (SEM ACÚMULO)
--━━━━━━━━━━━━━━━━┃╋┃

local MAX_PARTICLES = 25
local particles = {}

task.spawn(function()
    while devCard.Parent do
        
        -- Limite de partículas
        if #particles >= MAX_PARTICLES then
            task.wait(0.1)
            continue
        end

        local p = Instance.new("Frame")
        p.Size = UDim2.new(0, math.random(2,4), 0, math.random(2,4))
        p.Position = UDim2.fromScale(math.random(), math.random())
        p.BackgroundColor3 = Color3.fromRGB(200,180,255)
        p.BackgroundTransparency = 0.2
        p.BorderSizePixel = 0
        p.ZIndex = 5
        p.Parent = devCard

        Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)

        table.insert(particles, p)

        -- Movimento leve + fade
        local tween = TweenService:Create(
            p,
            TweenInfo.new(
                math.random(12,18)/10, -- 1.2s a 1.8s
                Enum.EasingStyle.Sine,
                Enum.EasingDirection.Out
            ),
            {
                Position = p.Position + UDim2.new(0, math.random(-10,10), 0, math.random(-10,10)),
                BackgroundTransparency = 1
            }
        )

        tween:Play()

        -- Remove depois
        tween.Completed:Connect(function()
            table.remove(particles, table.find(particles, p))
            p:Destroy()
        end)

        task.wait(0.15)
    end
end)

-- Hover
devCard.MouseEnter:Connect(function()
    TweenService:Create(devCard, TweenInfo.new(0.25), {
        BackgroundColor3 = Color3.fromRGB(35,28,48)
    }):Play()
end)

devCard.MouseLeave:Connect(function()
    TweenService:Create(devCard, TweenInfo.new(0.25), {
        BackgroundColor3 = Color3.fromRGB(22,18,30)
    }):Play()
end)

-- Botão hitbox: abre perfil do dev ao clicar no card
local devProfileBtn = Instance.new("TextButton", devCard)
devProfileBtn.Size = UDim2.new(1, 0, 1, 0)
devProfileBtn.BackgroundTransparency = 1
devProfileBtn.Text = ""
devProfileBtn.ZIndex = 6
devProfileBtn.MouseButton1Click:Connect(function()
    createProfileView(mainFrame, {
        UserId = 2596486665,
        DisplayName = (devName.Text ~= "Carregando..." and devName.Text or "Developer"),
        PlayerName = devUser.Text:gsub("@", ""),
        Foto = "https://www.roblox.com/headshot-thumbnail/image?userId=2596486665&width=150&height=150&format=png"
    })
end)

-- API Nome
task.spawn(function()
    local ok, data = pcall(function()
        return game:GetService("UserService"):GetUserInfosByUserIdsAsync({2596486665})
    end)

    if ok and data[1] then
        devName.Text = data[1].DisplayName
        devUser.Text = "@" .. data[1].Username
    else
        local ok2, name = pcall(function()
            return game:GetService("Players"):GetNameFromUserIdAsync(2596486665)
        end)

        devName.Text = ok2 and name or "Criador"
        devUser.Text = "@" .. (ok2 and name or "Developer")
    end
end)

yPosCred += 95

--━━━━━━━━━━━━━━━━┃╋┃
-- 📌 OUTROS CRÉDITOS
--━━━━━━━━━━━━━━━━┃╋┃

local credDefs = {
    {"Design & UI", "Enhanced Edition", RGB_COLORS[2]},
    {"Linguagem", "Roblox Lua 5.1", RGB_COLORS[3]},
    {"Back-end", "Supabase", RGB_COLORS[4]},
}

for i, c in ipairs(credDefs) do
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1,-20,0,40)
    card.Position = UDim2.new(0,10,0,yPosCred + (i-1)*46)
    card.BackgroundColor3 = Color3.fromRGB(18,18,26)
    card.BorderSizePixel = 0
    card.Parent = scrollFrame
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

    local stroke = Instance.new("UIStroke", card)
    stroke.Color = c[3]
    stroke.Thickness = 1.2
    stroke.Transparency = 0.35

    local l1 = Instance.new("TextLabel", card)
    l1.Size = UDim2.new(0,130,1,0)
    l1.Position = UDim2.new(0,10,0,0)
    l1.BackgroundTransparency = 1
    l1.Text = c[1]
    l1.TextColor3 = Color3.fromRGB(175,175,195)
    l1.Font = Enum.Font.Gotham
    l1.TextSize = 13
    l1.TextXAlignment = Enum.TextXAlignment.Left

    local l2 = Instance.new("TextLabel", card)
    l2.Size = UDim2.new(1,-150,1,0)
    l2.Position = UDim2.new(0,140,0,0)
    l2.BackgroundTransparency = 1
    l2.Text = c[2]
    l2.TextColor3 = c[3]
    l2.Font = Enum.Font.GothamBold
    l2.TextSize = 14
    l2.TextXAlignment = Enum.TextXAlignment.Right

    Instance.new("UIPadding", l2).PaddingRight = UDim.new(0,10)
end

--━━━━━━━━━━━━━━━━┃╋┃
-- ✨ COMPATIBILIDADE
--━━━━━━━━━━━━━━━━┃╋┃

local compatY = yPosCred + #credDefs * 46 + 6

local compatCard = Instance.new("Frame")
compatCard.Size = UDim2.new(1,-20,0,40)
compatCard.Position = UDim2.new(0,10,0,compatY)
compatCard.BackgroundColor3 = Color3.fromRGB(14,24,18)
compatCard.BorderSizePixel = 0
compatCard.Parent = scrollFrame
Instance.new("UICorner", compatCard).CornerRadius = UDim.new(0,10)

local compatStroke = Instance.new("UIStroke", compatCard)
compatStroke.Color = Color3.fromRGB(50,200,100)
compatStroke.Thickness = 1.2

local compatText = Instance.new("TextLabel", compatCard)
compatText.Size = UDim2.new(1,-20,1,0)
compatText.Position = UDim2.new(0,10,0,0)
compatText.BackgroundTransparency = 1
compatText.Text = "All Executors"
compatText.TextColor3 = Color3.fromRGB(90,220,110)
compatText.Font = Enum.Font.GothamBold
compatText.TextSize = 13

--━━━━━━━━━━━━━━━━┃╋┃
-- 📤 BOTÃO PUBLICAR
--━━━━━━━━━━━━━━━━┃╋┃

local goPublishY = compatY + 48

local goPublishBtn = Instance.new("TextButton")
goPublishBtn.Size = UDim2.new(1,-20,0,48)
goPublishBtn.Position = UDim2.new(0,10,0,goPublishY)
goPublishBtn.BackgroundColor3 = Color3.fromRGB(220,40,110)
goPublishBtn.BorderSizePixel = 0
goPublishBtn.Text = "📤  PUBLICAR UMA MÚSICA  →"
goPublishBtn.TextColor3 = Color3.fromRGB(255,255,255)
goPublishBtn.Font = Enum.Font.GothamBold
goPublishBtn.TextSize = 15
goPublishBtn.AutoButtonColor = false
goPublishBtn.Parent = scrollFrame
Instance.new("UICorner", goPublishBtn).CornerRadius = UDim.new(0,12)

local stroke = Instance.new("UIStroke", goPublishBtn)
stroke.Thickness = 1.5
stroke.Color = Color3.fromRGB(255,100,160)

-- Animação
task.spawn(function()
    while goPublishBtn.Parent do
        TweenService:Create(goPublishBtn, TweenInfo.new(1.4), {
            BackgroundColor3 = Color3.fromRGB(170,25,80)
        }):Play()
        task.wait(1.4)
        TweenService:Create(goPublishBtn, TweenInfo.new(1.4), {
            BackgroundColor3 = Color3.fromRGB(220,40,110)
        }):Play()
        task.wait(1.4)
    end
end)

goPublishBtn.MouseButton1Click:Connect(function()

    -- efeito de clique
    TweenService:Create(goPublishBtn, TweenInfo.new(0.1), {
        Size = UDim2.new(1,-26,0,44)
    }):Play()

    task.wait(0.1)

    TweenService:Create(goPublishBtn, TweenInfo.new(0.1), {
        Size = UDim2.new(1,-20,0,48)
    }):Play()

    -- esconder outras páginas
    scrollFrame.Visible = false
    leaderboardScroll.Visible = false

    local musicList = mainFrame:FindFirstChild("MusicListFrame")
    if musicList then
        musicList.Visible = false
    end

    -- mostrar página de publicar
    publishScroll.Visible = true
    publishScroll.Position = UDim2.new(1,0,0,5)

    TweenService:Create(publishScroll, TweenInfo.new(
        0.35,
        Enum.EasingStyle.Back,
        Enum.EasingDirection.Out
    ), {
        Position = UDim2.new(0,5,0,5)
    }):Play()

    -- mover indicador da aba e atualizar botões (usa mainFrame para acessar TabFrame)
    local tabF = mainFrame:FindFirstChild("TabFrame")
    if tabF then
        local tabInd = tabF:FindFirstChild("TabIndicator")
        if tabInd then
            TweenService:Create(tabInd, TweenInfo.new(
                0.35,
                Enum.EasingStyle.Back,
                Enum.EasingDirection.Out
            ), {
                Position = UDim2.new(0, 85 + 3, 0, 3) -- índice 2: (2-1)*85 + 3
            }):Play()
        end
        -- Atualiza cor e tamanho de todos os botões de aba
        local tabBtns = {}
        for _, ch in ipairs(tabF:GetChildren()) do
            if ch:IsA("TextButton") then
                table.insert(tabBtns, ch)
            end
        end
        table.sort(tabBtns, function(a, b)
            return a.Position.X.Offset < b.Position.X.Offset
        end)
        for i, btn in ipairs(tabBtns) do
            TweenService:Create(btn, TweenInfo.new(0.25), {
                TextColor3 = (i == 2) and Color3.fromRGB(255,255,255) or Color3.fromRGB(170,170,195),
                TextSize   = (i == 2) and 13 or 12
            }):Play()
        end
        -- Auto-scroll para exibir a aba "Publicar" (índice 2)
        TweenService:Create(tabF, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
            CanvasPosition = Vector2.new(math.max(0, 85 - 20), 0)
        }):Play()
    end

end)

scrollFrame.CanvasSize = UDim2.new(0, 0, 0, goPublishY + 66)

	-- ══════════════════════════════════════════════════════
	-- 📤 PÁGINA PUBLICAR — Formulário (antes ficava na Home)
	-- ══════════════════════════════════════════════════════
	local titleFrame     = createTitle(publishScroll)
	local nameBox        = createInputField(publishScroll, "Nome da Música", 120, 20)
	local idBox          = createInputField(publishScroll, "ID da Música (apenas números)", 190, 50)
	local getCategoryFunc, resetCategoryFunc = createCategoryDropdown(publishScroll, 260)
	local feedbackLabel  = createFeedback(publishScroll, 430)

	local userPreview = createUserPreview(publishScroll, 330, mainFrame, feedbackLabel, function()
	    local btnFrame = publishScroll:FindFirstChild("📋 VER MÚSICASFrame")
	    viewMusicList(feedbackLabel, musicListFrame, musicListScroll, publishScroll, btnFrame, mainFrame, leaderboardScroll)
	end)

	idBox:GetPropertyChangedSignal("Text"):Connect(function()
		local filteredText = string.gsub(idBox.Text, "[^%d]", "")
		if filteredText ~= idBox.Text then idBox.Text = filteredText end
	end)

    local publishButton = createStyledButton(
        publishScroll, "📤 PUBLICAR MÚSICA", 480, Color3.fromRGB(255, 50, 120),
        function()
            local btnFrame = publishScroll:FindFirstChild("📤 PUBLICAR MÚSICAFrame")
            publishMusic(nameBox, idBox, getCategoryFunc, feedbackLabel, btnFrame, mainFrame, resetCategoryFunc)
        end
    )

	-- Conectar o botão de aba "📋 Músicas"
	btnMusicas.MouseButton1Click:Connect(function()
	    local tabF = mainFrame:FindFirstChild("TabFrame")
	    local tabInd = tabF and tabF:FindFirstChild("TabIndicator")
	    if tabInd then
	        TweenService:Create(tabInd, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	            {Position = UDim2.new(0, 85*2 + 3, 0, 3)}):Play()
	    end
	    if tabF then
	        for _, ch in ipairs(tabF:GetChildren()) do
	            if ch:IsA("TextButton") then
	                TweenService:Create(ch, TweenInfo.new(0.25), {TextColor3 = Color3.fromRGB(170,170,195), TextSize = 12}):Play()
	            end
	        end
	        TweenService:Create(tabF, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {CanvasPosition = Vector2.new(85, 0)}):Play()
	    end
	    btnMusicas.TextColor3 = Color3.fromRGB(255,255,255)
	    TweenService:Create(btnMusicas, TweenInfo.new(0.25), {TextSize = 13}):Play()
	    
	    -- Esconde as outras telas com suavidade para a musicListFrame brilhar
	    scrollFrame.Visible = false
	    publishScroll.Visible = false
	    leaderboardScroll.Visible = false

	    viewMusicList(feedbackLabel, musicListFrame, musicListScroll, scrollFrame, nil, mainFrame, leaderboardScroll)
	end)
	
	-- LOGICA DE BOTÃO FECHAR E VOLTAR (CORRIGIDA)
	closeButton.MouseButton1Click:Connect(function() 
    mainFrame.Visible = false;
    floatingGui.Enabled = true 
end)

-- €€ DRAG DA GUI PRINCIPAL €€
-- Usa um Frame transparente (não TextButton) para não bloquear cliques nos botões de aba.
-- O usuário pode arrastar pela borda RGB da GUI (áreas sem conteúdo interativo).
do
    local guiDragging     = false
    local guiDragStartPos = Vector2.new()  -- posição do mouse no início do drag
    local guiStartAbsPos  = Vector2.new()  -- AbsolutePosition do mainFrame no início do drag

    -- Frame cobre a GUI inteira mas com ZIndex BAIXO (abaixo dos botões/abas).
    -- Frame não consome eventos de mouse, então botões com ZIndex maior continuam clicáveis.
    local dragHitbox = Instance.new("Frame")
    dragHitbox.Name               = "DragHitbox"
    dragHitbox.Size               = UDim2.new(1, 0, 1, 0)
    dragHitbox.Position           = UDim2.new(0, 0, 0, 0)
    dragHitbox.BackgroundTransparency = 1
    dragHitbox.BorderSizePixel    = 0
    dragHitbox.ZIndex             = 1   -- abaixo de tudo (abas, botões, conteúdo)
    dragHitbox.Parent             = mainFrame

    local BORDER_ZONE = 14  -- pixels a partir da borda que ativam o drag

    local function isInBorderZone(inputPos)
        local absPos  = mainFrame.AbsolutePosition
        local absSize = mainFrame.AbsoluteSize
        local lx = inputPos.X - absPos.X
        local ly = inputPos.Y - absPos.Y
        return lx < BORDER_ZONE or lx > absSize.X - BORDER_ZONE
            or ly < BORDER_ZONE or ly > absSize.Y - BORDER_ZONE
    end

    dragHitbox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            if isInBorderZone(Vector2.new(input.Position.X, input.Position.Y)) then
                guiDragging     = true
                guiDragStartPos = Vector2.new(input.Position.X, input.Position.Y)
                -- Captura a posição absoluta (canto superior esquerdo) do mainFrame
                guiStartAbsPos  = mainFrame.AbsolutePosition
            end
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not guiDragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then return end

        local delta   = Vector2.new(input.Position.X, input.Position.Y) - guiDragStartPos
        local absSize = mainFrame.AbsoluteSize

        -- Calcula nova posição sem limite de tela
        local newLeft = guiStartAbsPos.X + delta.X
        local newTop  = guiStartAbsPos.Y + delta.Y

        -- AnchorPoint = (0.5, 0.5): Position refere-se ao CENTRO do frame
        mainFrame.Position = UDim2.new(0, newLeft + absSize.X * 0.5, 0, newTop + absSize.Y * 0.5)
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            guiDragging = false
        end
    end)
end
    
	floatingButton.MouseButton1Click:Connect(function() 
    mainFrame.Visible = true
    floatingGui.Enabled = false
end)
	
    -- Botão de tipo de pesquisa — abre painel flutuante com 3 opções
    local filterBtn = musicListFrame.SearchFrame.FilterType
    local searchBox = musicListFrame.SearchFrame.SearchInput

    filterBtn.MouseButton1Click:Connect(function()
        makeFloatingPanel(mainFrame, {
            zBase        = 50,
            panelSize    = UDim2.new(0.82, 0, 0, 228),
            panelPos     = UDim2.new(0.09, 0, 0.5, -114),
            cornerRadius = 18,
            overlayClose = true,
            gradient     = true,
        }, function(panel, closeFn)
            local z = 52

            local hdrFrame, closePanelBtn, titleLbl = makePanelHeader(panel, "TIPO DE PESQUISA", z)
            local hdrIco = makeIcon(hdrFrame, ICONS.SEARCH_TYPE, UDim2.new(0, 16, 0, 16),
                UDim2.new(0, 14, 0.5, -8), z + 3)
            titleLbl.Position = UDim2.new(0, 36, 0, 0)
            titleLbl.Size     = UDim2.new(1, -72, 1, 0)
            closePanelBtn.MouseButton1Click:Connect(closeFn)

            local HEADER_H = 46
            local opts = {
                { label = "Por nome da música",   type = "Nome",         icon = ICONS.MUSIC_NOTE },
                { label = "Por ID da música",      type = "ID_Musica",    icon = ICONS.COPY       },
                { label = "Por nome do player",    type = "PlayerName",   icon = ICONS.VERIFY     },
            }

            for i, opt in ipairs(opts) do
                local isActive = (currentSearchType == opt.type)
                local btn = Instance.new("TextButton", panel)
                btn.Size = UDim2.new(1, -20, 0, 42)
                btn.Position = UDim2.new(0, 10, 0, HEADER_H + (i-1) * 48 + 8)
                btn.BackgroundColor3 = isActive
                    and Color3.fromRGB(45, 90, 210) or Color3.fromRGB(22, 20, 34)
                btn.BorderSizePixel = 0
                btn.Text = ""
                btn.ZIndex = z + 1
                btn.AutoButtonColor = false
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
                local bs = Instance.new("UIStroke", btn)
                bs.Color = isActive and Color3.fromRGB(100, 150, 255) or Color3.fromRGB(45, 45, 70)
                bs.Thickness = 1.5

                makeIcon(btn, opt.icon, UDim2.new(0, 20, 0, 20), UDim2.new(0, 12, 0.5, -10), z + 2)

                local lbl = Instance.new("TextLabel", btn)
                lbl.Size = UDim2.new(1, -44, 1, 0)
                lbl.Position = UDim2.new(0, 40, 0, 0)
                lbl.BackgroundTransparency = 1
                lbl.Text = opt.label
                lbl.TextColor3 = isActive
                    and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(190, 195, 225)
                lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 13
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.ZIndex = z + 2

                btn.MouseButton1Click:Connect(function()
                    currentSearchType = opt.type
                    local placeholders = {
                        Nome       = "Pesquisar por nome...",
                        ID_Musica  = "Pesquisar por ID...",
                        PlayerName = "Pesquisar por player...",
                    }
                    searchBox.PlaceholderText = placeholders[opt.type] or "Pesquisar..."
                    closeFn()
                    task.wait(0.1)
                    if searchBox.Text ~= "" then
                        renderFilteredList(musicListScroll, searchBox.Text, true, mainFrame)
                    end
                end)
            end
        end)
    end)

    searchBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            renderFilteredList(musicListScroll, searchBox.Text, true, mainFrame)
        end
    end)

    -- 🔥 [AUTO-LOAD COM SPLASH] Carregamento real durante a splash screen
    -- updateProgressFunc(percent, status) controla a splash: ao chegar em 100% ela fecha sozinha.
    task.spawn(function()
        viewMusicList(feedbackLabel, nil, musicListScroll, nil, nil, mainFrame, leaderboardScroll, updateProgressFunc)

        -- Após os dados carregados, exibe a GUI principal
        mainFrame.Visible = true
        mainFrame.Size = UDim2.new(0, 0, 0, 0)
        local entranceTween = TweenService:Create(mainFrame,
            TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Size = UDim2.new(0.9, 0, 0.85, 0)}
        )
        entranceTween:Play()
    end)
end

main()