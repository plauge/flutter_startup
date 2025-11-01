import '../../exports.dart';
import '../text_code/custom_text_code_search_widget.dart';
import '../../../widgets/phone_code/phone_code_content_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeContentVersion2Widget extends ConsumerWidget {
  static final log = scopedLogger(LogCategory.gui);

  const HomeContentVersion2Widget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SvgPicture.asset(
          'assets/images/id-truster-badge.svg',
          height: 80,
        ),
        Gap(AppDimensionsTheme.getLarge(context)),
        CustomTextCodeSearchWidget(),
        const PhoneCodeContentWidget()
      ],
    );
  }
}

// Created on 2025-01-16 at 17:30
