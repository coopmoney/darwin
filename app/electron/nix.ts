import { execa } from 'execa'
import os from 'node:os'
import path from 'node:path'
import fs from 'node:fs'
import { getHostAttrFromStore, readHostAttrFromFile } from './store'

export function determineHostAttr(): string | null {
  return getHostAttrFromStore() || readHostAttrFromFile() || null
}

export async function evaluateInstalledApps(configDir: string, hostAttr: string) {
  // nix eval --json .#darwinConfigurations.<host>.config.environment.systemPackages
  const attr = `.#darwinConfigurations.${hostAttr}.config.environment.systemPackages`
  const { stdout } = await execa('nix', ['eval', '--json', attr], {
    cwd: configDir,
    env: {
      ...process.env,
      NIX_CONFIG: 'experimental-features = nix-command flakes',
    },
  })
  return JSON.parse(stdout)
}

export async function listDarwinHosts(configDir: string): Promise<string[]> {
  // nix eval --json .#darwinConfigurations --apply builtins.attrNames
  const { stdout } = await execa(
    'nix',
    ['eval', '--json', '.#darwinConfigurations', '--apply', 'builtins.attrNames'],
    {
      cwd: configDir,
      env: { ...process.env, NIX_CONFIG: 'experimental-features = nix-command flakes' },
    }
  )
  return JSON.parse(stdout)
}

export async function darwinRebuildSwitch(hostAttr: string, onData?: (chunk: string) => void) {
  // We will run without sudo here; the caller should elevate using sudo-prompt
  return execa('darwin-rebuild', ['switch', '--flake', `.#${hostAttr}`], {
    env: process.env,
  })
}
