import 'package:just_audio/just_audio.dart';
import 'package:vibration/vibration.dart';
import 'dart:developer' as developer;

class AudioHandler {
  static Future<void> playConfirmedSound() async {
    try {
      developer.log('Forsøger at afspille confirmed lyd med ny metode',
          name: 'AudioHandler');

      // Opret en helt ny player til hver afspilning for at undgå caching-problemer
      final AudioPlayer tempPlayer = AudioPlayer();

      developer.log('Ny AudioPlayer oprettet til confirmed lyd',
          name: 'AudioHandler');

      await tempPlayer.setAsset('assets/sounds/confirmed.mp3');
      await tempPlayer.setVolume(1.0);

      developer.log('Confirmed lyd indlæst, forsøger at afspille',
          name: 'AudioHandler');

      await tempPlayer.play();

      developer.log('Confirmed lyd afspilning startet!', name: 'AudioHandler');

      // Opret en timer til at rydde op i spilleren
      Future.delayed(const Duration(seconds: 3), () {
        tempPlayer.dispose();
        developer.log('Temporary confirmed player disposed',
            name: 'AudioHandler');
      });
    } catch (e) {
      developer.log('Fejl ved afspilning af confirmed lyd: $e',
          name: 'AudioHandler');
    }
  }

  static Future<void> playAlertSound() async {
    try {
      developer.log('=================== ALERT SOUND START ===================',
          name: 'AudioHandler');

      // Opret en helt ny player til hver afspilning for at undgå caching-problemer
      final AudioPlayer tempPlayer = AudioPlayer();

      developer.log('Ny AudioPlayer oprettet til alert lyd',
          name: 'AudioHandler');

      await tempPlayer.setAsset('assets/sounds/alert.mp3');
      await tempPlayer.setVolume(1.0);

      developer.log('Alert lyd indlæst, forsøger at afspille',
          name: 'AudioHandler');

      // Tjek om enheden har en vibrator
      final bool hasVibrator = await Vibration.hasVibrator() ?? false;
      developer.log('Telefonen har vibrator: $hasVibrator',
          name: 'AudioHandler');

      // Afspil vibration sammen med lyden - brug en dramatisk notifikation
      if (hasVibrator) {
        developer.log('Starter vibration nu...', name: 'AudioHandler');

        try {
          Vibration.vibrate(
            pattern: [0, 500, 100, 500, 100, 500],
            intensities: [0, 255, 0, 255, 0, 255], // Fuld intensitet
          );
          developer.log('Vibration metode kaldt uden fejl',
              name: 'AudioHandler');
        } catch (vibrationError) {
          developer.log('Fejl ved vibration: $vibrationError',
              name: 'AudioHandler');
        }

        developer.log('Vibration afspillet', name: 'AudioHandler');
      } else {
        developer.log('Telefonen har ikke vibrator eller tilladelse mangler',
            name: 'AudioHandler');
      }

      await tempPlayer.play();

      developer.log('Alert lyd afspilning startet!', name: 'AudioHandler');

      // Opret en timer til at rydde op i spilleren
      Future.delayed(const Duration(seconds: 3), () {
        tempPlayer.dispose();
        developer.log('Temporary alert player disposed', name: 'AudioHandler');
      });

      developer.log('=================== ALERT SOUND END ===================',
          name: 'AudioHandler');
    } catch (e) {
      developer.log('Fejl ved afspilning af alert lyd: $e',
          name: 'AudioHandler');
    }
  }
}
