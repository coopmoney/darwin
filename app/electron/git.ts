import simpleGit, { SimpleGit, StatusResult } from 'simple-git'
import fs from 'node:fs'
import path from 'node:path'

export function gitFor(dir: string): SimpleGit {
  return simpleGit({ baseDir: dir })
}

export async function isRepo(dir: string) {
  try {
    await gitFor(dir).revparse(['--is-inside-work-tree'])
    return true
  } catch {
    return false
  }
}

export async function initIfNeeded(dir: string) {
  if (!(await isRepo(dir))) {
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true })
    await gitFor(dir).init()
    const gi = path.join(dir, '.gitignore')
    if (!fs.existsSync(gi)) {
      fs.writeFileSync(gi, ['node_modules', 'result', 'release', 'dist', 'dist-electron'].join('\n'))
    }
  }
}

export async function status(dir: string): Promise<StatusResult & { hasChanges: boolean }> {
  const s = await gitFor(dir).status()
  return Object.assign(s, { hasChanges: s.files.length > 0 })
}

export async function commitAll(dir: string, message: string) {
  const git = gitFor(dir)
  await git.add(['-A'])
  const res = await git.commit(message)
  return res
}
