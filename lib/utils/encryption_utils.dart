import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:convert';

/// Utility class for handling AES encryption and decryption
class EncryptionUtils {
  /// Encrypts a string using AES encryption
  /// Returns a base64 encoded string containing both IV and encrypted data
  static Future<String> encryptString(String inputData, String inputKey) async {
    final plainText = inputData.codeUnits;
    final iv = encrypt.IV.fromSecureRandom(16);
    final key = encrypt.Key.fromUtf8(inputKey.padRight(32));
    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc),
    );

    final encrypted = encrypter.encryptBytes(plainText, iv: iv);
    final base64EncodedData = encrypted.base64;
    final base64EncodedIV = base64.encode(iv.bytes);
    return "$base64EncodedIV:$base64EncodedData";
  }

  /// Decrypts a base64 encoded string that contains both IV and encrypted data
  /// Returns the decrypted string or 'error' if decryption fails
  static Future<String> decryptString(
    String base64EncodedDataWithIV,
    String inputKey,
  ) async {
    try {
      final parts = base64EncodedDataWithIV.split(':');
      final iv = encrypt.IV.fromBase64(parts[0]);
      final encryptedData = encrypt.Encrypted.fromBase64(parts[1]);

      final key = encrypt.Key.fromUtf8(inputKey.padRight(32));
      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc),
      );

      final decrypted = encrypter.decryptBytes(encryptedData, iv: iv);
      return String.fromCharCodes(decrypted);
    } catch (e) {
      print('Decryption error: $e');
      return 'error';
    }
  }
}
