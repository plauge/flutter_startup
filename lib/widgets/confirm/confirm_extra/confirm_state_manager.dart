/// Håndterer tilstandsændringer i bekræftelsesprocessen.
///
/// Denne fil indeholder funktionalitet til at håndtere ændringer i bekræftelsestilstanden
/// baseret på data modtaget fra serveren.

import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../../../models/confirm_state.dart';
import '../../../models/confirm_payload.dart';

/// En klasse til at håndtere tilstandsændringer i bekræftelsesprocessen
class ConfirmStateManager {
  /// Behandler tilstandsændringer baseret på data modtaget fra serveren
  ///
  /// Returnerer et map med den nye tilstand, bekræftelsesdata og eventuel fejlbesked
  static Map<String, dynamic> handleStateChange({
    required ConfirmState newState,
    required Map<String, dynamic>? data,
    required String contactId,
    ConfirmPayload? currentConfirmData,
    String answerString = '',
  }) {
    debugPrint('🔍 handleStateChange called with state: $newState');
    debugPrint('🔍 Raw data received: $data');
    debugPrint('🔍 Answer string: $answerString');

    ConfirmState resultState = newState;
    ConfirmPayload? resultConfirmData = currentConfirmData;
    String? errorMessage;
    bool currentStateIsSet = false;

    if (data != null) {
      try {
        // Hvis det er en error, så skal vi udskrive errorMessage
        if (data['status_code'] == null || data['status_code'] != 200) {
          debugPrint('🔍 🇩🇰🔍 🇩🇰🔍 🇩🇰🔍 🇩🇰 Error data: $data');
          resultState = ConfirmState.error;
          errorMessage =
              data['message'] == null || data['message'].toString().isEmpty
                  ? 'Der skete en fejl du'
                  : data['message'];
          return {
            'state': resultState,
            'confirmData': resultConfirmData,
            'errorMessage': errorMessage,
          };
        }

        // Udpak payload fra response
        if (data['data'] != null && data['data']['payload'] != null) {
          final payload = data['data']['payload'] as Map<String, dynamic>;
          debugPrint('🔍 Extracted payload: $payload');

          final Map<String, dynamic> confirmData = {
            'confirms_id': payload['confirms_id'],
            'created_at': DateTime.now().toIso8601String(),
            'status': payload['status'],
            'contacts_id': contactId,
            'question': payload['question'] ?? '',
          };

          // Tilføj de ekstra data fra StepWatchWidget hvis de findes
          if (payload.containsKey('receiver_status')) {
            confirmData['receiver_status'] = payload['receiver_status'];
          }
          if (payload.containsKey('initiator_status')) {
            confirmData['initiator_status'] = payload['initiator_status'];
          }
          if (payload.containsKey('receiver_user_id')) {
            confirmData['receiver_user_id'] = payload['receiver_user_id'];
          }
          if (payload.containsKey('initiator_user_id')) {
            confirmData['initiator_user_id'] = payload['initiator_user_id'];
          }
          if (payload.containsKey('encrypted_receiver_answer')) {
            confirmData['encrypted_receiver_answer'] =
                payload['encrypted_receiver_answer'];
          }
          if (payload.containsKey('encrypted_initiator_answer')) {
            confirmData['encrypted_initiator_answer'] =
                payload['encrypted_initiator_answer'];
          }
          if (payload.containsKey('encrypted_receiver_question')) {
            confirmData['encrypted_receiver_question'] =
                payload['encrypted_receiver_question'];
          }
          if (payload.containsKey('encrypted_initiator_question')) {
            confirmData['encrypted_initiator_question'] =
                payload['encrypted_initiator_question'];
          }

          developer.log(
            'Ekstra confirm data tilføjet: ${confirmData.keys.where((key) => key.startsWith('encrypted_') || key.endsWith('_status') || key.endsWith('_user_id')).toList()}',
            name: 'ConfirmStateManager',
          );

          // Vis mig eksempel her på hvordan jeg kan teset de 4 variabler.

          // Test af de 4 krypterede variabler
          developer.log('Test af krypterede variabler fra payload:',
              name: 'ConfirmTest');
          developer.log(
              'encrypted_receiver_answer: ${payload['encrypted_receiver_answer']}',
              name: 'ConfirmTest');
          developer.log(
              'encrypted_initiator_answer: ${payload['encrypted_initiator_answer']}',
              name: 'ConfirmTest');
          developer.log(
              'encrypted_receiver_question: ${payload['encrypted_receiver_question']}',
              name: 'ConfirmTest');
          developer.log(
              'encrypted_initiator_question: ${payload['encrypted_initiator_question']}',
              name: 'ConfirmTest');

          // Eksempel på test af værdierne
          if (payload['encrypted_initiator_question'] == '957,315') {
            developer.log(
                '✅ encrypted_initiator_question har korrekt værdi: 957,315',
                name: 'ConfirmTest');
          } else {
            developer.log(
                '❌ encrypted_initiator_question har ikke den forventede værdi',
                name: 'ConfirmTest');
          }

          // Kun sæt new_record hvis den er med i payload
          if (payload.containsKey('new_record')) {
            confirmData['new_record'] = payload['new_record'];
          } else if (currentConfirmData != null) {
            // Behold eksisterende værdi hvis den findes
            confirmData['new_record'] = currentConfirmData.newRecord;
          }
          // Ellers bruges default værdien fra modellen (false)

          debugPrint('🔍 Prepared data for ConfirmPayload: $confirmData');
          resultConfirmData = ConfirmPayload.fromJson(confirmData);
          debugPrint(
              '🔍 Successfully created ConfirmPayload: $resultConfirmData');
          debugPrint('🔍 new_record value: ${resultConfirmData?.newRecord}');

          // Her!
          debugPrint('🔍 🔍 🔍 🔍 TEST VALUES: 🔍 🔍 🔍 🔍');
          debugPrint('🔍 Status: ${resultConfirmData?.status}');
          debugPrint('🔍 New Record: ${resultConfirmData?.newRecord}');
          debugPrint('🔍 Full confirmData: ${resultConfirmData?.toJson()}');
          debugPrint(
              '🔍 encryptedInitiatorAnswer: ${resultConfirmData?.encryptedInitiatorAnswer}');

          if (resultConfirmData?.newRecord == true) {
            debugPrint('🔍 newRecord == true');
            if (resultConfirmData?.status == 1) {
              debugPrint('🔍 resultConfirmData?.status == 1');
              resultState = ConfirmState.watch;
              currentStateIsSet = true;
            }

            if (resultConfirmData?.status == 2) {
              debugPrint('🔍 resultConfirmData?.status == 2');
              resultState = ConfirmState.watch;
              currentStateIsSet = true;
            }

            if (resultConfirmData?.status == 3) {
              // Svar: confirms_initiator_update
              debugPrint('🔍>>>>>> resultConfirmData?.status == 3');
              debugPrint('🔍>>>>>> answerString: $answerString');
              debugPrint(
                  '🔍>>>>>> resultConfirmData?.encryptedReceiverAnswer: ${resultConfirmData?.encryptedReceiverAnswer}');
              if (resultConfirmData?.encryptedInitiatorAnswer == answerString) {
                resultState = ConfirmState.step_4;
              } else {
                //resultState = ConfirmState.fraud;
                resultState = ConfirmState.step_4;
              }
              currentStateIsSet = true;
            }

            if (resultConfirmData?.status == 4) {
              debugPrint('🔍 resultConfirmData?.status == 4');
              resultState = ConfirmState.step_5;
              currentStateIsSet = true;
            }

            if (resultConfirmData?.status == 5) {
              debugPrint('🔍 resultConfirmData?.status == 5');
              resultState = ConfirmState.watch;
              currentStateIsSet = true;
            }
            if (resultConfirmData?.status == 6) {
              debugPrint('🔍 resultConfirmData?.status == 6');
              resultState = ConfirmState.step_7;
              currentStateIsSet = true;
            }
          } else {
            debugPrint('🔍 newRecord == false');
            if (resultConfirmData?.status == 2) {
              debugPrint('🔍 resultConfirmData?.status == 2');
              resultState = ConfirmState.step_3;
              currentStateIsSet = true;
            }

            if (resultConfirmData?.status == 3) {
              // Svar: confirms_reciever_update
              debugPrint('❤️❤️🇩🇰❤️❤️ resultConfirmData?.status == 3');
              resultState = ConfirmState.watch;
              currentStateIsSet = true;
            }

            if (resultConfirmData?.status == 4) {
              debugPrint('❤️❤️🇩🇰❤️❤️ resultConfirmData?.status == 4');
              resultState = ConfirmState.watch;
              currentStateIsSet = true;

              //resultState = ConfirmState.fraud;
            }
            if (resultConfirmData?.status == 5) {
              debugPrint('❤️❤️🇩🇰❤️❤️ resultConfirmData?.status == 5');
              resultState = ConfirmState.step_6;
              currentStateIsSet = true;
            }
            if (resultConfirmData?.status == 6) {
              debugPrint('🔍 resultConfirmData?.status == 6');
              resultState = ConfirmState.step_7;
              currentStateIsSet = true;
            }
          }

          // Hvis tilstanden ikke er sat, så er der sket en fejl
          if (!currentStateIsSet) {
            debugPrint(
                '🔍 Unexpected state combination - Status: ${resultConfirmData?.status}, New Record: ${resultConfirmData?.newRecord}');
            resultState = ConfirmState.error;
            errorMessage = 'Uventet tilstand';
          }
        } else {
          throw Exception('Mangler payload data i svaret fra serveren');
        }
      } catch (e, stackTrace) {
        debugPrint('❌ Error creating ConfirmPayload: $e');
        debugPrint('❌ Stack trace: $stackTrace');
        resultState = ConfirmState.error;
        errorMessage = 'Kunne ikke behandle data: $e';
      }
    } else {
      debugPrint('❌ No data received, setting confirmData to null');
      resultConfirmData = null;
    }

    debugPrint('🔍 Final state: $resultState');
    debugPrint('🔍 Final confirmData: $resultConfirmData');
    debugPrint('🔍 Final new_record value: ${resultConfirmData?.newRecord}');
    debugPrint('🔍 Final errorMessage: $errorMessage');

    return {
      'state': resultState,
      'confirmData': resultConfirmData,
      'errorMessage': errorMessage,
    };
  }
}
