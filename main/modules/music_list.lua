-- ══════════════════════════════════════════════════════════════
-- 🎵 music_list.lua — Publicação, lista de músicas, filtros
-- Depende de: config.lua, core.lua, api.lua, ui_components.lua, profile.lua
-- ══════════════════════════════════════════════════════════════

local TMI              = _G.TMI
local player           = TMI.player
local TweenService     = TMI.TweenService
local HttpService      = TMI.HttpService
local ICONS            = TMI.ICONS
local RGB_COLORS       = TMI.RGB_COLORS
local _cache           = TMI._cache
local _dirty           = TMI._dirty
local CATEGORIES_LIST  = TMI.CATEGORIES_LIST

local makeIcon            = TMI.makeIcon
local makeSwitch          = TMI.makeSwitch
local makeFloatingPanel   = TMI.makeFloatingPanel
local makePanelHeader     = TMI.makePanelHeader
local animRGB             = TMI.animRGB
local formatCount         = TMI.formatCount
local normalizeImageUrl   = TMI.normalizeImageUrl
local spinIcon            = TMI.spinIcon

local fetchLikeCount      = TMI.fetchLikeCount
local checkPlayerLiked    = TMI.checkPlayerLiked
local giveLike            = TMI.giveLike
local removeLike          = TMI.removeLike
local loadFullCache       = TMI.loadFullCache
local fetchPlaylists      = TMI.fetchPlaylists
local sbHeaders           = TMI.sbHeaders
local request             = TMI.request
local SUPABASE_URL        = TMI.SUPABASE_URL

local createMusicCard         = TMI.createMusicCard
local createAudioPlayerScreen = TMI.createAudioPlayerScreen
local openEditMusicScreen     = TMI.openEditMusicScreen
local openMoreOptionsMenu     = TMI.openMoreOptionsMenu
local showKeySystem           = TMI.showKeySystem
local createProfileView       = TMI.createProfileView
local updateLeaderboard       = TMI.updateLeaderboard
local createPlaylistDetailView = TMI.createPlaylistDetailView

    pTitle.BackgroundTransparency = 1; pTitle.Text = "💿 REVISÃO DE PUBLICAÇÃO"; pTitle.TextColor3 = Color3.fromRGB(255, 255, 255); pTitle.Font = Enum.Font.GothamBold; pTitle.TextSize = 18;
    pTitle.ZIndex = 51

    local infoContent = Instance.new("TextLabel", previewFrame)
    infoContent.Size = UDim2.new(0.9, 0, 0, 80);
    infoContent.Position = UDim2.new(0.05, 0, 0.15, 0); infoContent.BackgroundTransparency = 1; infoContent.Text = "<b>Arquivo:</b> " .. assetInfo.Name .. "\n<b>Autor:</b> " .. assetInfo.Creator.Name .. "\n<b>Status:</b> Verificado";
    infoContent.TextColor3 = Color3.fromRGB(220, 220, 220); infoContent.Font = Enum.Font.Gotham; infoContent.TextSize = 14; infoContent.RichText = true; infoContent.TextXAlignment = Enum.TextXAlignment.Left;
    infoContent.ZIndex = 51

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

