import Store from 'electron-store'
import fs from 'node:fs'
import os from 'node:os'
import path from 'node:path'

export type AppSettings = {
  configDir: string
  hostAttr?: string
  autoStart: boolean
}

const defaults: AppSettings = {
  configDir: path.join(os.homedir(), '.darwin'),
  autoStart: true,
}

const store = new Store<AppSettings>({ name: 'settings', defaults })

export function getConfigDir() {
  return store.get('configDir')
}

export function setConfigDir(dir: string) {
  store.set('configDir', dir)
}

export function getHostAttrFromStore(): string | undefined {
  return store.get('hostAttr')
}

export function setHostAttr(attr: string) {
  store.set('hostAttr', attr)
}

export function ensureConfigDirExists() {
  const dir = getConfigDir()
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true })
  return dir
}

export function readHostAttrFromFile(): string | undefined {
  try {
    const cfgHome = process.env.XDG_CONFIG_HOME || path.join(os.homedir(), '.config')
    const hostFile = path.join(cfgHome, 'darwin', 'host')
    if (fs.existsSync(hostFile)) {
      const v = fs.readFileSync(hostFile, 'utf8').trim()
      return v || undefined
    }
  } catch {}
  return undefined
}

export default store
