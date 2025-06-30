import '../../exports.dart';

class ConfirmPayloadTestDataWidget extends StatelessWidget {
  final ConfirmPayload confirmPayload;
  final String? title;

  const ConfirmPayloadTestDataWidget({
    super.key,
    required this.confirmPayload,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: title ?? 'ConfirmPayload indhold:',
            type: CustomTextType.info,
            alignment: CustomTextAlignment.left,
          ),
          Gap(AppDimensionsTheme.getSmall(context)),
          _buildDataRow(context, 'Confirms ID:', confirmPayload.confirmsId),
          _buildDataRow(context, 'Contacts ID:', confirmPayload.contactsId),
          _buildDataRow(context, 'Status:', confirmPayload.status.toString()),
          _buildDataRow(context, 'Question:', confirmPayload.question ?? 'N/A'),
          _buildDataRow(context, 'Created At:', confirmPayload.createdAt.toString()),
          _buildDataRow(context, 'New Record:', confirmPayload.newRecord.toString()),
          _buildDataRow(context, 'Initiator User ID:', confirmPayload.initiatorUserId ?? 'N/A'),
          _buildDataRow(context, 'Encrypted Initiator Question:', confirmPayload.encryptedInitiatorQuestion ?? 'N/A'),
          _buildDataRow(context, 'Encrypted Initiator Answer:', confirmPayload.encryptedInitiatorAnswer ?? 'N/A'),
          _buildDataRow(context, 'Initiator Status:', confirmPayload.initiatorStatus?.toString() ?? 'N/A'),
          _buildDataRow(context, 'Receiver User ID:', confirmPayload.receiverUserId ?? 'N/A'),
          _buildDataRow(context, 'Encrypted Receiver Question:', confirmPayload.encryptedReceiverQuestion ?? 'N/A'),
          _buildDataRow(context, 'Encrypted Receiver Answer:', confirmPayload.encryptedReceiverAnswer ?? 'N/A'),
          _buildDataRow(context, 'Receiver Status:', confirmPayload.receiverStatus?.toString() ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildDataRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppDimensionsTheme.getSmall(context)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: CustomText(
              text: label,
              type: CustomTextType.info,
              alignment: CustomTextAlignment.left,
            ),
          ),
          Expanded(
            flex: 3,
            child: CustomText(
              text: value,
              type: CustomTextType.bread,
              alignment: CustomTextAlignment.left,
            ),
          ),
        ],
      ),
    );
  }
}

// Created on 2025-01-27 at 14:05:00
