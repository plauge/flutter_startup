import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import 'generated/route_explorer.g.dart';
import 'models/route_info.dart';

class RouteExplorerScreen extends StatefulWidget {
  const RouteExplorerScreen({super.key});

  @override
  State<RouteExplorerScreen> createState() => _RouteExplorerScreenState();
}

class _RouteExplorerScreenState extends State<RouteExplorerScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (!kDebugMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/home');
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Gruppér routes baseret på deres path
  Map<String, List<RouteInfo>> _getGroupedRoutes() {
    final routes =
        getGeneratedRoutes(); // Use generated list instead of hardcoded

    // Filtrér baseret på søgning
    final filteredRoutes = _searchQuery.isEmpty
        ? routes
        : routes
            .where((route) =>
                route.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                route.path.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    // Gruppér routes
    final Map<String, List<RouteInfo>> groupedRoutes = {};

    for (var route in filteredRoutes) {
      String group = 'Other';

      if (route.path.startsWith('/onboarding')) {
        group = 'Onboarding';
      } else if (route.path.startsWith('/connect')) {
        group = 'Connect';
      } else if (route.path.startsWith('/test')) {
        group = 'Test';
      } else if (route.path.startsWith('/system-status')) {
        group = 'System Status';
      } else if (route.path == '/login' ||
          route.path == '/login_check_email' ||
          route.path == '/auth-callback') {
        group = 'Authentication';
      } else if (route.path == '/home' || route.path == '/contacts') {
        group = 'Main Navigation';
      }

      if (!groupedRoutes.containsKey(group)) {
        groupedRoutes[group] = [];
      }
      groupedRoutes[group]!.add(route);
    }

    return groupedRoutes;
  }

  @override
  Widget build(BuildContext context) {
    final groupedRoutes = _getGroupedRoutes();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Explorer'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search routes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: groupedRoutes.length,
              itemBuilder: (context, index) {
                final groupName = groupedRoutes.keys.elementAt(index);
                final routes = groupedRoutes[groupName]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        groupName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    ...routes.map((route) => Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          child: ListTile(
                            title: Text(route.name),
                            subtitle: Text(route.path),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              context.push(route.path);
                            },
                          ),
                        )),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
