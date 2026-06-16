const express = require('express');
const fs = require('fs');
const path = require('path');
const os = require('os');
const { exec } = require('youtube-dl-exec');
const ffmpegPath = require('ffmpeg-static');

const app = express();
app.use(express.json());
const port = process.env.PORT || 8080;

function print(message) {
    console.log(`${new Date().toLocaleString()} | ${message}`);
}

app.post('/yt/video', async (req, res) => {
    let rawId = req.query.videoId;
    if (!rawId) return res.sendStatus(404);
    
    // Limpa a URL de rastreadores
    let cleanId = rawId.split('?')[0].split('&')[0];
    let videoURL = 'https://youtu.be/' + cleanId;
    
    // Cria um diretório temporário dinâmico (compatível com Linux/Render e Android/Termux)
    let tempPath = path.join(os.tmpdir(), `${cleanId}_${Date.now()}.webm`);

    print(`Iniciando download blindado (yt-dlp): ${videoURL}`);

    try {
        // O yt-dlp baixa, usa o ffmpeg para juntar vídeo/áudio e salva o .webm perfeito no disco
        await exec(videoURL, {
            format: 'bestvideo[ext=webm][height<=720]+bestaudio[ext=webm]/best[ext=webm]/best',
            mergeOutputFormat: 'webm',
            output: tempPath,
            ffmpegLocation: ffmpegPath, // Força o uso do FFmpeg interno do projeto
            noWarnings: true
        });

        print(`Download e conversão concluídos! Enviando ${cleanId}.webm para o executor...`);
        
        // Envia o arquivo validado para o seu script no Delta
        res.sendFile(tempPath, (err) => {
            if (err) print(`Erro no envio: ${err.message}`);
            
            // Faxina automática: deleta o arquivo do servidor para não estourar o armazenamento
            if (fs.existsSync(tempPath)) {
                fs.unlinkSync(tempPath);
            }
        });

    } catch (err) {
        print(`Falha no yt-dlp: ${err.message}`);
        // Se der qualquer erro de IP ou conexão, retorna 500 (O seu script Lua já está protegido contra isso)
        res.sendStatus(500);
        
        if (fs.existsSync(tempPath)) fs.unlinkSync(tempPath);
    }
});

app.post('/yt/audio', async (req, res) => {
    let rawId = req.query.videoId;
    if (!rawId) return res.sendStatus(404);
    
    let cleanId = rawId.split('?')[0].split('&')[0];
    let videoURL = 'https://youtu.be/' + cleanId;
    let tempPath = path.join(os.tmpdir(), `${cleanId}_${Date.now()}.mp3`);

    print(`Baixando Áudio: ${videoURL}`);

    try {
        await exec(videoURL, {
            extractAudio: true,
            audioFormat: 'mp3',
            output: tempPath,
            ffmpegLocation: ffmpegPath,
            noWarnings: true
        });

        print(`Áudio pronto! Enviando ${cleanId}.mp3`);
        
        res.sendFile(tempPath, (err) => {
            if (fs.existsSync(tempPath)) fs.unlinkSync(tempPath);
        });

    } catch (err) {
        print(`Erro no áudio: ${err.message}`);
        res.sendStatus(500);
        if (fs.existsSync(tempPath)) fs.unlinkSync(tempPath);
    }
});

app.listen(port, () => {
    print(`Servidor blindado online na porta ${port} - Usando yt-dlp`);
});
