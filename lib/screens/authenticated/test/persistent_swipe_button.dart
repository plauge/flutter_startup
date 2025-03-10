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
  static const int _maxPulseCount = 3;

  // Audio players til lydeffekter
  AudioPlayer? _confirmedPlayer;
  AudioPlayer? _alertPlayer;
  bool _soundsLoaded = false;

  @override
  void initState() {
    super.initState();
    _previousState = widget.buttonState;

    // Initialiser audio players
    _confirmedPlayer = AudioPlayer();
    _alertPlayer = AudioPlayer();

    // Preload sound files
    _preloadSounds();

    // Check if we need to start a timer already (if widget is created with initPost state)
    if (widget.buttonState == SwipeButtonState.initPost) {
      _startWaitingTimer();
    }

    // Initialiser pulse controller hvis vi starter i confirmed state
    if (widget.buttonState == SwipeButtonState.confirmed &&
        widget.showConfirmationEffect) {
      _setupPulseAnimation();
      _playConfirmedSound();
    } else if (widget.buttonState == SwipeButtonState.fraud) {
      // Afspil alert lyd hvis vi starter i fraud state
      _playAlertSound();
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
          // Vi kalder setupPulseAnimation som håndterer oprydning først
          _setupPulseAnimation();
        }

        // Afspil lyd når status skifter til confirmed
        _playConfirmedSound();
      } else if (widget.buttonState == SwipeButtonState.fraud) {
        // Afspil alert lyd når status skifter til fraud
        _playAlertSound();
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

  // Preload sound files
  Future<void> _preloadSounds() async {
    try {
      developer.log('Preloading sound files', name: 'PersistentSwipeButton');

      if (_confirmedPlayer != null) {
        await _confirmedPlayer!.setAsset('assets/sounds/confirmed.mp3');
        developer.log('Confirmed sound preloaded successfully',
            name: 'PersistentSwipeButton');
      }

      if (_alertPlayer != null) {
        await _alertPlayer!.setAsset('assets/sounds/alert.mp3');
        developer.log('Alert sound preloaded successfully',
            name: 'PersistentSwipeButton');
      }

      _soundsLoaded = true;
      developer.log('All sounds preloaded successfully',
          name: 'PersistentSwipeButton');
    } catch (e) {
      developer.log('Error preloading sounds: $e',
          name: 'PersistentSwipeButton');
    }
  }

  // Afspil confirmed lyd
  Future<void> _playConfirmedSound() async {
    try {
      developer.log('Forsøger at afspille confirmed lyd med ny metode',
          name: 'PersistentSwipeButton');

      // Stop eksisterende players
      _alertPlayer?.stop();
      _confirmedPlayer?.stop();

      // Opret en helt ny player til hver afspilning for at undgå caching-problemer
      final AudioPlayer tempPlayer = AudioPlayer();

      // Log for at tjekke flow
      developer.log('Ny AudioPlayer oprettet til confirmed lyd',
          name: 'PersistentSwipeButton');

      // Indlæs og forsøg at afspille lyden
      await tempPlayer.setAsset('assets/sounds/confirmed.mp3');
      await tempPlayer.setVolume(1.0);

      developer.log('Confirmed lyd indlæst, forsøger at afspille',
          name: 'PersistentSwipeButton');

      await tempPlayer.play();

      developer.log('Confirmed lyd afspilning startet!',
          name: 'PersistentSwipeButton');

      // Opret en timer til at rydde op i spilleren
      Timer(Duration(seconds: 3), () {
        tempPlayer.dispose();
        developer.log('Temporary confirmed player disposed',
            name: 'PersistentSwipeButton');
      });
    } catch (e) {
      developer.log('Fejl ved afspilning af confirmed lyd: $e',
          name: 'PersistentSwipeButton');
    }
  }

  // Afspil alert lyd
  Future<void> _playAlertSound() async {
    try {
      developer.log('=================== ALERT SOUND START ===================',
          name: 'PersistentSwipeButton');

      // Stop eksisterende players
      _alertPlayer?.stop();
      _confirmedPlayer?.stop();

      // Opret en helt ny player til hver afspilning for at undgå caching-problemer
      final AudioPlayer tempPlayer = AudioPlayer();

      // Log for at tjekke flow
      developer.log('Ny AudioPlayer oprettet til alert lyd',
          name: 'PersistentSwipeButton');

      // Indlæs og forsøg at afspille lyden
      await tempPlayer.setAsset('assets/sounds/alert.mp3');
      await tempPlayer.setVolume(1.0);

      developer.log('Alert lyd indlæst, forsøger at afspille',
          name: 'PersistentSwipeButton');

      // Tjek om enheden har en vibrator
      final bool hasVibrator = await Vibration.hasVibrator() ?? false;
      developer.log('Telefonen har vibrator: $hasVibrator',
          name: 'PersistentSwipeButton');

      // Afspil vibration sammen med lyden - brug en dramatisk notifikation
      if (hasVibrator) {
        developer.log('Starter vibration nu...', name: 'PersistentSwipeButton');

        // Afspil en intens vibration med mønster for at signalere advarsel
        // Mønster: 500ms on, 100ms off, 500ms on, 100ms off, 500ms on
        try {
          Vibration.vibrate(
            pattern: [0, 500, 100, 500, 100, 500],
            intensities: [0, 255, 0, 255, 0, 255], // Fuld intensitet
          );
          developer.log('Vibration metode kaldt uden fejl',
              name: 'PersistentSwipeButton');
        } catch (vibrationError) {
          developer.log('Fejl ved vibration: $vibrationError',
              name: 'PersistentSwipeButton');
        }

        developer.log('Vibration afspillet', name: 'PersistentSwipeButton');
      } else {
        developer.log('Telefonen har ikke vibrator eller tilladelse mangler',
            name: 'PersistentSwipeButton');
      }

      await tempPlayer.play();

      developer.log('Alert lyd afspilning startet!',
          name: 'PersistentSwipeButton');

      // Opret en timer til at rydde op i spilleren
      Timer(Duration(seconds: 3), () {
        tempPlayer.dispose();
        developer.log('Temporary alert player disposed',
            name: 'PersistentSwipeButton');
      });

      developer.log('=================== ALERT SOUND END ===================',
          name: 'PersistentSwipeButton');
    } catch (e) {
      developer.log('Fejl ved afspilning af alert lyd: $e',
          name: 'PersistentSwipeButton');
    }
  }

  void _handleConfirm() async {
    try {
      developer.log('🔍 Starting _handleConfirm',
          name: 'PersistentSwipeButton');

      if (widget.contactId == null) {
        developer.log('❌ Error in _handleConfirm: contactId is null',
            name: 'PersistentSwipeButton');
        if (widget.onConfirmStateChange != null) {
          widget.onConfirmStateChange!(ConfirmState.error, {
            'message': 'Contact ID is missing',
          });
        }
        return;
      }

      final result = await ref.read(confirmsConfirmProvider.notifier).confirm(
            contactsId: widget.contactId!,
            question: widget.question,
          );

      if (widget.onConfirmStateChange != null) {
        widget.onConfirmStateChange!(ConfirmState.initiator_update, result);
      }
    } catch (e) {
      developer.log('❌ Error in _handleConfirm: $e',
          name: 'PersistentSwipeButton');
      if (widget.onConfirmStateChange != null) {
        widget.onConfirmStateChange!(ConfirmState.error, {
          'message': 'Der opstod en fejl: $e',
        });
      }
    }
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

    // Ryd audio players
    _confirmedPlayer?.dispose();
    _alertPlayer?.dispose();

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

        // Handle confirmation process
        _handleConfirm();

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
