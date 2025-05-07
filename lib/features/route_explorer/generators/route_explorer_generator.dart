import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';

Builder routeExplorerBuilder(BuilderOptions options) =>
    RouteExplorerGenerator();

class RouteExplorerGenerator extends Builder {
  @override
  Future<void> build(BuildStep buildStep) async {
    final inputId = buildStep.inputId;
    final outputId = AssetId(
      inputId.package,
      'lib/features/route_explorer/generated/route_explorer.g.dart',
    );

    final library = await buildStep.inputLibrary;
    final routePathsClass = library.topLevelElements
        .whereType<ClassElement>()
        .where((element) => element.name == 'RoutePaths')
        .firstOrNull;
    if (routePathsClass == null) return;

    final routes = <String>[];
    for (final field in routePathsClass.fields) {
      if (field.isStatic && field.type.isDartCoreString) {
        final value = field.computeConstantValue();
        if (value != null) {
          routes.add('''
    RouteInfo(
      name: '${field.name}',
      path: RoutePaths.${field.name},
    ),''');
        }
      }
    }

    final content = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:idtruster/core/router/app_router.dart';
import 'package:idtruster/features/route_explorer/models/route_info.dart';

List<RouteInfo> getGeneratedRoutes() {
  return [
${routes.join('\n')}
  ];
}
''';

    await buildStep.writeAsString(outputId, content);
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        'lib/core/router/app_router.dart': [
          'lib/features/route_explorer/generated/route_explorer.g.dart'
        ],
      };
}
