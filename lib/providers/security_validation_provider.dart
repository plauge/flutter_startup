import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/security_validation_provider.g.dart';

@riverpod
class SecurityValidationNotifier extends _$SecurityValidationNotifier {
  @override
  bool build() => false;

  void setValidated() => state = true;
  void reset() => state = false;
}
