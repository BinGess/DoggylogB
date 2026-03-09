import 'package:doggylog/features/home/presentation/home_shell.dart';
import 'package:doggylog/features/onboarding/presentation/onboarding_screen.dart';
import 'package:doggylog/features/shared/application/doggylog_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final hasOnboarded = ref.watch(
    appStateProvider.select(
      (state) => state.preferences.hasCompletedOnboarding,
    ),
  );
  return GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/', builder: (context, state) => const HomeShell()),
    ],
    redirect: (context, state) {
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
