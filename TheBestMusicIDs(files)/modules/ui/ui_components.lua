-- ══════════════════════════════════════════════════════════════
-- 🧩 ui_components.lua — Componentes de UI reutilizáveis
-- createLogoWidget, createSplashScreen, showKeySystem,
-- createKeyPanel, createAudioPlayerScreen, openEditMusicScreen,
-- openMoreOptionsMenu, createMusicCard, createPlaylistDetailView,
-- createAddToPlaylistModal, createNewPlaylistModal
-- Depende de: config.lua, core.lua, api.lua
-- ══════════════════════════════════════════════════════════════

local TMI              = _G.TMI
local player           = TMI.player
local TweenService        = TMI.TweenService
local UserInputService    = TMI.UserInputService
local RunService          = TMI.RunService
local Players             = TMI.Players
local MarketplaceService  = TMI.MarketplaceService
local HttpService      = TMI.HttpService
local ICONS            = TMI.ICONS
local RGB_COLORS       = TMI.RGB_COLORS
local _cache           = TMI._cache

local makeIcon          = TMI.makeIcon
local spinIcon          = TMI.spinIcon
local makeSwitch        = TMI.makeSwitch
local animRGB           = TMI.animRGB
local makeFloatingPanel = TMI.makeFloatingPanel
local makePanelHeader   = TMI.makePanelHeader
local formatCount       = TMI.formatCount
local normalizeImageUrl = TMI.normalizeImageUrl

local sbHeaders          = TMI.sbHeaders
local viewMusicList       = TMI.viewMusicList
local sbPatch            = TMI.sbPatch
local fetchLikeCount     = TMI.fetchLikeCount
local checkPlayerLiked   = TMI.checkPlayerLiked
local giveLike           = TMI.giveLike
local removeLike         = TMI.removeLike
local generateAccessLink = TMI.generateAccessLink
local validateKey        = TMI.validateKey
local sbDeleteMusic      = TMI.sbDeleteMusic
local fetchPlaylists     = TMI.fetchPlaylists
local addSongToPlaylistAPI    = TMI.addSongToPlaylistAPI
local removeSongFromPlaylistAPI = TMI.removeSongFromPlaylistAPI
local deletePlaylistAPI  = TMI.deletePlaylistAPI

local showKeySystem
local SCRIPT_NAME        = TMI.SCRIPT_NAME
local EDIT_SCRIPT_NAME   = TMI.EDIT_SCRIPT_NAME
local SUPABASE_URL       = TMI.SUPABASE_URL
local request            = TMI.request

local createAddToPlaylistModal
local createNewPlaylistModal
local openEditMusicScreen
local openMoreOptionsMenu

local function createLogoWidget(parent, size, position, zIndex)
    local container = Instance.new("Frame")
    container.Name = "LogoWidget"
    container.Size = UDim2.new(0, size, 0, size)
    container.Position = position
    container.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
    container.BorderSizePixel = 0
    container.ZIndex = zIndex or 2
    container.BackgroundTransparency = 0.4
    container.Parent = parent
    Instance.new("UICorner", container).CornerRadius = UDim.new(1, 0)

    local grad = Instance.new("UIGradient", container)
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 28, 42)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 16))
    })
    grad.Rotation = 135

    local rgbBorder = Instance.new("UIStroke", container)
    rgbBorder.Thickness = 3
    rgbBorder.Color = RGB_COLORS[1]
    rgbBorder.Transparency = 0
    rgbBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local iconSize = math.floor(size * 0.70)
    local icon = Instance.new("ImageLabel", container)
    icon.Size = UDim2.new(0, iconSize, 0, iconSize)
    icon.Position = UDim2.new(0.5, -iconSize/2, 0.5, -iconSize/2)
    icon.BackgroundTransparency = 1
    icon.Image = ICONS.LOGO
    icon.ScaleType = Enum.ScaleType.Fit
    icon.ZIndex = (zIndex or 2) + 2

    return container, rgbBorder, icon
end

-- [[ 🎨 FUNÇÃO DA SPLASH SCREEN ]]
local function createSplashScreen(onLoadComplete)
	local splashGui = Instance.new("ScreenGui")
	splashGui.Name = "SplashScreenGui"
	splashGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	splashGui.IgnoreGuiInset = true
	splashGui.ResetOnSpawn = false
	splashGui.Parent = game.CoreGui

	-- Background escuro com gradiente
	local background = Instance.new("Frame")
	background.Name = "Background"
	background.Size = UDim2.new(1, 0, 1, 0)
	background.Position = UDim2.new(0, 0, 0, 0)
	background.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
	background.BorderSizePixel = 0
	background.ZIndex = 100
	background.Parent = splashGui

	-- Gradiente animado no fundo
	local bgGradient = Instance.new("UIGradient", background)
	bgGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 5, 25)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(5, 15, 30)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 5, 15))
	})
	bgGradient.Rotation = 45

	-- Animação do gradiente do fundo
	spawn(function()
		while background.Parent do
			for i = 0, 360, 2 do
				if not background.Parent then break end
				bgGradient.Rotation = i
				wait(0.03)
			end
		end
	end)

	-- Container central
	local container = Instance.new("Frame")
	container.Name = "Container"
	container.Size = UDim2.new(0, 500, 0, 400)
	container.Position = UDim2.new(0.5, -250, 0.5, -200)
	container.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
	container.BorderSizePixel = 0
	container.ZIndex = 101
	container.BackgroundTransparency = 1
	container.Parent = background

	Instance.new("UICorner", container).CornerRadius = UDim.new(0, 25)
	container.ClipsDescendants = true

	-- Borda RGB animada
	local containerBorder = Instance.new("UIStroke", container)
	containerBorder.Thickness = 3
	containerBorder.Color = RGB_COLORS[1]
	containerBorder.Transparency = 0

	spawn(function()
		local idx = 1
		while container.Parent do
			idx = idx % #RGB_COLORS + 1
			TweenService:Create(containerBorder, TweenInfo.new(1.2, Enum.EasingStyle.Sine), {Color = RGB_COLORS[idx]}):Play()
			wait(1.2)
		end
	end)

	-- Glow effect no container
	local glow = Instance.new("ImageLabel", container)
	glow.Name = "Glow"
	glow.Size = UDim2.new(1, 40, 1, 40)
	glow.Position = UDim2.new(0.5, -20, 0.5, -20)
	glow.AnchorPoint = Vector2.new(0.5, 0.5)
	glow.BackgroundTransparency = 1
	glow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
	glow.ImageColor3 = RGB_COLORS[1]
	glow.ImageTransparency = 0.7
	glow.ZIndex = 100
	glow.ScaleType = Enum.ScaleType.Slice
	glow.SliceCenter = Rect.new(10, 10, 10, 10)

	-- Partículas decorativas (círculos flutuantes)
	local function createParticle()
		local particle = Instance.new("Frame")
		particle.Size = UDim2.new(0, math.random(3, 8), 0, math.random(3, 8))
		particle.Position = UDim2.new(math.random(0, 100) / 100, 0, math.random(0, 100) / 100, 0)
		particle.BackgroundColor3 = RGB_COLORS[math.random(1, #RGB_COLORS)]
		particle.BorderSizePixel = 0
		particle.ZIndex = 102
		particle.BackgroundTransparency = math.random(30, 70) / 100
		particle.Parent = background

		Instance.new("UICorner", particle).CornerRadius = UDim.new(1, 0)

		-- Animação flutuante
		local duration = math.random(3, 6)
		local endPos = UDim2.new(
			math.random(0, 100) / 100, 0,
			math.random(0, 100) / 100, 0
		)

		TweenService:Create(particle, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Position = endPos,
			BackgroundTransparency = 1
		}):Play()

		task.delay(duration, function()
			if particle then particle:Destroy() end
		end)
	end

	-- Gerar partículas continuamente
	local particleTask = task.spawn(function()
		for i = 1, 30 do
			createParticle()
			wait(0.1)
		end
		while container.Parent do
			createParticle()
			wait(0.5)
		end
	end)

	-- Ícone principal usando a logo
local iconFrame, iconBorder, iconImg = createLogoWidget(
    container, 120, UDim2.new(0.5, -60, 0.25, -60), 103
)

-- Pulso do ícone
spawn(function()
    while iconFrame.Parent do
        TweenService:Create(iconFrame, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Size = UDim2.new(0, 130, 0, 130),
            Position = UDim2.new(0.5, -65, 0.25, -65)
        }):Play()
        wait(1)
        TweenService:Create(iconFrame, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Size = UDim2.new(0, 120, 0, 120),
            Position = UDim2.new(0.5, -60, 0.25, -60)
        }):Play()
        wait(1)
    end
end)

-- RGB animado próprio (splash é independente da GUI principal)
spawn(function()
    local idx = 1
    while iconFrame.Parent do
        idx = idx % #RGB_COLORS + 1
        TweenService:Create(iconBorder, TweenInfo.new(1.2, Enum.EasingStyle.Sine), {Color = RGB_COLORS[idx]}):Play()
        wait(1.2)
    end
end)

	-- Título
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, -40, 0, 50)
	title.Position = UDim2.new(0, 20, 0.5, -25)
	title.BackgroundTransparency = 1
	title.Text = "MUSIC ID PUBLISHER"
	title.TextColor3 = Color3.new(1, 1, 1)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 28
	title.ZIndex = 103
	title.TextTransparency = 1
	title.Parent = container

	-- Efeito de brilho no título
	local titleStroke = Instance.new("UIStroke", title)
	titleStroke.Thickness = 1.5
	titleStroke.Color = RGB_COLORS[1]
	titleStroke.Transparency = 1

	-- Versão
	local version = Instance.new("TextLabel")
	version.Name = "Version"
	version.Size = UDim2.new(1, -40, 0, 25)
	version.Position = UDim2.new(0, 20, 0.6, 0)
	version.BackgroundTransparency = 1
	version.Text = "Versão " .. TMI.versao .. " — Enhanced Edition"
	version.TextColor3 = RGB_COLORS[2]
	version.Font = Enum.Font.Gotham
	version.TextSize = 14
	version.ZIndex = 103
	version.TextTransparency = 1
	version.Parent = container

	-- Status de carregamento
	local loadingText = Instance.new("TextLabel")
	loadingText.Name = "LoadingText"
	loadingText.Size = UDim2.new(1, -40, 0, 25)
	loadingText.Position = UDim2.new(0, 20, 0.72, 0)
	loadingText.BackgroundTransparency = 1
	loadingText.Text = "Inicializando..."
	loadingText.TextColor3 = Color3.fromRGB(200, 200, 200)
	loadingText.Font = Enum.Font.Gotham
	loadingText.TextSize = 13
	loadingText.ZIndex = 103
	loadingText.TextTransparency = 1
	loadingText.Parent = container

	-- Barra de progresso (fundo)
	local progressBg = Instance.new("Frame")
	progressBg.Name = "ProgressBg"
	progressBg.Size = UDim2.new(1, -80, 0, 8)
	progressBg.Position = UDim2.new(0, 40, 0.82, 0)
	progressBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	progressBg.BorderSizePixel = 0
	progressBg.ZIndex = 103
	progressBg.BackgroundTransparency = 1
	progressBg.Parent = container

	Instance.new("UICorner", progressBg).CornerRadius = UDim.new(1, 0)

	-- Barra de progresso (preenchimento)
	local progressBar = Instance.new("Frame")
	progressBar.Name = "ProgressBar"
	progressBar.Size = UDim2.new(0, 0, 1, 0)
	progressBar.BackgroundColor3 = RGB_COLORS[1]
	progressBar.BorderSizePixel = 0
	progressBar.ZIndex = 104
	progressBar.Parent = progressBg

	Instance.new("UICorner", progressBar).CornerRadius = UDim.new(1, 0)

	-- Gradiente na barra de progresso
	local progressGradient = Instance.new("UIGradient", progressBar)
	progressGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, RGB_COLORS[1]),
		ColorSequenceKeypoint.new(0.5, RGB_COLORS[2]),
		ColorSequenceKeypoint.new(1, RGB_COLORS[3])
	})

	-- Animação do gradiente da barra
	spawn(function()
		local offset = 0
		while progressBar.Parent do
			offset = (offset + 0.02) % 1
			progressGradient.Offset = Vector2.new(offset, 0)
			wait(0.03)
		end
	end)

	-- Percentual
	local percentText = Instance.new("TextLabel")
	percentText.Name = "PercentText"
	percentText.Size = UDim2.new(1, -40, 0, 20)
	percentText.Position = UDim2.new(0, 20, 0.88, 0)
	percentText.BackgroundTransparency = 1
	percentText.Text = "0%"
	percentText.TextColor3 = Color3.new(1, 1, 1)
	percentText.Font = Enum.Font.GothamBold
	percentText.TextSize = 16
	percentText.ZIndex = 103
	percentText.TextTransparency = 1
	percentText.Parent = container

	-- Animação de entrada (fade in + scale)
	container.Size = UDim2.new(0, 100, 0, 100)
	container.Position = UDim2.new(0.5, -50, 0.5, -50)

	wait(0.1)

	-- Fade in do background
	TweenService:Create(background, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()

	-- Entrada do container
	TweenService:Create(container, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 500, 0, 400),
		Position = UDim2.new(0.5, -250, 0.5, -200),
		BackgroundTransparency = 0
	}):Play()

	-- Fade in dos textos
	wait(0.3)
	TweenService:Create(title, TweenInfo.new(0.6), {TextTransparency = 0}):Play()
	TweenService:Create(titleStroke, TweenInfo.new(0.6), {Transparency = 0}):Play()
	wait(0.2)
	TweenService:Create(version, TweenInfo.new(0.6), {TextTransparency = 0}):Play()
	wait(0.2)
	TweenService:Create(loadingText, TweenInfo.new(0.6), {TextTransparency = 0}):Play()
	TweenService:Create(progressBg, TweenInfo.new(0.6), {BackgroundTransparency = 0}):Play()
	TweenService:Create(percentText, TweenInfo.new(0.6), {TextTransparency = 0}):Play()

	-- Função para atualizar progresso
	-- Ao chamar com percent=100, a splash fecha sozinha e chama onLoadComplete
	local splashClosed = false
	local function updateProgress(percent, status)
		percent = math.clamp(percent, 0, 100)
		loadingText.Text = status or "Carregando..."
		percentText.Text = math.floor(percent) .. "%"
		TweenService:Create(progressBar, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(percent / 100, 0, 1, 0)
		}):Play()

		if percent >= 100 and not splashClosed then
			splashClosed = true
			task.delay(0.6, function()
				TweenService:Create(title, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
				TweenService:Create(titleStroke, TweenInfo.new(0.4), {Transparency = 1}):Play()
				TweenService:Create(version, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
				TweenService:Create(loadingText, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
				TweenService:Create(percentText, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
				TweenService:Create(progressBg, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
				TweenService:Create(progressBar, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
				task.wait(0.3)
				TweenService:Create(container, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
					Size = UDim2.new(0, 0, 0, 0),
					Position = UDim2.new(0.5, 0, 0.5, 0),
					BackgroundTransparency = 1
				}):Play()
				TweenService:Create(containerBorder, TweenInfo.new(0.6), {Transparency = 1}):Play()
				task.wait(0.4)
				TweenService:Create(background, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
				task.wait(0.6)
				task.cancel(particleTask)
				splashGui:Destroy()
				if onLoadComplete then onLoadComplete() end
			end)
		end
	end

	return splashGui, updateProgress
end

-- [[ 🖼️ GUI DO KEY SYSTEM ]] --

-- ════════════════════════════════════════════════════════════
-- 🏗️ SISTEMA DE PAINÉIS REUTILIZÁVEIS
-- ════════════════════════════════════════════════════════════

-- Anima a cor de uma UIStroke ou TextLabel ciclicamente nos RGB_COLORS
local function animRGB(target, prop, speed)
    prop = prop or "Color"
    speed = speed or 1
    local idx = 1
    local function loop()
        if not target.Parent then return end
        idx = idx % #RGB_COLORS + 1
        TweenService:Create(target, TweenInfo.new(speed, Enum.EasingStyle.Sine), {[prop] = RGB_COLORS[idx]}):Play()
        task.delay(speed, loop)
    end
    loop()
end

--[[
    makeFloatingPanel(parent, opts, buildFn) → closePanel
    ────────────────────────────────────────────────────────
    Cria um overlay escuro (TextButton) com um painel flutuante centralizado,
    borda RGB animada e animação de entrada/saída.

    opts = {
        zBase      = 30,          -- ZIndex base (overlay = zBase, panel = zBase+1)
        panelSize  = UDim2,       -- tamanho do painel (default: 0.88 × 320)
        panelPos   = UDim2,       -- posição do painel (default: centralizado)
        overlayClose = true,      -- fechar ao clicar no overlay? (default: true)
        cornerRadius = 18,        -- raio dos cantos do painel
        gradient   = true,        -- aplicar UIGradient no painel?
        rgbSpeed   = 1,           -- velocidade da animação RGB da borda
    }
    buildFn(panel, closePanel)   -- callback que popula o painel
--]]
local function makeFloatingPanel(parent, opts, buildFn)
    opts = opts or {}
    local z         = opts.zBase or 30
    local pSize     = opts.panelSize or UDim2.new(0.88, 0, 0, 320)
    local pH        = pSize.Y.Offset
    local pPos      = opts.panelPos  or UDim2.new(0.06, 0, 0.5, -pH/2)
    local cr        = opts.cornerRadius or 18
    local rgbSpd    = opts.rgbSpeed or 1
    local canClose  = opts.overlayClose ~= false

    -- Overlay (bloqueia interação, fundo escuro, hitbox NÃO fecha)
    local overlay = Instance.new("TextButton", parent)
    overlay.Name                  = "FloatingOverlay"
    overlay.Size                  = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3      = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.45
    overlay.Text                  = ""
    overlay.BorderSizePixel       = 0
    overlay.ZIndex                = z
    overlay.AutoButtonColor       = false
    Instance.new("UICorner", overlay).CornerRadius = UDim.new(0, 20)

    -- Painel (filho do overlay, cliques DENTRO não fecham)
    local panel = Instance.new("Frame", overlay)
    panel.Name                   = "FloatingPanel"
    panel.Size                   = pSize
    panel.Position               = pPos
    panel.BackgroundColor3       = Color3.fromRGB(16, 14, 24)
    panel.BorderSizePixel        = 0
    panel.ZIndex                 = z + 1
    panel.BackgroundTransparency = 1
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, cr)

    if opts.gradient ~= false then
        local gr = Instance.new("UIGradient", panel)
        gr.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 18, 36)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 8, 18))
        })
        gr.Rotation = 135
    end

    local border = Instance.new("UIStroke", panel)
    border.Thickness = 2
    border.Color     = RGB_COLORS[1]
    animRGB(border, "Color", rgbSpd)

    -- Animação de entrada
    local startPos = UDim2.new(pPos.X.Scale, pPos.X.Offset, pPos.Y.Scale, pPos.Y.Offset - 25)
    panel.Position = startPos
    TweenService:Create(panel, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position             = pPos,
        BackgroundTransparency = 0
    }):Play()
    TweenService:Create(overlay, TweenInfo.new(0.2), {BackgroundTransparency = 0.45}):Play()

    -- closePanel: fecha com animação e destrói o overlay
    local closed = false
    local function closePanel()
        if closed then return end
        closed = true
        TweenService:Create(panel, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size                 = UDim2.new(pSize.X.Scale, pSize.X.Offset, 0, 0),
            Position             = UDim2.new(pPos.X.Scale, pPos.X.Offset, pPos.Y.Scale, pPos.Y.Offset + pH/2),
            BackgroundTransparency = 1
        }):Play()
        TweenService:Create(overlay, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
        task.wait(0.27)
        if overlay and overlay.Parent then overlay:Destroy() end
    end

    -- Overlay só fecha se overlayClose=true E clicar FORA do painel
    overlay.MouseButton1Click:Connect(function()
        if canClose then closePanel() end
    end)
    -- Bloquear propagação do clique dentro do painel (impede fechar ao clicar nele)
    local hitblock = Instance.new("TextButton", panel)
    hitblock.Size                  = UDim2.new(1, 0, 1, 0)
    hitblock.BackgroundTransparency = 1
    hitblock.Text                  = ""
    hitblock.ZIndex                = z + 1
    hitblock.AutoButtonColor       = false
    hitblock.MouseButton1Click:Connect(function() end)

    -- Chama o builder com painel e closePanel
    if buildFn then buildFn(panel, closePanel, overlay) end

    return closePanel, panel, overlay
end

-- Header padrão para painéis: título + botão X (retorna closeBtn)
local function makePanelHeader(panel, titleText, zBase)
    local z = zBase or (panel.ZIndex or 30)
    local header = Instance.new("Frame", panel)
    header.Size                 = UDim2.new(1, 0, 0, 46)
    header.BackgroundColor3     = Color3.fromRGB(22, 18, 36)
    header.BorderSizePixel      = 0
    header.ZIndex               = z + 2
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 18)

    local lbl = Instance.new("TextLabel", header)
    lbl.Size                   = UDim2.new(1, -50, 1, 0)
    lbl.Position               = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text                   = titleText
    lbl.TextColor3             = Color3.fromRGB(200, 185, 255)
    lbl.Font                   = Enum.Font.GothamBold
    lbl.TextSize               = 15
    lbl.TextXAlignment         = Enum.TextXAlignment.Left
    lbl.ZIndex                 = z + 3

    local closeBtn = Instance.new("TextButton", header)
    closeBtn.Size              = UDim2.new(0, 28, 0, 28)
    closeBtn.Position          = UDim2.new(1, -36, 0.5, -14)
    closeBtn.BackgroundColor3  = Color3.fromRGB(180, 40, 40)
    closeBtn.BorderSizePixel   = 0
    closeBtn.Text              = ""
    closeBtn.ZIndex            = z + 3
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)
    makeIcon(closeBtn, ICONS.CLOSE, UDim2.new(0, 16, 0, 16), UDim2.new(0.5, -8, 0.5, -8), z + 4)

    return header, closeBtn, lbl
