import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_log.dart';
import '../parser/engine/decoders.dart' show decodeUtf8Lenient;

typedef _KeyMap = Map<String, String>;

/// Расшифровка кастомных зашифрованных подписок формата:
/// `ENC:<base64(iv_12 + ciphertext + gcm_tag_16)>`
///
/// Ключи хранятся локально в `SharedPreferences` отдельно для каждого URL подписки.
class SubDecryptor {
  static const String _prefix = 'ENC:';
  static const String _prefsKey = 'lxbox_sub_enc_keys_v1';

  static final AesGcm _cipher = AesGcm.with256bits();
  static final RegExp _hex64Re = RegExp(r'^[0-9a-fA-F]{64}$');

  static bool isValidHexKey(String key) => _hex64Re.hasMatch(key.trim());

  static Future<_KeyMap> _loadMap() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
      }
    } catch (e) {
      AppLog.I.warning('[subscription] Failed to read saved encryption keys: $e');
    }
    return {};
  }

  static Future<void> _saveMap(_KeyMap map) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(map));
  }

  static Future<String?> getKeyForUrl(String url) async {
    final normalized = url.trim();
    if (normalized.isEmpty) return null;
    final map = await _loadMap();
    return map[normalized];
  }

  static Future<void> setKeyForUrl(String url, String? hexKey) async {
    final normalizedUrl = url.trim();
    if (normalizedUrl.isEmpty) return;

    final map = await _loadMap();
    final trimmedKey = (hexKey ?? '').trim();

    if (trimmedKey.isEmpty) {
      map.remove(normalizedUrl);
    } else {
      if (!isValidHexKey(trimmedKey)) {
        throw const FormatException('Encryption key must be 64 hex characters');
      }
      map[normalizedUrl] = trimmedKey;
    }

    await _saveMap(map);
  }

  static Future<void> removeKeyForUrl(String url) => setKeyForUrl(url, null);

  static Future<String> decryptIfNeeded(String body, {required String url}) async {
    final trimmed = body.trim();
    if (!trimmed.startsWith(_prefix)) return body;

    final keyHex = await getKeyForUrl(url);
    if (keyHex == null || !isValidHexKey(keyHex)) {
      AppLog.I.warning('[subscription] ENC payload received, but no valid key saved for this URL');
      throw const FormatException('Subscription encryption key is missing or invalid');
    }

    final payloadB64 = trimmed.substring(_prefix.length).replaceAll(RegExp(r'\s+'), '');
    final raw = base64.decode(payloadB64);

    // Минимум: 12 байт IV + 16 байт GCM MAC tag
    if (raw.length < 28) {
      throw const FormatException('Encrypted subscription payload is too short');
    }

    final secretBox = SecretBox.fromConcatenation(
      raw,
      nonceLength: _cipher.nonceLength,
      macLength: _cipher.macAlgorithm.macLength,
    );

    final clearBytes = await _cipher.decrypt(
      secretBox,
      secretKey: SecretKey(_hexToBytes(keyHex.trim())),
    );

    return decodeUtf8Lenient(clearBytes);
  }

  static Uint8List _hexToBytes(String hex) {
    final out = Uint8List(hex.length ~/ 2);
    for (var i = 0; i < out.length; i++) {
      out[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return out;
  }
}
