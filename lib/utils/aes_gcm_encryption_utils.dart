import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:crypto/crypto.dart';
import 'app_logger.dart';

/*
void main() async {
  // Generér en ny token på 64 tegn
  final token = AESGCMEncryptionUtils.generateSecureToken();
  print("Genereret token: $token");

  final data = "Dette er en testbesked";

  // Kryptering
  final encryptedData = await AESGCMEncryptionUtils.encryptString(data, token);
  print("Krypteret data: $encryptedData");

  // Dekryptering
  final decryptedData =
      await AESGCMEncryptionUtils.decryptString(encryptedData, token);
  print("Dekrypteret tekst: $decryptedData");
}

*/

/// Utility class for AES-GCM encryption and decryption
///
/// Implements secure encryption using:
/// - AES-GCM 256-bit for authenticated encryption
/// - SHA-256 key derivation from secure tokens
/// - Secure random IV generation
/// - 64-character secure tokens
///
/// Usage:
/// ```dart
/// final token = AESGCMEncryptionUtils.generateSecureToken();
/// final encrypted = await AESGCMEncryptionUtils.encryptString("hemmelighed", token);
/// final decrypted = await AESGCMEncryptionUtils.decryptString(encrypted, token);
/// ```
class AESGCMEncryptionUtils {
  static final log = scopedLogger(LogCategory.service);
  static const int _tokenLength = 64;
  static const String _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789@#\$%^&*()-_=+';

  /// Generates a random 64-character secure token
  static String generateSecureToken() {
    final random = Random.secure();
    return List.generate(_tokenLength, (_) => _chars[random.nextInt(_chars.length)]).join();
  }

  /// Generates a random 10-character secure test key
  static String generateSecureTestKey() {
    final random = Random.secure();
    return List.generate(10, (_) => _chars[random.nextInt(_chars.length)]).join();
  }

  /// Generates a random 32-character secure password
  static String generateSecurePassword32() {
    final random = Random.secure();
    return List.generate(32, (_) => _chars[random.nextInt(_chars.length)]).join();
  }

  /// Derives a 256-bit key from a token using SHA-256
  static SecretKey _deriveKey(String token) {
    final tokenBytes = utf8.encode(token);
    final digest = sha256.convert(tokenBytes);
    return SecretKey(digest.bytes);
  }

  /// Encrypts a string using AES-GCM encryption
  /// Returns a string formatted as: base64(iv):base64(ciphertext):base64(mac)
  static Future<String> encryptString(String text, String token) async {
    if (text.isEmpty) {
      throw ArgumentError("Input data må ikke være tom.");
    }
    if (token.length != _tokenLength) {
      throw ArgumentError("Token skal være præcis $_tokenLength tegn lang.");
    }

    final algorithm = AesGcm.with256bits();
    final secretKey = _deriveKey(token);
    final nonce = algorithm.newNonce();

    final plainTextBytes = utf8.encode(text);

    final secretBox = await algorithm.encrypt(
      plainTextBytes,
      secretKey: secretKey,
      nonce: nonce,
    );

    // Format: base64(iv):base64(ciphertext):base64(mac)
    final ivBase64 = base64.encode(secretBox.nonce);
    final ciphertextBase64 = base64.encode(secretBox.cipherText);
    final macBase64 = base64.encode(secretBox.mac.bytes);

    return "$ivBase64:$ciphertextBase64:$macBase64";
  }

  /// Decrypts a string formatted as: base64(iv):base64(ciphertext):base64(mac)
  /// Returns the decrypted string or throws an error if decryption fails
  static Future<String> decryptString(String data, String token) async {
    if (token.length != _tokenLength) {
      throw ArgumentError("Token skal være præcis $_tokenLength tegn lang.");
    }

    try {
      final parts = data.split(':');
      if (parts.length != 3) {
        throw FormatException("Dataformatet er ikke korrekt. Forventet format: iv:ciphertext:mac");
      }

      final ivBytes = base64.decode(parts[0]);
      final ciphertextBytes = base64.decode(parts[1]);
      final macBytes = base64.decode(parts[2]);

      final algorithm = AesGcm.with256bits();
      final secretKey = _deriveKey(token);

      final secretBox = SecretBox(
        ciphertextBytes,
        nonce: ivBytes,
        mac: Mac(macBytes),
      );

      final decryptedBytes = await algorithm.decrypt(
        secretBox,
        secretKey: secretKey,
      );

      return utf8.decode(decryptedBytes);
    } catch (e) {
      log('lib/utils/aes_gcm_encryption_utils.dart - decryptString() - Krypteringsfejl: $e');
      throw Exception("Kryptering fejlede. Kontakt support hvis problemet fortsætter.");
    }
  }
}

// Created on: ${DateTime.now().toIso8601String()}
