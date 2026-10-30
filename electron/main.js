const { app, BrowserWindow, ipcMain, shell } = require('electron');
const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');
const Store = require('electron-store');

const store = new Store({
  defaults: {
    apiProvider: 'anthropic',
    customApiBase: '',
    apiKey: '',
    proxy: {
      enabled: false,
      url: 'http://127.0.0.1:7890'
    },
    defaults: {
      model: 'claude-opus-5-5',
      effort: 'medium'
    },
    subscriptionCache: {
      enabled: true,
      ttl: 300
    }
  }
});

let mainWindow;
let claudeProcess;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1000,
    height: 700,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      nodeIntegration: false,
      contextIsolation: true
    },
    icon: path.join(__dirname, '../resources/icons/icon.png')
  });

  mainWindow.loadFile(path.join(__dirname, 'index.html'));

  // Open DevTools in development
  if (process.env.NODE_ENV === 'development') {
    mainWindow.webContents.openDevTools();
  }

  mainWindow.on('closed', () => {
    mainWindow = null;
  });
}

app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', () => {
  if (mainWindow === null) {
    createWindow();
  }
});

// ============================================================================
// IPC Handlers
// ============================================================================

// Get configuration
ipcMain.handle('get-config', () => {
  return store.store;
});

// Save configuration
ipcMain.handle('save-config', (event, config) => {
  store.set(config);
  return { success: true };
});

// Launch Claude Code
ipcMain.handle('launch-claude', async (event, args) => {
  const config = store.store;

  // Determine script path
  const isPackaged = app.isPackaged;
  const scriptName = process.platform === 'win32' ? 'cc.ps1' : 'cc.sh';
  const scriptPath = isPackaged
    ? path.join(process.resourcesPath, 'scripts', scriptName)
    : path.join(__dirname, '../scripts', scriptName);

  // Build command
  let command, commandArgs;

  if (process.platform === 'win32') {
    // Windows: PowerShell
    command = 'powershell.exe';
    commandArgs = [
      '-NoProfile',
      '-ExecutionPolicy', 'Bypass',
      '-File', scriptPath,
      ...args
    ];
  } else {
    // macOS/Linux: bash
    command = scriptPath;
    commandArgs = args;
  }

  // Set environment variables
  const env = { ...process.env };

  if (config.proxy.enabled) {
    env.HTTPS_PROXY = config.proxy.url;
    env.HTTP_PROXY = config.proxy.url;
  }

  if (config.apiProvider !== 'anthropic') {
    env.ANTHROPIC_BASE_URL = config.customApiBase;
    env.ANTHROPIC_AUTH_TOKEN = config.apiKey;
  }

  // Spawn Claude Code process
  return new Promise((resolve, reject) => {
    claudeProcess = spawn(command, commandArgs, {
      env,
      shell: true,
      stdio: 'inherit'
    });

    claudeProcess.on('exit', (code) => {
      resolve({ exitCode: code });
    });

    claudeProcess.on('error', (err) => {
      reject({ error: err.message });
    });
  });
});

// Test proxy connection
ipcMain.handle('test-proxy', async (event, proxyUrl) => {
  const { exec } = require('child_process');

  return new Promise((resolve) => {
    const testCommand = process.platform === 'win32'
      ? `powershell -Command "Test-NetConnection -ComputerName ${new URL(proxyUrl).hostname} -Port ${new URL(proxyUrl).port} -InformationLevel Quiet"`
      : `nc -z -w2 ${new URL(proxyUrl).hostname} ${new URL(proxyUrl).port}`;

    exec(testCommand, (error, stdout) => {
      resolve({ success: !error });
    });
  });
});

// Test API connection
ipcMain.handle('test-api', async (event, apiBase, apiKey) => {
  const https = require('https');
  const http = require('http');

  return new Promise((resolve) => {
    const url = new URL('/v1/messages', apiBase);
    const protocol = url.protocol === 'https:' ? https : http;

    const options = {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'anthropic-version': '2023-06-01',
        'x-api-key': apiKey
      }
    };

    const req = protocol.request(url, options, (res) => {
      resolve({ success: res.statusCode < 500 });
    });

    req.on('error', () => {
      resolve({ success: false });
    });

    req.end();
  });
});

// Get Claude Code version
ipcMain.handle('get-claude-version', async () => {
  const { exec } = require('child_process');

  return new Promise((resolve) => {
    exec('claude --version', (error, stdout) => {
      if (error) {
        resolve({ version: 'Not installed' });
      } else {
        resolve({ version: stdout.trim() });
      }
    });
  });
});

// Open external link
ipcMain.handle('open-external', async (event, url) => {
  await shell.openExternal(url);
});

// Export config
ipcMain.handle('export-config', async () => {
  const { dialog } = require('electron');

  const result = await dialog.showSaveDialog(mainWindow, {
    title: 'Export Configuration',
    defaultPath: 'claude-launcher-config.json',
    filters: [{ name: 'JSON', extensions: ['json'] }]
  });

  if (!result.canceled) {
    fs.writeFileSync(result.filePath, JSON.stringify(store.store, null, 2));
    return { success: true };
  }

  return { success: false };
});

// Import config
ipcMain.handle('import-config', async () => {
  const { dialog } = require('electron');

  const result = await dialog.showOpenDialog(mainWindow, {
    title: 'Import Configuration',
    filters: [{ name: 'JSON', extensions: ['json'] }],
    properties: ['openFile']
  });

  if (!result.canceled && result.filePaths.length > 0) {
    try {
      const config = JSON.parse(fs.readFileSync(result.filePaths[0], 'utf8'));
      store.set(config);
      return { success: true };
    } catch (err) {
      return { success: false, error: err.message };
    }
  }

  return { success: false };
});