end

-- ════════════════════════════════════════════════════════════
-- 🔐 KEY SYSTEM REUTILIZÁVEL
-- ════════════════════════════════════════════════════════════
--[[
    showKeySystem(parent, scriptName, onSuccess, onCancel)
    ────────────────────────────────────────────────────────
    Exibe o painel de verificação de key.
    scriptName: "publish_music", "edit_music", "playlist_create", etc.
    onSuccess / onCancel: callbacks opcionais
--]]
local function showKeySystem(parent, scriptName, onSuccess, onCancel, zBaseOverride)
    scriptName = scriptName or SCRIPT_NAME
    local ICON_LINK   = ICONS.LINK
    local ICON_VERIFY = ICONS.VERIFY
    local ICON_OK     = ICONS.OK

    makeFloatingPanel(parent, {
        zBase      = zBaseOverride or 60,
        panelSize  = UDim2.new(0.85, 0, 0, 300),
        panelPos   = UDim2.new(0.075, 0, 0.5, -150),
        overlayClose = false,
        cornerRadius = 15,
    }, function(panel, closePanel)
        local z = (zBaseOverride or 60) + 1

        local title = Instance.new("TextLabel", panel)
        title.Size               = UDim2.new(1, -20, 0, 32)
        title.Position           = UDim2.new(0, 12, 0, 12)
        title.BackgroundTransparency = 1
        title.Text               = "🔐 VERIFICAÇÃO NECESSÁRIA"
        title.TextColor3         = Color3.fromRGB(200, 200, 255)
        title.Font               = Enum.Font.GothamBold
        title.TextSize           = 16
        title.TextXAlignment     = Enum.TextXAlignment.Left
        title.ZIndex             = z

        local sub = Instance.new("TextLabel", panel)
        sub.Size                 = UDim2.new(1, -20, 0, 18)
        sub.Position             = UDim2.new(0, 12, 0, 46)
        sub.BackgroundTransparency = 1
        sub.Text                 = "Insira a key para continuar"
        sub.TextColor3           = Color3.fromRGB(140, 130, 170)
        sub.Font                 = Enum.Font.Gotham
        sub.TextSize             = 13
        sub.TextXAlignment       = Enum.TextXAlignment.Left
        sub.ZIndex               = z

        local keyBg = Instance.new("Frame", panel)
        keyBg.Size               = UDim2.new(1, -24, 0, 42)
        keyBg.Position           = UDim2.new(0, 12, 0, 76)
        keyBg.BackgroundColor3   = Color3.fromRGB(28, 24, 42)
        keyBg.BorderSizePixel    = 0
        keyBg.ZIndex             = z
        Instance.new("UICorner", keyBg).CornerRadius = UDim.new(0, 10)
        Instance.new("UIStroke", keyBg).Color = Color3.fromRGB(80, 60, 120)

        local keyBox = Instance.new("TextBox", keyBg)
        keyBox.Size              = UDim2.new(1, -16, 1, 0)
        keyBox.Position          = UDim2.new(0, 8, 0, 0)
        keyBox.BackgroundTransparency = 1
        keyBox.PlaceholderText   = "Cole sua key aqui..."
        keyBox.Text              = ""
        keyBox.TextColor3        = Color3.fromRGB(255, 255, 255)
        keyBox.Font              = Enum.Font.Gotham
        keyBox.TextSize          = 15
        keyBox.ZIndex            = z + 1
        keyBox.ClearTextOnFocus  = false

        -- Texto de erro (fora dos botões)
        local errLbl = Instance.new("TextLabel", panel)
        errLbl.Size              = UDim2.new(1, -24, 0, 18)
        errLbl.Position          = UDim2.new(0, 12, 0, 126)
        errLbl.BackgroundTransparency = 1
        errLbl.Text              = ""
        errLbl.TextColor3        = Color3.fromRGB(255, 100, 100)
        errLbl.Font              = Enum.Font.Gotham
        errLbl.TextSize          = 12
        errLbl.TextXAlignment    = Enum.TextXAlignment.Left
        errLbl.ZIndex            = z

        -- Botão PEGAR KEY
        local getBtn = Instance.new("TextButton", panel)
        getBtn.Size              = UDim2.new(0.42, -8, 0, 40)
        getBtn.Position          = UDim2.new(0, 12, 0, 152)
        getBtn.BackgroundColor3  = Color3.fromRGB(255, 170, 0)
        getBtn.Text              = ""
        getBtn.BorderSizePixel   = 0
        getBtn.ZIndex            = z + 1
        Instance.new("UICorner", getBtn).CornerRadius = UDim.new(0, 10)
        local getLinkIco = makeIcon(getBtn, ICON_LINK, UDim2.new(0, 20, 0, 20), UDim2.new(0.5, -60, 0.5, -10), z + 2)
        local getLbl = Instance.new("TextLabel", getBtn)
        getLbl.Size              = UDim2.new(1, -28, 1, 0)
        getLbl.Position          = UDim2.new(0, 26, 0, 0)
        getLbl.BackgroundTransparency = 1
        getLbl.Text              = "PEGAR KEY"
        getLbl.TextColor3        = Color3.fromRGB(255, 255, 255)
        getLbl.Font              = Enum.Font.GothamBold
        getLbl.TextSize          = 13
        getLbl.ZIndex            = z + 2

        -- Estado ERRO inline do getBtn (só "ERRO" no botão + msg fora)
        local getErrLbl = Instance.new("TextLabel", panel)
        getErrLbl.Size           = UDim2.new(1, -24, 0, 14)
        getErrLbl.Position       = UDim2.new(0, 12, 0, 196)
        getErrLbl.BackgroundTransparency = 1
        getErrLbl.Text           = ""
        getErrLbl.TextColor3     = Color3.fromRGB(255, 120, 80)
        getErrLbl.Font           = Enum.Font.Gotham
        getErrLbl.TextSize       = 11
        getErrLbl.TextXAlignment = Enum.TextXAlignment.Left
        getErrLbl.ZIndex         = z

        -- Botão VERIFICAR
        local verBtn = Instance.new("TextButton", panel)
        verBtn.Size              = UDim2.new(0.55, -8, 0, 40)
        verBtn.Position          = UDim2.new(0.45, 0, 0, 152)
        verBtn.BackgroundColor3  = Color3.fromRGB(0, 200, 100)
        verBtn.Text              = ""
        verBtn.BorderSizePixel   = 0
        verBtn.ZIndex            = z + 1
        Instance.new("UICorner", verBtn).CornerRadius = UDim.new(0, 10)
        local verIco = makeIcon(verBtn, ICON_VERIFY, UDim2.new(0, 20, 0, 20), UDim2.new(0.5, -80, 0.5, -10), z + 2)
        local verLbl = Instance.new("TextLabel", verBtn)
        verLbl.Size              = UDim2.new(1, -28, 1, 0)
        verLbl.Position          = UDim2.new(0, 26, 0, 0)
        verLbl.BackgroundTransparency = 1
        verLbl.Text              = "VERIFICAR"
        verLbl.TextColor3        = Color3.fromRGB(255, 255, 255)
        verLbl.Font              = Enum.Font.GothamBold
        verLbl.TextSize          = 14
        verLbl.ZIndex            = z + 2

        -- Botão CANCELAR
        local cancelBtn = Instance.new("TextButton", panel)
        cancelBtn.Size           = UDim2.new(1, -24, 0, 28)
        cancelBtn.Position       = UDim2.new(0, 12, 0, 256)
        cancelBtn.BackgroundTransparency = 1
        cancelBtn.Text           = "Cancelar"
        cancelBtn.TextColor3     = Color3.fromRGB(150, 150, 150)
        cancelBtn.Font           = Enum.Font.Gotham
        cancelBtn.TextSize       = 14
        cancelBtn.BorderSizePixel = 0
        cancelBtn.ZIndex         = z + 1

        -- Lógica PEGAR KEY
        getBtn.MouseButton1Click:Connect(function()
            getLinkIco.Image = ICONS.LOADING
            getLbl.Text = "GERANDO..."
            getErrLbl.Text = ""
            local _spin = spinIcon(getLinkIco)
            task.spawn(function()
                local ok = generateAccessLink(scriptName)
                _spin:Disconnect(); getLinkIco.Rotation = 0
                if ok then
                    getLinkIco.Image = ICON_OK
                    getLbl.Text = "COPIADO!"
                    task.wait(2)
                else
                    getLinkIco.Image = ICON_LINK
                    getLbl.Text = "ERRO"
                    getErrLbl.Text = "não foi possível gerar o link"
                    task.wait(2)
                    getErrLbl.Text = ""
                end
                getLinkIco.Image = ICON_LINK
                getLbl.Text = "PEGAR KEY"
            end)
        end)

        -- Lógica VERIFICAR
        verBtn.MouseButton1Click:Connect(function()
            local key = keyBox.Text:match("^%s*(.-)%s*$")
            if key == "" then errLbl.Text = "⚠️ Digite a key primeiro."; return end
            errLbl.Text = ""
            verIco.Image = ICONS.LOADING
            verLbl.Text = "VERIFICANDO..."
            local _spin = spinIcon(verIco)
            verBtn.Active = false
            task.spawn(function()
                local ok, msg = validateKey(key, scriptName)
                _spin:Disconnect(); verIco.Rotation = 0
                verBtn.Active = true
                if ok then
                    verIco.Image = ICON_OK
                    verLbl.Text = "SUCESSO!"
                    verBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                    task.wait(0.4)
                    closePanel()
                    if onSuccess then onSuccess() end
                else
                    verIco.Image = ICON_VERIFY
                    verLbl.Text = "ERRO"
                    verBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
                    errLbl.Text = tostring(msg or "key inválida ou expirada")
                    task.wait(2)
                    verBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
                    verLbl.Text = "VERIFICAR"
                    errLbl.Text = ""
                end
            end)
        end)

        cancelBtn.MouseButton1Click:Connect(function()
            closePanel()
            if onCancel then onCancel() end
        end)
    end)
end

-- createKeyPanel: redireciona para showKeySystem (reutilizável)
-- Mantida por compatibilidade com chamadas existentes
local function createKeyPanel(parent, onSuccessCallback, onCancelCallback)
    showKeySystem(parent, SCRIPT_NAME, onSuccessCallback, onCancelCallback)
    -- Retorna um frame dummy para compatibilidade com código que acessa .ZIndex/.Visible
    local dummy = Instance.new("Frame"); dummy.Name = "KeySystemFrame"
    dummy.Size = UDim2.new(0,0,0,0); dummy.BackgroundTransparency = 1
    dummy.Visible = true; dummy.ZIndex = 60; dummy.Parent = parent
    return dummy
end

-- Forward declaration para o modal
local createAddToPlaylistModal
local createNewPlaylistModal  -- → ADICIONAR ESTA LINHA

-- 鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲═
-- 📡 PLAYLIST API
-- 鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲═
-- ═══════════════════════════════════════════════════════════════════
-- 📡 FUNÇÕES DE API — SUPABASE
-- Colunas espelham os nomes Lua para não alterar o código de display.
-- musics   : ID_Musica, Nome, Categoria, PlayerName, DisplayName,
--            UserId, Foto, Data
-- playlists: PlaylistId (text PK), PlaylistName, OwnerId, OwnerName,
--            ImageUrl, Songs (jsonb array de strings)
-- likes    : user_id, music_id   (UNIQUE)
-- follows  : follower_id, following_id  (UNIQUE)
-- ═══════════════════════════════════════════════════════════════════

-- Busca todas as playlists de um userId
local function fetchPlaylists(userId, callback)
    task.spawn(function()
        local ok, res = pcall(function()
            return request({
                Url     = SUPABASE_URL .. "/rest/v1/playlists?OwnerId=eq." .. tostring(userId) .. "&select=*&order=created_at.asc",
                Method  = "GET",
                Headers = sbHeaders(),
            })
        end)
        if ok and res and res.Body then
            local pok, data = pcall(function() return HttpService:JSONDecode(res.Body) end)
            callback(pok and type(data) == "table", pok and data or {})
        else
            callback(false, {})
        end
    end)
end

-- Busca todas as músicas do banco
-- ════════════════════════════════════════════════════════════
-- 🔄 CARGA COMPLETA DO CACHE (splash + background refresh)
-- Faz 5 requests em paralelo e popula _cache de uma vez.
-- onProgress(pct, msg) — opcional, usado pela splash screen.
-- onDone(success)      — chamado quando tudo terminar.
-- ════════════════════════════════════════════════════════════
local function loadFullCache(onProgress, onDone)
    local function rep(p, m) if onProgress then onProgress(p, m) end end

    local results  = {}
    local pending  = 5
    local function checkDone()
        pending -= 1
        if pending > 0 then return end

        -- ── Distribuir resultados no _cache ──────────────────
        -- 1. Músicas
        if type(results.musics) == "table" then
            _cache.musicData = results.musics
            _cache.musicData     = _cache.musicData   -- mantém alias legado
            _dirty.musicList = false
        end

        -- 2. Likes totais por música
        _cache.likesMap = {}
        if type(results.allLikes) == "table" then
            for _, row in ipairs(results.allLikes) do
                local mid = tostring(row.music_id)
                _cache.likesMap[mid] = (_cache.likesMap[mid] or 0) + 1
            end
        end

        -- 3. Minhas músicas curtidas
        _cache.myLikes = {}
        if type(results.myLikes) == "table" then
            for _, row in ipairs(results.myLikes) do
                _cache.myLikes[tostring(row.music_id)] = true
            end
        end

        -- 4. Seguidores de cada player
        _cache.followersMap = {}
        if type(results.allFollows) == "table" then
            for _, row in ipairs(results.allFollows) do
                local uid = tostring(row.following_id)
                _cache.followersMap[uid] = (_cache.followersMap[uid] or 0) + 1
            end
        end

        -- 5. Players que eu sigo
        _cache.myFollowing = {}
        if type(results.myFollowing) == "table" then
            for _, row in ipairs(results.myFollowing) do
                _cache.myFollowing[tostring(row.following_id)] = true
            end
        end

        _dirty.leaderboard = true
        -- NÃO chama rep(100) aqui — o caller (viewMusicList) é responsável pelo 100%
        -- para garantir que o leaderboard também termine antes de fechar a splash.
        if onDone then onDone(true) end
    end

    local function fetch(key, url, pct, msg)
        task.spawn(function()
            rep(pct, msg)
            local ok, res = pcall(function()
                return request({ Url = SUPABASE_URL..url, Method = "GET", Headers = sbHeaders() })
            end)
            if ok and res and res.Body then
                local pok, data = pcall(function() return HttpService:JSONDecode(res.Body) end)
                results[key] = (pok and type(data)=="table") and data or {}
            else
                results[key] = {}
            end
            checkDone()
        end)
    end

    fetch("musics",      "/rest/v1/musics?select=*&order=Data.desc",                                        10, "Carregando músicas...")
    fetch("allLikes",    "/rest/v1/likes?select=music_id",                                                  30, "Carregando likes...")
    fetch("myLikes",     "/rest/v1/likes?user_id=eq."..tostring(player.UserId).."&select=music_id",         50, "Verificando suas curtidas...")
    fetch("allFollows",  "/rest/v1/follows?select=following_id",                                            65, "Carregando seguidores...")
    fetch("myFollowing", "/rest/v1/follows?follower_id=eq."..tostring(player.UserId).."&select=following_id", 80, "Verificando quem você segue...")
end

-- Alias legado (alguns lugares ainda chamam fetchAllMusic)
local function fetchAllMusic(callback)
    loadFullCache(nil, function(ok) callback(ok, _cache.musicData) end)
end

-- Cria uma nova playlist
local function createPlaylistAPI(name, imageUrl, callback)
    task.spawn(function()
        -- ID gerado no cliente no mesmo formato legado
        local newId = "PL_" .. tostring(player.UserId) .. "_" .. tostring(os.time())
        local body = HttpService:JSONEncode({
            PlaylistId   = newId,
            PlaylistName = name,
            OwnerId      = tostring(player.UserId),
            OwnerName    = player.Name,
            ImageUrl     = imageUrl or "",
            Songs        = {},
        })
        local ok, res = pcall(function()
            return request({
                Url     = SUPABASE_URL .. "/rest/v1/playlists",
                Method  = "POST",
                Headers = sbHeaders(),
                Body    = body,
            })
        end)
        if ok and res then
            local st = tonumber(res.StatusCode) or 0
            if st == 201 or st == 200 then
                callback(true, newId)
            else
                callback(false, tostring(res.Body or "Erro ao criar"))
            end
        else
            callback(false, "Falha de conexão")
        end
    end)
end

-- Adiciona uma música a uma playlist (read-modify-write nas Songs jsonb)
local function addSongToPlaylistAPI(playlistId, songId, callback)
    task.spawn(function()
        -- 1. Busca Songs atual
        local ok1, res1 = pcall(function()
            return request({
                Url     = SUPABASE_URL .. "/rest/v1/playlists?PlaylistId=eq." .. tostring(playlistId) .. "&select=Songs",
                Method  = "GET",
                Headers = sbHeaders(),
            })
        end)
        if not (ok1 and res1 and res1.Body) then callback(false, "Falha de conexão"); return end
        local pok, rows = pcall(function() return HttpService:JSONDecode(res1.Body) end)
        if not pok or type(rows) ~= "table" or #rows == 0 then callback(false, "Playlist não encontrada"); return end

        local songs = rows[1].Songs or {}
        -- Verifica duplicata
        for _, s in ipairs(songs) do
            if tostring(s) == tostring(songId) then callback(false, "já está na playlist"); return end
        end
        table.insert(songs, tostring(songId))

        -- 2. Salva de volta
        local ok2, res2 = pcall(function()
            return sbPatch("playlists", "PlaylistId=eq." .. tostring(playlistId), { Songs = songs })
        end)
        if ok2 and res2 then
            local st = tonumber(res2.StatusCode) or 0
            callback(st == 200 or st == 204, st ~= 200 and st ~= 204 and tostring(res2.Body) or "Sucesso")
        else
            callback(false, "Falha de conexão")
        end
    end)
end

