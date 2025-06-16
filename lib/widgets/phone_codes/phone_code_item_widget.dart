import '../../exports.dart';

class PhoneCodeItemWidget extends ConsumerStatefulWidget {
  final PhoneCode phoneCode;
  final bool showAll;
  final bool swipeAction;

  const PhoneCodeItemWidget({
    super.key,
    required this.phoneCode,
    this.showAll = false,
    this.swipeAction = false,
  });

  @override
  ConsumerState<PhoneCodeItemWidget> createState() => _PhoneCodeItemWidgetState();
}

class _PhoneCodeItemWidgetState extends ConsumerState<PhoneCodeItemWidget> {
  late bool _showAllDetails;

  @override
  void initState() {
    super.initState();
    _showAllDetails = widget.showAll;
  }

  void _toggleDetails() {
    setState(() {
      _showAllDetails = !_showAllDetails;
    });
  }

  Future<void> _markAsRead() async {
    try {
      await ref.read(markPhoneCodeAsReadProvider(widget.phoneCode.phoneCodesId).future);
    } catch (e) {
      // Error handling is done in provider
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardWidget = Card(
      margin: EdgeInsets.symmetric(
        vertical: AppDimensionsTheme.getSmall(context),
        horizontal: AppDimensionsTheme.getMedium(context),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const CustomText(
                  text: '',
                  type: CustomTextType.info,
                ),
                Text(
                  widget.phoneCode.receiverRead ? 'Læst' : 'Ulæst',
                  style: TextStyle(
                    color: widget.phoneCode.receiverRead ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Gap(AppDimensionsTheme.getSmall(context)),

            // Vis initiator_info felter
            ..._buildInitiatorInfo(widget.phoneCode.initiatorInfo, context),

            // Vis opdateret dato kun hvis _showAllDetails er true
            //if (_showAllDetails) ...[
            Gap(AppDimensionsTheme.getLarge(context)),
            CustomText(
              text: 'Opdateret: ${widget.phoneCode.updatedAt.toLocal().toString().split('.')[0]}',
              type: CustomTextType.bread,
            ),
            //],

            Gap(AppDimensionsTheme.getSmall(context)),
            if (widget.phoneCode.initiatorCancel) ...[
              Gap(AppDimensionsTheme.getSmall(context)),
              const Text(
                'Status: Annulleret',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],

            // Toggle ikon i nederste højre hjørne
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: _toggleDetails,
                  icon: Icon(
                    _showAllDetails ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Theme.of(context).primaryColor,
                  ),
                  tooltip: _showAllDetails ? 'Skjul detaljer' : 'Vis detaljer',
                ),
              ],
            ),
          ],
        ),
      ),
    );

    // Return either dismissible wrapper or plain card
    if (widget.swipeAction) {
      return Dismissible(
        key: Key(widget.phoneCode.phoneCodesId),
        direction: DismissDirection.startToEnd,
        onDismissed: (direction) {
          _markAsRead();
        },
        background: Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: AppDimensionsTheme.getLarge(context)),
          color: Colors.green,
          child: const Icon(
            Icons.check,
            color: Colors.white,
            size: 32,
          ),
        ),
        child: cardWidget,
      );
    }

    return cardWidget;
  }

  List<Widget> _buildInitiatorInfo(Map<String, dynamic> initiatorInfo, BuildContext context) {
    List<Widget> widgets = [];

    if (initiatorInfo['name'] != null && initiatorInfo['name'].toString().isNotEmpty) {
      widgets.addAll([
        Gap(AppDimensionsTheme.getSmall(context)),
        CustomText(
          text: '${initiatorInfo['name']}',
          type: CustomTextType.info,
        ),
        Gap(AppDimensionsTheme.getSmall(context)),
      ]);
    }

    // Vis company og department hvis det findes
    if (initiatorInfo['company'] != null && initiatorInfo['company'].toString().isNotEmpty) {
      String companyText = '${initiatorInfo['company']}';

      // Tilføj department i parenteser hvis det findes
      if (initiatorInfo['department'] != null && initiatorInfo['department'].toString().isNotEmpty) {
        companyText += ' (${initiatorInfo['department']})';
      }

      widgets.addAll([
        Gap(AppDimensionsTheme.getSmall(context)),
        CustomText(
          text: companyText,
          type: CustomTextType.info,
        ),
        Gap(AppDimensionsTheme.getLarge(context)),
      ]);
    }

    // Her
    widgets.addAll([
      Gap(AppDimensionsTheme.getSmall(context)),
      CustomText(
        text: 'Kode: ${widget.phoneCode.confirmCode}',
        type: CustomTextType.info,
      ),
      //Gap(AppDimensionsTheme.getLarge(context)),
    ]);

    // Vis kun de følgende hvis _showAllDetails er true
    if (_showAllDetails) {
      widgets.addAll([
        Gap(AppDimensionsTheme.getSmall(context)),
      ]);

      // Vis address hvis det findes
      if (initiatorInfo['address'] != null && initiatorInfo['address'] is Map) {
        final address = initiatorInfo['address'] as Map<String, dynamic>;
        final addressParts = <String>[];

        if (address['street'] != null && address['street'].toString().isNotEmpty) {
          addressParts.add(address['street'].toString());
        }
        if (address['postal_code'] != null && address['postal_code'].toString().isNotEmpty) {
          addressParts.add(address['postal_code'].toString());
        }
        if (address['city'] != null && address['city'].toString().isNotEmpty) {
          addressParts.add(address['city'].toString());
        }
        if (address['region'] != null && address['region'].toString().isNotEmpty) {
          addressParts.add(address['region'].toString());
        }
        if (address['country'] != null && address['country'].toString().isNotEmpty) {
          addressParts.add(address['country'].toString());
        }

        if (addressParts.isNotEmpty) {
          widgets.addAll([
            Gap(AppDimensionsTheme.getSmall(context)),
            CustomText(
              text: 'Adresse: ${addressParts.join(', ')}',
              type: CustomTextType.bread,
            ),
          ]);
        }
      }

      // Vis phone hvis det findes
      if (initiatorInfo['phone'] != null && initiatorInfo['phone'].toString().isNotEmpty) {
        widgets.addAll([
          Gap(AppDimensionsTheme.getSmall(context)),
          CustomText(
            text: 'Telefon: ${initiatorInfo['phone']}',
            type: CustomTextType.bread,
          ),
        ]);
      }

      if (initiatorInfo['mobile'] != null && initiatorInfo['mobile'].toString().isNotEmpty) {
        widgets.addAll([
          Gap(AppDimensionsTheme.getSmall(context)),
          CustomText(
            text: 'Mobile: ${initiatorInfo['mobile']}',
            type: CustomTextType.bread,
          ),
        ]);
      }

      // Vis email hvis det findes
      if (initiatorInfo['email'] != null && initiatorInfo['email'].toString().isNotEmpty) {
        widgets.addAll([
          Gap(AppDimensionsTheme.getSmall(context)),
          CustomText(
            text: 'Email: ${initiatorInfo['email']}',
            type: CustomTextType.bread,
          ),
        ]);
      }
    }

    return widgets;
  }
}

// Created: 2025-01-16 15:00:00
