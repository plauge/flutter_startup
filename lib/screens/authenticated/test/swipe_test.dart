import '../../../exports.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'dart:developer' as developer;

// Enum for swipe button states
enum SwipeButtonState {
  init,
  waiting,
  confirmed,
  error,
  fraud,
}

class SwipeTestScreen extends AuthenticatedScreen {
  SwipeTestScreen({Key? key}) : super(key: key);

  static Future<SwipeTestScreen> create() async {
    final screen = SwipeTestScreen();
    return AuthenticatedScreen.create(screen);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    developer.log('Building SwipeTestScreen', name: 'SwipeTestScreen');

    return Scaffold(
      appBar: AuthenticatedAppBar(
        title: 'Swipe Test',
        backRoutePath: RoutePaths.home,
      ),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _PersistentSwipeButton(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensionsTheme.getMedium(context),
                    vertical: AppDimensionsTheme.getSmall(context),
                  ),
                  onSwipe: () => _showSwipeMessage(context),
                ),
                Gap(AppDimensionsTheme.getSmall(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSwipeMessage(BuildContext context) {
    // Fjern eventuelle aktive snackbars først
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // Vis den nye snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Swipped"),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class _PersistentSwipeButton extends StatefulWidget {
  final EdgeInsets padding;
  final VoidCallback onSwipe;

  const _PersistentSwipeButton({
    required this.padding,
    required this.onSwipe,
  });

  @override
  State<_PersistentSwipeButton> createState() => _PersistentSwipeButtonState();
}

class _PersistentSwipeButtonState extends State<_PersistentSwipeButton> {
  SwipeButtonState _buttonState = SwipeButtonState.init;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: widget.padding,
          child: _buildSwipeButtonForState(),
        ),
        Gap(AppDimensionsTheme.getMedium(context)),
        _buildStateDropdown(),
      ],
    );
  }

  Widget _buildStateDropdown() {
    return DropdownButton<SwipeButtonState>(
      value: _buttonState,
      onChanged: (SwipeButtonState? newValue) {
        if (newValue != null) {
          setState(() {
            _buttonState = newValue;
          });
        }
      },
      items: SwipeButtonState.values
          .map<DropdownMenuItem<SwipeButtonState>>((SwipeButtonState value) {
        return DropdownMenuItem<SwipeButtonState>(
          value: value,
          child: Text(value.toString().split('.').last),
        );
      }).toList(),
    );
  }

  Widget _buildSwipeButtonForState() {
    switch (_buttonState) {
      case SwipeButtonState.init:
        return _buildInitButton();
      case SwipeButtonState.waiting:
        return _buildWaitingButton();
      case SwipeButtonState.confirmed:
        return _buildConfirmedButton();
      case SwipeButtonState.error:
        return _buildErrorButton();
      case SwipeButtonState.fraud:
        return _buildFraudButton();
    }
  }

  Widget _buildInitButton() {
    return SwipeButton(
      thumbPadding: const EdgeInsets.all(3),
      thumb: const Icon(
        Icons.chevron_right,
        color: const Color(0xFF014459),
      ),
      height: 60,
      borderRadius: BorderRadius.circular(25),
      elevationThumb: 2,
      elevationTrack: 2,
      activeThumbColor: Colors.white,
      activeTrackColor: const Color(0xFF014459),
      child: Text(
        "Swipe to confirm",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      onSwipe: () {
        setState(() {
          _buttonState = SwipeButtonState.waiting;
        });
        widget.onSwipe();
      },
    );
  }

  Widget _buildWaitingButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF719696),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 0.5,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Centreret tekst
          Center(
            child: Text(
              "Waiting...",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Thumb fastgjort til højre side
          Positioned(
            right: 2,
            top: 2,
            bottom: 2,
            child: Material(
              elevation: 0,
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(25),
                bottomRight: Radius.circular(25),
                topLeft: Radius.circular(25),
                bottomLeft: Radius.circular(25),
              ),
              child: Container(
                width: 56,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                    topLeft: Radius.circular(25),
                    bottomLeft: Radius.circular(25),
                  ),
                ),
                child: const Icon(
                  Icons.loop_sharp,
                  color: const Color(0xFF719696),
                  size: 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmedButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF0E5D4A),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 0.5,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Centreret tekst
          Center(
            child: Text(
              "Confirmed",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Thumb fastgjort til højre side
          Positioned(
            right: 2,
            top: 2,
            bottom: 2,
            child: Material(
              elevation: 0,
              color: const Color(0xFF0E5D4A),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(25),
                bottomRight: Radius.circular(25),
                topLeft: Radius.circular(25),
                bottomLeft: Radius.circular(25),
              ),
              child: Container(
                width: 56,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                    topLeft: Radius.circular(25),
                    bottomLeft: Radius.circular(25),
                  ),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF656565),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 0.5,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Centreret tekst
          Center(
            child: Text(
              "Timed out",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Thumb fastgjort til højre side
        ],
      ),
    );
  }

  Widget _buildFraudButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFC42121),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 0.5,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Centreret tekst
          Center(
            child: Text(
              "Attempted fraud",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Thumb fastgjort til højre side
          Positioned(
            right: 2,
            top: 2,
            bottom: 2,
            child: Material(
              elevation: 0,
              color: const Color(0xFFC42121),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(25),
                bottomRight: Radius.circular(25),
                topLeft: Radius.circular(25),
                bottomLeft: Radius.circular(25),
              ),
              child: Container(
                width: 56,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                    topLeft: Radius.circular(25),
                    bottomLeft: Radius.circular(25),
                  ),
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
