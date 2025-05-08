import '../../exports.dart';

enum Level {
  level_1,
  level_2,
  level_3,
}

class CustomLevelLabel extends StatelessWidget {
  const CustomLevelLabel({
    super.key,
    required this.level,
  });

  final Level level;

  @override
  Widget build(BuildContext context) {
    // Determine background color based on level
    Color backgroundColor;
    String labelText;

    switch (level) {
      case Level.level_1:
        backgroundColor = const Color(0xFF0E5D4A);
        labelText = 'Level 1';
      case Level.level_2:
        backgroundColor = const Color(0xFF89AB0C);
        labelText = 'Level 2';
      case Level.level_3:
        backgroundColor = const Color(0xFFEA7A18);
        labelText = 'Level 3';
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        color: backgroundColor,
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 3,
        horizontal: 10,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            labelText,
            textScaler: TextScaler.noScaling,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.normal,
              height: 1.15, // 115% line-height
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }
}

// Created: 2024-07-02 14:43