-- Remove uma música de uma playlist
local function removeSongFromPlaylistAPI(playlistId, songId, callback)
    task.spawn(function()
        local ok1, res1 = pcall(function()
            return request({
                Url     = SUPABASE_URL .. "/rest/v1/playlists?PlaylistId=eq." .. tostring(playlistId) .. "&select=Songs",
                Method  = "GET",
                Headers = sbHeaders(),
            })
        end)
        if not (ok1 and res1 and res1.Body) then callback(false, "Falha de conexão"); return end
        local pok, rows = pcall(function() return HttpService:JSONDecode(res1.Body) end)
        if not pok or type(rows) ~= "table" or #rows == 0 then callback(false, "Playlist não encontrada"); return end

        local songs = rows[1].Songs or {}
        local newSongs = {}
        for _, s in ipairs(songs) do
            if tostring(s) ~= tostring(songId) then table.insert(newSongs, tostring(s)) end
        end

        local ok2, res2 = pcall(function()
            return sbPatch("playlists", "PlaylistId=eq." .. tostring(playlistId), { Songs = newSongs })
        end)
        local st = ok2 and res2 and tonumber(res2.StatusCode) or 0
        callback(st == 200 or st == 204, "Sucesso")
    end)
end

-- Deleta uma playlist inteira
local function deletePlaylistAPI(playlistId, callback)
    task.spawn(function()
        local ok, res = pcall(function()
            return request({
                Url     = SUPABASE_URL .. "/rest/v1/playlists?PlaylistId=eq." .. tostring(playlistId) .. "&OwnerId=eq." .. tostring(player.UserId),
                Method  = "DELETE",
                Headers = sbHeaders(),
            })
        end)
        local st = ok and res and tonumber(res.StatusCode) or 0
        callback(st == 200 or st == 204, "Sucesso")
    end)
end

-- createAudioPlayerScreen movido para audio_player.lua


-- 鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲═
-- ══════════════════════════════════════════════════════════
-- ✏️ TELA DE EDIÇÃO DE MÚSICA
-- ══════════════════════════════════════════════════════════
local CATEGORIES_LIST = {"Funk","Hip Hop","Phonk","Lo-fi","Eletrônica","Sertanejo","Rock","Pop","Outro"}

-- openEditKeyVerify: usa showKeySystem com zBase=100 para ficar acima do painel de edição (zBase=88)
local function openEditKeyVerify(parent, onConfirm)
    showKeySystem(parent, EDIT_SCRIPT_NAME, onConfirm, nil, 100)
end

-- DELETE de uma música (apenas o dono — RLS policy: UserId = x-player-id)
local function sbDeleteMusic(musicId, callback)
    task.spawn(function()
        local ok, res = pcall(function()
            return request({
                Url     = SUPABASE_URL .. "/rest/v1/musics?ID_Musica=eq." .. tostring(musicId),
                Method  = "DELETE",
                Headers = sbHeaders(),
            })
        end)
        local st = ok and res and tonumber(res.StatusCode) or 0
        callback(st == 200 or st == 204 or st == 201 or st == 200)
    end)
end

function openEditMusicScreen(parent, musicData)
    -- Código de 6 dígitos aleatório gerado a cada abertura do painel
    local DANGER_CODE = string.format("%06d", math.random(0, 999999))
    makeFloatingPanel(parent, {
        zBase        = 88,
        panelSize    = UDim2.new(0.88, 0, 0, 360),
        panelPos     = UDim2.new(0.06, 0, 0.5, -180),
        overlayClose = false,
    }, function(panel, closePanel)
    local z = 90

    -- ── HEADER FIXO ──────────────────────────────────────────────
    local _, closeBtn, titleLbl = makePanelHeader(panel, "✏️  EDITAR PUBLICAÇÃO", z)
    closeBtn.MouseButton1Click:Connect(closePanel)
    titleLbl.TextColor3 = Color3.fromRGB(220, 220, 255)

    -- ── SCROLL (área do meio, entre header e botão salvar) ────────
    local HEADER_H = 44
    local FOOTER_H = 52  -- altura reservada para o botão salvar fixo
    local scroll = Instance.new("ScrollingFrame", panel)
    scroll.Size = UDim2.new(1, 0, 1, -(HEADER_H + FOOTER_H))
    scroll.Position = UDim2.new(0, 0, 0, HEADER_H)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Color3.fromRGB(80,80,120)
    scroll.CanvasSize = UDim2.new(1, 0, 0, 0)  -- ajustado depois
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.ScrollingDirection = Enum.ScrollingDirection.Y
    scroll.ZIndex = z
    -- clip para não sobrepor header/footer
    scroll.ClipsDescendants = true

    local sy = 8  -- cursor Y dentro do scroll

    local function addToScroll(inst, h, extraPad)
        inst.Parent = scroll
        inst.ZIndex = z + 1
        sy = sy + (extraPad or 0)
        inst.Position = UDim2.new(inst.Position.X.Scale, inst.Position.X.Offset, 0, sy)
        sy = sy + h
    end

    -- helper: cria TextLabel label dentro do scroll
    local function makeLabel(txt, color, size)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1,-24,0,18)
        l.Position = UDim2.new(0,12,0,0)
        l.BackgroundTransparency = 1
        l.Text = txt
        l.TextColor3 = color or Color3.fromRGB(160,160,220)
        l.Font = Enum.Font.GothamBold
        l.TextSize = size or 11
        l.TextXAlignment = Enum.TextXAlignment.Left
        return l
    end

    -- ── ID (não editável) ─────────────────────────────────────────
    addToScroll(makeLabel("ID DA MÚSICA (não editável)", Color3.fromRGB(70,70,90)), 18)

    local idField = Instance.new("TextLabel")
    idField.Size = UDim2.new(1,-24,0,38); idField.Position = UDim2.new(0,12,0,0)
    idField.BackgroundColor3 = Color3.fromRGB(16,16,22); idField.BorderSizePixel = 0
    idField.Text = tostring(musicData.ID_Musica or "")
    idField.TextColor3 = Color3.fromRGB(60,60,80); idField.Font = Enum.Font.Gotham
    idField.TextSize = 14
    Instance.new("UICorner", idField).CornerRadius = UDim.new(0,10)
    Instance.new("UIStroke", idField).Color = Color3.fromRGB(35,35,50)
    addToScroll(idField, 42, 2)

    -- ── NOME ──────────────────────────────────────────────────────
    addToScroll(makeLabel("NOME DA MÚSICA"), 18, 8)

    local nomeBox = Instance.new("TextBox")
    nomeBox.Size = UDim2.new(1,-24,0,38); nomeBox.Position = UDim2.new(0,12,0,0)
    nomeBox.BackgroundColor3 = Color3.fromRGB(22,22,36); nomeBox.BorderSizePixel = 0
    nomeBox.PlaceholderText = "Nome do áudio..."; nomeBox.Text = tostring(musicData.Nome or "")
    nomeBox.TextColor3 = Color3.fromRGB(255,255,255); nomeBox.Font = Enum.Font.Gotham
    nomeBox.TextSize = 14; nomeBox.ClearTextOnFocus = false
    Instance.new("UICorner", nomeBox).CornerRadius = UDim.new(0,10)
    local nomeStroke = Instance.new("UIStroke", nomeBox); nomeStroke.Color = Color3.fromRGB(60,60,90)
    addToScroll(nomeBox, 40, 2)

    -- contador
    local NAME_MAX = 20
    local nomeCounter = Instance.new("TextLabel")
    nomeCounter.Size = UDim2.new(0,50,0,14); nomeCounter.Position = UDim2.new(1,-62,0,0)
    nomeCounter.BackgroundTransparency = 1
    nomeCounter.Text = #nomeBox.Text.."/"..NAME_MAX
    nomeCounter.TextColor3 = Color3.fromRGB(120,120,120); nomeCounter.Font = Enum.Font.Gotham
    nomeCounter.TextSize = 11
    addToScroll(nomeCounter, 0)  -- sobreposição leve (decorativo)

    nomeBox:GetPropertyChangedSignal("Text"):Connect(function()
        local cur = #nomeBox.Text
        if cur > NAME_MAX then nomeBox.Text = string.sub(nomeBox.Text, 1, NAME_MAX); return end
        nomeCounter.Text = cur.."/"..NAME_MAX
        nomeCounter.TextColor3 = cur >= NAME_MAX and Color3.fromRGB(255,100,100) or Color3.fromRGB(120,120,120)
    end)

    -- ── CATEGORIA ─────────────────────────────────────────────────
    addToScroll(makeLabel("CATEGORIA"), 18, 10)

    local originalNome = tostring(musicData.Nome or "")
    local originalCat  = tostring(musicData.Categoria or "Outro")
    local selectedCat  = musicData.Categoria or "Outro"
    local dangerUnlocked = false  -- declarado ANTES dos catBtns para que os handlers o capturem corretamente
    local catBtns = {}
    local catX, catY = 12, sy
    local catRowStart = sy

    for _, cat in ipairs(CATEGORIES_LIST) do
        local cb = Instance.new("TextButton")
        cb.Size = UDim2.new(0, 72, 0, 26); cb.Position = UDim2.new(0, catX, 0, catY)
        cb.BackgroundColor3 = (cat == selectedCat) and Color3.fromRGB(50,100,200) or Color3.fromRGB(28,28,42)
        cb.Text = cat; cb.TextColor3 = Color3.fromRGB(255,255,255)
        cb.Font = Enum.Font.Gotham; cb.TextSize = 11; cb.BorderSizePixel = 0
        cb.ZIndex = z + 1; cb.Parent = scroll
        Instance.new("UICorner", cb).CornerRadius = UDim.new(0,8)
        Instance.new("UIStroke", cb).Color = Color3.fromRGB(55,55,80)
        catBtns[cat] = cb
        catX = catX + 78
        if catX > 250 then catX = 12; catY = catY + 32 end
        cb.MouseButton1Click:Connect(function()
            if dangerUnlocked or not cb.Active then return end  -- bloqueado no modo perigo (ou botão desativado)
            selectedCat = cat
            for k, b in pairs(catBtns) do
                TweenService:Create(b, TweenInfo.new(0.15), {
                    BackgroundColor3 = (k == cat) and Color3.fromRGB(50,100,200) or Color3.fromRGB(28,28,42)
                }):Play()
            end
            updateSaveBtn()
        end)
    end
    -- avança cursor após as linhas de categoria
    local catRows = math.ceil(#CATEGORIES_LIST / 3)
    sy = catRowStart + catRows * 32 + 4

    -- ── ÁREA DE PERIGO ────────────────────────────────────────────
    sy = sy + 16

    -- linha divisória
    local divLine = Instance.new("Frame")
    divLine.Size = UDim2.new(1,-24,0,1); divLine.Position = UDim2.new(0,12,0,sy)
    divLine.BackgroundColor3 = Color3.fromRGB(180,40,40); divLine.BorderSizePixel = 0
    divLine.ZIndex = z+1; divLine.Parent = scroll
    sy = sy + 9

    -- título "ÁREA DE PERIGO"
    local dangerTitle = Instance.new("TextLabel")
    dangerTitle.Size = UDim2.new(1,-24,0,18); dangerTitle.Position = UDim2.new(0,12,0,sy)
    dangerTitle.BackgroundTransparency = 1; dangerTitle.Text = "⚠️  ÁREA DE PERIGO"
    dangerTitle.TextColor3 = Color3.fromRGB(255,70,70); dangerTitle.Font = Enum.Font.GothamBold
    dangerTitle.TextSize = 12; dangerTitle.TextXAlignment = Enum.TextXAlignment.Left
    dangerTitle.ZIndex = z+1; dangerTitle.Parent = scroll
    sy = sy + 22

    -- descrição
    local dangerDesc = Instance.new("TextLabel")
    dangerDesc.Size = UDim2.new(1,-24,0,30); dangerDesc.Position = UDim2.new(0,12,0,sy)
    dangerDesc.BackgroundTransparency = 1
    dangerDesc.Text = "Ações irreversíveis. Tenha certeza antes de prosseguir."
    dangerDesc.TextColor3 = Color3.fromRGB(180,100,100); dangerDesc.Font = Enum.Font.Gotham
    dangerDesc.TextSize = 10; dangerDesc.TextXAlignment = Enum.TextXAlignment.Left
    dangerDesc.TextWrapped = true; dangerDesc.ZIndex = z+1; dangerDesc.Parent = scroll
    sy = sy + 34

    -- ── Toggle "Excluir música" ─────────────────────────────────
    local toggleRow = Instance.new("Frame", scroll)
    toggleRow.Size = UDim2.new(1,-24,0,36); toggleRow.Position = UDim2.new(0,12,0,sy)
    toggleRow.BackgroundTransparency = 1; toggleRow.ZIndex = z+1

    -- label
    local toggleLabel = Instance.new("TextLabel", toggleRow)
    toggleLabel.Size = UDim2.new(1,-54,1,0); toggleLabel.Position = UDim2.new(0,0,0,0)
    toggleLabel.BackgroundTransparency = 1; toggleLabel.Text = "Excluir música"
    toggleLabel.TextColor3 = Color3.fromRGB(255,80,80); toggleLabel.Font = Enum.Font.GothamBold
    toggleLabel.TextSize = 13; toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.ZIndex = z+2

    -- switch reutilizável (cor vermelha = modo perigo)
    local sw = makeSwitch(toggleRow, toggleRow.AbsoluteSize.X - 44, 6, z+2, Color3.fromRGB(200,50,50))
    sw.track.Position = UDim2.new(1,-44,0.5,-12)  -- reposiciona relativo ao toggleRow
    local switchTrack    = sw.track
    local switchStroke   = sw.stroke
    local switchKnob     = sw.knob
    local dangerActivateBtn = sw.track
    sy = sy + 40

    -- padding final do scroll
    sy = sy + 8

    -- ── BOTÃO SALVAR FIXO NA BASE ─────────────────────────────────
    local saveBtn = Instance.new("TextButton", panel)
    saveBtn.Size = UDim2.new(1,-24,0,38); saveBtn.Position = UDim2.new(0,12,1,-(FOOTER_H - 7))
    saveBtn.BackgroundColor3 = Color3.fromRGB(55,55,70); saveBtn.Text = "SALVAR ALTERAÇÕES"
    saveBtn.TextColor3 = Color3.fromRGB(130,130,150); saveBtn.Font = Enum.Font.GothamBold
    saveBtn.TextSize = 15; saveBtn.BorderSizePixel = 0; saveBtn.ZIndex = z + 2
    saveBtn.Active = false
    Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0,12)
    local saveBtnStroke = Instance.new("UIStroke", saveBtn)
    saveBtnStroke.Color = Color3.fromRGB(70,70,90); saveBtnStroke.Thickness = 1.5

    -- linha separadora acima do botão salvar
    local footerLine = Instance.new("Frame", panel)
    footerLine.Size = UDim2.new(1,0,0,1); footerLine.Position = UDim2.new(0,0,1,-FOOTER_H)
    footerLine.BackgroundColor3 = Color3.fromRGB(45,45,65); footerLine.BorderSizePixel = 0
    footerLine.ZIndex = z + 2

    -- ── ESTADO: modo perigo ativo ─────────────────────────────────
    -- (dangerUnlocked já declarado antes dos catBtns, ver acima)

    local function setFieldsLocked(locked)
        -- bloqueia/desbloqueia nome e categorias
        nomeBox.TextEditable = not locked
        nomeBox.Active = not locked
        nomeBox.BackgroundColor3 = locked and Color3.fromRGB(16,16,22) or Color3.fromRGB(22,22,36)
        nomeBox.TextColor3 = locked and Color3.fromRGB(60,60,80) or Color3.fromRGB(255,255,255)
        for _, b in pairs(catBtns) do
            b.Active = not locked
            b.AutoButtonColor = not locked
            TweenService:Create(b, TweenInfo.new(0.15), {
                BackgroundColor3 = locked and Color3.fromRGB(18,18,28) or
                    ((b.Text == selectedCat) and Color3.fromRGB(50,100,200) or Color3.fromRGB(28,28,42)),
                TextColor3 = locked and Color3.fromRGB(60,60,80) or Color3.fromRGB(255,255,255)
            }):Play()
        end
    end

    -- updateSaveBtn
    function updateSaveBtn()
        if dangerUnlocked then
            -- modo perigo: botão vira "CONFIRMAR EXCLUSÃO" vermelho e ativo
            saveBtn.Active = true
            saveBtn.Text = "🗑️  CONFIRMAR EXCLUSÃO"
            TweenService:Create(saveBtn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(160,20,20),
                TextColor3 = Color3.fromRGB(255,255,255)
            }):Play()
            TweenService:Create(saveBtnStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(255,60,60)}):Play()
            return
        end
        local nameChanged = nomeBox.Text:match("^%s*(.-)%s*$") ~= originalNome
        local catChanged  = selectedCat ~= originalCat
        local hasChanges  = nameChanged or catChanged
        if hasChanges then
            saveBtn.Active = true
            TweenService:Create(saveBtn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(40,130,255),
                TextColor3 = Color3.fromRGB(255,255,255)
            }):Play()
            TweenService:Create(saveBtnStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(80,180,255)}):Play()
        else
            saveBtn.Active = false
            TweenService:Create(saveBtn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(55,55,70),
                TextColor3 = Color3.fromRGB(130,130,150)
            }):Play()
            TweenService:Create(saveBtnStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(70,70,90)}):Play()
        end
    end

    nomeBox:GetPropertyChangedSignal("Text"):Connect(updateSaveBtn)

    -- ── PAINEL DE CONFIRMAÇÃO DE CÓDIGO (reutilizável) ────────────
    dangerActivateBtn.MouseButton1Click:Connect(function()
        -- Se já está ativo, basta desativar sem painel de código
        if dangerUnlocked then
            dangerUnlocked = false
            setFieldsLocked(false)
            TweenService:Create(dangerActivateBtn, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
                BackgroundColor3 = Color3.fromRGB(50,50,70)
            }):Play()
            TweenService:Create(switchStroke, TweenInfo.new(0.25), {
                Color = Color3.fromRGB(100,40,40)
            }):Play()
            TweenService:Create(switchKnob, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
                Position = UDim2.new(0,3,0.5,-9),
                BackgroundColor3 = Color3.fromRGB(140,80,80)
            }):Play()
            updateSaveBtn()
            return
        end
        -- Usa makeFloatingPanel reutilizável, igual ao showKeySystem
        makeFloatingPanel(parent, {
            zBase        = 102,
            panelSize    = UDim2.new(0.85, 0, 0, 300),
            panelPos     = UDim2.new(0.075, 0, 0.5, -150),
            overlayClose = false,
            cornerRadius = 15,
        }, function(confirmPanel, closeConfirm)
            local cz = 104

            -- título
            local cTitle = Instance.new("TextLabel", confirmPanel)
            cTitle.Size = UDim2.new(1,-16,0,28); cTitle.Position = UDim2.new(0,10,0,12)
            cTitle.BackgroundTransparency = 1; cTitle.Text = "🔐  CONFIRMAR EXCLUSÃO"
            cTitle.TextColor3 = Color3.fromRGB(255,80,80); cTitle.Font = Enum.Font.GothamBold
            cTitle.TextSize = 15; cTitle.TextXAlignment = Enum.TextXAlignment.Center; cTitle.ZIndex = cz

            -- instrução linha 1
            local cInfo1 = Instance.new("TextLabel", confirmPanel)
            cInfo1.Size = UDim2.new(1,-24,0,18); cInfo1.Position = UDim2.new(0,12,0,52)
            cInfo1.BackgroundTransparency = 1; cInfo1.Text = "Para ativar a exclusão,"
            cInfo1.TextColor3 = Color3.fromRGB(200,200,220); cInfo1.Font = Enum.Font.Gotham
            cInfo1.TextSize = 13; cInfo1.TextXAlignment = Enum.TextXAlignment.Center; cInfo1.ZIndex = cz

            -- instrução linha 2 (código em vermelho) — usando RichText
            local cInfo2 = Instance.new("TextLabel", confirmPanel)
            cInfo2.Size = UDim2.new(1,-24,0,20); cInfo2.Position = UDim2.new(0,12,0,70)
            cInfo2.BackgroundTransparency = 1
            cInfo2.RichText = true
            cInfo2.Text = 'digite o código: <font color="#FF4444"><b>' .. DANGER_CODE .. '</b></font>'
            cInfo2.TextColor3 = Color3.fromRGB(200,200,220); cInfo2.Font = Enum.Font.Gotham
            cInfo2.TextSize = 13; cInfo2.TextXAlignment = Enum.TextXAlignment.Center; cInfo2.ZIndex = cz

            -- aviso irreversível
            local cWarn = Instance.new("TextLabel", confirmPanel)
            cWarn.Size = UDim2.new(1,-24,0,28); cWarn.Position = UDim2.new(0,12,0,94)
            cWarn.BackgroundTransparency = 1; cWarn.Text = "⚠️ Esta ação é IRREVERSÍVEL!\nO áudio será excluído permanentemente."
            cWarn.TextColor3 = Color3.fromRGB(255,160,60); cWarn.Font = Enum.Font.Gotham
            cWarn.TextSize = 11; cWarn.TextXAlignment = Enum.TextXAlignment.Center
            cWarn.TextWrapped = true; cWarn.ZIndex = cz

            -- campo de código
            local cBox = Instance.new("TextBox", confirmPanel)
            cBox.Size = UDim2.new(1,-40,0,42); cBox.Position = UDim2.new(0,20,0,134)
            cBox.BackgroundColor3 = Color3.fromRGB(20,12,12); cBox.BorderSizePixel = 0
            cBox.PlaceholderText = "Digite o código aqui..."; cBox.Text = ""
            cBox.TextColor3 = Color3.fromRGB(255,100,100); cBox.Font = Enum.Font.GothamBold
            cBox.TextSize = 16; cBox.ClearTextOnFocus = false; cBox.ZIndex = cz
            cBox.TextXAlignment = Enum.TextXAlignment.Center
            Instance.new("UICorner", cBox).CornerRadius = UDim.new(0,10)
            local cBoxStroke = Instance.new("UIStroke", cBox)
            cBoxStroke.Color = Color3.fromRGB(120,30,30); cBoxStroke.Thickness = 1.5

            -- feedback do código
            local cFb = Instance.new("TextLabel", confirmPanel)
            cFb.Size = UDim2.new(1,-24,0,16); cFb.Position = UDim2.new(0,12,0,182)
            cFb.BackgroundTransparency = 1; cFb.Text = ""
            cFb.TextColor3 = Color3.fromRGB(255,80,80); cFb.Font = Enum.Font.Gotham
            cFb.TextSize = 11; cFb.TextXAlignment = Enum.TextXAlignment.Center; cFb.ZIndex = cz

            -- botão confirmar
            local cConfirm = Instance.new("TextButton", confirmPanel)
            cConfirm.Size = UDim2.new(1,-40,0,40); cConfirm.Position = UDim2.new(0,20,0,204)
            cConfirm.BackgroundColor3 = Color3.fromRGB(140,20,20); cConfirm.BorderSizePixel = 0
            cConfirm.Text = "CONFIRMAR"; cConfirm.TextColor3 = Color3.fromRGB(255,255,255)
            cConfirm.Font = Enum.Font.GothamBold; cConfirm.TextSize = 14; cConfirm.ZIndex = cz
            Instance.new("UICorner", cConfirm).CornerRadius = UDim.new(0,10)
            Instance.new("UIStroke", cConfirm).Color = Color3.fromRGB(255,60,60)

            -- botão cancelar
            local cCancel = Instance.new("TextButton", confirmPanel)
            cCancel.Size = UDim2.new(1,-40,0,34); cCancel.Position = UDim2.new(0,20,0,250)
            cCancel.BackgroundColor3 = Color3.fromRGB(35,35,50); cCancel.BorderSizePixel = 0
            cCancel.Text = "CANCELAR"; cCancel.TextColor3 = Color3.fromRGB(160,160,180)
            cCancel.Font = Enum.Font.Gotham; cCancel.TextSize = 13; cCancel.ZIndex = cz
            Instance.new("UICorner", cCancel).CornerRadius = UDim.new(0,10)

            cCancel.MouseButton1Click:Connect(closeConfirm)

            cConfirm.MouseButton1Click:Connect(function()
                local typed = cBox.Text:match("^%s*(.-)%s*$")
                if typed ~= DANGER_CODE then
                    cFb.Text = "❌ Código incorreto!"
                    TweenService:Create(cBoxStroke, TweenInfo.new(0.1,Enum.EasingStyle.Bounce), {
                        Color = Color3.fromRGB(255,60,60)
                    }):Play()
                    return
                end
                -- Código correto → fecha painel de confirmação e ativa modo perigo
                closeConfirm()
                dangerUnlocked = true
                setFieldsLocked(true)
                -- Anima switch para ON: trilha vermelha, bolinha vai para a direita
                dangerActivateBtn.Active = true  -- permanece clicável para desativar
                TweenService:Create(dangerActivateBtn, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
                    BackgroundColor3 = Color3.fromRGB(180,25,25)
                }):Play()
                TweenService:Create(switchStroke, TweenInfo.new(0.25), {
                    Color = Color3.fromRGB(255,60,60)
                }):Play()
                TweenService:Create(switchKnob, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
                    Position = UDim2.new(1,-21,0.5,-9),
                    BackgroundColor3 = Color3.fromRGB(255,255,255)
                }):Play()
                updateSaveBtn()
            end)
        end)
    end)

    -- ── helper: executar delete após key verificada ───────────────
    local function doDelete()
        saveBtn.Text = "DELETANDO..."; saveBtn.Active = false
        local _ico = makeIcon(saveBtn, ICONS.LOADING, UDim2.new(0,16,0,16), UDim2.new(0,8,0.5,-8), z+3)
        local _spin = spinIcon(_ico)
        sbDeleteMusic(musicData.ID_Musica, function(ok)
            _spin:Disconnect(); if _ico and _ico.Parent then _ico:Destroy() end
            if ok then
                for i, m in ipairs(_cache.musicData) do
                    if tostring(m.ID_Musica) == tostring(musicData.ID_Musica) then
                        table.remove(_cache.musicData, i); break
                    end
                end
                closePanel()
            else
                saveBtn.Text = "❌ Erro ao deletar!"; saveBtn.TextColor3 = Color3.fromRGB(255,80,80)
                task.wait(2)
                if saveBtn and saveBtn.Parent then
                    saveBtn.Text = "🗑️  CONFIRMAR EXCLUSÃO"; saveBtn.Active = true
                    saveBtn.TextColor3 = Color3.fromRGB(255,255,255)
                end
            end
        end)
    end

    -- ── SALVAR ────────────────────────────────────────────────────
    saveBtn.MouseButton1Click:Connect(function()
        if not saveBtn.Active then return end
        -- Modo perigo: o botão salvar vira "confirmar exclusão"
        if dangerUnlocked then
            openEditKeyVerify(parent, function()
                doDelete()
            end)
            return
        end
        local newName = nomeBox.Text:match("^%s*(.-)%s*$")
        if newName == "" then return end
        openEditKeyVerify(parent, function()
            saveBtn.Text = "SALVANDO..."; saveBtn.Active = false
            local _sIco = makeIcon(saveBtn, ICONS.LOADING, UDim2.new(0,16,0,16), UDim2.new(0,8,0.5,-8), z+3)
            local _spin = spinIcon(_sIco)
            task.spawn(function()
                local ok2, res = pcall(function()
                    return sbPatch("musics", "ID_Musica=eq."..tostring(musicData.ID_Musica), {
                        Nome = newName, Categoria = selectedCat
                    })
                end)
                local st = ok2 and res and tonumber(res.StatusCode) or 0
                local success = (st == 200 or st == 204 or st == 201)
                local errMsg  = (not ok2) and tostring(res) or ("HTTP " .. tostring(st))
                _spin:Disconnect(); if _sIco and _sIco.Parent then _sIco:Destroy() end
                saveBtn.Active = true
                if success then
                    musicData.Nome = newName; musicData.Categoria = selectedCat
                    originalNome = newName; originalCat = selectedCat
                    for _, m in ipairs(_cache.musicData) do
                        if tostring(m.ID_Musica) == tostring(musicData.ID_Musica) then
                            m.Nome = newName; m.Categoria = selectedCat; break
                        end
                    end
                    saveBtn.Text = "✅ Salvo!"; saveBtn.TextColor3 = Color3.fromRGB(80,255,140)
                    updateSaveBtn()
                    task.wait(1.5); closePanel()
                else
                    saveBtn.Text = "❌ Erro: " .. errMsg
                    saveBtn.TextColor3 = Color3.fromRGB(255,80,80)
                    task.wait(2)
                    if saveBtn and saveBtn.Parent then
                        saveBtn.Text = "SALVAR ALTERAÇÕES"; updateSaveBtn()
                    end
                end
            end)
        end)
    end)

    end) -- fim makeFloatingPanel (openEditMusicScreen)
