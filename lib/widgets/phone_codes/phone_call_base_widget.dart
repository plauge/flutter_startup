import 'dart:async';
import '../../exports.dart';

// Base class med fælles funktionalitet for phone call widgets
abstract class PhoneCallBaseState<T extends ConsumerStatefulWidget> extends ConsumerState<T> {
  final log = scopedLogger(LogCategory.gui);
  Timer? _timer;
  late ValueNotifier<String> timeAgoNotifier;

  // Abstract properties som skal implementeres af subclasses
  String get initiatorName;
  String? get initiatorCompany;
  String get confirmCode;
  DateTime get createdAt;
  DateTime get lastControlDateAt;
  String? get initiatorPhone;
  String? get websiteUrl;
  Map<String, dynamic>? get initiatorAddress;
  VoidCallback? get onConfirm;
  VoidCallback? get onReject;
  bool get history;
  int get action;
  String? get phoneCodesId;
  String? get logoPath;
  bool get demo;
  dynamic get viewType;

  // Abstract method for widget type name
  String getWidgetTypeName();

  // Display backend UTC times in user's local timezone
  DateTime get createdAtLocal => createdAt.toLocal();
  DateTime get lastControlledLocal => lastControlDateAt.toLocal();

  // Helper methods for action values
  bool get isConfirmed => action == 1;

  String getActionIcon() {
    switch (action) {
      case 1: // confirmed
        return 'assets/icons/phone/check_circle.svg';
      case -1: // rejected
      case -10: // timeout
      case -9: // cancelled
        return 'assets/icons/phone/cancel_circle.svg';
      default:
        return 'assets/icons/phone/cancel_circle.svg';
    }
  }

  Color getActionColor() {
    switch (action) {
      case 1: // confirmed
        return const Color(0xFF0E5D4A);
      case -1: // rejected
      case -10: // timeout
      case -9: // cancelled
        return const Color(0xFFC42121);
      default:
        return const Color(0xFFC42121);
    }
  }

  String getActionText() {
    switch (action) {
      case 1: // confirmed
        return I18nService().t('widget_phone_code.confirmed', fallback: 'Confirmed');
      case -1: // rejected
        return I18nService().t('widget_phone_code.cancelled', fallback: 'Rejected');
      case -10: // timeout
        return I18nService().t('widget_phone_code.timeout', fallback: 'Timeout');
      case -9: // cancelled
        return I18nService().t('widget_phone_code.cancelled', fallback: 'Cancelled');
      default:
        return I18nService().t('widget_phone_code.cancelled', fallback: 'Rejected');
    }
  }

  void trackEvent(WidgetRef ref, String eventName, Map<String, dynamic> properties) {
    final analytics = ref.read(analyticsServiceProvider);
    analytics.track(eventName, {
      ...properties,
      'widget': getWidgetTypeName(),
      'phone_codes_id': phoneCodesId ?? 'unknown',
      'view_type': viewType.toString(),
      'history': history,
      'demo': demo,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  @override
  void initState() {
    super.initState();
    timeAgoNotifier = ValueNotifier(getTimeAgo());

    // Start timer der opdaterer kun timer teksten hvert sekund
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      timeAgoNotifier.value = getTimeAgo();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    timeAgoNotifier.dispose();
    super.dispose();
  }

  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    final totalSeconds = difference.inSeconds;

    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    return 'Aktiv: ${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> markAsRead() async {
    if (phoneCodesId != null) {
      try {
        await ref.read(markPhoneCodeAsReadProvider(phoneCodesId!).future);
        log('${getWidgetTypeName()}._markAsRead - Markeret som læst: $phoneCodesId');
      } catch (e) {
        log('${getWidgetTypeName()}._markAsRead - Fejl ved markering som læst: $e');
        // Error handling is done in provider
      }
    }
  }

  Future<void> markAsRejected() async {
    if (phoneCodesId != null) {
      try {
        await ref.read(markPhoneCodeAsRejectedProvider(phoneCodesId!).future);
        log('${getWidgetTypeName()}._markAsRejected - Markeret som afvist: $phoneCodesId');
      } catch (e) {
        log('${getWidgetTypeName()}._markAsRejected - Fejl ved markering som afvist: $e');
        // Error handling is done in provider
      }
    }
  }

  void handleConfirm(WidgetRef ref) {
    log('${getWidgetTypeName()}._handleConfirm - Bekræfter telefon kode${demo ? ' (demo mode)' : ''}');
    trackEvent(ref, '${getWidgetTypeName()}_confirm_pressed', {
      'initiator_name': initiatorName,
      'initiator_company': initiatorCompany ?? 'unknown',
    });
    if (!demo) {
      markAsRead();
    }
    onConfirm?.call();
  }

  void handleReject(WidgetRef ref) {
    log('${getWidgetTypeName()}._handleReject - Afviser telefon kode${demo ? ' (demo mode)' : ''}');
    trackEvent(ref, '${getWidgetTypeName()}_reject_pressed', {
      'initiator_name': initiatorName,
      'initiator_company': initiatorCompany ?? 'unknown',
    });
    if (!demo) {
      markAsRejected();
    }
    onReject?.call();
  }
}

// Created: 2025-01-29 15:45:00
