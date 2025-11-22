"use strict";
const electron = require("electron");
electron.contextBridge.exposeInMainWorld("ipcRenderer", {
  on(...args) {
    const [channel, listener] = args;
    return electron.ipcRenderer.on(channel, (event, ...args2) => listener(event, ...args2));
  },
  off(...args) {
    const [channel, ...omit] = args;
    return electron.ipcRenderer.off(channel, ...omit);
  },
  send(...args) {
    const [channel, ...omit] = args;
    return electron.ipcRenderer.send(channel, ...omit);
  },
  invoke(...args) {
    const [channel, ...omit] = args;
    return electron.ipcRenderer.invoke(channel, ...omit);
  }
});
electron.contextBridge.exposeInMainWorld("darwinAPI", {
  openMain: () => electron.ipcRenderer.send("overlay:open-main"),
  config: {
    get: () => electron.ipcRenderer.invoke("config:get"),
    setDir: (dir) => electron.ipcRenderer.invoke("config:setDir", dir),
    pickDir: () => electron.ipcRenderer.invoke("config:pickDir"),
    setHostAttr: (host) => electron.ipcRenderer.invoke("config:setHostAttr", host)
  },
  git: {
    initIfNeeded: () => electron.ipcRenderer.invoke("git:initIfNeeded"),
    status: () => electron.ipcRenderer.invoke("git:status"),
    commit: (message) => electron.ipcRenderer.invoke("git:commit", message)
  },
  darwin: {
    evolve: (description) => electron.ipcRenderer.invoke("darwin:evolve", description),
    apply: (hostOverride) => electron.ipcRenderer.invoke("darwin:apply", hostOverride)
  },
  flake: {
    installedApps: () => electron.ipcRenderer.invoke("flake:installedApps")
  }
});
