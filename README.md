# L×Box — Encrypted Subscriptions Fork

[![Upstream](https://img.shields.io/badge/Upstream-Leadaxe%2FLxBox-blue)](https://github.com/Leadaxe/LxBox)
[![License](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![Dart](https://img.shields.io/badge/Dart-3.11%2B-blue)](https://dart.dev/)

A private fork of **[Leadaxe/LxBox](https://github.com/Leadaxe/LxBox)** — an open-source Android VPN and proxy client powered by [sing-box-lx](https://github.com/Leadaxe/sing-box-lx). This version adds client-side **AES-256-GCM** subscription decryption and automated APK delivery to a private Telegram channel.

---

## What's different from upstream

- **AES-256-GCM subscription decryption (`app/lib/services/subscription/sub_decryptor.dart`)**
  Subscriptions prefixed with `ENC:` are automatically decrypted in `fetchRaw` before parsing. Keys are never hardcoded into the APK; instead, they are kept in memory per subscription and prompted when needed. This allows proxying subscriptions through third-party CDNs without exposing server addresses, UUIDs, or REALITY parameters. Standard subscriptions (Base64, URI lists, JSON) work unchanged.
- **Custom signing & Telegram APK delivery (`.github/workflows/ci.yml`)**
  Release APKs are signed with a personal keystore and sent directly to a private Telegram channel. Builds are neither published to GitHub Releases nor retained in GitHub Actions artifacts.
- **Automated upstream sync (`.github/workflows/sync-upstream.yml`)**
  A GitHub Actions workflow regularly pulls updates from `Leadaxe/LxBox` and triggers a `build-fast` (`arm64-v8a`) build whenever new commits arrive.

---

## Encrypted subscription format

The client expects a plain-text response formatted as:

```text
ENC:<base64(iv_12_bytes + ciphertext + gcm_tag_16_bytes)>
```

- **Cipher:** AES-256-GCM (256-bit key, random 96-bit IV per response, 128-bit authentication tag)
- **Payload:** Any standard subscription format supported by L×Box (Base64, URI list, JSON, including `# profile-title:` and `# subscription-userinfo:` comments)

---

## Building this fork

### Required GitHub Actions Secrets

Configure these under **Settings → Secrets and variables → Actions**:

| Secret | Description |
|--------|-------------|
| `TG_BOT_TOKEN` | Telegram bot token from `@BotFather` used to send built APKs |
| `TG_CHAT_ID` | Private Telegram channel ID (`-100...`) where the bot posts builds |
| `ANDROID_KEYSTORE_BASE64` | Base64-encoded release keystore (`.jks` / PKCS12) |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password |
| `ANDROID_KEY_PASSWORD` | Signing key password |
| `ANDROID_KEY_ALIAS` | Key alias inside the keystore |
| `SYNC_PAT` | Classic Personal Access Token (`repo` and `workflow` scopes) for `sync-upstream.yml` |

### Manual build

Run **Actions → CI → Run workflow** with `run_mode: build-fast` and `abi: arm64-v8a`. The signed APK will be delivered to your private Telegram channel.

---

## Upstream features & documentation

All core protocols (VLESS REALITY/XHTTP/ML-KEM-768, VMess, Trojan, Shadowsocks, Hysteria2, TUIC v5, AnyTLS, NaïveProxy, WireGuard, AmneziaWG 2.0, Cloudflare WARP / MASQUE, Tailscale), routing rules, DNS groups, chains, and diagnostics are inherited from **[Leadaxe/LxBox](https://github.com/Leadaxe/LxBox)**:

- [User Guide](docs/USER_GUIDE.md)
- [Feature Catalogue](docs/spec/features/README.md)
- [Supported Protocols](docs/PROTOCOLS.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Security](docs/SECURITY.md)

---

## License

This fork is distributed under the [GNU General Public License v3.0](LICENSE) of upstream **L×Box** and **sing-box**.
