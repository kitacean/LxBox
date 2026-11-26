# L×Box — форк с шифрованием подписок

[![Upstream](https://img.shields.io/badge/Upstream-Leadaxe%2FLxBox-blue)](https://github.com/Leadaxe/LxBox)
[![License](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![Dart](https://img.shields.io/badge/Dart-3.11%2B-blue)](https://dart.dev/)

Приватный форк **[Leadaxe/LxBox](https://github.com/Leadaxe/LxBox)** — Android-клиента VPN и прокси с открытым исходным кодом на базе [sing-box-lx](https://github.com/Leadaxe/sing-box-lx). В этой версии добавлена расшифровка подписок **AES-256-GCM** на стороне клиента и автоматическая отправка собранных APK в закрытый Telegram-канал.

---

## Отличия от оригинала

- **Расшифровка подписок AES-256-GCM (`app/lib/services/subscription/sub_decryptor.dart`)**
  Подписки с префиксом `ENC:` автоматически расшифровываются в `fetchRaw` до парсинга. Ключи не вшиваются в APK, а хранятся в оперативной памяти отдельно для каждой подписки и запрашиваются по мере необходимости. Это позволяет проксировать подписки через сторонние CDN, не раскрывая адреса серверов, UUID и параметры REALITY. Обычные подписки (Base64, списки ссылок, JSON) работают без изменений.
- **Своя подпись и доставка APK в Telegram (`.github/workflows/ci.yml`)**
  Релизные APK подписываются собственным keystore и отправляются напрямую в закрытый Telegram-канал. Сборки не публикуются в GitHub Releases и не сохраняются в артефактах Actions.
- **Автосинхронизация с апстримом (`.github/workflows/sync-upstream.yml`)**
  Workflow в GitHub Actions регулярно подтягивает обновления из `Leadaxe/LxBox` и при появлении новых коммитов запускает сборку `build-fast` (`arm64-v8a`).

---

## Формат зашифрованной подписки

Клиент ожидает текстовый ответ в формате:

```text
ENC:<base64(iv_12_байт + шифртекст + gcm_tag_16_байт)>
```

- **Шифр:** AES-256-GCM (256-битный ключ, случайный 96-битный IV на каждый ответ, 128-битный тег аутентификации)
- **Содержимое:** любой стандартный формат подписки, который поддерживает L×Box (Base64, список URI, JSON, включая комментарии `# profile-title:` и `# subscription-userinfo:`)

---

## Сборка форка

### Необходимые секреты GitHub Actions

Секреты задаются в разделе **Settings → Secrets and variables → Actions**:

| Секрет | Описание |
|--------|----------|
| `TG_BOT_TOKEN` | Токен Telegram-бота от `@BotFather` для отправки собранных APK |
| `TG_CHAT_ID` | ID закрытого Telegram-канала (формат `-100...`), куда бот присылает сборки |
| `ANDROID_KEYSTORE_BASE64` | Файл релизного keystore (`.jks` / PKCS12) в Base64 |
| `ANDROID_KEYSTORE_PASSWORD` | Пароль от keystore |
| `ANDROID_KEY_PASSWORD` | Пароль от ключа подписи |
| `ANDROID_KEY_ALIAS` | Алиас ключа внутри keystore |
| `SYNC_PAT` | Classic Personal Access Token (права `repo` и `workflow`) для `sync-upstream.yml` |

### Ручная сборка

Запустите **Actions → CI → Run workflow** с параметрами `run_mode: build-fast` и `abi: arm64-v8a`. Готовый подписанный APK придёт в закрытый Telegram-канал.

---

## Возможности оригинала и документация

Все базовые протоколы (VLESS REALITY/XHTTP/ML-KEM-768, VMess, Trojan, Shadowsocks, Hysteria2, TUIC v5, AnyTLS, NaïveProxy, WireGuard, AmneziaWG 2.0, Cloudflare WARP / MASQUE, Tailscale), правила маршрутизации, группы DNS, цепочки и диагностика унаследованы от **[Leadaxe/LxBox](https://github.com/Leadaxe/LxBox)**:

- [Руководство пользователя](docs/USER_GUIDE.md)
- [Каталог фич](docs/spec/features/README.md)
- [Поддерживаемые протоколы](docs/PROTOCOLS.md)
- [Архитектура](docs/ARCHITECTURE.md)
- [Безопасность](docs/SECURITY.md)

---

## Лицензия

Форк распространяется под лицензией [GNU General Public License v3.0](LICENSE) оригинальных проектов **L×Box** и **sing-box**.
