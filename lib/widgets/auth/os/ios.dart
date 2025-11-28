import '../../../exports.dart';

class IOSWidget extends StatelessWidget {
  const IOSWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final appStatusAsync = ref.watch(securityAppStatusProvider);
        final appStatus = appStatusAsync.value;

        final appVersionInt = AppVersionConstants.appVersionInt;
        final minimumRequiredVersion = appStatus?.data.payload.minimumRequiredVersion ?? 0;
        // ignore: unused_local_variable
        final shouldSwapOrder = appVersionInt > minimumRequiredVersion;

        return Column(
          children: [
            const CustomText(
              text: 'IOS',
              type: CustomTextType.head,
              alignment: CustomTextAlignment.center,
            ),
          ],
        );
      },
    );
  }
}

// File created: 2025-01-27
