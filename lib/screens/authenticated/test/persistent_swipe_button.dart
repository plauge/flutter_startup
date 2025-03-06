import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import '../../../exports.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'dart:developer' as developer;

// Enum for swipe button states
enum SwipeButtonState {
  init,
  initPost,
  waiting,
  confirmed,
  error,
  fraud,
}

/// A swipe button that persists its appearance through various states.
///
/// This widget shows different appearances based on the provided state:
/// init, initPost, waiting, confirmed, error, or fraud.
class PersistentSwipeButton extends StatefulWidget {
  /// The current state of the button
  final SwipeButtonState buttonState;

  /// Padding around the button
  final EdgeInsets padding;

  /// Callback triggered when the user completes a swipe action
  final VoidCallback onSwipe;

  /// Callback triggered when the button suggests a state change
  final ValueChanged<SwipeButtonState>? onStateChange;

  /// Whether to show a pulsating effect on confirmation
  final bool showConfirmationEffect;

  /// Speed of pulse in milliseconds (lower = faster)
  final int pulseSpeed;

  /// Number of times the button should pulse
  final int pulseCount;

  /// Intensity of pulse effect (0.0-1.0, higher = stronger effect)
  final double intensity;

  /// Color of glow effect
  final Color glowColor;

  const PersistentSwipeButton({
    Key? key,
    required this.buttonState,
    required this.padding,
    required this.onSwipe,
    this.onStateChange,
    this.showConfirmationEffect = true,
    this.pulseSpeed = 350,
    this.pulseCount = 5,
    this.intensity = 0.2,
    this.glowColor = const Color.fromRGBO(14, 93, 74, 1),
  }) : super(key: key);

  @override
  State<PersistentSwipeButton> createState() => _PersistentSwipeButtonState();
}

