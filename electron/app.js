// app.js - Frontend application logic

let currentConfig = {};

// ============================================================================
// Initialization
// ============================================================================

async function init() {
  await loadConfig();
  await updateStatus();
  setupNavigation();
}

// Load configuration
async function loadConfig() {
  currentConfig = await window.electronAPI.getConfig();
  populateSettings();
  updateHomeStatus();
}

// Populate settings form
function populateSettings() {
  document.getElementById('api-provider-select').value = currentConfig.apiProvider;
  document.getElementById('custom-api-base').value = currentConfig.customApiBase;
  document.getElementById('api-key').value = currentConfig.apiKey;
  document.getElementById('proxy-enabled').checked = currentConfig.proxy.enabled;
  document.getElementById('proxy-url').value = currentConfig.proxy.url;
  document.getElementById('default-model').value = currentConfig.defaults.model;
  document.getElementById('default-effort').value = currentConfig.defaults.effort;
  document.getElementById('cache-enabled').checked = currentConfig.subscriptionCache.enabled;

  toggleCustomAPI();
  toggleProxy();
}

// Update home page status
function updateHomeStatus() {
  document.getElementById('api-provider').textContent =
    currentConfig.apiProvider === 'anthropic' ? 'Anthropic Official' : 'Custom Gateway';
  document.getElementById('proxy-status').textContent =
    currentConfig.proxy.enabled ? `Enabled (${currentConfig.proxy.url})` : 'Disabled';

  document.getElementById('model-select').value = currentConfig.defaults.model;
  document.getElementById('effort-select').value = currentConfig.defaults.effort;
}

// Update Claude version
async function updateStatus() {
  const result = await window.electronAPI.getClaudeVersion();
  document.getElementById('claude-version').textContent = result.version;
}

// ============================================================================
// Navigation
// ============================================================================

function setupNavigation() {
  const navItems = document.querySelectorAll('.nav-item');
  navItems.forEach(item => {
    item.addEventListener('click', () => {
      const page = item.getAttribute('data-page');
      showPage(page);

      navItems.forEach(n => n.classList.remove('active'));
      item.classList.add('active');
    });
  });
}

function showPage(pageName) {
  const pages = document.querySelectorAll('.page');
  pages.forEach(page => page.classList.add('hidden'));
  document.getElementById(`page-${pageName}`).classList.remove('hidden');
}

// ============================================================================
// Launch Claude Code
// ============================================================================

async function launchClaude() {
  const prompt = document.getElementById('prompt-input').value;
  const model = document.getElementById('model-select').value;
  const effort = document.getElementById('effort-select').value;

  const args = [
    '--model', model,
    '--effort', effort
  ];

  if (prompt) {
    args.push(prompt);
  }

  try {
    const result = await window.electronAPI.launchClaude(args);
    console.log('Claude Code launched', result);
  } catch (err) {
    alert('Failed to launch Claude Code: ' + err.error);
  }
}

async function quickLaunch(command) {
  const args = command ? [command] : [];

  try {
    await window.electronAPI.launchClaude(args);
  } catch (err) {
    alert('Failed to launch: ' + err.error);
  }
}

// ============================================================================
// Settings Management
// ============================================================================

function toggleCustomAPI() {
  const provider = document.getElementById('api-provider-select').value;
  const fields = document.getElementById('custom-api-fields');

  if (provider === 'custom') {
    fields.classList.remove('hidden');
  } else {
    fields.classList.add('hidden');
  }
}

function toggleProxy() {
  const enabled = document.getElementById('proxy-enabled').checked;
  const fields = document.getElementById('proxy-fields');

  if (enabled) {
    fields.classList.remove('hidden');
  } else {
    fields.classList.add('hidden');
  }
}

async function saveSettings() {
  const config = {
    apiProvider: document.getElementById('api-provider-select').value,
    customApiBase: document.getElementById('custom-api-base').value,
    apiKey: document.getElementById('api-key').value,
    proxy: {
      enabled: document.getElementById('proxy-enabled').checked,
      url: document.getElementById('proxy-url').value
    },
    defaults: {
      model: document.getElementById('default-model').value,
      effort: document.getElementById('default-effort').value
    },
    subscriptionCache: {
      enabled: document.getElementById('cache-enabled').checked,
      ttl: 300
    }
  };

  const result = await window.electronAPI.saveConfig(config);

  if (result.success) {
    alert('Settings saved successfully!');
    currentConfig = config;
    updateHomeStatus();
  } else {
    alert('Failed to save settings');
  }
}

async function exportConfig() {
  const result = await window.electronAPI.exportConfig();
  if (result.success) {
    alert('Configuration exported successfully!');
  }
}

async function importConfig() {
  const result = await window.electronAPI.importConfig();
  if (result.success) {
    alert('Configuration imported successfully!');
    await loadConfig();
  } else if (result.error) {
    alert('Failed to import: ' + result.error);
  }
}

// ============================================================================
// Connection Testing
// ============================================================================

async function testProxyConnection() {
  const proxyUrl = document.getElementById('proxy-url').value;
  const resultSpan = document.getElementById('proxy-test-result');

  resultSpan.textContent = 'Testing...';
  resultSpan.className = 'status info';

  const result = await window.electronAPI.testProxy(proxyUrl);

  if (result.success) {
    resultSpan.textContent = '✓ Connected';
    resultSpan.className = 'status success';
  } else {
    resultSpan.textContent = '✗ Failed';
    resultSpan.className = 'status error';
  }
}

async function testAPIConnection() {
  const apiBase = document.getElementById('custom-api-base').value;
  const apiKey = document.getElementById('api-key').value;
  const resultSpan = document.getElementById('api-test-result');

  resultSpan.textContent = 'Testing...';
  resultSpan.className = 'status info';

  const result = await window.electronAPI.testAPI(apiBase, apiKey);

  if (result.success) {
    resultSpan.textContent = '✓ API reachable';
    resultSpan.className = 'status success';
  } else {
    resultSpan.textContent = '✗ Failed';
    resultSpan.className = 'status error';
  }
}

async function testConnections() {
  alert('Testing proxy and API connections...');

  if (currentConfig.proxy.enabled) {
    await testProxyConnection();
  }

  if (currentConfig.apiProvider === 'custom') {
    await testAPIConnection();
  }

  showPage('settings');
}

// ============================================================================
// Utilities
// ============================================================================

async function openExternal(url) {
  await window.electronAPI.openExternal(url);
}

// Initialize on load
window.addEventListener('DOMContentLoaded', init);
