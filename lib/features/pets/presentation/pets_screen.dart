import 'package:doggylog/features/shared/application/doggylog_providers.dart';
import 'package:doggylog/features/shared/data/sample_data.dart';
import 'package:doggylog/features/shared/presentation/widgets/liquid_glass_card.dart';
import 'package:doggylog/features/shared/presentation/widgets/soft_backdrop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PetsScreen extends ConsumerWidget {
  const PetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final controller = ref.read(appStateProvider.notifier);
    final activePet = state.selectedPet;
    return Scaffold(
      appBar: AppBar(title: const Text('宠物养成')),
      body: SoftBackdrop(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            LiquidGlassCard(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.18),
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.88),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('当前陪伴', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    activePet == null
                        ? '还没有选中宠物。'
                        : '${activePet.name} · 忠诚度 ${activePet.loyaltyPoints} · Lv.${activePet.loyaltyLevel}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...state.pets.map((pet) {
              final skins = defaultSkins[pet.breed] ?? const [];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: LiquidGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pet.name,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '忠诚度 ${pet.loyaltyPoints} · Lv.${pet.loyaltyLevel}',
                                ),
                              ],
                            ),
                          ),
                          ChoiceChip(
                            label: Text(pet.isSelected ? '当前陪伴' : '切换'),
                            selected: pet.isSelected,
                            onSelected: (_) => controller.selectPet(pet.id),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: skins.map((skin) {
                          final unlocked =
                              pet.unlockedSkinIds.contains(skin.id) ||
                              pet.loyaltyLevel >= skin.unlockLevel;
                          return FilterChip(
                            label: Text(
                              unlocked
                                  ? skin.name
                                  : '${skin.name} Lv.${skin.unlockLevel}',
                            ),
                            selected: pet.selectedSkinId == skin.id,
                            onSelected: unlocked
                                ? (_) =>
                                      controller.updatePetSkin(pet.id, skin.id)
                                : null,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
