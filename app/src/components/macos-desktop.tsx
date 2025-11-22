"use client"

import { Wifi, Battery } from "lucide-react"

export function MacOSDesktop() {
  return (
    <div className="relative w-full h-screen bg-[#1a1a1a] overflow-hidden">
      {/* macOS Menu Bar */}
      <div className="absolute top-0 left-0 right-0 h-7 bg-[#1c1c1e]/95 backdrop-blur-xl border-b border-white/[0.08] flex items-center justify-between px-4 z-40">
        {/* Left side */}
        <div className="flex items-center gap-6">
          <svg className="w-3.5 h-3.5 text-white/90" viewBox="0 0 16 16" fill="currentColor">
            <path d="M11.182 3.818c.74-.74.74-1.939 0-2.678-.74-.74-1.939-.74-2.678 0L3.818 5.826c-.74.74-.74 1.939 0 2.678l4.686 4.686c.74.74 1.939.74 2.678 0 .74-.74.74-1.939 0-2.678L7.496 7.165l3.686-3.347z" />
          </svg>
          <div className="flex items-center gap-4 text-[11px] font-medium">
            <span className="text-white/90">Darwinian</span>
            <span className="text-white/70">File</span>
            <span className="text-white/70">Edit</span>
            <span className="text-white/70">View</span>
            <span className="text-white/70">Go</span>
            <span className="text-white/70">Window</span>
            <span className="text-white/70">Help</span>
          </div>
        </div>

        {/* Right side */}
        <div className="flex items-center gap-3">
          <Battery className="w-4 h-4 text-white/70" />
          <Wifi className="w-4 h-4 text-white/70" />
          <span className="text-[11px] text-white/90 font-medium">Fri Nov 22 2:30 PM</span>
        </div>
      </div>

      {/* Desktop Wallpaper - Dark gradient */}
      <div className="absolute inset-0 bg-gradient-to-br from-[#0f0f10] via-[#1a1625] to-[#0a0a12]" />

      {/* Terminal Window */}
      <div className="absolute top-20 left-12 w-[600px] rounded-lg overflow-hidden shadow-2xl border border-white/[0.08] bg-[#1c1c1e]/95 backdrop-blur-xl animate-in fade-in slide-in-from-bottom-4 duration-500">
        {/* Terminal Title Bar */}
        <div className="h-11 bg-[#28282a]/95 border-b border-white/[0.08] flex items-center justify-between px-4">
          <div className="flex items-center gap-2">
            <div className="flex gap-1.5">
              <div className="w-3 h-3 rounded-full bg-[#ff5f57]" />
              <div className="w-3 h-3 rounded-full bg-[#febc2e]" />
              <div className="w-3 h-3 rounded-full bg-[#28ca42]" />
            </div>
            <span className="text-[11px] text-white/60 ml-2 font-medium">darwinian-config — zsh</span>
          </div>
        </div>

        {/* Terminal Content */}
        <div className="p-4 font-mono text-[13px] leading-relaxed space-y-2">
          <div className="text-[#00ff00]">
            <span className="text-[#5ac8fa]">darwinian</span>
            <span className="text-white/60"> ❯ </span>
            <span className="text-white/90">darwin-rebuild switch</span>
          </div>
          <div className="text-white/70">building the system configuration...</div>
          <div className="text-white/70 flex items-center gap-2">
            <span className="text-[#00ff00]">✓</span> vim installed successfully
          </div>
          <div className="text-white/70 flex items-center gap-2">
            <span className="text-[#00ff00]">✓</span> natural scroll disabled
          </div>
          <div className="text-white/70 flex items-center gap-2">
            <span className="text-[#00ff00]">✓</span> system packages updated
          </div>
          <div className="text-[#5ac8fa] mt-2">Build succeeded! Your system has evolved.</div>
        </div>
      </div>

      {/* Dock */}
      <div className="absolute bottom-2 left-1/2 -translate-x-1/2 z-30">
        <div className="bg-white/10 backdrop-blur-2xl rounded-2xl px-3 py-2 border border-white/20 shadow-2xl">
          <div className="flex items-center gap-2">
            {[...Array(7)].map((_, i) => (
              <div
                key={i}
                className="w-12 h-12 rounded-xl bg-gradient-to-br from-white/20 to-white/5 border border-white/10 hover:scale-110 transition-transform cursor-pointer"
              />
            ))}
            <div className="w-px h-12 bg-white/20 mx-1" />
            <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-primary/40 to-primary/20 border border-primary/30 hover:scale-110 transition-transform cursor-pointer flex items-center justify-center">
              <span className="text-xl">🧬</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
