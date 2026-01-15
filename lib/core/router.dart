import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/app_shell.dart';
import 'services/tool_registry.dart';

// Defines the router provider
final routerProvider = Provider<GoRouter>((ref) {
  final tools = ref.watch(toolRegistryProvider);

  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Center(
              child: Text(
                'Welcome to DevToys Clone',
                style: TextStyle(fontSize: 24),
              ),
            ), // TODO: Replace with Tool Dashboard
          ),
          ...tools.map(
            (tool) => GoRoute(
              path: tool.route,
              builder: (context, state) => tool.builder(context),
            ),
          ),
        ],
      ),
    ],
  );
});
