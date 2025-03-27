import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import '../utils/state_handler.dart';
import '../../../../../models/confirm_state.dart';

class InitButton extends ConsumerWidget {
  final VoidCallback onSwipe;
  final ValueChanged<String>? onStateChange;
  final Function(ConfirmState, Map<String, dynamic>?)? onConfirmStateChange;
  final String? contactId;
  final String question;

  const InitButton({
    Key? key,
    required this.onSwipe,
    required this.question,
    this.onStateChange,
    this.onConfirmStateChange,
    this.contactId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SwipeButton(
      thumbPadding: const EdgeInsets.all(3),
      thumb: SvgPicture.asset(
        'assets/images/confirmation/swipe.svg',
        width: 40,
        height: 40,
      ),
      height: 60,
      borderRadius: BorderRadius.circular(30),
      elevationThumb: 2,
      elevationTrack: 2,
      activeThumbColor: Colors.white,
      activeTrackColor: const Color(0xFF014459),
      child: Text(
        "Swipe to confirm",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      onSwipe: () {
        // Notify parent about swipe
        onSwipe();

        // Handle confirmation process
        if (onConfirmStateChange != null) {
          StateHandler.handleConfirm(
            ref: ref,
            contactId: contactId,
            question: question,
            onConfirmStateChange: onConfirmStateChange!,
          );
        }

        // Suggest state change to initPost
        if (onStateChange != null) {
          developer.log('Swipe detected, requesting state change to initPost',
              name: 'InitButton');
          onStateChange!('initPost');
        }
      },
    );
  }
}
