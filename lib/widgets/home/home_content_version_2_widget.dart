import '../../exports.dart';

class HomeContentVersion2Widget extends ConsumerWidget {
  static final log = scopedLogger(LogCategory.gui);

  const HomeContentVersion2Widget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Gap(AppDimensionsTheme.getMedium(context)),
        CustomText(
          text: 'Version 2 - Test Content',
          type: CustomTextType.head,
          alignment: CustomTextAlignment.center,
        ),
        Gap(AppDimensionsTheme.getLarge(context)),
        CustomText(
          text: 'This is a test version of the home content widget.',
          type: CustomTextType.bread,
          alignment: CustomTextAlignment.center,
        ),
      ],
    );
  }
}

// Created on 2025-01-16 at 17:30
