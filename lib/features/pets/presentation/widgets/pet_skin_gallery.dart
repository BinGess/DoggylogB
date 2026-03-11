import 'package:doggylog/app/localization/app_localizations.dart';
import 'package:doggylog/app/theme/app_skin_theme.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:flutter/material.dart';

const _skinPreviewDogAssets = [
  'assets/images/calendar/calendar_dog_timeline.png',
  'assets/images/calendar/calendar_dog1_timeline.png',
  'assets/images/calendar/calendar_dog2_timeline.png',
  'assets/images/calendar/calendar_dog3_timeline.png',
];

class PetSkinGallery extends StatelessWidget {
  const PetSkinGallery({
    super.key,
    required this.pets,
    required this.selectedPetId,
    required this.onPetSelected,
  });

  final List<PetProfile> pets;
  final String? selectedPetId;
  final ValueChanged<String> onPetSelected;

  @override
  Widget build(BuildContext context) {
    // Keep breed slots stable according to the incoming pet order.
    // If multiple pets share a breed, swap only the representative inside that
    // fixed slot so the selected skin can still appear selected without
    // reordering the whole gallery.
    final petsByBreed = <PetBreed, List<PetProfile>>{};
    final orderedBreeds = <PetBreed>[];
    for (final pet in pets) {
      if (!isPetSkinVisibleInManagement(pet.breed)) {
        continue;
      }
      final breedPets = petsByBreed.putIfAbsent(pet.breed, () {
        orderedBreeds.add(pet.breed);
        return <PetProfile>[];
      });
      breedPets.add(pet);
    }

    final uniquePets = [
      for (final breed in orderedBreeds)
        petsByBreed[breed]!.firstWhere(
          (pet) => pet.id == selectedPetId,
          orElse: () => petsByBreed[breed]!.first,
        ),
    ];

    return Column(
      children: [
        for (var index = 0; index < uniquePets.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _PetSkinCard(
              pet: uniquePets[index],
              previewAsset:
                  _skinPreviewDogAssets[index % _skinPreviewDogAssets.length],
              isSelected: uniquePets[index].id == selectedPetId,
              onTap: () => onPetSelected(uniquePets[index].id),
            ),
          ),
      ],
    );
  }
}

class _PetSkinCard extends StatelessWidget {
  const _PetSkinCard({
    required this.pet,
    required this.previewAsset,
    required this.isSelected,
    required this.onTap,
  });

  final PetProfile pet;
  final String previewAsset;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final skinTheme = appSkinThemeForBreed(pet.breed);
    final spec = skinTheme.spec;
    final borderColor = spec.primaryLight.withValues(
      alpha: isSelected ? 0.75 : 0.24,
    );
    final labelColor = spec.onSurfaceVariantLight;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('pet-skin-card-${pet.id}'),
        borderRadius: BorderRadius.circular(spec.cardRadius + 4),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(spec.cardRadius + 4),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                spec.backgroundLight,
                spec.cardLight.first,
                spec.cardLight.last,
              ],
            ),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 2.2 : 1.2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 82,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(spec.cardRadius),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        spec.primaryLight.withValues(alpha: 0.20),
                        spec.secondaryLight.withValues(alpha: 0.18),
                        Colors.white.withValues(alpha: 0.92),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 10,
                        left: 12,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Colors.white.withValues(alpha: 0.72),
                            border: Border.all(
                              color: spec.primaryLight.withValues(alpha: 0.16),
                            ),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset(
                                  previewAsset,
                                  fit: BoxFit.cover,
                                  alignment: Alignment.centerLeft,
                                  filterQuality: FilterQuality.medium,
                                ),
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        spec.primaryLight.withValues(
                                          alpha: 0.18,
                                        ),
                                        spec.secondaryLight.withValues(
                                          alpha: 0.12,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: spec.backgroundLight.withValues(
                                      alpha: 0.08,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 20,
                        right: 16,
                        child: _PreviewOrb(
                          size: 42,
                          color: spec.secondaryLight.withValues(alpha: 0.24),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        left: 12,
                        right: 12,
                        child: Container(
                          height: 26,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Colors.white.withValues(alpha: 0.82),
                            border: Border.all(
                              color: spec.primaryLight.withValues(alpha: 0.14),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              Icon(
                                Icons.pets_rounded,
                                size: 16,
                                color: spec.primaryLight,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  context.l10n.localizedSkinStyleName(
                                    spec.styleName,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: spec.onSurfaceVariantLight,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pet.name,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: spec.onSurfaceVariantLight,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${context.l10n.breedLabel(pet.breed)} · ${context.l10n.localizedSkinStyleName(spec.styleName)}',
                            style: Theme.of(
                              context,
                            ).textTheme.labelMedium?.copyWith(
                              color: labelColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _StatusBadge(
                      label: isSelected
                          ? context.l10n.currentSkinBadge
                          : context.l10n.tapToSwitchSkin,
                      background: isSelected
                          ? spec.primaryLight
                          : spec.primaryLight.withValues(alpha: 0.10),
                      foreground: isSelected ? Colors.white : spec.primaryLight,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  context.l10n.localizedSkinDescription(spec),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: labelColor,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewOrb extends StatelessWidget {
  const _PreviewOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withValues(alpha: color.a * 0.25),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