end

-- ⋰ MENU DE MAIS OPÇÕES (3 pontinhos)
-- 鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲═

function openMoreOptionsMenu(parent, musicData)
    makeFloatingPanel(parent, {
        zBase        = 70,
        panelSize    = UDim2.new(0.88, 0, 0, 320),
        panelPos     = UDim2.new(0.06, 0, 0.5, -160),
        overlayClose = false,
    }, function(panel, closeMenu)
    local z = 72

    local _, closeBtn, titleLbl = makePanelHeader(panel, "⋰  MAIS OPÇÕES", z)
    closeBtn.MouseButton1Click:Connect(closeMenu)
    titleLbl.TextColor3 = Color3.fromRGB(220, 220, 255)

    local infoFrame = Instance.new("Frame", panel)
    infoFrame.Size = UDim2.new(1, -24, 0, 62); infoFrame.Position = UDim2.new(0, 12, 0, 50)
    infoFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 30); infoFrame.BorderSizePixel = 0; infoFrame.ZIndex = 72
    Instance.new("UICorner", infoFrame).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", infoFrame).Color = Color3.fromRGB(45, 45, 70)

    local infoName = Instance.new("TextLabel", infoFrame)
    infoName.Size = UDim2.new(1, -12, 0, 28); infoName.Position = UDim2.new(0, 10, 0, 4)
    infoName.BackgroundTransparency = 1; infoName.Text = "🎵 " .. (musicData.Nome or "N/A")
    infoName.TextColor3 = Color3.fromRGB(255, 255, 255); infoName.Font = Enum.Font.GothamBold
    infoName.TextSize = 15; infoName.TextXAlignment = Enum.TextXAlignment.Left
    infoName.TextTruncate = Enum.TextTruncate.AtEnd; infoName.ZIndex = 73

    local infoId = Instance.new("TextLabel", infoFrame)
    infoId.Size = UDim2.new(1, -12, 0, 20); infoId.Position = UDim2.new(0, 10, 0, 34)
    infoId.BackgroundTransparency = 1; infoId.Text = "🆔 " .. tostring(musicData.ID_Musica or "N/A") .. "  📂 " .. (musicData.Categoria or "Outros")
    infoId.TextColor3 = Color3.fromRGB(150, 150, 200); infoId.Font = Enum.Font.Gotham
    infoId.TextSize = 12; infoId.TextXAlignment = Enum.TextXAlignment.Left; infoId.ZIndex = 73

    -- Divisor
    local div = Instance.new("Frame", panel)
    div.Size = UDim2.new(1, -24, 0, 1); div.Position = UDim2.new(0, 12, 0, 118)
    div.BackgroundColor3 = Color3.fromRGB(45, 45, 70); div.BorderSizePixel = 0; div.ZIndex = 72

    -- ScrollFrame para os botões (permite rolar se não couber na tela)
    local btnScroll = Instance.new("ScrollingFrame", panel)
    btnScroll.Size = UDim2.new(1, 0, 1, -128)
    btnScroll.Position = UDim2.new(0, 0, 0, 128)
    btnScroll.BackgroundTransparency = 1
    btnScroll.BorderSizePixel = 0
    btnScroll.ScrollBarThickness = 3
    btnScroll.ScrollBarImageColor3 = Color3.fromRGB(80,80,120)
    btnScroll.CanvasSize = UDim2.new(0, 0, 0, 210) -- 3 botões × 70px cada
    btnScroll.ZIndex = 72
    btnScroll.ClipsDescendants = true

    -- ── Status do áudio ──────────────────────────────────────────────────────
    -- nil  → ainda não verificado → verificação prioritária ao abrir o painel
    -- "ok" | "banned" | "private" → já verificado (cache)
    local audioIdStr  = tostring(musicData.ID_Musica or "")
    local audioStatus = TMI._audioStatusCache[audioIdStr]
    local isPending   = (audioStatus == nil)
    local listenBlocked = isPending or audioStatus == "banned" or audioStatus == "private"

    -- ── Texto de motivo ───────────────────────────────────────────────────────
    local listenBlockReason, listenBlockColor
    if isPending then
        listenBlockReason = "Verificando..."
        listenBlockColor  = Color3.fromRGB(140, 140, 200)
    elseif audioStatus == "private" then
        listenBlockReason = "Privado — sem permissão de acesso"
        listenBlockColor  = Color3.fromRGB(200, 160, 0)
    elseif audioStatus == "banned" then
        listenBlockReason = "Indisponível — banido ou inexistente"
        listenBlockColor  = Color3.fromRGB(200, 60, 60)
    end

    -- €€ Botão: 🎵 ESCUTAR ÁUDIO €€
    local listenBtn = Instance.new("TextButton", btnScroll)
    listenBtn.Size = UDim2.new(1, -24, 0, 60); listenBtn.Position = UDim2.new(0, 12, 0, 0)
    listenBtn.BackgroundColor3 = listenBlocked
        and Color3.fromRGB(18, 18, 25)
        or  Color3.fromRGB(20, 20, 38)
    listenBtn.Text = ""
    listenBtn.BorderSizePixel = 0; listenBtn.ZIndex = 72
    listenBtn.Active = not listenBlocked
    Instance.new("UICorner", listenBtn).CornerRadius = UDim.new(0, 14)
    local lBtnStroke = Instance.new("UIStroke", listenBtn)
    lBtnStroke.Thickness    = 1.8
    lBtnStroke.Color        = listenBlocked and Color3.fromRGB(45, 45, 60) or RGB_COLORS[1]
    lBtnStroke.Transparency = listenBlocked and 0.5 or 0

    -- Animação RGB da borda (só quando já desbloqueado desde o início)
    if not listenBlocked then
        spawn(function()
            local i = 1
            while listenBtn.Parent do
                i = i % #RGB_COLORS + 1
                TweenService:Create(lBtnStroke, TweenInfo.new(1, Enum.EasingStyle.Sine), {Color = RGB_COLORS[i]}):Play()
                wait(1)
            end
        end)
    end

    -- Ícone principal: spinner LOADING enquanto pendente, LISTEN nos demais casos
    local listenIcon = Instance.new("ImageLabel", listenBtn)
    listenIcon.Size = UDim2.new(0, 32, 0, 32); listenIcon.Position = UDim2.new(0, 14, 0.5, -16)
    listenIcon.BackgroundTransparency = 1
    listenIcon.Image     = isPending and ICONS.LOADING or ICONS.LISTEN
    listenIcon.ScaleType = Enum.ScaleType.Fit; listenIcon.ZIndex = 73
    listenIcon.ImageTransparency = (listenBlocked and not isPending) and 0.6 or 0

    -- Gira o ícone principal enquanto aguarda a verificação
    local mainIconSpinConn
    if isPending then
        mainIconSpinConn = spinIcon(listenIcon)
    end

    local listenLbl = Instance.new("TextLabel", listenBtn)
    listenLbl.Size = UDim2.new(1, -60, 0, 22); listenLbl.Position = UDim2.new(0, 52, 0, 8)
    listenLbl.BackgroundTransparency = 1; listenLbl.Text = "ESCUTAR ÁUDIO"
    listenLbl.TextXAlignment = Enum.TextXAlignment.Left
    listenLbl.TextColor3 = listenBlocked
        and Color3.fromRGB(80, 80, 100)
        or  Color3.fromRGB(255, 255, 255)
    listenLbl.Font = Enum.Font.GothamBold; listenLbl.TextSize = 15; listenLbl.ZIndex = 73

    -- Ícone de carregando menor no subtext (visível apenas quando pendente)
    local subSpinImg = Instance.new("ImageLabel", listenBtn)
    subSpinImg.Size                   = UDim2.new(0, 12, 0, 12)
    subSpinImg.Position               = UDim2.new(0, 52, 0, 36)
    subSpinImg.BackgroundTransparency = 1
    subSpinImg.Image                  = ICONS.LOADING
    subSpinImg.ScaleType              = Enum.ScaleType.Fit
    subSpinImg.ZIndex                 = 74
    subSpinImg.Visible                = isPending

    local subSpinConn
    if isPending then
        subSpinConn = spinIcon(subSpinImg)
    end

    local listenSub = Instance.new("TextLabel", listenBtn)
    -- Quando pendente: desloca à direita para dar espaço ao spinner do subtext
    listenSub.Size = UDim2.new(1, isPending and -82 or -60, 0, 16)
    listenSub.Position = UDim2.new(0, isPending and 68 or 52, 0, 34)
    listenSub.BackgroundTransparency = 1
    listenSub.Text = listenBlocked
        and (listenBlockReason or "Verificando...")
        or  "Player com efeitos visuais sincronizados"
    listenSub.TextXAlignment = Enum.TextXAlignment.Left
    listenSub.TextColor3 = listenBlocked
        and (listenBlockColor or Color3.fromRGB(130, 130, 180))
        or  Color3.fromRGB(130, 130, 180)
    listenSub.Font = Enum.Font.Gotham; listenSub.TextSize = 11; listenSub.ZIndex = 73

    -- ── Helpers de atualização dinâmica de UI ─────────────────────────────────
    local function enableListenBtn()
        if not listenBtn or not listenBtn.Parent then return end
        listenBtn.Active = true
        listenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 38)
        listenIcon.Image = ICONS.LISTEN
        listenIcon.ImageTransparency = 0
        lBtnStroke.Color = RGB_COLORS[1]
        lBtnStroke.Transparency = 0
        listenLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        listenSub.Position = UDim2.new(0, 52, 0, 34)
        listenSub.Size = UDim2.new(1, -60, 0, 16)
        listenSub.Text = "Player com efeitos visuais sincronizados"
        listenSub.TextColor3 = Color3.fromRGB(130, 130, 180)
        subSpinImg.Visible = false
        -- Inicia animação RGB da borda
        spawn(function()
            local i = 1
            while listenBtn.Parent do
                i = i % #RGB_COLORS + 1
                TweenService:Create(lBtnStroke, TweenInfo.new(1, Enum.EasingStyle.Sine), {Color = RGB_COLORS[i]}):Play()
                wait(1)
            end
        end)
        listenBtn.MouseEnter:Connect(function()
            TweenService:Create(listenBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30, 30, 55)}):Play()
        end)
        listenBtn.MouseLeave:Connect(function()
            TweenService:Create(listenBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(20, 20, 38)}):Play()
        end)
        listenBtn.MouseButton1Click:Connect(function()
            closeMenu(); task.wait(0.35)
            TMI.createAudioPlayerScreen(parent, musicData)
        end)
    end

    local function blockListenBtn(status)
        if not listenBtn or not listenBtn.Parent then return end
        listenBtn.Active = false
        listenBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
        listenIcon.Image = ICONS.LISTEN
        listenIcon.ImageTransparency = 0.6
        lBtnStroke.Color = Color3.fromRGB(45, 45, 60)
        lBtnStroke.Transparency = 0.5
        listenLbl.TextColor3 = Color3.fromRGB(80, 80, 100)
        subSpinImg.Visible = false
        listenSub.Position = UDim2.new(0, 52, 0, 34)
        listenSub.Size = UDim2.new(1, -60, 0, 16)
        if status == "private" then
            listenSub.Text = "Privado — sem permissão de acesso"
            listenSub.TextColor3 = Color3.fromRGB(200, 160, 0)
        else
            listenSub.Text = "Indisponível — banido ou inexistente"
            listenSub.TextColor3 = Color3.fromRGB(200, 60, 60)
        end
    end

    -- Hover e clique (só quando já desbloqueado desde o início — pendente recebe via callback)
    if not listenBlocked then
        listenBtn.MouseEnter:Connect(function()
            TweenService:Create(listenBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30, 30, 55)}):Play()
        end)
        listenBtn.MouseLeave:Connect(function()
            TweenService:Create(listenBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(20, 20, 38)}):Play()
        end)
        listenBtn.MouseButton1Click:Connect(function()
            closeMenu(); task.wait(0.35)
            TMI.createAudioPlayerScreen(parent, musicData)
        end)
    end

    -- ── Verificação prioritária quando o status ainda não foi verificado ───────
    -- Chama checkAudioStatus imediatamente para ESTE ID, antes dos demais.
    -- Se o preload de fundo já iniciou este ID, apenas enfileira o callback
    -- via _audioCheckingSet (sem duplicar requisições HTTP).
    -- Ao concluir, atualiza a UI dinamicamente no painel já aberto.
    if isPending then
        checkAudioStatus(audioIdStr, function(status)
            -- Para os spinners
            if mainIconSpinConn then mainIconSpinConn:Disconnect(); mainIconSpinConn = nil end
            if subSpinConn      then subSpinConn:Disconnect();      subSpinConn = nil      end
            listenIcon.Rotation = 0

            if status == "ok" then
                enableListenBtn()
            else
                blockListenBtn(status)
            end
        end)
    end

    -- €€ Botão: ➡ ADICIONAR À PLAYLIST €€
    local plBtn = Instance.new("TextButton", btnScroll)
    plBtn.Size = UDim2.new(1, -24, 0, 60); plBtn.Position = UDim2.new(0, 12, 0, 70)
    plBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 38); plBtn.Text = ""
    plBtn.BorderSizePixel = 0; plBtn.ZIndex = 72
    Instance.new("UICorner", plBtn).CornerRadius = UDim.new(0, 14)
    local plBtnStroke = Instance.new("UIStroke", plBtn)
    plBtnStroke.Thickness = 1.8; plBtnStroke.Color = Color3.fromRGB(140, 70, 200)

    local plIcon = makeIcon(plBtn, ICONS.TAB_MUSICAS, UDim2.new(0, 28, 0, 28), UDim2.new(0, 10, 0.5, -14), 73)
    local plLbl = Instance.new("TextLabel", plBtn)
    plLbl.Size = UDim2.new(1, -60, 0, 22); plLbl.Position = UDim2.new(0, 52, 0, 8)
    plLbl.BackgroundTransparency = 1; plLbl.Text = "ADICIONAR À PLAYLIST"; plLbl.TextXAlignment = Enum.TextXAlignment.Left
    plLbl.TextColor3 = Color3.fromRGB(200, 160, 255); plLbl.Font = Enum.Font.GothamBold; plLbl.TextSize = 15; plLbl.ZIndex = 73
    local plSub = Instance.new("TextLabel", plBtn)
    plSub.Size = UDim2.new(1, -60, 0, 16); plSub.Position = UDim2.new(0, 52, 0, 32)
    plSub.BackgroundTransparency = 1; plSub.Text = "Salvar em uma das suas playlists"
    plSub.TextXAlignment = Enum.TextXAlignment.Left; plSub.TextColor3 = Color3.fromRGB(130, 100, 180)
    plSub.Font = Enum.Font.Gotham; plSub.TextSize = 11; plSub.ZIndex = 73

    plBtn.MouseEnter:Connect(function()
        TweenService:Create(plBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30, 20, 50)}):Play()
    end)
    plBtn.MouseLeave:Connect(function()
        TweenService:Create(plBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(20, 20, 38)}):Play()
    end)
    plBtn.MouseButton1Click:Connect(function()
        closeMenu()
        task.wait(0.35)
        if createAddToPlaylistModal then
            createAddToPlaylistModal(parent, musicData)
        end
    end)

    -- €€ Botão: ✏️ EDITAR PUBLICAÇÃO €€
    local isOwner = tostring(musicData.UserId) == tostring(player.UserId)

    local editBtn = Instance.new("TextButton", btnScroll)
    editBtn.Size = UDim2.new(1, -24, 0, 56); editBtn.Position = UDim2.new(0, 12, 0, 140)
    editBtn.BackgroundColor3 = isOwner and Color3.fromRGB(20, 20, 38) or Color3.fromRGB(18, 18, 25)
    editBtn.Text = ""; editBtn.BorderSizePixel = 0; editBtn.ZIndex = 72
    editBtn.Active = isOwner
    Instance.new("UICorner", editBtn).CornerRadius = UDim.new(0, 14)
    local eBtnStroke = Instance.new("UIStroke", editBtn)
    eBtnStroke.Thickness = 1.8
    eBtnStroke.Color = isOwner and Color3.fromRGB(80, 180, 255) or Color3.fromRGB(45, 45, 60)
    eBtnStroke.Transparency = isOwner and 0 or 0.5

    local eIcon = Instance.new("ImageLabel", editBtn)
    eIcon.Size = UDim2.new(0, 28, 0, 28); eIcon.Position = UDim2.new(0, 14, 0.5, -14)
    eIcon.BackgroundTransparency = 1; eIcon.Image = ICONS.EDIT
    eIcon.ScaleType = Enum.ScaleType.Fit; eIcon.ZIndex = 73
    eIcon.ImageTransparency = isOwner and 0 or 0.6

    local eLbl = Instance.new("TextLabel", editBtn)
    eLbl.Size = UDim2.new(1, -60, 0, 20); eLbl.Position = UDim2.new(0, 52, 0, 8)
    eLbl.BackgroundTransparency = 1; eLbl.Text = "EDITAR PUBLICAÇÃO"
    eLbl.TextXAlignment = Enum.TextXAlignment.Left
    eLbl.TextColor3 = isOwner and Color3.fromRGB(140, 200, 255) or Color3.fromRGB(80, 80, 100)
    eLbl.Font = Enum.Font.GothamBold; eLbl.TextSize = 14; eLbl.ZIndex = 73

    local eSub = Instance.new("TextLabel", editBtn)
    eSub.Size = UDim2.new(1, -60, 0, 16); eSub.Position = UDim2.new(0, 52, 0, 30)
    eSub.BackgroundTransparency = 1
    eSub.Text = isOwner and "Alterações e exclusão" or "Somente o autor pode editar"
    eSub.TextXAlignment = Enum.TextXAlignment.Left
    eSub.TextColor3 = isOwner and Color3.fromRGB(100, 140, 200) or Color3.fromRGB(55, 55, 70)
    eSub.Font = Enum.Font.Gotham; eSub.TextSize = 11; eSub.ZIndex = 73

    if isOwner then
        local editHitbox = Instance.new("TextButton", editBtn)
        editHitbox.Size = UDim2.new(1,0,1,0); editHitbox.BackgroundTransparency = 1
        editHitbox.Text = ""; editHitbox.ZIndex = 74
        editHitbox.MouseEnter:Connect(function()
            TweenService:Create(editBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(18, 28, 55)}):Play()
        end)
        editHitbox.MouseLeave:Connect(function()
            TweenService:Create(editBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(20, 20, 38)}):Play()
        end)
        editHitbox.MouseButton1Click:Connect(function()
            closeMenu()
            task.wait(0.35)
            openEditMusicScreen(parent, musicData)
        end)
    end

    end) -- fim makeFloatingPanel (openMoreOptionsMenu)
