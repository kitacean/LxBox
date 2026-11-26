import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import '../app_log.dart';
import '../parser/engine/decoders.dart' show decodeUtf8Lenient;

/// Расшифровка кастомных зашифрованных подписок формата:
/// `ENC:<base64(iv_12 + ciphertext + gcm_tag_16)>`
/// Ключ задаётся при сборке: `--dart-define=SUB_ENC_KEY=<64 hex chars>`
class SubDecryptor {
  static const String _prefix = 'ENC:';
  static const String _keyHex = String.fromEnvironment('SUB_ENC_KEY');

  static final AesGcm _cipher = AesGcm.with256bits();

  static Future<String> decryptIfNeeded(String body) async {
    final trimmed = body.trim();
    if (!trimmed.startsWith(_prefix)) return body;

    if (_keyHex.length != 64) {
      AppLog.I.warning('[subscription] ENC payload received, but SUB_ENC_KEY is not set');
      throw const FormatException('SUB_ENC_KEY is missing or invalid');
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
      secretKey: SecretKey(_hexToBytes(_keyHex)),
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
