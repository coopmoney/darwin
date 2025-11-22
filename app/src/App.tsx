import { useEffect, useMemo, useState } from 'react'
import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/tabs'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Textarea } from '@/components/ui/textarea'
import { DarwinWidget } from '@/components/darwin-widget'
import { MacOSDesktop } from '@/components/macos-desktop'

declare global {
  interface Window {
    darwinAPI: any
  }
}

function useConfig() {
  const [configDir, setConfigDir] = useState<string>('')
  const [hostAttr, setHostAttr] = useState<string | null>(null)
  useEffect(() => {
    window.darwinAPI.config.get().then((c: any) => { setConfigDir(c.configDir); setHostAttr(c.hostAttr) })
  }, [])
  return { configDir, hostAttr, pickDir: async () => {
    const dir = await window.darwinAPI.config.pickDir()
    if (dir) setConfigDir(dir)
  } }
}

function useGitStatus() {
  const [status, setStatus] = useState<any>(null)
  const refresh = async () => setStatus(await window.darwinAPI.git.status())
  useEffect(() => { refresh() }, [])
  return { status, refresh }
}

function Overview() {
  const { configDir, hostAttr, pickDir } = useConfig()
  const [hostEdit, setHostEdit] = useState(hostAttr ?? '')
  useEffect(() => { if (hostAttr) setHostEdit(hostAttr) }, [hostAttr])
  const [apps, setApps] = useState<any[]>([])
  const [error, setError] = useState<string | null>(null)
  const load = async () => {
    setError(null)
    try { const a = await window.darwinAPI.flake.installedApps(); setApps(a || []) } catch (e: any) { setError(e.message) }
  }
  return (
    <div className="p-4 space-y-3">
      <div className="flex items-center gap-3">
        <div className="text-sm">Config dir: <span className="font-mono">{configDir}</span></div>
        <Button variant="secondary" onClick={pickDir}>Change…</Button>
        <div className="flex items-center gap-2">
          <span className="text-sm">Host:</span>
          <Input className="w-[260px]" value={hostEdit} onChange={(e)=>setHostEdit(e.target.value)} placeholder="e.g. Coopers-MacBook-Pro" />
          <Button variant="secondary" onClick={async ()=>{ await window.darwinAPI.config.setHostAttr(hostEdit); }}>Save</Button>
        </div>
        <Button onClick={load}>Refresh apps</Button>
      </div>
      {error && <div className="text-red-500 text-sm">{error}</div>}
      <div className="grid grid-cols-2 gap-2 max-h-[50vh] overflow-auto">
        {apps.map((p: any, i: number) => (
          <div key={i} className="text-sm font-mono border rounded p-2">{JSON.stringify(p)}</div>
        ))}
      </div>
    </div>
  )
}

function Actions() {
  const { refresh, status } = useGitStatus()
  const [commitMsg, setCommitMsg] = useState('')
  const [evolveDesc, setEvolveDesc] = useState('')
  const [busy, setBusy] = useState(false)
  const hasChanges = !!status?.hasChanges

  const doEvolve = async () => { setBusy(true); try { await window.darwinAPI.darwin.evolve(evolveDesc); await refresh() } finally { setBusy(false) } }
  const doCommit = async () => { if (!commitMsg) return; setBusy(true); try { await window.darwinAPI.git.commit(commitMsg); setCommitMsg(''); await refresh() } finally { setBusy(false) } }
  const doApply = async () => { setBusy(true); try { await window.darwinAPI.darwin.apply(); } finally { setBusy(false) } }

  return (
    <div className="p-4 space-y-4">
      <div className="text-sm">Pending changes: <span className="font-mono">{hasChanges ? 'yes' : 'no'}</span></div>
      <div className="space-y-2">
        <label className="text-sm">Evolve description</label>
        <Textarea value={evolveDesc} onChange={(e) => setEvolveDesc(e.target.value)} placeholder="Describe desired changes (e.g., add app X, enable Y)" />
        <Button onClick={doEvolve} disabled={busy || !evolveDesc}>Evolve</Button>
      </div>
      <div className="space-y-2">
        <label className="text-sm">Commit message</label>
        <Input value={commitMsg} onChange={(e) => setCommitMsg(e.target.value)} placeholder="Summarize your changes" />
        <Button onClick={doCommit} disabled={busy || !hasChanges || !commitMsg}>Commit</Button>
      </div>
      <div>
        <Button onClick={doApply} disabled={busy}>Apply</Button>
      </div>
    </div>
  )
}

export default function App() {
  return (
    <div className="p-3">
      {/* Drag region for frameless window */}
      <div className="fixed top-0 left-0 right-0 h-8 z-[60]" style={{ WebkitAppRegion: 'drag' }} />
      <div className="mb-4">
        <DarwinWidget />
      </div>
      <Tabs defaultValue="overview">
        <TabsList>
          <TabsTrigger value="overview">Overview</TabsTrigger>
          <TabsTrigger value="actions">Actions</TabsTrigger>
          <TabsTrigger value="desktop">Desktop</TabsTrigger>
        </TabsList>
        <TabsContent value="overview"><Overview /></TabsContent>
        <TabsContent value="actions"><Actions /></TabsContent>
        <TabsContent value="desktop"><MacOSDesktop /></TabsContent>
      </Tabs>
    </div>
  )
}
