# L×Box — Encrypted Subscriptions Fork

[![Upstream](https://img.shields.io/badge/Upstream-Leadaxe%2FLxBox-blue)](https://github.com/Leadaxe/LxBox)
[![License](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![Dart](https://img.shields.io/badge/Dart-3.11%2B-blue)](https://dart.dev/)

A personal fork of **[Leadaxe/LxBox](https://github.com/Leadaxe/LxBox)** — the open-source Android VPN and proxy client powered by [sing-box-lx](https://github.com/Leadaxe/sing-box-lx) — extended with transparent client-side decryption for **AES-256-GCM encrypted subscriptions** and automated release builds.

---

## What's different from upstream

- **AES-256-GCM subscription decryption (`app/lib/services/subscription/sub_decryptor.dart`)**
  Subscriptions prefixed with `ENC:` are automatically decrypted inside `fetchRaw` before parsing. This allows serving subscription endpoints through third-party CDNs without exposing server addresses, UUIDs, or REALITY parameters in plaintext. Standard unencrypted subscriptions (Base64, URI lists, Xray/sing-box JSON) continue to work unchanged.
- **Custom signing & CI key injection (`.github/workflows/ci.yml`)**
  Release APKs are built with `--dart-define=SUB_ENC_KEY=...` and signed with a personal keystore so updates install cleanly over previous builds.
- **Automated upstream sync & releases (`.github/workflows/sync-upstream.yml`)**
  A daily GitHub Actions job pulls updates from `Leadaxe/LxBox`, triggers a `build-fast` (`arm64-v8a`) APK build when new commits arrive, and publishes the APK directly to **Releases**.

---

## Encrypted subscription format

The client expects a plain-text response formatted as:

```text
ENC:<base64(iv_12_bytes + ciphertext + gcm_tag_16_bytes)>
```

- **Cipher:** AES-256-GCM (256-bit key, 96-bit random IV per response, 128-bit authentication tag)
- **Plaintext:** Any standard subscription format supported by L×Box (Base64, URI list, JSON, including inline `# profile-title:` / `# subscription-userinfo:` comments)

---

## Building this fork

### Required GitHub Actions Secrets

Configure these under **Settings → Secrets and variables → Actions**:

| Secret | Description |
|--------|-------------|
| `SUB_ENC_KEY` | 64-character hex string (32-byte AES-256 key, e.g. `openssl rand -hex 32`) |
| `ANDROID_KEYSTORE_BASE64` | Base64-encoded `.jks` / PKCS12 release keystore |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password |
| `ANDROID_KEY_PASSWORD` | Key password |
| `ANDROID_KEY_ALIAS` | Key alias inside the keystore |
| `SYNC_PAT` | Classic Personal Access Token (`repo` + `workflow` scopes) for `sync-upstream.yml` |

### Manual build

Run **Actions → CI → Run workflow** with `run_mode: build-fast` and `abi: arm64-v8a`. The signed APK will be published under **Releases**.

---

## Upstream features & documentation

All core protocols (VLESS REALITY/XHTTP/ML-KEM-768, VMess, Trojan, Shadowsocks, Hysteria2, TUIC v5, AnyTLS, NaïveProxy, WireGuard, AmneziaWG 2.0, Cloudflare WARP / MASQUE, Tailscale), routing rules, DNS groups, chains, and diagnostics come from upstream **[Leadaxe/LxBox](https://github.com/Leadaxe/LxBox)**:

- [User Guide](docs/USER_GUIDE.md)
- [Feature Catalogue](docs/spec/features/README.md)
- [Supported Protocols](docs/PROTOCOLS.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Security](docs/SECURITY.md)

---

## License

This fork retains the [GNU General Public License v3.0](LICENSE) of upstream **L×Box** and **sing-box**.
