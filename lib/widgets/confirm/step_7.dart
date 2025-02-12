import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/confirm_state.dart';
import '../../widgets/custom/custom_button.dart';
import '../../widgets/custom/custom_text.dart';

class Step7Widget extends StatelessWidget {
  final Map<String, dynamic> rawData;
  final Function(ConfirmState, Map<String, dynamic>?) onStateChange;

  const Step7Widget({
    super.key,
    required this.rawData,
    required this.onStateChange,
  });

  void _handleTryAgain() {
    onStateChange(ConfirmState.initial, null);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CustomText(
            text: 'Gennemført!',
            type: CustomTextType.head,
            alignment: CustomTextAlignment.center,
          ),
          const SizedBox(height: 20),
          CustomButton(
            onPressed: _handleTryAgain,
            text: 'Prøv igen',
          ),
        ],
      ),
    );
  }
}
