import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../exports.dart';

part 'generated/text_code_search_result_provider.g.dart';

@riverpod
class TextCodeSearchResult extends _$TextCodeSearchResult {
  static final log = scopedLogger(LogCategory.provider);

  @override
  bool build() {
    return false; // Default: no result
  }

  void setHasResult(bool hasResult) {
    log('Setting text code search result: $hasResult');
    state = hasResult;
  }
}

// Created on 2025-01-16 at 18:00