local isPublishing = false 
local function publishMusic(nameBox, idBox, getCategoryFunc, feedbackLabel, publishButtonFrame, targetFrame, resetCategoryFunc)
    if isPublishing then return end 
    local nome_custom = nameBox.Text
    local id_text = idBox.Text:gsub("%D", "")
    local id = tonumber(id_text)
    local categoria = getCategoryFunc()
    
    if nome_custom == "" or id_text == "" or categoria == "" then
        feedbackLabel.Text = "⚠️ Atenção: Preencha todos os campos obrigatórios."
        feedbackLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
        return
    end

    local screenOverlay = createOverlay(targetFrame)
    local function fullCleanup()
        if screenOverlay then
            local fadeOut = TweenService:Create(screenOverlay, TweenInfo.new(0.4), {BackgroundTransparency = 1})
            fadeOut:Play()
            fadeOut.Completed:Connect(function() if screenOverlay then screenOverlay:Destroy() end screenOverlay = nil end)
        end
    end

    feedbackLabel.Text = "🔎 Sincronizando com o banco de dados..."
    feedbackLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    
    -- Verifica duplicata direto no Supabase (índice único em ID_Musica)
    local checkSuccess, checkResponse = pcall(function()
        return request({
            Url     = SUPABASE_URL .. "/rest/v1/musics?ID_Musica=eq." .. tostring(id) .. "&select=ID_Musica",
            Method  = "GET",
            Headers = sbHeaders({ ["Prefer"] = "count=exact" }),
        })
    end)
    if checkSuccess and checkResponse and checkResponse.Body then
        local pok, rows = pcall(function() return HttpService:JSONDecode(checkResponse.Body) end)
        if pok and type(rows) == "table" and #rows > 0 then
            feedbackLabel.Text = "⛔ Este áudio já está registrado no sistema global."
            feedbackLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            fullCleanup()
            return
        end
    end

    feedbackLabel.Text = "💿 Validando informações do arquivo..."
    local MarketplaceService = game:GetService("MarketplaceService")
    local successInfo, assetInfo = pcall(function() return MarketplaceService:GetProductInfo(id, Enum.InfoType.Asset) end)

    if not successInfo or not assetInfo or assetInfo.AssetTypeId ~= 3 then
        feedbackLabel.Text = "❌ Erro: Identificador inválido ou arquivo inexistente."
        feedbackLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        fullCleanup()
        return
    end

    local previewFrame = Instance.new("Frame")
    previewFrame.Name = "PreviewFrame"
    previewFrame.Size = UDim2.new(0, 0, 0, 0)
    previewFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    previewFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    previewFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    previewFrame.BorderSizePixel = 0
    previewFrame.ZIndex = 50
    previewFrame.ClipsDescendants = true
    previewFrame.Parent = targetFrame

    Instance.new("UICorner", previewFrame).CornerRadius = UDim.new(0, 12)
    local pStroke = Instance.new("UIStroke", previewFrame)
    pStroke.Thickness = 2
    spawn(function()
        local idx = 1
        while previewFrame and previewFrame.Parent do
            idx = idx % #RGB_COLORS + 1
            TweenService:Create(pStroke, TweenInfo.new(1.5), {Color = RGB_COLORS[idx]}):Play()
            task.wait(1.5)
        end
    end)

    local pTitle = Instance.new("TextLabel", previewFrame)
    pTitle.Size = UDim2.new(1, 0, 0, 45);
    pTitle.BackgroundTransparency = 1; pTitle.Text = "💿 REVISÃO DE PUBLICAÇÃO"; pTitle.TextColor3 = Color3.fromRGB(255, 255, 255); pTitle.Font = Enum.Font.GothamBold; pTitle.TextSize = 18;
    pTitle.ZIndex = 51

    local infoContent = Instance.new("TextLabel", previewFrame)
    infoContent.Size = UDim2.new(0.9, 0, 0, 80);
    infoContent.Position = UDim2.new(0.05, 0, 0.15, 0); infoContent.BackgroundTransparency = 1; infoContent.Text = "<b>Arquivo:</b> " .. assetInfo.Name .. "\n<b>Autor:</b> " .. assetInfo.Creator.Name .. "\n<b>Status:</b> Verificado";
    infoContent.TextColor3 = Color3.fromRGB(220, 220, 220); infoContent.Font = Enum.Font.Gotham; infoContent.TextSize = 14; infoContent.RichText = true; infoContent.TextXAlignment = Enum.TextXAlignment.Left;
    infoContent.ZIndex = 51

    local sound = Instance.new("Sound", previewFrame)
    sound.SoundId = "rbxassetid://" .. id
    local bgBar = Instance.new("Frame", previewFrame);
    bgBar.Size = UDim2.new(0.9, 0, 0, 4); bgBar.Position = UDim2.new(0.05, 0, 0.45, 0); bgBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50);
    bgBar.ZIndex = 51
    local fillBar = Instance.new("Frame", bgBar); fillBar.Size = UDim2.new(0, 0, 1, 0);
    fillBar.BackgroundColor3 = Color3.fromRGB(255, 0, 120); fillBar.ZIndex = 52
    local timeLabel = Instance.new("TextLabel", previewFrame);
    timeLabel.Size = UDim2.new(0.9, 0, 0, 20); timeLabel.Position = UDim2.new(0.05, 0, 0.48, 0); timeLabel.BackgroundTransparency = 1; timeLabel.Text = "00:00 / 00:00";
    timeLabel.TextColor3 = Color3.fromRGB(150, 150, 150); timeLabel.Font = Enum.Font.Code; timeLabel.TextSize = 12;
    timeLabel.ZIndex = 51

    local function createControlBtn(text, pos, size, color)
        local btn = Instance.new("TextButton", previewFrame)
        btn.Size = size;
        btn.Position = pos; btn.BackgroundColor3 = color; btn.Text = text; btn.TextColor3 = Color3.fromRGB(255, 255, 255); btn.Font = Enum.Font.GothamBold; btn.TextSize = 14;
        btn.ZIndex = 55
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        return btn
    end

    local backBtn = createControlBtn("-5s", UDim2.new(0.05, 0, 0.58, 0), UDim2.new(0.28, 0, 0, 35), Color3.fromRGB(40, 40, 50))
    local playBtn = createControlBtn("PLAY", UDim2.new(0.36, 0, 0.58, 0), UDim2.new(0.28, 0, 0, 35), Color3.fromRGB(60, 60, 80))
    local previewPlayIcon = makeIcon(playBtn, ICONS.PLAY, UDim2.new(0, 18, 0, 18), UDim2.new(0, 6, 0.5, -9), 56)
    local skipBtn = createControlBtn("+5s", UDim2.new(0.67, 0, 0.58, 0), UDim2.new(0.28, 0, 0, 35), Color3.fromRGB(40, 40, 50))
    local cancelBtn = createControlBtn("CANCELAR", UDim2.new(0.05, 0, 0.8, 0), UDim2.new(0.43, 0, 0, 45), Color3.fromRGB(120, 40, 40))
    local confirmBtn = createControlBtn("CONFIRMAR ENVIO", UDim2.new(0.52, 0, 0.8, 0), UDim2.new(0.43, 0, 0, 45), Color3.fromRGB(0, 150, 100))

    local function formatTime(s) return string.format("%02d:%02d", math.floor(s/60), s%60) end
    playBtn.MouseButton1Click:Connect(function() if sound.IsPlaying then sound:Pause(); playBtn.Text = "PLAY"; previewPlayIcon.Image = ICONS.PLAY else sound:Play();
    playBtn.Text = "PAUSE"; previewPlayIcon.Image = ICONS.PAUSE end end)
    backBtn.MouseButton1Click:Connect(function() sound.TimePosition = math.max(0, sound.TimePosition - 5) end)
    skipBtn.MouseButton1Click:Connect(function() sound.TimePosition = math.min(sound.TimeLength, sound.TimePosition + 5) end)

    spawn(function()
        while previewFrame and previewFrame.Parent do
            if sound.TimeLength > 0 then
                infoContent.Text = "<b>Arquivo:</b> " .. assetInfo.Name .. "\n<b>Autor:</b> " .. assetInfo.Creator.Name .. "\n<b>Duração:</b> " .. formatTime(sound.TimeLength)
                fillBar.Size = UDim2.new(sound.TimePosition / sound.TimeLength, 0, 1, 0)
                timeLabel.Text = formatTime(sound.TimePosition) .. " / " .. formatTime(sound.TimeLength)
            end
            task.wait(0.2)
        end
    end)

    TweenService:Create(previewFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0.9, 0, 0.7, 0)}):Play()
    cancelBtn.MouseButton1Click:Connect(function() sound:Stop();
    previewFrame:Destroy(); fullCleanup(); feedbackLabel.Text = "🚫 Operação cancelada pelo usuário." end)

    confirmBtn.MouseButton1Click:Connect(function()
        sound:Stop(); previewFrame:Destroy() 
        local function finishEverything()
            isPublishing = true
            feedbackLabel.Text = "🚀 Sincronizando dados com o servidor global..."
            
            local payload = {
                ID_Musica = tostring(id), Nome = nome_custom, Categoria = categoria, PlayerName = player.Name, DisplayName = player.DisplayName, UserId = tostring(player.UserId),
                Foto = "https://www.roblox.com/headshot-thumbnail/image?userId="..player.UserId.."&width=150&height=150&format=png", Data = os.date("%Y-%m-%d %H:%M:%S")
            }
            local s, res = pcall(function()
                return request({
                    Url     = SUPABASE_URL .. "/rest/v1/musics",
                    Method  = "POST",
                    Headers = sbHeaders(),
                    Body    = HttpService:JSONEncode(payload),
                })
            end)
            isPublishing = false
            fullCleanup()
            
            local st = res and tonumber(res.StatusCode) or 0
            if s and (st == 201 or st == 200 or st == 0) then
                feedbackLabel.Text = "✨ SUCESSO: Áudio publicado globalmente!"
                feedbackLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
                nameBox.Text = ""
                idBox.Text = ""
                _dirty.musicList   = true   -- força re-fetch na próxima abertura da aba músicas
                _dirty.leaderboard = true
                if resetCategoryFunc then resetCategoryFunc() end
            else
                feedbackLabel.Text = "✨ Processado: Registro enviado ao servidor."
                feedbackLabel.TextColor3 = Color3.fromRGB(200, 255, 200)
                nameBox.Text = ""
                idBox.Text = ""
                if resetCategoryFunc then resetCategoryFunc() end
            end
        end

        local function onCancelKey() fullCleanup();
        feedbackLabel.Text = "🚫 Autenticação não concluída." end
        local oldKey = targetFrame:FindFirstChild("KeySystemFrame")
        if oldKey then oldKey:Destroy() end
        showKeySystem(targetFrame, SCRIPT_NAME, finishEverything, onCancelKey)
    end)