class _PersistentSwipeButtonState extends State<PersistentSwipeButton>
    with TickerProviderStateMixin {
  // Tilføj en konstant for fade-varigheden
  final Duration _fadeDuration = const Duration(milliseconds: 300);
  // Tilføj en variabel til at holde styr på forrige tilstand
  late SwipeButtonState _previousState;
  // Timer til at håndtere automatisk skift fra initPost til waiting
  Timer? _stateTimer;

  // Animation controller til pulseffekt
  AnimationController? _pulseController;
  Animation<double>? _pulseAnimation;
  int _pulseCount = 0;
  static const int _maxPulseCount = 3;

  @override
  void initState() {
    super.initState();
    _previousState = widget.buttonState;

    // Check if we need to start a timer already (if widget is created with initPost state)
    if (widget.buttonState == SwipeButtonState.initPost) {
      _startWaitingTimer();
    }

    // Initialiser pulse controller hvis vi starter i confirmed state
    if (widget.buttonState == SwipeButtonState.confirmed &&
        widget.showConfirmationEffect) {
      _setupPulseAnimation();
    }
  }

  @override
  void didUpdateWidget(PersistentSwipeButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Håndter state skift
    if (oldWidget.buttonState != widget.buttonState) {
      _previousState = oldWidget.buttonState;

      // Start timer hvis vi skifter til initPost
      if (widget.buttonState == SwipeButtonState.initPost) {
        _startWaitingTimer();
      }

      // Start pulse animation hvis vi skifter til confirmed
      if (widget.buttonState == SwipeButtonState.confirmed &&
          widget.showConfirmationEffect) {
        // Vi kalder setupPulseAnimation som håndterer oprydning først
        _setupPulseAnimation();
      } else if (widget.buttonState != SwipeButtonState.confirmed) {
        // Stop animation hvis vi forlader confirmed state
        if (_pulseController != null) {
          _pulseController!.stop();
          _pulseController!.dispose();
          _pulseController = null;
        }
      }
    }

    // Håndter skift i showConfirmationEffect
    else if (oldWidget.showConfirmationEffect !=
        widget.showConfirmationEffect) {
      if (widget.buttonState == SwipeButtonState.confirmed &&
          widget.showConfirmationEffect) {
        _setupPulseAnimation();
      } else if (!widget.showConfirmationEffect && _pulseController != null) {
        _pulseController!.stop();
        _pulseController!.dispose();
        _pulseController = null;
      }
    }
  }

  void _setupPulseAnimation() {
    // Ryd eksisterende controller
    if (_pulseController != null) {
      _pulseController!.stop();
      _pulseController!.dispose();
      _pulseController = null;
    }

    // Hvis komponentet ikke længere er mounted, så undgå at skabe ny controller
    if (!mounted) return;

    // Nulstil pulse count
    _pulseCount = 0;

    // Opret ny controller med hastighed fra widget
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.pulseSpeed),
    );

    // Opret en curved animation for mere naturlig pulsering
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController!,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    // Lyt til animation status
    _pulseController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _pulseCount++;
        // Reverse uanset antal pulse (så vi altid slutter i dismissed tilstand)
        if (_pulseController != null && mounted) {
          _pulseController!.reverse();
        }
      } else if (status == AnimationStatus.dismissed) {
        // Start forfra hvis vi ikke har nået max antal pulse
        if (_pulseCount < widget.pulseCount) {
          if (_pulseController != null && mounted) {
            _pulseController!.forward();
          }
        } else {
          // Ellers stopper vi i dismissed tilstand (uden skygge)
          if (_pulseController != null) {
            _pulseController!.stop();
          }
        }
      }
    });

    // Start animation
    _pulseController!.forward();
  }

  void _startWaitingTimer() {
    developer.log('Starting timer to change state to waiting',
        name: 'PersistentSwipeButton');
    _stateTimer?.cancel();
    _stateTimer = Timer(const Duration(milliseconds: 150), () {
      if (mounted && widget.onStateChange != null) {
        developer.log('Timer completed, requesting state change to waiting',
            name: 'PersistentSwipeButton');
        widget.onStateChange!(SwipeButtonState.waiting);
      }
    });
  }

  @override
  void dispose() {
    // Ryd timer for at undgå memory leaks
    _stateTimer?.cancel();
    // Ryd animation controller
    if (_pulseController != null) {
      _pulseController!.stop();
      _pulseController!.dispose();
      _pulseController = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: _shouldSkipAnimation()
          // Undgå animation mellem init og initPost ved direkte at vise child
          ? _buildSwipeButtonForState()
          // Normal animation for andre state-ændringer
          : AnimatedSwitcher(
              duration: _fadeDuration,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: _buildSwipeButtonForState(),
            ),
    );
  }

  // Ny metode: Tjekker om vi er i overgang fra init til initPost, hvor vi vil undgå animation
  bool _shouldSkipAnimation() {
    return (_previousState == SwipeButtonState.init &&
        widget.buttonState == SwipeButtonState.initPost);
  }

  Widget _buildSwipeButtonForState() {
    // Tilføj en key til hver knap baseret på dens tilstand
    // Dette hjælper AnimatedSwitcher med at identificere ændringer
    switch (widget.buttonState) {
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
        // Notify parent about swipe
        widget.onSwipe();

        // Suggest state change to initPost
        if (widget.onStateChange != null) {
          developer.log('Swipe detected, requesting state change to initPost',
              name: 'PersistentSwipeButton');
          widget.onStateChange!(SwipeButtonState.initPost);
        }
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
            right: 3,
            top: 3,
            bottom: 3,
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
          // Tekst forskudt lidt til venstre
          Align(
            alignment: Alignment(-0.15, 0), // Forskyd teksten lidt til venstre
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
            right: 3,
            top: 3,
            bottom: 3,
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
    return AnimatedBuilder(
      animation: _pulseAnimation ?? const AlwaysStoppedAnimation(0.0),
      builder: (context, child) {
        // Simplificeret skygge-konfiguration
        final double animationValue = _pulseAnimation?.value ?? 0.0;

        // Beregn effekter baseret på intensitet og animationsværdi
        final double extraOpacity = widget.showConfirmationEffect
            ? (animationValue * widget.intensity)
            : 0.0;

        final double shadowSpread =
            0.5 + (animationValue * 3.0 * widget.intensity);
        final double glowSpread =
            1.0 + (animationValue * 5.0 * widget.intensity);

        final double shadowBlur =
            2.0 + (animationValue * 8.0 * widget.intensity);
        final double glowBlur =
            8.0 + (animationValue * 12.0 * widget.intensity);

        return Container(
          key: key,
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF0E5D4A),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              // Standard skygge (primær)
              BoxShadow(
                color: Colors.black.withOpacity(0.2 + extraOpacity),
                spreadRadius: shadowSpread,
                blurRadius: shadowBlur,
                offset: Offset(0, 1),
              ),
              // Glød-effekt (sekundær)
              if (widget.showConfirmationEffect && _pulseController != null)
                BoxShadow(
                  color: widget.glowColor.withOpacity(extraOpacity),
                  spreadRadius: glowSpread,
                  blurRadius: glowBlur,
                  offset: const Offset(0, 0),
                ),
            ],
          ),
          child: Stack(
            children: [
              // Centreret tekst
              Align(
                alignment:
                    Alignment(-0.15, 0), // Forskyd teksten lidt til venstre
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
      },
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
          Align(
            alignment:
                const Alignment(-0.15, 0), // Forskyd teksten lidt til venstre
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