end

-- ══════════════════════════════════════════════════════════════
-- 🔊 checkAudioStatus — verifica status de um ID de áudio.
--
--    Cache + Deduplicação:
--      • TMI._audioStatusCache[id] → resultado persistente da sessão
--      • TMI._audioCheckingSet[id] → lista de callbacks aguardando uma
--        verificação já em voo; evita requisições HTTP duplicadas para o
--        mesmo ID, mesmo com dezenas de chamadas simultâneas.
--
--    Prioridade: ao ser chamada do painel de 3 pontinhos (isPending),
--    esta função inicia a verificação imediatamente, antes do lote de
--    background. Se o lote já a iniciou, apenas enfileira o callback.
--
--    Passo 1: MarketplaceService:GetProductInfo → banido / excluído
--             Em caso de erro de rede/timeout → fallback Sound (evita
--             falsos-positivos "banned" por rate-limit).
--    Passo 2a (executor): game:HttpGet assetdelivery → privado / ok
--             Falha de HttpGet → fallback Sound (evita falso "private").
--    Passo 2b (fallback): instância Sound → privado / ok
--
--    callback(status): "ok" | "banned" | "private"
-- ══════════════════════════════════════════════════════════════
-- Inicializa tabela de verificações em voo (uma vez por sessão)
TMI._audioCheckingSet = TMI._audioCheckingSet or {}

local function checkAudioStatus(audioId, callback)
    local idStr = tostring(audioId or "")
    if idStr == "" or idStr == "0" then callback("banned") return end

    -- Cache hit → resposta imediata, zero requisição
    local cached = TMI._audioStatusCache[idStr]
    if cached then callback(cached) return end

    -- Verificação já em voo para este ID → apenas enfileira o callback
    if TMI._audioCheckingSet[idStr] then
        table.insert(TMI._audioCheckingSet[idStr], callback)
        return
    end

    -- Nova verificação: registra callback e inicia task
    TMI._audioCheckingSet[idStr] = {callback}

    task.spawn(function()
        local finalStatus

        local id = tonumber(idStr)
        if not id or id <= 0 then
            finalStatus = "banned"
        else
            -- ── PASSO 1: metadados (banido / excluído / moderado) ─────────────
            local ok, result = pcall(function()
                return MarketplaceService:GetProductInfo(id, Enum.InfoType.Asset)
            end)

            if not ok or not result or not result.AssetTypeId then
                -- Falha de rede / rate-limit: usa Sound como fallback antes de
                -- decretar "banned", evitando falsos-positivos por timeout.
                local sndFB = Instance.new("Sound")
                sndFB.SoundId = "rbxassetid://" .. tostring(id)
                sndFB.Volume  = 0
                sndFB.Parent  = workspace
                local eFB, lFB = 0, 1.5
                while not sndFB.IsLoaded and eFB < lFB do task.wait(0.05); eFB += 0.05 end
                local okFB = sndFB.IsLoaded and sndFB.TimeLength > 0
                sndFB:Destroy()
                finalStatus = okFB and "ok" or "banned"

            elseif result.AssetTypeId ~= 3 then
                -- Não é áudio (AssetTypeId 3)
                finalStatus = "banned"

            else
                local nameL = string.lower(tostring(result.Name or ""))
                if nameL == "[content deleted]" or nameL == "(removed)" then
                    finalStatus = "banned"
                else
                    -- ── PASSO 2: verifica privacidade ─────────────────────────
                    -- Prefere HttpGet (sem criar Sound, sem log 403 no console).
                    local hasHttpGet = false
                    pcall(function() hasHttpGet = (game.HttpGet ~= nil) end)

                    if hasHttpGet then
                        local hOk, resp = pcall(function()
                            return game:HttpGet(
                                "https://assetdelivery.roblox.com/v1/asset/?id=" .. tostring(id)
                            )
                        end)

                        if not hOk then
                            -- HttpGet falhou (executor sem acesso ao endpoint) →
                            -- usa Sound como fallback para não marcar como "private" errado
                            local SoundService = game:GetService("SoundService")
                            local snd = Instance.new("Sound")
                            snd.SoundId = "rbxassetid://" .. tostring(id)
                            snd.Volume  = 0
                            snd.Parent  = SoundService
                            local elapsed, limit = 0, 2.5
                            while not snd.IsLoaded and elapsed < limit do
                                task.wait(0.1); elapsed += 0.1
                            end
                            local loaded = snd.IsLoaded and snd.TimeLength > 0
                            snd:Destroy()
                            finalStatus = loaded and "ok" or "private"
                        else
                            local r = tostring(resp or "")
                            if r:find("not authorized", 1, true)
                                or r:find("Access Denied", 1, true)
                                or r:find("Unauthorized",  1, true) then
                                finalStatus = "private"
                            else
                                finalStatus = "ok"
                            end
                        end
                    else
                        -- Fallback puro: instância Sound (Studio / executors sem HttpGet)
                        local SoundService = game:GetService("SoundService")
                        local snd = Instance.new("Sound")
                        snd.SoundId = "rbxassetid://" .. tostring(id)
                        snd.Volume  = 0
                        snd.Parent  = SoundService
                        local elapsed, limit = 0, 2.5
                        while not snd.IsLoaded and elapsed < limit do
                            task.wait(0.1); elapsed += 0.1
                        end
                        local loaded = snd.IsLoaded and snd.TimeLength > 0
                        snd:Destroy()
                        finalStatus = loaded and "ok" or "private"
                    end
                end
            end
        end

        -- Salva no cache e dispara todos os callbacks enfileirados
        TMI._audioStatusCache[idStr] = finalStatus
        local cbs = TMI._audioCheckingSet[idStr] or {}
        TMI._audioCheckingSet[idStr] = nil   -- libera a entrada
        for _, cb in ipairs(cbs) do
            task.defer(cb, finalStatus)
        end
    end)
end

-- ══════════════════════════════════════════════════════════════
-- 🗄️ preloadAudioStatuses — pré-carrega o status de TODOS os IDs
--    em background, em lotes com pausa entre lotes.
--    Seguro para 500+ entradas; ignora IDs já em cache ou em voo.
--    BATCH reduzido para evitar rate-limit do MarketplaceService
--    (falsos "banned" causados por timeout de requisição).
--    Chamado por music_list.lua após loadFullCache concluir.
-- ══════════════════════════════════════════════════════════════
local function preloadAudioStatuses(idList)
    if type(idList) ~= "table" or #idList == 0 then return end

    task.spawn(function()
        local BATCH   = 15    -- simultâneos por lote (equilibra velocidade e precisão)
        local PAUSE   = 0.1   -- segundos de pausa entre lotes
        local TIMEOUT = 5.0   -- máximo de espera por lote

        -- Filtra apenas IDs ainda sem cache E sem verificação em voo
        local toCheck = {}
        for _, id in ipairs(idList) do
            local s = tostring(id or "")
            if s ~= "" and s ~= "0"
                and not TMI._audioStatusCache[s]
                and not TMI._audioCheckingSet[s] then
                table.insert(toCheck, s)
            end
        end

        local total = #toCheck
        if total == 0 then return end
        print(string.format("[TMI] Verificando status de %d áudios em background...", total))

        local i = 1
        while i <= total do
            local bEnd    = math.min(i + BATCH - 1, total)
            local waiting = bEnd - i + 1

            for j = i, bEnd do
                local s = toCheck[j]
                checkAudioStatus(s, function()
                    waiting = waiting - 1
                end)
            end

            -- Aguarda lote terminar (ou timeout)
            local t = 0
            while waiting > 0 and t < TIMEOUT do
                task.wait(0.1); t = t + 0.1
            end

            i = bEnd + 1
            if i <= total then task.wait(PAUSE) end
        end

        print(string.format("[TMI] ✓ Status de áudio pré-carregado (%d IDs verificados)", total))
    end)
end

-- Exportado para music_list.lua chamar após loadFullCache
TMI.preloadAudioStatuses = preloadAudioStatuses
-- Exportado para que outros módulos (profile.lua) possam adicionar o banner
TMI.addStatusBanner  = addStatusBanner
TMI.checkAudioStatus = checkAudioStatus

-- ══════════════════════════════════════════════════════════════
-- 🎗️ addStatusBanner — banner triangular no canto superior
--    esquerdo do card de música.
--    status: "banned" → vermelho  |  "private" → amarelo
--
--    Técnica: UIGradient Transparency diagonal (Rotation=45) num
--    Frame que fica 100% DENTRO do cardFrame (0..60 px nos dois eixos).
--    → Sem frame rotacionado, sem ClipsDescendants, sem vazamento
--      para fora do ScrollingFrame ao rolar a lista.
--    → ZIndex 25 garante exibição ACIMA do avatarFrame (ZIndex 20).
-- ══════════════════════════════════════════════════════════════
local BANNER_Z = 25

local function addStatusBanner(cardFrame, status)
    if status == "ok" then return end

    local bannerColor, iconId, infoTitle, infoDesc
    if status == "banned" then
        bannerColor = Color3.fromRGB(210, 45, 45)
        iconId      = ICONS.BANNED
        infoTitle   = "⛔  Áudio Indisponível"
        infoDesc    = "Este áudio foi banido, excluído ou nunca existiu no Roblox. O ID pode ser inválido ou o conteúdo foi removido pela moderação da plataforma."
    else -- "private"
        bannerColor = Color3.fromRGB(230, 185, 0)
        iconId      = ICONS.PRIVATE
        infoTitle   = "🔒  Áudio Privado"
        infoDesc    = "Este áudio está configurado como privado pelo autor. Apenas o criador original tem permissão para reproduzi-lo no Roblox."
    end

    -- ── Frame triangular via UIGradient ───────────────────────
    -- Fica totalmente dentro do cardFrame: dimensões 60×60 px.
    -- UIGradient Rotation=45 vai de cima-esq (pos 0, sólido) para
    -- baixo-dir (pos 1, transparente), simulando um triângulo de canto.
    local banner = Instance.new("Frame", cardFrame)
    banner.Name             = "StatusBannerClip"
    banner.Size             = UDim2.new(0, 60, 0, 60)
    banner.Position         = UDim2.new(0, 0, 0, 0)
    banner.BackgroundColor3 = bannerColor
    banner.BorderSizePixel  = 0
    banner.ZIndex           = BANNER_Z
    Instance.new("UICorner", banner).CornerRadius = UDim.new(0, 15)  -- espelha canto do card

    local grad = Instance.new("UIGradient", banner)
    grad.Rotation     = 45
    grad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0,    0),  -- canto sup-esq: totalmente opaco
        NumberSequenceKeypoint.new(0.48, 1),  -- ~48% da diagonal: transparente
        NumberSequenceKeypoint.new(1,    1),  -- canto inf-dir: transparente
    })

    -- ── Ícone via makeIcon na área sólida do triângulo ────────
    makeIcon(banner, iconId, UDim2.new(0, 22, 0, 22), UDim2.new(0, 5, 0, 5), BANNER_Z + 2)

    -- ── Hitbox de clique cobrindo o triângulo visível ─────────
    local iconBtn = Instance.new("TextButton", banner)
    iconBtn.Size                   = UDim2.new(0, 38, 0, 38)
    iconBtn.Position               = UDim2.new(0, 0, 0, 0)
    iconBtn.BackgroundTransparency = 1
    iconBtn.Text                   = ""
    iconBtn.ZIndex                 = BANNER_Z + 3
    iconBtn.AutoButtonColor        = false

    -- ── Painel explicativo ao clicar ──────────────────────────
    iconBtn.MouseButton1Click:Connect(function()
        local rootFrame = cardFrame:FindFirstAncestor("MainFrame")
        if not rootFrame then
            rootFrame = cardFrame
            local p = cardFrame.Parent
            while p do if p:IsA("Frame") then rootFrame = p end; p = p.Parent end
        end
        if not rootFrame then return end

        makeFloatingPanel(rootFrame, {
            zBase        = 60,
            panelSize    = UDim2.new(0.82, 0, 0, 230),
            panelPos     = UDim2.new(0.09, 0, 0.5, -115),
            cornerRadius = 18,
            rgbSpeed     = 1.2,
        }, function(panel, closePanel)
            local _, closeBtn, _ = makePanelHeader(panel, infoTitle, 62)
            closeBtn.MouseButton1Click:Connect(closePanel)

            -- Círculo colorido de fundo
            local iconBg = Instance.new("Frame", panel)
            iconBg.Size                   = UDim2.new(0, 62, 0, 62)
            iconBg.Position               = UDim2.new(0.5, -31, 0, 56)
            iconBg.BackgroundColor3       = bannerColor
            iconBg.BackgroundTransparency = 0.80
            iconBg.BorderSizePixel        = 0
            iconBg.ZIndex                 = 62
            Instance.new("UICorner", iconBg).CornerRadius = UDim.new(1, 0)

            makeIcon(panel, iconId, UDim2.new(0, 52, 0, 52), UDim2.new(0.5, -26, 0, 61), 63)

            local descLbl = Instance.new("TextLabel", panel)
            descLbl.Size                   = UDim2.new(1, -28, 0, 90)
            descLbl.Position               = UDim2.new(0, 14, 0, 128)
            descLbl.BackgroundTransparency = 1
            descLbl.Text                   = infoDesc
            descLbl.TextColor3             = Color3.fromRGB(185, 175, 215)
            descLbl.Font                   = Enum.Font.Gotham
            descLbl.TextSize               = 13
            descLbl.TextWrapped            = true
            descLbl.TextXAlignment         = Enum.TextXAlignment.Center
            descLbl.ZIndex                 = 63
        end)
    end)
