import '../../exports.dart';

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
                width: 7,
              ),
            ),
            child: CircleAvatar(
              radius: radius,
              backgroundColor: Colors.grey[300],
              backgroundImage: profileImageProvider != null
                  ? NetworkImage(
                      '${profileImageProvider!}?v=${DateTime.now().millisecondsSinceEpoch}',
                      headers: const {
                        'Cache-Control': 'no-cache',
                      },
                    )
                  : null,
              child: profileImageProvider == null
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
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 20,
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