end

local function showMusicListInGUI(musicListFrame, musicListScroll, mainScrollFrame)
    -- Anima perfeitamente da direita para a esquerda, igual às outras abas
    musicListFrame.Visible = true
    musicListFrame.Position = UDim2.new(1, 0, 0, 5)
    TweenService:Create(musicListFrame, TweenInfo.new(0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 5, 0, 5)}):Play()

    spawn(function()
        local colorIndex = 1
        while musicListFrame.Visible do
            colorIndex = colorIndex % #RGB_COLORS + 1
            TweenService:Create(musicListScroll, TweenInfo.new(2, Enum.EasingStyle.Sine), {ScrollBarImageColor3 = RGB_COLORS[colorIndex]}):Play()
            wait(2)
        end
    end)
end

-- ATUALIZAÇÃO v3.3: showMainContent agora aceita leaderboardScroll para forçar visibilidade correta
local function showMainContent(musicListFrame, mainScrollFrame, leaderboardScroll, resetTabFunc)
    musicListFrame.Visible = false
    
local function renderFilteredList(musicListScroll, filterText, isNewSearch, mainFrameForProfile)
    if isNewSearch then
        for _, child in ipairs(musicListScroll:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextButton") then child:Destroy() end
        end
        currentStartIndex = 1
        currentFilterText = filterText:lower()
    end

    local yPos = (currentStartIndex == 1) and 10 or (musicListScroll.CanvasSize.Y.Offset - 70)
    local count = 0
    local foundData = {}

    for _, musicData in ipairs(allMusicData) do
        local textToSearch = tostring(musicData[currentSearchType] or ""):lower()
        local textMatch = currentFilterText == "" or textToSearch:find(currentFilterText)

        local catMatch = true
        if #selectedCategories > 0 then
            catMatch = false
            local musicCat = tostring(musicData.Categoria or ""):lower()
            for _, cat in ipairs(selectedCategories) do
                if musicCat == cat:lower() then catMatch = true; break end
            end
        end

        if textMatch and catMatch then table.insert(foundData, musicData) end
    end

    -- allMusicData já vem do Supabase com order=Data.desc (mais novo primeiro).
    -- "newest" → mantém a ordem original (mais novo no topo)
    -- "oldest" → inverte (mais antigo no topo)
    -- "liked"  → ordena por número de curtidas (decrescente)
    if currentSortMode == "liked" then
        table.sort(foundData, function(a, b)
            local la = _cache.likesMap[tostring(a.ID_Musica)] or 0
            local lb = _cache.likesMap[tostring(b.ID_Musica)] or 0
            return la > lb
        end)
    elseif currentSortOrder == "oldest" then
        local rev = {}
        for i = #foundData, 1, -1 do table.insert(rev, foundData[i]) end
        foundData = rev
    end

    for i = currentStartIndex, #foundData do
        if count >= itemsPerBatch then break end
        createMusicCard(musicListScroll, foundData[i], yPos, function(userData)
            createProfileView(mainFrameForProfile, userData)
        end)
        yPos = yPos + 110
        count = count + 1
        currentStartIndex = i + 1
    end

    if currentStartIndex <= #foundData then
        local loadMoreBtn = Instance.new("TextButton")
        loadMoreBtn.Name = "LoadMoreButton"
        loadMoreBtn.Size = UDim2.new(1, -40, 0, 50)
        loadMoreBtn.Position = UDim2.new(0, 20, 0, yPos)
        loadMoreBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        loadMoreBtn.Text = "➡ CARREGAR MAIS (" .. (#foundData - currentStartIndex + 1) .. ")"
        loadMoreBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        loadMoreBtn.Font = Enum.Font.GothamBold
        loadMoreBtn.ZIndex = 20
        loadMoreBtn.Parent = musicListScroll
        Instance.new("UICorner", loadMoreBtn).CornerRadius = UDim.new(0, 10)
        loadMoreBtn.MouseButton1Click:Connect(function()
            loadMoreBtn:Destroy()
            renderFilteredList(musicListScroll, currentFilterText, false, mainFrameForProfile)
        end)
        yPos = yPos + 70
    end
    musicListScroll.CanvasSize = UDim2.new(0, 0, 0, yPos + 20)
end

-- 🎵 Overlay de carregamento de músicas — usa makeFloatingPanel para reutilizar código
local function createMusicLoadingOverlay(parent)
    local overlay, destroyOverlay
    makeFloatingPanel(parent, {
        zBase        = 50,
        panelSize    = UDim2.new(0, 220, 0, 200),
        panelPos     = UDim2.new(0.5, -110, 0.5, -100),
        cornerRadius = 20,
        overlayClose = false,
        gradient     = true,
        rgbSpeed     = 1,
    }, function(panel, closeFn)
        destroyOverlay = closeFn

        -- Anéis giratórios (dentro do panel, centralizados no topo)
        local function makeRing(sz, speed, dir, strokeColor, strokeAlpha)
            local ring = Instance.new("Frame", panel)
            ring.Size = UDim2.new(0, sz, 0, sz)
            -- Centro horizontal do panel; verticalmente no terço superior do card
            ring.Position = UDim2.new(0.5, -sz/2, 0, 18 + (90 - sz)/2)
            ring.BackgroundTransparency = 1
            ring.BorderSizePixel = 0
            ring.ZIndex = 52
            local st = Instance.new("UIStroke", ring)
            st.Thickness = 4; st.Color = strokeColor; st.Transparency = strokeAlpha
            Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)
            TweenService:Create(ring,
                TweenInfo.new(math.abs(speed), Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
                { Rotation = dir * 360 }
            ):Play()
            animRGB(st, "Color", 1)
            return ring
        end
        makeRing(80, 1.6,  1, RGB_COLORS[1], 0.3)
        makeRing(58, 1.1, -1, RGB_COLORS[3], 0.5)

        -- Ícone 🎵 pulsante
        local iconLabel = Instance.new("TextLabel", panel)
        iconLabel.Size = UDim2.new(1, 0, 0, 44)
        iconLabel.Position = UDim2.new(0, 0, 0, 18)
        iconLabel.BackgroundTransparency = 1
        iconLabel.Text = "🎵"; iconLabel.TextSize = 34
        iconLabel.Font = Enum.Font.GothamBold; iconLabel.ZIndex = 53
        iconLabel.TextXAlignment = Enum.TextXAlignment.Center
        task.spawn(function()
            while iconLabel.Parent do
                TweenService:Create(iconLabel, TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextSize=40}):Play()
                wait(0.7)
                TweenService:Create(iconLabel, TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextSize=34}):Play()
                wait(0.7)
            end
        end)

        -- Título
        local loadTitle = Instance.new("TextLabel", panel)
        loadTitle.Size = UDim2.new(1, -20, 0, 28)
        loadTitle.Position = UDim2.new(0, 10, 0, 110)
        loadTitle.BackgroundTransparency = 1
        loadTitle.Text = "CARREGANDO"; loadTitle.Font = Enum.Font.GothamBold
        loadTitle.TextSize = 18; loadTitle.TextColor3 = Color3.fromRGB(255,255,255)
        loadTitle.ZIndex = 53; loadTitle.TextXAlignment = Enum.TextXAlignment.Center
        animRGB(loadTitle, "TextColor3", 1)

        -- Barra indeterminada
        local barBg = Instance.new("Frame", panel)
        barBg.Size = UDim2.new(1, -24, 0, 6); barBg.Position = UDim2.new(0, 12, 0, 148)
        barBg.BackgroundColor3 = Color3.fromRGB(30,30,45); barBg.BorderSizePixel = 0
        barBg.ZIndex = 53; barBg.ClipsDescendants = true
        Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)
        local barFill = Instance.new("Frame", barBg)
        barFill.Size = UDim2.new(0.35,0,1,0); barFill.Position = UDim2.new(-0.35,0,0,0)
        barFill.BackgroundColor3 = RGB_COLORS[1]; barFill.BorderSizePixel = 0; barFill.ZIndex = 54
        Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)
        animRGB(barFill, "BackgroundColor3", 1)
        task.spawn(function()
            while barFill.Parent do
                TweenService:Create(barFill, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position=UDim2.new(1,0,0,0)}):Play()
                wait(0.9); barFill.Position = UDim2.new(-0.35,0,0,0)
            end
        end)

        -- Sub-texto rotativo
        local subText = Instance.new("TextLabel", panel)
        subText.Size = UDim2.new(1,-20,0,20); subText.Position = UDim2.new(0,10,0,163)
        subText.BackgroundTransparency = 1; subText.Text = "Sincronizando músicas"
        subText.TextColor3 = Color3.fromRGB(160,160,200); subText.Font = Enum.Font.Gotham
        subText.TextSize = 12; subText.ZIndex = 53; subText.TextXAlignment = Enum.TextXAlignment.Center
        local dotMsgs = {"Sincronizando músicas","Conectando ao servidor","Baixando IDs","Quase lá"}
        task.spawn(function()
            local mi = 1
            while subText.Parent do
                mi = mi % #dotMsgs + 1
                TweenService:Create(subText, TweenInfo.new(0.2), {TextTransparency=1}):Play(); wait(0.2)
                subText.Text = dotMsgs[mi]
                TweenService:Create(subText, TweenInfo.new(0.2), {TextTransparency=0}):Play(); wait(0.9)
            end
        end)

        overlay = panel.Parent  -- referência ao overlay externo
    end)

    -- destroyOverlay já é o closeFn do makeFloatingPanel
    return overlay, destroyOverlay
