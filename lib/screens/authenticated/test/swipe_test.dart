import '../../../exports.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'dart:developer' as developer;
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';

// Enum for swipe button states
enum SwipeButtonState {
  init,
  initPost,
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
  // Tilføj en konstant for fade-varigheden
  final Duration _fadeDuration = const Duration(milliseconds: 300);
  // Tilføj en variabel til at holde styr på forrige tilstand
  SwipeButtonState _previousState = SwipeButtonState.init;
  // Timer til at håndtere automatisk skift fra initPost til waiting
  Timer? _stateTimer;

  @override
  void dispose() {
    // Ryd timer for at undgå memory leaks
    _stateTimer?.cancel();
    super.dispose();
  }

  // Hjælpefunktion til at håndtere tilstandsskift
  void _changeState(SwipeButtonState newState) {
    // Annuller eventuelle eksisterende timers
    _stateTimer?.cancel();

    setState(() {
      _previousState = _buttonState;
      _buttonState = newState;
    });

    // Hvis den nye tilstand er initPost, så start en timer for at skifte til waiting efter 1 sekund
    if (newState == SwipeButtonState.initPost) {
      _stateTimer = Timer(const Duration(milliseconds: 150), () {
        setState(() {
          _previousState = _buttonState;
          _buttonState = SwipeButtonState.waiting;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: widget.padding,
          child: _shouldSkipAnimation()
              // Undgå animation mellem init og initPost ved direkte at vise child
              ? _buildSwipeButtonForState()
              // Normal animation for andre state-ændringer
              : AnimatedSwitcher(
                  duration: _fadeDuration,
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: _buildSwipeButtonForState(),
                ),
        ),
        Gap(AppDimensionsTheme.getMedium(context)),
        _buildStateDropdown(),
      ],
    );
  }

  // Ny metode: Tjekker om vi er i overgang fra init til initPost, hvor vi vil undgå animation
  bool _shouldSkipAnimation() {
    return (_previousState == SwipeButtonState.init &&
        _buttonState == SwipeButtonState.initPost);
  }

  Widget _buildStateDropdown() {
    return DropdownButton<SwipeButtonState>(
      value: _buttonState,
      onChanged: (SwipeButtonState? newValue) {
        if (newValue != null) {
          _changeState(newValue);
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
    // Tilføj en key til hver knap baseret på dens tilstand
    // Dette hjælper AnimatedSwitcher med at identificere ændringer
    switch (_buttonState) {
      case SwipeButtonState.init:
        return _buildInitButton(key: ValueKey('init'));
      case SwipeButtonState.initPost:
        return _buildInitPostButton(key: ValueKey('initPost'));
      case SwipeButtonState.waiting:
        return _buildWaitingButton(key: ValueKey('waiting'));
      case SwipeButtonState.confirmed:
        return _buildConfirmedButton(key: ValueKey('confirmed'));
      case SwipeButtonState.error:
        return _buildErrorButton(key: ValueKey('error'));
      case SwipeButtonState.fraud:
        return _buildFraudButton(key: ValueKey('fraud'));
    }
  }

  Widget _buildInitButton({Key? key}) {
    return SwipeButton(
      key: key,
      thumbPadding: const EdgeInsets.all(3),
      thumb: SvgPicture.asset(
        'assets/images/confirmation/swipe.svg',
        width: 40,
        height: 40,
      ),
      height: 60,
      borderRadius: BorderRadius.circular(30),
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
        _changeState(SwipeButtonState.initPost);
        widget.onSwipe();
      },
    );
  }

  Widget _buildInitPostButton({Key? key}) {
    return Container(
      key: key,
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF014459),
        borderRadius: BorderRadius.circular(30),
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
              "Swipe to confirm",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Thumb fastgjort til højre side
          Positioned(
            right: 1,
            top: 1,
            bottom: 1,
            child: Material(
              elevation: 0,
              color: const Color(0xFF014459),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
                topLeft: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
              child: Container(
                width: 60,
                //padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  //border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                  ),
                ),
                child: SvgPicture.asset(
                  'assets/images/confirmation/swipe.svg',
                  width: 40,
                  height: 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingButton({Key? key}) {
    return Container(
      key: key,
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF719696),
        borderRadius: BorderRadius.circular(30),
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
            right: 1,
            top: 1,
            bottom: 1,
            child: Material(
              elevation: 0,
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
                topLeft: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
              child: Container(
                width: 58,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                  ),
                ),
                child: SvgPicture.asset(
                  'assets/images/confirmation/rotate.svg',
                  width: 40,
                  height: 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmedButton({Key? key}) {
    return Container(
      key: key,
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF0E5D4A),
        borderRadius: BorderRadius.circular(30),
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
            right: 1,
            top: 1,
            bottom: 1,
            child: Material(
              elevation: 0,
              color: const Color(0xFF0E5D4A),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
                topLeft: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
              child: Container(
                width: 60,
                //padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  //border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                  ),
                ),
                child: SvgPicture.asset(
                  'assets/images/confirmation/confirmed.svg',
                  width: 40,
                  height: 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorButton({Key? key}) {
    return Container(
      key: key,
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF656565),
        borderRadius: BorderRadius.circular(30),
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

  Widget _buildFraudButton({Key? key}) {
    return Container(
      key: key,
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFC42121),
        borderRadius: BorderRadius.circular(30),
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
            right: 1,
            top: 1,
            bottom: 1,
            child: Material(
              elevation: 0,
              color: const Color(0xFFC42121),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
                topLeft: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
              child: Container(
                width: 60,
                //padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  //border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                  ),
                ),
                child: SvgPicture.asset(
                  'assets/images/confirmation/fraud.svg',
                  width: 40,
                  height: 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
