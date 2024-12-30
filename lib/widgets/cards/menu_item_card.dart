import '../../exports.dart';

class MenuItemCard extends StatelessWidget {
  const MenuItemCard({
    super.key,
    required this.onTap,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final VoidCallback onTap;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
              decoration: BoxDecoration(
                color: AppColors.primaryColor(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 40,
                color: AppColors.primaryColor(context),
              ),
            ),
            Gap(AppDimensionsTheme.getMedium(context)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.getHeadingMedium(context),
                  ),
                  Gap(AppDimensionsTheme.getSmall(context)),
                  Text(
                    subtitle,
                    style: AppTheme.getBodyMedium(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
