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
    return Column(
      children: [
        Text('Email: ${user.email}'),
        // Widget kan nu bruge authToken til API kald hvis nødvendigt
      ],
    );
  }
}
