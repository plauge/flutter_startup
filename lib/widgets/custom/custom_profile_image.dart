import '../../exports.dart';
import '../../utils/image_url_validator.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomProfileImage extends StatelessWidget {
  const CustomProfileImage({
    super.key,
    required this.profileImageProvider,
    required this.handleImageSelection,
    this.radius = 90,
    this.showEdit = true,
  });

  final String? profileImageProvider;
  final Future<void> Function(BuildContext, WidgetRef) handleImageSelection;
  final double radius;
  final bool showEdit;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
            ),
            child: CircleAvatar(
              radius: radius,
              backgroundColor: Colors.grey[300],
              backgroundImage: ImageUrlValidator.isValidImageUrl(profileImageProvider)
                  ? NetworkImage(
                      '${profileImageProvider!}?v=${DateTime.now().millisecondsSinceEpoch}',
                      headers: const {
                        'Cache-Control': 'no-cache',
                      },
                    )
                  : null,
              child: !ImageUrlValidator.isValidImageUrl(profileImageProvider)
                  ? Icon(
                      Icons.person,
                      size: radius * 1.33,
                      color: Colors.grey,
                    )
                  : null,
            ),
          ),
          if (showEdit)
            Positioned(
              bottom: 0,
              right: 0,
              child: Consumer(
                builder: (context, ref, _) => GestureDetector(
                  onTap: () => handleImageSelection(context, ref),
                  child: Container(
                    //padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      'assets/icons/edit_profile_image.svg',
                      width: 40,
                      height: 40,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
// Created on: 2024-06-27 13:50
