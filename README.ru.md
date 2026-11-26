# L×Box — форк с шифрованием подписок

[![Upstream](https://img.shields.io/badge/Upstream-Leadaxe%2FLxBox-blue)](https://github.com/Leadaxe/LxBox)
[![License](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![Dart](https://img.shields.io/badge/Dart-3.11%2B-blue)](https://dart.dev/)

Личный форк **[Leadaxe/LxBox](https://github.com/Leadaxe/LxBox)** — открытого Android-клиента VPN и прокси на базе [sing-box-lx](https://github.com/Leadaxe/sing-box-lx), дополненный прозрачной расшифровкой подписок в **AES-256-GCM** на стороне клиента и автоматической сборкой релизов.

---

## Отличия от оригинала

- **Расшифровка подписок AES-256-GCM (`app/lib/services/subscription/sub_decryptor.dart`)**
  Подписки с префиксом `ENC:` автоматически расшифровываются внутри `fetchRaw` до парсинга. Это позволяет отдавать ссылки подписок через сторонние CDN, не раскрывая адреса серверов, UUID или параметры REALITY в открытом виде. Обычные незашифрованные подписки (Base64, списки ссылок, Xray/sing-box JSON) продолжают работать как раньше.
- **Своя подпись и проброс ключа в CI (`.github/workflows/ci.yml`)**
  Релизные APK собираются с флагом `--dart-define=SUB_ENC_KEY=...` и подписываются личным хранилищем ключей, чтобы обновления ставились поверх прошлых сборок без переустановки.
- **Автосинхронизация с апстримом и публикация релизов (`.github/workflows/sync-upstream.yml`)**
  Ежедневная задача GitHub Actions подтягивает обновления из `Leadaxe/LxBox`, при появлении новых коммитов запускает сборку `build-fast` (`arm64-v8a`) и выкладывает готовый APK в **Releases**.

---

## Формат зашифрованной подписки

Клиент ждёт ответ в виде обычного текста формата:

```text
ENC:<base64(iv_12_байт + шифртекст + gcm_tag_16_байт)>
```

- **Шифр:** AES-256-GCM (256-битный ключ, случайный 96-битный IV на каждый ответ, 128-битный тег аутентификации)
- **Открытый текст:** любой стандартный формат подписки, поддерживаемый L×Box (Base64, список URI, JSON, включая inline-комментарии `# profile-title:` / `# subscription-userinfo:`)

---

## Сборка этого форка

### Нужные секреты GitHub Actions

Добавь их в разделе **Settings → Secrets and variables → Actions**:

| Секрет | Описание |
|--------|----------|
| `SUB_ENC_KEY` | 64-символьная hex-строка (32-байтный ключ AES-256, например `openssl rand -hex 32`) |
| `ANDROID_KEYSTORE_BASE64` | Хранилище ключей релиза (`.jks` / PKCS12) в формате Base64 |
| `ANDROID_KEYSTORE_PASSWORD` | Пароль от хранилища ключей |
| `ANDROID_KEY_PASSWORD` | Пароль от ключа |
| `ANDROID_KEY_ALIAS` | Алиас ключа внутри хранилища |
| `SYNC_PAT` | Classic Personal Access Token (права `repo` и `workflow`) для `sync-upstream.yml` |

### Ручная сборка

Запусти **Actions → CI → Run workflow** с параметрами `run_mode: build-fast` и `abi: arm64-v8a`. Подписанный APK появится в разделе **Releases**.

---

## Возможности оригинала и документация

Все базовые протоколы (VLESS REALITY/XHTTP/ML-KEM-768, VMess, Trojan, Shadowsocks, Hysteria2, TUIC v5, AnyTLS, NaïveProxy, WireGuard, AmneziaWG 2.0, Cloudflare WARP / MASQUE, Tailscale), правила маршрутизации, группы DNS, цепочки и диагностика взяты из оригинального **[Leadaxe/LxBox](https://github.com/Leadaxe/LxBox)**:

- [Руководство пользователя](docs/USER_GUIDE.md)
- [Каталог фич](docs/spec/features/README.md)
- [Поддерживаемые протоколы](docs/PROTOCOLS.md)
- [Архитектура](docs/ARCHITECTURE.md)
- [Безопасность](docs/SECURITY.md)

---

## Лицензия

В этом форке сохранена лицензия [GNU General Public License v3.0](LICENSE) оригинальных проектов **L×Box** и **sing-box**.
