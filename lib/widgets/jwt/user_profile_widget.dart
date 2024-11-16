import '../../exports.dart';

class UserProfileWidget extends StatelessWidget {
  final AppUser user;
  final String authToken;

  const UserProfileWidget({
    required this.user,
    required this.authToken,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.grey[300],
      child: Column(
        children: [
          Text('HEJ!', style: const TextStyle(color: Colors.black)),
          Text('Email: ${user.email}',
              style: const TextStyle(color: Colors.black)),
          Text('AuthToken: $authToken',
              style: const TextStyle(color: Colors.black, fontSize: 12)),
          // Widget kan nu bruge authToken til API kald hvis nødvendigt
        ],
      ),
    );
  }
}
