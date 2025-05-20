import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../exports.dart';

Future<bool> validateSupabaseAuth(BuildContext context) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) {
    context.go(RoutePaths.settings);
  }

  final session = Supabase.instance.client.auth.currentSession;
  if (session == null) {
    context.go(RoutePaths.settings);
  }

  return user != null && session != null;
}

// Created on: 2024-07-18 11:30