end

-- viewMusicList: abre a aba de músicas.
-- • Se cache está limpo (_dirty.musicList == false) → renderiza instantaneamente, sem loading.
-- • Se cache está dirty (nova música publicada, etc.)  → re-busca em background e re-renderiza.
-- • onProgress é usado APENAS pela splash screen na carga inicial.
local function viewMusicList(feedbackLabel, musicListFrame, musicListScroll, mainScrollFrame, listButtonFrame, targetFrame, leaderboardScroll, onProgress)
    local function report(pct, msg) if onProgress then onProgress(pct, msg) end end

    -- ── Renderiza direto do cache ─────────────────────────────
    local function renderFromCache()
        renderFilteredList(musicListScroll, "", true, targetFrame)
        if musicListFrame and mainScrollFrame then
            showMusicListInGUI(musicListFrame, musicListScroll, mainScrollFrame)
        end
        _dirty.musicList = false
        if feedbackLabel then
            feedbackLabel.Text = "Banco de dados atualizado!"
            feedbackLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        end
    end

    -- ── Carga inicial via splash (onProgress passado) ─────────
    if onProgress then
        if isFetching then return end
        isFetching = true
        loadFullCache(
            -- onProgress da splash: 10% – 88%
            function(pct, msg) report(math.min(pct, 88), msg) end,
            function(ok)
                isFetching = false
                if ok then
                    report(89, "Renderizando músicas...")
                    renderFromCache()
                    if leaderboardScroll then
                        -- leaderboard fará 89→99% via onProgress, e chama onComplete com 100%
                        updateLeaderboard(leaderboardScroll, targetFrame,
                            function() report(100, "Carregamento completo!") end,
                            function(pct, msg) report(89 + math.floor((pct - 90) / 10 * 11), msg) end)
                    else
                        report(100, "Carregamento completo!")
                    end
                else
                    report(100, "Falha na conexão.")
                    if feedbackLabel then
                        feedbackLabel.Text = "❌ Falha de conexão."
                        feedbackLabel.TextColor3 = Color3.fromRGB(255,100,100)
                    end
                end
            end)
        return
    end

    -- ── Abertura manual pelo usuário ──────────────────────────
    -- Cache limpo → abre instantaneamente
    if not _dirty.musicList and #_cache.musicData > 0 then
        renderFromCache()
        -- Atualiza leaderboard em background apenas se dirty
        if leaderboardScroll and _dirty.leaderboard then
            updateLeaderboard(leaderboardScroll, targetFrame)
        end
        return
    end

    -- Cache dirty → re-busca em background e re-renderiza ao terminar
    if isFetching then return end
    isFetching = true
    loadFullCache(nil, function(ok)
        isFetching = false
        if ok then
            renderFromCache()
            if leaderboardScroll then
                updateLeaderboard(leaderboardScroll, targetFrame)
            end
        else
            if feedbackLabel then
                feedbackLabel.Text = "❌ Falha de conexão."
                feedbackLabel.TextColor3 = Color3.fromRGB(255,100,100)
            end
        end
    end)
