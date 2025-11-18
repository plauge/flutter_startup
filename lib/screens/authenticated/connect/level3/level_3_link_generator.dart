import '../../../../exports.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../../../../services/i18n_service.dart';
import 'dart:io'; // Added for Platform detection

class Level3LinkGeneratorScreen extends AuthenticatedScreen {
  Level3LinkGeneratorScreen({super.key});
  late BuildContext _context;

  static Future<Level3LinkGeneratorScreen> create() async {
    final screen = Level3LinkGeneratorScreen();
    return AuthenticatedScreen.create(screen);
  }

  Future<String?> _handleCopyInvitationLink(WidgetRef ref, TextEditingController controller) async {
    if (controller.text.trim().isEmpty) {
      showDialog(
        context: _context,
        builder: (context) => AlertDialog(
          title: CustomText(
            text: I18nService().t('screen_contacts_connect_level_3_create_link.error_title', fallback: 'Error'),
            type: CustomTextType.head,
          ),
          content: CustomText(
            text: I18nService().t('screen_contacts_connect_level_3_create_link.error_body', fallback: 'Please enter a temporary name'),
            type: CustomTextType.bread,
          ),
          actions: [
            CustomButton(
              text: I18nService().t('screen_contacts_connect_level_3_create_link.error_button', fallback: 'OK'),
              onPressed: () => Navigator.pop(context),
              buttonType: CustomButtonType.primary,
            ),
          ],
        ),
      );
      return null;
    }

    try {
      final secretKey = await ref.read(storageProvider.notifier).getCurrentUserToken();

      if (secretKey == null) {
        if (!_context.mounted) return null;
        CustomSnackBar.show(
          context: _context,
          text: I18nService().t('screen_contacts_connect_level_3_create_link.error_no_secret_key', fallback: 'Could not find secret key. Please try again.'),
          type: CustomTextType.button,
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        );
        return null;
      }
      final commonToken = AESGCMEncryptionUtils.generateSecureToken();
      final commonKey = AESGCMEncryptionUtils.generateSecureToken();

      final encryptedInitiatorCommonToken = await AESGCMEncryptionUtils.encryptString(commonToken, secretKey);
      final encryptedReceiverCommonKey = await AESGCMEncryptionUtils.encryptString(commonToken, commonKey);

      final result = await ref.read(createInvitationLevel3V2Provider(
        (
          initiatorEncryptedKey: encryptedInitiatorCommonToken,
          receiverEncryptedKey: encryptedReceiverCommonKey,
          receiverTempName: controller.text.trim(),
        ),
      ).future);
      final invitationCode = result['invitation_level_3_code']!;

      // Log invitation code details for debugging
      debugPrint('🔍 Generated invitation code: $invitationCode');
      debugPrint('🔍 Invitation code length: ${invitationCode.length}');
      debugPrint('🔍 Invitation code contains "-": ${invitationCode.contains('-')}');

      // Validate invitation code format - should be exactly 13 characters and start with "idti"
      if (invitationCode.length != 13) {
        debugPrint('⚠️ WARNING: Invitation code length is ${invitationCode.length}, expected 13');
      }
      if (!invitationCode.toLowerCase().startsWith('idti')) {
        debugPrint('⚠️ WARNING: Invitation code does not start with "idti"');
      }
      if (invitationCode.contains('-')) {
        debugPrint('⚠️ WARNING: Invitation code contains "-" character at position ${invitationCode.indexOf('-')}');
      }

      if (commonKey.length != 64) {
        throw Exception('Common key must be exactly 64 characters long');
      }

      final base64EncodedKey = base64.encode(utf8.encode(commonKey));
      debugPrint('🔍 Base64 encoded key: $base64EncodedKey');
      debugPrint('🔍 Base64 encoded key length: ${base64EncodedKey.length}');

      // final invitationLink = 'https://link.idtruster.com/invitation/?invite=${Uri.encodeComponent(invitationCode)}&key=${Uri.encodeComponent(base64EncodedKey)}';
      final invitationLink = '${Uri.encodeComponent(invitationCode)}${Uri.encodeComponent(base64EncodedKey)}';
      debugPrint('🔍 Generated invitation link (before encoding): ${invitationCode}${base64EncodedKey}');
      debugPrint('🔍 Generated invitation link (after encoding): $invitationLink');
      debugPrint('🔍 Invitation link length: ${invitationLink.length}');

      await Clipboard.setData(ClipboardData(text: invitationLink));

      return invitationLink;
    } catch (e) {
      if (!_context.mounted) return null;

      CustomSnackBar.show(
        context: _context,
        text: 'Error: ${e.toString()}',
        type: CustomTextType.button,
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      );
      return null;
    }
  }

