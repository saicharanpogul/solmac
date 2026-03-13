# Solmac

A native macOS menu bar app to control `solana-test-validator`. Start/stop your local validator, pick which programs and accounts to clone, and stream logs — all from the menu bar.

## Features

- **Menu bar control** — Start and stop `solana-test-validator` with a click. The Solana logo icon shows status: outline when stopped, filled when running.
- **Program & account toggles** — Enable/disable programs and accounts directly from the menu dropdown. Changes apply on next validator start.
- **Presets library** — 20+ popular Solana programs (Metaplex, Jupiter, Raydium, Orca, Drift, Pyth, etc.) organized by category. One-click to add.
- **Auto-inspect** — When adding a program manually, auto-detect runs `solana program show` to determine upgradeability and discover associated accounts (e.g., ProgramData).
- **Per-item cluster** — Each program/account can specify its source cluster (mainnet, devnet, testnet). Cross-cluster items are pre-fetched automatically before the validator starts.
- **Config file + UI** — JSON config at `~/.config/solmac/config.json` as the source of truth, with a full settings UI to manage it.
- **Log viewer** — Live-streaming log window with search filter, auto-scroll, and slot noise filtering. Full logs written to file.
- **Port configuration** — RPC, faucet, and gossip ports editable in settings.

## Requirements

- macOS 14 (Sonoma) or later
- [Solana CLI tools](https://docs.solana.com/cli/install-solana-cli-tools) installed (`solana-test-validator`, `solana`)

## Build & Run

```bash
# Development (debug build + run)
swift build
swift run Solmac

# Release .app bundle
./scripts/build-app.sh
open Solmac.app
```

The app appears in the menu bar with no Dock icon (`LSUIElement = true`).

## Usage

### Quick start

1. Launch the app — the Solana logo appears in the menu bar
2. Click the icon → **Start Validator**
3. The icon fills in to indicate the validator is running

### Adding programs

**From presets:**
- Open **Settings** (Cmd+,) → **Presets** tab
- Browse by category or search
- Click **Add** — the program and any known associated accounts are added

**Manually:**
- Open **Settings** → **Programs** tab → **Add Program**
- Enter the program address and click **Auto-detect** to inspect it on-chain
- The app detects upgradeability and finds the ProgramData account
- Save — associated accounts are optionally added alongside the program

### Per-item cluster

Each program and account has a cluster selector (Mainnet, Devnet, Testnet). When the validator starts:

1. Items are grouped by cluster
2. The cluster with the most items becomes the primary (`-u` flag)
3. Items from other clusters are pre-fetched via `solana account` / `solana program dump` and loaded via `--account` / `--bpf-program`

### Log viewer

Open via the menu (Cmd+L). Features:
- Live streaming of validator output
- Search/filter bar
- **Hide Slot Noise** toggle — filters repetitive per-slot messages from the viewer (still written to the log file at `~/.config/solmac/logs/validator.log`)

## Configuration

Config lives at `~/.config/solmac/config.json`. Example:

```json
{
  "programs": [
    {
      "id": "...",
      "address": "metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s",
      "label": "Metaplex Token Metadata",
      "cluster": "mainnet-beta",
      "isEnabled": true,
      "isUpgradeable": true
    }
  ],
  "accounts": [
    {
      "id": "...",
      "address": "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
      "label": "Raydium AMM Authority",
      "cluster": "mainnet-beta",
      "isEnabled": true,
      "useMaybeClone": true
    }
  ],
  "ledgerDirectory": "/Users/you/.config/solmac/test-ledger",
  "resetOnStart": true,
  "validatorPath": "",
  "rpcPort": 8899,
  "faucetPort": 9900,
  "gossipPort": 0,
  "additionalArgs": []
}
```

| Field | Description |
|---|---|
| `validatorPath` | Path to `solana-test-validator`. Empty = auto-detect. |
| `ledgerDirectory` | Absolute path for the validator ledger. |
| `resetOnStart` | Pass `--reset` to wipe ledger on each start. |
| `rpcPort` | JSON RPC port (WebSocket on next port). Default: 8899. |
| `faucetPort` | Faucet port. Default: 9900. |
| `gossipPort` | Gossip port. 0 = auto. |
| `additionalArgs` | Extra CLI flags passed to the validator verbatim. |

## File paths

| Path | Purpose |
|---|---|
| `~/.config/solmac/config.json` | Configuration |
| `~/.config/solmac/logs/validator.log` | Full validator log (rotated at 50MB) |
| `~/.config/solmac/cache/accounts/` | Pre-fetched account JSON files |
| `~/.config/solmac/cache/programs/` | Pre-fetched program SO files |
| `~/.config/solmac/test-ledger/` | Default ledger directory |

## Project structure

```
Sources/Solmac/
├── SolmacApp.swift              # Entry point, MenuBarExtra + window scenes
├── Models/
│   ├── ClusterSource.swift      # Cluster enum (mainnet, devnet, testnet)
│   ├── CloneableItem.swift      # CloneableProgram & CloneableAccount
│   ├── SolmacConfig.swift       # Top-level config model
│   ├── ValidatorState.swift     # State machine (stopped/running/error/...)
│   └── ProgramPreset.swift      # Preset library data
├── Services/
│   ├── ConfigManager.swift      # JSON config read/write
│   ├── ValidatorManager.swift   # Process lifecycle (start/stop/monitor)
│   ├── PreFetchService.swift    # Cross-cluster pre-fetching
│   ├── CommandBuilder.swift     # Builds validator CLI arguments
│   ├── LogManager.swift         # File + in-memory log buffer
│   └── ProgramInspector.swift   # On-chain program inspection
├── Views/
│   ├── MenuBarView.swift        # Menu bar dropdown content
│   ├── SettingsWindow.swift     # Tabbed settings window
│   ├── SettingsPresetsTab.swift # Preset program browser
│   ├── SettingsProgramsTab.swift
│   ├── SettingsAccountsTab.swift
│   ├── SettingsGeneralTab.swift
│   ├── ItemEditorSheet.swift    # Add/edit form with auto-inspect
│   └── LogViewerWindow.swift    # Live log viewer
└── Utilities/
    ├── ProcessRunner.swift      # Async Process wrapper
    ├── Constants.swift          # File paths
    └── SolanaIcon.swift         # Solana logo drawn as NSImage
```

## Tech stack

- **Swift 6 / SwiftUI** with `@Observable` (Observation framework)
- **Swift Package Manager** — no Xcode project, builds from CLI
- **Zero external dependencies** — only Foundation and AppKit
- **macOS 14+** (Sonoma) for `MenuBarExtra` and `@Observable`

## License

MIT