end

local function viewMusicList(feedbackLabel, musicListFrame, musicListScroll, mainScrollFrame, listButtonFrame, targetFrame, leaderboardScroll, onProgress)
    local function report(pct, msg) if onProgress then onProgress(pct, msg) end end

    -- ── Renderiza direto do cache ─────────────────────────────
    local function renderFromCache()
        renderFilteredList(musicListScroll, "", true, targetFrame)
        if musicListFrame and mainScrollFrame then
            showMusicListInGUI(musicListFrame, musicListScroll, mainScrollFrame)
        end
        _dirty.musicList = false
        if feedbackLabel then
            feedbackLabel.Text = "Banco de dados atualizado!"
            feedbackLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        end
    end

    -- ── Carga inicial via splash (onProgress passado) ─────────
    if onProgress then
        if isFetching then return end
        isFetching = true
        loadFullCache(
            -- onProgress da splash: 10% – 88%
            function(pct, msg) report(math.min(pct, 88), msg) end,
            function(ok)
                isFetching = false
                if ok then
                    report(89, "Renderizando músicas...")
                    renderFromCache()
                    if leaderboardScroll then
                        -- leaderboard fará 89→99% via onProgress, e chama onComplete com 100%
                        updateLeaderboard(leaderboardScroll, targetFrame,
                            function() report(100, "Carregamento completo!") end,
                            function(pct, msg) report(89 + math.floor((pct - 90) / 10 * 11), msg) end)
                    else
                        report(100, "Carregamento completo!")
                    end
                else
                    report(100, "Falha na conexão.")
                    if feedbackLabel then
                        feedbackLabel.Text = "❌ Falha de conexão."
                        feedbackLabel.TextColor3 = Color3.fromRGB(255,100,100)
                    end
                end
            end)
        return
    end

    -- ── Abertura manual pelo usuário ──────────────────────────
    -- Cache limpo → abre instantaneamente
    if not _dirty.musicList and #_cache.musicData > 0 then
        renderFromCache()
        -- Atualiza leaderboard em background apenas se dirty
        if leaderboardScroll and _dirty.leaderboard then
            updateLeaderboard(leaderboardScroll, targetFrame)
        end
        return
    end

    -- Cache dirty → re-busca em background e re-renderiza ao terminar
    if isFetching then return end
    isFetching = true
    loadFullCache(nil, function(ok)
        isFetching = false
        if ok then
            renderFromCache()
            if leaderboardScroll then
                updateLeaderboard(leaderboardScroll, targetFrame)
            end
        else
            if feedbackLabel then
                feedbackLabel.Text = "❌ Falha de conexão."
                feedbackLabel.TextColor3 = Color3.fromRGB(255,100,100)
            end
        end
    end)
