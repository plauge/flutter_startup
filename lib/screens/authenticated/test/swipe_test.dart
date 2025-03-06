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
        color: Colors.white,
      ),
      elevationThumb: 2,
      elevationTrack: 2,
      child: Text(
        "SWIPE TO CONFIRM",
        style: const TextStyle(
          color: Colors.black,
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
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                  Gap(AppDimensionsTheme.getSmall(context)),
                  Text(
                    "PROCESSING...",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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
      height: 50,
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  Gap(AppDimensionsTheme.getSmall(context)),
                  Text(
                    "CONFIRMED",
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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
      height: 50,
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red),
                  Gap(AppDimensionsTheme.getSmall(context)),
                  Text(
                    "ERROR OCCURRED",
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFraudButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.deepOrange.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning, color: Colors.deepOrange),
                  Gap(AppDimensionsTheme.getSmall(context)),
                  Text(
                    "FRAUD DETECTED",
                    style: const TextStyle(
                      color: Colors.deepOrange,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
