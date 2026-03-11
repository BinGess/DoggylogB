import 'dart:math' as math;

import 'package:doggylog/features/shared/application/doggylog_providers.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart' hide LinearGradient;

class AnimatedPetAvatar extends ConsumerStatefulWidget {
  const AnimatedPetAvatar({
    super.key,
    required this.breed,
    required this.mood,
    required this.sceneMode,
    this.size = 92,
  });

  final PetBreed breed;
  final PetMood mood;
  final SceneMode sceneMode;
  final double size;

  @override
  ConsumerState<AnimatedPetAvatar> createState() => _AnimatedPetAvatarState();
}

class _AnimatedPetAvatarState extends ConsumerState<AnimatedPetAvatar>
    with SingleTickerProviderStateMixin {
  static Future<bool>? _assetExistsFuture;

  late final AnimationController _fallbackController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  SMINumber? _moodInput;
  SMINumber? _sceneInput;
  SMINumber? _loyaltyInput;

  @override
  void dispose() {
    _fallbackController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AnimatedPetAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncRiveInputs();
  }

  void _handleRiveInit(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(
      artboard,
      'DoggyState',
    );
    if (controller == null) {
      return;
    }
    artboard.addController(controller);
    _moodInput = controller.findInput<double>('mood') as SMINumber?;
    _sceneInput = controller.findInput<double>('sceneMode') as SMINumber?;
    _loyaltyInput = controller.findInput<double>('loyaltyLevel') as SMINumber?;
    _syncRiveInputs();
  }

  void _syncRiveInputs() {
    _moodInput?.value = switch (widget.mood) {
      PetMood.excited => 3,
      PetMood.calm => 2,
      PetMood.lazy => 1,
      PetMood.sad => 0,
    };
    _sceneInput?.value = switch (widget.sceneMode) {
      SceneMode.home => 0,
      SceneMode.working => 1,
      SceneMode.walking => 2,
      SceneMode.resting => 3,
      SceneMode.caring => 4,
    };
    _loyaltyInput?.value =
        ref.read(appStateProvider).selectedPet?.loyaltyLevel.toDouble() ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _assetExistsFuture ??= _checkRiveAsset(),
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return _buildRiveAvatar();
        }
        return _FallbackPetAvatar(
          controller: _fallbackController,
          breed: widget.breed,
          mood: widget.mood,
          sceneMode: widget.sceneMode,
          size: widget.size,
        );
      },
    );
  }

  Widget _buildRiveAvatar() {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: ClipOval(
        child: RiveAnimation.asset(
          'assets/rive/doggy_companion.riv',
          artboard: widget.breed.name,
          fit: BoxFit.cover,
          onInit: _handleRiveInit,
        ),
      ),
    );
  }

  static Future<bool> _checkRiveAsset() async {
    try {
      await rootBundle.load('assets/rive/doggy_companion.riv');
      return true;
    } catch (_) {
      return false;
    }
  }
}

class _FallbackPetAvatar extends ConsumerWidget {
  const _FallbackPetAvatar({
    required this.controller,
    required this.breed,
    required this.mood,
    required this.sceneMode,
    required this.size,
  });

  final AnimationController controller;
  final PetBreed breed;
  final PetMood mood;
  final SceneMode sceneMode;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final motion = ref.watch(appStateProvider.select((state) => state.motion));
    final palette = switch (breed) {
      PetBreed.shiba => [const Color(0xFFF05D56), const Color(0xFF3DBA89)],
      PetBreed.goldenRetriever => [
        const Color(0xFF0066FF),
        const Color(0xFF38BDF8),
      ],
      PetBreed.beagle => [const Color(0xFF6366F1), const Color(0xFFA5B4FC)],
      PetBreed.husky => [const Color(0xFF4A90D9), const Color(0xFF87CEEB)],
      PetBreed.samoyed => [const Color(0xFFC96480), const Color(0xFF9B7BBF)],
    };
    final badge = switch (mood) {
      PetMood.excited => Icons.auto_awesome_rounded,
      PetMood.calm => Icons.spa_rounded,
      PetMood.lazy => Icons.bedtime_rounded,
      PetMood.sad => Icons.cloudy_snowing,
    };
    final amplitude = switch (mood) {
      PetMood.excited => 8.0,
      PetMood.calm => 4.0,
      PetMood.lazy => 2.0,
      PetMood.sad => 1.0,
    };
    final spin = sceneMode == SceneMode.walking ? 0.04 : 0.015;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final wave = math.sin(controller.value * math.pi * 2);
        return Transform.translate(
          offset: Offset(motion.x * 10, (wave * amplitude) + (motion.y * 8)),
          child: Transform.rotate(
            angle: (wave * spin) + (motion.x * 0.06),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: palette,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(-6, -6),
                  ),
                  BoxShadow(
                    color: palette.first.withValues(alpha: 0.32),
                    blurRadius: 26,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.pets_rounded,
                    size: size * 0.45,
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                  Positioned(
                    right: 10,
                    bottom: 8,
                    child: Container(
                      width: size * 0.3,
                      height: size * 0.3,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        badge,
                        size: size * 0.18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