end

local function createFilterPanel(musicListFrame, musicListScroll, mainFrame)
    local ALL_CATS = CATEGORIES_LIST  -- reutiliza a mesma lista de publicação/edição

    -- FilterOpenBtn agora é filho direto do musicListFrame (acima da barra de pesquisa)
    local filterOpenBtn = musicListFrame:FindFirstChild("FilterOpenBtn")
    local filterDot     = filterOpenBtn and filterOpenBtn:FindFirstChild("FilterDot")

    if not filterOpenBtn then
        warn("[createFilterPanel] FilterOpenBtn não encontrado no SearchFrame")
        return
    end

    -- ── Estado temp dos filtros ───────────────────────────────────
    local tempSort      = currentSortOrder
    local tempMostLiked = (currentSortMode == "liked")
    local tempCats      = {}
    local chipUpdaters  = {}

    local function refreshFilterDot()
        if filterDot then
            filterDot.Visible = (currentSortOrder ~= "newest")
                or (currentSortMode == "liked")
                or (#selectedCategories > 0)
        end
    end

    -- ── Abre o painel de filtro usando makeFloatingPanel (igual ao painel de edição, System, etc.) ──
    filterOpenBtn.MouseButton1Click:Connect(function()
        tempSort      = currentSortOrder
        tempMostLiked = (currentSortMode == "liked")
        tempCats      = {}
        for _, c in ipairs(selectedCategories) do tempCats[c] = true end

        makeFloatingPanel(musicListFrame, {
            zBase        = 30,
            panelSize    = UDim2.new(0.92, 0, 0, 340),
            panelPos     = UDim2.new(0.04, 0, 0.08, 0),
            cornerRadius = 18,
            overlayClose = true,
            gradient     = true,
        }, function(panel, closeFn)
            local z = 32

            -- ── Header padrão reutilizável (igual ao painel de edição) ──
            local hdrFrame, closeBtn, titleLbl = makePanelHeader(panel, "FILTROS", z)
            -- Ícone de funil: filho do header, separado do TextLabel
            local hdrIcon = makeIcon(hdrFrame, ICONS.FILTER, UDim2.new(0, 16, 0, 16),
                UDim2.new(0, 14, 0.5, -8), z + 3)
            -- Empurra o texto para não sobrepor o ícone
            titleLbl.Position = UDim2.new(0, 36, 0, 0)
            titleLbl.Size     = UDim2.new(1, -72, 1, 0)
            closeBtn.MouseButton1Click:Connect(closeFn)

            -- ── ScrollingFrame — conteúdo rolável (apenas vertical) ──
            local HEADER_H = 46
            local FOOTER_H = 48
            local scroll = Instance.new("ScrollingFrame", panel)
            scroll.Size  = UDim2.new(1, 0, 1, -(HEADER_H + FOOTER_H))
            scroll.Position = UDim2.new(0, 0, 0, HEADER_H)
            scroll.BackgroundTransparency = 1
            scroll.BorderSizePixel = 0
            scroll.ScrollBarThickness = 3
            scroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 120)
            scroll.ScrollingDirection = Enum.ScrollingDirection.Y
            scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
            scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
            scroll.ZIndex = z
            scroll.ClipsDescendants = true

            -- helper: linha separadora
            local function mkDivider(sy)
                local d = Instance.new("Frame", scroll)
                d.Size = UDim2.new(1, -24, 0, 1)
                d.Position = UDim2.new(0, 12, 0, sy)
                d.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
                d.BorderSizePixel = 0; d.ZIndex = z
                return sy + 12
            end

            -- helper: seção com barra colorida
            local function mkSectionRow(sy, label, accent)
                local bar = Instance.new("Frame", scroll)
                bar.Size = UDim2.new(0, 3, 0, 14); bar.Position = UDim2.new(0, 12, 0, sy + 2)
                bar.BackgroundColor3 = accent; bar.BorderSizePixel = 0; bar.ZIndex = z + 1
                Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
                local lbl = Instance.new("TextLabel", scroll)
                lbl.Size = UDim2.new(1, -80, 0, 18); lbl.Position = UDim2.new(0, 20, 0, sy)
                lbl.BackgroundTransparency = 1; lbl.Text = label
                lbl.TextColor3 = accent; lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 11
                lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = z + 1
                return sy + 22
            end

            -- helper: linha com label + switch
            local function mkSwitchRow(sy, label, accent, initVal, onToggleFn)
                local row = Instance.new("Frame", scroll)
                row.Size = UDim2.new(1, -20, 0, 36); row.Position = UDim2.new(0, 10, 0, sy)
                row.BackgroundColor3 = Color3.fromRGB(22, 20, 34); row.BorderSizePixel = 0
                row.ZIndex = z; Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

                local lbl = Instance.new("TextLabel", row)
                lbl.Size = UDim2.new(1, -60, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0)
                lbl.BackgroundTransparency = 1; lbl.Text = label
                lbl.TextColor3 = Color3.fromRGB(210, 215, 240)
                lbl.Font = Enum.Font.Gotham; lbl.TextSize = 13
                lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = z + 1

                local sw = makeSwitch(row, 0, 0, z + 1, accent)
                sw.track.Position = UDim2.new(1, -52, 0.5, -12)
                sw.setOn(initVal)

                sw.track.MouseButton1Click:Connect(function()
                    -- o makeSwitch já alterna via MouseButton1Click interno;
                    -- chama callback após leve delay para ler estado atualizado
                    task.defer(function() onToggleFn(sw.get()) end)
                end)
                return sy + 42
            end

            local sy = 10

            -- ════════════════════════════════════════
            -- SEÇÃO 1 — MAIS ANTIGO
            -- ════════════════════════════════════════
            sy = mkSectionRow(sy, "MAIS ANTIGO", Color3.fromRGB(90, 160, 255))
            sy = mkSwitchRow(sy, "Exibir do mais antigo ao mais novo",
                Color3.fromRGB(90, 160, 255), tempSort == "oldest",
                function(val) tempSort = val and "oldest" or "newest" end)

            sy = sy + 4
            sy = mkDivider(sy)

            -- ════════════════════════════════════════
            -- SEÇÃO 2 — CATEGORIAS
            -- ════════════════════════════════════════
            local syBeforeCat = sy
            sy = mkSectionRow(sy, "CATEGORIAS", Color3.fromRGB(130, 100, 255))

            -- botão Limpar alinhado à direita na mesma linha da seção
            local btnClear = Instance.new("TextButton", scroll)
            btnClear.Size = UDim2.new(0, 56, 0, 18)
            btnClear.Position = UDim2.new(1, -68, 0, syBeforeCat + 2)
            btnClear.BackgroundColor3 = Color3.fromRGB(50, 24, 24)
            btnClear.BorderSizePixel = 0
            btnClear.Text = "✕ Limpar"
            btnClear.TextColor3 = Color3.fromRGB(220, 80, 80)
            btnClear.Font = Enum.Font.GothamBold; btnClear.TextSize = 10
            btnClear.ZIndex = z + 2
            Instance.new("UICorner", btnClear).CornerRadius = UDim.new(0, 6)

            -- chips 3 colunas
            local chipH, chipGap, chipCols = 28, 6, 3
            chipUpdaters = {}
            for i, catName in ipairs(ALL_CATS) do
                local col  = (i - 1) % chipCols
                local row  = math.floor((i - 1) / chipCols)
                local cw   = 1 / chipCols

                local chip = Instance.new("TextButton", scroll)
                chip.Size = UDim2.new(cw, -10, 0, chipH)
                chip.Position = UDim2.new(col * cw, 10 + col * (-2), 0, sy + row * (chipH + chipGap))
                chip.BorderSizePixel = 0
                chip.Text = catName
                chip.Font = Enum.Font.GothamBold; chip.TextSize = 11
                chip.ZIndex = z + 1
                Instance.new("UICorner", chip).CornerRadius = UDim.new(0, 8)
                local cs = Instance.new("UIStroke", chip); cs.Thickness = 1.2

                local function updChip()
                    if tempCats[catName] then
                        chip.BackgroundColor3 = Color3.fromRGB(55, 90, 220)
                        chip.TextColor3       = Color3.fromRGB(255, 255, 255)
                        cs.Color              = Color3.fromRGB(120, 160, 255)
                    else
                        chip.BackgroundColor3 = Color3.fromRGB(22, 20, 34)
                        chip.TextColor3       = Color3.fromRGB(130, 130, 165)
                        cs.Color              = Color3.fromRGB(45, 45, 70)
                    end
                end
                updChip()
                chip.MouseButton1Click:Connect(function()
                    tempCats[catName] = not tempCats[catName] or nil
                    updChip()
                end)
                table.insert(chipUpdaters, updChip)
            end

            local numRows = math.ceil(#ALL_CATS / chipCols)
            sy = sy + numRows * (chipH + chipGap) + 6

            btnClear.MouseButton1Click:Connect(function()
                tempCats = {}
                for _, upd in ipairs(chipUpdaters) do upd() end
            end)

            sy = mkDivider(sy)

            -- ════════════════════════════════════════
            -- SEÇÃO 3 — MAIS CURTIDAS
            -- ════════════════════════════════════════
            sy = mkSectionRow(sy, "MAIS CURTIDAS", Color3.fromRGB(255, 90, 120))
            sy = mkSwitchRow(sy, "Ordenar por músicas mais curtidas",
                Color3.fromRGB(255, 90, 120), tempMostLiked,
                function(val) tempMostLiked = val end)

            sy = sy + 8  -- padding final

            -- ── Footer fixo — botão APLICAR ─────────────────────────
            local footerLine = Instance.new("Frame", panel)
            footerLine.Size = UDim2.new(1, 0, 0, 1)
            footerLine.Position = UDim2.new(0, 0, 1, -FOOTER_H)
            footerLine.BackgroundColor3 = Color3.fromRGB(50, 50, 72)
            footerLine.BorderSizePixel = 0; footerLine.ZIndex = z + 2

            local applyBtn = Instance.new("TextButton", panel)
            applyBtn.Size = UDim2.new(1, -20, 0, 34)
            applyBtn.Position = UDim2.new(0, 10, 1, -(FOOTER_H - 7))
            applyBtn.BackgroundColor3 = Color3.fromRGB(45, 185, 100)
            applyBtn.BorderSizePixel = 0
            applyBtn.Text = "✔  APLICAR"
            applyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            applyBtn.Font = Enum.Font.GothamBold; applyBtn.TextSize = 14
            applyBtn.ZIndex = z + 3
            Instance.new("UICorner", applyBtn).CornerRadius = UDim.new(0, 12)

            applyBtn.MouseButton1Click:Connect(function()
                currentSortOrder = tempSort
                currentSortMode  = tempMostLiked and "liked" or "date"
                selectedCategories = {}
                for cat, v in pairs(tempCats) do
                    if v then table.insert(selectedCategories, cat) end
                end
                refreshFilterDot()
                closeFn()
                task.wait(0.25)
                renderFilteredList(musicListScroll, currentFilterText, true, mainFrame)
            end)
        end)
    end)

    refreshFilterDot()
end


-- ── Exportar ──────────────────────────────────────────────────
TMI.viewMusicList      = viewMusicList
TMI.renderFilteredList = renderFilteredList
TMI.createFilterPanel  = createFilterPanel
TMI.publishMusic       = publishMusic

print("[TMI] music_list.lua carregado ✓")
