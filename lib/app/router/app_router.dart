import 'package:doggylog/features/home/presentation/home_shell.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

String? normalizeExternalLocation(Uri uri) {
  if (uri.scheme != 'doggylog') {
    return null;
  }

  if (uri.host == 'tab' && uri.pathSegments.isNotEmpty) {
    return '/tab/${uri.pathSegments.first}';
  }

  return '/';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/onboarding', redirect: (context, state) => '/'),
      GoRoute(path: '/', builder: (context, state) => const HomeShell()),
      GoRoute(
        path: '/tab/:tab',
        builder: (context, state) =>
            HomeShell(initialTabId: state.pathParameters['tab']),
      ),
    ],
    redirect: (context, state) {
      final normalized = normalizeExternalLocation(state.uri);
      if (normalized != null &&
          normalized != state.matchedLocation &&
          normalized != state.uri.path) {
        return normalized;
      }
      return null;
    },
  );
});
