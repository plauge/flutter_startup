import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../exports.dart';
import 'validate_face_id_status.dart';

/// Widget that wraps a child and requires Face ID authentication before displaying it
/// Shows a loading overlay while Face ID validation is in progress
/// Navigates to Home if Face ID validation fails
class FaceIdProtectionLayer extends ConsumerStatefulWidget {
  final Widget child;
  final String screenName;

  const FaceIdProtectionLayer({
    super.key,
    required this.child,
    required this.screenName,
  });

  @override
  ConsumerState<FaceIdProtectionLayer> createState() => _FaceIdProtectionLayerState();
}

class _FaceIdProtectionLayerState extends ConsumerState<FaceIdProtectionLayer> {
  Future<bool>? _faceIdValidationFuture;
  bool _isValidated = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    final log = scopedLogger(LogCategory.security);
    log('FaceIdProtectionLayer.initState - lib/core/widgets/screens/authenticated_screen_helpers/face_id_protection_layer.dart', {
      'screenName': widget.screenName,
      'mounted': mounted,
    });
    
    // Only start FaceID validation if widget is still mounted
    // This should NEVER be called unless face_id_protected is true
    if (mounted) {
      log('Starting FaceID validation - lib/core/widgets/screens/authenticated_screen_helpers/face_id_protection_layer.dart', {
        'screenName': widget.screenName,
      });
      _startFaceIdValidation();
    } else {
      log('Widget not mounted, skipping FaceID validation - lib/core/widgets/screens/authenticated_screen_helpers/face_id_protection_layer.dart', {
        'screenName': widget.screenName,
      });
    }
  }

  @override
  void dispose() {
    final log = scopedLogger(LogCategory.security);
    log('FaceIdProtectionLayer.dispose - lib/core/widgets/screens/authenticated_screen_helpers/face_id_protection_layer.dart', {
      'screenName': widget.screenName,
    });
    _isDisposed = true;
    // Cancel any pending FaceID validation
    _faceIdValidationFuture = null;
    super.dispose();
  }

  void _startFaceIdValidation() {
    if (!mounted || _isDisposed) return;
    _faceIdValidationFuture = _validateFaceId();
  }

  Future<bool> _validateFaceId() async {
    if (!mounted || _isDisposed) return false;
    final result = await validateFaceIdStatus(
      context,
      ref,
      widget.screenName,
      handleNavigation: false,
    );
    if (!mounted || _isDisposed) return false;
    if (!result) {
      // Show error alert and navigate to home
      if (!_isDisposed) {
        _showErrorAndNavigate();
      }
      return false;
    }
    if (mounted && !_isDisposed) {
      setState(() {
        _isValidated = true;
      });
    }
    return true;
  }

  void _showErrorAndNavigate() {
    if (!mounted || _isDisposed) return;
    // Show appropriate error dialog based on the error type
    // For now, we'll show a generic error and navigate to home
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              I18nService().t('screen_contact_verification.auth_failed_title', fallback: 'Authentication Failed'),
              style: AppTheme.getBodyMedium(context),
            ),
            content: Text(
              I18nService().t('screen_contact_verification.auth_failed_message', fallback: 'Biometric authentication failed. Redirecting to home.'),
              style: AppTheme.getBodyMedium(context),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (mounted) {
                    context.go(RoutePaths.home);
                  }
                },
                child: Text(I18nService().t('screen_contact_verification.ok_button', fallback: 'OK')),
              ),
            ],
          ),
        ).then((_) {
          if (mounted && !_isDisposed) {
            context.go(RoutePaths.home);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // If already validated, show child immediately
    if (_isValidated) {
      return widget.child;
    }

    // Show loading overlay while validating
    return FutureBuilder<bool>(
      future: _faceIdValidationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading overlay
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          // Error occurred, will navigate to home via _showErrorAndNavigate
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.data == true) {
          // Validation successful, show child
          return widget.child;
        }

        // Validation failed, show loading while navigating
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

// Created: 2025-01-27

