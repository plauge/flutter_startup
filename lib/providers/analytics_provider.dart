import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/analytics_service.dart';
import '../utils/app_logger.dart';

part 'generated/analytics_provider.g.dart';

@riverpod
AnalyticsService analyticsService(AnalyticsServiceRef ref) {
  final log = scopedLogger(LogCategory.service);
  log('lib/providers/analytics_provider.dart - analyticsService provider called');

  final service = AnalyticsService();
  log('lib/providers/analytics_provider.dart - calling service.initialize()');
  service.initialize();
  log('lib/providers/analytics_provider.dart - service.initialize() called, returning service');
  return service;
}

// Created on 2024-12-30 at 16:30
