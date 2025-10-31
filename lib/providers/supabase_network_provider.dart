import '../exports.dart';

// TODO(temporary-network-guard): remove when moving to full gateway
// Global offline/online flag
final networkOfflineProvider = StateProvider<bool>((ref) => false);

// Backward-compat alias (if anything referenced the old name)
final supabaseNetworkProvider = networkOfflineProvider;

// Last valid location (incl. query) to restore after connection returns
final lastLocationProvider = StateProvider<String?>((ref) => null);

// Created: 2025-10-31 10:00
