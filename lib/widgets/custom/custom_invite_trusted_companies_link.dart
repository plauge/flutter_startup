import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/i18n_service.dart';

/// A reusable link widget that copies the ID-Truster business invite link to clipboard and shows a snackbar.
/// Test key: Key('invite_trusted_companies_link')
class CustomInviteTrustedCompaniesLink extends StatelessWidget {
  /// Optional: Allows overriding the snackbar context (for nested usage)
  final BuildContext? snackbarContext;
  const CustomInviteTrustedCompaniesLink({Key? key, this.snackbarContext}) : super(key: key ?? const Key('invite_trusted_companies_link'));

  static const String _link = 'https://idtruster.com/businesses/';

  void _handleTap(BuildContext context) async {
    await Clipboard.setData(const ClipboardData(text: _link));
    ScaffoldMessenger.of(snackbarContext ?? context).showSnackBar(
      SnackBar(
        content: Text(
          I18nService().t(
            'widget_invite_trusted_companies.snackbar_text',
            fallback: 'Link copied! You can now send it to a company.',
          ),
          style: const TextStyle(color: Colors.white),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: key,
      onTap: () => _handleTap(context),
      child: Text.rich(
        TextSpan(
          text: I18nService().t(
            'widget_invite_trusted_companies.link_text',
            fallback: 'Make it safer for all.\nInvite trusted companies to use ID-Truster.',
          ),
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            decoration: TextDecoration.underline,
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// Oprettet: 2025-01-16 15:30
