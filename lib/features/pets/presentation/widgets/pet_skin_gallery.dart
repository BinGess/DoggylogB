import 'package:doggylog/app/theme/app_skin_theme.dart';
import 'package:doggylog/features/shared/domain/models.dart';
import 'package:flutter/material.dart';

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
    return Column(
      children: [
        for (final pet in pets)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _PetSkinCard(
              pet: pet,
              isSelected: pet.id == selectedPetId,
              onTap: () => onPetSelected(pet.id),
            ),
          ),
      ],
    );
  }
}

class _PetSkinCard extends StatelessWidget {
  const _PetSkinCard({
    required this.pet,
    required this.isSelected,
    required this.onTap,
  });

  final PetProfile pet;
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
            boxShadow: [
              BoxShadow(
                color: spec.shadowLight.withValues(
                  alpha: isSelected ? 0.42 : 0.22,
                ),
                blurRadius: isSelected ? 28 : 16,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 108,
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
                        top: 12,
                        left: 14,
                        child: _PreviewOrb(
                          size: 44,
                          color: spec.primaryLight.withValues(alpha: 0.34),
                        ),
                      ),
                      Positioned(
                        top: 28,
                        right: 24,
                        child: _PreviewOrb(
                          size: 58,
                          color: spec.secondaryLight.withValues(alpha: 0.24),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        left: 18,
                        right: 18,
                        child: Container(
                          height: 34,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: Colors.white.withValues(alpha: 0.82),
                            border: Border.all(
                              color: spec.primaryLight.withValues(alpha: 0.14),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              Icon(
                                Icons.pets_rounded,
                                color: spec.primaryLight,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  spec.styleName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: spec.onSurfaceVariantLight,
                                    fontWeight: FontWeight.w700,
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
                const SizedBox(height: 16),
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
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${breedLabel(pet.breed)} · ${spec.styleName}',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: labelColor),
                          ),
                        ],
                      ),
                    ),
                    _StatusBadge(
                      label: isSelected ? '当前皮肤' : '点击切换',
                      background: isSelected
                          ? spec.primaryLight
                          : spec.primaryLight.withValues(alpha: 0.10),
                      foreground: isSelected ? Colors.white : spec.primaryLight,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  spec.styleDescription,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: labelColor,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    ...[
                      spec.primaryLight,
                      spec.secondaryLight,
                      spec.backgroundLight,
                    ].map(
                      (color) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _PreviewOrb(size: 16, color: color),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Lv.${pet.loyaltyLevel}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: spec.primaryLight,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
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
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

String breedLabel(PetBreed breed) {
  return switch (breed) {
    PetBreed.shiba => 'Shiba',
    PetBreed.goldenRetriever => 'Golden Retriever',
    PetBreed.beagle => 'Beagle',
    PetBreed.husky => 'Husky',
  };
}
