# TrollHelper OTA Builder

Build TrollHelper installer IPAs for OTA installation using the CoreTrust bug.

## What's included

- `TrollHelper_iOS15.ipa` — arm64 (A8-A11), iOS 14.0-15.6.1
- `TrollHelper_arm64e.ipa` — arm64e (A12+), iOS 14.0-15.6.1

## Prerequisites

You need to provide `Victim/InstallerVictim.ipa` — this is the Tips.app extracted from an iOS IPSW.

### How to get InstallerVictim.ipa

1. Download an IPSW from ipsw.me (any iOS 14-16 device)
2. Extract IPSW (it's a zip file)
3. Find the largest DMG inside
4. Extract DMG with 7z: `7z x largest.dmg`
5. Find Applications/Tips.app
6. Package: `mkdir -p Payload && cp -r Tips.app Payload/ && zip -r InstallerVictim.ipa Payload/`

## Files

| File | Description |
|------|-------------|
| `scripts/pwnify.py` | Pure Python pwnify replacement (Mach-O FAT manipulation) |
| `scripts/generate_victim_cert.sh` | Generate victim.p12 signing certificate |
| `helpers/` | Compiled TrollStorePersistenceHelper binaries |
| `Victim/InstallerVictim.ipa` | Victim IPA (Tips.app, NOT included due to licensing) |
| `Victim/victim.p12` | Pre-generated signing certificate |
