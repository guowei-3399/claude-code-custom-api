const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
  // Configuration
  getConfig: () => ipcRenderer.invoke('get-config'),
  saveConfig: (config) => ipcRenderer.invoke('save-config', config),
  exportConfig: () => ipcRenderer.invoke('export-config'),
  importConfig: () => ipcRenderer.invoke('import-config'),

  // Claude Code
  launchClaude: (args) => ipcRenderer.invoke('launch-claude', args),
  getClaudeVersion: () => ipcRenderer.invoke('get-claude-version'),

  // Testing
  testProxy: (proxyUrl) => ipcRenderer.invoke('test-proxy', proxyUrl),
  testAPI: (apiBase, apiKey) => ipcRenderer.invoke('test-api', apiBase, apiKey),

  // Utilities
  openExternal: (url) => ipcRenderer.invoke('open-external', url)
});
