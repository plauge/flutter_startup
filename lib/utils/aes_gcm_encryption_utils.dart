import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:pointycastle/export.dart';

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
/// - AES-256 in GCM mode for authenticated encryption
/// - PBKDF2 key derivation with 100,000 iterations
/// - Secure random salt and IV generation
/// - 64-character secure tokens
///
/// Usage:
/// ```dart
/// final token = AESGCMEncryptionUtils.generateSecureToken();
/// final encrypted = await AESGCMEncryptionUtils.encryptString("hemmelighed", token);
/// final decrypted = await AESGCMEncryptionUtils.decryptString(encrypted, token);
/// ```
class AESGCMEncryptionUtils {
  static const int _iterations = 100000;
  static const int _keyLength = 32; // 256-bit key
  static const int _ivLength = 12; // Recommended IV size for GCM
  static const int _saltLength = 16; // Salt for PBKDF2
  static const int _tokenLength = 64; // Add this

  /// Generates a random 64-character secure token
  static String generateSecureToken() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789@#\$%^&*()-_=+';
    final random = Random.secure();
    return List.generate(64, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Derives a 256-bit key from a 64-character token using PBKDF2
  static encrypt.Key _deriveKey(String token, Uint8List salt) {
    final keyDerivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    final params = Pbkdf2Parameters(salt, _iterations, _keyLength);
    keyDerivator.init(params);
    final key = keyDerivator.process(utf8.encode(token));
    return encrypt.Key(key);
  }

  /// Encrypts a string using AES-GCM encryption
  /// Returns a base64 encoded string containing: salt, IV, and encrypted data
  static Future<String> encryptString(String inputData, String token) async {
    if (inputData.isEmpty) {
      throw ArgumentError("Input data må ikke være tom.");
    }
    if (token.length != _tokenLength) {
      throw ArgumentError("Token skal være præcis $_tokenLength tegn lang.");
    }

    final plainText = utf8.encode(inputData);

    // Generate random salt and IV
    final salt = _generateSecureRandom(_saltLength);
    final iv = encrypt.IV.fromSecureRandom(_ivLength);

    // Derive key from token and salt
    final key = _deriveKey(token, salt);

    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.gcm),
    );

    final encrypted = encrypter.encryptBytes(plainText, iv: iv);

    // Return Base64 encoded salt, IV, and encrypted data
    final base64EncodedSalt = base64.encode(salt);
    final base64EncodedIV = base64.encode(iv.bytes);
    final base64EncodedData = encrypted.base64;

    return "$base64EncodedSalt:$base64EncodedIV:$base64EncodedData";
  }

  /// Decrypts a base64 encoded string containing: salt, IV, and encrypted data
  /// Returns the decrypted string or throws an error if decryption fails
  static Future<String> decryptString(String encodedData, String token) async {
    if (token.length != 64) {
      throw ArgumentError("Token skal være præcis 64 tegn lang.");
    }

    try {
      final parts = encodedData.split(':');
      if (parts.length != 3) {
        throw FormatException("Dataformatet er ikke korrekt.");
      }

      final salt = base64.decode(parts[0]);
      final iv = encrypt.IV.fromBase64(parts[1]);
      final encryptedData = encrypt.Encrypted.fromBase64(parts[2]);

      // Derive key from token and salt
      final key = _deriveKey(token, salt);

      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.gcm),
      );

      final decrypted = encrypter.decryptBytes(encryptedData, iv: iv);
      return utf8.decode(decrypted);
    } catch (e) {
      print('Krypteringsfejl: $e');
      throw Exception(
          "Kryptering fejlede. Kontakt support hvis problemet fortsætter.");
    }
  }

  /// Helper function to generate a secure random byte array
  static Uint8List _generateSecureRandom(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
        List.generate(length, (_) => random.nextInt(256)));
  }
}
