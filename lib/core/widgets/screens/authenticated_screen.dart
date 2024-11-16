import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_screen.dart';

abstract class AuthenticatedScreen extends BaseScreen {
  const AuthenticatedScreen({super.key});

  Widget buildAuthenticatedWidget(BuildContext context, WidgetRef ref);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return buildAuthenticatedWidget(context, ref);
  }
}
