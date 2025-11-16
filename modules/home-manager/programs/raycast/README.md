# Raycast Configuration

This module manages Raycast configuration files, snippets, and scripts.

## Setup

1. Install Raycast (already included in Homebrew casks in common config, or add it if not present)

2. Export your Raycast settings:
   - Open Raycast
   - Go to Preferences (Cmd+,)
   - Navigate to Advanced
   - Export settings

3. Place exported files in this directory:
# Raycast Configuration

This module manages Raycast configuration files, snippets, and scripts with sensible defaults included.

## Default Configuration

The module includes a `preferences.json` file with these defaults:
- **Theme**: Dark mode
- **Hotkey**: Cmd+Space (global launcher)
- **Clipboard History**: Cmd+Shift+V
- **File Search**: Cmd+Shift+F
- **Search Position**: Center
- **Result View**: Large
- **Built-in Extensions**: Calculator, Calendar, Clipboard History, System, File Search, Window Management

## macOS System Defaults

The following system-level preferences are configured:
- Menu bar icon enabled
- Clipboard history: 100 items
- Window width: 680px
- Analytics and crash reporting disabled
- Initial setup marked as completed

## Customization

### Export your settings
1. Open Raycast
2. Go to Preferences (Cmd+,)
3. Navigate to Advanced
4. Export settings

### Place files in this directory
```
modules/home-manager/programs/raycast/
├── preferences.json    # Main preferences (defaults provided)
├── snippets/          # Text snippets (optional)
└── scripts/           # Custom scripts (optional)
```

## What gets synced

- **preferences.json**: Hotkeys, extensions, appearance, and other settings
- **snippets/**: All your text snippets (if directory exists)
- **scripts/**: Custom script commands (if directory exists)

## Note

Some settings (like installed extensions and their data) are stored in `~/Library/Application Support/com.raycast.macos/` and may need to be synced separately if you want them across machines.

## Default Hotkeys

- **Cmd+Space**: Open Raycast
- **Cmd+Shift+V**: Clipboard History
- **Cmd+Shift+F**: File Search

You can customize these hotkeys through the Raycast UI or by modifying `preferences.json`.
## What gets synced

- **preferences.json**: Hotkeys, extensions, appearance, and other settings
- **snippets/**: All your text snippets
- **scripts/**: Custom script commands

## Note

Some settings (like installed extensions and their data) are stored in `~/Library/Application Support/com.raycast.macos/` and may need to be synced separately if you want them across machines.