  void _showOnlineConnectionInfo(BuildContext context) {
    // TODO: Implement online connection info modal
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState auth,
  ) {
    _context = context;
    return Scaffold(
      appBar: AuthenticatedAppBar(title: I18nService().t('screen_contacts_connect_level_3_create_link.connect_online_header', fallback: 'Connect online'), backRoutePath: RoutePaths.connect),
      body: GestureDetector(
        onTap: () {
          // Fjern focus fra alle input felter og luk keyboardet
          FocusScope.of(context).unfocus();
        },
        child: AppTheme.getParentContainerStyle(context).applyToContainer(
          child: SingleChildScrollView(
            child: _ConnectLevel3Content(
              onCopyLink: (controller) async {
                return await _handleCopyInvitationLink(ref, controller);
              },
              onShowInfo: () => _showOnlineConnectionInfo(context),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConnectLevel3Content extends StatefulWidget {
  final Future<String?> Function(TextEditingController) onCopyLink;
  final VoidCallback onShowInfo;

  const _ConnectLevel3Content({
    required this.onCopyLink,
    required this.onShowInfo,
  });

  @override
  State<_ConnectLevel3Content> createState() => _ConnectLevel3ContentState();
}

class _ConnectLevel3ContentState extends State<_ConnectLevel3Content> {
  late final TextEditingController _temporaryNameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _temporaryNameController = TextEditingController();
  }

  @override
  void dispose() {
    _temporaryNameController.dispose();
    super.dispose();
  }

  void _handleCopyLink() {
    setState(() {
      _isLoading = true;
    });

    // Vent på at UI er opdateret før vi starter den asynkrone proces
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final invitationLink = await widget.onCopyLink(_temporaryNameController);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        if (invitationLink != null) {
          _InvitationLinkModal.show(context, invitationLink);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomText(
          text: I18nService().t('screen_contacts_connect_level_3_create_link.connect_online_header', fallback: 'Connect Online'),
          type: CustomTextType.head,
          alignment: CustomTextAlignment.center,
        ),
        //Gap(AppDimensionsTheme.getLarge(context)),
        // Gap(AppDimensionsTheme.getLarge(context)),
        // Container(
        //   padding: const EdgeInsets.fromLTRB(25, 13, 25, 13),
        //   decoration: BoxDecoration(
        //     color: Colors.black,
        //     borderRadius: BorderRadius.circular(10),
        //   ),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       Text(
        //         I18nService().t('screen_contacts_connect_level_3_create_link.connect_online_body', fallback: 'This connection will be '),
        //         textScaler: TextScaler.noScaling,
        //         style: TextStyle(
        //           color: const Color(0xFFFFFFFF),
        //           fontFamily: 'Poppins',
        //           fontSize: 14,
        //           fontWeight: FontWeight.w400,
        //           height: 1.0,
        //         ),
        //       ),
        //       Container(
        //         padding: const EdgeInsets.symmetric(
        //           horizontal: 8,
        //           vertical: 9,
        //         ),
        //         decoration: BoxDecoration(
        //           color: Colors.orange,
        //           borderRadius: BorderRadius.circular(6),
        //         ),
        //         child: Text(
        //           I18nService().t('screen_contacts_connect_level_3_create_link.connect_online_security_level', fallback: 'Security Level 3'),
        //           textScaler: TextScaler.noScaling,
        //           textAlign: TextAlign.center,
        //           style: TextStyle(
        //             color: Color(0xFFFFFFFF),
        //             fontFamily: 'Poppins',
        //             fontSize: 12,
        //             fontWeight: FontWeight.w700,
        //             height: 1.15,
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),

        //Gap(AppDimensionsTheme.getLarge(context)),
        Gap(AppDimensionsTheme.getLarge(context)),
        CustomHelpText(
          text: I18nService().t('screen_contacts_connect_level_3_create_link.connect_online_help_text', fallback: 'Enter a temporary name and click the button below to generate and copy an invitation link.'),
          type: CustomTextType.label,
          alignment: CustomTextAlignment.left,
        ),

        //Gap(AppDimensionsTheme.getLarge(context)),
        // TextFormField(
        //   controller: _temporaryNameController,
        //   decoration: AppTheme.getTextFieldDecoration(context).copyWith(
        //     labelText: 'Temporary name',
        //     hintText: 'Enter a temporary name',
        //   ),
        // ),
        Gap(AppDimensionsTheme.getLarge(context)),
        CustomTextFormField(
          controller: _temporaryNameController,
          labelText: I18nService().t('screen_contacts_connect_level_3_create_link.connect_online_temporary_name_label', fallback: 'Enter a temporary name'),
        ),
        Gap(AppDimensionsTheme.getLarge(context)),
        Builder(
          builder: (context) {
            final copyButton = CustomButton(
              key: const Key('level3_copy_invitation_link_button'),
              text: I18nService().t('screen_contacts_connect_level_3_create_link.connect_online_copy_invitation_link', fallback: 'Copy Invitation Link'),
              onPressed: _handleCopyLink,
              buttonType: CustomButtonType.primary,
            );

            return Platform.isAndroid ? SafeArea(top: false, child: copyButton) : copyButton;
          },
        ),
        if (_isLoading)
          Column(
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: const CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.black,
                ),
              ),
              Gap(AppDimensionsTheme.getSmall(context)),
              CustomText(
                text: I18nService().t('screen_contacts_connect_level_3_create_link.connect_online_creating_secure_link', fallback: 'Creating secure link'),
                type: CustomTextType.bread,
              ),
              // Add additional widgets here
            ],
          ),
        // Gap(AppDimensionsTheme.getLarge(context)),
        // CustomButton(
        //   text: 'Read About Online Connections',
        //   onPressed: widget.onShowInfo,
        //   icon: Icons.info_outline,
        //   buttonType: CustomButtonType.secondary,
        // ),
      ],
    );
  }
}

class _InvitationLinkModal extends StatelessWidget {
  final String invitationLink;

