const express = require('express');
const { exec } = require('child_process');
const path = require('path');
const fs = require('fs');
const cors = require('cors');

const app = express();
const PORT = 8080;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static(__dirname));

// Ana sayfa
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'emulator_viewer.html'));
});

// Ekran görüntüsü al
app.post('/api/screenshot', (req, res) => {
    const timestamp = Date.now();
    const filename = `screenshot_${timestamp}.png`;
    
    exec(`flutter screenshot --out ${filename}`, { cwd: __dirname }, (error, stdout, stderr) => {
        if (error) {
            console.error(`Hata: ${error.message}`);
            return res.status(500).json({ error: error.message });
        }
        
        if (stderr) {
            console.error(`stderr: ${stderr}`);
        }
        
        console.log(`stdout: ${stdout}`);
        
        // Dosya yolunu döndür
        res.json({
            success: true,
            filename: filename,
            path: `/${filename}`,
            timestamp: timestamp
        });
    });
});

// Uygulamayı başlat
app.post('/api/start-app', (req, res) => {
    exec('flutter run -d 2412DPC0AG', { cwd: __dirname }, (error, stdout, stderr) => {
        if (error) {
            return res.status(500).json({ error: error.message });
        }
        res.json({ success: true, message: 'Uygulama başlatılıyor...' });
    });
});

// Testleri çalıştır
app.post('/api/run-tests', (req, res) => {
    exec('flutter test integration_test/smoke_test.dart', { cwd: __dirname }, (error, stdout, stderr) => {
        if (error) {
            return res.status(500).json({ error: error.message, output: stdout });
        }
        res.json({ success: true, output: stdout });
    });
});

// Emülatör durumu
app.get('/api/status', (req, res) => {
    exec('flutter devices', (error, stdout, stderr) => {
        if (error) {
            return res.status(500).json({ error: error.message });
        }
        
        const devices = stdout.includes('2412DPC0AG');
        res.json({
            emulator: devices ? 'connected' : 'disconnected',
            deviceId: '2412DPC0AG',
            flutter: 'running'
        });
    });
});

app.listen(PORT, () => {
    console.log(`
╔══════════════════════════════════════════════════════════╗
║                                                          ║
║   🚀 Android Emulator Viewer Server                     ║
║                                                          ║
║   📱 Emülatör: 2412DPC0AG                               ║
║   🌐 URL: http://localhost:${PORT}                        ║
║   📊 Status: http://localhost:${PORT}/api/status          ║
║                                                          ║
║   Chrome'da şu adresi açın:                             ║
║   👉 http://localhost:${PORT}                            ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝
    `);
});
