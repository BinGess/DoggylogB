import 'package:doggylog/app/localization/app_localizations.dart';
import 'package:doggylog/features/shared/presentation/widgets/animated_pet_avatar.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:doggylog/features/shared/presentation/widgets/liquid_glass_card.dart';
import 'package:flutter/material.dart';

class PetCompanionCard extends StatelessWidget {
  const PetCompanionCard({
    super.key,
    required this.pet,
    required this.mood,
    required this.sceneMode,
    required this.onLongPress,
  });

  final PetProfile? pet;
  final PetMood mood;
  final SceneMode sceneMode;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pet = this.pet;
    final l10n = context.l10n;
    return GestureDetector(
      onLongPress: onLongPress,
      child: LiquidGlassCard(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary.withValues(alpha: 0.30),
            scheme.secondary.withValues(alpha: 0.16),
            Colors.white.withValues(alpha: 0.10),
          ],
        ),
        child: Row(
          children: [
            AnimatedPetAvatar(
              breed: pet?.breed ?? PetBreed.shiba,
              mood: mood,
              sceneMode: sceneMode,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet == null
                        ? l10n.pickFirstPup
                        : l10n.petCompanionTitle(
                            l10n.localizedStoredText(pet.name),
                          ),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _moodCopy(context, mood, sceneMode),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _TinyPill(
                        label: pet == null
                            ? l10n.noPetChosen
                            : l10n.levelLabel(pet.loyaltyLevel),
                        icon: Icons.star_rounded,
                      ),
                      _TinyPill(
                        label: l10n.sceneLabel(sceneMode),
                        icon: Icons.location_on_rounded,
                      ),
                      _TinyPill(
                        label: l10n.longPressFetch,
                        icon: Icons.sports_baseball_rounded,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _moodCopy(
    BuildContext context,
    PetMood mood,
    SceneMode sceneMode,
  ) {
    final l10n = context.l10n;
    if (sceneMode == SceneMode.walking) {
      return l10n.walkingModeCopy;
    }
    return l10n.moodCopy(mood);
  }
}

class _TinyPill extends StatelessWidget {
  const _TinyPill({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 16), const SizedBox(width: 6), Text(label)],
      ),
    );
  }
}
