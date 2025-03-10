import '../../../exports.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'dart:developer' as developer;
import 'dart:async';
import 'persistent_swipe_button.dart';

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

    // State management for PersistentSwipeButton
    final ValueNotifier<SwipeButtonState> buttonStateNotifier =
        ValueNotifier<SwipeButtonState>(SwipeButtonState.init);

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
                ValueListenableBuilder<SwipeButtonState>(
                    valueListenable: buttonStateNotifier,
                    builder: (context, buttonState, _) {
                      return Column(
                        children: [
                          PersistentSwipeButton(
                            buttonState: buttonState,
                            padding: EdgeInsets.symmetric(
                              horizontal: AppDimensionsTheme.getMedium(context),
                              vertical: AppDimensionsTheme.getSmall(context),
                            ),
                            question: "Swipe to confirm test",
                            onSwipe: () => _showSwipeMessage(context),
                            onStateChange: (SwipeButtonState newState) {
                              // Update button state based on widget's suggestion
                              buttonStateNotifier.value = newState;

                              // Log state change for debugging
                              developer.log(
                                  'Button state changed to: ${newState.toString().split('.').last}',
                                  name: 'SwipeTestScreen');
                            },
                          ),
                          Gap(AppDimensionsTheme.getMedium(context)),
                          _buildStateDropdown(buttonState, buttonStateNotifier),
                        ],
                      );
                    }),
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

  Widget _buildStateDropdown(SwipeButtonState currentState,
      ValueNotifier<SwipeButtonState> stateNotifier) {
    return DropdownButton<SwipeButtonState>(
      value: currentState,
      onChanged: (SwipeButtonState? newValue) {
        if (newValue != null) {
          stateNotifier.value = newValue;
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
}
