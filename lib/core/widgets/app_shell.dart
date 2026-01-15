import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/tool_registry.dart';
import '../models/tool_item.dart';

class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toolsByCategory = ref.watch(toolsByCategoryProvider);
    final theme = Theme.of(context);
    final currentPath = GoRouterState.of(context).uri.path;

    // TODO: Make this adaptive (NavigationRail vs Drawer based on width)
    // For now, focusing on Desktop/Web structure with NavigationRail

    return Scaffold(
      body: Row(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: NavigationRail(
                      extended: MediaQuery.of(context).size.width > 900,
                      backgroundColor: theme.colorScheme.surface,
                      selectedIndex: _calculateSelectedIndex(
                        currentPath,
                        toolsByCategory,
                      ),
                      onDestinationSelected: (index) {
                        final destination = _getDestinationFromIndex(
                          index,
                          toolsByCategory,
                        );
                        if (destination != null) {
                          context.go(destination);
                        }
                      },
                      leading: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Icon(
                          Icons.handyman,
                          size: 32,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      destinations: [
                        const NavigationRailDestination(
                          icon: Icon(Icons.home_outlined),
                          selectedIcon: Icon(Icons.home),
                          label: Text('All Tools'),
                        ),
                        ..._buildToolDestinations(toolsByCategory),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(
    String path,
    Map<ToolCategory, List<ToolItem>> tools,
  ) {
    if (path == '/') return 0;

    int index = 1; // Start after 'Home'
    for (var category in ToolCategory.values) {
      final categoryTools = tools[category] ?? [];
      for (var tool in categoryTools) {
        if (path == tool.route) return index;
        index++;
      }
    }
    return 0;
  }

  String? _getDestinationFromIndex(
    int index,
    Map<ToolCategory, List<ToolItem>> tools,
  ) {
    if (index == 0) return '/';

    int currentIndex = 1;
    for (var category in ToolCategory.values) {
      final categoryTools = tools[category] ?? [];
      for (var tool in categoryTools) {
        if (currentIndex == index) return tool.route;
        currentIndex++;
      }
    }
    return null;
  }

  List<NavigationRailDestination> _buildToolDestinations(
    Map<ToolCategory, List<ToolItem>> tools,
  ) {
    final destinations = <NavigationRailDestination>[];

    for (var category in ToolCategory.values) {
      final categoryTools = tools[category] ?? [];
      // We could add headers here if NavigationRail supported them natively nicely
      // For now, just listing all tools flat
      for (var tool in categoryTools) {
        destinations.add(
          NavigationRailDestination(
            icon: Icon(tool.icon),
            label: Text(tool.name),
          ),
        );
      }
    }
    return destinations;
  }
}
