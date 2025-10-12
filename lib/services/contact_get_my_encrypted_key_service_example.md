# Contact Get My Encrypted Key Integration

## Oversigt

Integration til at hente krypteret nøgle for en kontakt via Supabase RPC endpoint `contact_get_my_encrypted_key_for_contact`.

## Komponenter

### Service

- **Fil**: `lib/services/contact_get_my_encrypted_key_service.dart`
- **Metode**: `getMyEncryptedKeyForContact(String inputMyContactUserId)`
- **Return**: `Future<String?>` - Returnerer encrypted_key eller null hvis det fejler

### Provider

- **Fil**: `lib/providers/contact_get_my_encrypted_key_provider.dart`
- **Provider**: `contactGetMyEncryptedKeyProvider`
- **Parameter**: `inputMyContactUserId` (String)

### Model

Ingen model nødvendig - servicen returnerer direkte String (minimalistisk tilgang).

## Brug i UI

```dart
import 'package:idtruster/exports.dart';

class ExampleWidget extends ConsumerWidget {
  const ExampleWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myContactUserId = 'contact-user-id-here';

    // Hent encrypted key for kontakt
    final encryptedKeyAsync = ref.watch(
      contactGetMyEncryptedKeyProvider(myContactUserId)
    );

    return encryptedKeyAsync.when(
      data: (encryptedKey) {
        if (encryptedKey == null) {
          return const CustomText(text: 'Ingen nøgle fundet');
        }
        return CustomText(text: 'Encrypted key: $encryptedKey');
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => CustomText(
        text: 'Fejl: $error',
      ),
    );
  }
}
```

## Manuel service kald

```dart
// Hvis du skal bruge servicen direkte (ikke anbefalet)
final service = ContactGetMyEncryptedKeyService(Supabase.instance.client);
final encryptedKey = await service.getMyEncryptedKeyForContact(myContactUserId);
```

## API Response struktur

```json
[
  {
    "status_code": 200,
    "data": {
      "message": "Encrypted key retrieved successfully",
      "payload": {
        "role": "initiator",
        "contact_id": "c7b3225c-4181-4d94-b0ef-414be440d893",
        "encrypted_key": "DnQtYWkNY7oksntr:qgloPrc+lms+j1yHF9vb5XeCRmyLAG3nQEhYoeHvHrbsTMIbzNb5CTNUfu06oVPY4NrPljiMbXQ0yZjnIfOVCQ==:GU4VzFxtLY0RdQHDFK73pg=="
      },
      "success": true
    },
    "log_id": "c273c4c3-3cb0-46e6-ac79-91d3bcfd1671"
  }
]
```

Servicen parser dette og returnerer kun `encrypted_key` feltet som String.

## Logging

Servicen logger omfattende information via `app_logger`:

- RPC kald med input parameter
- Response data
- Success/fejl status
- Fejl og stack traces ved exceptions

## Fejlhåndtering

- Returnerer `null` hvis:
  - Response er null eller tom
  - success er false
  - Payload mangler
- Kaster exception ved uventede fejl (med logging)

---

Oprettet: 2025-10-07 14:30:00


