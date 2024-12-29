import '../../exports.dart';

class CheckEmail extends StatelessWidget {
  const CheckEmail({super.key});

  @override
  Widget build(BuildContext context) {
    return AppTheme.getParentContainerStyle(context).applyToContainer(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Tjek din email',
                style: AppTheme.getHeadingLarge(context),
                textAlign: TextAlign.center,
              ),
              Gap(AppDimensionsTheme.getMedium(context)),
              Text(
                'Vi har sendt dig en bekræftelses email. Klik på linket i emailen for at bekræfte din konto.',
                style: AppTheme.getBodyMedium(context),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
