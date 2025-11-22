import { execa } from 'execa'
import sudoPrompt from 'sudo-prompt'
import { initIfNeeded, commitAll } from '../git'
import { determineHostAttr, darwinRebuildSwitch } from '../nix'

export async function evolve(configDir: string, description: string) {
  await initIfNeeded(configDir)
  // Ask codex to produce a unified diff patch and write it to /tmp/darwin-evolve.patch
  const patchPath = '/tmp/darwin-evolve.patch'
  const prompt = `Propose Nix flake configuration changes for: ${description}. Generate a single unified diff (git patch format) applicable from the repository root (no absolute paths). Write ONLY the patch content to ${patchPath}. If no changes are needed, write an empty file.`
  await execa('codex', ['e', prompt], { cwd: configDir })
  // Apply patch if non-empty
  const { stdout: sizeOut } = await execa('bash', ['-lc', `[ -s ${patchPath} ] && echo nonempty || echo empty`])
  if (sizeOut.trim() === 'nonempty') {
    // Apply the patch and stage
    await execa('git', ['apply', patchPath], { cwd: configDir })
  }
}

export async function commit(configDir: string, message: string) {
  await initIfNeeded(configDir)
  return commitAll(configDir, message)
}

export async function apply(configDir: string, hostAttrFromUI?: string) {
  const host = hostAttrFromUI || determineHostAttr()
  if (!host) throw new Error('Host attribute not found. Set ~/.config/darwin/host or configure in Settings.')
  return new Promise<{ code: number; stdout: string; stderr: string }>((resolve, reject) => {
    const safeDir = configDir.replace(/'/g, "'\\''")
    const command = `cd '${safeDir}' && darwin-rebuild switch --flake ".#${host}"`
    sudoPrompt.exec(command, { name: 'Darwin' }, (error, stdout, stderr) => {
      if (error) return reject(error)
      resolve({ code: 0, stdout, stderr })
    })
  })
}