end

-- ==========================================
-- 👤 MUSIC CARD
-- ==========================================
local GOLD1 = Color3.fromRGB(255, 200, 50)
local GOLD2 = Color3.fromRGB(200, 160, 40)

local function createMusicCard(parent, musicData, yPosition, openProfileFunc, onRemove)
    -- ── Verificação TOP1 ──────────────────────────────────────
    local isTop1 = TMI._cache.top1UserId ~= nil
        and tostring(musicData.UserId) == tostring(TMI._cache.top1UserId)

    local cardFrame = Instance.new("Frame")
	cardFrame.Name = "MusicCard"
	cardFrame.Size = UDim2.new(1, -20, 0, 100)
	cardFrame.Position = UDim2.new(0, 10, 0, yPosition)
	cardFrame.BackgroundColor3 = isTop1
        and Color3.fromRGB(30, 22, 5)
        or  Color3.fromRGB(25, 25, 35)
	cardFrame.BorderSizePixel = 0
	cardFrame.ZIndex = 20
	cardFrame.Parent = parent

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 15)
	cardCorner.Parent = cardFrame

    -- ── Borda dourada pulsante para TOP1 ─────────────────────
    if isTop1 then
        local goldStroke = Instance.new("UIStroke", cardFrame)
        goldStroke.Thickness = 2
        goldStroke.Color     = GOLD1
        -- pulso suave de transparência
        TweenService:Create(goldStroke,
            TweenInfo.new(1.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
            { Transparency = 0.55 }
        ):Play()
    end

	local avatarFrame = Instance.new("Frame")
	avatarFrame.Name = "AvatarFrame"
	avatarFrame.Size = UDim2.new(0, 70, 0, 70)
	avatarFrame.Position = UDim2.new(0, 15, 0, 15)
	avatarFrame.BackgroundColor3 = isTop1
        and GOLD2
        or  RGB_COLORS[math.random(1, #RGB_COLORS)]
	avatarFrame.BorderSizePixel = 0
	avatarFrame.ZIndex = 20
	avatarFrame.Parent = cardFrame

	Instance.new("UICorner", avatarFrame).CornerRadius = UDim.new(1, 0)
	
	local avatarImage = Instance.new("ImageLabel")
	avatarImage.Name = "AvatarImage"
	avatarImage.Size = UDim2.new(1, -4, 1, -4)
	avatarImage.Position = UDim2.new(0, 2, 0, 2)
	avatarImage.BackgroundTransparency = 1
	avatarImage.Image = normalizeImageUrl(musicData.Foto, musicData.UserId)
	avatarImage.ZIndex = 20
	avatarImage.Parent = avatarFrame
	Instance.new("UICorner", avatarImage).CornerRadius = UDim.new(1, 0)
    
    local profileBtn = Instance.new("TextButton")
    profileBtn.Name = "ProfileHitbox"
    profileBtn.Size = UDim2.new(1, 0, 1, 0)
    profileBtn.BackgroundTransparency = 1
    profileBtn.Text = ""
    profileBtn.ZIndex = 21
    profileBtn.Parent = avatarFrame

    if openProfileFunc then
        profileBtn.MouseButton1Click:Connect(function()
            openProfileFunc(musicData)
        end)
    end
	
	-- Linha de nome (ícone MUSIC_NOTE à esquerda + texto deslocado)
	local musicName = Instance.new("TextLabel")
	musicName.Name = "MusicName"
	musicName.Size = UDim2.new(0, 230, 0, 25)
	musicName.Position = UDim2.new(0, 120, 0, 15)
	musicName.BackgroundTransparency = 1
	musicName.Text = (musicData.Nome or "Nome não disponível")
	musicName.TextColor3 = Color3.fromRGB(255, 255, 255)
	musicName.TextSize = 16
	musicName.Font = Enum.Font.GothamBold
	musicName.TextXAlignment = Enum.TextXAlignment.Left
	musicName.TextTruncate = Enum.TextTruncate.AtEnd
	musicName.ZIndex = 20
	musicName.Parent = cardFrame
	makeIcon(cardFrame, ICONS.MUSIC_NOTE, UDim2.new(0, 14, 0, 14), UDim2.new(0, 103, 0, 20), 21)

	-- Linha de publicador (ícone IC_PLAYER à esquerda + texto deslocado)
	local publisherName = Instance.new("TextLabel")
	publisherName.Name = "PublisherName"
	publisherName.Size = UDim2.new(0, 232, 0, 20)
	publisherName.Position = UDim2.new(0, 118, 0, 57)
	publisherName.BackgroundTransparency = 1
	publisherName.Text = "Por: " .. (musicData.DisplayName or musicData.PlayerName or "Usuário")
	publisherName.TextColor3 = Color3.fromRGB(180, 180, 180)
	publisherName.TextSize = 14
	publisherName.Font = Enum.Font.Gotham
	publisherName.TextXAlignment = Enum.TextXAlignment.Left
	publisherName.ZIndex = 20
	publisherName.Parent = cardFrame
	makeIcon(cardFrame, ICONS.IC_PLAYER, UDim2.new(0, 14, 0, 14), UDim2.new(0, 101, 0, 62), 21)

	-- Linha de categoria (ícone IC_CATEGORY à esquerda + texto deslocado)
	local musicCategory = Instance.new("TextLabel")
	musicCategory.Name = "MusicCategory"
	musicCategory.Size = UDim2.new(0, 232, 0, 20)
	musicCategory.Position = UDim2.new(0, 118, 0, 40)
	musicCategory.BackgroundTransparency = 1
	musicCategory.Text = (musicData.Categoria or "Outros")
	musicCategory.TextColor3 = Color3.fromRGB(150, 150, 150)
	musicCategory.TextSize = 12
	musicCategory.Font = Enum.Font.Gotham
	musicCategory.TextXAlignment = Enum.TextXAlignment.Left
	musicCategory.ZIndex = 20
	musicCategory.Parent = cardFrame
	makeIcon(cardFrame, ICONS.IC_CATEGORY, UDim2.new(0, 13, 0, 13), UDim2.new(0, 102, 0, 44), 21)

	-- Badge de ID — frame auto-size: ícone fixo + texto ID sem sobreposição
	local idBadge = Instance.new("Frame")
	idBadge.Name = "MusicIdBadge"
	idBadge.AutomaticSize = Enum.AutomaticSize.X
	idBadge.Size = UDim2.new(0, 0, 0, 25)
	idBadge.Position = UDim2.new(1, -10, 0, 37)
	idBadge.AnchorPoint = Vector2.new(1, 0)
	idBadge.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	idBadge.BorderSizePixel = 0
	idBadge.ZIndex = 20
	idBadge.Parent = cardFrame
	Instance.new("UICorner", idBadge).CornerRadius = UDim.new(0, 8)
	local idBadgePad = Instance.new("UIPadding", idBadge)
	idBadgePad.PaddingLeft   = UDim.new(0, 4)
	idBadgePad.PaddingRight  = UDim.new(0, 6)
	idBadgePad.PaddingTop    = UDim.new(0, 0)
	idBadgePad.PaddingBottom = UDim.new(0, 0)
	local idBadgeList = Instance.new("UIListLayout", idBadge)
	idBadgeList.FillDirection = Enum.FillDirection.Horizontal
	idBadgeList.VerticalAlignment = Enum.VerticalAlignment.Center
	idBadgeList.SortOrder = Enum.SortOrder.LayoutOrder
	idBadgeList.Padding = UDim.new(0, 3)
	-- ícone IC_ID (sempre no início, LayoutOrder=1)
	local idIcon = Instance.new("ImageLabel", idBadge)
	idIcon.LayoutOrder = 1
	idIcon.Size = UDim2.new(0, 14, 0, 14)
	idIcon.BackgroundTransparency = 1
	idIcon.Image = ICONS.IC_ID
	idIcon.ScaleType = Enum.ScaleType.Fit
	idIcon.ZIndex = 21
	-- texto do ID (sempre depois do ícone, LayoutOrder=2)
	local musicId = Instance.new("TextLabel", idBadge)
	musicId.Name = "MusicId"
	musicId.LayoutOrder = 2
	musicId.AutomaticSize = Enum.AutomaticSize.X
	musicId.Size = UDim2.new(0, 0, 1, 0)
	musicId.BackgroundTransparency = 1
	musicId.BorderSizePixel = 0
	musicId.Text = tostring(musicData.ID_Musica or "N/A")
	musicId.TextColor3 = Color3.fromRGB(255, 255, 255)
	musicId.TextSize = 14
	musicId.Font = Enum.Font.GothamBold
	musicId.ZIndex = 21
	
	-- [[ 🖼️ BOTÃO COPIAR (IMAGE VERSION) ]]
	local copyButton = Instance.new("ImageButton")
	copyButton.Name = "CopyButton"
	copyButton.Size = UDim2.new(0, 25, 0, 25) -- Ajustado para quadrado
	copyButton.Position = UDim2.new(1, -35, 0, 65)
	copyButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
	copyButton.BorderSizePixel = 0
	copyButton.Image = ICONS.COPY -- Ícone Copiar
	copyButton.ScaleType = Enum.ScaleType.Fit
	copyButton.ZIndex = 20
	copyButton.Parent = cardFrame
	copyButton.BackgroundTransparency = 1
	Instance.new("UICorner", copyButton).CornerRadius = UDim.new(0, 6)
	
	copyButton.MouseEnter:Connect(function()
		TweenService:Create(copyButton, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(70, 170, 255)}):Play()
	end)
	copyButton.MouseLeave:Connect(function()
		TweenService:Create(copyButton, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
	end)
	
	copyButton.MouseButton1Click:Connect(function()
		if setclipboard then
			setclipboard(tostring(musicData.ID_Musica))
			-- Estado: Sucesso
			copyButton.Image = ICONS.OK -- Ícone Concluído
			copyButton.ImageColor3 = Color3.fromRGB(50, 255, 100)
			wait(1.5)
			-- Estado: Normal
			copyButton.Image = ICONS.COPY -- Volta para Copiar
			copyButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
		else
			-- Estado: Erro
			copyButton.Image = ICONS.LOADING
			local _cpSpin = spinIcon(copyButton)
			wait(1.5)
			if _cpSpin then _cpSpin:Disconnect() end; copyButton.Rotation = 0
			copyButton.Image = ICONS.COPY
		end
	end)
	
	-- [[ 🗑️ BOTÃO REMOVER (Se callback fornecido) ]]
    if onRemove then
        local removeBtn = Instance.new("ImageButton")
        removeBtn.Name = "RemoveButton"
        removeBtn.Size = UDim2.new(0, 25, 0, 25)
        removeBtn.Position = UDim2.new(1, -70, 0, 65) -- Ajuste de posição
        removeBtn.BackgroundColor3 = Color3.fromRGB(140, 30, 30)
        removeBtn.BorderSizePixel = 0
        removeBtn.Image = ICONS.DELETE -- Ícone Excluir
        removeBtn.ScaleType = Enum.ScaleType.Fit
        removeBtn.ImageColor3 = Color3.new(1,1,1)
        removeBtn.ZIndex = 20
        removeBtn.BackgroundTransparency = 1
        removeBtn.Parent = cardFrame
        Instance.new("UICorner", removeBtn).CornerRadius = UDim.new(0, 6)
        
        local removeBtnStroke = Instance.new("UIStroke", removeBtn)
        removeBtnStroke.Color = Color3.fromRGB(200, 50, 50)
        removeBtnStroke.Thickness = 0
        
        removeBtn.MouseEnter:Connect(function()
            TweenService:Create(removeBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(180, 40, 40)}):Play()
        end)
        removeBtn.MouseLeave:Connect(function()
            TweenService:Create(removeBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(140, 30, 30)}):Play()
        end)
        
        removeBtn.MouseButton1Click:Connect(function()
            removeBtn.Image = ICONS.LOADING
            spinIcon(removeBtn) -- card destruído pelo onRemove, sem necessidade de disconnect
            removeBtn.Active = false
            onRemove(musicData, cardFrame, removeBtn)
        end)
    end
	
	-- [[ ⋰ BOTÃO MAIS OPÇÕES (3 pontinhos) ]]
    local moreBtn = Instance.new("ImageButton")
    moreBtn.Name = "MoreOptionsBtn"
    moreBtn.Size = UDim2.new(0, 25, 0, 25)
    local morePos = onRemove and -105 or -70
    moreBtn.Position = UDim2.new(1, morePos, 0, 65)
    moreBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    moreBtn.BorderSizePixel = 0
    moreBtn.Image = ICONS.MORE   -- ícone 3 pontinhos
    moreBtn.ScaleType = Enum.ScaleType.Fit
    moreBtn.ZIndex = 20
    moreBtn.BackgroundTransparency = 1
    moreBtn.Parent = cardFrame
    Instance.new("UICorner", moreBtn).CornerRadius = UDim.new(0, 6)
    local moreBtnStroke = Instance.new("UIStroke", moreBtn)
    moreBtnStroke.Color = Color3.fromRGB(100, 100, 140)
    moreBtnStroke.Thickness = 0

    moreBtn.MouseEnter:Connect(function()
        TweenService:Create(moreBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(65, 65, 85)}):Play()
    end)
    moreBtn.MouseLeave:Connect(function()
        TweenService:Create(moreBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(45, 45, 60)}):Play()
    end)
    moreBtn.MouseButton1Click:Connect(function()
        -- Sobe até o MainFrame para garantir que o overlay cubra a GUI inteira,
        -- independente de qual página (home ou músicas públicas) o card está.
        local rootFrame = cardFrame:FindFirstAncestor("MainFrame")
        if not rootFrame then
            -- Fallback: pega o Frame mais alto na hierarquia
            rootFrame = cardFrame
            local p = cardFrame.Parent
            while p do
                if p:IsA("Frame") then rootFrame = p end
                p = p.Parent
            end
        end
        if rootFrame then
            openMoreOptionsMenu(rootFrame, musicData)
        end
    end)
	
	local dateLabel = Instance.new("TextLabel")
	dateLabel.Name = "DateLabel"
	dateLabel.Size = UDim2.new(0, 110, 0, 15)
	dateLabel.Position = UDim2.new(0, 118, 0, 78)
	dateLabel.BackgroundTransparency = 1
	local dataBruta = musicData.Data or os.date("%d/%m/%Y")
	dateLabel.Text = string.sub(tostring(dataBruta), 1, 10)
	dateLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
	dateLabel.TextSize = 11
	dateLabel.Font = Enum.Font.Gotham
	dateLabel.ZIndex = 20
	dateLabel.Parent = cardFrame
	dateLabel.TextXAlignment = Enum.TextXAlignment.Left
	makeIcon(cardFrame, ICONS.IC_DATE, UDim2.new(0, 12, 0, 12), UDim2.new(0, 102, 0, 80), 21)
	
	-- [[ 👍 BOTÃO DE LIKE — canto inferior esquerdo do card ]]
	local likeBtn = Instance.new("ImageButton")
	likeBtn.Name = "LikeButton"
	likeBtn.Size = UDim2.new(0, 28, 0, 28)
	likeBtn.Position = UDim2.new(0, 8, 1, -34)
	likeBtn.BackgroundTransparency = 1
	likeBtn.BorderSizePixel = 0
	likeBtn.Image = ICONS.LIKE_OFF
	likeBtn.ScaleType = Enum.ScaleType.Fit
	likeBtn.ZIndex = 21
	likeBtn.Parent = cardFrame

	-- Contador de likes sobreposto ao centro do ícone
	local likeCountLbl = Instance.new("TextLabel")
	likeCountLbl.Name = "LikeCount"
	likeCountLbl.Size = UDim2.new(0, 28, 0, 28)  -- mesmo tamanho do ícone
	likeCountLbl.Position = UDim2.new(0, 8, 1, -34) -- mesmo position do ícone
	likeCountLbl.BackgroundTransparency = 1
	likeCountLbl.Text = "..."
	likeCountLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	likeCountLbl.Font = Enum.Font.GothamBold
	likeCountLbl.TextSize = 9
	likeCountLbl.TextXAlignment = Enum.TextXAlignment.Center
	likeCountLbl.TextYAlignment = Enum.TextYAlignment.Center
	likeCountLbl.ZIndex = 22  -- acima do ícone
	likeCountLbl.Parent = cardFrame

	local likeActive = false
	local likeLoading = false

	local function updateLikeUI(liked, count)
		likeActive = liked
		likeBtn.Image = liked and ICONS.LIKE_ON or ICONS.LIKE_OFF
		likeCountLbl.TextColor3 = liked and Color3.fromRGB(0,0,0) or Color3.fromRGB(255,255,255)
		likeCountLbl.Text = formatCount(count)
	end

	local musicIdStr = tostring(musicData.ID_Musica)
	checkPlayerLiked(musicIdStr, function(liked)
		fetchLikeCount(musicIdStr, function(count)
			if cardFrame and cardFrame.Parent then updateLikeUI(liked, count) end
		end)
	end)

	likeBtn.MouseButton1Click:Connect(function()
		if likeLoading then return end
		likeLoading = true
		if likeActive then
			removeLike(musicIdStr, function(ok)
				likeLoading = false
				if ok then fetchLikeCount(musicIdStr, function(ct) if cardFrame and cardFrame.Parent then updateLikeUI(false, ct) end end) end
			end)
		else
			giveLike(musicIdStr, function(ok)
				likeLoading = false
				if ok then fetchLikeCount(musicIdStr, function(ct) if cardFrame and cardFrame.Parent then updateLikeUI(true, ct) end end) end
			end)
		end
	end)

	-- ── Verificação de status do áudio (async) ───────────────
    -- O banner aparece após a verificação; não bloqueia a criação do card.
    local audioIdNum = tonumber(tostring(musicData.ID_Musica or ""))
    if audioIdNum and audioIdNum > 0 then
        checkAudioStatus(audioIdNum, function(status)
            if cardFrame and cardFrame.Parent then
                addStatusBanner(cardFrame, status)
            end
        end)
    end

	return cardFrame
end

-- 鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲═
-- 🎵 PLAYLIST UI FUNCTIONS
-- 鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲═

-- Verifica key de playlist via Firebase
-- createPlaylistKeyPanel: usa showKeySystem (reutilizável)
local function createPlaylistKeyPanel(parent, onSuccess, onCancel)
    showKeySystem(parent, PLAYLIST_SCRIPT_NAME, onSuccess, onCancel)
end



