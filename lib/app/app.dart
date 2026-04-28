import 'package:doggylog/app/localization/app_localizations.dart';
import 'package:doggylog/app/router/app_router.dart';
import 'package:doggylog/app/theme/app_skin_theme.dart';
import 'package:doggylog/app/theme/app_theme.dart';
import 'package:doggylog/features/shared/application/doggylog_providers.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

AppSkinTheme? activeSkinThemeForState(AppState state) {
  final selectedPet = state.selectedPet;
  return selectedPet == null ? null : appSkinThemeForBreed(selectedPet.breed);
}

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
    final skinTheme = activeSkinThemeForState(state);
    final themeSkin = skinTheme ?? AppSkinTheme.shibaJoy;
    final locale = state.preferences.languageMode == AppLanguageMode.system
        ? null
        : resolveAppLocale(state.preferences.languageMode);
    return MaterialApp.router(
      title: AppLocalizations.current(
        mode: state.preferences.languageMode,
      ).appTitle,
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      themeMode: ThemeMode.system,
      theme: AppTheme.light(
        fontScale: state.preferences.fontScale,
        skinTheme: themeSkin,
      ),
      darkTheme: AppTheme.dark(
        fontScale: state.preferences.fontScale,
        skinTheme: themeSkin,
      ),
      routerConfig: router,
      builder: (context, child) {
        if (skinTheme == null) {
          return const _InitialAppSurface();
        }
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
                                context.l10n.unlockSheetTitle,
                                style: Theme.of(context).textTheme.titleLarge,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                context.l10n.unlockSheetSubtitle,
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
                                label: Text(context.l10n.unlockNow),
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

class _InitialAppSurface extends StatelessWidget {
  const _InitialAppSurface();

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    return ColoredBox(
      color: brightness == Brightness.dark
          ? const Color(0xFF111827)
          : const Color(0xFFF8FAFC),
    );
  }
}
