import 'package:doggylog/app/router/app_router.dart';
import 'package:doggylog/app/theme/app_theme.dart';
import 'package:doggylog/features/shared/application/doggylog_providers.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DoggyLogApp extends ConsumerStatefulWidget {
  const DoggyLogApp({super.key});

  @override
  ConsumerState<DoggyLogApp> createState() => _DoggyLogAppState();
}

class _DoggyLogAppState extends ConsumerState<DoggyLogApp>
    with WidgetsBindingObserver {
  AppLifecycleState? _lifecycleState;
  bool _unlockInFlight = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _attemptUnlockIfNeeded(ref.read(appStateProvider));
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycleState = state;
    final controller = ref.read(appStateProvider.notifier);
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      controller.lockAppIfNeeded();
    }
    if (state == AppLifecycleState.resumed) {
      _attemptUnlockIfNeeded(ref.read(appStateProvider));
    }
  }

  Future<void> _attemptUnlockIfNeeded(AppState state) async {
    if (_unlockInFlight ||
        !mounted ||
        !state.preferences.faceIdEnabled ||
        !state.biometricAvailable ||
        state.appUnlocked) {
      return;
    }
    _unlockInFlight = true;
    try {
      await ref.read(appStateProvider.notifier).unlockApp();
    } finally {
      _unlockInFlight = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    ref.listen(appStateProvider, (_, next) {
      if (_lifecycleState == null ||
          _lifecycleState == AppLifecycleState.resumed) {
        _attemptUnlockIfNeeded(next);
      }
    });
    final state = ref.watch(appStateProvider);
    return MaterialApp.router(
      title: 'DoggyLog',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: router,
      builder: (context, child) {
        return Stack(
          children: [
            child ?? const SizedBox.shrink(),
            if (state.preferences.faceIdEnabled &&
                state.biometricAvailable &&
                !state.appUnlocked)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.58),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: Card(
                        margin: const EdgeInsets.all(24),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.lock_rounded, size: 42),
                              const SizedBox(height: 14),
                              Text(
                                'DoggyLog 已锁定',
                                style: Theme.of(context).textTheme.titleLarge,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '使用 Face ID / Touch ID 恢复访问。',
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                              if (state.lastSyncMessage != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  state.lastSyncMessage!,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                              const SizedBox(height: 18),
                              FilledButton.icon(
                                onPressed: () => _attemptUnlockIfNeeded(state),
                                icon: const Icon(Icons.fingerprint_rounded),
                                label: const Text('立即解锁'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