  const _InvitationLinkModal({
    required this.invitationLink,
  });

  static void show(BuildContext context, String invitationLink) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _InvitationLinkModal(invitationLink: invitationLink),
    );
  }

  String _getTruncatedLink(String link) {
    if (link.length <= 30) {
      return link;
    }
    return '${link.substring(0, 30)}...';
  }

  void _copyLinkToClipboard(BuildContext context, String link) {
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          I18nService().t(
            'screen_contacts_connect_level_3_create_link.link_copied',
            fallback: 'Link copied to clipboard',
          ),
          style: AppTheme.getBodyMedium(context).copyWith(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header row with close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    I18nService().t(
                      'screen_contacts_connect_level_3_create_link.invitation_link_title',
                      fallback: 'Invitation Link',
                    ),
                    style: AppTheme.getHeadingMedium(context),
                  ),
                  GestureDetector(
                    key: const Key('invitation_link_modal_close_button'),
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Color(0xFF014459),
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
              Gap(AppDimensionsTheme.getLarge(context)),
              // Link display
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF014459),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      I18nService().t(
                        'screen_contacts_connect_level_3_create_link.use_this_link',
                        fallback: 'Use this link:',
                      ),
                      style: AppTheme.getBodyMedium(context).copyWith(
                        color: const Color(0xFF014459),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Gap(AppDimensionsTheme.getMedium(context)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF014459)),
                      ),
                      child: SelectableText(
                        _getTruncatedLink(invitationLink),
                        style: AppTheme.getBodyMedium(context).copyWith(
                          color: const Color(0xFF014459),
                          fontSize: 14,
                          fontFamily: 'Courier',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Gap(AppDimensionsTheme.getLarge(context)),
              // Confirmation message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[300]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green[600],
                      size: 20,
                    ),
                    Gap(AppDimensionsTheme.getSmall(context)),
                    Expanded(
                      child: Text(
                        I18nService().t(
                          'screen_contacts_connect_level_3_create_link.link_in_clipboard',
                          fallback: 'The link has been copied to your clipboard. Only send the link through channels where you are certain of the recipient\'s identity.',
                        ),
                        style: AppTheme.getBodyMedium(context).copyWith(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Gap(AppDimensionsTheme.getLarge(context)),
              // Copy button (for manual copy if needed)
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  key: const Key('invitation_link_modal_copy_button'),
                  text: I18nService().t(
                    'screen_contacts_connect_level_3_create_link.copy_link_again',
                    fallback: 'Copy Link Again',
                  ),
                  onPressed: () => _copyLinkToClipboard(context, invitationLink),
                  buttonType: CustomButtonType.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Created: 2024-12-19 12:00:00