-- €€ DETALHE DA PLAYLIST (songs inside) €€
local function createPlaylistDetailView(profileScroll, playlist, isOwner, onBack, tabsBar)
    -- Dupla verificação: só é dono se o UserId bater
    local realIsOwner = isOwner and (tostring(playlist.OwnerId) == tostring(player.UserId))
    isOwner = realIsOwner

    -- Oculta a barra de abas e reseta o scroll para o topo
    if tabsBar then tabsBar.Visible = false end
    profileScroll.CanvasPosition = Vector2.new(0, 0)

    -- Limpa scroll atual por completo (inclusive bigAv, headerBg, etc.)
    for _, c in ipairs(profileScroll:GetChildren()) do
        c:Destroy()
    end

    -- Loading enquanto carrega músicas
    local loadingLabel = Instance.new("TextLabel", profileScroll)
    loadingLabel.Size = UDim2.new(1, -20, 0, 50)
    loadingLabel.Position = UDim2.new(0, 10, 0, 80)
    loadingLabel.BackgroundTransparency = 1
    loadingLabel.Text = "Carregando músicas..."
    loadingLabel.TextColor3 = Color3.fromRGB(150, 140, 180)
    loadingLabel.Font = Enum.Font.Gotham
    loadingLabel.TextSize = 14
    loadingLabel.ZIndex = 22
    local _llIco = makeIcon(loadingLabel, ICONS.LOADING, UDim2.new(0, 16, 0, 16), UDim2.new(0, 6, 0.5, -8), 23)
    spinIcon(_llIco) -- destruído junto com loadingLabel:Destroy()

    -- Garante que _cache.musicData está populado
    local function renderPlaylistContent()
        loadingLabel:Destroy()

        -- Header da playlist
        local headerFrame = Instance.new("Frame", profileScroll)
        headerFrame.Size = UDim2.new(1,-20,0,60)
        headerFrame.Position = UDim2.new(0,10,0,8)
        headerFrame.BackgroundColor3 = Color3.fromRGB(22,16,36)
        headerFrame.BorderSizePixel = 0; headerFrame.ZIndex = 22
        Instance.new("UICorner", headerFrame).CornerRadius = UDim.new(0,14)
        local hBorder = Instance.new("UIStroke", headerFrame)
        hBorder.Color = RGB_COLORS[3]; hBorder.Thickness = 1.5

        local backBtn = Instance.new("TextButton", headerFrame)
        backBtn.Size = UDim2.new(0,50,0,40); backBtn.Position = UDim2.new(0,8,0.5,-20)
        backBtn.BackgroundColor3 = Color3.fromRGB(50,35,75); backBtn.BorderSizePixel = 0
        backBtn.Text = ""; backBtn.TextColor3 = Color3.fromRGB(200,180,255)
        backBtn.Font = Enum.Font.GothamBold; backBtn.TextSize = 16; backBtn.ZIndex = 23
        Instance.new("UICorner", backBtn).CornerRadius = UDim.new(0,8)
        makeIcon(backBtn, ICONS.BACK, UDim2.new(0, 22, 0, 22), UDim2.new(0.5, -11, 0.5, -11), 24)
        backBtn.MouseButton1Click:Connect(function()
            if tabsBar then tabsBar.Visible = true end
            if onBack then onBack() end
        end)

        local plName = Instance.new("TextLabel", headerFrame)
        plName.Size = UDim2.new(1,-150,0,22); plName.Position = UDim2.new(0,70,0,12)
        plName.BackgroundTransparency = 1
        plName.Text = "🎵 " .. (playlist.PlaylistName or "Playlist")
        plName.TextColor3 = Color3.fromRGB(220,200,255); plName.Font = Enum.Font.GothamBold
        plName.TextSize = 15; plName.TextXAlignment = Enum.TextXAlignment.Left; plName.ZIndex = 23

        local songIds = playlist.Songs or {}
        local countLabel = Instance.new("TextLabel", headerFrame)
        countLabel.Size = UDim2.new(1,-150,0,18); countLabel.Position = UDim2.new(0,70,0,36)
        countLabel.BackgroundTransparency = 1
        countLabel.Text = #songIds .. (#songIds == 1 and " música" or " músicas")
        countLabel.TextColor3 = Color3.fromRGB(140,120,180); countLabel.Font = Enum.Font.Gotham
        countLabel.TextSize = 12; countLabel.TextXAlignment = Enum.TextXAlignment.Left; countLabel.ZIndex = 23

        local yPos = 80

        if #songIds == 0 then
            local empty = Instance.new("TextLabel", profileScroll)
            empty.Size = UDim2.new(1,-20,0,50); empty.Position = UDim2.new(0,10,0,yPos)
            empty.BackgroundTransparency = 1; empty.Text = "🎵 Nenhuma música nesta playlist ainda."
            empty.TextColor3 = Color3.fromRGB(120,120,150); empty.Font = Enum.Font.Gotham
            empty.TextSize = 14; empty.ZIndex = 22
            profileScroll.CanvasSize = UDim2.new(0,0,0,yPos+60)
            return
        end

        -- Monta lookup de músicas por ID
        local musicById = {}
        for _, m in ipairs(_cache.musicData) do
            musicById[tostring(m.ID_Musica)] = m
        end

        for _, songId in ipairs(songIds) do
            local music = musicById[tostring(songId)]
            
            -- Se não encontrou a música nos dados globais, cria objeto mínimo
            if not music then
                music = {
                    ID_Musica = songId,
                    Nome = "ID: " .. tostring(songId),
                    Categoria = "Desconhecida",
                    PlayerName = "Desconhecido",
                    DisplayName = "Desconhecido",
                    UserId = 0,
                    Foto = "",
                    Data = ""
                }
            end
            
            -- Callback de remoção (só para donos)
            local removeCallback = nil
            if isOwner then
                removeCallback = function(musicData, cardFrame, removeBtn)
                    -- Remove do cache local na hora (optimistic update)
                    for i, pl in ipairs(playerPlaylists) do
                        if pl.PlaylistId == playlist.PlaylistId then
                            local newSongs = {}
                            for _, s in ipairs(pl.Songs) do
                                if tostring(s) ~= tostring(musicData.ID_Musica) then
                                    table.insert(newSongs, s)
                                end
                            end
                            playerPlaylists[i].Songs = newSongs
                            playlist.Songs = newSongs
                        end
                    end
                    -- Atualiza contagem visualmente na hora
                    countLabel.Text = #playlist.Songs .. (#playlist.Songs == 1 and " música" or " músicas")
                    -- Anima remoção imediata
                    TweenService:Create(cardFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                        Size = UDim2.new(1, -20, 0, 0),
                        BackgroundTransparency = 1
                    }):Play()
                    task.delay(0.3, function()
                        if cardFrame and cardFrame.Parent then
                            cardFrame:Destroy()
                        end
                        -- Reorganiza posições
                        local yp = 80
                        for _, child in ipairs(profileScroll:GetChildren()) do
                            if child:IsA("Frame") and child.Name == "MusicCard" then
                                child.Position = UDim2.new(0, 10, 0, yp)
                                yp = yp + 108
                            end
                        end
                        profileScroll.CanvasSize = UDim2.new(0, 0, 0, yp + 20)
                        -- Se não sobrou nenhuma música, mostra label de vazio
                        if #playlist.Songs == 0 then
                            local empty = Instance.new("TextLabel", profileScroll)
                            empty.Size = UDim2.new(1,-20,0,50); empty.Position = UDim2.new(0,10,0,80)
                            empty.BackgroundTransparency = 1; empty.Text = "Nenhuma música nesta playlist ainda."
                            empty.TextColor3 = Color3.fromRGB(120,120,150); empty.Font = Enum.Font.Gotham
                            empty.TextSize = 14; empty.ZIndex = 22
                            profileScroll.CanvasSize = UDim2.new(0,0,0,140)
                        end
                    end)
                    -- Chama API em segundo plano
                    removeSongFromPlaylistAPI(playlist.PlaylistId, musicData.ID_Musica, function(ok, _)
                        -- Silencioso: já sumiu visualmente
                    end)
                end
            end
            
            -- Cria card usando a função padrão
            createMusicCard(profileScroll, music, yPos, nil, removeCallback)
            yPos = yPos + 108
        end

        profileScroll.CanvasSize = UDim2.new(0,0,0,yPos+20)
    end

    -- Verifica se precisa carregar dados
    if #_cache.musicData == 0 then
        fetchAllMusic(function(ok, data)
            if ok then
                renderPlaylistContent()
            else
                loadingLabel.Text = "❌ Erro ao carregar músicas."
                loadingLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            end
        end)
    else
        renderPlaylistContent()
    end
end

