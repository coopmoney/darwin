import { app, BrowserWindow, Tray, Menu, nativeImage, screen, systemPreferences, ipcMain } from 'electron'
import { createRequire } from 'node:module'
import { fileURLToPath } from 'node:url'
import path from 'node:path'
import { registerIpcHandlers } from './ipc'

const require = createRequire(import.meta.url)
const __dirname = path.dirname(fileURLToPath(import.meta.url))

// The built directory structure
//
// ├─┬─┬ dist
// │ │ └── index.html
// │ │
// │ ├─┬ dist-electron
// │ │ ├── main.js
// │ │ └── preload.mjs
// │
process.env.APP_ROOT = path.join(__dirname, '..')

// 🚧 Use ['ENV_NAME'] avoid vite:define plugin - Vite@2.x
export const VITE_DEV_SERVER_URL = process.env['VITE_DEV_SERVER_URL']
export const MAIN_DIST = path.join(process.env.APP_ROOT, 'dist-electron')
export const RENDERER_DIST = path.join(process.env.APP_ROOT, 'dist')

process.env.VITE_PUBLIC = VITE_DEV_SERVER_URL ? path.join(process.env.APP_ROOT, 'public') : RENDERER_DIST

let mainWindow: BrowserWindow | null
let overlayWindow: BrowserWindow | null
let tray: Tray | null

function createMainWindow() {
  mainWindow = new BrowserWindow({
    width: 980,
    height: 720,
    show: true,
    title: 'Darwin',
    icon: path.join(process.env.APP_ROOT!, 'image.png'),
    frame: false,
    titleBarStyle: 'hiddenInset',
    transparent: true,
    backgroundColor: '#00000000',
    vibrancy: 'under-window',
    visualEffectState: 'active',
    webPreferences: {
      preload: path.join(__dirname, 'preload.mjs'),
      nodeIntegration: false,
      contextIsolation: true,
      sandbox: true,
    },
  })

  if (VITE_DEV_SERVER_URL) {
    mainWindow.loadURL(VITE_DEV_SERVER_URL)
  } else {
    mainWindow.loadFile(path.join(RENDERER_DIST, 'index.html'))
  }
}

function createOverlayWindow() {
  overlayWindow = new BrowserWindow({
    width: 120,
    height: 120,
    frame: false,
    transparent: true,
    resizable: false,
    movable: false,
    focusable: false,
    alwaysOnTop: true,
    skipTaskbar: true,
    show: false,
    hasShadow: false,
    webPreferences: {
      preload: path.join(__dirname, 'preload.mjs'),
      nodeIntegration: false,
      contextIsolation: true,
      sandbox: true,
    },
  })

  // Render a minimal overlay UI from the same renderer bundle (can branch by location.hash)
  if (VITE_DEV_SERVER_URL) {
    overlayWindow.loadURL(`${VITE_DEV_SERVER_URL}#overlay`)
  } else {
    overlayWindow.loadFile(path.join(RENDERER_DIST, 'index.html'), { hash: 'overlay' })
  }

  // Click handled via renderer -> IPC
}

function createTray() {
  const imagePath = path.join(process.env.APP_ROOT!, 'image.png')
  const image = nativeImage.createFromPath(imagePath)
  tray = new Tray(image)
  const menu = Menu.buildFromTemplate([
    { label: 'Open', click: () => mainWindow?.show() },
    { type: 'separator' },
    { label: 'Evolve', click: () => {/* TODO: trigger evolve */} },
    { label: 'Commit', click: () => {/* TODO: trigger commit */} },
    { label: 'Apply', click: () => {/* TODO: trigger apply */} },
    { type: 'separator' },
    { label: 'Quit', click: () => app.quit() },
  ])
  tray.setToolTip('Darwin')
  tray.setContextMenu(menu)
}

function setAutoStart() {
  try {
    app.setLoginItemSettings({ openAtLogin: true, openAsHidden: true })
  } catch {}
}

// Global input (Alt + bottom-right 120x120 on primary display)
function startGlobalInputWatcher() {
  // Request Accessibility permission (will prompt on first run)
  try { systemPreferences.isTrustedAccessibilityClient(true) } catch {}

  // Prefer native global hook; fall back to polling if unavailable
  let hook: any
  try {
    // eslint-disable-next-line @typescript-eslint/no-var-requires
    hook = require('uiohook-napi')
  } catch {
    hook = null
  }

  let altDown = false
  let lastX = 0, lastY = 0

  const updateOverlay = () => {
    if (!overlayWindow) return
    const primary = screen.getPrimaryDisplay()
    const { x, y, width, height } = primary.workArea
    const zoneW = 120, zoneH = 120
    const zoneX = x + width - zoneW
    const zoneY = y + height - zoneH
    const inside = lastX >= zoneX && lastY >= zoneY && lastX <= zoneX + zoneW && lastY <= zoneY + zoneH
    const shouldShow = altDown && inside
    if (shouldShow) {
      overlayWindow.setBounds({ x: zoneX, y: zoneY, width: zoneW, height: zoneH })
      if (!overlayWindow.isVisible()) overlayWindow.showInactive()
    } else if (overlayWindow.isVisible()) {
      overlayWindow.hide()
    }
  }

  if (hook && hook.uIOhook) {
    hook.uIOhook.on('keyup', (e: any) => { if (e.keycode === 56 || e.keycode === 3640) { altDown = false; updateOverlay() } })
    hook.uIOhook.on('keydown', (e: any) => { if (e.keycode === 56 || e.keycode === 3640) { altDown = true; updateOverlay() } })
    hook.uIOhook.on('mousemove', (e: any) => { lastX = e.x; lastY = e.y; updateOverlay() })
    hook.uIOhook.start()
  } else {
    // Fallback: poll cursor position ~8Hz
    setInterval(() => {
      const { x: cx, y: cy } = screen.getCursorScreenPoint()
      lastX = cx; lastY = cy
      // No reliable alt detection without hook; assume false
      altDown = false
      updateOverlay()
    }, 125)
  }
}

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit()
    mainWindow = null
    overlayWindow = null
  }
})

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createMainWindow()
  }
})

app.whenReady().then(() => {
  try { const { nativeTheme } = require('electron'); nativeTheme.themeSource = 'dark' } catch {}
  // In dev, hide Dock to simulate agent app behavior
  try { if (process.platform === 'darwin') app.dock.hide() } catch {}
  createMainWindow()
  createOverlayWindow()
  createTray()
  setAutoStart()
  startGlobalInputWatcher()
  registerIpcHandlers()

  ipcMain.on('overlay:open-main', () => {
    if (mainWindow) {
      mainWindow.show()
      mainWindow.focus()
    }
  })
})
