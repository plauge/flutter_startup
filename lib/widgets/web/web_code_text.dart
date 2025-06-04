import 'package:flutter/material.dart';
import '../../../exports.dart';

class WebCodeText extends StatelessWidget {
  const WebCodeText({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomText(
          text: 'Test a website og shop',
          type: CustomTextType.head,
        ),
        const Gap(16),
        CustomText(
          text: 'Dette er en test',
          type: CustomTextType.bread,
        ),
        const Gap(24),
        CustomButton(
          onPressed: () {
            // Functionality will be added later
          },
          text: 'Click to insert code',
          buttonType: CustomButtonType.primary,
        ),
      ],
    );
  }
}

// Created: 2023-10-02 16:45:00
