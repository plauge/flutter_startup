import '../../../exports.dart';

class Contact {
  final String id;
  final String name;
  final String email;
  final String phone;

  Contact({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
    );
  }
}

final contactsProvider = FutureProvider<List<Contact>>((ref) async {
  // Simuler netværksforsinkelse for at teste loading state
  await Future.delayed(const Duration(milliseconds: 800));

  return [
    Contact(
      id: '1',
      name: 'John Doe',
      email: 'john@example.com',
      phone: '+45 12 34 56 78',
    ),
    Contact(
      id: '2',
      name: 'Jane Smith',
      email: 'jane@example.com',
      phone: '+45 23 45 67 89',
    ),
    Contact(
      id: '3',
      name: 'Peter Jensen',
      email: 'peter@example.com',
      phone: '+45 34 56 78 90',
    ),
    Contact(
      id: '4',
      name: 'Maria Nielsen',
      email: 'maria@example.com',
      phone: '+45 45 67 89 01',
    ),
    Contact(
      id: '5',
      name: 'Anders Hansen',
      email: 'anders@example.com',
      phone: '+45 56 78 90 12',
    ),
  ];
});

class ContactsAllWidget extends StatelessWidget {
  final AppUser user;
  final String authToken;

  const ContactsAllWidget({
    required this.user,
    required this.authToken,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final contactsAsync = ref.watch(contactsProvider);

        return contactsAsync.when(
          data: (contacts) => Column(
            children: [
              Container(
                padding: EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
                color: AppColors.primaryColor(context).withOpacity(0.1),
                child: Text(
                  'Total Contacts: ${contacts.length}',
                  style: AppTheme.getBodyMedium(context)
                      .copyWith(color: Colors.black),
                ),
              ),
              Gap(AppDimensionsTheme.getSmall(context)),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  return Container(
                    padding:
                        EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
                    color: AppColors.primaryColor(context).withOpacity(0.1),
                    margin: EdgeInsets.only(
                        bottom: AppDimensionsTheme.getSmall(context)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Name: ${contact.name}',
                          style: AppTheme.getBodyMedium(context)
                              .copyWith(color: Colors.black),
                        ),
                        Text(
                          'Email: ${contact.email}',
                          style: AppTheme.getBodyMedium(context)
                              .copyWith(color: Colors.black),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => SelectableText.rich(
            TextSpan(
              text: 'Error: ',
              children: [
                TextSpan(
                  text: error.toString(),
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