-- €€ MODAL: ADICIONAR MÚSICA À PLAYLIST €€
createAddToPlaylistModal = function(parent, musicData)
    -- Sobe na hierarquia para achar o mainFrame
    local target = parent
   -- Guard: garante que os globais sejam tabelas válidas.
   -- Cobre nil E o caso onde fetchPlaylists retornou ok=true, data=nil
   -- (fazendo playerPlaylists = nil na linha "if ok then playerPlaylists = data end").
   if type(playerPlaylists) ~= "table" then
       TMI.playerPlaylists = TMI.playerPlaylists or {}
       playerPlaylists = TMI.playerPlaylists
   end
   if playlistKeyUnlocked == nil then playlistKeyUnlocked = false end
    for _ = 1, 6 do
        if not target then break end
        if target.Name == "MainFrame" then break end
        target = target.Parent
    end
    if not target then return end

    local _closeModal_ref = {}
    local closeModal = function() if _closeModal_ref[1] then _closeModal_ref[1]() end end

    makeFloatingPanel(target, {
        zBase      = 55,
        panelSize  = UDim2.new(0.88, 0, 0, 320),
        panelPos   = UDim2.new(0.06, 0, 0.5, -160),
        overlayClose = true,
        cornerRadius = 18,
    }, function(panel, closePanelFn)
        _closeModal_ref[1] = closePanelFn
        local z = 56

        local _, closeBtn = makePanelHeader(panel, "➪ Adicionar à Playlist", z)
        closeBtn.MouseButton1Click:Connect(closePanelFn)

        local musicInfo = Instance.new("TextLabel", panel)
        musicInfo.Size = UDim2.new(1,-20,0,18); musicInfo.Position = UDim2.new(0,10,0,50)
        musicInfo.BackgroundTransparency = 1
        musicInfo.Text = "🎵 " .. (musicData.Nome or "ID: " .. tostring(musicData.ID_Musica))
        musicInfo.TextColor3 = Color3.fromRGB(180,170,220); musicInfo.Font = Enum.Font.Gotham
        musicInfo.TextSize = 13; musicInfo.TextTruncate = Enum.TextTruncate.AtEnd; musicInfo.ZIndex = z

        local plScroll = Instance.new("ScrollingFrame", panel)
        plScroll.Size = UDim2.new(1,-16,0,190); plScroll.Position = UDim2.new(0,8,0,74)
        plScroll.BackgroundTransparency = 1; plScroll.BorderSizePixel = 0
        plScroll.ScrollBarThickness = 5; plScroll.ScrollBarImageColor3 = RGB_COLORS[3]
        plScroll.CanvasSize = UDim2.new(0,0,0,0); plScroll.ZIndex = z

        local fbLabel = Instance.new("TextLabel", panel)
        fbLabel.Size = UDim2.new(1,-20,0,18); fbLabel.Position = UDim2.new(0,10,0,270)
        fbLabel.BackgroundTransparency = 1; fbLabel.Text = ""
        fbLabel.TextColor3 = Color3.fromRGB(100,220,100); fbLabel.Font = Enum.Font.Gotham
        fbLabel.TextSize = 12; fbLabel.ZIndex = z

    local function buildPlaylistRows()
        -- Segurança: nunca usa # num valor não-tabela
        if type(playerPlaylists) ~= "table" then playerPlaylists = TMI.playerPlaylists or {} end
        for _, c in ipairs(plScroll:GetChildren()) do
            if c:IsA("Frame") or c:IsA("TextButton") then c:Destroy() end
        end
        local yP = 4

        -- Botão criar nova playlist
        local newBtn = Instance.new("TextButton", plScroll)
        newBtn.Size = UDim2.new(1,-8,0,36); newBtn.Position = UDim2.new(0,4,0,yP)
        newBtn.BackgroundColor3 = Color3.fromRGB(40,25,65); newBtn.BorderSizePixel = 0
        newBtn.Text = "✨ Criar Nova Playlist"; newBtn.TextColor3 = Color3.fromRGB(180,150,255)
        newBtn.Font = Enum.Font.GothamBold; newBtn.TextSize = 13; newBtn.ZIndex = 58
        Instance.new("UICorner", newBtn).CornerRadius = UDim.new(0,10)
        local newBtnStroke = Instance.new("UIStroke", newBtn)
        newBtnStroke.Color = Color3.fromRGB(100,60,180); newBtnStroke.Thickness = 1.5
        yP = yP + 44

        newBtn.MouseButton1Click:Connect(function()
    closeModal()
    createNewPlaylistModal(target, function(name, imageUrl)
        createPlaylistKeyPanel(target, function()
            playlistKeyUnlocked = true
            createPlaylistAPI(name, imageUrl, function(ok, idOrErr)
                if ok then
                    local newPl = {
                        PlaylistId = idOrErr, PlaylistName = name,
                        OwnerId = tostring(player.UserId), OwnerName = player.Name,
                        Songs = {}, ImageUrl = imageUrl
                    }
                    table.insert(playerPlaylists, newPl)
                    playlistKeyUnlocked = false
                    addSongToPlaylistAPI(idOrErr, musicData.ID_Musica, function(added, _)
                        if added then
                            table.insert(playerPlaylists[#playerPlaylists].Songs, tostring(musicData.ID_Musica))
                        end
                    end)
                end
            end)
        end, nil)
    end)
end)

        if #playerPlaylists == 0 then
            local emptyLbl = Instance.new("TextLabel", plScroll)
            emptyLbl.Size = UDim2.new(1,-8,0,30); emptyLbl.Position = UDim2.new(0,4,0,yP)
            emptyLbl.BackgroundTransparency = 1; emptyLbl.Text = "Nenhuma playlist criada ainda."
            emptyLbl.TextColor3 = Color3.fromRGB(130,120,160); emptyLbl.Font = Enum.Font.Gotham
            emptyLbl.TextSize = 13; emptyLbl.ZIndex = 58
            yP = yP + 36
        else
            for _, pl in ipairs(playerPlaylists) do
                local row = Instance.new("Frame", plScroll)
                row.Size = UDim2.new(1,-8,0,44); row.Position = UDim2.new(0,4,0,yP)
                row.BackgroundColor3 = Color3.fromRGB(26,20,42); row.BorderSizePixel = 0; row.ZIndex = 58
                Instance.new("UICorner", row).CornerRadius = UDim.new(0,10)
                local rStroke = Instance.new("UIStroke", row)
                rStroke.Color = Color3.fromRGB(60,45,90); rStroke.Thickness = 1

                local plNameLbl = Instance.new("TextLabel", row)
                plNameLbl.Size = UDim2.new(1,-90,1,0); plNameLbl.Position = UDim2.new(0,10,0,0)
                plNameLbl.BackgroundTransparency = 1
                plNameLbl.Text = "🎵 " .. (pl.PlaylistName or "Playlist")
                plNameLbl.TextColor3 = Color3.fromRGB(210,200,255); plNameLbl.Font = Enum.Font.GothamBold
                plNameLbl.TextSize = 13; plNameLbl.TextXAlignment = Enum.TextXAlignment.Left
                plNameLbl.TextTruncate = Enum.TextTruncate.AtEnd; plNameLbl.ZIndex = 59

                local countLbl = Instance.new("TextLabel", row)
                countLbl.Size = UDim2.new(0,40,1,0); countLbl.Position = UDim2.new(1,-90,0,0)
                countLbl.BackgroundTransparency = 1
                countLbl.Text = #(pl.Songs or {}) .. " 🎵"
                countLbl.TextColor3 = Color3.fromRGB(130,120,170); countLbl.Font = Enum.Font.Gotham
                countLbl.TextSize = 12; countLbl.ZIndex = 59

                -- [[ 🖼️ BOTÃO ADICIONAR NA LISTA DE PLAYLITS (IMAGE VERSION) ]]
                local addBtn = Instance.new("ImageButton", row)
                addBtn.Size = UDim2.new(0, 32, 0, 32) -- Tamanho quadrado para ícone
                addBtn.Position = UDim2.new(1, -42, 0.5, -16)
                addBtn.BackgroundColor3 = Color3.fromRGB(60, 100, 200)
                addBtn.BorderSizePixel = 0
                addBtn.Image = ICONS.ADD -- Ícone Adicionar
                addBtn.ScaleType = Enum.ScaleType.Fit
                addBtn.ZIndex = 59
                Instance.new("UICorner", addBtn).CornerRadius = UDim.new(0, 8)

                local capturedPl = pl
                addBtn.MouseButton1Click:Connect(function()
                    if not addBtn.Active then return end
                    
                    -- Verificação local: Já está na playlist?
                    for _, s in ipairs(capturedPl.Songs) do
                        if tostring(s) == tostring(musicData.ID_Musica) then
                            -- Estado: Aviso (Já existe)
                            addBtn.Image = ICONS.WARN -- Ícone Erro/Aviso
                            addBtn.BackgroundColor3 = Color3.fromRGB(160, 120, 0)
                            fbLabel.Text = "⚠️ Já está na playlist!"
                            fbLabel.TextColor3 = Color3.fromRGB(255, 200, 80)
                            
                            task.delay(1.5, function()
                                addBtn.Image = ICONS.ADD
                                addBtn.BackgroundColor3 = Color3.fromRGB(60, 100, 200)
                            end)
                            return
                        end
                    end

                    -- Estado: Carregando (Início da API)
                    addBtn.Active = false
                    addBtn.Image = ICONS.LOADING
                    local _addSpin = spinIcon(addBtn)
                    addBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 140)
                    
                    addSongToPlaylistAPI(capturedPl.PlaylistId, musicData.ID_Musica, function(ok, msg)
                        if _addSpin then _addSpin:Disconnect() end; addBtn.Rotation = 0
                        if ok then
                            table.insert(capturedPl.Songs, tostring(musicData.ID_Musica))
                            
                            -- Atualiza contador no card do perfil se visível
                            local plCard = target:FindFirstChild("PlCard_" .. tostring(capturedPl.PlaylistId), true)
                            if plCard then
                                local countLbl = plCard:FindFirstChild("SongCountLbl")
                                if countLbl then
                                    local n = #capturedPl.Songs
                                    countLbl.Text = n .. (n == 1 and " música" or " músicas")
                                end
                            end

                            -- Estado: Sucesso
                            addBtn.Image = ICONS.OK -- Ícone Concluído
                            addBtn.BackgroundColor3 = Color3.fromRGB(40, 130, 60)
                            fbLabel.Text = "✨ Adicionado em \"" .. (capturedPl.PlaylistName or "") .. "\""
                            task.wait(2)
                            closeModal()
                        else
                            local errMsg = tostring(msg or "")
                            local jaEsta = errMsg:find("já está") or errMsg:find("already")
                            
                            -- Estado: Erro ou Já Existe (via API)
                            addBtn.Image = ICONS.WARN -- Ícone Erro/Aviso
                            addBtn.BackgroundColor3 = jaEsta and Color3.fromRGB(160, 120, 0) or Color3.fromRGB(150, 50, 50)
                            addBtn.Active = true
                            
                            fbLabel.Text = jaEsta and "⚠️ Já está na playlist!" or "❌ Erro ao adicionar."
                            fbLabel.TextColor3 = jaEsta and Color3.fromRGB(255, 200, 80) or Color3.fromRGB(255, 150, 80)
                            
                            task.delay(1.5, function()
                                addBtn.Image = ICONS.ADD
                                addBtn.BackgroundColor3 = Color3.fromRGB(60, 100, 200)
                            end)
                        end
                    end)
                end)
                yP = yP + 50
            end
        end
        plScroll.CanvasSize = UDim2.new(0,0,0,yP+8)
    end

    -- Carrega playlists do player
    local myId = tostring(player.UserId)
    if #playerPlaylists == 0 then
        plScroll.CanvasSize = UDim2.new(0,0,0,44)
        local loadLbl = Instance.new("TextLabel", plScroll)
        loadLbl.Size = UDim2.new(1,0,0,36); loadLbl.BackgroundTransparency = 1
        loadLbl.Text = "Carregando playlists..."; loadLbl.TextColor3 = Color3.fromRGB(150,140,180)
        loadLbl.Font = Enum.Font.Gotham; loadLbl.TextSize = 13; loadLbl.ZIndex = 58
        local _ldIco = makeIcon(loadLbl, ICONS.LOADING, UDim2.new(0, 16, 0, 16), UDim2.new(0, 6, 0.5, -8), 59)
        spinIcon(_ldIco) -- destruído junto com loadLbl:Destroy()
        fetchPlaylists(myId, function(ok, data)
            loadLbl:Destroy()
            -- Só atribui se data for de fato uma tabela (evita playerPlaylists = nil
            -- quando fetchPlaylists retorna ok=true mas data=nil por erro de parse)
            if ok and type(data) == "table" then
                playerPlaylists    = data
                TMI.playerPlaylists = data
            end
            buildPlaylistRows()
        end)
    else
        buildPlaylistRows()
    end

    end) -- fim makeFloatingPanel (createAddToPlaylistModal)
end

-- 鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲═
-- 🖼️ VALIDAÇÃO DE IMAGEM
-- 鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲═
local function validateImageId(imageId, onResult)
    task.spawn(function()
        if not imageId or imageId == "" then
            onResult(true, "", "")  -- Vazio é válido (opcional)
            return
        end
        
        -- Remove caracteres não numéricos
        local cleanId = imageId:match("%d+")
        if not cleanId then
            onResult(false, "", "ID deve conter apenas números")
            return
        end
        
        -- Validação oficial usando MarketplaceService
        local MarketplaceService = game:GetService("MarketplaceService")
        local success, assetInfo = pcall(function()
            return MarketplaceService:GetProductInfo(tonumber(cleanId), Enum.InfoType.Asset)
        end)
        
        if not success or not assetInfo then
            onResult(false, "", "ID não encontrado no Roblox")
            return
        end
        
        -- AssetTypeId para imagens:
        -- 1 = Image (antiga)
        -- 13 = Decal
        local isImage = (assetInfo.AssetTypeId == 1 or assetInfo.AssetTypeId == 13)
        
        if isImage then
            local imageUrl = "rbxassetid://" .. cleanId
            onResult(true, imageUrl, "")
        else
            local typeName = assetInfo.AssetTypeId == 3 and "Áudio" or 
                           assetInfo.AssetTypeId == 10 and "Modelo" or
                           assetInfo.AssetTypeId == 2 and "Mesh" or
                           "Tipo " .. tostring(assetInfo.AssetTypeId)
            onResult(false, "", "Este ID é " .. typeName .. ", não uma imagem")
        end
    end)
end

-- 鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲═
-- 🎵 MODAL REUTILIZÁVEL: CRIAR NOVA PLAYLIST
-- 鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲═
createNewPlaylistModal = function(parent, onConfirm)
    makeFloatingPanel(parent, {
        zBase        = 60,
        panelSize    = UDim2.new(0.9, 0, 0, 340),
        panelPos     = UDim2.new(0.05, 0, 0.5, -170),
        overlayClose = false,
    }, function(panel, closePanel)
    local z = 62

    local _, closeBtn = makePanelHeader(panel, "✨ Criar Nova Playlist", z)
    closeBtn.MouseButton1Click:Connect(closePanel)

    local nameLabel = Instance.new("TextLabel", panel)
    nameLabel.Size = UDim2.new(1,-24,0,20); nameLabel.Position = UDim2.new(0,12,0,58)
    nameLabel.BackgroundTransparency = 1; nameLabel.Text = "Nome da Playlist"
    nameLabel.TextColor3 = Color3.fromRGB(180,170,210); nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14; nameLabel.TextXAlignment = Enum.TextXAlignment.Left; nameLabel.ZIndex = 62

    local npInput = Instance.new("TextBox", panel)
    npInput.Size = UDim2.new(1,-24,0,42); npInput.Position = UDim2.new(0,12,0,82)
    npInput.BackgroundColor3 = Color3.fromRGB(28,24,42); npInput.BorderSizePixel = 0
    npInput.PlaceholderText = "Ex: Minhas Favoritas..."; npInput.Text = ""
    npInput.TextColor3 = Color3.fromRGB(255,255,255); npInput.Font = Enum.Font.Gotham
    npInput.TextSize = 15; npInput.ZIndex = 62; npInput.ClearTextOnFocus = false
    Instance.new("UICorner", npInput).CornerRadius = UDim.new(0,10)
    local nameInputStroke = Instance.new("UIStroke", npInput)
    nameInputStroke.Color = Color3.fromRGB(80,60,120); nameInputStroke.Thickness = 1.5

    local imgLabel = Instance.new("TextLabel", panel)
    imgLabel.Size = UDim2.new(1,-150,0,20); imgLabel.Position = UDim2.new(0,12,0,136)
    imgLabel.BackgroundTransparency = 1; imgLabel.Text = "ID da Imagem (Opcional)"
    imgLabel.TextColor3 = Color3.fromRGB(180,170,210); imgLabel.Font = Enum.Font.GothamBold
    imgLabel.TextSize = 14; imgLabel.TextXAlignment = Enum.TextXAlignment.Left; imgLabel.ZIndex = 62

    local imgInput = Instance.new("TextBox", panel)
    imgInput.Size = UDim2.new(1,-150,0,42); imgInput.Position = UDim2.new(0,12,0,160)
    imgInput.BackgroundColor3 = Color3.fromRGB(28,24,42); imgInput.BorderSizePixel = 0
    imgInput.PlaceholderText = "Ex: 123456789"; imgInput.Text = ""
    imgInput.TextColor3 = Color3.fromRGB(200,190,220); imgInput.Font = Enum.Font.Gotham
    imgInput.TextSize = 14; imgInput.ZIndex = 62; imgInput.ClearTextOnFocus = false
    Instance.new("UICorner", imgInput).CornerRadius = UDim.new(0,10)
    local imgInputStroke = Instance.new("UIStroke", imgInput)
    imgInputStroke.Color = Color3.fromRGB(80,60,120); imgInputStroke.Thickness = 1.5

    local previewContainer = Instance.new("Frame", panel)
    previewContainer.Size = UDim2.new(0,120,0,120); previewContainer.Position = UDim2.new(1,-132,0,136)
    previewContainer.BackgroundColor3 = Color3.fromRGB(22,18,36); previewContainer.BorderSizePixel = 0
    previewContainer.ZIndex = 62
    Instance.new("UICorner", previewContainer).CornerRadius = UDim.new(0,12)
    local previewStroke = Instance.new("UIStroke", previewContainer)
    previewStroke.Color = Color3.fromRGB(60,45,90); previewStroke.Thickness = 2

    local previewImg = Instance.new("ImageLabel", previewContainer)
    previewImg.Size = UDim2.new(1,-4,1,-4); previewImg.Position = UDim2.new(0,2,0,2)
    previewImg.BackgroundTransparency = 1; previewImg.Image = ""
    previewImg.ScaleType = Enum.ScaleType.Fit; previewImg.ZIndex = 63
    Instance.new("UICorner", previewImg).CornerRadius = UDim.new(0,10)

    local previewIcon = Instance.new("TextLabel", previewContainer)
    previewIcon.Size = UDim2.new(1,0,1,0); previewIcon.BackgroundTransparency = 1
    previewIcon.Text = "🎵"; previewIcon.TextSize = 48; previewIcon.ZIndex = 63
    previewIcon.TextColor3 = Color3.fromRGB(100,80,140)

    local previewStatus = Instance.new("TextLabel", panel)
    previewStatus.Size = UDim2.new(1,-24,0,16); previewStatus.Position = UDim2.new(0,12,0,210)
    previewStatus.BackgroundTransparency = 1; previewStatus.Text = ""
    previewStatus.TextColor3 = Color3.fromRGB(150,140,180); previewStatus.Font = Enum.Font.Gotham
    previewStatus.TextSize = 11; previewStatus.TextXAlignment = Enum.TextXAlignment.Left; previewStatus.ZIndex = 62

    local npFb = Instance.new("TextLabel", panel)
    npFb.Size = UDim2.new(1,-24,0,18); npFb.Position = UDim2.new(0,12,0,236)
    npFb.BackgroundTransparency = 1; npFb.Text = ""
    npFb.TextColor3 = Color3.fromRGB(255,120,120); npFb.Font = Enum.Font.GothamBold
    npFb.TextSize = 13; npFb.ZIndex = 62

    local cfBtn = Instance.new("TextButton", panel)
    cfBtn.Size = UDim2.new(0.52,-8,0,38); cfBtn.Position = UDim2.new(0,12,0,264)
    cfBtn.BackgroundColor3 = Color3.fromRGB(50,140,80); cfBtn.BorderSizePixel = 0
    cfBtn.Text = "✨ Criar"; cfBtn.TextColor3 = Color3.fromRGB(255,255,255)
    cfBtn.Font = Enum.Font.GothamBold; cfBtn.TextSize = 15; cfBtn.ZIndex = 62
    cfBtn.Active = false; cfBtn.BackgroundTransparency = 0.5
    Instance.new("UICorner", cfBtn).CornerRadius = UDim.new(0,10)

    local ccBtn = Instance.new("TextButton", panel)
    ccBtn.Size = UDim2.new(0.46,-8,0,38); ccBtn.Position = UDim2.new(0.53,0,0,264)
    ccBtn.BackgroundColor3 = Color3.fromRGB(55,35,70); ccBtn.BorderSizePixel = 0
    ccBtn.Text = "✨ Cancelar"; ccBtn.TextColor3 = Color3.fromRGB(200,180,220)
    ccBtn.Font = Enum.Font.GothamBold; ccBtn.TextSize = 15; ccBtn.ZIndex = 62
    Instance.new("UICorner", ccBtn).CornerRadius = UDim.new(0,10)

    ccBtn.MouseButton1Click:Connect(function() closePanel() end)

    local isValidating = false
    local currentImageUrl = ""
    local imageIsValid = true

    local function updateButtonState()
        local nameOk = npInput.Text:match("^%s*(.-)%s*$") ~= ""
        if nameOk and imageIsValid and not isValidating then
            cfBtn.Active = true; cfBtn.BackgroundTransparency = 0
            cfBtn.BackgroundColor3 = Color3.fromRGB(50,140,80)
        else
            cfBtn.Active = false; cfBtn.BackgroundTransparency = 0.5
            cfBtn.BackgroundColor3 = Color3.fromRGB(40,100,60)
        end
    end

    imgInput.FocusLost:Connect(function()
        local idText = imgInput.Text:match("^%s*(.-)%s*$")
        if idText == "" then
            previewImg.Image = ""; previewIcon.Visible = true
            previewStroke.Color = Color3.fromRGB(60,45,90)
            previewStatus.Text = "Nenhuma imagem (padrão: 🎵)"
            previewStatus.TextColor3 = Color3.fromRGB(130,120,170)
            currentImageUrl = ""; imageIsValid = true
            updateButtonState(); return
        end
        isValidating = true; imageIsValid = false
        updateButtonState()
        previewStatus.Text = "Validando ID..."
        previewStatus.TextColor3 = Color3.fromRGB(150,140,200)
        local _pvIco = makeIcon(previewStatus, ICONS.LOADING, UDim2.new(0, 16, 0, 16), UDim2.new(0, 6, 0.5, -8), 72)
        local _pvSpin = spinIcon(_pvIco)
        validateImageId(idText, function(valid, url, errMsg)
            isValidating = false
            _pvSpin:Disconnect(); _pvIco:Destroy()
            if valid then
                imageIsValid = true; currentImageUrl = url
                previewImg.Image = url; previewIcon.Visible = false
                previewStroke.Color = Color3.fromRGB(80,180,100)
                previewStatus.Text = "✨ Imagem válida"
                previewStatus.TextColor3 = Color3.fromRGB(100,220,120)
            else
                imageIsValid = false; currentImageUrl = ""
                previewImg.Image = ""; previewIcon.Visible = true
                previewStroke.Color = Color3.fromRGB(200,60,60)
                previewStatus.Text = "❌ " .. errMsg
                previewStatus.TextColor3 = Color3.fromRGB(255,100,100)
            end
            updateButtonState()
        end)
    end)

    imgInput:GetPropertyChangedSignal("Text"):Connect(function()
        if imgInput.Text ~= "" then imageIsValid = false; updateButtonState() end
    end)
    npInput:GetPropertyChangedSignal("Text"):Connect(updateButtonState)

    cfBtn.MouseButton1Click:Connect(function()
        if not cfBtn.Active then return end
        local name = npInput.Text:match("^%s*(.-)%s*$")
        if name == "" then npFb.Text = "⚠️ Digite um nome válido."; return end
        closePanel()
        onConfirm(name, currentImageUrl)
    end)

    end) -- fim makeFloatingPanel (createNewPlaylistModal)
end

-- ══════════════════════════════════════════════════════════════
-- 🔄 createInnerLoadingScreen — tela de carregamento DENTRO da GUI
--    Fundo TRANSPARENTE (igual a uma página de conteúdo): os elementos
--    ficam flutuando sobre o background escuro da própria GUI.
--    Retorna updateProgress(percent, status).
--    Ao chegar em 100%: fade-out dos elementos → Destroy → onLoadComplete.
-- ══════════════════════════════════════════════════════════════
local function createInnerLoadingScreen(parent, onLoadComplete)
    -- Container transparente — ocupa toda a GUI, sem fundo próprio
    local loadFrame = Instance.new("Frame", parent)
    loadFrame.Name                   = "InnerLoadingScreen"
    loadFrame.Size                   = UDim2.new(1, 0, 1, 0)
    loadFrame.Position               = UDim2.new(0, 0, 0, 0)
    loadFrame.BackgroundTransparency = 1          -- ← transparente como página de conteúdo
    loadFrame.BorderSizePixel        = 0
    loadFrame.ZIndex                 = 50

    -- ── Logo pulsante centralizada ────────────────────────────
    local iconFrame, iconBorder = createLogoWidget(
        loadFrame, 90, UDim2.new(0.5, -45, 0.14, 0), 51
    )

    -- Pulso do ícone
    spawn(function()
        while loadFrame.Parent do
            TweenService:Create(iconFrame, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Size = UDim2.new(0, 100, 0, 100), Position = UDim2.new(0.5, -50, 0.14, -5)
            }):Play()
            wait(1)
            TweenService:Create(iconFrame, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Size = UDim2.new(0, 90, 0, 90), Position = UDim2.new(0.5, -45, 0.14, 0)
            }):Play()
            wait(1)
        end
    end)

    -- Borda RGB do ícone
    spawn(function()
        local idx = 1
        while loadFrame.Parent do
            idx = idx % #RGB_COLORS + 1
            TweenService:Create(iconBorder, TweenInfo.new(1.2, Enum.EasingStyle.Sine), {Color = RGB_COLORS[idx]}):Play()
            wait(1.2)
        end
    end)

    -- ── Título ────────────────────────────────────────────────
    local title = Instance.new("TextLabel", loadFrame)
    title.Size                   = UDim2.new(1, -20, 0, 36)
    title.Position               = UDim2.new(0, 10, 0.44, 0)
    title.BackgroundTransparency = 1
    title.Text                   = "MUSIC ID PUBLISHER"
    title.TextColor3             = Color3.new(1, 1, 1)
    title.Font                   = Enum.Font.GothamBold
    title.TextSize               = 20
    title.ZIndex                 = 51
    local titleStroke = Instance.new("UIStroke", title)
    titleStroke.Thickness = 1.5
    titleStroke.Color     = RGB_COLORS[1]
    animRGB(titleStroke, "Color", 1.2)

    -- ── Versão ────────────────────────────────────────────────
    local versionLbl = Instance.new("TextLabel", loadFrame)
    versionLbl.Size                   = UDim2.new(1, -20, 0, 18)
    versionLbl.Position               = UDim2.new(0, 10, 0.565, 0)
    versionLbl.BackgroundTransparency = 1
    versionLbl.Text                   = "Versão " .. TMI.versao .. " — Enhanced Edition"
    versionLbl.TextColor3             = RGB_COLORS[2]
    versionLbl.Font                   = Enum.Font.Gotham
    versionLbl.TextSize               = 12
    versionLbl.ZIndex                 = 51

    -- ── Status de carregamento ────────────────────────────────
    local loadingText = Instance.new("TextLabel", loadFrame)
    loadingText.Size                   = UDim2.new(1, -20, 0, 20)
    loadingText.Position               = UDim2.new(0, 10, 0.665, 0)
    loadingText.BackgroundTransparency = 1
    loadingText.Text                   = "Inicializando..."
    loadingText.TextColor3             = Color3.fromRGB(170, 165, 210)
    loadingText.Font                   = Enum.Font.Gotham
    loadingText.TextSize               = 12
    loadingText.ZIndex                 = 51

    -- ── Barra de progresso (fundo) ────────────────────────────
    local progressBg = Instance.new("Frame", loadFrame)
    progressBg.Size             = UDim2.new(1, -60, 0, 8)
    progressBg.Position         = UDim2.new(0, 30, 0.77, 0)
    progressBg.BackgroundColor3 = Color3.fromRGB(30, 28, 48)
    progressBg.BorderSizePixel  = 0
    progressBg.ZIndex           = 51
    Instance.new("UICorner", progressBg).CornerRadius = UDim.new(1, 0)

    -- ── Barra de progresso (preenchimento) ────────────────────
    local progressBar = Instance.new("Frame", progressBg)
    progressBar.Size             = UDim2.new(0, 0, 1, 0)
    progressBar.BackgroundColor3 = RGB_COLORS[1]
    progressBar.BorderSizePixel  = 0
    progressBar.ZIndex           = 52
    Instance.new("UICorner", progressBar).CornerRadius = UDim.new(1, 0)

    local progressGradient = Instance.new("UIGradient", progressBar)
    progressGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,   RGB_COLORS[1]),
        ColorSequenceKeypoint.new(0.5, RGB_COLORS[2]),
        ColorSequenceKeypoint.new(1,   RGB_COLORS[3]),
    })

    -- Animação do gradiente da barra
    spawn(function()
        local offset = 0
        while progressBar.Parent do
            offset = (offset + 0.02) % 1
            progressGradient.Offset = Vector2.new(offset, 0)
            wait(0.03)
        end
    end)

    -- ── Percentual ────────────────────────────────────────────
    local percentText = Instance.new("TextLabel", loadFrame)
    percentText.Size                   = UDim2.new(1, -20, 0, 20)
    percentText.Position               = UDim2.new(0, 10, 0.845, 0)
    percentText.BackgroundTransparency = 1
    percentText.Text                   = "0%"
    percentText.TextColor3             = Color3.new(1, 1, 1)
    percentText.Font                   = Enum.Font.GothamBold
    percentText.TextSize               = 15
    percentText.ZIndex                 = 51

    -- ── Fade-out seguro: por tipo de objeto ───────────────────
    -- Separar Frame e ImageLabel evita o erro "no property ImageTransparency
    -- for object 'Frame'" que acontecia quando os dois eram tratados juntos.
    local function fadeOutAll()
        local tw = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        for _, obj in ipairs(loadFrame:GetDescendants()) do
            if obj:IsA("TextLabel") then
                TweenService:Create(obj, tw, { TextTransparency = 1 }):Play()
            elseif obj:IsA("ImageLabel") then
                -- ImageLabel tem BackgroundTransparency E ImageTransparency
                TweenService:Create(obj, tw, { ImageTransparency = 1, BackgroundTransparency = 1 }):Play()
            elseif obj:IsA("Frame") then
                -- Frame só tem BackgroundTransparency (sem ImageTransparency!)
                TweenService:Create(obj, tw, { BackgroundTransparency = 1 }):Play()
            elseif obj:IsA("UIStroke") then
                TweenService:Create(obj, tw, { Transparency = 1 }):Play()
            end
        end
    end

    -- ── updateProgress ────────────────────────────────────────
    local loadClosed = false
    local function updateProgress(percent, status)
        if not loadFrame or not loadFrame.Parent then return end
        percent = math.clamp(percent or 0, 0, 100)

        if loadingText.Parent then
            loadingText.Text = status or "Carregando..."
        end
        if percentText.Parent then
            percentText.Text = math.floor(percent) .. "%"
        end
        if progressBar.Parent then
            TweenService:Create(progressBar,
                TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { Size = UDim2.new(percent / 100, 0, 1, 0) }
            ):Play()
        end

        if percent >= 100 and not loadClosed then
            loadClosed = true
            task.delay(0.55, function()
                -- 1) Fade individual de cada tipo (sem erro de propriedade)
                fadeOutAll()
                -- 2) Aguarda o fade terminar e destrói o container
                task.wait(0.45)
                if loadFrame and loadFrame.Parent then
                    loadFrame:Destroy()
                end
                -- 3) Callback de conclusão
                if onLoadComplete then onLoadComplete() end
            end)
        end
    end

    return updateProgress
end

-- ── Exportar ──────────────────────────────────────────────────
TMI.createLogoWidget        = createLogoWidget
TMI.createSplashScreen      = createSplashScreen
TMI.showKeySystem           = showKeySystem
TMI.createKeyPanel          = createKeyPanel
-- TMI.createAudioPlayerScreen set by audio_player.lua
TMI.openEditMusicScreen     = openEditMusicScreen
TMI.openMoreOptionsMenu     = openMoreOptionsMenu
TMI.createMusicCard         = createMusicCard
TMI.createPlaylistDetailView = createPlaylistDetailView
TMI.createAddToPlaylistModal  = createAddToPlaylistModal
TMI.createNewPlaylistModal   = createNewPlaylistModal
TMI.createPlaylistKeyPanel   = createPlaylistKeyPanel
TMI.createInnerLoadingScreen = createInnerLoadingScreen

print("[TMI] ui_components.lua carregado ✓")
