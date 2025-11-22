import { ipcRenderer, contextBridge } from 'electron'

// --------- Expose some API to the Renderer process ---------
contextBridge.exposeInMainWorld('ipcRenderer', {
  on(...args: Parameters<typeof ipcRenderer.on>) {
    const [channel, listener] = args
    return ipcRenderer.on(channel, (event, ...args) => listener(event, ...args))
  },
  off(...args: Parameters<typeof ipcRenderer.off>) {
    const [channel, ...omit] = args
    return ipcRenderer.off(channel, ...omit)
  },
  send(...args: Parameters<typeof ipcRenderer.send>) {
    const [channel, ...omit] = args
    return ipcRenderer.send(channel, ...omit)
  },
  invoke(...args: Parameters<typeof ipcRenderer.invoke>) {
    const [channel, ...omit] = args
    return ipcRenderer.invoke(channel, ...omit)
  },
})

contextBridge.exposeInMainWorld('darwinAPI', {
  openMain: () => ipcRenderer.send('overlay:open-main'),
  config: {
    get: () => ipcRenderer.invoke('config:get'),
    setDir: (dir: string) => ipcRenderer.invoke('config:setDir', dir),
    pickDir: () => ipcRenderer.invoke('config:pickDir'),
    setHostAttr: (host: string) => ipcRenderer.invoke('config:setHostAttr', host),
  },
  git: {
    initIfNeeded: () => ipcRenderer.invoke('git:initIfNeeded'),
    status: () => ipcRenderer.invoke('git:status'),
    commit: (message: string) => ipcRenderer.invoke('git:commit', message),
  },
  darwin: {
    evolve: (description: string) => ipcRenderer.invoke('darwin:evolve', description),
    apply: (hostOverride?: string) => ipcRenderer.invoke('darwin:apply', hostOverride),
  },
  flake: {
    installedApps: () => ipcRenderer.invoke('flake:installedApps'),
  },
})
