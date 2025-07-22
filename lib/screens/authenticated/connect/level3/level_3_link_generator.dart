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

  Future<void> _handleCopyInvitationLink(WidgetRef ref, TextEditingController controller) async {
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
      return;
    }

    try {
      final secretKey = await ref.read(storageProvider.notifier).getCurrentUserToken();

      if (secretKey == null) {
        if (!_context.mounted) return;
        CustomSnackBar.show(
          context: _context,
          text: I18nService().t('screen_contacts_connect_level_3_create_link.error_no_secret_key', fallback: 'Could not find secret key. Please try again.'),
          type: CustomTextType.button,
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        );
        return;
      }
      final commonToken = AESGCMEncryptionUtils.generateSecureToken();
      final commonKey = AESGCMEncryptionUtils.generateSecureToken();

      final encryptedInitiatorCommonToken = await AESGCMEncryptionUtils.encryptString(commonToken, secretKey);
      final encryptedReceiverCommonKey = await AESGCMEncryptionUtils.encryptString(commonToken, commonKey);

      final invitationId = await ref.read(createInvitationLevel3Provider(
        (
          initiatorEncryptedKey: encryptedInitiatorCommonToken,
          receiverEncryptedKey: encryptedReceiverCommonKey,
          receiverTempName: controller.text.trim(),
        ),
      ).future);

      if (commonKey.length != 64) {
        throw Exception('Common key must be exactly 64 characters long');
      }

      final base64EncodedKey = base64.encode(utf8.encode(commonKey));
      final invitationLink = 'https://link.idtruster.com/invitation/?invite=${Uri.encodeComponent(invitationId)}&key=${Uri.encodeComponent(base64EncodedKey)}';

      await Clipboard.setData(ClipboardData(text: invitationLink));

      if (!_context.mounted) return;

      CustomSnackBar.show(
        context: _context,
        text: I18nService().t('screen_contacts_connect_level_3_create_link.success_copy_link', fallback: 'Invitation link copied to clipboard'),
        type: CustomTextType.button,
        backgroundColor: Theme.of(_context).primaryColor,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      if (!_context.mounted) return;

      CustomSnackBar.show(
        context: _context,
        text: 'Error: ${e.toString()}',
        type: CustomTextType.button,
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      );
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
                await _handleCopyInvitationLink(ref, controller);
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
  final Future<void> Function(TextEditingController) onCopyLink;
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
      await widget.onCopyLink(_temporaryNameController);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: I18nService().t('screen_contacts_connect_level_3_create_link.connect_online_header', fallback: 'Connect Online'),
          type: CustomTextType.head,
        ),
        Gap(AppDimensionsTheme.getLarge(context)),
        Gap(AppDimensionsTheme.getLarge(context)),
        Container(
          padding: const EdgeInsets.fromLTRB(25, 13, 25, 13),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                I18nService().t('screen_contacts_connect_level_3_create_link.connect_online_body', fallback: 'This connection will be '),
                textScaler: TextScaler.noScaling,
                style: TextStyle(
                  color: const Color(0xFFFFFFFF),
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.0,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  I18nService().t('screen_contacts_connect_level_3_create_link.connect_online_security_level', fallback: 'Security Level 3'),
                  textScaler: TextScaler.noScaling,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
              ),
            ],
          ),
        ),

        Gap(AppDimensionsTheme.getLarge(context)),
        Gap(AppDimensionsTheme.getLarge(context)),
        CustomHelpText(
          text: I18nService().t('screen_contacts_connect_level_3_create_link.connect_online_help_text', fallback: 'Enter a temporary name and click the button below to generate and copy an invitation link.'),
          type: CustomTextType.label,
          alignment: CustomTextAlignment.left,
        ),

        Gap(AppDimensionsTheme.getLarge(context)),
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

// Created: 2024-12-19 12:00:00
