import '../../exports.dart';

class PhoneCodeItemWidget extends StatelessWidget {
  final PhoneCode phoneCode;

  const PhoneCodeItemWidget({
    super.key,
    required this.phoneCode,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
                  phoneCode.receiverRead ? 'Læst' : 'Ulæst',
                  style: TextStyle(
                    color: phoneCode.receiverRead ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Gap(AppDimensionsTheme.getSmall(context)),

            // Vis initiator_info felter
            ..._buildInitiatorInfo(phoneCode.initiatorInfo, context),
            Gap(AppDimensionsTheme.getLarge(context)),
            CustomText(
              text: 'Oprettet: ${phoneCode.createdAt.toLocal().toString().split('.')[0]}',
              type: CustomTextType.bread,
            ),
            Gap(AppDimensionsTheme.getSmall(context)),
            if (phoneCode.initiatorCancel) ...[
              Gap(AppDimensionsTheme.getSmall(context)),
              const Text(
                'Status: Annulleret',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
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
        text: 'Kode: ${phoneCode.confirmCode}',
        type: CustomTextType.info,
      ),
      Gap(AppDimensionsTheme.getLarge(context)),
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

    return widgets;
  }
}

// Created: 2025-01-16 15:00:00
