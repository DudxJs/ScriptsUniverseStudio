const childProcess = require('child_process');
const ffmpeg = require('ffmpeg-static');
const express = require('express');
// Usando a versão mantida e atualizada para não tomar block do YouTube
const ytdl = require('@distube/ytdl-core'); 

const app = express();
app.use(express.json());
const port = process.env.PORT || 8080;

function print(message) {
    console.log(`${new Date().toLocaleString()} | ${message}`);
}

function itagExists(info) {
    for (const index in info.formats) {
        switch (info.formats[index].itag) {
            case 247: return [247, 'copy']; // 720p
            case 244: return [244, 'copy']; // 480p
            case 243: return [243, 'copy']; // 360p
            case 242: return [242, 'copy']; // 240p
            case 278: return [278, 'copy']; // 144p
        }
    } 
    return ['highestvideo', 'libvpx-vp9'];
}

app.post('/yt/video', async (req, res) => {
    let rawId = req.query.videoId;
    if (!rawId) return res.sendStatus(404);
    
    // Limpa parâmetros extras do link (ex: remove o ?si=...)
    let cleanId = rawId.split('?')[0].split('&')[0];
    let videoURL = 'https://youtu.be/' + cleanId;
    
    let validURL = ytdl.validateURL(videoURL);

    if (validURL) {
        try { 
            let info = await ytdl.getInfo(videoURL);
            let [videoQuality, codec] = itagExists(info);
            print(`Baixando: ${videoURL} | Qualidade: ${videoQuality}`);
            
            let video = ytdl.downloadFromInfo(info, { quality: videoQuality });
            let audio = ytdl.downloadFromInfo(info, { quality: 'highestaudio' });
            
            let ffmpegProcess = childProcess.spawn(ffmpeg, ['-loglevel', 'quiet',
                '-i', 'pipe:0', '-i', 'pipe:1', '-map', '0:v', '-map', '1:a',
                '-metadata','duration=' + info.videoDetails.lengthSeconds,
                '-c:v', codec, '-f', 'webm', '-shortest', 'pipe:2'
            ]); 
            
            video.pipe(ffmpegProcess.stdio[0]);
            audio.pipe(ffmpegProcess.stdio[1]);
            ffmpegProcess.stdio[2].pipe(res)
            .on('finish', () => {
                print('Concluído: ' + videoURL);
            });
        } catch(err) { 
            res.sendStatus(500);
            print('ERRO WEBM : ' + err.message);
        }
    } else { 
        res.sendStatus(404); 
    }
});

// A rota de áudio adaptada com a mesma lógica de limpeza de link
app.post('/yt/audio', async (req, res) => {
    let rawId = req.query.videoId;
    if (!rawId) return res.sendStatus(404);
    
    let cleanId = rawId.split('?')[0].split('&')[0];
    let videoURL = 'https://youtu.be/' + cleanId;

    if (ytdl.validateURL(videoURL)) { 
        try { 
            print('Baixando áudio: ' + videoURL);
            let audio = ytdl(videoURL, { quality: 'highestaudio' });
            let ffmpegProcess = childProcess.spawn(ffmpeg, [
                '-loglevel','quiet', '-i', 'pipe:0',
                '-f', 'mp3', 'pipe:1'
            ]); 
            
            audio.pipe(ffmpegProcess.stdio[0]);
            ffmpegProcess.stdio[1].pipe(res)
            .on('finish', () => {
                print('Áudio concluído: ' + videoURL);
            });
        } catch(err) { 
            res.sendStatus(500);
            print('ERRO MP3 : ' + err.message);
        }
    } else { 
        res.sendStatus(404); 
    }
});

app.listen(port, () => {
    print(`Servidor rodando na porta ${port}`);
});
