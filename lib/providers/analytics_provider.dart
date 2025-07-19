import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/analytics_service.dart';

part 'generated/analytics_provider.g.dart';

@riverpod
AnalyticsService analyticsService(AnalyticsServiceRef ref) {
  final service = AnalyticsService();
  service.initialize();
  return service;
}

// Created on 2024-12-30 at 16:30
