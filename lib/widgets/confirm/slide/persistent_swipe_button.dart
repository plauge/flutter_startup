import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import '../../../exports.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'dart:developer' as developer;
import 'package:just_audio/just_audio.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/confirms_provider.dart';
import '../../../models/confirm_state.dart';
import 'extra/audio_handler.dart';
import 'extra/utils/animation_handler.dart';
import 'extra/utils/state_handler.dart';
import 'extra/buttons/init_button.dart';
import 'extra/buttons/init_post_button.dart';
import 'extra/buttons/waiting_button.dart';
import 'extra/buttons/confirmed_button.dart';
import 'extra/buttons/error_button.dart';
import 'extra/buttons/fraud_button.dart';

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
class PersistentSwipeButton extends ConsumerStatefulWidget {
  /// The current state of the button
  final SwipeButtonState buttonState;

  /// Padding around the button
  final EdgeInsets padding;

  /// Callback triggered when the user completes a swipe action
  final VoidCallback onSwipe;

  /// Callback triggered when the button suggests a state change
  final ValueChanged<SwipeButtonState>? onStateChange;

  /// Callback triggered when confirm state changes with additional data
  final Function(ConfirmState, Map<String, dynamic>?)? onConfirmStateChange;

  /// Contact ID for confirmation
  final String? contactId;

  /// Question text for confirmation
  final String question;

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
    required this.question,
    this.onStateChange,
    this.onConfirmStateChange,
    this.contactId,
    this.showConfirmationEffect = true,
    this.pulseSpeed = 350,
    this.pulseCount = 5,
    this.intensity = 0.2,
    this.glowColor = const Color.fromRGBO(14, 93, 74, 1),
  }) : super(key: key);

  @override
  ConsumerState<PersistentSwipeButton> createState() =>
      _PersistentSwipeButtonState();
}

class _PersistentSwipeButtonState extends ConsumerState<PersistentSwipeButton>
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
      AudioHandler.playConfirmedSound();
    } else if (widget.buttonState == SwipeButtonState.fraud) {
      // Afspil alert lyd hvis vi starter i fraud state
      AudioHandler.playAlertSound();
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
      if (widget.buttonState == SwipeButtonState.confirmed) {
        if (widget.showConfirmationEffect) {
          _setupPulseAnimation();
        }
        AudioHandler.playConfirmedSound();
      } else if (widget.buttonState == SwipeButtonState.fraud) {
        AudioHandler.playAlertSound();
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

    _pulseController = AnimationHandler.setupPulseAnimation(
      vsync: this,
      pulseSpeed: widget.pulseSpeed,
      pulseCount: widget.pulseCount,
      onAnimationComplete: () {
        if (_pulseCount < widget.pulseCount) {
          _pulseCount++;
          if (_pulseController != null && mounted) {
            _pulseController!.forward();
          }
        } else {
          if (_pulseController != null) {
            _pulseController!.stop();
          }
        }
      },
    );

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController!,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
  }

  void _startWaitingTimer() {
    StateHandler.startWaitingTimer(
      onStateChange: () {
        if (mounted && widget.onStateChange != null) {
          widget.onStateChange!(SwipeButtonState.waiting);
        }
      },
    );
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
    switch (widget.buttonState) {
      case SwipeButtonState.init:
        return InitButton(
          key: const ValueKey('init'),
          onSwipe: widget.onSwipe,
          question: widget.question,
          onStateChange: (state) {
            if (widget.onStateChange != null) {
              widget.onStateChange!(SwipeButtonState.values.firstWhere(
                (e) => e.toString() == 'SwipeButtonState.$state',
              ));
            }
          },
          onConfirmStateChange: widget.onConfirmStateChange,
          contactId: widget.contactId,
        );
      case SwipeButtonState.initPost:
        return const InitPostButton(key: ValueKey('initPost'));
      case SwipeButtonState.waiting:
        return const WaitingButton(key: ValueKey('waiting'));
      case SwipeButtonState.confirmed:
        return ConfirmedButton(
          key: const ValueKey('confirmed'),
          pulseAnimation: _pulseAnimation,
          showConfirmationEffect: widget.showConfirmationEffect,
          intensity: widget.intensity,
          glowColor: widget.glowColor,
        );
      case SwipeButtonState.error:
        return const ErrorButton(key: ValueKey('error'));
      case SwipeButtonState.fraud:
        return const FraudButton(key: ValueKey('fraud'));
    }
  }
}
