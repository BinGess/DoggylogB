import 'package:doggylog/features/home/presentation/home_shell.dart';
import 'package:doggylog/features/onboarding/presentation/onboarding_screen.dart';
import 'package:doggylog/features/shared/application/doggylog_providers.dart';
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

final hasCompletedOnboardingProvider = Provider<bool>((ref) {
  return ref.watch(
    appStateProvider.select(
      (state) => state.preferences.hasCompletedOnboarding,
    ),
  );
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final hasOnboarded = ref.watch(hasCompletedOnboardingProvider);
  return GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
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

      final onboarding = state.matchedLocation == '/onboarding';
      if (!hasOnboarded && !onboarding) {
        return '/onboarding';
      }
      if (hasOnboarded && onboarding) {
        return '/';
      }
      return null;
    },
  );
});
