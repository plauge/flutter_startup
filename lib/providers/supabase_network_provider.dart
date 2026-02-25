import '../exports.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// TODO(temporary-network-guard): remove when moving to full gateway
// Global offline/online flag
final networkOfflineProvider = StateProvider<bool>((ref) => false);

// Backward-compat alias (if anything referenced the old name)
final supabaseNetworkProvider = networkOfflineProvider;

// Last valid location (incl. query) to restore after connection returns
final lastLocationProvider = StateProvider<String?>((ref) => null);

// Reactive connectivity stream from the OS - fires instantly when WiFi/cellular changes
final connectivityStreamProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

// Created: 2025-10-31 10:00
