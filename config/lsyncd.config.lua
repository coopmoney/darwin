-- lsyncd.conf.lua
settings {
  logfile = "/tmp/lsyncd.log",
  statusFile = "/tmp/lsyncd.status"
}

sync {
  default.rsyncssh,
  source = "/Users/coopermaruyama/Developer/darkmatter/monorepo",
	host = "cooper@100.107.182.84",
  targetdir = "/Users/cooper/Developer/apollo-sync",
	ssh = {
		identityFile = "/Users/cooper/.ssh/id_ed25519",
		options = {
			StrictHostKeyChecking="no"
		},
	},
  exclude = {
    -- Git and version control
    ".git/",
    ".gitignore",
    
    -- Common development directories
    "node_modules/",
    ".next/",
    "dist/",
    "build/",
    
    -- Nix and development environments
    ".devenv/",
    ".direnv/",
    ".devshell/",
    "result",
    "result-*",
    
			-- IDE and editor files
			".vscode/",
			".idea/",
			"*.swp",
			"*.swo",
			"*~",
			
			-- OS files
			".DS_Store",
			"Thumbs.db",
			
			-- Logs and temporary files
			"*.log",
			".tmp/",
			"tmp/",
		},
  rsync = {
    archive = true,
    compress = true,
    verbose = true,
  }
}
