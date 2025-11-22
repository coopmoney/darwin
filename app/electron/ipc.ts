import { ipcMain, dialog, app } from 'electron'
import path from 'node:path'
import fs from 'node:fs'
import store, { ensureConfigDirExists, getConfigDir, setConfigDir, getHostAttrFromStore, setHostAttr, readHostAttrFromFile } from './store'
import * as git from './git'
import * as nix from './nix'
import * as darwin from './cli/darwin'

function sanitizeDir(p: string) {
  if (!p || typeof p !== 'string') throw new Error('Invalid path')
  return p
}

export function registerIpcHandlers() {
  ipcMain.handle('config:get', async () => ({
    configDir: getConfigDir(),
    hostAttr: getHostAttrFromStore() || readHostAttrFromFile() || null,
  }))

  ipcMain.handle('config:setHostAttr', async (_e, host: string) => {
    setHostAttr(host)
    return { ok: true }
  })

  ipcMain.handle('config:setDir', async (_e, dir: string) => {
    setConfigDir(sanitizeDir(dir))
    ensureConfigDirExists()
    return { ok: true }
  })

  ipcMain.handle('config:pickDir', async (e) => {
    const res = await dialog.showOpenDialog({ properties: ['openDirectory', 'createDirectory'] })
    if (res.canceled || res.filePaths.length === 0) return null
    const dir = res.filePaths[0]
    setConfigDir(dir)
    ensureConfigDirExists()
    return dir
  })

  ipcMain.handle('git:initIfNeeded', async () => {
    const dir = ensureConfigDirExists()
    await git.initIfNeeded(dir)
    return { ok: true }
  })

  ipcMain.handle('git:status', async () => {
    const dir = ensureConfigDirExists()
    await git.initIfNeeded(dir)
    return git.status(dir)
  })

  ipcMain.handle('git:commit', async (_e, message: string) => {
    const dir = ensureConfigDirExists()
    return git.commitAll(dir, message)
  })

  ipcMain.handle('darwin:evolve', async (_e, description: string) => {
    const dir = ensureConfigDirExists()
    await darwin.evolve(dir, description)
    return { ok: true }
  })

  ipcMain.handle('darwin:apply', async (_e, hostOverride?: string) => {
    const dir = ensureConfigDirExists()
    return darwin.apply(dir, hostOverride)
  })

  ipcMain.handle('flake:installedApps', async () => {
    const dir = ensureConfigDirExists()
    let host = nix.determineHostAttr()
    if (!host) {
      try {
        const hosts = await nix.listDarwinHosts(dir)
        if (hosts && hosts.length === 1) {
          host = hosts[0]
        } else {
          throw Object.assign(new Error('Host attribute not found'), { code: 'NO_HOST', hosts })
        }
      } catch (e) {
        throw new Error('Host attribute not found')
      }
    }
    return nix.evaluateInstalledApps(dir, host)
  })

  ipcMain.handle('flake:listHosts', async () => {
    const dir = ensureConfigDirExists()
    return nix.listDarwinHosts(dir)
  })
}
