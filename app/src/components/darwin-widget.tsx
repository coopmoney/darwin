"use client"

import { useState } from "react"
import { Sparkles, Zap, GitBranch, X, Terminal, Check } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { cn } from "@/lib/utils"

export function DarwinWidget() {
  const [isExpanded, setIsExpanded] = useState(true)
  const [activeTab, setActiveTab] = useState<"evolve" | "apply" | "commit">("evolve")
  const [isProcessing, setIsProcessing] = useState(false)
  const [evolveText, setEvolveText] = useState("")
  const [commitMsg, setCommitMsg] = useState("")

  const handleEvolve = async () => {
    setIsProcessing(true)
    try { await (window as any).darwinAPI?.darwin?.evolve?.(evolveText) } finally { setIsProcessing(false) }
  }
  const handleApply = async () => {
    setIsProcessing(true)
    try { await (window as any).darwinAPI?.darwin?.apply?.() } finally { setIsProcessing(false) }
  }
  const handleCommit = async () => {
    setIsProcessing(true)
    try { await (window as any).darwinAPI?.git?.commit?.(commitMsg) } finally { setIsProcessing(false) }
  }

  return (
    <div className="fixed bottom-6 right-6 z-50">
      {isExpanded ? (
        <div className="bg-card border border-border rounded-xl shadow-2xl w-[420px] backdrop-blur-xl overflow-hidden animate-in slide-in-from-bottom-4 duration-300">
          {/* Header */}
          <div className="flex items-center justify-between p-4 border-b border-border bg-card/50">
            <div className="flex items-center gap-2">
              <div className="w-8 h-8 rounded-lg bg-primary flex items-center justify-center">
                <Sparkles className="w-4 h-4 text-primary-foreground" />
              </div>
              <div>
                <h3 className="text-sm font-semibold text-foreground">Darwinian</h3>
                <p className="text-xs text-muted-foreground">System Manager</p>
              </div>
            </div>
            <Button variant="ghost" size="sm" onClick={() => setIsExpanded(false)} className="h-8 w-8 p-0">
              <X className="w-4 h-4" />
            </Button>
          </div>

          {/* Tabs */}
          <div className="flex border-b border-border bg-muted/30">
            <button
              onClick={() => setActiveTab("evolve")}
              className={cn(
                "flex-1 px-4 py-3 text-sm font-medium transition-colors relative",
                activeTab === "evolve" ? "text-foreground" : "text-muted-foreground hover:text-foreground",
              )}
            >
              <div className="flex items-center justify-center gap-2">
                <Sparkles className="w-4 h-4" />
                Evolve
              </div>
              {activeTab === "evolve" && <div className="absolute bottom-0 left-0 right-0 h-0.5 bg-primary" />}
            </button>
            <button
              onClick={() => setActiveTab("apply")}
              className={cn(
                "flex-1 px-4 py-3 text-sm font-medium transition-colors relative",
                activeTab === "apply" ? "text-foreground" : "text-muted-foreground hover:text-foreground",
              )}
            >
              <div className="flex items-center justify-center gap-2">
                <Zap className="w-4 h-4" />
                Apply
              </div>
              {activeTab === "apply" && <div className="absolute bottom-0 left-0 right-0 h-0.5 bg-primary" />}
            </button>
            <button
              onClick={() => setActiveTab("commit")}
              className={cn(
                "flex-1 px-4 py-3 text-sm font-medium transition-colors relative",
                activeTab === "commit" ? "text-foreground" : "text-muted-foreground hover:text-foreground",
              )}
            >
              <div className="flex items-center justify-center gap-2">
                <GitBranch className="w-4 h-4" />
                Commit
              </div>
              {activeTab === "commit" && <div className="absolute bottom-0 left-0 right-0 h-0.5 bg-primary" />}
            </button>
          </div>

          {/* Content */}
          <div className="p-4">
            {activeTab === "evolve" && (
              <div className="space-y-4">
                <div>
                  <label className="text-sm font-medium text-foreground mb-2 block">
                    What would you like to evolve?
                  </label>
                  <Input
                    value={evolveText}
                    onChange={(e) => setEvolveText(e.target.value)}
                    placeholder="e.g., install vim, disable natural scroll..."
                    className="bg-background border-border"
                  />
                </div>
                <div className="bg-muted/50 rounded-lg p-3 space-y-2">
                  <div className="flex items-start gap-2 text-xs">
                    <Terminal className="w-3.5 h-3.5 text-muted-foreground mt-0.5 flex-shrink-0" />
                    <div className="text-muted-foreground">
                      <span className="text-foreground font-medium">Example:</span> Install development tools and
                      configure git
                    </div>
                  </div>
                </div>
                <Button
                  onClick={handleEvolve}
                  disabled={isProcessing || !evolveText}
                  className="w-full bg-primary hover:bg-primary/90 text-primary-foreground"
                >
                  {isProcessing ? (
                    <>
                      <div className="w-4 h-4 border-2 border-primary-foreground/30 border-t-primary-foreground rounded-full animate-spin mr-2" />
                      Evolving...
                    </>
                  ) : (
                    <>
                      <Sparkles className="w-4 h-4 mr-2" />
                      Evolve System
                    </>
                  )}
                </Button>
              </div>
            )}

            {activeTab === "apply" && (
              <div className="space-y-4">
                <div className="bg-muted/50 rounded-lg p-4 space-y-3">
                  <div className="flex items-center justify-between">
                    <span className="text-sm text-foreground">Pending Changes</span>
                    <span className="text-xs text-muted-foreground">3 modifications</span>
                  </div>
                  <div className="space-y-2">
                    <div className="flex items-center gap-2 text-xs">
                      <Check className="w-3.5 h-3.5 text-primary" />
                      <span className="text-muted-foreground">Install vim editor</span>
                    </div>
                    <div className="flex items-center gap-2 text-xs">
                      <Check className="w-3.5 h-3.5 text-primary" />
                      <span className="text-muted-foreground">Disable natural scroll</span>
                    </div>
                    <div className="flex items-center gap-2 text-xs">
                      <Check className="w-3.5 h-3.5 text-primary" />
                      <span className="text-muted-foreground">Update system packages</span>
                    </div>
                  </div>
                </div>
                <Button
                  onClick={handleApply}
                  disabled={isProcessing}
                  className="w-full bg-primary hover:bg-primary/90 text-primary-foreground"
                >
                  {isProcessing ? (
                    <>
                      <div className="w-4 h-4 border-2 border-primary-foreground/30 border-t-primary-foreground rounded-full animate-spin mr-2" />
                      Applying...
                    </>
                  ) : (
                    <>
                      <Zap className="w-4 h-4 mr-2" />
                      Apply with nix-darwin
                    </>
                  )}
                </Button>
              </div>
            )}

            {activeTab === "commit" && (
              <div className="space-y-4">
                <div>
                  <label className="text-sm font-medium text-foreground mb-2 block">Commit Message</label>
                  <Input value={commitMsg} onChange={(e)=>setCommitMsg(e.target.value)} placeholder="e.g., Add development environment" className="bg-background border-border" />
                </div>
                <div className="bg-muted/50 rounded-lg p-3 space-y-2">
                  <div className="text-xs text-muted-foreground">
                    Your configuration will be versioned and synced across all your devices.
                  </div>
                </div>
                <Button
                  onClick={handleCommit}
                  disabled={isProcessing || !commitMsg}
                  className="w-full bg-primary hover:bg-primary/90 text-primary-foreground"
                >
                  {isProcessing ? (
                    <>
                      <div className="w-4 h-4 border-2 border-primary-foreground/30 border-t-primary-foreground rounded-full animate-spin mr-2" />
                      Committing...
                    </>
                  ) : (
                    <>
                      <GitBranch className="w-4 h-4 mr-2" />
                      Commit & Sync
                    </>
                  )}
                </Button>
              </div>
            )}
          </div>

          {/* Footer */}
          <div className="px-4 py-3 bg-muted/30 border-t border-border">
            <div className="flex items-center justify-between text-xs">
              <span className="text-muted-foreground">Last sync: 2 minutes ago</span>
              <span className="text-primary">●</span>
            </div>
          </div>
        </div>
      ) : (
        <Button
          onClick={() => setIsExpanded(true)}
          size="lg"
          className="rounded-full w-14 h-14 bg-primary hover:bg-primary/90 text-primary-foreground shadow-2xl animate-in zoom-in duration-200"
        >
          <Sparkles className="w-5 h-5" />
        </Button>
      )}
    </div>
  )
}
